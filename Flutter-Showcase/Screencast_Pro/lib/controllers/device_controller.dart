import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/routes/app_routes.dart';
import '../models/cast_device.dart';
import '../services/discovery_service.dart';
import '../utils/app_colors.dart';
import '../utils/text_styles.dart';

// DeviceController manages the device-discovery screen (WiFi mode only).
//
// Flow:
//   1. onInit → requests location permission → reads WiFi SSID/IP → starts scan
//   2. startScan → sends UDP broadcast "SCREEN_CAST_DISCOVER" to subnet
//   3. Any Mac/PC running ReceiverService replies with name, IP, port
//   4. Replies appear in the device list within ~4 seconds
//   5. User taps a device → connectToDevice() → CastingView opens
class DeviceController extends GetxController {
  final _discovery = DiscoveryService(); // UDP-based WiFi device discovery

  // Observable state — CastingView wraps these with Obx() to rebuild on change
  final devices          = <CastDevice>[].obs; // Discovered receiver devices
  final isScanning       = false.obs;          // True while the UDP scan is running
  final permissionDenied = false.obs;          // True if location permission was denied
  final wifiSSID         = RxnString();        // Current WiFi network name (banner)
  final wifiIP           = RxnString();        // This device's IP on the WiFi network

  // Accent colour used for icons, progress bar, and scan label
  Color get accent => AppColors.wifiAccent;

  @override
  void onInit() {
    super.onInit();
    _initWifi(); // Request permission, load network info, then scan
  }

  @override
  void onClose() {
    _discovery.stopScan(); // Cancel any in-progress scan when leaving the screen
    super.onClose();
  }

  // ── WiFi initialisation ───────────────────────────────────────────────────

  // Request location permission (Android requires it to read WiFi SSID),
  // populate the network info banner, then auto-start the first scan.
  Future<void> _initWifi() async {
    try {
      final status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        permissionDenied.value = true;
        // Still try to scan — some Android versions allow it without location
      }
    } catch (e) {
      debugPrint('[DeviceController] Location permission error: $e');
    }

    // Populate the WiFi banner shown at the top of the device list
    final info = NetworkInfo();
    wifiSSID.value = await info.getWifiName();
    wifiIP.value   = await info.getWifiIP();

    startScan(); // Auto-start so the user doesn't have to tap Refresh first
  }

  // ── Scanning ──────────────────────────────────────────────────────────────

  // Send a UDP broadcast to the local subnet and collect replies.
  // Receivers on the same WiFi network respond with their hostname and IP.
  // Called automatically on init and by the AppBar refresh button.
  Future<void> startScan() async {
    isScanning.value = true;
    devices.clear();

    try {
      final found = await _discovery.scanForDevices();
      devices.assignAll(found);

      // Let the user know if nothing replied (e.g. Mac app is not open)
      if (found.isEmpty) {
        Get.snackbar(
          'No Receivers Found',
          'Make sure the Mac/PC receiver app is open and on the same WiFi network.',
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      _showError('Discovery Error', e.toString());
    } finally {
      isScanning.value = false;
    }
  }

  // ── Device selection ──────────────────────────────────────────────────────

  // Called when the user taps a device tile.
  // Shows a brief "Connecting…" dialog, then navigates to the casting screen.
  // For WiFi devices the actual WebSocket connection is opened in CastingController.
  Future<void> connectToDevice(CastDevice device) async {
    // Show connecting dialog — gives feedback while navigation and WS connect happen
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.dialogBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: accent),
              const SizedBox(height: 20),
              Text(
                'Connecting to\n${device.name}',
                textAlign: TextAlign.center,
                style: mediumPoppins(15, textColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Small delay so the dialog is visible for at least half a second
    await Future.delayed(const Duration(milliseconds: 600));
    Get.back(); // Dismiss the dialog

    device.isConnected = true;
    // Pass the full CastDevice to CastingController via route arguments
    Get.toNamed(AppRoutes.casting, arguments: device);
  }

  // Show a red error snackbar at the bottom of the screen.
  void _showError(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      backgroundColor: Colors.red.withValues(alpha: 0.85),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }
}
