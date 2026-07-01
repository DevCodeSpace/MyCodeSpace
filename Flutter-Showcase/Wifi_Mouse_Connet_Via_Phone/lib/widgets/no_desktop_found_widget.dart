import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mouse_demo/controllers/device_list_controller.dart';
import 'package:mouse_demo/theme/app_colors.dart';

class NoDesktopFoundWidget extends GetView<DeviceListController> {
  const NoDesktopFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final Color surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final Color buttonTextColor = isDark ? AppColors.backgroundDark : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: textColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.desktop_access_disabled_rounded, size: 50, color: textColor.withValues(alpha: 0.8)),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'No Desktops Found',
            style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            "We couldn't detect any active connections on your current network.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 20),

          _buildTroubleshootingCard(surfaceColor, textColor),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: controller.scanAgain,
              icon: Icon(Icons.radar, color: buttonTextColor, size: 20),
              label: Text(
                'RESCAN NETWORK',
                style: GoogleFonts.spaceGrotesk(color: buttonTextColor, fontWeight: FontWeight(700), fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingCard(Color surfaceColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.manage_search, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'TROUBLESHOOTING',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // List Items
          _buildTroubleshootingStep(
            icon: Icons.power_settings_new_rounded,
            title: 'Is your desktop on?',
            subtitle: 'Ensure the target computer is powered on and awake.',
            textColor: textColor,
          ),
          const SizedBox(height: 20),
          _buildTroubleshootingStep(icon: Icons.wifi, title: 'Is it on the same WiFi?', subtitle: 'Both devices must be connected to identical networks.', textColor: textColor),
          const SizedBox(height: 20),
          _buildTroubleshootingStep(
            icon: Icons.video_label,
            title: 'Is the server app running?',
            subtitle: 'The companion app must be active on your desktop.',
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingStep({required IconData icon, required String title, required String subtitle, required Color textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Pod
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: textColor.withValues(alpha: 0.05), shape: BoxShape.circle),
          child: Icon(icon, color: textColor, size: 22),
        ),
        const SizedBox(width: 16),

        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                title,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight(700)),
              ),
              Text(subtitle, style: TextStyle(color: textColor, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
