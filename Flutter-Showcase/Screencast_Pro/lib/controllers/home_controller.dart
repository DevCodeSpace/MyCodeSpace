import 'package:get/get.dart';
import '../app/routes/app_routes.dart';

// HomeController drives the Home screen (Android sender side).
// Its only job is navigation — no data fetching or state management here.
class HomeController extends GetxController {
  // Navigate to the WiFi device list.
  // DeviceController on the next screen starts the UDP broadcast scan automatically.
  void goToWifiDevices() {
    Get.toNamed(AppRoutes.devices);
  }

  // Navigates to the Browser Casting feature screen.
  // The PublicStreamController on the next screen will manage the HTTP server.
  void goToPublicStream() {
    Get.toNamed(AppRoutes.publicStream);
  }

  // Navigates to the TV Cast screen where the app discovers smart TVs via SSDP
  // and pushes the MJPEG stream to them using LG SSAP / DLNA / Samsung REST API.
  void goToTvCast() {
    Get.toNamed(AppRoutes.tvCast);
  }
}
