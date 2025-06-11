import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signimatic/Routes/app_pages.dart';
import 'package:signimatic/Routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Signimatic',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
      ),
      initialRoute: Routes.loginScreen,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
