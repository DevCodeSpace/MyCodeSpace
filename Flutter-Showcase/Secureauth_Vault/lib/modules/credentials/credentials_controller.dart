import 'package:authenticator/modules/settings/settings_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/services/database_service.dart';
import '../../core/utils/app_constants.dart';
import '../../models/category.dart';
import '../../models/credential.dart';

class CredentialsController extends GetxController {
  final credentials = <Credential>[].obs;
  final categories = <Category>[].obs;
  final filtered = <Credential>[].obs;
  final selectedCategory = Rx<Category?>(null);
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final selectedCredential = Rx<Credential?>(null);
  final showFav = false.obs;

  DatabaseService get _db => Get.find<DatabaseService>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([loadCredentials(), loadCategories()]);
    isLoading.value = false;
  }

  Future<void> loadCredentials() async {
    credentials.value = await _db.getAllCredentials();
    _applyFilters();
  }

  Future<void> loadCategories() async {
    categories.value = await _db.getCategories(AppConstants.categoryTypeCredential);
  }

  void onFavChange() {
    showFav.toggle();
    _applyFilters();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void selectCategory(Category? cat) {
    selectedCategory.value = cat;
    _applyFilters();
  }

  void _applyFilters() {
    var list = credentials.toList();
    // Favorite filter
    if (showFav.value) {
      list = list.where((c) => c.isFavorite).toList();
    }
    if (selectedCategory.value != null) {
      list = list.where((c) => c.categoryId == selectedCategory.value!.id).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((c) => c.title.toLowerCase().contains(q) || c.url.toLowerCase().contains(q) || c.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    filtered.value = list;
  }

  Future<void> addCredential(Credential cred) async {
    await _db.insertCredential(cred);
    await loadCredentials();
    Get.find<SettingsController>().loadStats();
  }

  Future<void> updateCredential(Credential cred) async {
    await _db.updateCredential(cred);
    await loadCredentials();
    Get.snackbar('Updated', '${cred.title} is updated');
    if (selectedCredential.value?.id == cred.id) {
      selectedCredential.value = cred;
    }
  }

  Future<void> deleteCredential(String id) async {
    await _db.deleteCredential(id);
    await loadCredentials();
  }

  Future<void> toggleFavorite(Credential cred) async {
    await updateCredential(cred.copyWith(isFavorite: !cred.isFavorite));
  }

  void copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    Get.snackbar('Copied', '$label copied to clipboard', duration: const Duration(seconds: 2));
  }

  Category? categoryById(String? id) {
    if (id == null) return null;
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
