import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'connect_controller.dart';
import '../../core/theme/app_theme.dart';

class ConnectView extends GetView<ConnectController> {
  const ConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Device Discovery'),
        actions: [
          Obx(
            () => controller.adapterState.value == fbp.BluetoothAdapterState.on
                ? IconButton(
                    onPressed: controller.isScanning.value
                        ? controller.stopScan
                        : controller.startScan,
                    icon: Icon(
                      controller.isScanning.value
                          ? Icons.stop_circle_outlined
                          : Icons.sync,
                      size: 28,
                    ),
                    color: AppTheme.primaryBlue,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionStatusHeader(),
          _buildDiscoverableToggle(),
          _buildDebugStatus(),
          Expanded(
            child: Obx(() {
              if (controller.adapterState.value !=
                  fbp.BluetoothAdapterState.on) {
                return _buildBluetoothOffState();
              }
              return RefreshIndicator(
                onRefresh: () => controller.refreshDeviceLists(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  children: [
                    // System Devices (Already connected devices)
                    if (controller.systemDevices.isNotEmpty) ...[
                      _buildSectionHeader('CONNECTED SYSTEM DEVICES'),
                      const SizedBox(height: 12),
                      ...controller.systemDevices.map(
                        (device) => _buildDeviceCard(device, isConnected: true),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Paired Devices
                    if (controller.pairedDevices.isNotEmpty) ...[
                      _buildSectionHeader('PAIRED DEVICES'),
                      const SizedBox(height: 12),
                      ...controller.pairedDevices.map(
                        (device) => _buildDeviceCard(device, isPaired: true),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Nearby Devices (Scanned)
                    _buildSectionHeader('NEARBY DEVICES'),
                    const SizedBox(height: 12),
                    if (controller.isScanning.value &&
                        controller.scanResults.isEmpty)
                      _buildShimmerList()
                    else if (controller.scanResults.isEmpty &&
                        !controller.isScanning.value)
                      _buildEmptyState()
                    else
                      ...controller.scanResults.map(
                        (result) => _buildDeviceCard(
                          result.device,
                          rssi: result.rssi,
                          localName: result.advertisementData.advName,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverableToggle() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: controller.isDiscoverable.value
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: controller.isDiscoverable.value
                ? AppTheme.primaryBlue
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              controller.isDiscoverable.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: controller.isDiscoverable.value
                  ? AppTheme.primaryBlue
                  : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Make Discoverable',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: controller.isDiscoverable.value
                          ? AppTheme.primaryBlue
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    controller.isDiscoverable.value
                        ? 'Visible to other devices'
                        : 'Hidden from others',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: controller.isDiscoverable.value,
              onChanged: (_) => controller.toggleDiscoverable(),
              activeThumbColor: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatusHeader() {
    return Obx(() {
      final state = controller.adapterState.value;
      Color color = Colors.grey;
      String text = 'Bluetooth Unknown';

      if (state == fbp.BluetoothAdapterState.on) {
        color = Colors.green;
        text = 'Bluetooth Ready';
      } else if (state == fbp.BluetoothAdapterState.off) {
        color = Colors.red;
        text = 'Bluetooth Disabled';
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        color: color.withValues(alpha: 0.1),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (controller.isScanning.value)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDebugStatus() {
    return Obx(
      () => Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Status',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              controller.debugStatus.value,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 2),
            Text(
              'Raw scan results: ${controller.rawScanCount.value} • Chat candidates: ${controller.scanResults.length}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppTheme.darkGrey.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(
    fbp.BluetoothDevice device, {
    int? rssi,
    bool isPaired = false,
    bool isConnected = false,
    String? localName,
  }) {
    String displayName = (localName != null && localName.isNotEmpty)
        ? localName
        : (device.platformName.isNotEmpty
              ? device.platformName
              : device.remoteId.str);

    return Obx(() {
      final isConnecting =
          controller.connectingDeviceId.value == device.remoteId.str;
      final isDiscovered = controller.isDiscoveredByApp(device);
      final canAttemptConnection = controller.canAttemptChatConnection(device);
      final canOpenChat = controller.canOpenChat(device) || isConnected;
      return FadeInUp(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: _buildSignalIcon(rssi, isConnected),
            title: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            subtitle: Text(
              isConnected
                  ? 'Connected • ${device.remoteId.str}'
                  : isPaired
                  ? isDiscovered
                        ? 'Paired • Ready for chat'
                        : 'Paired • Open app on both phones'
                  : device.remoteId.str,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            trailing: isConnecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryBlue,
                    ),
                  )
                : ElevatedButton(
                    onPressed: canAttemptConnection
                        ? () => controller.connectToDevice(device)
                        : () => controller.rescanForDevice(device),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (isPaired || isConnected)
                          ? AppTheme.lightBlue
                          : AppTheme.primaryBlue,
                      foregroundColor: (isPaired || isConnected)
                          ? AppTheme.primaryBlue
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(80, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      canOpenChat
                          ? 'Open'
                          : isPaired
                          ? 'Chat'
                          : 'Connect',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
          ),
        ),
      );
    });
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        5,
        (index) => Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignalIcon(int? rssi, bool isConnected) {
    IconData icon = Icons.bluetooth_audio;
    Color color = isConnected ? Colors.green : AppTheme.primaryBlue;
    if (rssi != null) {
      if (rssi > -60) {
        icon = Icons.signal_cellular_alt;
        color = Colors.green;
      } else if (rssi > -80) {
        icon = Icons.signal_cellular_alt_2_bar;
        color = Colors.orange;
      } else {
        icon = Icons.signal_cellular_alt_1_bar;
        color = Colors.red;
      }
    } else if (isConnected) {
      icon = Icons.bluetooth_connected;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildBluetoothOffState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Pulse(
            infinite: true,
            child: Icon(
              Icons.bluetooth_disabled,
              size: 100,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Bluetooth Required',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please enable Bluetooth to continue',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: controller.turnOnBluetooth,
            child: const Text('Turn On Bluetooth'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              'No devices found yet',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
