import 'Export/export.dart';

void main() async {
  // Ensures that plugin services are initialized before using them
  WidgetsFlutterBinding.ensureInitialized();

  // Registers all necessary global controllers using GetX dependency injection
  registerController();

  // Initializes shared preferences or local settings
  await Settings.init();

  // Locks device orientation to portrait mode only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Runs the Flutter application
  runApp(const MyApp());
}

// Main widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Sets the reference screen size for responsive design
      designSize: const Size(360, 690),
      builder: (_, child) {
        return GetMaterialApp(
          title: "Biosphere Store", // Application title

          // App-wide theme configuration
          theme: ThemeData(
            // Sets the primary color via GetX theme override
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: HealthifyColors.lightBlue,
            ),

            // Customizes the appearance of the AppBar
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark, // Sets status bar icon color
              color: Colors.white, // AppBar background
              elevation: 0, // No shadow
              iconTheme: IconThemeData(color: HealthifyColors.lightBlue), // Icon color
              titleTextStyle: TextStyle(
                color: HealthifyColors.lightBlue, // Title text color
                fontSize: 16,
              ),
              centerTitle: true, // Centers title in the AppBar
            ),

            // Default background color of scaffold widgets
            scaffoldBackgroundColor: Colors.white,

            // App-wide primary and focus color
            primaryColor: HealthifyColors.lightBlue,
            focusColor: HealthifyColors.lightBlue,

            // Configures selection and cursor appearance in text fields
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: HealthifyColors.lightBlue,
              selectionHandleColor: HealthifyColors.lightBlue,
            ),

            // Styles for text input fields
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: HealthifyColors.lightBlue),
              ),
              labelStyle: TextStyle(color: HealthifyColors.lightBlue),
            ),
          ),

          // Removes the debug banner in the top right corner
          debugShowCheckedModeBanner: false,

          // Initial route of the app (landing screen)
          initialRoute: Routes.landingPage,

          // Defines the route pages using GetX
          getPages: Routes.getPages,
        );
      },
    );
  }
}

// Registers global services/controllers at app startup using GetX
void registerController() {
  Get.put(RestService(), permanent: true); // Keeps RestService alive throughout app lifecycle
}
