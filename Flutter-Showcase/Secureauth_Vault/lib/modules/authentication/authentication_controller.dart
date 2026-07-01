import 'dart:async';
import 'dart:convert';

import 'package:authenticator/models/account_model.dart';
import 'package:get/get.dart';
import 'package:otp/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationController extends GetxController {
  // Add any necessary state variables and methods for authentication management here
  final accounts = <AccountModel>[].obs;
  final searchQuery = ''.obs;
  final secondsRemaining = 30.obs;

  Timer? _timer;

  static const String storageKey = "accounts";

  @override
  void onInit() {
    super.onInit();
    _loadAccounts();
    _startTimer();
  }

  // ================= SEARCH =================

  List<AccountModel> get filteredAccounts {
    if (searchQuery.value.isEmpty) {
      return accounts;
    }

    return accounts.where((acc) {
      return acc.account.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // ================= TIMER =================

  void _startTimer() {
    _updateSeconds();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateSeconds();
    });
  }

  void _updateSeconds() {
    final currentSecond = DateTime.now().second;
    secondsRemaining.value = 30 - (currentSecond % 30);
  }

  // ================= STORAGE =================

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> jsonList = accounts.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList(storageKey, jsonList);
  }

  Future<void> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String>? jsonList = prefs.getStringList(storageKey);

    if (jsonList != null) {
      accounts.value = jsonList.map((e) => AccountModel.fromJson(jsonDecode(e))).toList();
    }
  }

  // ================= LOGIC =================
  bool addAccount(AccountModel account) {
    final normalizedSecret = account.secret.trim().toUpperCase();
    final normalizedAccount = account.account.trim().toLowerCase();

    final exists = accounts.any((e) {
      final existingSecret = e.secret.trim().toUpperCase();
      final existingAccount = e.account.trim().toLowerCase();

      return existingSecret == normalizedSecret && existingAccount == normalizedAccount;
    });

    if (exists) {
      return false;
    }

    accounts.add(account);
    _saveAccounts();
    return true;
  }

  void removeAccount(AccountModel account) {
    accounts.remove(account);
    _saveAccounts(); // 🔥 update storage
  }

  // ================= OTP =================

  String getOtp(String secret) {
    secondsRemaining.value;

    return OTP.generateTOTPCodeString(
      secret,
      DateTime.now().millisecondsSinceEpoch,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );
  }

  String formatOtp(String otp) {
    if (otp.length == 6) {
      return "${otp.substring(0, 3)} ${otp.substring(3)}";
    }
    return otp;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
