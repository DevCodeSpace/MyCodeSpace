import 'package:authenticator/Controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Routes/app_pages.dart';
import 'Routes/app_route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController(), permanent: true);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.dashboard,
        getPages: AppPages.pages,
        themeMode: theme.isDark.value ? ThemeMode.dark : ThemeMode.light,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      colorScheme: const ColorScheme.light(primary: Color(0xFF00A884)),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0E1A),
      colorScheme: const ColorScheme.dark(primary: Color(0xFF00D4AA)),
    );
  }
}
