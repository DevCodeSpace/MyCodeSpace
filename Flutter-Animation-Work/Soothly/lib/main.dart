import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soothly/Routes/app_pages.dart';
import 'package:soothly/Routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Soothly',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      initialRoute: Routes.slpashScreen,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
