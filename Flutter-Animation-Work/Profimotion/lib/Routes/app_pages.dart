import 'package:get/get.dart';
import 'package:profimotion/Routes/app_routes.dart';
import 'package:profimotion/Routes/binding.dart';
import 'package:profimotion/View/profile_screen.dart';

class AppPages {
  static const initial = Routes.profileScreen;

  static final routes = [
    GetPage(
      name: initial,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];
}
