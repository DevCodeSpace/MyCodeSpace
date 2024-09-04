import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'helper/service_locator.dart';
import 'helper/routes.dart';
import 'providers/auth_provider.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetIt.instance<AuthProvider>(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Provider with GetIt Boiler plate',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute:
                authProvider.isAuthenticated ? Routes.home : Routes.login,
            routes: Routes.routes,
          );
        },
      ),
    );
  }
}
