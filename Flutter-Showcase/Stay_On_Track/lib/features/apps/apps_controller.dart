import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/usage_service.dart';
import '../../core/models/usage_model.dart';

class AppsController extends GetxController {
  final UsageService usageService = Get.find<UsageService>();
  final searchController = TextEditingController();

  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<String> get categories => ['All', 'Social Media', 'Entertainment', 'Productivity', 'Communication'];

  List<AppUsageInfo> get filteredApps {
    return usageService.apps.where((app) {
      final matchesSearch = app.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      final matchesCategory = selectedCategory.value == 'All' || app.category == selectedCategory.value;
      return matchesSearch && matchesCategory;
    }).toList()..sort((a, b) => b.elapsedMinutes.compareTo(a.elapsedMinutes));
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  final RxBool notificationsSilenced = false.obs;

  void toggleNotifications() {
    notificationsSilenced.toggle();
  }
}
