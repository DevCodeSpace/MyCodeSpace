import 'package:get/get.dart';
import '../../features/splash/splash_view.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/dashboard/dashboard_view.dart';
import '../../features/apps/installed_apps_view.dart';
import '../../features/apps/app_details_view.dart';
import '../../features/apps/set_limit_view.dart';
import '../../features/apps/active_limits_view.dart';
import '../../features/apps/limit_reached_alert_view.dart';
import '../../features/analytics/analytics_deep_dive_view.dart';
import '../../features/settings/settings_view.dart';
import '../../core/widgets/navigation_scaffold.dart';
import 'app_routes.dart';

class AppPages {
  static const String initial = AppRoutes.splash;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const NavigationScaffold(
        pages: [
          DashboardView(),
          InstalledAppsView(),
          AnalyticsDeepDiveView(),
          SettingsView(),
        ],
      ),
    ),
    GetPage(
      name: AppRoutes.appDetails,
      page: () => const AppDetailsView(),
    ),
    GetPage(
      name: AppRoutes.setLimit,
      page: () => const SetLimitView(),
    ),
    GetPage(
      name: AppRoutes.activeLimits,
      page: () => const ActiveLimitsView(),
    ),
    GetPage(
      name: AppRoutes.limitReached,
      page: () => const LimitReachedAlertView(),
      transition: Transition.fadeIn,
    ),
  ];
}
