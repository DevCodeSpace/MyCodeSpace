// Importing necessary packages for the main page functionality
import 'package:banking_app/Controller/main_controller.dart';
import 'package:banking_app/Core/widgets/navigation_bar_widget.dart'; // Custom widget for navigation bar buttons
import 'package:banking_app/Export/export.dart'; // Consolidated imports for the app
import 'package:dart_extensions_pro/dart_extensions_pro.dart'; // Extension methods for Dart
import 'package:flutter/cupertino.dart'; // Cupertino widgets for iOS-style UI components

// MainPage widget, a stateless view using GetX for state management
class MainPage extends GetView<MainController> {
  // Constructor with optional key for widget identification
  const MainPage({super.key});

  @override
  // Builds the UI for the main page
  Widget build(BuildContext context) {
    // Obx widget to rebuild UI when reactive state changes
    return Obx(
      () => Scaffold(
        // Main content area of the page
        body: SizedBox(
          // Set width to full screen width
          width: MediaQuery.of(context).size.width,
          // Set height to full screen height
          height: MediaQuery.of(context).size.height,
          // Stack to layer the content and navigation bar
          child: Stack(
            children: [
              // Positioned.fill ensures the content fills the available space
              Positioned.fill(
                // IndexedStack to switch between pages based on selected index
                child: IndexedStack(
                  // Current index from the controller to determine visible page
                  index: controller.navigationSelectedIndex.value,
                  children: [
                    // Home page widget
                    HomePage(),
                    // Analysis page widget
                    AnalysisPage(),
                    // Cards page widget
                    CardsPage(),
                    // Placeholder container for the profile page
                    Container(color: Colors.white),
                  ],
                ),
              ),
              // Bottom navigation bar
              Positioned(
                bottom: 0, // Position at the bottom of the stack
                child: Container(
                  // Fixed height for the navigation bar
                  height: 100,
                  // White background for the navigation bar
                  color: Colors.white,
                  // Full screen width for the navigation bar
                  width: MediaQuery.of(context).size.width,
                  // Row to arrange navigation buttons horizontally
                  child: Row(
                    // Evenly space buttons in the row
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Home button
                      NavigationBarButton(
                        iconData: CupertinoIcons.home, // Home icon
                        isSelected:
                            controller.navigationSelectedIndex.value ==
                            0, // Highlight if selected
                        onTap: () {
                          // Update selected index to show Home page
                          controller.navigationSelectedIndex.value = 0;
                        },
                      ),
                      // Analysis button
                      NavigationBarButton(
                        iconData: CupertinoIcons.chart_bar, // Chart icon
                        isSelected:
                            controller.navigationSelectedIndex.value ==
                            1, // Highlight if selected
                        onTap: () {
                          // Update selected index to show Analysis page
                          controller.navigationSelectedIndex.value = 1;
                        },
                      ),
                      // Cards button
                      NavigationBarButton(
                        iconData: CupertinoIcons.creditcard, // Credit card icon
                        isSelected:
                            controller.navigationSelectedIndex.value ==
                            2, // Highlight if selected
                        onTap: () {
                          // Update selected index to show Cards page
                          controller.navigationSelectedIndex.value = 2;
                        },
                      ),
                      // Profile button
                      NavigationBarButton(
                        iconData: CupertinoIcons.person, // Person icon
                        isSelected:
                            controller.navigationSelectedIndex.value ==
                            3, // Highlight if selected
                        onTap: () {
                          // Update selected index to show Profile page
                          controller.navigationSelectedIndex.value = 3;
                        },
                      ),
                    ],
                  ).pOnly(b: 15), // Add bottom padding of 15 to the row
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
