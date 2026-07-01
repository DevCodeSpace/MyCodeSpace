// lib/app/routes/app_pages.dart

import 'package:get/get.dart';
import '../modules/attendance/attendance_binding.dart';
import '../modules/attendance/employee_view.dart';
import '../modules/attendance/history_view.dart';
import '../modules/attendance/home_view.dart';
import '../modules/attendance/face_scan_view.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView(), transition: Transition.fade, transitionDuration: const Duration(milliseconds: 600)),
    GetPage(name: AppRoutes.home, page: () => const HomeView(), binding: AttendanceBinding(), transition: Transition.cupertino),
    GetPage(
      name: AppRoutes.liveness,
      page: () => const FaceScanView(),
      binding: AttendanceBinding(), // reuse existing controller (fenix: true)
      transition: Transition.cupertino,
    ),
    GetPage(name: AppRoutes.history, page: () => HistoryView(), binding: AttendanceBinding(), transition: Transition.cupertino),
    GetPage(name: AppRoutes.employee, page: () => EmployeeView(), binding: AttendanceBinding(), transition: Transition.cupertino),
  ];
}
