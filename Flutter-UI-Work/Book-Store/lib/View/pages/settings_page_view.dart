// Importing necessary packages for text styles, extensions, and exports
import 'package:book_store/Core/Theme/app_color.dart';
import 'package:book_store/View/pages/home_page.dart';
import 'package:book_store/core/Theme/text_style.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/material.dart';

// Defines the SettingsPageView as a stateless widget
class SettingsPageView extends StatelessWidget {
  // Callback function to open a specific tab
  final Function(int) openTab;
  // Constructor with required openTab callback and optional key parameter
  const SettingsPageView({required this.openTab, super.key});

  @override
  // Builds the UI for the SettingsPageView
  Widget build(BuildContext context) {
    // Returns a SizedBox to constrain the widget to screen dimensions
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      // PageView for swipeable content
      child: PageView(
        children: [
          // ListView for scrollable settings content
          ListView(
            padding: const EdgeInsets.all(0), // Removes default padding
            children: [
              // Header widget for the settings page
              Header(),
              // Adds vertical spacing of 10 units
              10.hBox,
              // Clipped container for promotional banner
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                // SizedBox for the promotional banner
                child: SizedBox(
                  height: 180,
                  // Stack to layer background image and text content
                  child: Stack(
                    children: [
                      // Positioned image for the background gradient
                      Positioned.fill(
                        child: Image.asset(
                          'images/gradient.png',
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      // Positioned column for promotional text and button
                      Positioned.fill(
                        child: Column(
                          children: [
                            // Adds vertical spacing of 15 units
                            15.hBox,
                            // Displays promotional title
                            Text(
                              'Christmas Sale',
                              style: boldTextStyle(color: Colors.white, 30),
                            ),
                            // Adds vertical spacing of 5 units
                            5.hBox,
                            // RichText for promotional description
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                text:
                                    'Chapter books, series, fiction books, picture books upto ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                children: <TextSpan>[
                                  // Emphasizes discount percentage
                                  TextSpan(
                                    text: '50% off.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ).pH(25), // Applies horizontal padding of 25 units
                            // Adds vertical spacing of 15 units
                            15.hBox,
                            // GestureDetector for navigating to books tab
                            GestureDetector(
                              onTap: () {
                                openTab(1); // Calls callback to open books tab
                              },
                              // Clipped container for 'View all' button
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  color:
                                      BookStoreColors
                                          .mediumRed, // Sets button color
                                  padding: const EdgeInsets.symmetric(),
                                  // Displays 'View all' text
                                  child: const Text(
                                    'View all',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).pSymmetric(
                                    h: 25,
                                    v: 10,
                                  ), // Applies symmetric padding
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Adds vertical spacing of 20 units
              20.hBox,
              // Clipped container for settings options
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: BookStoreColors.veryLightSand, // Sets background color
                  // Column to arrange settings tiles
                  child: Column(
                    children: [
                      // Settings tile for order history
                      SettingsTile(
                        icon: Icons.shopping_bag_rounded,
                        settingsName: 'Order History',
                      ),
                      // Divider between settings tiles
                      Divider(
                        color: BookStoreColors.darkBrown.withValues(alpha: .3),
                        height: 0.6,
                        indent: 10,
                        endIndent: 10,
                        thickness: .2,
                      ),
                      // Settings tile for payment
                      SettingsTile(
                        icon: Icons.payment_rounded,
                        settingsName: 'Payment',
                      ),
                      // Divider between settings tiles
                      Divider(
                        color: BookStoreColors.darkBrown.withValues(alpha: .3),
                        height: 0.6,
                        indent: 10,
                        endIndent: 10,
                        thickness: .2,
                      ),
                      // Settings tile for legal and privacy
                      SettingsTile(
                        icon: Icons.privacy_tip_rounded,
                        settingsName: 'Legal & Privacy',
                      ),
                      // Divider between settings tiles
                      Divider(
                        color: BookStoreColors.darkBrown.withValues(alpha: .3),
                        height: 0.6,
                        indent: 10,
                        endIndent: 10,
                        thickness: .2,
                      ),
                      // Settings tile for help
                      SettingsTile(
                        icon: Icons.help_outline_rounded,
                        settingsName: 'Help',
                      ),
                      // Divider between settings tiles
                      Divider(
                        color: BookStoreColors.darkBrown.withValues(alpha: .3),
                        height: 0.6,
                        indent: 10,
                        endIndent: 10,
                        thickness: .2,
                      ),
                      // Settings tile for about
                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        settingsName: 'About',
                      ),
                    ],
                  ),
                ),
              ),
              // Adds vertical spacing of 20 units
              20.hBox,
              // Container for logout button
              Container(
                padding: const EdgeInsets.symmetric(),
                // Applies gradient background
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      BookStoreColors.mediumRed,
                      BookStoreColors.lightRed,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                // Displays 'log out' text
                child: Text(
                  'log out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).pSymmetric(h: 25, v: 10), // Applies symmetric padding
              ),
            ],
          ),
        ],
      ),
    ).pH(18); // Applies horizontal padding of 18 units
  }
}

// Defines the SettingsTile as a stateless widget
class SettingsTile extends StatelessWidget {
  // Icon for the settings option
  final IconData icon;
  // Name of the settings option
  final String settingsName;
  // Constructor with required icon and settingsName parameters and optional key
  const SettingsTile({
    required this.icon,
    required this.settingsName,
    super.key,
  });

  @override
  // Builds the UI for the SettingsTile
  Widget build(BuildContext context) {
    // Returns a SizedBox for the settings tile
    return SizedBox(
      height: 60,
      // Row to arrange icon, text, and arrow
      child: Row(
        children: [
          // Expanded widget for icon and text
          Expanded(
            child: Row(
              children: [
                // Clipped container for the icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    color: BookStoreColors.mediumSand.withValues(
                      alpha: .5,
                    ), // Sets background color
                    padding: const EdgeInsets.all(10), // Applies padding
                    // Displays the settings icon
                    child: Icon(
                      icon,
                      color: BookStoreColors.darkBrown.withValues(alpha: .7),
                      size: 23,
                    ),
                  ),
                ),
                // Adds horizontal spacing of 15 units
                const SizedBox(width: 15),
                // Displays settings option name
                Text(
                  settingsName,
                  style: TextStyle(
                    color: BookStoreColors.darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Forward arrow icon
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: BookStoreColors.darkBrown.withValues(alpha: .7),
            size: 18,
          ),
        ],
      ).pH(10), // Applies horizontal padding of 10 units
    ).pV(5); // Applies vertical padding of 5 units
  }
}
