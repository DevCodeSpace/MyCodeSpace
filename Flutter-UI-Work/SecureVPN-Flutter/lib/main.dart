import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Controller/vpn_controller.dart';
import 'View/vpn_dashboard_screen.dart';

/// Entry point of the SecureVPN application
void main() {
  // Initialize VPN controller for global state management
  Get.put(VpnController());
  runApp(const MyApp());
}

/// Root widget of the application
/// Sets up the Material app with dark theme and GetX state management
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Secure VPN",

      // App theme configuration with dark color scheme
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFF0A0A0B,
        ), // Deep black background
        fontFamily: 'SF Pro Display', // Apple's system font
      ),
      home: const HomeScreen(),
    );
  }
}
