import 'dart:async';

import 'package:flutter/material.dart'; // TextEditingController, Colors, etc.
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../models/tv_device.dart';
import '../services/discovery_service.dart';
import '../services/mjpeg_server_service.dart';
import '../services/tv_cast_service.dart';
import '../services/tv_discovery_service.dart';

// ---------------------------------------------------------------------------
// TvCastStatus — tracks where we are in the TV-connection lifecycle.
// Drives which status card / icon the UI renders for the selected TV.
// ---------------------------------------------------------------------------
enum TvCastStatus {
  idle,        // No TV selected yet
  connecting,  // castToTv() call is in flight
  connected,   // TV accepted the stream URL and opened its browser
  failed,      // castToTv() returned false (pairing rejected / timeout / etc.)
}

// ---------------------------------------------------------------------------
// TvCastController
//
// Single controller for the "Cast to TV" screen.  Owns:
//   - MjpegServerService  — starts an HTTP MJPEG server so the TV has a URL
//                           to open in its browser.
//   - TvDiscoveryService  — SSDP scan that finds smart TVs on the subnet.
//   - TvCastService       — sends the URL to the TV via LG SSAP / DLNA / Samsung.
//
// User flow:
//   1. [startCasting]     — requests screen-recording permission, starts the
//                           MJPEG server, then kicks off a background TV scan.
//   2. [castToTv]         — sends the stream URL to the chosen TV.
//   3. [rescan]           — repeats the SSDP scan (user can call this manually).
//   4. [stopAll]          — stops the MJPEG server and any active TV session.
// ---------------------------------------------------------------------------
class TvCastController extends GetxController
    with GetTickerProviderStateMixin {
  final _mjpeg        = MjpegServerService();
  final _tvDiscovery  = TvDiscoveryService();   // SSDP scan — finds smart TVs
  final _udpDiscovery = DiscoveryService();      // UDP broadcast — finds Mac/PC receivers
  final _caster       = TvCastService();
  final _netInfo      = NetworkInfo();

  // ── Reactive state exposed to the UI ──────────────────────────────────────

  /// True while the MJPEG HTTP server is running and capturing the screen
  final isStreaming = false.obs;

  /// True during the permission-dialog + server-startup phase
  final isStarting = false.obs;

  /// True while the SSDP TV scan is in progress
  final isScanning = false.obs;

  /// Full HTTP URL of the MJPEG stream (null until the server starts)
  /// e.g. "http://192.168.1.10:8080"
  final streamUrl = RxnString();

  /// Smart TVs discovered during the last SSDP scan
  final discoveredTvs = <TvDevice>[].obs;

  /// The TV most recently chosen for casting (null = none selected)
  final selectedTv = Rxn<TvDevice>();

  /// Current state of the TV-to-phone connection attempt
  final castStatus = TvCastStatus.idle.obs;

  /// Number of viewers currently connected to the MJPEG stream
  final viewerCount = 0.obs;

  /// Elapsed casting time — updated every second while streaming
  final elapsed = Rx<Duration>(Duration.zero);

  /// True while a manual-IP connection attempt is in progress
  final isManualConnecting = false.obs;

  /// Bound to the "Enter IP" TextField in the empty-devices state.
  /// Holds the IP address typed by the user (e.g. "192.168.1.17").
  final manualIpController = TextEditingController();

  Timer? _timer;

  /// Looping fade animation for the pulsing "LIVE" icon in [CastingHeader]
  late final AnimationController pulseCtrl;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // One-second looping animation — drives the icon heartbeat in the header
    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Mirror MJPEG viewer count into the reactive field so the UI stays live
    _mjpeg.onViewerCountChanged = (count) => viewerCount.value = count;
  }

  @override
  void onClose() {
    // Always clean up when the screen is disposed; leaving the MJPEG server
    // running after navigation would waste battery and keep the screen capture active.
    stopAll();
    pulseCtrl.dispose();
    manualIpController.dispose(); // TextField controller must be disposed manually
    _mjpeg.onViewerCountChanged = null;
    super.onClose();
  }

  // ── Public actions ─────────────────────────────────────────────────────────

  /// Starts screen capture and the MJPEG HTTP server, then kicks off a
  /// background SSDP scan for nearby smart TVs.
  ///
  /// Shows a loading dialog while the system permission dialog is active,
  /// then shows an error snackbar on failure.
  Future<void> startCasting() async {
    if (isStarting.value || isStreaming.value) return;
    isStarting.value = true;

    // Show a spinner while the "Allow recording?" dialog is up
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Start the MJPEG server (requests MediaProjection permission first)
      // Port 8080 preferred; falls back to OS-assigned if 8080 is busy.
      final port = await _mjpeg.startServerAndCapture(port: 8080);
      if (Get.isDialogOpen == true) Get.back();

      if (port == null) {
        _showError(
          'Stream Failed',
          'Screen recording permission was denied or the server could not start.\n'
          'Tap "Start now" when prompted by Android.',
        );
        return;
      }

      // Get the phone's own WiFi IP to build the LAN-accessible URL
      final ip = await _netInfo.getWifiIP();
      if (ip == null) {
        _showError('WiFi Not Found',
            'Could not read the device IP. Make sure WiFi is connected.');
        _mjpeg.stopServerAndCapture();
        return;
      }

      streamUrl.value    = 'http://$ip:$port';
      isStreaming.value  = true;
      viewerCount.value  = 0;
      _startTimer();

      // Kick off SSDP scan in the background — UI shows a scanning spinner
      // while the stream is already live and the URL is ready to copy manually.
      _scanForTvs();
    } finally {
      isStarting.value = false;
    }
  }

  /// Sends the MJPEG stream URL to [tv] using the appropriate protocol.
  ///
  /// Updates [castStatus] so the UI shows connecting → connected/failed.
  /// On failure, shows a contextual error snackbar explaining what to check.
  Future<void> castToTv(TvDevice tv) async {
    if (streamUrl.value == null) return;

    selectedTv.value  = tv;
    castStatus.value  = TvCastStatus.connecting;

    final success = await _caster.castToTv(tv, streamUrl.value!);
    castStatus.value = success ? TvCastStatus.connected : TvCastStatus.failed;

    if (!success) {
      final hint = tv.platform == TvPlatform.lgWebOs
          ? 'Check your TV for a pairing prompt and tap "Allow".'
          : 'Make sure the TV supports DLNA/UPnP casting and is on the same WiFi.';
      _showError('Cast Failed', 'Could not connect to "${tv.name}". $hint');
    }
  }

  /// Re-runs the SSDP + UDP scan. Useful when a TV is turned on after the initial scan.
  Future<void> rescan() => _scanForTvs();

  /// Manually probes the IP typed in [manualIpController] using a direct UDP
  /// unicast packet to port 8766.
  ///
  /// Why unicast?  Consumer routers often do NOT forward directed-broadcast
  /// packets between their WiFi and Ethernet segments, so a Mac on Ethernet is
  /// invisible to the subnet broadcast scan.  A unicast packet is always routed
  /// to the destination IP, bypassing this limitation.
  ///
  /// If the ScreenCast Pro receiver app is running on the target device:
  ///   → it replies → we create a [TvDevice] and call [castToTv] automatically.
  ///
  /// If the receiver app is NOT running (e.g. user wants "without receiver"):
  ///   → probe returns null → we show a snackbar with the URL to open manually.
  Future<void> connectToManualIp() async {
    final ip = manualIpController.text.trim();
    if (ip.isEmpty) {
      _showError('Enter an IP', 'Type your Mac or TV IP address first.');
      return;
    }
    if (streamUrl.value == null) {
      _showError('Not streaming', 'Tap "Scan & Start Casting" first.');
      return;
    }

    isManualConnecting.value = true;
    try {
      // Unicast UDP probe — works across WiFi→Ethernet router segments
      final found = await _udpDiscovery.probeSpecificDevice(ip);

      if (found != null && found.ip != null) {
        // Receiver app is running: add to the list (if not already there) and cast
        final tv = TvDevice(
          ip:       found.ip!,
          port:     found.wsPort,
          name:     found.name,
          platform: TvPlatform.macPc,
          wsPort:   found.wsPort,
        );
        if (!discoveredTvs.any((d) => d.ip == tv.ip)) {
          discoveredTvs.add(tv);
        }
        await castToTv(tv);
      } else {
        // Receiver app not running — guide user to open URL manually in browser.
        // The stream URL is visible in the card at the top of the screen.
        Get.snackbar(
          'Receiver Not Found at $ip',
          'The ScreenCast Pro receiver app is not running there.\n'
          'Copy the URL shown on screen and open it in any browser on that device.',
          backgroundColor: Colors.orange.withValues(alpha: 0.92),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 7),
        );
      }
    } finally {
      isManualConnecting.value = false;
    }
  }

  /// Stops the MJPEG server, screen capture, and any active TV session.
  void stopAll() {
    _mjpeg.stopServerAndCapture();
    final tv = selectedTv.value;
    if (tv != null) _caster.stopCast(tv);

    isStreaming.value = false;
    streamUrl.value   = null;
    selectedTv.value  = null;
    castStatus.value  = TvCastStatus.idle;
    discoveredTvs.clear();
    viewerCount.value = 0;
    _stopTimer();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  // Runs SSDP (smart TVs) and UDP broadcast (Mac/PC receivers) in parallel,
  // then merges the results into [discoveredTvs].
  // Called by startCasting (automatically) and rescan (user-triggered).
  Future<void> _scanForTvs() async {
    isScanning.value = true;
    discoveredTvs.clear();
    try {
      // Run both scans concurrently — different ports/protocols, no conflict
      final ssdpFuture = _tvDiscovery.scanForTvs();       // SSDP: LG/Samsung/DLNA
      final udpFuture  = _udpDiscovery.scanForDevices();  // UDP: Mac/PC receivers

      final tvDevices   = await ssdpFuture;
      final castDevices = await udpFuture;

      // Add smart TVs from SSDP scan
      discoveredTvs.addAll(tvDevices);

      // Convert each Mac/PC CastDevice to a TvDevice so it appears in the
      // same list alongside TVs. wsPort stores the WebSocket port used by the
      // Mac's ReceiverService — needed for the "open_url" cast command.
      for (final d in castDevices) {
        final ip = d.ip;
        if (ip == null) continue;
        discoveredTvs.add(TvDevice(
          ip:       ip,
          port:     d.wsPort,
          name:     d.name,
          platform: TvPlatform.macPc,
          wsPort:   d.wsPort,
        ));
      }

      debugPrint('[TvCastCtrl] Found ${tvDevices.length} TV(s) + ${castDevices.length} Mac/PC(s)');
    } catch (e) {
      debugPrint('[TvCastCtrl] Scan error: $e');
    } finally {
      isScanning.value = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    elapsed.value = Duration.zero;
    // Tick every second to update the elapsed-time clock in the header
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
      duration: const Duration(seconds: 6),
    );
  }
}
