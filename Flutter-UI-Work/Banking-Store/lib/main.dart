import 'Export/export.dart';

void main() async {
  // Ensures all bindings are initialized before the app starts (required for async setup or plugin usage)
  WidgetsFlutterBinding.ensureInitialized();

  // Registers global controllers/services with GetX
  registerController();

  // Initialize app settings (like reading from local storage or setting preferences)
  await Settings.init();

  // Locks the device orientation to portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Starts the Flutter app
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Used for responsive design. 360x690 is the reference design size
      designSize: const Size(360, 690),
      builder: (_, child) {
        return GetMaterialApp(
          title: "Banking Store",

          // Global theme configuration for the app
          theme: ThemeData(
            // Custom primary color using GetX's theme override and app-specific colors
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: StoreColors.darkTeal,
            ),

            // AppBar style customization
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.dark, // Status bar icons color
              color: Colors.white, // AppBar background color
              elevation: 0,
              iconTheme: IconThemeData(color: StoreColors.darkTeal), // AppBar icons color
              titleTextStyle: TextStyle(
                color: StoreColors.darkTeal, // Title text color
                fontSize: 16,
              ),
              centerTitle: true,
            ),

            // Default background color for Scaffold widgets
            scaffoldBackgroundColor: Colors.white,

            // Primary and focus colors used across the UI
            primaryColor: StoreColors.darkTeal,
            focusColor: StoreColors.darkTeal,

            // Theme for text selection and cursor
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: StoreColors.darkTeal,
              selectionHandleColor: StoreColors.darkTeal,
            ),

            // Input field focus/label styling
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: StoreColors.darkTeal),
              ),
              labelStyle: TextStyle(color: StoreColors.darkTeal),
            ),
          ),

          // Hide the debug banner in non-debug builds
          debugShowCheckedModeBanner: false,

          // Starting route of the application
          initialRoute: Routes.landingPage,

          // Navigation routes using GetX
          getPages: Routes.getPages,
        );
      },
    );
  }
}

// Register global dependencies using GetX dependency injection
void registerController() {
  Get.put(RestService(), permanent: true);
}
