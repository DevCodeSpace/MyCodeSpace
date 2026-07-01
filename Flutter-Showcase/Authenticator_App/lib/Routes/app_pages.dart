import 'package:authenticator/Controller/auth_controller.dart';
import 'package:authenticator/Controller/scan_controller.dart';
import 'package:authenticator/Routes/app_route.dart';
import 'package:authenticator/Scan/scan_screen.dart';
import 'package:authenticator/dashboard/dashboard_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen(), binding: AuthBinding()),
    GetPage(name: AppRoutes.scanner, page: () => const ScannerScreen(), binding: ScannerBinding()),
  ];
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController());
    }
  }
}

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScannerController>(() => ScannerController());
  }
}
