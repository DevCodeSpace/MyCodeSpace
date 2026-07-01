import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:codex_share/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/services/device_catalog_service.dart';
import '../../data/services/permission_service.dart';
import '../../domain/entities/shared_file.dart';
import '../../domain/entities/transfer_history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import 'connection_controller.dart';
import 'transfer_controller.dart';

enum SendLibraryTab { apps, files, images, videos, recent }

class SendController extends GetxController {
  SendController({
    required this.transferController,
    required this.connectionController,
    required this.historyRepository,
    required this.permissionService,
    required this.deviceCatalogService,
  });

  final TransferController transferController;
  final ConnectionController connectionController;
  final HistoryRepository historyRepository;
  final PermissionService permissionService;
  final DeviceCatalogService deviceCatalogService;

  StreamSubscription<List<TransferHistoryEntry>>? _historySubscription;

  final selectedFiles = <SharedFile>[].obs;
  final recentEntries = <TransferHistoryEntry>[].obs;
  final availableApps = <SharedFile>[].obs;
  final availableImages = <SharedFile>[].obs;
  final availableVideos = <SharedFile>[].obs;
  final availableDocuments = <SharedFile>[].obs;
  final isPreparing = false.obs;
  final isLoadingLibrary = false.obs;
  final isLoadingMore = false.obs;
  final activeTab = SendLibraryTab.apps.obs;
  final thumbnailCache = <String, Uint8List>{}.obs;
  final _loadingThumbnails = <String>{}.obs;
  final _thumbnailQueue = <SharedFile>[];
  bool _isProcessingQueue = false;

  // Pagination State
  final _offsets = <SendLibraryTab, int>{
    SendLibraryTab.images: 0,
    SendLibraryTab.videos: 0,
    SendLibraryTab.files: 0,
  };
  final _hasMore = <SendLibraryTab, bool>{
    SendLibraryTab.images: true,
    SendLibraryTab.videos: true,
    SendLibraryTab.files: true,
  };
  static const int _pageSize = 60;

  // Search and File Manager
  final searchQuery = ''.obs;
  final currentPath = RxnString();
  final pathHistory = <String?>[].obs;
  final TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _historySubscription = historyRepository.watchHistory().listen((entries) {
      recentEntries.assignAll(entries.take(12));
    });
  }

  @override
  void onReady() {
    super.onReady();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    // Load active tab first for immediate responsiveness
    await loadActiveTab();

    // Then pre-fetch other tabs in the background
    _prefetchOthers();
  }

  Future<void> _prefetchOthers() async {
    final granted = await permissionService.ensureTransferPermissions();
    if (!granted) return;

    try {
      // Pre-fetch first page in background
      if (availableImages.isEmpty) {
        deviceCatalogService.getImages(limit: _pageSize).then((files) {
          availableImages.assignAll(files);
          _offsets[SendLibraryTab.images] = files.length;
          _hasMore[SendLibraryTab.images] = files.length >= _pageSize;
        });
      }
      if (availableVideos.isEmpty) {
        deviceCatalogService.getVideos(limit: _pageSize).then((files) {
          availableVideos.assignAll(files);
          _offsets[SendLibraryTab.videos] = files.length;
          _hasMore[SendLibraryTab.videos] = files.length >= _pageSize;
        });
      }
    } catch (_) {
      // Background pre-fetch failures are silent
    }
  }

  @override
  void onClose() {
    selectedFiles.clear();
    _historySubscription?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  List<SharedFile> get visibleFiles {
    final query = searchQuery.value.toLowerCase();
    List<SharedFile> files = switch (activeTab.value) {
      SendLibraryTab.apps => availableApps,
      SendLibraryTab.images => availableImages,
      SendLibraryTab.videos => availableVideos,
      SendLibraryTab.recent => const <SharedFile>[],
      SendLibraryTab.files => availableDocuments,
    };

    if (query.isEmpty) return files;

    return files.where((file) {
      return file.name.toLowerCase().contains(query) ||
          (file.secondaryLabel?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
  }

  Future<void> navigateToDirectory(SharedFile folder) async {
    if (!folder.isFolder) return;
    pathHistory.add(currentPath.value);
    currentPath.value = folder.path;
    availableDocuments.clear();
    await loadActiveTab();
  }

  Future<void> navigateBack() async {
    if (pathHistory.isEmpty) return;
    currentPath.value = pathHistory.removeLast();
    availableDocuments.clear();
    await loadActiveTab();
  }

  Future<void> loadActiveTab() async {
    if (activeTab.value == SendLibraryTab.recent) return;

    // Determine if we actually need to show a loading indicator
    final needsFetch = switch (activeTab.value) {
      SendLibraryTab.apps => availableApps.isEmpty,
      SendLibraryTab.images => availableImages.isEmpty,
      SendLibraryTab.videos => availableVideos.isEmpty,
      SendLibraryTab.files => availableDocuments.isEmpty,
      _ => false,
    };

    if (!needsFetch) {
      isLoadingLibrary.value = false;
      return;
    }

    final granted = await permissionService.ensureTransferPermissions();
    if (!granted) {
      Get.snackbar('Permission needed', 'Storage access is required.');
      return;
    }

    isLoadingLibrary.value = true;
    try {
      switch (activeTab.value) {
        case SendLibraryTab.apps:
          availableApps.assignAll(
            await deviceCatalogService.getInstalledApps(),
          );
          break;
        case SendLibraryTab.images:
          final files = await deviceCatalogService.getImages(
            limit: _pageSize,
            offset: 0,
          );
          availableImages.assignAll(files);
          _offsets[SendLibraryTab.images] = files.length;
          _hasMore[SendLibraryTab.images] = files.length >= _pageSize;
          break;
        case SendLibraryTab.videos:
          final files = await deviceCatalogService.getVideos(
            limit: _pageSize,
            offset: 0,
          );
          availableVideos.assignAll(files);
          _offsets[SendLibraryTab.videos] = files.length;
          _hasMore[SendLibraryTab.videos] = files.length >= _pageSize;
          break;
        case SendLibraryTab.files:
          // Default to Internal Storage root if no path is set
          final targetPath = currentPath.value ?? '/storage/emulated/0';
          availableDocuments.assignAll(
            await deviceCatalogService.getFileSystemItems(targetPath),
          );
          _hasMore[SendLibraryTab.files] = false;
          break;
        case SendLibraryTab.recent:
          break;
      }
    } catch (error) {
      Get.snackbar('Unable to load library', '$error');
    } finally {
      isLoadingLibrary.value = false;
    }
  }

  Future<void> loadMore() async {
    final tab = activeTab.value;
    if (isLoadingMore.value || !(_hasMore[tab] ?? false)) return;

    isLoadingMore.value = true;
    try {
      final offset = _offsets[tab] ?? 0;
      List<SharedFile> newFiles = [];

      switch (tab) {
        case SendLibraryTab.images:
          newFiles = await deviceCatalogService.getImages(
            limit: _pageSize,
            offset: offset,
          );
          availableImages.addAll(newFiles);
          break;
        case SendLibraryTab.videos:
          newFiles = await deviceCatalogService.getVideos(
            limit: _pageSize,
            offset: offset,
          );
          availableVideos.addAll(newFiles);
          break;
        case SendLibraryTab.files:
          if (currentPath.value == null) {
            newFiles = await deviceCatalogService.getDocuments(
              limit: _pageSize,
              offset: offset,
            );
            availableDocuments.addAll(newFiles);
          }
          break;
        default:
          break;
      }

      if (newFiles.isNotEmpty) {
        _offsets[tab] = offset + newFiles.length;
        _hasMore[tab] = newFiles.length >= _pageSize;
      } else {
        _hasMore[tab] = false;
      }
    } catch (e) {
      debugPrint('Error loading more: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> setActiveTab(SendLibraryTab tab) async {
    activeTab.value = tab;
    await loadActiveTab();
  }

  void toggleSelection(SharedFile file) {
    final exists = selectedFiles.any((item) => item.path == file.path);
    if (exists) {
      selectedFiles.removeWhere((item) => item.path == file.path);
    } else {
      selectedFiles.add(file);
    }
  }

  bool isSelected(SharedFile file) {
    return selectedFiles.any((item) => item.path == file.path);
  }

  Future<void> shareAgain(TransferHistoryEntry entry) async {
    if (entry.filePath.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'This transfer does not include a local path.',
      );
      return;
    }

    final file = File(entry.filePath);
    if (!await file.exists()) {
      Get.snackbar('Missing file', 'The file is no longer available.');
      return;
    }

    final sharedFile = SharedFile(
      id: '${entry.id}-${DateTime.now().microsecondsSinceEpoch}',
      name: entry.fileName,
      path: entry.filePath,
      size: entry.fileSize,
      category: entry.fileCategory,
    );

    if (!isSelected(sharedFile)) {
      selectedFiles.add(sharedFile);
    }

    activeTab.value = switch (entry.fileCategory) {
      FileCategory.app => SendLibraryTab.apps,
      FileCategory.image => SendLibraryTab.images,
      FileCategory.video => SendLibraryTab.videos,
      _ => SendLibraryTab.files,
    };
    await loadActiveTab();
  }

  Future<bool> startSending() async {
    if (selectedFiles.isEmpty) return false;

    if (!connectionController.isConnected.value) {
      Get.toNamed(AppRoutes.discovery);
      return false;
    }

    isPreparing.value = true;
    try {
      await transferController.startSharing(selectedFiles);
      final accepted = await connectionController.requestTransfer();
      if (!accepted) {
        await transferController.cancel();
      }
      return accepted;
    } catch (e) {
      await transferController.cancel();
      return false;
    } finally {
      isPreparing.value = false;
    }
  }

  void removeFile(String id) {
    selectedFiles.removeWhere((file) => file.id == id);
  }

  String get totalSelectedSizeLabel {
    final bytes = selectedFiles.fold<int>(0, (sum, f) => sum + f.size);
    return Formatters.fileSize(bytes);
  }

  Future<void> sendSelectedFiles() async {
    final started = await startSending();
    if (started && transferController.errorText.value == null) {
      selectedFiles.clear();
      Get.toNamed(AppRoutes.transfer);
    }
  }

  Future<Uint8List?> getThumbnail(SharedFile file) async {
    if (thumbnailCache.containsKey(file.path)) {
      return thumbnailCache[file.path];
    }
    
    if (_loadingThumbnails.contains(file.path) || _thumbnailQueue.any((f) => f.path == file.path)) {
      return null;
    }

    _thumbnailQueue.add(file);
    
    // Ensure queue processing starts outside the current build frame
    Future.microtask(() => _processThumbnailQueue());
    return null;
  }

  Future<void> _processThumbnailQueue() async {
    if (_isProcessingQueue || _thumbnailQueue.isEmpty) return;
    _isProcessingQueue = true;

    while (_thumbnailQueue.isNotEmpty) {
      final file = _thumbnailQueue.removeAt(0);
      if (thumbnailCache.containsKey(file.path) || _loadingThumbnails.contains(file.path)) continue;

      _loadingThumbnails.add(file.path);
      try {
        final bytes = await deviceCatalogService.getThumbnail(
          file.path,
          file.category,
        );
        if (bytes != null) {
          if (thumbnailCache.length > 500) thumbnailCache.clear();
          thumbnailCache[file.path] = bytes;
        }
      } catch (e) {
        debugPrint('Thumbnail error: $e');
      } finally {
        _loadingThumbnails.remove(file.path);
      }
      // Small delay to prevent bridge flooding
      await Future.delayed(const Duration(milliseconds: 10));
    }

    _isProcessingQueue = false;
  }
}
