import 'package:get/get.dart';

import '../../controllers/splash_controller.dart';

/// Registers [SplashController] with GetX for the splash route.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}
