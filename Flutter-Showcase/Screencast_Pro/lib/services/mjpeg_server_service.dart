import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// HTTP server that broadcasts the Android screen as an MJPEG stream.
///
/// Flow:
///   1. [startServerAndCapture] binds an [HttpServer] on port 8080 (or fallback).
///   2. GET `/`      → returns a self-contained HTML page with an embedded
///                      `<img>` pointing at `/stream` — works in any browser.
///   3. GET `/stream`→ returns a continuous `multipart/x-mixed-replace` MJPEG
///                      stream; each part is a JPEG frame from MediaProjection.
///   4. Frames come from the native EventChannel and are pushed to all clients.
///
/// Compatible with: Chrome, Firefox, Safari, Smart TV browsers, VLC.
class MjpegServerService {
  // ── Native channel names ──────────────────────────────────────────────────

  /// Sends control commands to native Android (request / stop capture).
  static const _method = MethodChannel('screen_capture/control');

  /// Receives JPEG frame bytes from the native foreground capture service.
  static const _event = EventChannel('screen_capture/frames');

  // ── Server & state ────────────────────────────────────────────────────────

  HttpServer? _server;

  /// All HTTP responses currently subscribed to the MJPEG `/stream` path.
  final List<HttpResponse> _activeClients = [];

  StreamSubscription<dynamic>? _frameSub;
  bool _isStreaming = false;

  // ── Viewer count callback ─────────────────────────────────────────────────

  /// Called whenever a browser connects to or disconnects from `/stream`.
  /// The integer argument is the new total number of active viewers.
  void Function(int count)? onViewerCountChanged;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Starts the HTTP server and the native screen capture.
  ///
  /// Returns the port the server is bound to, or `null` if startup failed
  /// (permission denied, server bind error, non-Android platform).
  Future<int?> startServerAndCapture({int port = 8080}) async {
    if (_isStreaming) return null;
    if (!Platform.isAndroid) return null;

    final approved = await _requestScreenCapturePermission();
    if (!approved) return null;

    // Try the requested port first; fall back to an OS-assigned free port.
    _server = await _bindServer(port) ?? (port != 0 ? await _bindServer(0) : null);
    if (_server == null) return null;

    debugPrint('[MJPEG] Server started on port ${_server!.port}');
    _server!.listen(_handleHttpRequest);
    _isStreaming = true;

    // Subscribe to JPEG frames from the native capture service.
    _frameSub = _event.receiveBroadcastStream().listen((dynamic data) {
      if (!_isStreaming || _activeClients.isEmpty) return;
      try {
        _broadcastFrame(data as Uint8List);
      } catch (e) {
        debugPrint('[MJPEG] Frame broadcast error: $e');
      }
    });

    return _server!.port;
  }

  /// Stops the HTTP server, closes all client connections, and stops capture.
  void stopServerAndCapture() {
    if (!_isStreaming) return;
    _isStreaming = false;

    _frameSub?.cancel();
    _frameSub = null;

    // Flush & close all open browser connections before shutting the server.
    for (final client in List<HttpResponse>.from(_activeClients)) {
      try {
        client.close();
      } catch (_) {}
    }
    _activeClients.clear();
    onViewerCountChanged?.call(0);

    _server?.close(force: true);
    _server = null;

    if (Platform.isAndroid) {
      try {
        _method.invokeMethod('stopCapture');
      } catch (_) {}
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<bool> _requestScreenCapturePermission() async {
    try {
      return await _method.invokeMethod<bool>('requestCapture') ?? false;
    } catch (e) {
      debugPrint('[MJPEG] requestCapture error: $e');
      return false;
    }
  }

  Future<HttpServer?> _bindServer(int port) async {
    try {
      // Bind to 0.0.0.0 so devices on the LAN can reach the server.
      return await HttpServer.bind(InternetAddress.anyIPv4, port);
    } catch (e) {
      debugPrint('[MJPEG] Bind failed on port $port: $e');
      return null;
    }
  }

  /// Routes incoming requests to the HTML page or the MJPEG stream endpoint.
  void _handleHttpRequest(HttpRequest request) {
    final path = request.uri.path;

    if (path == '/' || path == '/index.html' || path.isEmpty) {
      _serveHtmlPage(request);
    } else if (path == '/stream') {
      _serveMjpegStream(request);
    } else {
      // Return 404 for any unknown path.
      request.response.statusCode = HttpStatus.notFound;
      request.response.close();
    }
  }

  /// Serves a minimal HTML page that embeds the MJPEG stream in an <img> tag.
  ///
  /// Opening the root URL in any browser is enough to watch the live cast —
  /// the user does NOT need to know the /stream path or configure anything.
  void _serveHtmlPage(HttpRequest request) {
    const html = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <title>ScreenCast Pro – Live</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: #0A0A1A;
            /* Force body to exactly viewport height and completely disable scrolling */
            height: 100vh;
            overflow: hidden;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      color: #fff;
    }
          /* flex-shrink: 0 ensures header and footer text are never compressed */
          h1 { font-size: 1.1rem; color: #6C63FF; margin-bottom: 12px; letter-spacing: 0.5px; flex-shrink: 0; }
    .frame-wrap {
            /* Flexible container constrained within the viewport */
            display: flex;
            justify-content: center;
            align-items: center;
            max-width: 95vw;
            max-height: 80vh;
      background: #000;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 0 40px rgba(108, 99, 255, 0.25);
    }
          img { 
            /* Scale down to fit the wrap without stretching or overflowing */
            max-width: 100%; 
            max-height: 80vh; 
            object-fit: contain; 
            display: block; 
          }
          p { margin-top: 12px; font-size: 0.75rem; color: rgba(255,255,255,0.3); flex-shrink: 0; }
  </style>
</head>
<body>
  <h1>● SCREENCAST PRO — LIVE</h1>
  <div class="frame-wrap">
    <img src="/stream" alt="Live screen cast" />
  </div>
  <p>ScreenCast Pro · LAN only</p>
</body>
</html>''';

    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.html;
    // Prevent caching so refreshing always re-requests the live page.
    request.response.headers.set('Cache-Control', 'no-cache, no-store');
    request.response.write(html);
    request.response.close();
  }

  /// Upgrades the connection to a continuous MJPEG multipart stream.
  ///
  /// The browser keeps this HTTP connection open indefinitely and renders each
  /// JPEG part as the next video frame — no JavaScript or WebSocket required.
  void _serveMjpegStream(HttpRequest request) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.parse('multipart/x-mixed-replace; boundary=frame');
    // Standard MJPEG anti-caching headers expected by most browsers.
    request.response.headers.set('Cache-Control', 'no-cache');
    request.response.headers.set('Pragma', 'no-cache');
    request.response.headers.set('Connection', 'keep-alive');

    _activeClients.add(request.response);
    onViewerCountChanged?.call(_activeClients.length);
    debugPrint('[MJPEG] Viewer connected (total: ${_activeClients.length})');

    // Remove client when the browser tab closes or the connection drops.
    request.response.done
        .then((_) {
          _activeClients.remove(request.response);
          onViewerCountChanged?.call(_activeClients.length);
          debugPrint('[MJPEG] Viewer disconnected (total: ${_activeClients.length})');
        })
        .catchError((_) {
          _activeClients.remove(request.response);
          onViewerCountChanged?.call(_activeClients.length);
        });
  }

  /// Writes a single JPEG frame to every connected MJPEG client.
  ///
  /// MJPEG multipart format per RFC 2046:
  /// ```
  ///   --frame\r\n
  ///   Content-Type: image/jpeg\r\n
  ///   Content-Length: N\r\n
  ///   \r\n
  ///   [jpeg bytes]
  ///   \r\n
  /// ```
  void _broadcastFrame(Uint8List frameBytes) {
    final header =
        '--frame\r\n'
        'Content-Type: image/jpeg\r\n'
        'Content-Length: ${frameBytes.length}\r\n'
        '\r\n';

    final headerBytes = utf8.encode(header);
    final footerBytes = utf8.encode('\r\n');

    // Iterate over a snapshot so we can safely remove dead clients mid-loop.
    final snapshot = List<HttpResponse>.from(_activeClients);
    for (final client in snapshot) {
      try {
        client.add(headerBytes);
        client.add(frameBytes);
        client.add(footerBytes);
      } catch (_) {
        // Client socket closed unexpectedly; remove from active list.
        _activeClients.remove(client);
        onViewerCountChanged?.call(_activeClients.length);
      }
    }
  }
}
