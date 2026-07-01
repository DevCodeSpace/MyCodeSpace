import 'package:bluetooth_chat/modules/home/home_controller.dart';
import 'package:bluetooth_chat/modules/chat/chat_controller.dart';
import 'package:bluetooth_chat/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/bluetooth_service.dart';

class ConnectController extends GetxController {
  final BtService _btService = Get.find<BtService>();

  final pairedDevices = <fbp.BluetoothDevice>[].obs;
  final systemDevices = <fbp.BluetoothDevice>[].obs;
  final connectingDeviceId = ''.obs;

  // Use streams from the service
  RxList<fbp.ScanResult> get scanResults => _btService.scanResultsObs;
  RxBool get isScanning => _btService.isScanningObs;
  Rx<fbp.BluetoothAdapterState> get adapterState => _btService.adapterStateObs;
  RxBool get isDiscoverable => _btService.isDiscoverableObs;
  RxString get debugStatus => _btService.debugStatusObs;
  RxInt get rawScanCount => _btService.rawScanCountObs;

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
    _checkAdapterState();
    refreshDeviceLists();
  }

  void _checkAdapterState() {
    ever(adapterState, (state) {
      if (state == fbp.BluetoothAdapterState.on) {
        _btService.ensurePeripheralReady();
      }
      if (state != fbp.BluetoothAdapterState.on &&
          state != fbp.BluetoothAdapterState.unknown) {
        _showBluetoothOffPopup();
      }
    });
  }

  void _showBluetoothOffPopup() {
    if (Get.isDialogOpen ?? false) return;
    Get.defaultDialog(
      title: 'Bluetooth is Off',
      middleText: 'Please enable Bluetooth to scan and connect to devices.',
      textConfirm: 'Enable',
      textCancel: 'Dismiss',
      confirmTextColor: Colors.white,
      onConfirm: () {
        turnOnBluetooth();
        Get.back();
      },
    );
  }

  Future<void> _requestPermissions() async {
    // Comprehensive permission request for Android 12+ and iOS
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise, // Crucial for message reception
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]?.isDenied ?? false) {
      Get.snackbar('Permissions', 'Bluetooth Scan permission is required');
    }

    final hasCorePermissions =
        (statuses[Permission.bluetoothScan]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothConnect]?.isGranted ?? false);

    if (hasCorePermissions &&
        adapterState.value == fbp.BluetoothAdapterState.on) {
      await _btService.ensurePeripheralReady();
      if (!isDiscoverable.value) {
        await _btService.setDiscoverable(true);
      }
      startScan();
    }
  }

  void startScan() {
    _btService.startScan();
    refreshDeviceLists();
  }

  void stopScan() => _btService.stopScan();
  void turnOnBluetooth() => _btService.turnOn();
  void toggleDiscoverable() =>
      _btService.setDiscoverable(!isDiscoverable.value);

  Future<void> refreshDeviceLists() async {
    pairedDevices.value = await _btService.getBondedDevices();
    systemDevices.value = await _btService.getSystemDevices();
  }

  bool isDiscoveredByApp(fbp.BluetoothDevice device) {
    return scanResults.any(
      (result) => result.device.remoteId.str == device.remoteId.str,
    );
  }

  bool isSystemConnected(fbp.BluetoothDevice device) {
    return systemDevices.any((d) => d.remoteId.str == device.remoteId.str);
  }

  bool canOpenChat(fbp.BluetoothDevice device) {
    return device.isConnected || isSystemConnected(device);
  }

  bool canAttemptChatConnection(fbp.BluetoothDevice device) {
    return canOpenChat(device) ||
        isDiscoveredByApp(device) ||
        pairedDevices.any(
          (paired) => paired.remoteId.str == device.remoteId.str,
        );
  }

  void rescanForDevice(fbp.BluetoothDevice device) {
    final name = device.platformName.isNotEmpty
        ? device.platformName
        : device.remoteId.str;

    Get.snackbar(
      'Scanning',
      'Looking for $name. Keep the app open and Make Discoverable enabled on the other phone.',
    );
    startScan();
  }

  void connectToDevice(fbp.BluetoothDevice device) async {
    connectingDeviceId.value = device.remoteId.str;

    final name = device.platformName.isNotEmpty
        ? device.platformName
        : 'Unknown Device';
    if (!device.isConnected) {
      await _btService.connect(device);
    }

    connectingDeviceId.value = '';
    final connected =
        device.isConnected ||
        _btService.canReplyToPeripheralPeer(device.remoteId.str);

    final chatSummary = ChatSummary(
      id: device.remoteId.str,
      name: name,
      lastMessage: connected
          ? 'Connected'
          : 'Tap send after both phones open the app',
      time: DateTime.now(),
      isOnline: connected,
    );

    Get.toNamed(
      AppRoutes.CHAT,
      arguments: ChatSessionArgs(summary: chatSummary),
    );

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshChats();
    }
  }
}
