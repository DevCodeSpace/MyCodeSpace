import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences?> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance;
  }

  static String get ipAddress =>
      _prefsInstance?.getString("ipAddress") ?? "";
  static set ipAddress(String value) =>
      _prefsInstance?.setString("ipAddress", value);


  static String get previousScanned =>
      _prefsInstance?.getString("previouysScanned") ?? "";
  static set previousScanned(String value) =>
      _prefsInstance?.setString("previouysScanned", value);

  static String get googleScriptUrl =>
      _prefsInstance?.getString("googleScriptUrl") ?? "";
  static set googleScriptUrl(String value) =>
      _prefsInstance?.setString("googleScriptUrl", value);

  static void clear() {
    _prefsInstance?.clear();
  }
}
