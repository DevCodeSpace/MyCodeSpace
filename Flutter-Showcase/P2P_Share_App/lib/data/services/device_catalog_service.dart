import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/file_type_helper.dart';
import '../../domain/entities/shared_file.dart';

class DeviceCatalogService {
  static const MethodChannel _channel = MethodChannel(
    AppConstants.nativeCatalogChannel,
  );

  Future<List<SharedFile>> getInstalledApps() async {
    final items = await _invokeList('getInstalledApps');
    return compute(_mapApps, items);
  }

  Future<List<SharedFile>> getImages({int limit = 50, int offset = 0}) async {
    final items = await _invokeList('getImages', arguments: {'limit': limit, 'offset': offset});
    return compute(_mapImages, items);
  }

  Future<List<SharedFile>> getVideos({int limit = 50, int offset = 0}) async {
    final items = await _invokeList('getVideos', arguments: {'limit': limit, 'offset': offset});
    return compute(_mapVideos, items);
  }

  Future<List<SharedFile>> getDocuments({int limit = 50, int offset = 0}) async {
    final items = await _invokeList('getDocuments', arguments: {'limit': limit, 'offset': offset});
    return compute(_mapDocuments, items);
  }

  Future<List<SharedFile>> getFileSystemItems(String? path) async {
    final items = await _invokeList('getFileSystemItems', arguments: {'path': path});
    return compute(_mapFileSystemItems, items);
  }

  Future<Uint8List?> getThumbnail(String path, FileCategory category) async {
    final result = await _channel.invokeMethod<String>('getThumbnail', {
      'path': path,
      'category': category.name,
    });
    return _decodeBytes(result);
  }

  Future<String?> publishReceivedFile({
    required String sourcePath,
    required String fileName,
    required FileCategory category,
  }) async {
    final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'publishReceivedFile',
      {
        'sourcePath': sourcePath,
        'fileName': fileName,
        'category': category.name,
      },
    );

    if (response == null) return null;
    final normalized = response.map((key, value) => MapEntry('$key', value));
    return normalized['path'] as String?;
  }

  Future<List<Map<String, dynamic>>> _invokeList(String method, {Map<String, dynamic>? arguments}) async {
    final response = await _channel.invokeMethod<List<dynamic>>(method, arguments);
    return (response ?? const <dynamic>[])
        .cast<Map<dynamic, dynamic>>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList();
  }

  // --- Static Mapping Functions for compute ---

  static List<SharedFile> _mapApps(List<Map<String, dynamic>> items) {
    return items
        .map(
          (item) => SharedFile(
            id: item['id'] as String,
            name: item['name'] as String,
            path: item['path'] as String,
            size: (item['size'] as num?)?.toInt() ?? 0,
            category: FileCategory.app,
            secondaryLabel: item['packageName'] as String?,
            thumbnailBytes: null, // Load lazily
          ),
        )
        .toList();
  }

  static List<SharedFile> _mapImages(List<Map<String, dynamic>> items) {
    return items
        .map(
          (item) => SharedFile(
            id: item['id'] as String,
            name: item['name'] as String,
            path: item['path'] as String,
            size: (item['size'] as num?)?.toInt() ?? 0,
            category: FileCategory.image,
            thumbnailBytes: null, // Load lazily
          ),
        )
        .toList();
  }

  static List<SharedFile> _mapVideos(List<Map<String, dynamic>> items) {
    return items
        .map(
          (item) => SharedFile(
            id: item['id'] as String,
            name: item['name'] as String,
            path: item['path'] as String,
            size: (item['size'] as num?)?.toInt() ?? 0,
            category: FileCategory.video,
            durationMillis: (item['durationMillis'] as num?)?.toInt(),
            thumbnailBytes: null, // Load lazily
          ),
        )
        .toList();
  }

  static List<SharedFile> _mapDocuments(List<Map<String, dynamic>> items) {
    return items
        .map(
          (item) => SharedFile(
            id: item['id'] as String,
            name: item['name'] as String,
            path: item['path'] as String,
            size: (item['size'] as num?)?.toInt() ?? 0,
            category: FileTypeHelper.detect(item['name'] as String),
            secondaryLabel: item['mimeType'] as String?,
          ),
        )
        .toList();
  }

  static List<SharedFile> _mapFileSystemItems(List<Map<String, dynamic>> items) {
    return items
        .map(
          (item) => SharedFile(
            id: item['id'] as String,
            name: item['name'] as String,
            path: item['path'] as String,
            size: (item['size'] as num?)?.toInt() ?? 0,
            category: (item['isFolder'] as bool? ?? false)
                ? FileCategory.document // Folders don't have a specific category in FileCategory enum, use document or add one
                : FileTypeHelper.detect(item['name'] as String),
            isFolder: item['isFolder'] as bool? ?? false,
            secondaryLabel: item['mimeType'] as String?,
          ),
        )
        .toList();
  }

  static Uint8List? _decodeBytes(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }
}
