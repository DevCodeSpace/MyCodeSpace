import 'Export/export.dart';

void main() async {
  // Ensure Flutter widgets and services are initialized before app execution
  WidgetsFlutterBinding.ensureInitialized();

  // Register all necessary controllers and services
  registerController();

  // Initialize settings (e.g., shared preferences or app-level configuration)
  await Settings.init();

  // Lock app orientation to portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Launch the app
  runApp(const MyApp());
}

// Root widget for the Book Store application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Sets the base design size for responsive scaling
      designSize: const Size(360, 690),
      builder: (_, child) {
        return GetMaterialApp(
          title: "Book Store", // Title shown in task manager or switcher
          // Defines the global app theme
          theme: ThemeData(
            colorScheme: Get.theme.colorScheme.copyWith(
              primary: BookStoreColors.lightBlue, // Primary theme color
            ),
            appBarTheme: AppBarTheme(
              systemOverlayStyle:
                  SystemUiOverlayStyle.dark, // Status bar icon color
              color: Colors.white, // AppBar background color
              elevation: 0, // Removes AppBar shadow
              iconTheme: IconThemeData(
                color: BookStoreColors.lightBlue,
              ), // Icon colors
              titleTextStyle: TextStyle(
                color: BookStoreColors.lightBlue,
                fontSize: 16,
              ),
              centerTitle: true, // Center-aligns AppBar title
            ),
            scaffoldBackgroundColor: Colors.white, // Page background color
            primaryColor:
                BookStoreColors.lightBlue, // Used throughout the theme
            focusColor: BookStoreColors.lightBlue, // Focused widget color
            // Cursor and text selection handle color
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: BookStoreColors.lightBlue,
              selectionHandleColor: BookStoreColors.lightBlue,
            ),

            // Input fields style
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: BookStoreColors.lightBlue),
              ),
              labelStyle: TextStyle(color: BookStoreColors.lightBlue),
            ),
          ),

          // Hides the debug banner in non-debug mode
          debugShowCheckedModeBanner: false,

          // Starting route when the app loads
          initialRoute: Routes.homePage,

          // Route configuration using GetX's routing system
          getPages: Routes.getPages,
        );
      },
    );
  }
}

// Registers controllers and services used across the app
void registerController() {
  // Persistent service for networking
  Get.put(RestService(), permanent: true);

  // Lazily load HomeController when first accessed, and keep it alive via fenix
  Get.lazyPut(() => HomeController(), fenix: true);
}
