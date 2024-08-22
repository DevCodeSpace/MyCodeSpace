import 'package:getx_boiler_plate/Configuration/app_configuration.dart';
import 'package:getx_boiler_plate/Controller/login_controller.dart';
import 'package:velocity_x/velocity_x.dart';

import '../Export/export.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            onChanged: (value) => controller.email.value = value,
            decoration: textfieldDecoration("Email"),
          ),
          10.heightBox,
          TextField(
            onChanged: (value) => controller.password.value = value,
            decoration: textfieldDecoration("Passowrd"),
            obscureText: true,
          ),
          60.heightBox,
          Obx(
            () => controller.isLoading.value
                ? const LoadingDialog()
                : button(
                    "Login",
                    controller.login,
                  ),
          ),
        ],
      ).p(16),
    );
  }
}
