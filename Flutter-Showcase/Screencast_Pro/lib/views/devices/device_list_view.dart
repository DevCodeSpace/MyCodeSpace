import 'package:permission_handler/permission_handler.dart';
import '../../utils/import_to_export.dart';
import '../../controllers/device_controller.dart';
import '../../models/cast_device.dart';

// DeviceListView shows all receiver devices found on the same WiFi network.
//
// When this screen opens, DeviceController automatically sends a UDP broadcast
// ("SCREEN_CAST_DISCOVER") to the local subnet. Any Mac or PC running
// ReceiverService replies with its hostname, IP, and WebSocket port.
// Those replies appear as tappable tiles within ~4 seconds.
//
// The user taps a tile to start casting to that device.
class DeviceListView extends GetView<DeviceController> {
  const DeviceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('WiFi Devices', style: boldPoppins(17, textColor: Colors.white)),
        actions: [
          // Refresh button — restarts the UDP scan; shows a spinner while scanning
          Obx(() => controller.isScanning.value
              ? const SizedBox(
                  width: 48,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white54),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.refresh_rounded, color: controller.accent),
                  onPressed: controller.startScan,
                )),
        ],
      ),
      body: Column(
        children: [
          // WiFi network banner — shows SSID and phone IP so user can verify
          // both the phone and Mac are on the same network
          Obx(() => controller.wifiSSID.value != null
              ? _WifiBanner(
                  ssid: controller.wifiSSID.value!,
                  ip:   controller.wifiIP.value,
                )
              : const SizedBox.shrink()),

          // Animated progress bar visible while UDP scan is running
          Obx(() => controller.isScanning.value
              ? _ScanBar(
                  color: controller.accent,
                  label: 'Looking for receivers on your WiFi network...',
                )
              : const SizedBox.shrink()),

          // Permission-denied banner if location was rejected (needed for SSID)
          Obx(() => controller.permissionDenied.value
              ? const _PermissionBanner(
                  label: 'Location permission required to read WiFi info.\n'
                         'Allow it in Settings to see network details.',
                )
              : const SizedBox.shrink()),

          // Device list — empty state or discovered device tiles
          Expanded(
            child: Obx(() {
              if (controller.devices.isEmpty) {
                return _EmptyState(isScanning: controller.isScanning.value);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: controller.devices.length,
                itemBuilder: (_, i) {
                  final device = controller.devices[i];
                  return _DeviceTile(
                    device: device,
                    accent: controller.accent,
                    // Tapping a tile triggers the "Connecting…" dialog + navigation
                    onTap: () => controller.connectToDevice(device),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── WiFi network info banner ──────────────────────────────────────────────────

// Shows the current WiFi network name and the phone's IP address.
// This helps the user verify both their phone and the Mac are on the same subnet.
class _WifiBanner extends StatelessWidget {
  final String  ssid;
  final String? ip;

  const _WifiBanner({required this.ssid, this.ip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.wifiAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.wifiAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_rounded, color: AppColors.wifiAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Strip surrounding quotes that Android sometimes adds to SSIDs
                Text(
                  ssid.replaceAll('"', ''),
                  style: semiboldPoppins(14, textColor: Colors.white),
                ),
                if (ip != null)
                  Text(ip!, style: regularPoppins(12, textColor: Colors.white54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.wifiAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Connected', style: boldPoppins(11, textColor: AppColors.wifiAccent)),
          ),
        ],
      ),
    );
  }
}

// ── Scan progress bar ─────────────────────────────────────────────────────────

// Indeterminate linear progress bar shown while the UDP scan is running.
class _ScanBar extends StatelessWidget {
  final Color  color;
  final String label;

  const _ScanBar({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: regularPoppins(13, textColor: color)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// ── Permission denied banner ──────────────────────────────────────────────────

// Shown if the user denied the location permission required for WiFi SSID reading.
// Provides a direct "Settings" shortcut to fix it without leaving the app.
class _PermissionBanner extends StatelessWidget {
  final String label;

  const _PermissionBanner({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: regularPoppins(13, textColor: Colors.white70)),
          ),
          TextButton(
            onPressed: openAppSettings, // Opens the OS app-settings page
            child: Text('Settings', style: semiboldPoppins(13, textColor: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

// Shown when no devices were found after the scan completes.
class _EmptyState extends StatelessWidget {
  final bool isScanning;

  const _EmptyState({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    // During scanning the progress bar already shows — don't double up
    if (isScanning) return const SizedBox.shrink();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_find_rounded, size: 64, color: Colors.white12),
          const SizedBox(height: 16),
          Text('No receivers found', style: mediumPoppins(16, textColor: Colors.white38)),
          const SizedBox(height: 6),
          Text(
            'Make sure the Mac/PC app is open\nand on the same WiFi network.',
            style: regularPoppins(13, textColor: Colors.white24),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Device tile ───────────────────────────────────────────────────────────────

// One row in the device list: icon | name + type | signal bars | chevron.
// Tapping it calls DeviceController.connectToDevice().
class _DeviceTile extends StatelessWidget {
  final CastDevice   device;
  final Color        accent;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.device,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            // Device icon (laptop_mac for Mac receiver, computer for PC, etc.)
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(device.icon, color: accent, size: 24),
            ),
            const SizedBox(width: 14),

            // Name and type label (e.g. "Pradip's MacBook Pro" / "Mac Receiver")
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: semiboldPoppins(15, textColor: Colors.white)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(device.typeLabel,
                          style: regularPoppins(12, textColor: Colors.white54)),
                      const SizedBox(width: 8),
                      // Small dot separator
                      Container(
                        width: 4, height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // IP address shown instead of signal label for WiFi receivers
                      Text(
                        device.ip ?? device.id,
                        style: regularPoppins(12, textColor: Colors.white38),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right chevron as tap affordance
            Icon(
              Icons.chevron_right_rounded,
              color: accent.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
