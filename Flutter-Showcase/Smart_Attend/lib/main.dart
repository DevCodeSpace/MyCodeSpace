// lib/main.dart

import 'package:smart_attend/routes/app_pages.dart';
import 'package:smart_attend/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Attend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)), useMaterial3: true),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    );
  }
}
