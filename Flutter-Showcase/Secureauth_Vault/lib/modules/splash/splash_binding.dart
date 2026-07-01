import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Splash logic must start immediately when the route opens.
    // lazyPut waits until first Get.find(), but SplashView doesn't read controller.
    Get.put<SplashController>(SplashController());
  }
}
