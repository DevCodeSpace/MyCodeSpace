import 'package:biosphere_app/Controller/home_controller.dart';
import 'package:biosphere_app/View/details_page.dart';
import 'package:biosphere_app/View/home_page.dart';
import 'package:biosphere_app/View/landing_page.dart';

import '../Export/export.dart';

class Routes {
  static const String landingPage = '/landingPage';
  static const String homePage = '/homePage';
  static const String detailsPage = '/detailsPage';

  static List<GetPage<dynamic>> get getPages {
    return [
      GetPage(
        name: Routes.landingPage,
        page: () => const LandingPage(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: Routes.homePage,
        page: () => const HomePage(),
        binding: BindingsBuilder.put(() => HomeController()),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: Routes.detailsPage,
        page: () => const DetailsPage(),
        transition: Transition.cupertino,
      ),
    ];
  }
}
