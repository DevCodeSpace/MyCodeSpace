import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_app_usage/core/services/usage_service.dart';
import '../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    final usageService = Get.put(UsageService());

    try {
      await usageService.initService();
    } catch (e) {
      Get.printError(info: "Error initializing usage service: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    Get.offAllNamed(completed ? AppRoutes.dashboard : AppRoutes.onboarding);
  }
}
