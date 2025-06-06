// Importing necessary packages for widgets, extensions, and custom exports
import 'package:banking_store/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';
import 'package:flutter/cupertino.dart' as cupertino;

// Defines the InsightsTab as a stateless widget
class InsightsTab extends StatelessWidget {
  // Requires a TabController for tab navigation
  final TabController controller;
  // Constructor with required controller and optional key parameter
  const InsightsTab({required this.controller, super.key});

  @override
  // Builds the UI for the InsightsTab
  Widget build(BuildContext context) {
    // Returns a Scaffold widget as the main structure
    return Scaffold(
      // Container with white background for the main content
      body: Container(
        color: Colors.white,
        // Column to arrange content vertically
        child: Column(
          // Aligns children to the start (left) of the column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adds vertical spacing of 70 units
            70.hBox,
            // Row for navigation and menu widgets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // GestureDetector for navigating back to the first tab
                GestureDetector(
                  onTap: () {
                    controller.animateTo(0);
                  },
                  // Displays a clear icon for closing or navigating back
                  child: Icon(
                    Icons.clear_rounded,
                    color: StoreColors.darkGreen,
                    size: 28,
                  ),
                ),
                // Custom widget for displaying a menu
                MenuWidget(),
              ],
            ),
            // Adds vertical spacing of 20 units
            20.hBox,
            // Centers a circular progress indicator widget
            Center(
              child: Container(
                height: 200,
                width: 200,
                // Applies white background and circular shape
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(200),
                ),
                // Stack to layer progress indicator and icon
                child: Stack(
                  children: [
                    // Circular progress indicator filling the container
                    Positioned.fill(
                      child: CircularProgressIndicator(
                        value: .65, // Sets progress to 65%
                        strokeWidth: 8,
                        color: StoreColors.darkGreen,
                        strokeCap: StrokeCap.round,
                        // Sets background color with low opacity
                        backgroundColor: StoreColors.darkBrown.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    // Centers an icon within the progress indicator
                    Positioned.fill(
                      child: Center(
                        child: Icon(
                          cupertino.CupertinoIcons.wind_snow,
                          color: StoreColors.darkBrown,
                          size: 75,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Adds vertical spacing of 40 units
            40.hBox,
            // Displays 'Palm Springs' title
            Text('Palm Springs', style: boldTextStyle(color: Colors.black, 22)),
            // Row for displaying financial goal information
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Displays dollar sign with specific styling
                Text(
                  '\$',
                  style: boldTextStyle(color: StoreColors.darkGreen, 26),
                ).pOnly(b: 9), // Adds bottom padding of 9 units
                // Adds horizontal spacing of 5 units
                5.wBox,
                // Displays current amount
                Text(
                  '52,238',
                  style: boldTextStyle(color: StoreColors.darkGreen, 40),
                ),
                // Displays goal amount
                Text(
                  ' of \$30,000',
                  style: mediumTextStyle(color: Colors.grey, 16),
                ).pOnly(b: 12), // Adds bottom padding of 12 units
              ],
            ),
            // Adds vertical spacing of 15 units
            15.hBox,
            // Custom column for displaying goals-related insights
            getInsightsColumn(MenuModel.goals),
            // Adds vertical spacing of 35 units
            35.hBox,
            // Custom column for displaying utilities-related insights
            getInsightsColumn(MenuModel.utilities),
          ],
        ).pH(35), // Applies horizontal padding of 35 units to the column
      ),
    );
  }

  // Function to create a column for displaying insights based on a MenuModel
  Column getInsightsColumn(MenuModel model) {
    // Returns a Column for organizing insight items
    return Column(
      // Aligns children to the start (left) of the column
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Displays the title of the MenuModel
        Text(
          model.title,
          style: boldTextStyle(color: StoreColors.darkTeal, 27),
        ),
        // Iterates through sub-menus to create rows for each item
        for (final subModels in model.subMenus) ...[
          // Adds vertical spacing of 10 units
          10.hBox,
          // Row for displaying sub-menu details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Displays the subtitle of the sub-menu
              Text(
                subModels.subtitle,
                style: regularTextStyle(color: StoreColors.darkTeal, 18),
              ),
              // Row for hint text and navigation icon
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Conditionally displays hint text if available
                  if (subModels.hint != null)
                    Text(
                      subModels.hint!,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  // Adds horizontal spacing of 10 units
                  10.wBox,
                  // Displays a forward arrow icon for navigation
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          // Adds vertical spacing of 10 units
          10.hBox,
          // Divider line with low opacity
          Container(
            height: .7,
            width: double.infinity,
            color: StoreColors.darkBrown.withValues(alpha: 0.2),
          ),
        ],
      ],
    );
  }
}
