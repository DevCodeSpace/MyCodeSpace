import 'dart:io';
import 'dart:typed_data';

import 'package:authenticator/app/routes/app_routes.dart';
import 'package:authenticator/modules/settings/settings_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/database_service.dart';
import '../../core/services/encryption_service.dart';
import '../../models/document_folder.dart';
import '../../models/document_model.dart';

class DocumentsController extends GetxController {
  final documents = <DocumentModel>[].obs;
  final filtered = <DocumentModel>[].obs;
  final folders = <DocumentFolder>[].obs;
  final searchQuery = ''.obs;
  final selectedFolderId = RxnString();
  final isLoading = false.obs;
  final selectedDocument = Rx<DocumentModel?>(null);
  var isEditMode = false.obs;
  var selectedDocIds = <String>{}.obs; // Stores selected Document IDs (Using String or int depending on your ID type)

  static const _uuid = Uuid();

  DatabaseService get _db => Get.find<DatabaseService>();
  EncryptionService get _enc => Get.find<EncryptionService>();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    await loadFolders();
    await loadDocuments(showLoader: false);
    isLoading.value = false;
  }

  Future<void> loadFolders() async {
    folders.value = await _db.getAllDocumentFolders();
    if (selectedFolderId.value != null && !folders.any((f) => f.id == selectedFolderId.value)) {
      selectedFolderId.value = null;
    }
    _applyFilter();
  }

  Future<void> loadDocuments({bool showLoader = true}) async {
    if (showLoader) {
      isLoading.value = true;
    }
    documents.value = await _db.getAllDocuments();
    _applyFilter();
    if (showLoader) {
      isLoading.value = false;
    }
  }

  void onSearch(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void selectFolder(String? folderId) {
    selectedFolderId.value = folderId;
    _applyFilter();
    Get.toNamed(AppRoutes.folder);
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      selectedDocIds.clear(); // Clear selections when exiting edit mode
    }
  }

  void toggleSelection(String docId) {
    if (selectedDocIds.contains(docId)) {
      selectedDocIds.remove(docId);
    } else {
      selectedDocIds.add(docId);
    }
  }

  String? folderNameById(String? folderId) {
    if (folderId == null) return null;
    for (final folder in folders) {
      if (folder.id == folderId) return folder.name;
    }
    return null;
  }

  Future<bool> createFolder(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      Get.snackbar('Folder Required', 'Please enter a folder name');
      return false;
    }
    if (folders.any((f) => f.name.toLowerCase() == name.toLowerCase())) {
      Get.snackbar('Already Exists', 'A folder named "$name" already exists');
      return false;
    }

    final folder = DocumentFolder(id: _uuid.v4(), name: name, createdAt: DateTime.now(), updatedAt: DateTime.now());
    await _db.insertDocumentFolder(folder);
    await loadFolders();
    selectedFolderId.value = folder.id;
    _applyFilter();
    Get.snackbar('Folder Created', '$name is ready');
    return true;
  }

  Future<void> deleteFolder(DocumentFolder folder) async {
    await _db.deleteDocumentFolder(folder.id);
    if (selectedFolderId.value == folder.id) {
      selectedFolderId.value = null;
    }
    await loadFolders();
    await loadDocuments(showLoader: false);
    Get.snackbar('Folder Deleted', '${folder.name} removed');
  }

  void _applyFilter() {
    var list = documents.toList();
    if (selectedFolderId.value != null) {
      list = list.where((d) => d.folderId == selectedFolderId.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((d) => d.name.toLowerCase().contains(q)).toList();
    }
    filtered.value = list;
  }

  Future<void> pickAndSaveFile({String? folderId}) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false, withData: false);
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;
    await _importFile(File(picked.path!), picked.name, folderId: folderId);
  }

  Future<void> pickImageFromCamera({String? folderId}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    await _importFile(File(image.path), p.basename(image.path), folderId: folderId);
  }

  Future<void> pickImageFromGallery({String? folderId}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await _importFile(File(image.path), p.basename(image.path), folderId: folderId);
  }

  Future<void> _importFile(File source, String originalName, {String? folderId}) async {
    isLoading.value = true;
    try {
      final bytes = await source.readAsBytes();
      final encryptedBytes = _enc.encryptBytes(Uint8List.fromList(bytes));

      final dir = await _vaultDir();
      final id = _uuid.v4();
      final ext = p.extension(originalName);
      final encFileName = '$id$ext.enc';
      final destPath = p.join(dir.path, encFileName);

      await File(destPath).writeAsBytes(encryptedBytes);

      final ext2 = ext.replaceFirst('.', '');
      final doc = DocumentModel(
        id: id,
        name: p.basenameWithoutExtension(originalName),
        fileName: encFileName,
        filePath: destPath,
        type: DocumentModel.typeFromExtension(ext2),
        folderId: folderId,
        size: bytes.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.insertDocument(doc);
      await loadDocuments(showLoader: false);
      Get.find<SettingsController>().loadStats();
      Get.snackbar('Saved', '${doc.name} added to SecureAuth Vault');
    } catch (e) {
      Get.snackbar('Error', 'Could not import file: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Uint8List?> readDecryptedBytes(DocumentModel doc) async {
    try {
      final encrypted = await File(doc.filePath).readAsBytes();
      return _enc.decryptBytes(Uint8List.fromList(encrypted));
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    try {
      final file = File(doc.filePath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    await _db.deleteDocument(doc.id);
  }

  Future<void> deleteSingleDocument(DocumentModel doc) async {
    await deleteDocument(doc);
    await loadDocuments(showLoader: false);
    Get.find<SettingsController>().loadStats();
  }

  Future<void> deleteSelectedDocuments() async {
    // Logic to delete all documents whose IDs are in selectedDocIds
    final itemsToDelete = filtered.where((doc) => selectedDocIds.contains(doc.id)).toList();

    for (var doc in itemsToDelete) {
      await deleteDocument(doc);
    }

    // Clean up state
    isEditMode.value = false;
    selectedDocIds.clear();
    await loadDocuments(showLoader: false);
    Get.find<SettingsController>().loadStats();

    Get.snackbar('Success', 'Deleted ${itemsToDelete.length} item(s) successfully', snackPosition: SnackPosition.BOTTOM);
  }

  Future<Directory> _vaultDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'vault_docs'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> showDeleteFolderDialog(BuildContext context) async {
    final folderId = selectedFolderId.value;
    if (folderId == null) return;

    final folderToDelete = folders.firstWhereOrNull((f) => f.id == folderId);
    if (folderToDelete == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        title: const Text('Delete Folder?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(
          'Are you sure you want to delete "${folderToDelete.name}"? The contained files will not be erased and will return to your general folder profile.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Get.back();
              await deleteFolder(folderToDelete);
            },
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
