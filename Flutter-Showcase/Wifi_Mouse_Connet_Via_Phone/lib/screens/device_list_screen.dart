import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mouse_demo/controllers/device_list_controller.dart';
import 'package:mouse_demo/models/device.dart';
import 'package:mouse_demo/routes/app_routes.dart';
import 'package:mouse_demo/theme/app_colors.dart';
import 'package:mouse_demo/widgets/no_desktop_found_widget.dart';
import 'package:mouse_demo/widgets/scanning_widget.dart';

class DeviceListScreen extends GetView<DeviceListController> {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mouse Control'),
        actions: [IconButton(onPressed: () => Get.toNamed(AppRoutes.settings), icon: const Icon(Icons.settings_rounded))],
      ),
      body: Obx(() {
        final hasHistory = controller.deviceHistory.isNotEmpty;
        final showScanner = controller.isScanning.value;
        final showNoDevices = !showScanner && controller.devices.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align headers to left
          children: [
            if (hasHistory) ...[
              _buildSectionHeader('RECENTLY CONNECTED'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDeviceTile(controller.deviceHistory.first, isHistory: true, context: context),
              ),
              SizedBox(height: 12),
            ],

            if (showScanner)
              const Expanded(child: Center(child: ScanningWidget()))
            else if (showNoDevices)
              const Expanded(child: Center(child: NoDesktopFoundWidget()))
            else ...[
              _buildSectionHeader('AVAILABLE DESKTOPS'),
              // Wrap ListView in Expanded so it knows how much space to take
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.devices.length,
                  itemBuilder: (context, index) => _buildDeviceTile(controller.devices[index], isHistory: false, context: context),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  // Helper: Section Headers (Removed SliverToBoxAdapter)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
      ),
    );
  }

  // Helper: Reusable Device Tile
  Widget _buildDeviceTile(Device device, {required bool isHistory, required BuildContext context}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = isHistory ? (isDark ? Colors.grey.shade400 : Colors.grey.shade600) : AppColors.primary;
    final Color textColor = isDark ? AppColors.textLight : AppColors.surfaceDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [baseColor.withValues(alpha: 0.15), baseColor.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baseColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(isHistory ? Icons.history : Icons.desktop_windows_rounded, color: baseColor, size: 24),
        title: Text(
          device.name,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
        ),
        subtitle: Text(
          device.ip,
          style: TextStyle(color: textColor.withValues(alpha: 0.6), fontFamily: 'monospace', fontWeight: FontWeight.w700),
        ),
        trailing: Text(
          isHistory ? "Connected" : "Connect",
          style: TextStyle(
            color: baseColor,
            fontWeight: FontWeight.w600, // Fixed: FontWeight constructor was missing .w
          ),
        ),
        onTap: () => controller.connectToDevice(device),
      ),
    );
  }
}
