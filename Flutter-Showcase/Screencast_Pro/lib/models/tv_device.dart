import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// TvPlatform — identifies the smart TV's OS/protocol so the cast service
// knows which communication path to use.
// ---------------------------------------------------------------------------
enum TvPlatform {
  /// LG webOS TV — connected via SSAP WebSocket on port 3000.
  /// The app registers itself, then sends "ssap://browser/open" with the
  /// MJPEG stream URL so the TV's built-in browser opens it.
  lgWebOs,

  /// Samsung Tizen TV — uses the Samsung Smart TV REST API on port 8001
  /// to launch the built-in Internet browser with the stream URL.
  samsungTizen,

  /// Generic DLNA/UPnP MediaRenderer (any brand that supports AVTransport).
  /// Casting is done via SOAP: SetAVTransportURI + Play.
  dlna,

  /// Mac or Windows PC running the ScreenCast Pro receiver app.
  /// Discovered via UDP broadcast (DiscoveryService, port 8766).
  /// Casting sends {"type":"open_url","url":"..."} over its WebSocket port
  /// so the receiver opens the MJPEG stream in the default browser.
  macPc,

  /// Device type could not be identified from SSDP or XML description.
  unknown,
}

// ---------------------------------------------------------------------------
// TvDevice — a smart TV or DLNA renderer discovered on the local network.
// ---------------------------------------------------------------------------
/// Holds every piece of information needed to show the device in the list
/// and to connect to it with the correct casting protocol.
class TvDevice {
  /// IPv4 address of the TV on the LAN (e.g. "192.168.1.55")
  final String ip;

  /// HTTP port used by the TV's UPnP/DLNA server (from SSDP LOCATION header)
  final int port;

  /// Human-readable device name parsed from the UPnP description XML
  final String name;

  /// Detected platform — drives which casting protocol [TvCastService] uses
  final TvPlatform platform;

  /// Full URL to the TV's UPnP device description XML (used for DLNA)
  final String? descriptionUrl;

  /// Absolute URL of the UPnP AVTransport SOAP control endpoint.
  /// Only populated for [TvPlatform.dlna] devices where the service was found.
  final String? avTransportControlUrl;

  /// WebSocket port used only for [TvPlatform.macPc] devices.
  /// Set from the UDP discovery reply's "port" field (the dynamic OS-assigned
  /// port of the Mac's ReceiverService WebSocket server).
  final int? wsPort;

  const TvDevice({
    required this.ip,
    required this.port,
    required this.name,
    required this.platform,
    this.descriptionUrl,
    this.avTransportControlUrl,
    this.wsPort,
  });

  // Material icon that represents this device type in the UI list
  IconData get icon {
    switch (platform) {
      case TvPlatform.lgWebOs:
      case TvPlatform.samsungTizen:
        return Icons.tv_rounded;
      case TvPlatform.dlna:
        return Icons.cast_rounded;
      case TvPlatform.macPc:
        return Icons.laptop_mac_rounded;
      case TvPlatform.unknown:
        return Icons.devices_other_rounded;
    }
  }

  // Short label shown under the TV name in the device tile
  String get platformLabel {
    switch (platform) {
      case TvPlatform.lgWebOs:
        return 'LG Smart TV';
      case TvPlatform.samsungTizen:
        return 'Samsung Smart TV';
      case TvPlatform.dlna:
        return 'Smart TV (DLNA)';
      case TvPlatform.macPc:
        return 'Mac / PC Receiver';
      case TvPlatform.unknown:
        return 'Network Device';
    }
  }
}
