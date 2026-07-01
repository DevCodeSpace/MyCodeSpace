import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/database_service.dart';
import '../../core/utils/app_constants.dart';
import '../credentials/credentials_controller.dart';
import '../documents/documents_controller.dart';

class SettingsController extends GetxController {
  final isDarkMode = true.obs;
  final biometricEnabled = true.obs;
  final autoLockTimeout = 60.obs;
  final stats = <String, int>{}.obs;
  final isBackingUp = false.obs;
  final isRestoring = false.obs;
  final availableIcons = <String>['purple'].obs; // The suffix matching your MainActivityPurple
  final selectedIcon = 'default'.obs;
  static const _channel = MethodChannel('com.secureAuthVault/icon_changer');
  final RxMap<String, String> dynamicJson = <String, String>{}.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService get _auth => Get.find<AuthService>();
  BackupService get _backup => Get.find<BackupService>();
  DatabaseService get _db => Get.find<DatabaseService>();

  @override
  Future<void> onInit() async {
    super.onInit();
    _loadSettings();
    _loadLanguageJson();
    loadStats();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchAndSyncFirebaseIconTimes();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(AppConstants.kThemeMode) ?? true;
    biometricEnabled.value = prefs.getBool(AppConstants.kBiometricEnabled) ?? true;
    autoLockTimeout.value = prefs.getInt(AppConstants.kAutoLockTimeout) ?? 60;
    selectedIcon.value = prefs.getString(AppConstants.kSelectedAppIcon) ?? 'default';
  }

  void _loadLanguageJson() {
    // Mimicking a parsed JSON block fetched locally or via API assets
    var jsonPayload = {
      "settings_title": "Settings",
      "storage_summary_header": "Storage Summary",
      "credentials_label": "Credentials",
      "documents_label": "Documents",
      "preferences_header": "Preferences",
      "dark_mode_title": "Dark Mode",
      "dark_mode_subtitle": "Optimize UI for low-light environments",
      "app_icon_title": "App Icon",
      "app_icon_subtitle": "Change app icon on home screen",
      "security_header": "Security & Access",
      "biometric_title": "Biometric Unlock",
      "biometric_subtitle": "Use biometric verification on open",
      "autolock_title": "Auto-Lock",
      "backup_header": "Backup & Cloud Sync",
      "google_drive_connected_title": "Google Drive",
      "google_drive_connected_subtitle": "Automatic encrypted sync active",
      "disconnect_btn": "Disconnect",
      "connect_drive_title": "Connect Google Drive",
      "connecting_drive_title": "Connecting Drive...",
      "restoring_backup_subtitle": "Restoring secure backup payload...",
      "enable_backup_subtitle": "Enable secure encrypted cloud backups",
      "manual_backup_title": "Backup to Google Drive",
      "manual_backup_subtitle": "Manually push encrypted payload now",
      "export_backup_title": "Export Local Backup",
      "export_backup_subtitle": "Save encrypted file direct to storage",
      "footer_security_notice":
          "SecureAuth Vault v1.0.0\nAll data is locally bound and secured via isolated hardware keys using client-side AES-256-GCM configurations.",
      "seconds_unit": "seconds",
      "autolock_picker_title": "Auto-Lock Timeout",
      "choose_icon_title": "Choose App Icon",
      "default_icon_label": "Default",
    };

    dynamicJson.assignAll(jsonPayload);
  }

  Future<void> fetchFirestoreConfig() async {
    try {
      // isLoadingConfig.value = true;

      // Target path: screens -> setting
      DocumentSnapshot doc = await _firestore.collection('screens').doc('setting').get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        // Extract the raw string from the 'texts' field
        final String? rawJsonString = data['texts'];

        if (rawJsonString != null) {
          // Parse the JSON string into a Dart Map
          final Map<String, String> decodedMap = jsonDecode(rawJsonString);
          dynamicJson.assignAll(decodedMap);
        }
      }
    } catch (e) {
      Get.log("Error fetching setting configurations from Firestore: $e", isError: true);
    } finally {
      // isLoadingConfig.value = false;
    }
  }

  // Safe accessor string helper
  String? getText(String key) {
    return dynamicJson[key];
  }

  // Future<void> checkDynamicIconSupport() async {
  //   supportDynamicIcons.value = await DynamicAppIconFlutterPlus.supportsAlternateIcons;
  //   selectedIcon.value = await DynamicAppIconFlutterPlus.getAlternateIconName() ?? 'default';
  //   if (supportDynamicIcons.value) {
  //     final icons = await DynamicAppIconFlutterPlus.getAvailableIcons();
  //     availableIcons.assignAll(icons);
  //     for (var icon in icons) {
  //       debugPrint('Available Icon: $icon');
  //     }
  //   }
  //   debugPrint('Dynamic Icon Support: ${supportDynamicIcons.value}, Available Icons: ${availableIcons.join(', ')}');
  // }

  Future<void> loadStats() async {
    stats.value = await _db.getStats();
  }

  Future<void> toggleDarkMode(bool val) async {
    isDarkMode.value = val;
    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kThemeMode, val);
  }

  Future<void> toggleBiometric(bool val) async {
    biometricEnabled.value = val;
    await _auth.setBiometricEnabled(val);
  }

  Future<void> setAutoLockTimeout(int seconds) async {
    autoLockTimeout.value = seconds;
    await _auth.setAutoLockTimeout(seconds);
  }

  Future<void> backupToCloud() async {
    isBackingUp.value = true;
    await _backup.backup();
    isBackingUp.value = false;
  }

  Future<void> exportLocalBackup() async {
    await _backup.exportLocalBackup();
  }

  bool get isGoogleSignedIn => _backup.isSignedIn.value;
  String? get googleAccountEmail => null;

  Future<void> signInGoogle() async {
    if (isRestoring.value) return;

    isRestoring.value = true;
    try {
      final signedIn = await _backup.signIn();
      if (!signedIn) return;

      final restored = await _backup.restoreLatestBackup();
      if (restored) {
        await _refreshAfterRestore();
      }
    } finally {
      isRestoring.value = false;
      update();
    }
  }

  Future<void> signOutGoogle() async {
    await _backup.signOut();
    update();
  }

  void lockNow() {
    _auth.lock();
  }

  Future<void> _refreshAfterRestore() async {
    await loadStats();

    if (Get.isRegistered<CredentialsController>()) {
      await Get.find<CredentialsController>().loadData();
    }
    if (Get.isRegistered<DocumentsController>()) {
      await Get.find<DocumentsController>().loadInitialData();
    }
  }

  void showExportFileInfo() {
    final isDark = Theme.of(Get.context!).brightness == Brightness.dark;

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            // border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modernized Drag Handle
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 28),

              // Elevated Glowing Icon Wrapper
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400.withValues(alpha: 0.16), Colors.blue.shade700.withValues(alpha: 0.24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.enhanced_encryption_rounded, size: 36, color: Colors.blue),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Encrypted Export File',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 14),

              // Body Text with better line spacing
              Text(
                'Your exported backup file is securely encrypted for privacy and protection.\n\n'
                'This file cannot be opened or viewed directly using file managers or third-party apps.\n\n'
                'You can only restore and access this data from inside the app using your correct backup password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 32),

              // Premium Styled Button
              SizedBox(
                width: double.infinity,
                height: 52, // Standard premium button height
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    elevation: isDark ? 0 : 2,
                    shadowColor: Colors.blue.withValues(alpha: 0.3),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> changeAppIcon(String? iconName) async {
    try {
      Get.back();
      await Future.delayed(const Duration(milliseconds: 250));
      await _channel.invokeMethod('changeAppIcon', {'iconName': iconName});

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.kSelectedAppIcon, iconName ?? 'default');
      selectedIcon.value = iconName ?? 'default';

      Get.snackbar(
        'App Icon Changed',
        'The app icon has been updated to "${iconName!.capitalizeFirst ?? 'Default'}".',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint("Error changing icon: $e");
      Get.snackbar('Error', 'Failed to change app icon.', backgroundColor: Colors.red.shade600, colorText: Colors.white);
    }
  }

  void showChangeIconsSheet() async {
    await refreshActiveIconState();

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
              'Choose App Icon',
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
                  itemCount: availableIcons.length + 1,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return ListTile(
                        title: Text(
                          'Default',
                          style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                        ),
                        onTap: () => changeAppIcon('default'),
                        trailing: selectedIcon.value == 'default'
                            ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 22)
                            : null,
                        dense: true,
                      );
                    }
                    final iconName = availableIcons[i - 1];
                    return ListTile(
                      title: Text(
                        iconName.capitalizeFirst ?? iconName,
                        style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                      ),
                      onTap: () => changeAppIcon(iconName),
                      trailing: selectedIcon.value == iconName
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

  void showTimeoutPicker() {
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
              decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(
              'Auto-Lock Timeout',
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
                  itemCount: AppConstants.lockTimeouts.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, i) {
                    final timeout = AppConstants.lockTimeouts[i];
                    final label = AppConstants.lockTimeoutLabels[i];
                    final isSelected = autoLockTimeout.value == timeout;

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
                          setAutoLockTimeout(timeout);
                          Get.back();
                        },
                        dense: true,
                      ),
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

  /// Fetches what alias component is actually enabled on the Android device right now
  Future<void> refreshActiveIconState() async {
    try {
      final String activeIcon = await _channel.invokeMethod('getActiveIcon');
      selectedIcon.value = activeIcon;
      debugPrint('🎨 Checked home screen layout state: Active Icon is "$activeIcon"');
    } catch (e) {
      debugPrint('❌ Failed to pull native icon state: $e');
    }
  }

  Future<void> fetchAndSyncFirebaseIconTimes() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(seconds: 10), minimumFetchInterval: Duration.zero));

      await remoteConfig.fetchAndActivate();

      String jsonConfigString = remoteConfig.getString('dynamic_app_icons');
      if (jsonConfigString.isEmpty) return;

      Map<String, dynamic> config = jsonDecode(jsonConfigString);

      String morningTime = config['morning_time'] ?? '10:00';
      String nightTime = config['night_time'] ?? '18:00';

      debugPrint('☁️ Syncing target timeline down to native alarms: Morning: $morningTime, Night: $nightTime');

      // 🔑 SEND TO NATIVE: Hand the parameters over to the hardware AlarmManager engine
      await _channel.invokeMethod('syncFirebaseTimeWindows', {'morning_time': morningTime, 'night_time': nightTime});
    } catch (e) {
      debugPrint("❌ Failure handling platform sync actions: $e");
    }
  }
}
