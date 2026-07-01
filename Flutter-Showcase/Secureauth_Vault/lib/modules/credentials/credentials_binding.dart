import 'package:authenticator/modules/credentials/add_edit_credential_controller.dart';
import 'package:get/get.dart';
import 'credentials_controller.dart';

class CredentialsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CredentialsController>(() => CredentialsController());
    Get.lazyPut<AddEditCredentialController>(() => AddEditCredentialController());
  }
}
