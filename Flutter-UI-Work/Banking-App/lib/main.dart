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
          title: "Banking App",
          theme: ThemeData(
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: BankingColors.lightGreen,
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              color: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: BankingColors.lightGreen),
              titleTextStyle: TextStyle(
                color: BankingColors.lightGreen,
                fontSize: 16,
              ),
              centerTitle: true,
            ),
            scaffoldBackgroundColor: Colors.white,
            primaryColor: BankingColors.lightGreen,
            focusColor: BankingColors.lightGreen,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: BankingColors.lightGreen,
              selectionHandleColor: BankingColors.lightGreen,
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: BankingColors.lightGreen),
              ),
              labelStyle: TextStyle(color: BankingColors.lightGreen),
            ),
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.mainPage,
          getPages: Routes.getPages,
        );
      },
    );
  }
}

void registerController() {
  Get.put(RestService(), permanent: true);
}
