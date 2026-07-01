import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Sends live screen frames from the Android device to the Mac receiver over WebSocket.
///
/// Architecture:
///   1. [connect]        — Opens a WebSocket connection to the Mac (IP:port).
///   2. [startStreaming] — Requests OS-level screen-capture permission via
///                         Android's MediaProjection API (MethodChannel call).
///                         On approval, a native ForegroundService starts and
///                         delivers JPEG frames through an EventChannel.
///   3. Each frame byte array is forwarded immediately over the WebSocket so
///                         the Mac receiver can display it via Image.memory().
///   4. [stopStreaming]  — Stops the native service, cancels the EventChannel
///                         subscription, and closes the WebSocket.
///
/// Why MediaProjection instead of RepaintBoundary?
///   RepaintBoundary.toImage() only captures Flutter's own widget tree.
///   When the user navigates to the Android home screen or opens another app,
///   Flutter enters the "paused" lifecycle state, rendering stops, and no frames
///   are produced. MediaProjection is an OS-level API that captures everything
///   visible on the display regardless of which app is in the foreground.
class CastStreamService {
  // ── Native channel names — must match exactly in MainActivity.kt ────────────

  /// MethodChannel for sending control commands to native Android code.
  /// Handles: "requestCapture" (shows system dialog), "stopCapture".
  static const _method = MethodChannel('screen_capture/control');

  /// EventChannel for receiving JPEG frame bytes from the native ForegroundService.
  /// Each event is a Uint8List (raw JPEG bytes) ready to send over WebSocket.
  static const _event = EventChannel('screen_capture/frames');

  // ── WebSocket connection to the Mac receiver ─────────────────────────────────

  WebSocket? _socket;        // Null when not connected
  StreamSubscription<dynamic>? _frameSub; // EventChannel subscription; cancel on stop

  bool _isStreaming = false; // True between startStreaming() success and stopStreaming()

  // ── FPS tracking ─────────────────────────────────────────────────────────────

  int      _frameCount = 0;          // Frames sent since last FPS window reset
  DateTime _fpsWindow  = DateTime.now(); // Start of the current 1-second FPS window
  double   fps         = 0.0;        // Last computed FPS (updated once per second)
  int      totalFrames = 0;          // Running total of frames sent this session

  /// Called when the WebSocket closes unexpectedly (network drop, Mac quit, etc.).
  /// CastingController sets this to update the UI and show an error message.
  VoidCallback? onDisconnected;

  // ── Connection ────────────────────────────────────────────────────────────────

  /// Opens a WebSocket connection to the Mac receiver at [host]:[port].
  ///
  /// Returns `true` on success. Must be called before [startStreaming].
  /// Attaches error/done listeners so unexpected drops trigger [onDisconnected].
  Future<bool> connect(String host, {int port = 8765}) async {
    try {
      debugPrint('[Cast] Connecting to ws://$host:$port');
      _socket = await WebSocket.connect('ws://$host:$port')
          .timeout(const Duration(seconds: 5));

      // Listen for socket-level events so we can notify the UI when the
      // connection drops without the user explicitly stopping the cast.
      _socket!.listen(
        null,
        onError: (e) {
          debugPrint('[Cast] Socket error: $e');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('[Cast] Socket closed by receiver');
          _handleDisconnect();
        },
      );

      debugPrint('[Cast] Connected successfully');
      return true;
    } catch (e) {
      debugPrint('[Cast] Connection failed: $e');
      return false;
    }
  }

  // ── Streaming ─────────────────────────────────────────────────────────────────

  /// Requests MediaProjection permission and starts streaming screen frames.
  ///
  /// Flow:
  ///   1. Calls native "requestCapture" → Android shows "Start recording?" dialog.
  ///   2. If approved, ScreenCaptureService (ForegroundService) starts.
  ///   3. Subscribes to EventChannel; each JPEG frame is forwarded to the WebSocket.
  ///
  /// Returns `false` if:
  ///   - Not running on Android (platform guard)
  ///   - User denies the capture permission dialog
  ///   - Native channel is unavailable (e.g. missing plugin / first install)
  Future<bool> startStreaming() async {
    if (_isStreaming || _socket == null) return false;

    // Guard: MediaProjection only exists on Android. The Mac side uses
    // ReceiverController and never calls this method, but guard explicitly
    // to avoid MissingPluginException in any edge case (e.g. tests).
    if (!Platform.isAndroid) {
      debugPrint('[Cast] startStreaming() called on non-Android platform — skipping');
      return false;
    }

    bool approved = false;
    try {
      // Show the system "Allow screen recording?" dialog.
      // Returns true when user taps "Start now", false if they cancel.
      approved = await _method.invokeMethod<bool>('requestCapture') ?? false;
    } on MissingPluginException {
      // Happens when the Kotlin native code was not compiled into the running
      // binary. Fix: run "flutter clean && flutter run -d <device>" to force
      // a full native rebuild. This guard prevents an unhandled crash.
      debugPrint('[Cast] Native screen_capture channel not found. '
          'Run "flutter clean && flutter run" to rebuild native code.');
      return false;
    } catch (e) {
      debugPrint('[Cast] requestCapture error: $e');
      return false;
    }

    if (!approved) {
      debugPrint('[Cast] Screen capture permission denied by user');
      return false;
    }

    _isStreaming = true;
    _fpsWindow   = DateTime.now();
    _frameCount  = 0;
    totalFrames  = 0;

    // Tell the Mac receiver that a cast session is starting.
    // The receiver uses this to switch from "waiting" to "streaming" UI.
    try { _socket!.add('{"type":"start_cast"}'); } catch (_) {}

    // Subscribe to JPEG frames from ScreenCaptureService.
    // Each EventChannel event is a raw Uint8List (JPEG encoded by Kotlin).
    // Image.memory() on the Mac side accepts JPEG directly, so no conversion needed.
    _frameSub = _event.receiveBroadcastStream().listen(
      (dynamic data) {
        if (!_isStreaming || _socket == null) return;
        try {
          final bytes = data as Uint8List;

          // Forward frame bytes directly to the Mac via the open WebSocket.
          _socket!.add(bytes);
          _frameCount++;
          totalFrames++;

          // Update the FPS counter once per second so CastingController can
          // display it in the "Screen Share — Live" panel.
          final now = DateTime.now();
          if (now.difference(_fpsWindow).inMilliseconds >= 1000) {
            fps         = _frameCount.toDouble();
            _frameCount = 0;
            _fpsWindow  = now;
          }
        } catch (e) {
          debugPrint('[Cast] Frame send error: $e');
          _handleDisconnect();
        }
      },
      onError: (e) {
        debugPrint('[Cast] EventChannel frame stream error: $e');
        _handleDisconnect();
      },
    );

    return true;
  }

  // ── Stop / cleanup ────────────────────────────────────────────────────────────

  /// Stops streaming and closes the WebSocket.
  ///
  /// Sends "stopCapture" to the native side (stops ScreenCaptureService and
  /// removes the persistent notification), then sends a "stop_cast" JSON
  /// message to the Mac so it can return to its waiting screen.
  void stopStreaming() {
    _isStreaming = false;

    // Cancel EventChannel subscription first so no frames are processed
    // after we close the WebSocket below.
    _frameSub?.cancel();
    _frameSub = null;

    // Tell native Android to stop ScreenCaptureService.
    if (Platform.isAndroid) {
      try { _method.invokeMethod('stopCapture'); } catch (_) {}
    }

    // Politely signal the Mac receiver before closing the socket,
    // so it can switch back to "Waiting for cast..." immediately.
    try {
      _socket?.add('{"type":"stop_cast"}');
      _socket?.close();
    } catch (_) {}
    _socket = null;
  }

  /// Handles unexpected disconnection (socket error or remote close).
  /// Clears streaming state and fires [onDisconnected] so the controller
  /// can update the UI with an error message.
  void _handleDisconnect() {
    _isStreaming = false;
    onDisconnected?.call();
  }

  /// Whether frames are actively being captured and sent.
  bool get isStreaming => _isStreaming;
}
