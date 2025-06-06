// Importing necessary packages for controller, colors, styles, exports, routes, extensions, and Flutter widgets

import 'package:biosphere_app/Export/export.dart';
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
        // Sets the background color to light green
        backgroundColor: HealthifyColors.lightGreen,
        // Stack to layer decorative elements, video, and content
        body: Stack(
          children: [
            // Positioned dotted oval border at top-right
            Positioned(
              width: 120,
              height: 70,
              top: 60,
              right: -60,
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
            // Positioned dotted oval border at top-left with rotation
            Positioned(
              width: 120,
              height: 70,
              top: 90,
              left: -40,
              // Rotates the dotted border for visual effect
              child: Transform.rotate(
                angle: (5 * pi) / 7,
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
            // Positioned large dotted oval border at bottom-right
            Positioned(
              width: 700,
              height: 400,
              bottom: 140,
              right: -480,
              // DottedBorder widget for decorative oval
              child: DottedBorder(
                color: Colors.white,
                dashPattern: [6, 3], // Sets dashed pattern
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
            // Conditionally displays video player if controller is available
            if (controller.videoController != null)
              Positioned(
                width: MediaQuery.of(context).size.width,
                height: 700,
                bottom: -40,
                // Checks if video is initialized
                child:
                    controller.isInitialized.value == true
                        ? AspectRatio(
                          // Sets aspect ratio based on video controller
                          aspectRatio:
                              (controller.videoController?.value.aspectRatio ??
                                  16 / 9),
                          // Displays video player
                          child: VideoPlayer(
                            controller.videoController ??
                                VideoPlayerController.asset("assets/dna.mp4"),
                          ),
                        )
                        : CircularProgressIndicator(), // Shows loading indicator if not initialized
              ),
            // Positioned column for main content
            Positioned.fill(
              child: Column(
                // Aligns content to the start (left)
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Adds vertical spacing of 70 units
                  70.hBox,
                  // Header row with navigation and title
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
                  // Adds vertical spacing of 25 units
                  25.hBox,
                  // Column for main text content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Displays 'Advanced' text
                      Text(
                        'Advanced',
                        style: customTextStyle(
                          44.5,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ).copyWith(
                          height: 1.1,
                          letterSpacing: -4.5,
                          wordSpacing: 5,
                        ),
                      ),
                      // Displays 'genetic mapping,' text aligned to the right
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'genetic mapping,',
                          style: customTextStyle(
                            44.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                          ).copyWith(
                            height: 1.1,
                            letterSpacing: -4.5,
                            wordSpacing: 5,
                          ),
                        ),
                      ),
                      // Displays 'up-to-date' text
                      Text(
                        'up-to-date',
                        style: customTextStyle(
                          44.5,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ).copyWith(
                          height: 1.1,
                          letterSpacing: -4.5,
                          wordSpacing: 5,
                        ),
                      ),
                      // Displays 'tools' text
                      Text(
                        'tools',
                        style: customTextStyle(
                          44.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w200,
                        ).copyWith(
                          height: 1.1,
                          letterSpacing: -4.5,
                          wordSpacing: 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ).pH(20), // Applies horizontal padding of 20 units
            ),
            // Aligns text for ethical practices statement
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Only legal, ethical\npractises',
                textAlign: TextAlign.start,
                style: customTextStyle(
                  16,
                  color: Color.fromARGB(255, 11, 47, 14),
                  fontWeight: FontWeight.w300,
                ).copyWith(letterSpacing: -0.7, wordSpacing: 2),
              ).pOnly(l: 20), // Applies left padding of 20 units
            ),
            // Positioned column for bottom content
            Positioned(
              width: MediaQuery.of(context).size.width,
              bottom: 35,
              // Column for 'Genetic Research' text and navigation button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Displays 'GENETIC RESEARCH' text
                  Text(
                    'GENETIC RESEARCH',
                    textAlign: TextAlign.end,
                    style: customTextStyle(
                      14,
                      color: Color.fromARGB(255, 11, 47, 14),
                      fontWeight: FontWeight.w300,
                    ).copyWith(letterSpacing: -0.7, wordSpacing: 2),
                  ),
                  // Adds vertical spacing of 55 units
                  55.hBox,
                  // GestureDetector for navigating to the details page
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        Routes.detailsPage,
                      ); // Navigates to DetailsPage
                    },
                    // Row for 'find out' text and arrow button
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Displays 'find out' text
                        Text(
                          'find out',
                          style: regularTextStyle(20, color: Colors.black),
                        ),
                        // Adds horizontal spacing of 10 units
                        10.wBox,
                        // Container for forward arrow icon
                        Container(
                          width: 40,
                          height: 40,
                          // Black background with circular shape
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          // Centers the arrow icon
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
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
    );
  }
}
