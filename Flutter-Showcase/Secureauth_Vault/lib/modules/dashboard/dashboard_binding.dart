import 'package:get/get.dart';

import '../authentication/authentication_controller.dart';
import '../credentials/credentials_controller.dart';
import '../documents/documents_controller.dart';
import '../settings/settings_controller.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<CredentialsController>(() => CredentialsController());
    Get.lazyPut<DocumentsController>(() => DocumentsController());
    Get.lazyPut<AuthenticationController>(() => AuthenticationController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
