import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/encryption_service.dart';

class SetupController extends GetxController {
  final pin = ''.obs;
  final confirmPin = ''.obs;
  final step = 0.obs; // 0 = create PIN, 1 = confirm PIN
  final isLoading = false.obs;
  final error = ''.obs;

  void addDigit(String digit) {
    error.value = '';
    if (step.value == 0) {
      if (pin.value.length < 6) pin.value += digit;
      if (pin.value.length == 6) {
        Future.delayed(const Duration(milliseconds: 200), () => step.value = 1);
      }
    } else {
      if (confirmPin.value.length < 6) confirmPin.value += digit;
      if (confirmPin.value.length == 6) _finishSetup();
    }
  }

  void deleteDigit() {
    error.value = '';
    if (step.value == 0) {
      if (pin.value.isNotEmpty) pin.value = pin.value.substring(0, pin.value.length - 1);
    } else {
      if (confirmPin.value.isNotEmpty) {
        confirmPin.value = confirmPin.value.substring(0, confirmPin.value.length - 1);
      }
    }
  }

  void goBack() {
    if (step.value == 1) {
      step.value = 0;
      confirmPin.value = '';
      error.value = '';
    }
  }

  Future<void> _finishSetup() async {
    if (pin.value != confirmPin.value) {
      error.value = 'PINs do not match. Try again.';
      confirmPin.value = '';
      return;
    }

    isLoading.value = true;
    try {
      await Get.find<EncryptionService>().storePinHash(pin.value);
      Get.offAllNamed(AppRoutes.auth);
    } catch (e) {
      error.value = 'Setup failed. Please try again.';
      confirmPin.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}
