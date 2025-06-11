import 'package:get/get.dart';
import 'package:sky_board/Routes/app_routes.dart';
import 'package:sky_board/Routes/binding.dart';
import 'package:sky_board/View/dashboard_screen.dart';

class AppPages {
  static const initial = Routes.dashboardScreen;

  static final routes = [
    GetPage(
      name: initial,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
  ];
}
