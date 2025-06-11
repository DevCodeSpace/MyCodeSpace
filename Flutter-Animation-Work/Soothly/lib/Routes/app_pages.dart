import 'package:get/get.dart';
import 'package:soothly/Routes/app_routes.dart';
import 'package:soothly/Routes/binding.dart';
import 'package:soothly/View/dashboard_screen.dart';
import 'package:soothly/View/onbording_screen.dart';
import 'package:soothly/View/splash_screen.dart';

class AppPages {
  static const initial = Routes.slpashScreen;

  static final routes = [
    GetPage(
      name: initial,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboardingScreen,
      page: () => OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 800),
    ),
    GetPage(
      name: Routes.dashboardScreen,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 500),
    ),
  ];
}
