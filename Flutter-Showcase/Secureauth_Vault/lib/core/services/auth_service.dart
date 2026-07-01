import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';
import 'encryption_service.dart';

class AuthService extends GetxService {
  final _localAuth = LocalAuthentication();
  final _encryption = Get.find<EncryptionService>();

  final isLocked = true.obs;
  final isBiometricAvailable = false.obs;

  DateTime? _lastActiveTime;
  int _autoLockTimeout = 60;

  int get autoLockTimeout => _autoLockTimeout;

  Future<AuthService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _autoLockTimeout = prefs.getInt(AppConstants.kAutoLockTimeout) ?? 60;

    try {
      isBiometricAvailable.value = await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
    } catch (_) {
      isBiometricAvailable.value = false;
    }

    return this;
  }

  Future<bool> authenticateWithBiometric() async {
    if (!isBiometricAvailable.value) return false;
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your SecureAuth Vault',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (result) {
        isLocked.value = false;
        _updateActivity();
      }
      return result;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticateWithPin(String pin) async {
    final result = await _encryption.verifyPin(pin);
    if (result) {
      await _encryption.setBackupKeyFromPin(pin);
      isLocked.value = false;
      _updateActivity();
    }
    return result;
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.kBiometricEnabled) ?? true;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.kBiometricEnabled, enabled);
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  void lock() {
    isLocked.value = true;
    _lastActiveTime = null;
  }

  void _updateActivity() {
    _lastActiveTime = DateTime.now();
  }

  void onAppResumed() {
    if (!isLocked.value && _autoLockTimeout > 0 && _lastActiveTime != null) {
      final elapsed = DateTime.now().difference(_lastActiveTime!).inSeconds;
      if (elapsed >= _autoLockTimeout) {
        lock();
      }
    }
  }

  void onAppPaused() {
    _updateActivity();
  }

  Future<void> setAutoLockTimeout(int seconds) async {
    _autoLockTimeout = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.kAutoLockTimeout, seconds);
  }

  Future<int> getAutoLockTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.kAutoLockTimeout) ?? 60;
  }
}
