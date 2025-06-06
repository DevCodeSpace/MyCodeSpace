import 'package:animations_app/View/splash_screen.dart';

import '../Export/export.dart';

class Routes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String ftpPage = '/ftpPage';

  static List<GetPage<dynamic>> get getPages {
    return [
      GetPage(
        name: Routes.splash,
        page: () => const SplashScreen(),
        transition: Transition.cupertino,
      ),
    ];
  }
}
