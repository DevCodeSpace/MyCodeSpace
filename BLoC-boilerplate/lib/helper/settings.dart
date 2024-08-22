

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

  static bool get isUserLoggedIn =>
      _prefsInstance?.getBool("IsUserLoggedIn") ?? false;
  static set isUserLoggedIn(bool value) =>
      _prefsInstance?.setBool("IsUserLoggedIn", value);

  static String get userSetting =>
      _prefsInstance?.getString("userSetting") ?? "";
  static set userSetting(String value) =>
      _prefsInstance?.setString("userSetting", value);

  static String get contactList =>
      _prefsInstance?.getString("contactList") ?? "";
  static set contactList(String value) =>
      _prefsInstance?.setString("contactList", value);

  static String get conversationList =>
      _prefsInstance?.getString("conversationList") ?? "";
  static set conversationList(String value) =>
      _prefsInstance?.setString("conversationList", value);

  static String get accessToken =>
      _prefsInstance?.getString("accessToken") ?? "";
  static set accessToken(String value) =>
      _prefsInstance?.setString("accessToken", value);

  static String get refreshToken =>
      _prefsInstance?.getString("refreshToken") ?? "";
  static set refreshToken(String value) =>
      _prefsInstance?.setString("refreshToken", value);

  static bool get isEdit => _prefsInstance?.getBool("isEdit") ?? false;
  static set isEdit(bool value) => _prefsInstance?.setBool("isEdit", value);
  
  static void clear() {
    _prefsInstance?.clear();
  }
}
