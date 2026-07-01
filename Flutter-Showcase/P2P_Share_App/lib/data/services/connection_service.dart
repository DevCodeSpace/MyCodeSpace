import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/pairing_request.dart';
import '../../domain/entities/transfer_request.dart';
import '../models/device_model.dart';

class ConnectionService {
  ConnectionService() : _dio = Dio();

  final Dio _dio;
  final StreamController<PairingRequest> _pairingRequests =
      StreamController<PairingRequest>.broadcast();
  final StreamController<TransferRequest> _transferRequests =
      StreamController<TransferRequest>.broadcast();
  final StreamController<Device> _disconnections =
      StreamController<Device>.broadcast();
  final StreamController<String> _transferCancellations =
      StreamController<String>.broadcast();

  HttpServer? _controlServer;
  RawDatagramSocket? _discoverySocket;
  bool _isRunning = false;
  String? _cachedLocalIp;

  _PendingRequest? _pendingPairingRequest;
  _PendingRequest? _pendingTransferRequest;

  Future<void> ensureRunning() async {
    if (_isRunning) return;

    await _startControlServer();
    await _startDiscoveryListener();
    _isRunning = true;
  }

  Stream<PairingRequest> watchPairingRequests() => _pairingRequests.stream;
  Stream<TransferRequest> watchTransferRequests() => _transferRequests.stream;
  Stream<Device> watchDisconnections() => _disconnections.stream;
  Stream<String> watchTransferCancellations() => _transferCancellations.stream;

  Future<String?> getLocalIpAddress() async {
    if (_cachedLocalIp != null && _cachedLocalIp!.isNotEmpty) {
      return _cachedLocalIp;
    }

    final wifiIp = await NetworkInfo().getWifiIP();
    if (wifiIp != null && wifiIp.isNotEmpty) {
      _cachedLocalIp = wifiIp;
      return wifiIp;
    }

    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.address.startsWith('127.')) {
          _cachedLocalIp = address.address;
          return address.address;
        }
      }
    }
    return null;
  }

  Future<String> getDisplayName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // androidInfo.model is typically the user-facing model name (e.g. Pixel 6 Pro)
        return androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // iosInfo.name is the user-assigned device name (e.g. "Priyanshu's iPhone")
        return iosInfo.name;
      } else if (Platform.isMacOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        return macOsInfo.computerName;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.name;
      }
    } catch (e) {
      // Fallback to legacy detection if plugin fails
    }

    final hostName = Platform.localHostname.trim();
    if (hostName.isNotEmpty && hostName.toLowerCase() != 'localhost') {
      return hostName;
    }

    final ip = await getLocalIpAddress();
    final segments = ip?.split('.');
    final suffix = (segments != null && segments.isNotEmpty)
        ? segments.last
        : null;
    return suffix == null ? 'ShareSphere Device' : 'ShareSphere Device $suffix';
  }

  Future<List<Device>> discoverPeers() async {
    await ensureRunning();
    final localIp = await getLocalIpAddress();

    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;

    final devices = <String, Device>{};
    final completer = Completer<List<Device>>();

    late final StreamSubscription<RawSocketEvent> subscription;
    subscription = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final packet = socket.receive();
      if (packet == null) return;

      try {
        final payload =
            jsonDecode(utf8.decode(packet.data)) as Map<String, dynamic>;
        if (payload['type'] != 'discover-response') return;

        final device = DeviceModel.fromJson({
          ...payload,
          'ipAddress': payload['ipAddress'] ?? packet.address.address,
          'port': payload['port'] ?? AppConstants.controlPort,
        });
        if (localIp != null && device.ipAddress == localIp) {
          return;
        }
        devices[device.ipAddress] = device;
      } on FormatException {
        return;
      }
    });

    socket.send(
      utf8.encode(
        jsonEncode({
          'type': 'discover-request',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      ),
      InternetAddress('255.255.255.255'),
      AppConstants.discoveryPort,
    );

    Future<void>.delayed(const Duration(milliseconds: 1800), () async {
      await subscription.cancel();
      socket.close();
      if (!completer.isCompleted) {
        final results = devices.values.toList()
          ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
        completer.complete(results);
      }
    });

    return completer.future;
  }

  Future<Device?> probePeer(String ipAddress) async {
    await ensureRunning();
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'http://$ipAddress:${AppConstants.controlPort}/ping',
        options: Options(
          sendTimeout: const Duration(milliseconds: 900),
          receiveTimeout: const Duration(milliseconds: 900),
          responseType: ResponseType.json,
        ),
      );

      return DeviceModel.fromJson({
        ...?response.data,
        'ipAddress': ipAddress,
        'port': response.data?['port'] ?? AppConstants.controlPort,
      });
    } on DioException {
      return null;
    } on SocketException {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<Device?> sendPairingRequest(Device device) async {
    await ensureRunning();
    final localIp = await getLocalIpAddress();
    if (localIp == null) {
      throw Exception('Unable to resolve local IP address.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      'http://${device.ipAddress}:${device.port}/pair/request',
      data: {
        'requestId': _requestId(),
        'senderName': await getDisplayName(),
        'senderIp': localIp,
        'senderPort': AppConstants.controlPort,
      },
      options: Options(
        sendTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(minutes: 2),
        contentType: Headers.jsonContentType,
      ),
    );

    final data = response.data ?? <String, dynamic>{};
    if (data['accepted'] != true) return null;

    return DeviceModel.fromJson({
      'id': data['id'] ?? data['ipAddress'],
      'deviceName': data['deviceName'] ?? device.name,
      'ipAddress': data['ipAddress'] ?? device.ipAddress,
      'port': data['port'] ?? device.port,
      'kind': data['kind'] ?? 'phone',
      'isConnected': true,
    });
  }

  Future<bool> sendTransferRequest(Device device) async {
    await ensureRunning();
    final localIp = await getLocalIpAddress();
    if (localIp == null) {
      throw Exception('Unable to resolve local IP address.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      'http://${device.ipAddress}:${device.port}/transfer/request',
      data: {
        'requestId': _requestId(),
        'senderName': await getDisplayName(),
        'senderIp': localIp,
        'senderPort': AppConstants.controlPort,
      },
      options: Options(
        sendTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(minutes: 5),
        contentType: Headers.jsonContentType,
      ),
    );

    return response.data?['accepted'] == true;
  }

  Future<void> sendDisconnectRequest(Device device) async {
    await ensureRunning();
    try {
      await _dio.post<void>(
        'http://${device.ipAddress}:${device.port}/disconnect',
        data: {
          'senderIp': await getLocalIpAddress(),
          'senderName': await getDisplayName(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      // Ignore errors during disconnect as the peer might already be gone
    }
  }

  Future<void> notifyTransferCancel(String ipAddress) async {
    await ensureRunning();
    try {
      await _dio.post<void>(
        'http://$ipAddress:${AppConstants.controlPort}/transfer/cancel',
        data: {'senderIp': await getLocalIpAddress()},
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      // Ignore errors as the peer might already have closed the connection
    }
  }

  Future<void> acceptPairingRequest(String requestId) async {
    final request = _pendingPairingRequest;
    if (request == null || request.requestId != requestId) return;

    request.completer.complete({
      'accepted': true,
      'id': request.device.id,
      'deviceName': await getDisplayName(),
      'ipAddress': await getLocalIpAddress(),
      'port': AppConstants.controlPort,
      'kind': 'phone',
    });
    _pendingPairingRequest = null;
  }

  Future<void> rejectPairingRequest(String requestId) async {
    final request = _pendingPairingRequest;
    if (request == null || request.requestId != requestId) return;
    request.completer.complete({'accepted': false});
    _pendingPairingRequest = null;
  }

  Future<void> acceptTransferRequest(String requestId) async {
    final request = _pendingTransferRequest;
    if (request == null || request.requestId != requestId) return;
    request.completer.complete({'accepted': true});
    _pendingTransferRequest = null;
  }

  Future<void> rejectTransferRequest(String requestId) async {
    final request = _pendingTransferRequest;
    if (request == null || request.requestId != requestId) return;
    request.completer.complete({'accepted': false});
    _pendingTransferRequest = null;
  }

  Future<void> _startControlServer() async {
    _controlServer = await HttpServer.bind(
      InternetAddress.anyIPv4,
      AppConstants.controlPort,
      shared: true,
    );

    unawaited(() async {
      await for (final request in _controlServer!) {
        try {
          await _handleControlRequest(request);
        } catch (_) {
          request.response
            ..statusCode = HttpStatus.internalServerError
            ..write(jsonEncode({'error': 'internal_error'}));
          await request.response.close();
        }
      }
    }());
  }

  Future<void> _startDiscoveryListener() async {
    _discoverySocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      AppConstants.discoveryPort,
      reuseAddress: true,
      reusePort: false,
    );
    _discoverySocket?.broadcastEnabled = true;
    _discoverySocket?.listen((event) async {
      if (event != RawSocketEvent.read) return;
      final packet = _discoverySocket?.receive();
      if (packet == null) return;

      try {
        final payload =
            jsonDecode(utf8.decode(packet.data)) as Map<String, dynamic>;
        if (payload['type'] != 'discover-request') return;

        final ip = await getLocalIpAddress();
        if (ip == null) return;

        _discoverySocket?.send(
          utf8.encode(
            jsonEncode({
              'type': 'discover-response',
              'id': ip,
              'deviceName': await getDisplayName(),
              'ipAddress': ip,
              'port': AppConstants.controlPort,
              'kind': 'phone',
            }),
          ),
          packet.address,
          packet.port,
        );
      } on FormatException {
        return;
      }
    });
  }

  Future<void> _handleControlRequest(HttpRequest request) async {
    final path = request.uri.path;
    if (request.method == 'GET' && path == '/ping') {
      await _writeJson(request.response, {
        'deviceName': await getDisplayName(),
        'port': AppConstants.controlPort,
        'transferPort': AppConstants.defaultPort,
        'kind': 'phone',
      });
      return;
    }

    if (request.method == 'POST' && path == '/pair/request') {
      final data = await _readJsonBody(request);
      final sender = DeviceModel.fromJson({
        'id': data['senderIp'] ?? '',
        'deviceName': data['senderName'] ?? 'Nearby device',
        'ipAddress': data['senderIp'] ?? '',
        'port': data['senderPort'] ?? AppConstants.controlPort,
        'kind': 'phone',
      });

      final pending = _PendingRequest(
        requestId: data['requestId'] as String? ?? _requestId(),
        device: sender,
      );
      _pendingPairingRequest = pending;
      _pairingRequests.add(
        PairingRequest(requestId: pending.requestId, sender: sender),
      );

      final decision = await pending.completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () => <String, dynamic>{'accepted': false},
      );
      await _writeJson(request.response, decision);
      return;
    }

    if (request.method == 'POST' && path == '/transfer/request') {
      final data = await _readJsonBody(request);
      final sender = DeviceModel.fromJson({
        'id': data['senderIp'] ?? '',
        'deviceName': data['senderName'] ?? 'Nearby device',
        'ipAddress': data['senderIp'] ?? '',
        'port': data['senderPort'] ?? AppConstants.controlPort,
        'kind': 'phone',
      });

      final pending = _PendingRequest(
        requestId: data['requestId'] as String? ?? _requestId(),
        device: sender,
      );
      _pendingTransferRequest = pending;
      _transferRequests.add(
        TransferRequest(requestId: pending.requestId, sender: sender),
      );

      final decision = await pending.completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => <String, dynamic>{'accepted': false},
      );
      await _writeJson(request.response, decision);
      return;
    }

    if (request.method == 'POST' && path == '/disconnect') {
      final data = await _readJsonBody(request);
      final sender = DeviceModel.fromJson({
        'id': data['senderIp'] ?? '',
        'deviceName': data['senderName'] ?? 'Nearby device',
        'ipAddress': data['senderIp'] ?? '',
        'port': AppConstants.controlPort,
        'kind': 'phone',
      });
      _disconnections.add(sender);
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    if (request.method == 'POST' && path == '/transfer/cancel') {
      final data = await _readJsonBody(request);
      final senderIp =
          data['senderIp'] as String? ??
          request.connectionInfo?.remoteAddress.address;
      if (senderIp != null) {
        _transferCancellations.add(senderIp);
      }
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  Future<Map<String, dynamic>> _readJsonBody(HttpRequest request) async {
    final body = await utf8.decoder.bind(request).join();
    if (body.isEmpty) return <String, dynamic>{};
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<void> _writeJson(
    HttpResponse response,
    Map<String, dynamic> data,
  ) async {
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(data));
    await response.close();
  }

  String _requestId() => DateTime.now().microsecondsSinceEpoch.toString();
}

class _PendingRequest {
  _PendingRequest({required this.requestId, required this.device});

  final String requestId;
  final Device device;
  final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();
}
