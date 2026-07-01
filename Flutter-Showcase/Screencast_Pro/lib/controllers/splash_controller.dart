import 'package:get/get.dart';

import '../app/routes/app_routes.dart';

/// A controller for the splash screen.
///
/// Its primary job is to wait for a few seconds and then navigate to the
/// correct starting screen based on the operating system.
class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for a short duration to show the splash screen.
    await Future.delayed(const Duration(milliseconds: 3500));

    // Determine the initial route based on the platform.
    // Android is the sender, others are receivers.
    Get.offNamed(GetPlatform.isAndroid ? AppRoutes.home : AppRoutes.receiver);
  }
}
