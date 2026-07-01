import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cast_device.dart';
import '../services/cast_stream_service.dart';
import '../utils/app_colors.dart';
import '../utils/text_styles.dart';

// CastingController manages an active WiFi screen-cast session on Android.
//
// Lifecycle:
//   onInit  → reads the target CastDevice from route arguments
//           → starts the pulse animation (visual heartbeat)
//           → opens a WebSocket to device.host:device.wsPort
//           → begins periodic screen-frame capture + sending
//   onClose → stops streaming, disposes animation, cancels timer
class CastingController extends GetxController with GetTickerProviderStateMixin {
  // ── Dependencies ──────────────────────────────────────────────────────────
  final _stream = CastStreamService(); // Handles screen capture and WebSocket sending

  // ── Reactive state observed by CastingView ────────────────────────────────
  final elapsed           = Duration.zero.obs; // Session duration (MM:SS display)
  final isStreamConnected = false.obs;          // True once WebSocket is open
  final streamFps         = 0.0.obs;            // Live frames-per-second counter
  final streamError       = RxnString();        // Non-null when connection fails

  // ── Animation ─────────────────────────────────────────────────────────────
  // Gently pulsing animation on the cast icon — confirms the session is live.
  late final AnimationController pulseCtrl;

  // ── Session data ──────────────────────────────────────────────────────────
  late final CastDevice device; // Receiver device chosen in DeviceListView

  Timer? _elapsedTimer; // Fires every second to increment elapsed duration

  // WiFi accent colour used throughout the casting screen
  Color get accent => AppColors.wifiAccent;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // DeviceController passes the selected CastDevice as the route argument
    device = Get.arguments as CastDevice;

    // Start the looping pulse animation for the cast icon
    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Increment elapsed every second while the session is running
    _elapsedTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => elapsed.value += const Duration(seconds: 1),
    );

    // Open WebSocket and start streaming immediately
    _initStream();
  }

  @override
  void onClose() {
    pulseCtrl.dispose();
    _elapsedTimer?.cancel();
    _stream.stopStreaming(); // Closes WebSocket and stops the capture timer
    super.onClose();
  }

  // ── WiFi streaming ────────────────────────────────────────────────────────

  // Connect to the Mac receiver and begin sending frames.
  // device.host = IPv4 address (e.g. 192.168.1.50) from UDP discovery.
  // device.wsPort = WebSocket port (default 8765).
  Future<void> _initStream() async {
    // Notify the UI if the connection drops mid-session
    _stream.onDisconnected = () {
      isStreamConnected.value = false;
      streamError.value = 'Connection lost — the receiver may have closed the app.';
    };

    final connected = await _stream.connect(device.host, port: device.wsPort);

    if (!connected) {
      streamError.value =
          'Could not reach ${device.name} at ${device.host}:${device.wsPort}.\n'
          'Make sure the Flutter app is running on the Mac.';
      return;
    }

    isStreamConnected.value = true;

    // Request OS-level capture permission and begin streaming
    final started = await _stream.startStreaming();
    if (!started) {
      streamError.value =
          'Screen capture permission was denied.\n'
          'Please allow screen recording when prompted.';
      return;
    }

    // Pull FPS from CastStreamService every second and push it to the UI
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isStreamConnected.value) { t.cancel(); return; }
      streamFps.value = _stream.fps;
    });
  }

  // ── User actions ──────────────────────────────────────────────────────────

  // Show a confirmation dialog before stopping the session.
  // If confirmed: stops the stream and pops back to the device list.
  void confirmStop() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Stop Casting?', style: boldPoppins(17, textColor: Colors.white)),
        content: Text(
          'Disconnect from "${device.name}"?',
          style: regularPoppins(14, textColor: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Cancel', style: mediumPoppins(14, textColor: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              _stream.stopStreaming(); // Stop capture + close WebSocket
              Get.back();             // Dismiss dialog
              Get.back();             // Return to device list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Stop', style: semiboldPoppins(14, textColor: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Format elapsed duration as MM:SS for the stream panel display
  String formatElapsed() {
    final d = elapsed.value;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
