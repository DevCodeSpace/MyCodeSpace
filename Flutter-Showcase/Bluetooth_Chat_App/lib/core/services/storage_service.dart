import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Profile Keys
  static const String keyUserName = 'user_name';
  static const String keyUserBio = 'user_bio';
  static const String keyUserImagePath = 'user_image_path';
  static const String keyIsProfileComplete = 'is_profile_complete';
  static const String keyChatHistory = 'chat_history'; // JSON list of chats
  static const String keyChatMessages =
      'chat_messages'; // JSON map keyed by device id
  static const String keyRemoteProfiles =
      'remote_profiles'; // JSON map keyed by device address

  // Setters
  Future<void> setUserName(String name) async =>
      await _prefs.setString(keyUserName, name);
  Future<void> setUserBio(String bio) async =>
      await _prefs.setString(keyUserBio, bio);
  Future<void> setUserImagePath(String path) async =>
      await _prefs.setString(keyUserImagePath, path);
  Future<void> setProfileComplete(bool status) async =>
      await _prefs.setBool(keyIsProfileComplete, status);
  Future<void> setChatHistory(String json) async =>
      await _prefs.setString(keyChatHistory, json);
  Future<void> setChatMessages(String json) async =>
      await _prefs.setString(keyChatMessages, json);
  Future<void> setRemoteProfiles(String json) async =>
      await _prefs.setString(keyRemoteProfiles, json);

  // Getters
  String getUserName() => _prefs.getString(keyUserName) ?? '';
  String getUserBio() => _prefs.getString(keyUserBio) ?? '';
  String getUserImagePath() => _prefs.getString(keyUserImagePath) ?? '';
  bool isProfileComplete() => _prefs.getBool(keyIsProfileComplete) ?? false;
  String getChatHistory() => _prefs.getString(keyChatHistory) ?? '[]';
  String getChatMessages() => _prefs.getString(keyChatMessages) ?? '{}';
  String getRemoteProfiles() => _prefs.getString(keyRemoteProfiles) ?? '{}';

  Future<void> clear() async => await _prefs.clear();
}
