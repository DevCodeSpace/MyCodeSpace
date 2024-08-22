
import 'package:getx_boiler_plate/Controller/login_controller.dart';
import 'package:getx_boiler_plate/View/home_page.dart';

import '../Export/export.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';

  static List<GetPage<dynamic>> get getPages {
    return [
      GetPage(
        name: Routes.login,
        page: () => const LoginPage(),
        binding: BindingsBuilder.put(
          () => LoginController(),
        ),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: Routes.home,
        page: () => const HomePage(),
        binding: BindingsBuilder.put(
          () => HomeController(),
        ),
        transition: Transition.cupertino,
      ),
    ];
  }
}
