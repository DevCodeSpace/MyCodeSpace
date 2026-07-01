import 'package:get/get.dart';

import '../../presentation/screens/device_discovery_screen.dart';
import '../../presentation/screens/history_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/receive_screen.dart';
import '../../presentation/screens/send_screen.dart';
import '../../presentation/screens/transfer_screen.dart';

import '../../presentation/screens/splash_screen.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const home = '/';
  static const send = '/send';
  static const receive = '/receive';
  static const discovery = '/discovery';
  static const transfer = '/transfer';
  static const history = '/history';
}

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.send,
      page: () => const SendScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.receive,
      page: () => const ReceiveScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.discovery,
      page: () => const DeviceDiscoveryScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.transfer,
      page: () => const TransferScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}
