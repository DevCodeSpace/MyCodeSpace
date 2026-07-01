import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait — simplifies camera overlay coordinate math.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const TextFinderApp());
}

class TextFinderApp extends StatelessWidget {
  const TextFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'TextLens Pro', debugShowCheckedModeBanner: false, theme: AppTheme.lightTheme, home: const SplashScreen());
  }
}
