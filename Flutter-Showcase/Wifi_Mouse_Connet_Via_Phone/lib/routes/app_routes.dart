import 'package:get/get.dart';
import 'package:mouse_demo/controllers/device_list_controller.dart';
import 'package:mouse_demo/controllers/settings_controller.dart';
import 'package:mouse_demo/controllers/splash_controller.dart';
import 'package:mouse_demo/controllers/trackpad_controller.dart';
import 'package:mouse_demo/screens/device_list_screen.dart';
import 'package:mouse_demo/screens/settings_screen.dart';
import 'package:mouse_demo/screens/splash_screen.dart';
import 'package:mouse_demo/screens/trackpad_screen.dart';

class AppRoutes {
  static String splash = "/splash";
  static String deviceList = "/device-list";
  static String trackpad = "/trackpad";
  static String settings = "/settings";
}

class Routes {
  static List<GetPage> routes = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen(), binding: BindingsBuilder.put(() => SplashController())),
    GetPage(name: AppRoutes.deviceList, page: () => DeviceListScreen(), binding: BindingsBuilder.put(() => DeviceListController())),
    GetPage(name: AppRoutes.trackpad, page: () => TrackpadScreen(), binding: BindingsBuilder.put(() => TrackpadController())),
    GetPage(name: AppRoutes.settings, page: () => SettingsScreen(), binding: BindingsBuilder.put(() => SettingsController())),
  ];
}
