import 'package:bloc_boiler_plate/screens/home_screen.dart';
import 'package:bloc_boiler_plate/screens/login_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  // static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, Widget Function(BuildContext)> get routes {
    return {
      // Routes.splash : (context) => const SplashScreen(),
      Routes.login: (context) => const LoginScreen(),
      Routes.home: (context) => const HomeScreen(),
    };
  }
}
