import 'package:banking_app/Controller/main_controller.dart';
import 'package:banking_app/View/main_page.dart';

import '../Export/export.dart';

class Routes {
  static const String mainPage = '/mainPage';

  static List<GetPage<dynamic>> get getPages {
    return [
      GetPage(
        name: Routes.mainPage,
        page: () => const MainPage(),
        binding: BindingsBuilder.put(() => MainController()),
        transition: Transition.cupertino,
      ),
    ];
  }
}
