import 'package:get/get.dart';
import 'package:getx_boiler_plate/Export/export.dart';
import 'package:getx_boiler_plate/Helper/routes.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;

  void login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    isLoading(true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate a network call
    isLoading(false);

    // Dummy login logic
    if (email.value == 'test@test.com' && password.value == 'password') {
      Get.snackbar('Success', 'Logged in successfully');
      // Navigate to the home screen or do whatever you need on successful login
      Get.toNamed(Routes.home);
    } else {
      Get.snackbar('Error', 'Invalid credentials');
    }
  }
}
