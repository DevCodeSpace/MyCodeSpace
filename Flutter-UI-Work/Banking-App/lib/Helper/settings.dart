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
      _prefsInstance!.getBool("IsUserLoggedIn") ?? false;
  static set isUserLoggedIn(bool value) {
    _prefsInstance!.setBool("IsUserLoggedIn", value);
  }

  static String get accessToken =>
      _prefsInstance?.getString("accessToken") ?? "";
  static set accessToken(String value) =>
      _prefsInstance?.setString("accessToken", value);

  static String get email => _prefsInstance?.getString("email") ?? "";
  static set email(String value) => _prefsInstance?.setString("email", value);

  static String get firstName => _prefsInstance?.getString("firstName") ?? "";
  static set firstName(String value) =>
      _prefsInstance?.setString("firstName", value);

  static String get userTypeName =>
      _prefsInstance?.getString("userTypeName") ?? "";
  static set userTypeName(String value) =>
      _prefsInstance?.setString("userTypeName", value);

  static String get lastName => _prefsInstance?.getString("lastName") ?? "";
  static set lastName(String value) =>
      _prefsInstance?.setString("lastName", value);

  static String get companyName =>
      _prefsInstance?.getString("companyName") ?? "";
  static set companyName(String value) =>
      _prefsInstance?.setString("companyName", value);

  static int get userId => _prefsInstance?.getInt("userId") ?? 0;
  static set userId(int value) => _prefsInstance?.setInt("userId", value);

  static int get userType => _prefsInstance?.getInt("userType") ?? 0;
  static set userType(int value) => _prefsInstance?.setInt("userType", value);

  static int get subscriptionLevel =>
      _prefsInstance?.getInt("subscriptionLevel") ?? 0;
  static set subscriptionLevel(int value) =>
      _prefsInstance?.setInt("subscriptionLevel", value);

  static void clear() {
    _prefsInstance?.clear();
  }
}
