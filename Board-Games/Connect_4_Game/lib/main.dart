import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/connect_four/providers/settings_provider.dart';
import '/features/connect_four/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: ConnectFourApp()));
}

class ConnectFourApp extends ConsumerWidget {
  const ConnectFourApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(settingsProvider.select((s) => s.darkMode));
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
