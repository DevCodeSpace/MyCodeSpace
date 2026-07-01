import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_app_usage/features/settings/settings_controller.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: GlacierColors.background,
      appBar: AppBar(
        backgroundColor: GlacierColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Settings',
          style: GlacierTextStyles.titleLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Info
              // _buildSectionTitle('Profile'),
              // _buildUserProfile(),
              // const SizedBox(height: 24),

              // Daily Usage Goal
              _buildSectionTitle('Daily Usage Goal'),
              Obx(() {
                final goalMin = controller.usageService.stats.value.totalGoalMinutes;
                final hours = goalMin ~/ 60;
                final mins = (goalMin % 60).toInt();
                final label = hours > 0 ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h') : '${mins}m';
                return _buildGoalRow(context: context, currentLabel: label, controller: controller);
              }),
              const SizedBox(height: 24),

              // General Settings
              _buildSectionTitle('Notification Preferences'),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Obx(() {
                      return _buildToggleItem(
                        icon: Icons.notifications_active_outlined,
                        title: 'Usage Alerts',
                        subtitle: 'Notify at 80% usage threshold',
                        value: controller.notifyAlerts.value,
                        onChanged: (val) => controller.notifyAlerts.value = val,
                      );
                    }),
                    _buildDivider(),
                    // Obx(() {
                    //   return _buildToggleItem(
                    //     icon: Icons.mail_outline,
                    //     title: 'Weekly Digest',
                    //     subtitle: 'Send weekly usage trends summary',
                    //     value: weeklyDigest.value,
                    //     onChanged: (val) => weeklyDigest.value = val,
                    //   );
                    // }),
                    // _buildDivider(),
                    Obx(() {
                      return _buildToggleItem(
                        icon: Icons.timer_outlined,
                        title: 'Focus Reminders',
                        subtitle: 'Remind when focus sessions end',
                        value: controller.focusReminder.value,
                        onChanged: (val) => controller.focusReminder.value = val,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Focus Schedule settings
              // _buildSectionTitle('Focus Mode Configurations'),
              // GlassContainer(
              //   padding: const EdgeInsets.all(16),
              //   child: Column(
              //     children: [
              //       _buildNavigationItem(icon: Icons.schedule_outlined, title: 'Focus Schedule', subtitle: 'Configure automated focus blocks', onTap: () {}),
              //       _buildDivider(),
              //       _buildNavigationItem(icon: Icons.list_alt_outlined, title: 'White-listed Apps', subtitle: 'Allow apps to bypass focus filters', onTap: () {}),
              //     ],
              //   ),
              // ),

              // const SizedBox(height: 24),

              // Account & Log out
              // _buildSectionTitle('Account settings'),
              // GlassContainer(
              //   padding: const EdgeInsets.all(16),
              //   child: Column(
              //     children: [_buildNavigationItem(icon: Icons.security_outlined, title: 'Privacy & Security', subtitle: 'Manage localized device sync', onTap: () {})],
              //   ),
              // ),

              // const SizedBox(height: 48),
              const SizedBox(height: 240),
              // Footnote
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: GlacierColors.surface, borderRadius: BorderRadius.circular(80)),
                  child: Text('StayOnTrack App v1.0.0 (Beta)', style: GlacierTextStyles.labelSmall.copyWith(color: GlacierColors.onSurface.withValues(alpha: 0.5))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(color: GlacierColors.primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GlacierTextStyles.labelSmall.copyWith(
              color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Premium Profile Avatar with Ambient Layering
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [GlacierColors.primary.withValues(alpha: 0.15), GlacierColors.primary.withValues(alpha: 0.02)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: GlacierColors.primary.withValues(alpha: 0.2), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'AM',
                    style: GlacierTextStyles.titleMedium.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Identity Text Block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Alex Mercer',
                  style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: GlacierColors.primary),
                ),
                // const SizedBox(height: 2),
                Text(
                  'alex@StayOnTrack.app',
                  style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Sleek Premium Action Trigger
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Handle Edit profile routing
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GlacierColors.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GlacierColors.onSurface.withValues(alpha: 0.05)),
                ),
                child: const Icon(Icons.edit_outlined, color: GlacierColors.primary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      children: [
        Icon(icon, color: GlacierColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
              ),
              Text(subtitle, style: GlacierTextStyles.bodySmall),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.8,
          alignment: Alignment.centerRight,
          child: CupertinoSwitch(value: value, activeTrackColor: GlacierColors.primaryContainer, inactiveTrackColor: GlacierColors.surfaceContainerHigh, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildNavigationItem({required IconData icon, required String title, required String subtitle, required VoidCallback? onTap, Color? titleColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? GlacierColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GlacierTextStyles.bodyMedium.copyWith(color: titleColor ?? GlacierColors.onSurface, fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle, style: GlacierTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: GlacierColors.onSurfaceVariant, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow({required BuildContext context, required String currentLabel, required SettingsController controller}) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: controller.showGoalPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, color: GlacierColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screen Time Goal',
                      style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                    ),
                    Text('Daily limit shown on the dashboard', style: GlacierTextStyles.bodySmall),
                  ],
                ),
              ),
              Text(
                currentLabel,
                style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 24, color: GlacierColors.outlineVariant.withValues(alpha: 0.3));
  }
}
