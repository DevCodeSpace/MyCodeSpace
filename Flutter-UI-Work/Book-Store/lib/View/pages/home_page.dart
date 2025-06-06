// Importing necessary packages for exports, extensions, and Cupertino widgets
import 'package:book_store/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/cupertino.dart';

// Defines the HomePage as a GetView widget, binding to HomeController
class HomePage extends GetView<HomeController> {
  // Constructor with optional key parameter
  const HomePage({super.key});

  @override
  // Builds the UI for the HomePage
  Widget build(BuildContext context) {
    // Uses Obx for reactive UI updates based on controller changes
    return Obx(
      () => Scaffold(
        // Sets the background color to light sand
        backgroundColor: BookStoreColors.lightSand,
        // Stack to layer the tab content and bottom navigation bar
        body: Stack(
          children: [
            // Positioned widget to fill the screen with tab content
            Positioned.fill(
              child: TabBarView(
                controller:
                    controller.tabController, // Associates the TabController
                physics:
                    const NeverScrollableScrollPhysics(), // Disables swipe navigation
                children: [
                  // Landing page view with callback to open specific tabs
                  LandingPageView(
                    openTab: (p0) {
                      controller.openTab(
                        p0,
                      ); // Calls controller method to switch tabs
                    },
                  ),
                  // Books page view with callback to open play with book
                  BooksPageView(openPlayWithBook: controller.openPlayWithBook),
                  // Placeholder container for an empty tab
                  Container(),
                  // Play page view displaying the selected book
                  PlayPageView(book: controller.book),
                  // Settings page view with callback to open specific tabs
                  SettingsPageView(
                    openTab: (p0) {
                      controller.openTab(
                        p0,
                      ); // Calls controller method to switch tabs
                    },
                  ),
                ],
              ),
            ),
            // Positioned bottom navigation bar
            Positioned(
              bottom: 0,
              width: MediaQuery.of(context).size.width,
              height: 70,
              // Container for the bottom navigation bar
              child: Container(
                color: BookStoreColors.veryLightSand, // Sets background color
                // Row to arrange tab icons evenly
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // GestureDetector for Home tab
                    GestureDetector(
                      onTap: () {
                        controller.tabIndex.value = 0; // Updates tab index
                        controller.tabController.animateTo(
                          controller.tabIndex.value, // Animates to Home tab
                        );
                      },
                      // Home icon with conditional coloring
                      child: Icon(
                        CupertinoIcons.home,
                        color:
                            controller.tabIndex.value == 0
                                ? BookStoreColors
                                    .golden // Selected color
                                : BookStoreColors.darkBrown.withValues(
                                  alpha: 0.5,
                                ), // Unselected color
                        size: 25,
                      ),
                    ),
                    // GestureDetector for Books tab
                    GestureDetector(
                      onTap: () {
                        controller.tabIndex.value = 1; // Updates tab index
                        controller.tabController.animateTo(
                          controller.tabIndex.value, // Animates to Books tab
                        );
                      },
                      // Book icon with conditional coloring
                      child: Icon(
                        CupertinoIcons.book,
                        color:
                            controller.tabIndex.value == 1
                                ? BookStoreColors
                                    .golden // Selected color
                                : BookStoreColors.darkBrown.withValues(
                                  alpha: 0.5,
                                ), // Unselected color
                        size: 25,
                      ),
                    ),
                    // GestureDetector for Favorites tab
                    GestureDetector(
                      onTap: () {
                        controller.tabIndex.value = 2; // Updates tab index
                        controller.tabController.animateTo(
                          controller
                              .tabIndex
                              .value, // Animates to Favorites tab
                        );
                      },
                      // Heart icon with conditional coloring
                      child: Icon(
                        CupertinoIcons.heart,
                        color:
                            controller.tabIndex.value == 2
                                ? BookStoreColors
                                    .golden // Selected color
                                : BookStoreColors.darkBrown.withValues(
                                  alpha: 0.5,
                                ), // Unselected color
                        size: 25,
                      ),
                    ),
                    // GestureDetector for Play tab
                    GestureDetector(
                      onTap: () {
                        controller.tabIndex.value = 3; // Updates tab index
                        controller.tabController.animateTo(
                          controller.tabIndex.value, // Animates to Play tab
                        );
                      },
                      // Play icon with conditional coloring
                      child: Icon(
                        size: 25,
                        CupertinoIcons.play_arrow_solid,
                        color:
                            controller.tabIndex.value == 3
                                ? BookStoreColors
                                    .golden // Selected color
                                : BookStoreColors.darkBrown.withValues(
                                  alpha: 0.5,
                                ), // Unselected color
                      ),
                    ),
                    // GestureDetector for Settings tab
                    GestureDetector(
                      onTap: () {
                        controller.tabIndex.value = 4; // Updates tab index
                        controller.tabController.animateTo(
                          controller.tabIndex.value, // Animates to Settings tab
                        );
                      },
                      // Settings icon with conditional coloring
                      child: Icon(
                        CupertinoIcons.settings_solid,
                        color:
                            controller.tabIndex.value == 4
                                ? BookStoreColors
                                    .golden // Selected color
                                : BookStoreColors.darkBrown.withValues(
                                  alpha: 0.5,
                                ), // Unselected color
                        size: 25,
                      ),
                    ),
                  ],
                ).pOnly(b: 10), // Applies bottom padding of 10 units
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Defines the Header as a stateless widget
class Header extends StatelessWidget {
  // Constructor with optional key parameter
  const Header({super.key});

  @override
  // Builds the UI for the Header widget
  Widget build(BuildContext context) {
    // Returns a Column for vertical arrangement
    return Column(
      children: [
        // Adds vertical spacing of 60 units
        60.hBox,
        // SizedBox for header row
        SizedBox(
          height: 50,
          // Row to arrange profile and cart icons
          child: Row(
            children: [
              // Expanded widget for profile section
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Clipped container for profile image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        height: 50,
                        width: 50,
                        color: Colors.white, // White background
                        // Displays profile image from assets
                        child: Image.asset(
                          'images/profile.png',
                          width: 35,
                          height: 35,
                          fit: BoxFit.contain,
                        ).p(5), // Applies padding of 5 units
                      ),
                    ),
                    // Adds horizontal spacing of 10 units
                    10.wBox,
                    // Displays greeting text
                    Text(
                      'Hi, Natalie!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gentiumBookPlus().copyWith(
                        color: BookStoreColors.darkBrown,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow:
                            TextOverflow.ellipsis, // Handles text overflow
                      ),
                    ),
                  ],
                ),
              ),
              // Clipped container for shopping cart icon
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 50,
                  width: 50,
                  color: Colors.white, // White background
                  // Displays shopping cart icon
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    color: BookStoreColors.darkBrown,
                    size: 24,
                  ).p(5), // Applies padding of 5 units
                ),
              ),
            ],
          ).pOnly(r: 18), // Applies right padding of 18 units
        ),
        // Adds vertical spacing of 20 units
        20.hBox,
      ],
    );
  }
}
