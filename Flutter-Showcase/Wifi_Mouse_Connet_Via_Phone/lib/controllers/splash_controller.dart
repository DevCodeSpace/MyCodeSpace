import 'package:get/get.dart';
import 'package:mouse_demo/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigateToMain();
  }

  void navigateToMain() {
    Future.delayed(Duration(seconds: 3), () => Get.toNamed(AppRoutes.deviceList));
  }
}
