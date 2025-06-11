import 'Export/export.dart';

void main() async {
  // Ensures Flutter binding is initialized before making any plugin or async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Registers global controllers/services using GetX dependency injection
  registerController();

  // Initializes app settings (e.g., loading from SharedPreferences)
  await Settings.init();

  // Locks device orientation to portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Launches the application
  runApp(const MyApp());
}

// Main widget for the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Sets the design size for responsive layout scaling
      designSize: const Size(360, 690),
      builder: (_, child) {
        return GetMaterialApp(
          title: "Banking App",

          // App-wide theme configuration
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

          // Disables debug banner
          debugShowCheckedModeBanner: false,

          // Initial route when the app starts
          initialRoute: Routes.mainPage,

          // Route definitions for navigation
          getPages: Routes.getPages,
        );
      },
    );
  }
}

// Registers essential services/controllers using GetX for dependency injection
void registerController() {
  Get.put(RestService(), permanent: true);
}
