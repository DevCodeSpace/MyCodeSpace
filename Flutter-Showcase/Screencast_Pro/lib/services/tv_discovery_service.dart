import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/tv_device.dart';

// ---------------------------------------------------------------------------
// TvDiscoveryService — finds smart TVs on the local WiFi via SSDP.
//
// Protocol overview (SSDP — Simple Service Discovery Protocol, part of UPnP):
//   1. We open a UDP socket and send an M-SEARCH message to the UPnP multicast
//      group 239.255.255.250:1900. Every UPnP-capable device on the subnet
//      receives this and may reply.
//   2. TVs/renderers reply unicast with their LOCATION (URL to XML description).
//   3. We fetch each LOCATION XML to get the friendly name, manufacturer, and
//      AVTransport control URL (needed for DLNA SOAP casting calls).
//   4. We filter out non-TV devices (printers, routers, NAS) by checking the
//      SERVER header and XML manufacturer fields for known TV keywords.
//
// No multicast JOIN is required — we only send M-SEARCH and receive unicast
// replies, so no special Android permission beyond INTERNET is needed.
// ---------------------------------------------------------------------------
class TvDiscoveryService {
  // SSDP multicast address: all UPnP devices on the subnet join this group
  static const String _ssdpAddress = '239.255.255.250';
  static const int    _ssdpPort    = 1900;

  // Wait this long for TVs to respond after sending M-SEARCH.
  // MX=3 inside the request tells devices to reply within a random 0-3 s window
  // to avoid a broadcast storm; we wait 5 s to be safe.
  static const Duration _scanWindow = Duration(seconds: 5);

  // M-SEARCH discovery message (plain ASCII, CRLF line endings per HTTP spec).
  // "ssdp:all" matches every device type on the network.
  static const String _mSearch =
      'M-SEARCH * HTTP/1.1\r\n'
      'HOST: 239.255.255.250:1900\r\n'
      'MAN: "ssdp:discover"\r\n'
      'MX: 3\r\n'
      'ST: ssdp:all\r\n'
      '\r\n';

  RawDatagramSocket? _socket; // UDP socket kept as field so stopScan() can abort early

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Sends an SSDP M-SEARCH, collects responses for 5 seconds, fetches device
  /// descriptions, and returns a de-duplicated list of smart TVs found.
  Future<List<TvDevice>> scanForTvs() async {
    final locationsQueued = <String>{};      // Prevents fetching the same URL twice
    final pendingFetches  = <Future<TvDevice?>>[];

    try {
      // Bind on any available port (OS picks); bind to 0.0.0.0 so we hear replies
      // regardless of which local interface the TV routes back through.
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

      // Register a listener BEFORE sending so we don't miss early replies
      _socket!.listen((RawSocketEvent event) {
        if (event != RawSocketEvent.read) return;
        final dg = _socket!.receive();
        if (dg == null) return;

        try {
          final text     = utf8.decode(dg.data, allowMalformed: true);
          final location = _header(text, 'LOCATION');
          if (location == null || locationsQueued.contains(location)) return;
          locationsQueued.add(location);

          // Pass along the SERVER and ST headers so we can pre-filter quickly
          final server = _header(text, 'SERVER') ?? '';
          final st     = _header(text, 'ST')     ?? '';

          // Queue an async XML description fetch for this device
          pendingFetches.add(_resolveDevice(location, server, st));
        } catch (_) {}
      });

      // Send M-SEARCH to the SSDP multicast group (no group join needed for sending)
      _socket!.send(
        utf8.encode(_mSearch),
        InternetAddress(_ssdpAddress),
        _ssdpPort,
      );
      debugPrint('[TVDisc] M-SEARCH sent → waiting ${_scanWindow.inSeconds}s');

      // Hold open while TVs reply
      await Future.delayed(_scanWindow);
    } catch (e) {
      debugPrint('[TVDisc] Scan error: $e');
    } finally {
      _socket?.close();
      _socket = null;
    }

    // Settle all XML fetches that were started during the scan window
    final results = await Future.wait(pendingFetches, eagerError: false);

    // Collect non-null results and remove IP duplicates (a TV can reply multiple
    // times for different service ST values)
    final seen    = <String>{};
    final devices = results
        .whereType<TvDevice>()
        .where((d) => seen.add(d.ip))
        .toList();

    debugPrint('[TVDisc] Found ${devices.length} TV(s)');
    return devices;
  }

  /// Abort a running scan early (e.g. when the user leaves the screen).
  void stopScan() {
    _socket?.close();
    _socket = null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Downloads [locationUrl] (UPnP device description XML) and builds a
  /// [TvDevice] from it.  Returns null if the device is not a recognisable TV.
  Future<TvDevice?> _resolveDevice(
    String locationUrl,
    String serverHeader,
    String stHeader,
  ) async {
    Uri uri;
    try {
      uri = Uri.parse(locationUrl);
    } catch (_) {
      return null; // Malformed LOCATION URL
    }

    final serverLow = serverHeader.toLowerCase();
    final stLow     = stHeader.toLowerCase();

    // Quick pre-screen using the cheaper SSDP headers before making an HTTP call.
    // Only proceed if the SERVER header or ST contains known TV/renderer keywords.
    // This skips routers, printers, and NAS devices that also reply to ssdp:all.
    final looksLikeTv =
        serverLow.contains('webos')        ||
        serverLow.contains('lge')          ||
        serverLow.contains('tizen')        ||
        serverLow.contains('samsung')      ||
        stLow.contains('mediarenderer')    ||
        stLow.contains('avtransport');
    if (!looksLikeTv) return null;

    // Fetch and parse the UPnP XML device description
    String xml;
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 4);
      final req  = await client.getUrl(uri);
      final resp = await req.close().timeout(const Duration(seconds: 4));
      xml = await resp.transform(utf8.decoder).join();
      client.close();
    } catch (e) {
      debugPrint('[TVDisc] XML fetch failed ($locationUrl): $e');
      // If the HTTP fetch times out but the SSDP headers already identified the
      // brand, create a best-effort device so it still appears in the list.
      if (serverLow.contains('webos') || serverLow.contains('lge')) {
        return TvDevice(ip: uri.host, port: uri.port, name: 'LG Smart TV', platform: TvPlatform.lgWebOs);
      }
      if (serverLow.contains('tizen') || serverLow.contains('samsung')) {
        return TvDevice(ip: uri.host, port: uri.port, name: 'Samsung Smart TV', platform: TvPlatform.samsungTizen);
      }
      return null;
    }

    // Extract the human-readable device name from the XML description
    final friendlyName =
        _xmlTag(xml, 'friendlyName') ??
        _xmlTag(xml, 'modelName')    ??
        'Smart TV (${uri.host})';

    // Determine platform from XML content (more reliable than SSDP headers)
    final manufacturer = (_xmlTag(xml, 'manufacturer') ?? '').toLowerCase();
    final xmlLow       = xml.toLowerCase();

    TvPlatform platform;
    if (xmlLow.contains('webos') || manufacturer.contains('lg')) {
      platform = TvPlatform.lgWebOs;
    } else if (manufacturer.contains('samsung') || xmlLow.contains('tizen')) {
      platform = TvPlatform.samsungTizen;
    } else if (xml.contains('AVTransport') || stLow.contains('mediarenderer')) {
      platform = TvPlatform.dlna;
    } else {
      return null; // Not a recognisable TV/renderer
    }

    // For DLNA devices, locate the AVTransport SOAP control URL so we can
    // call SetAVTransportURI + Play later.
    String? avControlUrl;
    if (xml.contains('AVTransport')) {
      avControlUrl = _avTransportControlUrl(xml, uri);
    }

    return TvDevice(
      ip:                    uri.host,
      port:                  uri.port,
      name:                  friendlyName,
      platform:              platform,
      descriptionUrl:        locationUrl,
      avTransportControlUrl: avControlUrl,
    );
  }

  // ── Tiny header / XML parsers ──────────────────────────────────────────────

  // Extracts a header value from an HTTP response string.
  // Example: _header(text, 'LOCATION') → 'http://192.168.1.55:9090/desc.xml'
  String? _header(String text, String key) {
    for (final line in text.split('\r\n')) {
      if (line.toLowerCase().startsWith('${key.toLowerCase()}:')) {
        return line.substring(key.length + 1).trim();
      }
    }
    return null;
  }

  // Returns the text content of the FIRST matching XML element.
  // Uses simple string search (no full XML parser needed for UPnP fields).
  String? _xmlTag(String xml, String tag) {
    final s = xml.indexOf('<$tag>');
    if (s == -1) return null;
    final e = xml.indexOf('</$tag>', s);
    if (e == -1) return null;
    return xml.substring(s + tag.length + 2, e).trim();
  }

  // Locates the AVTransport service's SOAP controlURL inside a UPnP device
  // description XML by iterating over all <service>...</service> blocks.
  // Returns the absolute URL (base URI + relative path).
  String? _avTransportControlUrl(String xml, Uri base) {
    int cursor = 0;
    while (true) {
      final start = xml.indexOf('<service>', cursor);
      if (start == -1) break;
      final end = xml.indexOf('</service>', start);
      if (end == -1) break;

      final block = xml.substring(start, end + 10);
      cursor = end + 10;

      // Only look at the AVTransport service block
      if (block.contains('AVTransport')) {
        final path = _xmlTag(block, 'controlURL');
        if (path != null) {
          // Build absolute URL: if path is already absolute, use it as-is
          if (path.startsWith('http')) return path;
          return '${base.scheme}://${base.host}:${base.port}$path';
        }
      }
    }
    return null;
  }
}
