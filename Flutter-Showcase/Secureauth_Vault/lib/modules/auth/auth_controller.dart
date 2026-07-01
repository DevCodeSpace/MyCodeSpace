import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';

class AuthController extends GetxController {
  final _authService = Get.find<AuthService>();

  final pin = ''.obs;
  final error = ''.obs;
  final isLoading = false.obs;
  final biometricFailed = false.obs;
  final biometricPending = false.obs;

  bool get biometricAvailable => _authService.isBiometricAvailable.value;

  @override
  void onReady() {
    super.onReady();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final enabled = await _authService.isBiometricEnabled();
    if (enabled && biometricAvailable) {
      await authenticateWithBiometric();
    }
  }

  Future<void> authenticateWithBiometric() async {
    biometricFailed.value = false;
    biometricPending.value = true;
    isLoading.value = true;
    final success = await _authService.authenticateWithBiometric();
    isLoading.value = false;
    biometricPending.value = false;
    if (success) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      biometricFailed.value = true;
    }
  }

  void addDigit(String digit) {
    error.value = '';
    if (pin.value.length < 6) {
      pin.value += digit;
    }
    if (pin.value.length == 6) {
      _verifyPin();
    }
  }

  void deleteDigit() {
    error.value = '';
    if (pin.value.isNotEmpty) {
      pin.value = pin.value.substring(0, pin.value.length - 1);
    }
  }

  Future<void> _verifyPin() async {
    isLoading.value = true;
    final success = await _authService.authenticateWithPin(pin.value);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      error.value = 'Incorrect PIN. Try again.';
      pin.value = '';
    }
  }
}
