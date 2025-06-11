import 'package:get/get.dart';
import 'package:signimatic/Routes/app_routes.dart';
import 'package:signimatic/Routes/binding.dart';
import 'package:signimatic/View/login_screen.dart';

class AppPages {
  static const initial = Routes.loginScreen;

  static final routes = [
    GetPage(
      name: initial,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
  ];
}
