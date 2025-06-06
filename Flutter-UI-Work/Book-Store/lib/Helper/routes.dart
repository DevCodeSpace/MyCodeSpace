import '../Export/export.dart';

class Routes {
  static const String landingPage = '/landingPage';
  static const String homePage = '/homePage';
  static const String detailsPage = '/detailsPage';

  static List<GetPage<dynamic>> get getPages {
    return [
      GetPage(
        name: Routes.homePage,
        page: () => const HomePage(),
        binding: BindingsBuilder.put(() => HomeController()),
        transition: Transition.cupertino,
      ),
    ];
  }
}
