import 'package:flutter/material.dart';

// CastConnectionType tells whether a device was found via Bluetooth or WiFi.
// Used throughout the app to decide which scanning/streaming path to use.
enum CastConnectionType { bluetooth, wifi }

// CastDeviceType categorises the receiver so the UI can show the right icon.
enum CastDeviceType {
  mac,              // macOS computer running the receiver app
  windowsPc,        // Windows PC running the receiver app
  smartTv,          // Smart TV (future support)
  bluetoothSpeaker, // Bluetooth speaker (BT demo only)
  bluetoothDevice,  // Generic Bluetooth device
  unknown,
}

// CastDevice holds all information about a device that can receive a screen cast.
// For WiFi devices discovered via UDP broadcast: ip = id = IPv4 address.
// For Bluetooth devices: id = BT MAC address, ip = null.
class CastDevice {
  // Unique identifier — IP address for WiFi, BT MAC address for Bluetooth
  final String id;

  // Human-readable name shown in the device list (e.g. "Pradip's MacBook Pro")
  final String name;

  // Whether this device was found via Bluetooth or WiFi
  final CastConnectionType connectionType;

  // Specific device category (used for icon and label)
  final CastDeviceType deviceType;

  // Signal strength in dBm — used for Bluetooth devices; WiFi devices default -50
  final int rssi;

  // Whether a casting session is currently active to this device
  bool isConnected;

  // IPv4 address of a WiFi receiver on the local network (null for BT devices)
  final String? ip;

  // WebSocket port on which the WiFi receiver is listening (default 8765)
  final int wsPort;

  CastDevice({
    required this.id,
    required this.name,
    required this.connectionType,
    this.deviceType = CastDeviceType.unknown,
    this.rssi = -50,
    this.isConnected = false,
    this.ip,
    this.wsPort = 8765,
  });

  // Convenience getter — true if this is a Bluetooth device
  bool get isBluetooth => connectionType == CastConnectionType.bluetooth;

  // Resolved host address used to open the WebSocket connection.
  // For WiFi: uses the explicit IP field; falls back to id (for backward compat).
  String get host => ip ?? id;

  // Material icon that represents this device in the list
  IconData get icon {
    switch (deviceType) {
      case CastDeviceType.mac:
        return Icons.laptop_mac;
      case CastDeviceType.windowsPc:
        return Icons.computer;
      case CastDeviceType.smartTv:
        return Icons.tv;
      case CastDeviceType.bluetoothSpeaker:
        return Icons.speaker;
      case CastDeviceType.bluetoothDevice:
        return Icons.bluetooth;
      case CastDeviceType.unknown:
        return Icons.devices_other;
    }
  }

  // Short label shown below the device name
  String get typeLabel {
    switch (deviceType) {
      case CastDeviceType.mac:
        return 'Mac Receiver';
      case CastDeviceType.windowsPc:
        return 'PC Receiver';
      case CastDeviceType.smartTv:
        return 'Smart TV';
      case CastDeviceType.bluetoothSpeaker:
        return 'BT Speaker';
      case CastDeviceType.bluetoothDevice:
        return 'BT Device';
      case CastDeviceType.unknown:
        return 'Unknown';
    }
  }

  // Human-readable signal quality label based on RSSI value
  String get signalLabel {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -65) return 'Good';
    if (rssi >= -75) return 'Fair';
    return 'Weak';
  }

  // Color representing signal quality (green = strong, red = weak)
  Color get signalColor {
    if (rssi >= -50) return Colors.greenAccent;
    if (rssi >= -65) return Colors.lightGreenAccent;
    if (rssi >= -75) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  // Number of filled signal bars (1–4) shown in the device tile
  int get signalBars {
    if (rssi >= -50) return 4;
    if (rssi >= -65) return 3;
    if (rssi >= -75) return 2;
    return 1;
  }
}
