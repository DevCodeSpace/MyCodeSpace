import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

class PreferenceHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _darkModeKey = "dark_mode";
  static const String _deviceHistoryKey = "device_history";
  static const String _autoConnectEnabledKey = "auto_connect_enabled";
  static const String _controlVolumeEnabledKey = "control_volume_enabled";
  static const String _moveKey = "move";
  static const String _moveSensitivityKey = "move_sensitivity";
  static const String _dragKey = "drag";
  static const String _dragSensitivityKey = "drag_sensitivity";
  static const String _verticalScrollKey = "vertical_scroll";
  static const String _horizontalScrollKey = "horizontal_scroll";
  static const String _scrollSensitivityKey = "scroll_sensitivity";
  static const String _gyroEnabledKey = "gyro_enabled";
  static const String _gyroSensitivityKey = "gyro_sensitivity";

  static Future<List<Device>> getDeviceHistory() async {
    final List<String>? data = _prefs?.getStringList(_deviceHistoryKey);
    if (data == null) return [];
    return data.map((e) => Device.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> addDevice(Device device) async {
    final List<String> data = _prefs?.getStringList(_deviceHistoryKey) ?? [];
    final devices = data.map((e) => Device.fromJson(jsonDecode(e))).toList();
    devices.removeWhere((d) => d.ip == device.ip);
    devices.insert(0, device);
    if (devices.length > 10) {
      devices.removeLast();
    }
    final encoded = devices.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs?.setStringList(_deviceHistoryKey, encoded);
  }

  static set isDarkMode(bool val) => _prefs?.setBool(_darkModeKey, val);
  static bool get isDarkMode => _prefs?.getBool(_darkModeKey) ?? true;

  static set isAutoConnectEnabled(bool val) => _prefs?.setBool(_autoConnectEnabledKey, val);
  static bool get isAutoConnectEnabled => _prefs?.getBool(_autoConnectEnabledKey) ?? true;

  static set isControlVolumeEnabled(bool val) => _prefs?.setBool(_controlVolumeEnabledKey, val);
  static bool get isControlVolumeEnabled => _prefs?.getBool(_controlVolumeEnabledKey) ?? false;

  static set isMoveEnabled(bool val) => _prefs?.setBool(_moveKey, val);
  static bool get isMoveEnabled => _prefs?.getBool(_moveKey) ?? true;

  static set moveSensitivity(double val) => _prefs?.setDouble(_moveSensitivityKey, val);
  static double get moveSensitivity => _prefs?.getDouble(_moveSensitivityKey) ?? 4.0;

  static set isDragEnabled(bool val) => _prefs?.setBool(_dragKey, val);
  static bool get isDragEnabled => _prefs?.getBool(_dragKey) ?? true;

  static set dragSensitivity(double val) => _prefs?.setDouble(_dragSensitivityKey, val);
  static double get dragSensitivity => _prefs?.getDouble(_dragSensitivityKey) ?? 2.0;

  static set isVerticalScrollEnabled(bool val) => _prefs?.setBool(_verticalScrollKey, val);
  static bool get isVerticalScrollEnabled => _prefs?.getBool(_verticalScrollKey) ?? true;

  static set isHorizontalScrollEnabled(bool val) => _prefs?.setBool(_horizontalScrollKey, val);
  static bool get isHorizontalScrollEnabled => _prefs?.getBool(_horizontalScrollKey) ?? true;

  static set scrollSensitivity(double val) => _prefs?.setDouble(_scrollSensitivityKey, val);
  static double get scrollSensitivity => _prefs?.getDouble(_scrollSensitivityKey) ?? 2.0;

  static set isGyroEnabled(bool val) => _prefs?.setBool(_gyroEnabledKey, val);
  static bool get isGyroEnabled => _prefs?.getBool(_gyroEnabledKey) ?? false;

  static set gyroSensitivity(double val) => _prefs?.setDouble(_gyroSensitivityKey, val);
  static double get gyroSensitivity => _prefs?.getDouble(_gyroSensitivityKey) ?? 1.0;
}
