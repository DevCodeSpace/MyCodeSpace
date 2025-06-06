import 'package:banking_store/View/home/tab_page.dart';
import 'package:banking_store/View/landing/landing_page.dart';
import 'package:banking_store/View/notification_page/notification_page.dart';

import '../Export/export.dart';

class Routes {
  static const String landingPage = '/landingPage';
  static const String notificationPage = '/notificationPage';
  static const String tabPage = '/TabPage';

  static List<GetPage<dynamic>> get getPages {
    return [
      GetPage(
        name: Routes.landingPage,
        page: () => const LandingPage(),

        transition: Transition.cupertino,
      ),
      GetPage(
        name: Routes.notificationPage,
        page: () => const NotificationPage(),

        transition: Transition.cupertino,
      ),
      GetPage(
        name: Routes.tabPage,
        page: () => const TabPage(),
        transition: Transition.cupertino,
      ),
    ];
  }
}
