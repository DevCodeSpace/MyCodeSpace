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
          title: "Book Store",
          theme: ThemeData(
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: BookStoreColors.lightBlue,
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: BookStoreColors.lightBlue),
              titleTextStyle: TextStyle(
                color: BookStoreColors.lightBlue,
                fontSize: 16,
              ),
              centerTitle: true,
            ),
            scaffoldBackgroundColor: Colors.white,
            primaryColor: BookStoreColors.lightBlue,
            focusColor: BookStoreColors.lightBlue,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: BookStoreColors.lightBlue,
              selectionHandleColor: BookStoreColors.lightBlue,
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: BookStoreColors.lightBlue),
              ),
              labelStyle: TextStyle(color: BookStoreColors.lightBlue),
            ),
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.homePage,
          getPages: Routes.getPages,
        );
      },
    );
  }
}

void registerController() {
  Get.put(RestService(), permanent: true);
  Get.lazyPut(() => HomeController(), fenix: true);
}
