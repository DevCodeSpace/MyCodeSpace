import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'utils/app_colors.dart';
import 'utils/app_globals.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make the Android status bar transparent so the app's dark background shows through
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));

  runApp(const ScreenCastingApp());
}

class ScreenCastingApp extends StatelessWidget {
  const ScreenCastingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary with appCaptureKey wraps the ENTIRE widget tree.
    // CastStreamService uses this key to locate the RenderRepaintBoundary and
    // capture the current screen as a PNG image every 150 ms.
    return RepaintBoundary(
      key: appCaptureKey,
      child: GetMaterialApp(
        title: 'ScreenCast Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.dark(primary: AppColors.primary, surface: AppColors.background),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),

        // The initial route is now the Splash screen.
        // SplashController will handle the delay and platform-specific routing.
        initialRoute: AppRoutes.splash,
        getPages: AppPages.pages,
      ),
    );
  }
}
