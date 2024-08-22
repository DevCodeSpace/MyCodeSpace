import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'Configuration/app_configuration.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Helper/routes.dart';
import 'Helper/settings.dart';
import 'Services/rest_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerController();
  await Settings.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, child) {
        return GetMaterialApp(
          title: "GetX Boiler Plate",
          theme: ThemeData(
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: primaryColor,
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              color: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: primaryColor,
              ),
              titleTextStyle: TextStyle(
                color: primaryColor,
                fontSize: 16.sp,
              ),
              centerTitle: true,
            ),
            scaffoldBackgroundColor: pageBackroundColor,
            primaryColor: primaryColor,
            splashColor: primaryColor.withOpacity(0.5),
            highlightColor: primaryColor.withOpacity(0.5),
            focusColor: primaryColor,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: primaryColor,
              selectionHandleColor: primaryColor,
              selectionColor: primaryColor.withOpacity(0.1),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: primaryColor,
                ),
              ),
              labelStyle: TextStyle(
                color: primaryColor,
              ),
            ),
          ),
          debugShowCheckedModeBanner: kDebugMode,
          initialRoute: Settings.isUserLoggedIn ? Routes.home : Routes.login,
          getPages: Routes.getPages,
        ).onTap(() {
          Get.focusScope?.unfocus();
        });
      },
    );
  }
}

void registerController() {
  Get.put(RestService(), permanent: true);
  // Get.lazyPut(() => ProjectViewController(), fenix: true);
}
