import 'Export/export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerController();
  await Settings.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (_, child) {
        return GetMaterialApp(
          title: "Banking Store",
          theme: ThemeData(
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: StoreColors.darkTeal,
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: StoreColors.darkTeal),
              titleTextStyle: TextStyle(
                color: StoreColors.darkTeal,
                fontSize: 16,
              ),
              centerTitle: true,
            ),
            scaffoldBackgroundColor: Colors.white,
            primaryColor: StoreColors.darkTeal,
            focusColor: StoreColors.darkTeal,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: StoreColors.darkTeal,
              selectionHandleColor: StoreColors.darkTeal,
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: StoreColors.darkTeal),
              ),
              labelStyle: TextStyle(color: StoreColors.darkTeal),
            ),
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.landingPage,
          getPages: Routes.getPages,
        );
      },
    );
  }
}

void registerController() {
  Get.put(RestService(), permanent: true);
}
