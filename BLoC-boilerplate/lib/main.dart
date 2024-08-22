

import 'package:bloc_boiler_plate/const/primary_theme.dart';
import 'package:bloc_boiler_plate/helper/routes.dart';
import 'package:bloc_boiler_plate/helper/settings.dart';
import 'package:bloc_boiler_plate/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

GlobalKey<NavigatorState> appKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Settings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark),
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: MaterialApp(
              navigatorKey: appKey,
              debugShowCheckedModeBanner: false,
              title: "Bloc Boiler Plate",
              routes: Routes.routes,
              theme: ThemeData(
                appBarTheme: const AppBarTheme(
                    foregroundColor: primaryColor,
                    surfaceTintColor: Colors.white,
                    backgroundColor: Colors.white),
                scaffoldBackgroundColor: Colors.white,
                fontFamily: helveticaNeueFont,
                textTheme:
                    const TextTheme(bodySmall: TextStyle(color: blackColor)),
                colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
                useMaterial3: true,
              ),
              home: const LoginScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
