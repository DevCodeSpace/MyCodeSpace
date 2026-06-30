import 'package:shared_preferences/shared_preferences.dart';

/// Thin static wrapper around SharedPreferences.
/// Every key is persisted across app launches. Call [init] once in main()
/// before any getter or setter is accessed.
class Settings {
  Settings._();

  static SharedPreferences? _prefs;

  /// Must be awaited in main() before the app boots so all getters are safe.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Bearer token used in the Authorization header for all API calls.
  static String get accessToken => _prefs?.getString("accessToken") ?? "";
  static set accessToken(String value) => _prefs?.setString("accessToken", value);

  /// Unix millisecond timestamp of the last completed chatbot session,
  /// recorded when a session is finalized.
  static int get lastChatBotTime => _prefs?.getInt("lastChatBotTime") ?? 0;
  static set lastChatBotTime(int value) => _prefs?.setInt("lastChatBotTime", value);

  /// Clears ALL persisted data — used on sign-out.
  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
