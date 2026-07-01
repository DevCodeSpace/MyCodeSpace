import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ClassicBluetoothDevice {
  final String name;
  final String address;

  const ClassicBluetoothDevice({required this.name, required this.address});

  factory ClassicBluetoothDevice.fromMap(Map<Object?, Object?> map) {
    return ClassicBluetoothDevice(
      name: map['name']?.toString() ?? 'Unknown Device',
      address: map['address']?.toString() ?? '',
    );
  }
}

enum ClassicConnectionRole { client, host }

class ClassicIncomingChatMessage {
  final String deviceAddress;
  final String message;
  final DateTime timestamp;

  ClassicIncomingChatMessage({
    required this.deviceAddress,
    required this.message,
    required this.timestamp,
  });
}

class ClassicConnectionEvent {
  final String? deviceAddress;
  final bool isConnected;
  final ClassicConnectionRole? role;

  ClassicConnectionEvent({
    required this.deviceAddress,
    required this.isConnected,
    required this.role,
  });
}

class ClassicBluetoothChatService extends GetxService {
  static const MethodChannel _channel = MethodChannel('bt_classic');

  final _incomingMessages =
      StreamController<ClassicIncomingChatMessage>.broadcast();
  final _connectionEvents =
      StreamController<ClassicConnectionEvent>.broadcast();
  final _isBluetoothEnabled = false.obs;
  final _activePeerAddress = RxnString();
  final _activeRole = Rxn<ClassicConnectionRole>();

  bool _serverRunning = false;

  Stream<ClassicIncomingChatMessage> get incomingMessages =>
      _incomingMessages.stream;
  Stream<ClassicConnectionEvent> get connectionEvents =>
      _connectionEvents.stream;
  bool get isBluetoothEnabled => _isBluetoothEnabled.value;
  String? get activePeerAddress => _activePeerAddress.value;
  ClassicConnectionRole? get activeRole => _activeRole.value;
  bool get hasActiveConnection => activePeerAddress != null;

  Future<ClassicBluetoothChatService> init() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    await refreshBluetoothState();
    return this;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    final args = call.arguments is Map
        ? Map<String, dynamic>.from(call.arguments as Map)
        : const <String, dynamic>{};

    switch (call.method) {
      case 'onConnected':
        _activePeerAddress.value = args['address'] as String?;
        _activeRole.value = ClassicConnectionRole.client;
        _connectionEvents.add(
          ClassicConnectionEvent(
            deviceAddress: _activePeerAddress.value,
            isConnected: true,
            role: _activeRole.value,
          ),
        );
        break;
      case 'onClientConnected':
        _activePeerAddress.value = args['address'] as String?;
        _activeRole.value = ClassicConnectionRole.host;
        _serverRunning = true;
        _connectionEvents.add(
          ClassicConnectionEvent(
            deviceAddress: _activePeerAddress.value,
            isConnected: true,
            role: _activeRole.value,
          ),
        );
        break;
      case 'onDisconnected':
      case 'onClientDisconnected':
        final previousRole = _activeRole.value;
        final previousAddress = _activePeerAddress.value;
        _activePeerAddress.value = null;
        _activeRole.value = null;
        _connectionEvents.add(
          ClassicConnectionEvent(
            deviceAddress: previousAddress,
            isConnected: false,
            role: previousRole,
          ),
        );
        if (_serverRunning) {
          await ensureServerRunning();
        }
        break;
      case 'onMessageReceived':
        final peerAddress = _activePeerAddress.value;
        final message = (args['message'] as String?)?.trim();
        if (peerAddress != null && message != null && message.isNotEmpty) {
          _incomingMessages.add(
            ClassicIncomingChatMessage(
              deviceAddress: peerAddress,
              message: message,
              timestamp: DateTime.now(),
            ),
          );
        }
        break;
      case 'onServerStarted':
        _serverRunning = true;
        break;
      case 'onServerStopped':
        _serverRunning = false;
        break;
      default:
        break;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      return await _channel.invokeMethod<bool>('requestPermissions') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> refreshBluetoothState() async {
    try {
      _isBluetoothEnabled.value =
          await _channel.invokeMethod<bool>('isBluetoothEnabled') ?? false;
    } catch (_) {
      _isBluetoothEnabled.value = false;
    }
    return _isBluetoothEnabled.value;
  }

  Future<bool> initializePairedChat() async {
    final granted = await requestPermissions();
    if (!granted) {
      return false;
    }

    final enabled = await refreshBluetoothState();
    if (!enabled) {
      return false;
    }

    await ensureServerRunning();
    return true;
  }

  Future<List<ClassicBluetoothDevice>> getPairedDevices() async {
    try {
      final raw = await _channel.invokeMethod<List>('getPairedDevices') ?? [];
      return raw
          .cast<Map<Object?, Object?>>()
          .map(ClassicBluetoothDevice.fromMap)
          .where((device) => device.address.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  bool isConnectedTo(String address) {
    return activePeerAddress == address;
  }

  Future<bool> ensureServerRunning() async {
    if (!isBluetoothEnabled) {
      return false;
    }

    if (_serverRunning && activeRole != ClassicConnectionRole.client) {
      return true;
    }

    if (activeRole == ClassicConnectionRole.client && hasActiveConnection) {
      return true;
    }

    try {
      final started = await _channel.invokeMethod<bool>('startServer') ?? false;
      _serverRunning = started;
      return started;
    } catch (_) {
      return false;
    }
  }

  Future<bool> connectToDevice(String address) async {
    if (isConnectedTo(address)) {
      return true;
    }

    if (hasActiveConnection) {
      await disconnect(resumeHosting: false);
    }

    if (_serverRunning) {
      await stopServer();
    }

    try {
      final connected =
          await _channel.invokeMethod<bool>('connectToDevice', {
            'address': address,
          }) ??
          false;
      if (!connected) {
        await ensureServerRunning();
      }
      return connected;
    } catch (_) {
      await ensureServerRunning();
      return false;
    }
  }

  Future<bool> sendMessage({
    required String address,
    required String message,
  }) async {
    if (!isConnectedTo(address)) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>('sendMessage', {
            'message': message,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> disconnect({bool resumeHosting = true}) async {
    try {
      final disconnected =
          await _channel.invokeMethod<bool>('disconnect') ?? false;
      _activePeerAddress.value = null;
      _activeRole.value = null;
      if (resumeHosting) {
        await ensureServerRunning();
      }
      return disconnected;
    } catch (_) {
      if (resumeHosting) {
        await ensureServerRunning();
      }
      return false;
    }
  }

  Future<bool> stopServer() async {
    try {
      final stopped = await _channel.invokeMethod<bool>('stopServer') ?? false;
      if (stopped) {
        _serverRunning = false;
      }
      return stopped;
    } catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    _incomingMessages.close();
    _connectionEvents.close();
    super.onClose();
  }
}
