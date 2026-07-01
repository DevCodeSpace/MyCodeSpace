import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stac/stac.dart';
import '../settings/settings_controller.dart';

class _Actions {
  static const toggleDarkMode = 'toggleDarkMode';
  static const toggleBiometric = 'toggleBiometric';
  static const showAppIconSheet = 'showAppIconSheet';
  static const showTimeoutPicker = 'showTimeoutPicker';
  static const signInGoogle = 'signInGoogle';
  static const signOutGoogle = 'signOutGoogle';
  static const backupToCloud = 'backupToCloud';
  static const exportLocalBackup = 'exportLocalBackup';
  static const showExportInfo = 'showExportInfo';
}

class AppActionHandler extends StacActionParser<Map<String, dynamic>> {
  const AppActionHandler();

  @override
  String get actionType => 'appAction';

  @override
  Map<String, dynamic> getModel(Map<String, dynamic> json) => json;

  @override
  Future<void> onCall(BuildContext context, Map<String, dynamic> actionMap) async {
    final String? method = actionMap['method'];
    
    // Efficiently locate your GetX controller for settings actions
    final controller = Get.find<SettingsController>();

    switch (method) {
      case _Actions.toggleDarkMode:
        controller.toggleDarkMode(!controller.isDarkMode.value);
        break;

      case _Actions.toggleBiometric:
        controller.toggleBiometric(!controller.biometricEnabled.value);
        break;

      case _Actions.showAppIconSheet:
        // Assuming your bottom sheet UI logic now lives inside your controller or helper
        controller.showChangeIconsSheet();
        break;

      case _Actions.showTimeoutPicker:
        controller.showTimeoutPicker();
        break;

      case _Actions.signInGoogle:
        controller.signInGoogle();
        break;

      case _Actions.signOutGoogle:
        controller.signOutGoogle();
        break;

      case _Actions.backupToCloud:
        controller.backupToCloud();
        break;

      case _Actions.exportLocalBackup:
        controller.exportLocalBackup();
        break;

      case _Actions.showExportInfo:
        controller.showExportFileInfo();
        break;

      default:
        debugPrint("⚠️ [AppActionHandler] Unknown method invoked via SDUI: $method");
    }
  }
}