import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:restaurant_order/firebase_options.dart';
import 'package:restaurant_order/routes/app_pages.dart';
import 'package:restaurant_order/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  // Disable dynamic fetching if it causes issues, or handle errors
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  GoogleFonts.config.allowRuntimeFetching = true;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception.toString().contains('libdartjni.so')) {
      debugPrint('Caught JNI error: ${details.exception}');
      return; // Ignore JNI errors to prevent crash
    }
    FlutterError.presentError(details);
  };

  runApp(const MyApp());
}

String _resolveInitialRoute() {
  final uri = Uri.base;
  final path = uri.path;

  if (path.isEmpty || path == '/') {
    return AppRoutes.splash;
  }

  var normalizedPath = path.startsWith('/') ? path : '/$path';
  if (normalizedPath.length > 1 && normalizedPath.endsWith('/')) {
    normalizedPath = normalizedPath.substring(0, normalizedPath.length - 1);
  }
  if (uri.query.isEmpty) return normalizedPath;
  return '$normalizedPath?${uri.query}';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: const Color(0xFFFFB800)),
      initialRoute: !GetPlatform.isWeb ? AppRoutes.splash : _resolveInitialRoute(),
      getPages: AppPages.routes,
      unknownRoute: AppPages.unknownRoute,
      title: 'DineAssist AI',
    );
  }
}
