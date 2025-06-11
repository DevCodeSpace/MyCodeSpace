import 'package:get/get.dart';
import 'package:soothly/Controller/dashboard_controller.dart';
import 'package:soothly/Controller/onboarding_controller.dart';
import 'package:soothly/Controller/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OnboardingController());
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
  }
}
