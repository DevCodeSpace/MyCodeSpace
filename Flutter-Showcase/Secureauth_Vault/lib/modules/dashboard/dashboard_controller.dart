import 'dart:async';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/database_service.dart';
import '../authentication/authentication_view.dart';
import '../credentials/credentials_view.dart';
import '../documents/documents_view.dart';
import '../settings/settings_view.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  // final currentIndex = 0.obs;
  final stats = <String, int>{}.obs;
  final currentIndex = 0.obs;
  final List<Widget> pages = const [CredentialsView(), DocumentsView(), AuthenticationView(), SettingsView()];
  Timer? _inactivityTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadStats();
    _resetInactivityTimer();
  }

  @override
  void onClose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = Get.find<AuthService>();
    if (state == AppLifecycleState.paused) {
      auth.onAppPaused();
      _inactivityTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      auth.onAppResumed();
      if (auth.isLocked.value) {
        Get.offAllNamed(AppRoutes.auth);
      } else {
        _resetInactivityTimer();
      }
    }
  }

  void onUserInteraction() => _resetInactivityTimer();

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    final timeout = Get.find<AuthService>().autoLockTimeout;
    if (timeout <= 0) return;
    _inactivityTimer = Timer(Duration(seconds: timeout), _lockDueToInactivity);
  }

  void _lockDueToInactivity() {
    Get.find<AuthService>().lock();
    Get.offAllNamed(AppRoutes.auth);
  }

  Future<void> loadStats() async {
    final db = Get.find<DatabaseService>();
    stats.value = await db.getStats();
  }

  void changeTab(int index) => currentIndex.value = index;
}
