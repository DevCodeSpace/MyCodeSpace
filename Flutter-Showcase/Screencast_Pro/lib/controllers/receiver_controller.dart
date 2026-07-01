import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../services/receiver_service.dart';

// ReceiverController runs on the Mac (or Windows PC) receiver device.
//
// It starts ReceiverService — which handles both UDP discovery and WebSocket
// frame reception — and exposes reactive state for ReceiverView to display:
//   • localIP    : Mac's IP address (shown while waiting for a cast connection)
//   • isConnected: whether an Android sender is actively streaming to us
//   • currentFrame: latest PNG frame received (displayed fullscreen when active)
//   • fps        : incoming frame rate (updated once per second)
class ReceiverController extends GetxController {
  final _service = ReceiverService(); // Handles UDP + WebSocket on the Mac side

  // ── Reactive state (observed by ReceiverView) ─────────────────────────────
  final localIP = ''.obs; // Mac's LAN IP, e.g. "192.168.1.50"
  final isConnected = false.obs; // True while an Android sender is streaming
  final currentFrame = Rxn<Uint8List>(); // Latest PNG frame bytes (null = no frame yet)
  final fps = 0.obs; // Current frames-per-second count

  // Internal FPS tracking — counts frames within the current one-second window
  int _frameCount = 0;
  Timer? _fpsTimer;

  @override
  void onInit() {
    super.onInit();
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    _startReceiver();
    // Mobile (Android/iOS) par casting receive karte waqt screen off na ho
    if (Platform.isAndroid || Platform.isIOS) {
      WakelockPlus.enable();
    }
  }

  @override
  void onClose() {
    _fpsTimer?.cancel();
    _service.stop(); // Shut down UDP listener and WebSocket server
    if (Platform.isAndroid || Platform.isIOS) {
      WakelockPlus.disable();
    }
    super.onClose();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  // Configure callbacks and start the receiver service.
  Future<void> _startReceiver() async {
    // Called by ReceiverService each time a PNG frame arrives from Android
    _service.onFrame = (Uint8List bytes) {
      currentFrame.value = bytes; // Push frame to the view for display
      _frameCount++;
    };

    // Called when an Android sender connects or disconnects
    _service.onConnection = (bool connected) {
      isConnected.value = connected;
      if (!connected) {
        currentFrame.value = null; // Clear the frame display when disconnected
        fps.value = 0;
      }
    };

    // Start both the UDP discovery listener and the WebSocket server
    await _service.start();

    // Read and store the Mac's local IP for display in the waiting screen
    localIP.value = await _service.getLocalIP();

    // Update the FPS counter every second
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      fps.value = _frameCount;
      _frameCount = 0;
    });
  }
}
