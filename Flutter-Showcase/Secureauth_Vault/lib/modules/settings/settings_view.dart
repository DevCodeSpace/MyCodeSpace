import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/utils/app_constants.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pageBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final titleColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('screens').doc('setting').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: pageBg,
            body: Center(child: Text('Error loading configurations: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: pageBg,
            body: const Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)))),
          );
        }

        Map<String, dynamic> textMap = {};
        List<String> imageUrls = [];

        if (snapshot.hasData && snapshot.data!.exists) {
          try {
            final data = snapshot.data!.data();
            final jsonString = data?['texts'];
            final jsonImageUrls = data?['image_urls'];
            if (jsonString != null) {
              textMap = jsonDecode(jsonString) as Map<String, dynamic>;
            }
            if (jsonImageUrls != null) {
              imageUrls = List<String>.from(jsonImageUrls);
            }
          } catch (e) {
            Get.log("Error parsing string configuration payload: $e", isError: true);
          }
        }

        String getText(String key, String fallback) {
          return textMap[key]?.toString() ?? fallback;
        }

        debugPrint("Parsed Settings Configs: ${imageUrls.length} images, ${textMap.length} text entries");

        return Scaffold(
          backgroundColor: pageBg,
          appBar: AppBar(
            backgroundColor: pageBg,
            elevation: 0,
            centerTitle: false,
            title: Text(
              getText('settings_title', 'Settings'),
              style: TextStyle(color: titleColor, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4),
            ),
          ),
          body: Obx(
            () => ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              children: [
                // ── Dynamic Network Carousel Block ───────────────────────────
                if (imageUrls.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 100,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      viewportFraction: 1,
                    ),
                    items: imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                // ── Storage stats ────────────────────────────────────────────
                _SectionHeader(getText('storage_summary_header', 'Storage Summary')),
                _StatsTile(
                  credentials: controller.stats['credentials'] ?? 0,
                  documents: controller.stats['documents'] ?? 0,
                  credentialsLabel: getText('credentials_label', 'Credentials'),
                  documentsLabel: getText('documents_label', 'Documents'),
                ),

                const SizedBox(height: 12),

                // ── Appearance & Theme ───────────────────────────────────────
                _SectionHeader(getText('preferences_header', 'Preferences')),
                _GroupedCard(
                  children: [
                    _CustomSwitchTile(
                      icon: Icons.dark_mode_rounded,
                      iconColor: Colors.amber,
                      title: getText('dark_mode_title', 'Dark Mode'),
                      subtitle: getText('dark_mode_subtitle', 'Optimize UI for low-light environments'),
                      value: controller.isDarkMode.value,
                      onChanged: controller.toggleDarkMode,
                    ),
                    _CustomActionTile(
                      icon: Icons.image_outlined,
                      iconColor: Colors.teal,
                      title: getText('app_icon_title', 'App Icon'),
                      subtitle: getText('app_icon_subtitle', 'Change app icon on home screen'),
                      onTap: () => showChangeIconsSheet(getText),
                    ),
                  ],
                ),

                // ── Security ─────────────────────────────────────────────────
                _SectionHeader(getText('security_header', 'Security & Access')),
                _GroupedCard(
                  children: [
                    _CustomSwitchTile(
                      icon: Icons.fingerprint_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: getText('biometric_title', 'Biometric Unlock'),
                      subtitle: getText('biometric_subtitle', 'Use biometric verification on open'),
                      value: controller.biometricEnabled.value,
                      onChanged: controller.toggleBiometric,
                    ),
                    _CustomActionTile(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFFA855F7),
                      title: getText('autolock_title', 'Auto-Lock'),
                      subtitle: _timeoutLabel(controller.autoLockTimeout.value, getText),
                      onTap: () => _showTimeoutPicker(context, getText),
                    ),
                  ],
                ),

                // ── Backup ───────────────────────────────────────────────────
                _SectionHeader(getText('backup_header', 'Backup & Cloud Sync')),
                _GroupedCard(
                  children: [
                    controller.isGoogleSignedIn
                        ? _CustomActionTile(
                            svgPath: 'assets/logo/drive_logo.svg',
                            title: getText('google_drive_connected_title', 'Google Drive'),
                            subtitle: getText('google_drive_connected_subtitle', 'Automatic encrypted sync active'),
                            trailing: controller.isRestoring.value
                                ? const _CustomLoader()
                                : TextButton(
                                    onPressed: controller.signOutGoogle,
                                    style: TextButton.styleFrom(
                                      foregroundColor: theme.colorScheme.error,
                                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    child: Text(getText('disconnect_btn', 'Disconnect')),
                                  ),
                          )
                        : _CustomActionTile(
                            svgPath: 'assets/logo/drive_logo.svg',
                            title: controller.isRestoring.value
                                ? getText('connecting_drive_title', 'Connecting Drive...')
                                : getText('connect_drive_title', 'Connect Google Drive'),
                            subtitle: controller.isRestoring.value
                                ? getText('restoring_backup_subtitle', 'Restoring secure backup payload...')
                                : getText('enable_backup_subtitle', 'Enable secure encrypted cloud backups'),
                            trailing: controller.isRestoring.value ? const _CustomLoader() : null,
                            onTap: controller.isRestoring.value ? null : controller.signInGoogle,
                          ),
                    _CustomActionTile(
                      icon: controller.isBackingUp.value ? Icons.sync_rounded : Icons.cloud_upload_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: getText('manual_backup_title', 'Backup to Google Drive'),
                      subtitle: getText('manual_backup_subtitle', 'Manually push encrypted payload now'),
                      enabled: controller.isGoogleSignedIn && !controller.isBackingUp.value && !controller.isRestoring.value,
                      trailing: controller.isBackingUp.value ? const _CustomLoader() : null,
                      onTap: controller.backupToCloud,
                    ),
                    _CustomActionTile(
                      icon: Icons.sim_card_download_outlined,
                      iconColor: const Color(0xFF14B8A6),
                      title: getText('export_backup_title', 'Export Local Backup'),
                      subtitle: getText('export_backup_subtitle', 'Save encrypted file direct to storage'),
                      trailing: GestureDetector(
                        onTap: controller.showExportFileInfo,
                        behavior: HitTestBehavior.translucent,
                        child: const Icon(Icons.info),
                      ),
                      onTap: controller.exportLocalBackup,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      getText('footer_security_notice', 'SecureAuth Vault v1.0.0\nAll data is locally bound and secured via isolated hardware keys.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeoutLabel(int seconds, String Function(String, String) getText) {
    final idx = AppConstants.lockTimeouts.indexOf(seconds);
    if (idx >= 0) return AppConstants.lockTimeoutLabels[idx];
    return '$seconds ${getText('seconds_unit', 'seconds')}';
  }

  void _showTimeoutPicker(BuildContext context, String Function(String, String) getText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    Get.bottomSheet(
      backgroundColor: surfaceColor,
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(
              getText('autolock_picker_title', 'Auto-Lock Timeout'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppConstants.lockTimeouts.length,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, i) {
                  final timeout = AppConstants.lockTimeouts[i];
                  final label = AppConstants.lockTimeoutLabels[i];
                  final isSelected = controller.autoLockTimeout.value == timeout;

                  return Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      title: Text(
                        label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                          fontSize: 15,
                        ),
                      ),
                      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 22) : null,
                      onTap: () {
                        controller.setAutoLockTimeout(timeout);
                        Navigator.pop(context);
                      },
                      dense: true,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void showChangeIconsSheet(String Function(String, String) getText) async {
    await controller.refreshActiveIconState();

    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    Get.bottomSheet(
      backgroundColor: surfaceColor,
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(
              getText('choose_icon_title', 'Choose App Icon'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.availableIcons.length + 1,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return ListTile(
                        title: Text(
                          getText('default_icon_label', 'Default'),
                          style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        ),
                        onTap: () => controller.changeAppIcon('default'),
                        trailing: controller.selectedIcon.value == 'default'
                            ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 22)
                            : null,
                        dense: true,
                      );
                    }
                    final iconName = controller.availableIcons[i - 1];
                    return ListTile(
                      title: Text(
                        iconName.capitalizeFirst ?? iconName,
                        style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                      ),
                      onTap: () => controller.changeAppIcon(iconName),
                      trailing: controller.selectedIcon.value == iconName
                          ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 22)
                          : null,
                      dense: true,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Shared Styling Core Blocks ───────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

class _GroupedCard extends StatelessWidget {
  final List<Widget> children;
  const _GroupedCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _CustomSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 24, height: 24, child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.decelerate,
              width: 44,
              height: 24,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: value ? Theme.of(context).colorScheme.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.decelerate,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomActionTile extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const _CustomActionTile({
    this.icon,
    this.svgPath,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final activeIconColor = iconColor ?? Theme.of(context).colorScheme.primary;

    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: icon != null
                    ? Icon(icon, color: activeIconColor, size: 22)
                    : (svgPath != null ? SvgPicture.asset(svgPath!, width: 22, height: 22) : const SizedBox.shrink()),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: mainColor),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ?? (onTap != null ? const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF64748B)) : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomLoader extends StatelessWidget {
  const _CustomLoader();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64748B))),
    );
  }
}

class _StatsTile extends StatelessWidget {
  final int credentials;
  final int documents;
  final String credentialsLabel;
  final String documentsLabel;

  const _StatsTile({required this.credentials, required this.documents, required this.credentialsLabel, required this.documentsLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(label: credentialsLabel, value: credentials, color: Theme.of(context).colorScheme.primary, icon: Icons.shield_outlined),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(label: documentsLabel, value: documents, color: const Color(0xFF10B981), icon: Icons.file_present_rounded),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderCol, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
