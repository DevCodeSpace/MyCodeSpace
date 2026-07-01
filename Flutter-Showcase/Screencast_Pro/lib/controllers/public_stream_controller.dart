import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:share_plus/share_plus.dart'; // REQUIRED: Add 'share_plus: ^10.0.0' to pubspec.yaml

import '../services/mjpeg_server_service.dart';

/// Manages all state for the "Cast Without Receiver" / browser-casting feature.
///
/// This is the no-receiver path for Mac, Windows, TVs, and phones that can
/// simply open a browser and load the MJPEG stream URL.
///
/// Owns the [MjpegServerService] lifecycle, builds the shareable LAN URL,
/// tracks elapsed time and active viewer count, and keeps the UI reactive.
class PublicStreamController extends GetxController
    with GetTickerProviderStateMixin {
  final _mjpegService = MjpegServerService();
  final _networkInfo = NetworkInfo();

  // ── Reactive UI state ─────────────────────────────────────────────────────

  /// True while the MJPEG server and native capture are running.
  final isStreaming = false.obs;

  /// True only during the startup window (permission dialog + server bind).
  final isStarting = false.obs;

  /// Full URL viewers should open, e.g. `http://192.168.1.10:8080`.
  /// This is the shareable link that a Mac browser can open without installing
  /// the dedicated receiver app.
  final streamUrl = RxnString();

  /// Elapsed casting duration — updated every second.
  final elapsed = Rx<Duration>(Duration.zero);

  /// Number of browser / player connections currently viewing the stream.
  final viewerCount = 0.obs;

  Timer? _timer;

  /// Looping animation controller for the pulsing "LIVE" icon.
  late final AnimationController pulseCtrl;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Wire up the viewer-count callback so the UI stays in sync without polling.
    _mjpegService.onViewerCountChanged = (count) {
      viewerCount.value = count;
    };
  }

  // ── Public actions ────────────────────────────────────────────────────────

  /// Requests screen-recording permission, starts the HTTP server, and builds
  /// the shareable stream URL that any browser on the LAN can open.
  Future<void> startStream() async {
    if (isStarting.value || isStreaming.value) return;

    isStarting.value = true;
    // Show a loading indicator while the permission dialog and server init run.
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Try port 8080 first so the URL stays predictable; falls back to an OS port.
      final port = await _mjpegService.startServerAndCapture(port: 8080);

      if (Get.isDialogOpen == true) Get.back();

      if (port != null) {
        // Get the phone's WiFi IP so we can build a LAN-accessible URL.
        final ip = await _networkInfo.getWifiIP();
        if (ip != null) {
          streamUrl.value = 'http://$ip:$port';
          isStreaming.value = true;
          viewerCount.value = 0;
          _startTimer();
        } else {
          _showError(
            'WiFi Not Found',
            'Could not read the device IP. Make sure WiFi is connected.',
          );
        }
      } else {
        // The most common failure is the user tapping "Don't Allow" on the
        // system "Allow screen recording?" dialog.
        _showError(
          'Stream Failed',
          'Screen recording permission was denied, or the server could not start.\nPlease try again and tap "Start now" when prompted.',
        );
      }
    } finally {
      isStarting.value = false;
    }
  }

  /// Stops the MJPEG server, capture service, and resets all reactive state.
  void stopStream() {
    _mjpegService.stopServerAndCapture();
    isStreaming.value = false;
    isStarting.value = false;
    streamUrl.value = null;
    viewerCount.value = 0;
    _stopTimer();
  }

  /// Triggers the native OS share sheet (Quick Share on Android, AirDrop on Mac/iOS).
  /// 
  /// Business Logic:
  /// Since we cannot natively discover phones without our app installed via UDP,
  /// we delegate the discovery and popup mechanism to the OS. 
  /// Using Quick Share, the sender sees a list of nearby devices, taps one, 
  /// and the target device receives a native OS popup. Once the target accepts, 
  /// their default browser automatically opens the live stream URL.
  Future<void> shareStreamUrl() async {
    if (streamUrl.value == null) return;
    
    await Share.share(
      'Click the URL below to watch my screen in real time from your browser: ${streamUrl.value}',
      subject: 'Live Screen Cast',
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    elapsed.value = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      elapsed.value = Duration(seconds: t.tick);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    elapsed.value = Duration.zero;
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void onClose() {
    // Always stop the HTTP server when the screen is disposed —
    // leaving the server running after navigation would waste battery and bandwidth.
    stopStream();
    pulseCtrl.dispose();
    _mjpegService.onViewerCountChanged = null;
    super.onClose();
  }
}
