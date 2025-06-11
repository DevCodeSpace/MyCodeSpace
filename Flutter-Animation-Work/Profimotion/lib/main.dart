import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:profimotion/Routes/app_pages.dart';
import 'package:profimotion/Routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Profimotion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      initialRoute: Routes.profileScreen,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
