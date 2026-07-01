import 'package:authenticator/modules/authentication/scan_view.dart';
import 'package:authenticator/modules/sdui/sdui_view.dart';
import 'package:get/get.dart';

import '../../modules/auth/auth_binding.dart';
import '../../modules/auth/auth_view.dart';
import '../../modules/authentication/authentication_binding.dart';
import '../../modules/authentication/authentication_view.dart';
import '../../modules/authentication/scan_binding.dart';
import '../../modules/credentials/add_edit_credential_view.dart';
import '../../modules/credentials/credential_detail_view.dart';
import '../../modules/credentials/credentials_binding.dart';
import '../../modules/dashboard/dashboard_binding.dart';
import '../../modules/dashboard/dashboard_view.dart';
import '../../modules/documents/folder_view.dart';
import '../../modules/settings/settings_binding.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/setup/setup_binding.dart';
import '../../modules/setup/setup_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: AppRoutes.auth, page: () => const AuthView(), binding: AuthBinding(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.setup, page: () => const SetupView(), binding: SetupBinding(), transition: Transition.fadeIn),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardView(), binding: DashboardBinding(), transition: Transition.fadeIn),
    GetPage(
      name: AppRoutes.credentialDetail,
      page: () => const CredentialDetailView(),
      binding: CredentialsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addEditCredential,
      page: () => const AddEditCredentialView(),
      binding: CredentialsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsView(), binding: SettingsBinding(), transition: Transition.rightToLeft),
    GetPage(
      name: AppRoutes.authentication,
      page: () => const AuthenticationView(),
      binding: AuthenticationBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(name: AppRoutes.scanner, page: () => const ScannerScreen(), binding: ScanBinding()),
    GetPage(name: AppRoutes.folder, page: () => const FolderView()),
    GetPage(name: AppRoutes.sdui, page: () => const SduiView()),
  ];
}
