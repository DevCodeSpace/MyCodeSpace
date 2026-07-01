import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/database_service.dart';
import '../../core/services/encryption_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<EncryptionService>(EncryptionService(), permanent: true);
    Get.put<DatabaseService>(DatabaseService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<BackupService>(BackupService(), permanent: true);
  }
}
