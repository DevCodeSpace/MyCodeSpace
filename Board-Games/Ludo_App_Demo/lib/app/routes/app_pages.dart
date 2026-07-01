import 'package:get/get.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/game/views/game_view.dart';
import '../modules/result/views/result_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: '/',
      page: () => const SplashView(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/game',
      page: () => const GameView(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: '/result',
      page: () => const ResultView(),
      transition: Transition.upToDown,
    ),
  ];
}
