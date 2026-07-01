import 'package:get/get.dart';

import '../../views/casting/casting_binding.dart';
import '../../views/casting/casting_view.dart';
import '../../views/devices/device_binding.dart';
import '../../views/devices/device_list_view.dart';
import '../../views/home/home_binding.dart';
// Android sender screens + bindings
import '../../views/home/home_view.dart';
import '../../views/public_stream/public_stream_binding.dart';
import '../../views/public_stream/public_stream_view.dart';
import '../../views/receiver/receiver_binding.dart';
// Mac / PC receiver screen + binding
import '../../views/receiver/receiver_view.dart';
import '../../views/splash/splash_binding.dart';
// Splash and Public Stream screens
import '../../views/splash/splash_view.dart';
// Smart TV casting screen + binding
import '../../views/tv_cast/tv_cast_binding.dart';
import '../../views/tv_cast/tv_cast_view.dart';
import 'app_routes.dart';

// AppPages maps each named route to its View widget and Binding class.
// GetX uses this list to instantiate the correct controller whenever a
// route is navigated to, and to dispose it when the screen is popped.
class AppPages {
  AppPages._(); // Prevent instantiation — this class is used statically only

  static final pages = [
    // Splash Screen — Initial route that determines platform and redirects
    GetPage(name: AppRoutes.splash, page: () => SplashView(), binding: SplashBinding()),

    // Home — landing screen where the user picks WiFi or Bluetooth casting
    GetPage(name: AppRoutes.home, page: () => const HomeView(), binding: HomeBinding()),

    // Device list — shows discovered receivers; receives CastConnectionType as arg
    GetPage(name: AppRoutes.devices, page: () => const DeviceListView(), binding: DeviceBinding()),

    // Casting — active session screen; receives a CastDevice as arg
    GetPage(name: AppRoutes.casting, page: () => const CastingView(), binding: CastingBinding()),

    // Receiver — full-screen display on Mac/PC; no route arguments needed
    GetPage(name: AppRoutes.receiver, page: () => const ReceiverView(), binding: ReceiverBinding()),

    // Public Stream (Browser Casting) — starts local MJPEG HTTP server
    GetPage(name: AppRoutes.publicStream, page: () => const PublicStreamView(), binding: PublicStreamBinding()),

    // TV Cast — SSDP discovery + LG SSAP / DLNA / Samsung REST casting
    GetPage(name: AppRoutes.tvCast, page: () => const TvCastView(), binding: TvCastBinding()),
  ];
}
