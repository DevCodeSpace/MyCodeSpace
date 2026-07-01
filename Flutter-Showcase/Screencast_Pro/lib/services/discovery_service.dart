import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/cast_device.dart';

// DiscoveryService finds receiver devices (Mac/PC) on the same WiFi network.
//
// How it works:
//   1. Android gets its own WiFi IP (e.g. 192.168.1.100) via network_info_plus.
//   2. It sends the string "SCREEN_CAST_DISCOVER" as a UDP broadcast to the
//      subnet broadcast address (e.g. 192.168.1.255) on port 8766.
//   3. Any device running ReceiverService hears the broadcast and replies with
//      a JSON object: { "name": "Mac hostname", "ip": "192.168.1.50", "port": 8765 }
//   4. DiscoveryService collects all replies for 4 seconds and returns them as
//      a list of CastDevice objects.
//
// This approach requires no mDNS / Bonjour libraries and works reliably on
// typical home and office WiFi networks.
class DiscoveryService {
  // UDP port used only for discovery broadcasts and responses.
  // Must match ReceiverService.discoveryPort on the Mac/PC side.
  static const int discoveryPort = 8766;

  // How long the scan waits for devices to reply before returning results.
  static const Duration scanDuration = Duration(seconds: 4);

  // The magic string Android sends to ask "is anyone a receiver out there?"
  static const String discoverMessage = 'SCREEN_CAST_DISCOVER';

  RawDatagramSocket? _socket; // UDP socket — kept as field so stopScan() can close it

  // Start a UDP broadcast scan and return all discovered receiver devices.
  // Call this when the user opens the device list screen.
  Future<List<CastDevice>> scanForDevices() async {
    final devices = <CastDevice>[];
    final seenIPs = <String>{}; // Tracks already-added IPs to avoid duplicates

    try {
      // Compute the WiFi subnet broadcast address (e.g. 192.168.1.255).
      // This is more reliable than 255.255.255.255 on most routers.
      final broadcastIP = await _getSubnetBroadcast();

      // Bind a UDP socket on any available port (0 = OS picks the port)
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.broadcastEnabled = true; // Required to send to broadcast addresses

      // Set up the listener BEFORE sending — packets can arrive very quickly
      _socket!.listen((RawSocketEvent event) {
        if (event != RawSocketEvent.read) return;
        final datagram = _socket!.receive();
        if (datagram == null) return;

        try {
          final message = utf8.decode(datagram.data);
          final json = jsonDecode(message) as Map<String, dynamic>;

          // Extract device details from the JSON response
          final ip   = (json['ip']   as String?) ?? datagram.address.address;
          final name = (json['name'] as String?) ?? 'Unknown Device';
          final port = (json['port'] as int?)    ?? 8765;

          // Skip duplicates (device might reply to both broadcast addresses)
          if (seenIPs.contains(ip)) return;
          seenIPs.add(ip);

          devices.add(CastDevice(
            id:             ip,   // IP is used as the unique device identifier
            name:           name,
            connectionType: CastConnectionType.wifi,
            deviceType:     CastDeviceType.mac, // UDP responders are desktop receivers
            ip:             ip,
            wsPort:         port,
          ));
        } catch (_) {
          // Ignore malformed packets from other apps on the network
        }
      });

      final payload = utf8.encode(discoverMessage);

      // Send to the subnet broadcast so all devices on the LAN see it
      _socket!.send(payload, InternetAddress(broadcastIP), discoveryPort);

      // Also send to 255.255.255.255 as a fallback for some network configs
      _socket!.send(payload, InternetAddress('255.255.255.255'), discoveryPort);

      debugPrint('[Discovery] Broadcast sent to $broadcastIP:$discoveryPort');

      // Wait for replies to arrive
      await Future.delayed(scanDuration);
    } catch (e) {
      debugPrint('[Discovery] Scan error: $e');
    } finally {
      _socket?.close();
      _socket = null;
    }

    debugPrint('[Discovery] Found ${devices.length} device(s)');
    return devices;
  }

  // Abort an in-progress scan early (e.g. when the user leaves the screen).
  void stopScan() {
    _socket?.close();
    _socket = null;
  }

  // Probe a single device at [ip]:8766 via UNICAST UDP.
  //
  // Why unicast instead of broadcast?
  //   Broadcast packets from a WiFi interface often do NOT reach devices on
  //   the Ethernet segment (same router, different physical interface). Routers
  //   are not required to forward directed broadcasts between interfaces.
  //   A unicast packet IS always forwarded by the router as long as both devices
  //   are on the same /24 subnet — so this reliably reaches a Mac on Ethernet.
  //
  // Returns the [CastDevice] if the receiver app is running at [ip],
  // or null if no reply within 3 seconds (app not running / wrong IP).
  Future<CastDevice?> probeSpecificDevice(String ip) async {
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      final completer = Completer<CastDevice?>();

      socket.listen((RawSocketEvent event) {
        if (event != RawSocketEvent.read) return;
        final datagram = socket!.receive();
        if (datagram == null) return;
        try {
          final message = utf8.decode(datagram.data);
          final json    = jsonDecode(message) as Map<String, dynamic>;
          final deviceIp = (json['ip']   as String?) ?? datagram.address.address;
          final name     = (json['name'] as String?) ?? 'Mac / PC';
          final port     = (json['port'] as int?)    ?? 8765;
          if (!completer.isCompleted) {
            completer.complete(CastDevice(
              id:             deviceIp,
              name:           name,
              connectionType: CastConnectionType.wifi,
              deviceType:     CastDeviceType.mac,
              ip:             deviceIp,
              wsPort:         port,
            ));
          }
        } catch (_) {}
      });

      // Send UNICAST directly to the given IP — bypasses the WiFi/Ethernet
      // broadcast-forwarding limitation of consumer routers.
      final payload = utf8.encode(discoverMessage);
      socket.send(payload, InternetAddress(ip), discoveryPort);
      debugPrint('[Discovery] Unicast probe → $ip:$discoveryPort');

      return await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('[Discovery] Probe timeout for $ip');
          return null;
        },
      );
    } catch (e) {
      debugPrint('[Discovery] Probe error for $ip: $e');
      return null;
    } finally {
      socket?.close();
    }
  }

  // Determine the subnet broadcast address from the device's WiFi IP.
  // Example: WiFi IP = 192.168.1.100  →  broadcast = 192.168.1.255  (/24 assumed)
  Future<String> _getSubnetBroadcast() async {
    try {
      final info  = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      if (wifiIP != null && wifiIP.contains('.')) {
        final parts = wifiIP.split('.');
        // Assume /24 (255.255.255.0) which covers most home/office networks
        return '${parts[0]}.${parts[1]}.${parts[2]}.255';
      }
    } catch (e) {
      debugPrint('[Discovery] Could not read WiFi IP: $e');
    }
    return '255.255.255.255'; // Fall back to limited broadcast
  }
}
