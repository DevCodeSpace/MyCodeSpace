import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mouse_demo/controllers/device_list_controller.dart';
import 'package:mouse_demo/controllers/settings_controller.dart';
import 'package:mouse_demo/helper/preference_helper.dart';
import 'package:mouse_demo/routes/app_routes.dart';
import 'package:mouse_demo/screens/device_list_screen.dart';
import 'package:mouse_demo/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(DeviceListController());
  Get.put(SettingsController());
  PreferenceHelper.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: Routes.routes,
      // --- LIGHT THEME ---
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          titleTextStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight(700), fontSize: 20, color: Colors.black87),
          iconTheme: const IconThemeData(color: AppColors.textDark),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        colorScheme: const ColorScheme.light(primary: AppColors.primary, surface: AppColors.surfaceLight),
      ),

      // --- DARK THEME ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          titleTextStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight(700), fontSize: 20, color: AppColors.textLight),
          iconTheme: const IconThemeData(color: AppColors.textLight),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surfaceDark),
      ),
      themeMode: PreferenceHelper.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: DeviceListScreen(),
    );
  }
}
