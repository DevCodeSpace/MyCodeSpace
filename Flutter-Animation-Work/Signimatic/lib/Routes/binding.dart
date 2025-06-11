
import 'package:get/get.dart';
import 'package:signimatic/Controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}
