import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/tv_device.dart';

// ---------------------------------------------------------------------------
// TvCastService — sends the MJPEG stream URL to a smart TV.
//
// Three casting paths depending on the TV's platform:
//
//   LG webOS  — SSAP (Second Screen Application Protocol) over WebSocket
//               ws://[TV_IP]:3000
//               Steps: register app → TV shows pairing prompt → user accepts
//               → send "ssap://browser/open" with {target: streamUrl}
//               → TV opens its built-in browser to the MJPEG URL.
//
//   Samsung   — REST API POST to http://[TV_IP]:8001/api/v2/applications/...
//               Launches the Tizen Internet browser app with the stream URL.
//
//   DLNA/UPnP — SOAP calls to the TV's AVTransport control URL:
//               1. SetAVTransportURI  → tells the renderer what to play
//               2. Play               → starts playback
//               Most DLNA-compatible TVs (LG, Sony, Philips, Panasonic) support this.
// ---------------------------------------------------------------------------
class TvCastService {
  // LG webOS SSAP WebSocket endpoint port (fixed by LG; cannot be changed)
  static const int _lgPort = 3000;

  // Samsung Smart TV REST API port (TV Remote API v2)
  static const int _samsungPort = 8001;

  // Keep the LG WebSocket alive after the browser-open command so that
  // stopCast() can optionally send a close command later.
  WebSocket? _lgSocket;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Instructs [tv] to open [streamUrl] (the MJPEG HTTP stream from this device).
  ///
  /// Returns true if the TV accepted the command.
  /// For LG TVs, the user may need to accept a pairing prompt on the TV screen
  /// before the method returns; it waits up to 30 seconds.
  Future<bool> castToTv(TvDevice tv, String streamUrl) async {
    debugPrint('[TVCast] Casting to "${tv.name}" (${tv.platform}) → $streamUrl');
    switch (tv.platform) {
      case TvPlatform.lgWebOs:
        return _castLg(tv.ip, streamUrl);
      case TvPlatform.samsungTizen:
        return _castSamsung(tv.ip, streamUrl);
      case TvPlatform.macPc:
        // Mac/PC: connect to the receiver's WebSocket and ask it to open
        // the MJPEG stream URL in the default browser via Process.run('open').
        final wsPort = tv.wsPort;
        if (wsPort == null) {
          debugPrint('[TVCast] No WebSocket port for "${tv.name}"');
          return false;
        }
        return _castMacPc(tv.ip, wsPort, streamUrl);
      case TvPlatform.dlna:
      case TvPlatform.unknown:
        final controlUrl = tv.avTransportControlUrl;
        if (controlUrl == null) {
          debugPrint('[TVCast] No AVTransport control URL for "${tv.name}"');
          return false;
        }
        return _castDlna(controlUrl, streamUrl);
    }
  }

  /// Stops any active cast session.
  /// For DLNA: sends a UPnP Stop command.
  /// For LG: closes the WebSocket (the TV's browser stays open but stream ends
  /// automatically when the MJPEG server shuts down).
  Future<void> stopCast(TvDevice tv) async {
    if (tv.platform == TvPlatform.dlna &&
        tv.avTransportControlUrl != null) {
      await _soapCall(
        tv.avTransportControlUrl!,
        'Stop',
        '<InstanceID>0</InstanceID><Speed>1</Speed>',
      );
    }
    _lgSocket?.close();
    _lgSocket = null;
  }

  // ---------------------------------------------------------------------------
  // LG webOS — SSAP
  // ---------------------------------------------------------------------------

  /// Connects to the LG TV's SSAP WebSocket endpoint and launches its browser.
  ///
  /// Protocol flow:
  ///   1. Connect to ws://[TV_IP]:3000
  ///   2. Send a "register" message with the app manifest.
  ///      First time: the TV displays "Allow access?" — user must accept on TV.
  ///   3. On "registered" response: send "ssap://browser/open" with stream URL.
  ///   4. On "response": complete with returnValue (true = success).
  ///
  /// Times out after 30 s (gives the user enough time to accept on the TV).
  Future<bool> _castLg(String ip, String streamUrl) async {
    try {
      _lgSocket?.close();
      // Connect to the SSAP WebSocket — LG webOS listens on port 3000
      _lgSocket = await WebSocket.connect('ws://$ip:$_lgPort')
          .timeout(const Duration(seconds: 6));

      final completer = Completer<bool>();

      _lgSocket!.listen(
        (dynamic msg) {
          try {
            final data = jsonDecode(msg as String) as Map<String, dynamic>;
            final type = (data['type'] as String?) ?? '';

            if (type == 'registered') {
              // Registration accepted (user tapped "Allow" on TV or the device
              // is already paired). Now open the TV's browser with our stream URL.
              _lgSocket!.add(jsonEncode({
                'type': 'request',
                'id': 'open_browser',
                'uri': 'ssap://browser/open',
                'payload': {'target': streamUrl},
              }));
            } else if (type == 'response') {
              // TV replied to "ssap://browser/open" — returnValue true = success
              final returnValue =
                  (data['payload'] as Map?)?['returnValue'] == true;
              if (!completer.isCompleted) completer.complete(returnValue);
            } else if (type == 'error') {
              debugPrint('[TVCast] LG SSAP error: ${data['error']}');
              if (!completer.isCompleted) completer.complete(false);
            }
            // 'prompt' type means the TV is waiting for the user to accept;
            // we just keep waiting — the completer will resolve once they do.
          } catch (_) {}
        },
        onError: (_) { if (!completer.isCompleted) completer.complete(false); },
        onDone:  () { if (!completer.isCompleted) completer.complete(false); },
      );

      // Step 1: send the registration request.
      // The TV validates the manifest and shows an "Allow access?" prompt if
      // this is the first time this appId connects (no stored client key).
      _lgSocket!.add(jsonEncode({
        'type': 'register',
        'id': 'register_0',
        'payload': {
          'forcePairing': false,
          'pairingType': 'PROMPT',
          'manifest': {
            'manifestVersion': 1,
            'appVersion': '1.1',
            'signed': {
              'created': '20240101',
              'appId': 'com.screencastpro.app',
              'vendorId': 'com.screencastpro',
              'localizedAppNames': {'': 'ScreenCast Pro'},
              'localizedVendorNames': {'': 'ScreenCast Pro'},
              'permissions': [
                'LAUNCH',
                'LAUNCH_WEBAPP',
                'APP_TO_APP',
                'CONTROL_INPUT_MEDIA_PLAYBACK',
                'READ_NETWORK_STATE',
              ],
              'serial': 'screencast-pro-001',
            },
            'permissions': ['LAUNCH', 'LAUNCH_WEBAPP', 'APP_TO_APP'],
            'signatures': [],
          },
        },
      }));

      // Wait for the user to accept the pairing prompt on the TV (up to 30 s)
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('[TVCast] LG pairing timed out');
          return false;
        },
      );
    } catch (e) {
      debugPrint('[TVCast] LG error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Samsung Tizen — REST API
  // ---------------------------------------------------------------------------

  /// Opens the Samsung TV's built-in Internet browser with [streamUrl].
  ///
  /// Samsung Smart TV Remote API v2 exposes a REST endpoint to launch apps.
  /// The Internet browser app ID is "org.tizen.browser".
  /// The URL is base64-encoded and passed as a launch parameter.
  Future<bool> _castSamsung(String ip, String streamUrl) async {
    try {
      // Encode the stream URL in base64 — Samsung's API requires this format
      final encodedUrl = base64Encode(utf8.encode(streamUrl));

      // Endpoint: POST http://[TV]:8001/api/v2/applications/org.tizen.browser
      final apiUrl =
          'http://$ip:$_samsungPort/api/v2/applications/org.tizen.browser';

      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final request = await client.postUrl(Uri.parse(apiUrl));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({
        'id': 'org.tizen.browser',
        'params': ['encode=$encodedUrl'],
      }));
      final response = await request.close().timeout(const Duration(seconds: 5));
      await response.drain<void>(); // Consume body to release the connection
      client.close();

      debugPrint('[TVCast] Samsung → HTTP ${response.statusCode}');
      return response.statusCode < 300;
    } catch (e) {
      debugPrint('[TVCast] Samsung error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Mac / PC — WebSocket "open_url" message
  // ---------------------------------------------------------------------------

  /// Connects to the Mac/PC receiver's WebSocket and sends an "open_url" message.
  ///
  /// The Mac's [ReceiverService] handles this message by running
  /// `Process.run('open', [url])` on macOS (or the platform equivalent),
  /// which opens the MJPEG stream URL in the default browser (Safari/Chrome).
  ///
  /// This requires the ScreenCast Pro receiver app to already be running on
  /// the Mac — the same app that is used for "Cast My Screen".
  Future<bool> _castMacPc(String ip, int wsPort, String streamUrl) async {
    WebSocket? socket;
    try {
      // Connect to the Mac receiver's WebSocket server
      socket = await WebSocket.connect('ws://$ip:$wsPort')
          .timeout(const Duration(seconds: 5));

      // Send a JSON command asking the receiver to open the MJPEG URL
      socket.add(jsonEncode({
        'type': 'open_url',
        'url': streamUrl,
      }));

      // Give the message a moment to flush before closing the socket
      await Future.delayed(const Duration(milliseconds: 300));
      await socket.close();

      debugPrint('[TVCast] Mac/PC open_url sent → $streamUrl');
      return true;
    } catch (e) {
      debugPrint('[TVCast] Mac/PC error: $e');
      await socket?.close();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Generic DLNA/UPnP — AVTransport SOAP
  // ---------------------------------------------------------------------------

  /// Pushes [streamUrl] to a DLNA MediaRenderer using UPnP AVTransport SOAP.
  ///
  /// Two sequential SOAP calls:
  ///   1. SetAVTransportURI — tells the renderer which stream to load.
  ///   2. Play              — starts playback (speed "1" = normal speed).
  ///
  /// Note: MJPEG (multipart/x-mixed-replace) is supported by most modern smart
  /// TV browsers but may not work on strict DLNA renderers that expect only
  /// MPEG/MP4 media.  In that case the UI will show "Cast Failed" and the user
  /// can open the URL manually in the TV's browser.
  Future<bool> _castDlna(String controlUrl, String streamUrl) async {
    // Step 1: SetAVTransportURI — load the stream URL onto the renderer
    final setOk = await _soapCall(
      controlUrl,
      'SetAVTransportURI',
      '<InstanceID>0</InstanceID>'
      '<CurrentURI>${_xmlEsc(streamUrl)}</CurrentURI>'
      '<CurrentURIMetaData></CurrentURIMetaData>',
    );
    if (!setOk) return false;

    // Brief pause to let the TV prepare the connection before we send Play
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 2: Play — start playback at normal speed
    return _soapCall(
      controlUrl,
      'Play',
      '<InstanceID>0</InstanceID><Speed>1</Speed>',
    );
  }

  // Sends a UPnP SOAP action to [controlUrl] with the given [action] name
  // and [bodyFields] XML fragment inside the action element.
  Future<bool> _soapCall(
    String controlUrl,
    String action,
    String bodyFields,
  ) async {
    // UPnP AVTransport service type — used in both Content-Type and SOAPAction
    const serviceType = 'urn:schemas-upnp-org:service:AVTransport:1';

    // Build the SOAP envelope required by the UPnP specification
    final envelope =
        '<?xml version="1.0" encoding="utf-8"?>'
        '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"'
        ' s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
        '<s:Body>'
        '<u:$action xmlns:u="$serviceType">$bodyFields</u:$action>'
        '</s:Body>'
        '</s:Envelope>';

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final req = await client.postUrl(Uri.parse(controlUrl));
      // UPnP requires Content-Type with charset and the SOAPAction header
      req.headers.set('Content-Type', 'text/xml; charset="utf-8"');
      req.headers.set('SOAPAction', '"$serviceType#$action"');
      req.write(envelope);
      final resp = await req.close().timeout(const Duration(seconds: 5));
      await resp.drain<void>();
      client.close();

      debugPrint('[TVCast] SOAP $action → ${resp.statusCode}');
      return resp.statusCode < 300;
    } catch (e) {
      debugPrint('[TVCast] SOAP $action error: $e');
      return false;
    }
  }

  // Escapes the five XML special characters in a URL before embedding it in XML
  String _xmlEsc(String v) => v
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
