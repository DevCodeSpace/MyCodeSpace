import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

// Callbacks used by ReceiverController to react to events from this service
typedef OnFrameReceived = void Function(Uint8List bytes);
typedef OnConnectionChanged = void Function(bool connected);

// ReceiverService runs exclusively on the Mac (or Windows) receiver device.
// It has two responsibilities:
//
//  1. UDP Discovery Responder (port 8766)
//     Listens for "SCREEN_CAST_DISCOVER" broadcast packets sent by Android senders.
//     Replies with a JSON payload containing this Mac's hostname, local IP, and
//     the WebSocket port — so Android knows where to connect.
//
//  2. WebSocket Frame Server (port 8765)
//     Accepts a WebSocket connection from the Android sender.
//     Receives raw PNG image bytes frame-by-frame and forwards each frame to
//     the ReceiverController via the onFrame callback so the UI can display it.
class ReceiverService {
  // Dynamically assigned port for WebSocket.
  // OS gives us a free port automatically when we bind to port 0.
  int _wsPort = 0;

  // Port on which the UDP discovery listener waits for broadcast packets
  static const int discoveryPort = 8766;

  HttpServer? _httpServer; // HTTP server that upgrades to WebSocket
  RawDatagramSocket? _udpSocket; // UDP socket for discovery responses
  WebSocket? _activeClient; // Currently connected Android sender

  // Callbacks — set by ReceiverController before calling start()
  OnFrameReceived? onFrame;
  OnConnectionChanged? onConnection;

  // Start both the UDP discovery listener and the WebSocket frame server.
  // Call this once when the Mac receiver screen opens.
  Future<void> start() async {
    // Start WebSocket first so we get the dynamic port assigned by the OS
    await _startWebSocketServer();
    await _startDiscoveryListener();
    debugPrint('[Receiver] Ready — WS port $_wsPort  |  UDP port $discoveryPort');
  }

  // ── UDP Discovery Responder ───────────────────────────────────────────────

  // Listen for Android sender broadcasts on UDP port 8766.
  // When a "SCREEN_CAST_DISCOVER" packet arrives, reply with Mac's info
  // so the sender can add this device to its discovered-device list.
  //
  // KEY FIX — Ethernet + WiFi scenario:
  //   Mac may have multiple network interfaces (Ethernet en0, WiFi en1, etc.).
  //   We use the sender's IP (from the UDP packet) to figure out which of our
  //   own IPs is on the same subnet — that is the reachable one.
  //   e.g. Android sends from 192.168.1.100 → we pick our 192.168.1.50 (Ethernet)
  //        rather than a self-assigned WiFi 169.254.x.x that Android can't reach.
  Future<void> _startDiscoveryListener() async {
    try {
      // Fetch the friendly display name once; reuse for every discovery reply.
      // On macOS: "scutil --get ComputerName" returns "iMac's Mac Pro (2)" —
      //   the human-readable name shown in System Settings → General → About.
      //   Platform.localHostname returns the OS hostname (e.g. "iMacs-Mac-Pro-2.bbrouter")
      //   which is ugly and harder to recognise in the device list.
      final deviceName = await _getDeviceName();

      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true, // Allow restart without "address in use" error
      );

      _udpSocket!.listen((RawSocketEvent event) async {
        if (event != RawSocketEvent.read) return;
        final datagram = _udpSocket!.receive();
        if (datagram == null) return;

        final message = utf8.decode(datagram.data);
        if (message != 'SCREEN_CAST_DISCOVER') return;

        // Use subnet-aware IP selection so Android always gets the IP that
        // is reachable from its own network interface (WiFi or Ethernet).
        final senderIP = datagram.address.address;
        final localIP = await _getReachableIP(senderIP);

        final reply = jsonEncode({
          'name': deviceName, // e.g. "iMac's Mac Pro (2)"
          'ip': localIP, // IP on the SAME subnet as Android sender
          'port': _wsPort, // Send the dynamic port OS assigned to us
          'os': Platform.operatingSystem, // e.g., 'macos', 'windows', 'android'
        });

        // Send reply directly to the Android sender
        _udpSocket!.send(utf8.encode(reply), datagram.address, datagram.port);
        debugPrint('[Receiver] Replied to $senderIP → name="$deviceName"  ip=$localIP');
      });
    } catch (e) {
      debugPrint('[Receiver] UDP listener error: $e');
    }
  }

  // Returns the human-readable computer name shown in System Settings.
  // On macOS: runs "scutil --get ComputerName" (e.g. "iMac's Mac Pro (2)").
  // Falls back to Platform.localHostname on non-macOS or if the command fails.
  Future<String> _getDeviceName() async {
    if (Platform.isMacOS) {
      try {
        final result = await Process.run('scutil', ['--get', 'ComputerName']);
        if (result.exitCode == 0) {
          final name = (result.stdout as String).trim();
          if (name.isNotEmpty) return name;
        }
      } catch (_) {}
    } else if (Platform.isAndroid) {
      return 'Android Receiver';
    }
    return Platform.localHostname;
  }

  // Find the Mac's IP address that is on the SAME /24 subnet as [senderIP].
  //
  // Why this matters:
  //   Mac may have Ethernet (192.168.1.50) AND WiFi with a self-assigned
  //   address (169.254.x.x) or a different subnet.  We must return the IP
  //   that Android can actually reach — the one sharing its subnet prefix.
  //
  //   Example:
  //     senderIP = "192.168.1.100"  →  subnet prefix = "192.168.1."
  //     Mac Ethernet = "192.168.1.50"  ← matches → return this
  //     Mac WiFi     = "169.254.8.3"   ← doesn't match, skip
  Future<String> _getReachableIP(String senderIP) async {
    final parts = senderIP.split('.');
    if (parts.length >= 3) {
      // Build the /24 subnet prefix from the sender's IP (e.g. "192.168.1.")
      final subnetPrefix = '${parts[0]}.${parts[1]}.${parts[2]}.';

      try {
        final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
        for (final iface in interfaces) {
          for (final addr in iface.addresses) {
            if (addr.isLoopback) continue;
            if (addr.address.startsWith('169.254.')) continue; // Skip APIPA/self-assigned
            // If this local IP is in the same /24 as Android, it's the right one
            if (addr.address.startsWith(subnetPrefix)) {
              debugPrint('[Receiver] Subnet match: ${iface.name} → ${addr.address}');
              return addr.address;
            }
          }
        }
      } catch (e) {
        debugPrint('[Receiver] Subnet scan error: $e');
      }
    }
    // Fall back to the generic best-guess IP if no subnet match was found
    return await getLocalIP();
  }

  // ── WebSocket Frame Server ────────────────────────────────────────────────

  // Start an HTTP server that upgrades incoming requests to WebSocket.
  // The Android sender connects here and streams PNG-encoded screen frames.
  Future<void> _startWebSocketServer() async {
    try {
      // Bind to port 0 tells the OS to assign any available free port
      _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, 0);

      // Save the dynamically assigned port so the UDP listener can broadcast it
      _wsPort = _httpServer!.port;

      _httpServer!.listen((HttpRequest request) async {
        // Only accept WebSocket upgrade requests — reject plain HTTP
        if (!WebSocketTransformer.isUpgradeRequest(request)) {
          request.response
            ..statusCode = HttpStatus.ok
            ..write('Screen Cast Receiver — connect via WebSocket')
            ..close();
          return;
        }

        // Upgrade the HTTP connection to a persistent WebSocket
        final ws = await WebSocketTransformer.upgrade(request);

        // Close any previous client before accepting the new one
        _activeClient?.close();
        _activeClient = ws;
        onConnection?.call(true);
        debugPrint('[Receiver] Sender connected');

        ws.listen(
          (data) {
            if (data is String) {
              // JSON control message from the Android side.
              // Currently handles: "open_url" (from TV Cast feature).
              _handleJsonMessage(data);
            } else if (data is List<int>) {
              // Raw JPEG frame bytes from CastStreamService
              onFrame?.call(Uint8List.fromList(data));
            } else if (data is Uint8List) {
              onFrame?.call(data);
            }
          },
          onDone: () {
            debugPrint('[Receiver] Sender disconnected');
            onConnection?.call(false);
            _activeClient = null;
          },
          onError: (e) {
            debugPrint('[Receiver] Sender error: $e');
            onConnection?.call(false);
            _activeClient = null;
          },
          cancelOnError: true,
        );
      });
    } catch (e) {
      debugPrint('[Receiver] WebSocket server error: $e');
    }
  }

  // ── JSON message handler ──────────────────────────────────────────────────

  // Parses a JSON string received over the WebSocket and dispatches to the
  // appropriate handler.
  //
  // Supported message types:
  //   "open_url"   — sent by TvCastService when the user selects this Mac/PC
  //                  from the "Cast to TV" screen. Opens [url] in the system's
  //                  default browser so it displays the MJPEG stream live.
  //                  macOS: `open <url>`  |  Windows: `start <url>`
  //   "start_cast" / "stop_cast" — informational (sent by CastStreamService),
  //                  ignored here; the WebSocket connect/close events are used
  //                  instead to drive the isConnected state.
  void _handleJsonMessage(String raw) {
    try {
      final msg  = jsonDecode(raw) as Map<String, dynamic>;
      final type = (msg['type'] as String?) ?? '';

      if (type == 'open_url') {
        final url = msg['url'] as String?;
        if (url == null || url.isEmpty) return;
        debugPrint('[Receiver] open_url → $url');
        _openUrlInBrowser(url);
      }
      // start_cast / stop_cast are silently ignored — handled via onDone/connect
    } catch (e) {
      debugPrint('[Receiver] JSON parse error: $e');
    }
  }

  // Opens [url] in the OS default browser.
  //   macOS:   `open <url>`   (opens in Safari / default browser)
  //   Windows: `start <url>`  (opens in default browser via cmd)
  //   Linux:   `xdg-open <url>`
  // This is called on the Mac when the Android "Cast to TV" feature picks this
  // device — it lets the Mac display the MJPEG stream without any UI interaction.
  void _openUrlInBrowser(String url) {
    try {
      if (Platform.isMacOS) {
        Process.run('open', [url]);
      } else if (Platform.isWindows) {
        Process.run('cmd', ['/c', 'start', url]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [url]);
      }
    } catch (e) {
      debugPrint('[Receiver] openUrlInBrowser error: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  // Get the Mac's best available LAN IPv4 address for display purposes.
  // Priority order:
  //   1. Private-range address that is NOT self-assigned (not 169.254.x.x)
  //      → 192.168.x.x, 10.x.x.x, or 172.16-31.x.x
  //   2. Any non-loopback, non-APIPA IPv4 address
  //   3. Loopback (127.0.0.1) as last resort
  //
  // APIPA (169.254.x.x) addresses are excluded because they are self-assigned
  // when no DHCP server is available — they cannot be reached from another device.
  Future<String> getLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);

      // Pass 1: look for a genuine LAN address (private range, not self-assigned)
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.isLoopback) continue;
          final a = addr.address;
          if (a.startsWith('169.254.')) continue; // APIPA — skip, not reachable
          if (a.startsWith('192.168.') || a.startsWith('10.') || _is172Private(a)) {
            return a;
          }
        }
      }

      // Pass 2: any non-loopback, non-APIPA address
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('169.254.')) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('[Receiver] IP detection failed: $e');
    }
    return '127.0.0.1';
  }

  // Returns true when the address is in the 172.16.0.0/12 private range.
  bool _is172Private(String address) {
    final parts = address.split('.');
    if (parts.length < 2 || parts[0] != '172') return false;
    final second = int.tryParse(parts[1]) ?? 0;
    return second >= 16 && second <= 31;
  }

  // Stop the receiver — close the WebSocket server and UDP socket.
  // Called when ReceiverController is destroyed (user closes the app).
  void stop() {
    _activeClient?.close();
    _httpServer?.close(force: true);
    _udpSocket?.close();
    _activeClient = null;
    _httpServer = null;
    _udpSocket = null;
    debugPrint('[Receiver] Stopped');
  }
}
