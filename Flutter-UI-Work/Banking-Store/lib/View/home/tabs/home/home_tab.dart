// Importing Dart's math library for mathematical operations like pi
import 'package:banking_store/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/cupertino.dart' as cupertino;

// Defines the HomeTab as a stateless widget
class HomeTab extends StatelessWidget {
  // Constructor with optional key parameter
  const HomeTab({super.key});

  @override
  // Builds the UI for the HomeTab
  Widget build(BuildContext context) {
    // Returns a Container with white background as the main structure
    return Container(
      color: Colors.white,
      // Uses Stack to layer multiple widgets
      child: Stack(
        children: [
          // Positioned widget to create a decorative background with curved bottom
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height / 2.4,
            // Clips the container with rounded bottom corners
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              // Container with dark brown background
              child: Container(
                color: StoreColors.darkBrown,
                // Stack for layering SVG decorations
                child: Stack(
                  children: [
                    // Positioned SVG at bottom-left with rotation and flip
                    Positioned(
                      bottom: 180,
                      left: -180,
                      height: 450,
                      child: Transform.flip(
                        flipY: true,
                        child: Transform.rotate(
                          angle: pi / 2.1,
                          // Loads SVG asset with dark green color filter
                          child: SvgPicture.asset(
                            "assets/svgs/svg-path.svg",
                            colorFilter: ColorFilter.mode(
                              StoreColors.darkGreen,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned SVG at top-right with rotation
                    Positioned(
                      top: -350,
                      right: -300,
                      height: 600,
                      child: Transform.flip(
                        flipY: false,
                        child: Transform.rotate(
                          angle: pi,
                          // Loads SVG asset with dark teal color filter
                          child: SvgPicture.asset(
                            "assets/svgs/svg-path.svg",
                            colorFilter: ColorFilter.mode(
                              StoreColors.darkTeal,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned SVG at bottom-right with rotation and flip
                    Positioned(
                      bottom: -60,
                      right: -150,
                      height: 330,
                      child: Transform.flip(
                        flipY: false,
                        flipX: true,
                        child: Transform.rotate(
                          angle: pi,
                          // Loads SVG asset with light pink color filter
                          child: SvgPicture.asset(
                            "assets/svgs/svg-path.svg",
                            colorFilter: ColorFilter.mode(
                              StoreColors.ligthPink,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Positioned widget for the main content column
          Positioned.fill(
            child: Container(
              // Column to arrange content vertically
              child: Column(
                children: [
                  // Adds vertical spacing of 70 units
                  70.hBox,
                  // Row for the notification icon at the top-right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // GestureDetector for navigating to the notification page
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.notificationPage);
                        },
                        // Displays a Cupertino slider icon
                        child: Icon(
                          cupertino.CupertinoIcons.slider_horizontal_3,
                          color: StoreColors.ligthPink.withValues(alpha: 0.9),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  // Adds vertical spacing of 65 units
                  65.hBox,
                  // Custom widget for displaying profile picture
                  ProfilePictureWidget(),
                  // Adds vertical spacing of 50 units
                  50.hBox,
                  // Container for the 'Instant' cash available card
                  Container(
                    height: 100,
                    // Applies white background, rounded corners, and shadow
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    // Row to display 'Instant' cash information
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Column for text labels
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Displays 'Instant' title
                            Text(
                              'Instant',
                              style: boldTextStyle(23, color: Colors.black),
                            ),
                            // Displays 'Cash available' subtitle
                            Text(
                              'Cash available',
                              style: boldTextStyle(color: Colors.grey, 14),
                            ),
                          ],
                        ),
                        // Displays cash amount
                        Text(
                          '\$2,162',
                          style: boldTextStyle(color: Colors.black, 24),
                        ),
                      ],
                    ).pH(25), // Applies horizontal padding of 25 units
                  ),
                  // Adds vertical spacing of 35 units
                  35.hBox,
                  // Container for the 'Savings' card
                  Container(
                    height: 170,
                    width: double.infinity,
                    // Applies white background, rounded corners, and shadow
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    // Column for savings content
                    child: Column(
                      children: [
                        // Row for savings title and amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column for savings text labels
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Displays 'Savings' title
                                Text(
                                  'Savings',
                                  style: boldTextStyle(color: Colors.black, 20),
                                ),
                                // Displays 'Smart saving is on' subtitle
                                Text(
                                  'Smart saving is on',
                                  style: boldTextStyle(color: Colors.grey, 14),
                                ),
                              ],
                            ),
                            // Displays savings amount
                            Text(
                              '\$5,102',
                              style: boldTextStyle(color: Colors.black, 24),
                            ),
                          ],
                        ),
                        // Adds vertical spacing of 20 units
                        20.hBox,
                        // Row for circular savings icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Iterates through savings models to display icons
                            for (final model in CircularIconModel.savings)
                              getCircularIcons(model),
                            // Adds a circular icon with '+' for adding savings
                            getCircularIcons(
                              CircularIconModel(
                                icon: Icons.add,
                                progressValue: 0,
                              ),
                              false,
                              true,
                            ),
                          ],
                        ),
                      ],
                    ).pOnly(t: 25).pH(25), // Applies top and horizontal padding
                  ),
                  // Adds vertical spacing of 35 units
                  35.hBox,
                  // Container for the 'Investment' card
                  Container(
                    height: 170,
                    width: double.infinity,
                    // Applies white background, rounded corners, and shadow
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 30,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    // Column for investment content
                    child: Column(
                      children: [
                        // Row for investment title and amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column for investment text labels
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Displays 'Investment' title
                                Text(
                                  'Investment',
                                  style: boldTextStyle(color: Colors.black, 20),
                                ),
                                // Displays 'Auto-investing is on' subtitle
                                Text(
                                  'Auto-investing is on',
                                  style: boldTextStyle(color: Colors.grey, 14),
                                ),
                              ],
                            ),
                            // Displays investment amount
                            Text(
                              '\$2,234',
                              style: boldTextStyle(color: Colors.black, 24),
                            ),
                          ],
                        ),
                        // Adds vertical spacing of 20 units
                        20.hBox,
                        // Row for circular investment icons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Iterates through investment models to display icons
                            for (final model in CircularIconModel.investments)
                              getCircularIcons(
                                model,
                                false,
                                true,
                                StoreColors.darkGreen,
                                Colors.white,
                              ),
                            // Adds a circular icon with '+' for adding investments
                            getCircularIcons(
                              CircularIconModel(
                                icon: Icons.add,
                                progressValue: 0,
                              ),
                              false,
                              true,
                              Colors.white,
                              StoreColors.darkGreen,
                            ),
                          ],
                        ),
                      ],
                    ).pOnly(t: 25).pH(25), // Applies top and horizontal padding
                  ),
                ],
              ).pH(35), // Applies horizontal padding of 35 units to the column
            ),
          ),
        ],
      ),
    );
  }

  // Function to create circular icons with optional progress and shadow
  Container getCircularIcons(
    CircularIconModel model, [
    bool showProgress = true,
    bool showShadow = false,
    Color? containerColor,
    Color? iconColor,
  ]) {
    // Returns a Container for the circular icon
    return Container(
      height: 42,
      width: 42,
      margin: const EdgeInsets.only(right: 15),
      // Applies color, rounded corners, and optional shadow
      decoration: BoxDecoration(
        color: containerColor ?? Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow:
            showShadow
                ? const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ]
                : null,
      ),
      // Stack to layer progress indicator and icon
      child: Stack(
        children: [
          // Conditionally shows a circular progress indicator
          if (showProgress)
            Positioned.fill(
              child: CircularProgressIndicator(
                value: model.progressValue,
                strokeWidth: 2,
                color: StoreColors.darkGreen,
                strokeCap: StrokeCap.round,
                backgroundColor: StoreColors.darkBrown.withValues(alpha: 0.1),
              ),
            ),
          // Centers the icon within the container
          Positioned.fill(
            child: Center(
              child: Icon(
                model.icon,
                color: iconColor ?? StoreColors.darkBrown,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
