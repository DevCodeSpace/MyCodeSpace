import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_board/Routes/app_pages.dart';
import 'package:sky_board/Routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkyBoard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      initialRoute: Routes.dashboardScreen,
      // initialRoute: Routes.deleteAccountPageWebPage,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
