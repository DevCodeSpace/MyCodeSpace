import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/colors.dart';
import 'core/services/usage_service.dart';
import 'core/services/background_service.dart';
import 'core/widgets/overlay_limit_alert.dart';

const _batteryChannel = MethodChannel('com.example.track_app_usage/battery');

Future<void> requestOverlayPermissionIfNeeded() async {
  final granted = await FlutterOverlayWindow.isPermissionGranted();
  if (!granted) {
    await FlutterOverlayWindow.requestPermission();
  }
}

// Asks Android to exclude this app from battery optimization so the background
// service continues running after the app is killed (swiped from recents).
Future<void> requestBatteryOptimizationExemptionIfNeeded() async {
  if (!Platform.isAndroid) return;
  try {
    final isIgnoring = await _batteryChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations') ?? false;
    if (!isIgnoring) {
      await _batteryChannel.invokeMethod('requestIgnoreBatteryOptimizations');
    }
  } catch (_) {}
}

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: OverlayLimitAlert()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermissionIfNeeded();
  await requestOverlayPermissionIfNeeded();
  await requestBatteryOptimizationExemptionIfNeeded();
  await initializeBackgroundService();

  // Set system navigation colors matching dark mode
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GlacierColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize global services
  Get.put(UsageService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'StayOnTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GlacierColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: GlacierColors.primary,
          brightness: Brightness.dark,
          surface: GlacierColors.surface,
          primary: GlacierColors.primary,
          secondary: GlacierColors.secondary,
          tertiary: GlacierColors.tertiary,
          error: GlacierColors.error,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
