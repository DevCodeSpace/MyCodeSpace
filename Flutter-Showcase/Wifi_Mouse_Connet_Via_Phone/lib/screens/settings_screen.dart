import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mouse_demo/controllers/settings_controller.dart';
import 'package:mouse_demo/helper/preference_helper.dart';
import 'package:mouse_demo/theme/app_colors.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Obx(
        () => SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Theme"),
              _buildSettingsCard(
                child: ListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w700)),
                  trailing: Switch.adaptive(value: controller.isDarkMode.value, onChanged: controller.toggleDarkMode),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Connectivity"),
              _buildSettingsCard(
                child: ListTile(
                  title: const Text('Auto-connect Desktop', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text("Reconnect to last used device", style: TextStyle(fontSize: 12)),
                  trailing: Switch.adaptive(value: controller.isAutoConnectEnabled.value, onChanged: controller.toggleIsAutoConnectEnabled),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Volume"),
              _buildSettingsCard(
                child: ListTile(
                  title: const Text('Control Desktop Volume', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text("Desktop volume can be changed from the phone's volume buttons", style: TextStyle(fontSize: 12)),
                  trailing: Switch.adaptive(value: controller.isControlVolumeEnabled.value, onChanged: controller.toggleIsControlVolumeEnabled),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Mouse Control"),
              _buildSettingsCard(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Cursor Move', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text("Move cursor with single finger", style: TextStyle(fontSize: 12)),
                      trailing: Switch.adaptive(value: controller.isMoveEnabled.value, onChanged: controller.toggleIsMoveEnabled),
                    ),
                    if (controller.isMoveEnabled.value)
                      _buildSliderTile(label: "Cursor Move Sensitivity", value: controller.moveSensitivity.value, onChanged: controller.changeMoveSensitivity),
                    _buildDivider(),
                    ListTile(
                      title: const Text('Cursor Drag', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text("Drag cursor with press and hold then scroll with the single finger", style: TextStyle(fontSize: 12)),
                      trailing: Switch.adaptive(value: controller.isDragEnabled.value, onChanged: controller.toggleIsDragEnabled),
                    ),
                    if (controller.isDragEnabled.value)
                      _buildSliderTile(label: "Cursor Drag Sensitivity", value: controller.dragSensitivity.value, onChanged: controller.changeDragSensitivity),
                    _buildDivider(),
                    ListTile(
                      title: const Text('Cursor Vertical Scroll', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text("Drag cursor with press and hold then scroll with the single finger", style: TextStyle(fontSize: 12)),
                      trailing: Switch.adaptive(value: controller.isVerticalScrollEnabled.value, onChanged: controller.toggleIsVerticalScrollEnabled),
                    ),
                    ListTile(
                      title: const Text('Cursor Horizontal Scroll', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text("Drag cursor with press and hold then scroll with the single finger", style: TextStyle(fontSize: 12)),
                      trailing: Switch.adaptive(value: controller.isHorizontalScrollEnabled.value, onChanged: controller.toggleIsHorizontalScrollEnabled),
                    ),
                    if (controller.isHorizontalScrollEnabled.value || controller.isVerticalScrollEnabled.value)
                      _buildSliderTile(label: "Cursor Scroll Sensitivity", value: controller.scrollSensitivity.value, onChanged: controller.changeScrollSensitivity),
                    _buildDivider(),
                    ListTile(
                      title: const Text('Gyroscope Mode', style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: const Text("Tilt phone to move cursor", style: TextStyle(fontSize: 12)),
                      trailing: Switch.adaptive(value: controller.isGyroEnabled.value, onChanged: controller.toggleIsGyroEnabled),
                    ),
                    if (controller.isGyroEnabled.value)
                      _buildSliderTile(label: "Gyro Sensitivity", value: controller.gyroSensitivity.value, onChanged: controller.changeGyroSensitivity),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(color: PreferenceHelper.isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight, borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: child),
    );
  }

  Widget _buildSliderTile({required String label, required double value, required ValueChanged<double> onChanged}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                value.toInt().toString(),
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(value: value, onChanged: onChanged, min: 1.0, max: 10.0, divisions: 9, padding: EdgeInsets.symmetric(horizontal: 8)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: PreferenceHelper.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight, indent: 20, endIndent: 20);
  }
}
