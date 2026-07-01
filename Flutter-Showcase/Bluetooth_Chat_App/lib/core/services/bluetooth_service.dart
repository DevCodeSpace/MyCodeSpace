import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:ble_peripheral/ble_peripheral.dart';

class IncomingChatMessage {
  final String deviceId;
  final String message;
  final DateTime timestamp;

  IncomingChatMessage({
    required this.deviceId,
    required this.message,
    required this.timestamp,
  });
}

class BtService extends GetxService {
  static const String chatAdvertiseName = 'BTChat';
  final _adapterState = fbp.BluetoothAdapterState.unknown.obs;
  final _scanResults = <fbp.ScanResult>[].obs;
  final _isScanning = false.obs;
  final _connectedDevices = <fbp.BluetoothDevice>[].obs;
  final _isDiscoverable = false.obs;
  final _debugStatus = 'Idle'.obs;
  final _rawScanCount = 0.obs;

  final _incomingMessages = StreamController<IncomingChatMessage>.broadcast();
  final Map<String, StreamSubscription<fbp.BluetoothConnectionState>>
  _connectionSubscriptions = {};
  final _peripheralConnections = <String>{}.obs;
  bool _gattServerInitialized = false;
  Future<bool>? _peripheralSetupFuture;

  StreamSubscription? _adapterStateSubscription;
  StreamSubscription? _scanResultsSubscription;
  StreamSubscription? _isScanningSubscription;

  // Custom Service & Characteristic UUIDs for Chat
  static const String chatServiceUuid = 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7';
  static const String chatCharUuid = '1965e648-7d8a-4934-972a-28952402120e';

  // Getters
  fbp.BluetoothAdapterState get adapterState => _adapterState.value;
  List<fbp.ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning.value;
  List<fbp.BluetoothDevice> get connectedDevices => _connectedDevices;
  bool get isDiscoverable => _isDiscoverable.value;
  String get debugStatus => _debugStatus.value;
  int get rawScanCount => _rawScanCount.value;

  Rx<fbp.BluetoothAdapterState> get adapterStateObs => _adapterState;
  RxList<fbp.ScanResult> get scanResultsObs => _scanResults;
  RxBool get isScanningObs => _isScanning;
  RxBool get isDiscoverableObs => _isDiscoverable;
  RxString get debugStatusObs => _debugStatus;
  RxInt get rawScanCountObs => _rawScanCount;
  Stream<IncomingChatMessage> get incomingMessages => _incomingMessages.stream;
  List<String> get peripheralConnections => _peripheralConnections.toList();

  Future<BtService> init() async {
    BlePeripheral.setBleStateChangeCallback((isOn) {
      _debugStatus.value = isOn ? 'BLE peripheral ready' : 'BLE peripheral off';
      Get.log('Peripheral BLE state: $isOn');
    });
    BlePeripheral.setAdvertisingStatusUpdateCallback((advertising, error) {
      _isDiscoverable.value = advertising;
      _debugStatus.value = error == null
          ? (advertising ? 'Advertising started' : 'Advertising stopped')
          : 'Advertising error: $error';
      Get.log('Advertising status: $advertising error=$error');
    });

    _adapterStateSubscription = fbp.FlutterBluePlus.adapterState.listen((
      state,
    ) {
      _adapterState.value = state;
    });

    _scanResultsSubscription = fbp.FlutterBluePlus.scanResults.listen((
      results,
    ) {
      _rawScanCount.value = results.length;
      final filtered = results.where(_isChatCandidate).toList();
      _scanResults.value = filtered;
      _debugStatus.value =
          'Scan sees ${results.length} raw devices, ${filtered.length} chat candidates';
      Get.log(_debugStatus.value);
    });

    _isScanningSubscription = fbp.FlutterBluePlus.isScanning.listen((scanning) {
      _isScanning.value = scanning;
    });

    return this;
  }

  Future<bool> ensurePeripheralReady() async {
    if (_gattServerInitialized) {
      return true;
    }

    if (_peripheralSetupFuture != null) {
      return _peripheralSetupFuture!;
    }

    _peripheralSetupFuture = _initPeripheralServer();
    final success = await _peripheralSetupFuture!;
    if (!success) {
      _peripheralSetupFuture = null;
    }
    return success;
  }

  Future<bool> _initPeripheralServer() async {
    try {
      if (_gattServerInitialized) {
        return true;
      }

      if (adapterState != fbp.BluetoothAdapterState.on) {
        _debugStatus.value = 'Bluetooth adapter is off';
        return false;
      }

      await BlePeripheral.initialize();
      await BlePeripheral.clearServices();
      await BlePeripheral.addService(
        BleService(
          uuid: chatServiceUuid,
          primary: true,
          characteristics: [
            BleCharacteristic(
              uuid: chatCharUuid,
              properties: [
                CharacteristicProperties.read.index,
                CharacteristicProperties.write.index,
                CharacteristicProperties.notify.index,
                CharacteristicProperties.indicate.index,
              ],
              descriptors: [
                BleDescriptor(
                  uuid: '00002902-0000-1000-8000-00805f9b34fb',
                  permissions: [
                    AttributePermissions.readable.index,
                    AttributePermissions.writeable.index,
                  ],
                ),
              ],
              permissions: [
                AttributePermissions.readable.index,
                AttributePermissions.writeable.index,
              ],
            ),
          ],
        ),
      );

      // Handle incoming Write requests (Incoming Messages)
      BlePeripheral.setWriteRequestCallback((
        deviceId,
        characteristicId,
        offset,
        value,
      ) {
        if (characteristicId == chatCharUuid && value != null) {
          try {
            final message = utf8.decode(value);
            _incomingMessages.add(
              IncomingChatMessage(
                deviceId: deviceId,
                message: message,
                timestamp: DateTime.now(),
              ),
            );
            return WriteRequestResult(status: 0);
          } catch (e) {
            return WriteRequestResult(status: 1);
          }
        }
        return WriteRequestResult(status: 10);
      });
      BlePeripheral.setConnectionStateChangeCallback((deviceId, connected) {
        Get.log('Peripheral connection state: $deviceId connected=$connected');
        if (connected) {
          _peripheralConnections.add(deviceId);
          final device = fbp.BluetoothDevice.fromId(deviceId);
          if (!_connectedDevices.any((d) => d.remoteId.str == deviceId)) {
            _connectedDevices.add(device);
          }
        } else {
          _peripheralConnections.remove(deviceId);
          _connectedDevices.removeWhere((d) => d.remoteId.str == deviceId);
        }
      });
      _gattServerInitialized = true;
      Get.log('Bluetooth chat GATT service ready: $chatServiceUuid');
      _debugStatus.value = 'Chat GATT service ready';
      return true;
    } catch (e) {
      Get.log('Peripheral server init error: $e');
      _debugStatus.value = 'Peripheral init failed: $e';
      return false;
    }
  }

  Future<void> turnOn() async {
    await fbp.FlutterBluePlus.turnOn();
  }

  Future<void> startScan() async {
    if (adapterState != fbp.BluetoothAdapterState.on) {
      Get.snackbar('Bluetooth Off', 'Please turn on Bluetooth to scan');
      return;
    }
    _scanResults.clear();
    _rawScanCount.value = 0;
    _debugStatus.value = 'Starting scan...';
    await fbp.FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: true,
      continuousUpdates: true,
      removeIfGone: const Duration(seconds: 4),
    );
  }

  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
  }

  Future<void> setDiscoverable(bool enable) async {
    if (enable) {
      final ready = await ensurePeripheralReady();
      if (!ready) {
        Get.snackbar(
          'Bluetooth Setup',
          'Could not start chat service. Turn Bluetooth on and grant permissions, then try again.',
        );
        return;
      }

      try {
        await BlePeripheral.startAdvertising(services: [chatServiceUuid]);
        _debugStatus.value = 'Requested advertising start';
      } catch (e) {
        Get.log('Advertising start failed, retrying minimal payload: $e');
        await BlePeripheral.startAdvertising(services: [chatServiceUuid]);
        _debugStatus.value = 'Advertising retried with minimal payload';
      }
    } else {
      await BlePeripheral.stopAdvertising();
      _debugStatus.value = 'Requested advertising stop';
    }
  }

  Future<void> startBackgroundChatHosting() async {
    if (adapterState != fbp.BluetoothAdapterState.on) {
      _debugStatus.value = 'Bluetooth adapter is off';
      return;
    }

    final ready = await ensurePeripheralReady();
    if (!ready || _isDiscoverable.value) {
      return;
    }

    try {
      await BlePeripheral.startAdvertising(services: [chatServiceUuid]);
      _debugStatus.value = 'Paired-device chat service active';
    } catch (e) {
      Get.log('Background chat hosting failed: $e');
      _debugStatus.value = 'Background hosting failed: $e';
    }
  }

  Future<List<fbp.BluetoothDevice>> getSystemDevices() async {
    return fbp.FlutterBluePlus.systemDevices([]);
  }

  Future<List<fbp.BluetoothDevice>> getBondedDevices() async {
    // Returns paired devices
    return await fbp.FlutterBluePlus.bondedDevices;
  }

  Future<fbp.BluetoothDevice?> resolveKnownDevice(String remoteId) async {
    final existing = _connectedDevices.firstWhereOrNull(
      (device) => device.remoteId.str == remoteId,
    );
    if (existing != null) {
      return existing;
    }

    final knownDevices = [
      ...await getSystemDevices(),
      ...await getBondedDevices(),
      ..._scanResults.map((result) => result.device),
    ];

    return knownDevices.firstWhereOrNull(
      (device) => device.remoteId.str == remoteId,
    );
  }

  Future<bool> connect(fbp.BluetoothDevice device) async {
    try {
      if (!device.isConnected) {
        await device.connect(
          license: fbp.License.free,
          timeout: const Duration(seconds: 10),
        );
      }

      if (!_connectedDevices.contains(device)) {
        _connectedDevices.add(device);
      }

      _connectionSubscriptions[device.remoteId.str]?.cancel();
      _connectionSubscriptions[device.remoteId.str] = device.connectionState
          .listen((state) {
            final isConnected = state == fbp.BluetoothConnectionState.connected;
            if (isConnected) {
              if (!_connectedDevices.contains(device)) {
                _connectedDevices.add(device);
              }
            } else {
              _connectedDevices.removeWhere(
                (d) => d.remoteId.str == device.remoteId.str,
              );
              if (state == fbp.BluetoothConnectionState.disconnected) {
                Get.snackbar(
                  'Disconnected',
                  'Connection lost with ${device.platformName}',
                );
              }
            }
          });

      return true;
    } catch (e) {
      Get.snackbar('Connection Error', 'Failed to connect: $e');
      return false;
    }
  }

  bool canReplyToPeripheralPeer(String remoteId) {
    return _peripheralConnections.contains(remoteId);
  }

  Future<void> sendPeripheralMessage({
    required String remoteId,
    required String message,
  }) async {
    await BlePeripheral.updateCharacteristic(
      characteristicId: chatCharUuid,
      deviceId: remoteId,
      value: Uint8List.fromList(utf8.encode(message)),
    );
  }

  bool _isChatCandidate(fbp.ScanResult result) {
    final adv = result.advertisementData;
    final hasChatService = adv.serviceUuids.any(
      (uuid) => uuid.toString().toLowerCase() == chatServiceUuid.toLowerCase(),
    );
    final hasChatName =
        adv.advName.trim().toLowerCase() == chatAdvertiseName.toLowerCase();
    final deviceHasChatName =
        result.device.platformName.trim().toLowerCase() ==
            chatAdvertiseName.toLowerCase() ||
        result.device.advName.trim().toLowerCase() ==
            chatAdvertiseName.toLowerCase();

    return adv.connectable &&
        (hasChatService || hasChatName || deviceHasChatName);
  }

  Future<void> disconnect(fbp.BluetoothDevice device) async {
    try {
      await device.disconnect();
      _connectedDevices.remove(device);
      await _connectionSubscriptions.remove(device.remoteId.str)?.cancel();
    } catch (e) {
      Get.snackbar('Disconnection Error', 'Failed to disconnect: $e');
    }
  }

  @override
  void onClose() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    for (final subscription in _connectionSubscriptions.values) {
      subscription.cancel();
    }
    _incomingMessages.close();
    BlePeripheral.stopAdvertising();
    super.onClose();
  }
}
