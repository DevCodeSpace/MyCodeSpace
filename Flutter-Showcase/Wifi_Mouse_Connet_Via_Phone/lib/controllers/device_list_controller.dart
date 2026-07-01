import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mouse_demo/helper/preference_helper.dart';
import 'package:mouse_demo/routes/app_routes.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pool/pool.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/device.dart';

class DeviceListController extends GetxController {
  // --- Observables ---
  RxBool isDarkMode = true.obs;
  RxBool isScanning = true.obs;
  RxBool isConnected = false.obs;
  RxList<Device> deviceHistory = <Device>[].obs;
  RxList<Device> devices = <Device>[].obs;
  RxString desktopName = "".obs;
  RxString wifiName = "-".obs;
  RxString ipAddress = "".obs;

  // --- Internal State ---
  WebSocketChannel? channel;
  String subnet = "";

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () async {
      await prepareNetwork();
      await fetchDeviceHistory();
    });
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  // --- Network Setup & WiFi Fetching ---
  Future<void> prepareNetwork() async {
    try {
      // Request location first as it's the most sensitive
      await Permission.location.request();
      await fetchWifiName();
      final info = NetworkInfo();
      String? ip = await info.getWifiIP();

      if (ip != null && ip != "0.0.0.0") {
        ipAddress.value = ip;
        subnet = ip.substring(0, ip.lastIndexOf('.'));
        scanDevices();
      } else {
        isScanning.value = false;
      }
    } catch (e, stack) {
      isScanning.value = false;
      debugPrint(e.toString());
      debugPrint(stack.toString());
    }
  }

  Future<void> fetchDeviceHistory() async {
    try {
      final history = await PreferenceHelper.getDeviceHistory();
      // Assign history to the new list instead of the live 'devices' list
      deviceHistory.assignAll(history);
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> fetchWifiName() async {
    try {
      var status = await Permission.location.status;
      if (status.isGranted) {
        final info = NetworkInfo();
        String? name = await info.getWifiName();
        // Clean quotes from SSID usually returned by Android/iOS
        wifiName.value = name?.replaceAll('"', '') ?? "Unknown WiFi";
      } else {
        wifiName.value = "Location Permission Required";
      }
    } catch (e) {
      wifiName.value = "Error fetching WiFi";
    }
  }

  // --- Scanning Logic ---
  Future<void> scanAgain() async {
    if (isScanning.value) return;

    // Reset UI State
    devices.clear();

    // Cleanup previous connection if user is rescanning
    disconnect();

    // Re-verify network context before scanning
    await prepareNetwork();
  }

  Future<void> scanDevices() async {
    // if (isScanning.value) return;
    isScanning.value = true;
    devices.clear();

    // Pool limits concurrent connections to avoid crashing the socket limit
    final pool = Pool(25);
    final List<Future> tasks = [];

    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      tasks.add(pool.withResource(() => _checkIp(ip)));
    }

    await Future.wait(tasks);
    isScanning.value = false;
    if (PreferenceHelper.isAutoConnectEnabled) {
      autoConnectRecentDevice();
    }
  }

  Future<void> _checkIp(String ip) async {
    try {
      // 1. First, try a raw TCP connection.
      // This is much faster and more likely to throw an error quickly if the IP is empty.
      final socket = await Socket.connect(ip, 3000, timeout: const Duration(seconds: 1));
      socket.destroy();

      debugPrint("🔍 Potential server found at $ip! Performing handshake...");

      // 2. If TCP worked, attempt the WebSocket handshake
      final ws = await WebSocket.connect('ws://$ip:3000').timeout(const Duration(seconds: 2));

      ws.add('who_are_you');

      final response = await ws.first.timeout(const Duration(seconds: 2));
      final data = jsonDecode(response.toString());

      if (data['type'] == 'trackpad_server') {
        final newDevice = Device(ip: ip, name: data['name'] ?? "Workstation");
        if (!devices.any((d) => d.ip == ip)) {
          devices.add(newDevice);
        }
      }
      await ws.close();
    } catch (_) {}
  }

  // --- Connection Lifecycle ---
  void connectToDevice(Device device) {
    try {
      channel = WebSocketChannel.connect(Uri.parse('ws://${device.ip}:3000'));
      isConnected.value = true;
      desktopName.value = device.name;

      Get.toNamed(AppRoutes.trackpad, arguments: {'ip': device.ip, 'name': device.name});

      channel!.stream.listen((message) => debugPrint("Incoming: $message"), onDone: () => disconnect(), onError: (_) => disconnect());
    } catch (e) {
      debugPrint("❌ Connection failed: $e");
      isConnected.value = false;
    }
  }

  void disconnect() {
    channel?.sink.close();
    channel = null;
    isConnected.value = false;

    // Automatically return to list if connection is lost while on trackpad
    if (Get.currentRoute == '/trackpad') {
      Get.back();
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void showIpChangeInfo() {
    Get.snackbar("Info", "IP address of the devices might have been changed.", snackPosition: SnackPosition.TOP, duration: Duration(seconds: 3));
  }

  void autoConnectRecentDevice() {
    if (deviceHistory.isNotEmpty) {
      final recentDevice = deviceHistory.first;
      for (Device dev in devices) {
        if ((dev.name == recentDevice.name) || (dev.ip == recentDevice.ip)) {
          connectToDevice(recentDevice);
          Get.snackbar("Auto connected with ${recentDevice.name}", "at the ${recentDevice.ip}");
          break;
        }
      }
    }
  }
}
