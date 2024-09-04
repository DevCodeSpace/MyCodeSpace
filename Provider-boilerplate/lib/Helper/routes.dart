import 'package:flutter/material.dart';
import 'package:provider_boiler_plate/screens/home_screen.dart';
import 'package:provider_boiler_plate/screens/login_screen.dart';

class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String feature = '/feature';

  static Map<String, Widget Function(BuildContext)> get routes {
    return {
      Routes.home: (context) => HomeScreen(),
      Routes.login: (context) => LoginScreen(),
    };
  }
}
