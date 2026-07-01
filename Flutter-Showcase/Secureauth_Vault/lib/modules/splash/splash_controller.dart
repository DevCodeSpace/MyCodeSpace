import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/database_service.dart';
import '../../core/services/encryption_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([Get.find<EncryptionService>().init(), Future.delayed(const Duration(milliseconds: 1500))]);

    await Get.find<DatabaseService>().init();
    await Get.find<AuthService>().init();
    await Get.find<BackupService>().init();

    final enc = Get.find<EncryptionService>();
    final isPinSet = await enc.isPinSet();

    if (isPinSet) {
      Get.offAllNamed(AppRoutes.auth);
    } else {
      Get.offAllNamed(AppRoutes.setup);
    }
  }
}
