// Importing necessary packages for colors, styles, extensions, dotted border, and Flutter widgets

import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/cupertino.dart';

// Importing custom export file for additional dependencies
import '../Export/export.dart';

// Defines the DetailsPage as a stateless widget
class DetailsPage extends StatelessWidget {
  // Constructor with optional key parameter
  const DetailsPage({super.key});

  @override
  // Builds the UI for the DetailsPage
  Widget build(BuildContext context) {
    // Returns a Scaffold widget as the main structure
    return Scaffold(
      // Sets the background color of the scaffold to white
      backgroundColor: Colors.white,
      // Column to arrange content vertically
      body: Column(
        children: [
          // Container for the header section with a light pink background
          Container(
            color: HealthifyColors.lightpink,
            height: 250,
            // Stack to layer decorative elements and header content
            child: Stack(
              children: [
                // Positioned dotted oval border at top-right
                Positioned(
                  width: 120,
                  height: 70,
                  top: 30,
                  right: -40,
                  // Rotates the dotted border for visual effect
                  child: Transform.rotate(
                    angle: 181.24,
                    // DottedBorder widget for decorative oval
                    child: DottedBorder(
                      color: Colors.white,
                      dashPattern: [6, 6], // Sets dashed pattern
                      strokeWidth: 2, // Sets border thickness
                      borderType: BorderType.Oval, // Specifies oval shape
                      child: Container(
                        // Empty container with circular border radius
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                        ),
                      ),
                    ),
                  ),
                ),
                // Positioned dotted oval border at top-left
                Positioned(
                  width: 120,
                  height: 70,
                  top: 80,
                  left: -40,
                  // Rotates the dotted border for visual effect
                  child: Transform.rotate(
                    angle: 181.64,
                    // DottedBorder widget for decorative oval
                    child: DottedBorder(
                      color: Colors.white,
                      dashPattern: [6, 6], // Sets dashed pattern
                      strokeWidth: 2, // Sets border thickness
                      borderType: BorderType.Oval, // Specifies oval shape
                      child: Container(
                        // Empty container with circular border radius
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                        ),
                      ),
                    ),
                  ),
                ),
                // Positioned column for header content
                Positioned.fill(
                  child: Column(
                    children: [
                      // Adds vertical spacing of 70 units
                      70.hBox,
                      // Row for navigation and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // GestureDetector for navigating back
                          GestureDetector(
                            onTap: () {
                              Get.back(); // Navigates to the previous screen
                            },
                            // Container for back arrow icon
                            child: Container(
                              height: 50,
                              width: 50,
                              // White background with circular shape
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(Icons.arrow_back_rounded, size: 24),
                            ),
                          ),
                          // Displays 'BioSphere' title
                          Text(
                            'BioSphere',
                            style: GoogleFonts.charmonman(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                          // Container for profile icon
                          Container(
                            height: 50,
                            width: 50,
                            // White background with circular shape
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(CupertinoIcons.person, size: 24),
                          ),
                        ],
                      ),
                      // Adds vertical spacing of 20 units
                      20.hBox,
                      // SizedBox for profile images
                      SizedBox(
                        height: 110,
                        // Row to arrange profile images horizontally
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Container for profile image
                            Container(
                              height: 110,
                              width: 110,
                              // White background with circular shape and border
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 15,
                                ),
                              ),
                              // Displays profile image from assets
                              child: Image.asset(
                                'assets/profile.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Adds horizontal spacing of 10 units
                            10.wBox,
                            // Container for 'New' button
                            Container(
                              height: 110,
                              width: 110,
                              // White background with circular shape and border
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 15,
                                ),
                              ),
                              // Column for 'New' icon and text
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded, size: 28),
                                  Text(
                                    'New',
                                    style: regularTextStyle(
                                      20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).pH(20), // Applies horizontal padding of 20 units
                ),
              ],
            ),
          ),
          // Expanded widget for the main content area
          Expanded(
            // Stack to layer content and decorative image
            child: Stack(
              children: [
                // Positioned robot image at bottom-right
                Positioned(
                  width: 200,
                  right: -3,
                  bottom: -3,
                  child: Image.asset('assets/robot.png'),
                ),
                // Positioned column for main text content
                Positioned(
                  // Note: Commented out height property
                  // height: 230,
                  top: 15,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Displays 'Trace' text aligned to the left
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Trace',
                          style: customTextStyle(
                            48,
                            color: Colors.black,
                            fontWeight: FontWeight.w200,
                          ).copyWith(
                            height: 1.1,
                            letterSpacing: -4.5,
                            wordSpacing: 5,
                          ),
                        ),
                      ),
                      // Displays 'origins of your' text
                      Text(
                        'origins of your',
                        style: customTextStyle(
                          48,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ).copyWith(
                          height: 1.1,
                          letterSpacing: -4.5,
                          wordSpacing: 5,
                        ),
                      ),
                      // Displays 'ancestors' text aligned to the right
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'ancestors',
                          style: customTextStyle(
                            48,
                            color: Colors.black,
                            fontWeight: FontWeight.w200,
                          ).copyWith(
                            height: 1.1,
                            letterSpacing: -4.5,
                            wordSpacing: 5,
                          ),
                        ).pOnly(r: 10), // Applies right padding of 10 units
                      ),
                      // Displays description text aligned to the left
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Explore and understand the\nunique characteristics\nencoded in your DNA.',
                          softWrap: true,
                          style: customTextStyle(
                            17,
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                          ).copyWith(letterSpacing: -0.5, wordSpacing: 1),
                        ),
                      ),
                    ],
                  ).pH(20), // Applies horizontal padding of 20 units
                ),
                // Positioned column for bottom-left content
                Positioned(
                  bottom: 30,
                  left: 20,
                  height: 255,
                  width: 190,
                  // Column for 'Trace your roots' text and button
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Displays 'Trace your roots' text
                      Text(
                        'Trace\nyour roots',
                        style: customTextStyle(
                          45,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ).copyWith(
                          height: 1.1,
                          letterSpacing: -4.5,
                          wordSpacing: 5,
                        ),
                      ),
                      // Container for 'Learn More' button
                      Container(
                        height: 45,
                        width: 140,
                        // Black background with rounded corners
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        // Displays 'LEARN MORE' text
                        child: Text(
                          'LEARN MORE',
                          style: regularTextStyle(16.5, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
