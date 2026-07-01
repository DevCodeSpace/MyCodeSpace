import 'package:authenticator/Controller/auth_controller.dart';
import 'package:get/get.dart';

import '../Model/account_model.dart';

class ScannerController extends GetxController {
  final isScanning = false.obs;
  final AuthController authController = Get.find<AuthController>();

  bool handleScan(String raw) {
    if (isScanning.value) return false;

    if (!raw.startsWith("otpauth://")) {
      return false;
    }

    isScanning.value = true;

    try {
      final uri = Uri.parse(raw);
      final secret = uri.queryParameters['secret'];
      final issuer = uri.queryParameters['issuer'] ?? "Unknown";
      final label = uri.pathSegments.isNotEmpty ? Uri.decodeComponent(uri.pathSegments.last) : "Account";
      final accountName = _extractAccountName(label, issuer);

      if (secret == null || secret.isEmpty) {
        isScanning.value = false;
        return false;
      }

      authController.addAccount(AccountModel(account: accountName, secret: secret));

      Get.back(result: true);
      return true;
    } catch (_) {
      isScanning.value = false;
      return false;
    }
  }

  String _extractAccountName(String label, String issuer) {
    final trimmedLabel = label.trim();

    if (trimmedLabel.startsWith('$issuer:')) {
      return trimmedLabel.substring(issuer.length + 1).trim();
    }

    return trimmedLabel.isEmpty ? 'Account' : trimmedLabel;
  }

  void resetScanState() {
    isScanning.value = false;
  }
}
