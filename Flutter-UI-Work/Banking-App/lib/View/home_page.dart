// Importing necessary packages for the home page functionality
import 'package:banking_app/Core/Theme/text_style.dart'; // Text styles for consistent typography
import 'package:banking_app/Export/export.dart'; // Consolidated imports for the app
import 'package:dart_extensions_pro/dart_extensions_pro.dart'; // Extension methods for Dart
import 'package:flutter/cupertino.dart'; // Cupertino widgets for iOS-style UI components

// HomePage widget, a stateful widget for the home screen
class HomePage extends StatefulWidget {
  // Constructor with optional key for widget identification
  const HomePage({super.key});

  @override
  // Creates the state for the HomePage widget
  State<HomePage> createState() => _HomePageState();
}

// State class for the HomePage widget
class _HomePageState extends State<HomePage> {
  // Variable to track the selected chart index
  int selectedChart = 0;

  @override
  // Builds the UI for the home page
  Widget build(BuildContext context) {
    return Scaffold(
      // Set background color to white
      backgroundColor: Colors.white,
      // SingleChildScrollView to enable scrolling content
      body: SingleChildScrollView(
        child: Column(
          // Align children to the start of the cross axis
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vertical spacing of 60 pixels
            60.hBox,
            // Header widget with welcome message
            Header(heading: 'Welcome, ', subHeading: 'John!'),
            // Vertical spacing of 16 pixels
            16.hBox,
            // Container for the savings section with chart
            Container(
              // Styling with light green background and rounded corners
              decoration: BoxDecoration(
                color: BankingColors.lightGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                // Align children to the start of the cross axis
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text displaying 'Savings' with medium style
                  Text(
                    'Savings',
                    style: mediumTextStyle(22, color: Colors.white),
                  ),
                  // Vertical spacing of 25 pixels
                  25.hBox,
                  // Line chart widget for savings data
                  LineChartSample(
                    lineColor: Colors.white, // Line color for the chart
                    gradientColors: [
                      // Gradient colors for the chart with varying opacity
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ],
              ).pOnly(l: 20, r: 29, t: 15, b: 10), // Padding for the container
            ),
            // Vertical spacing of 10 pixels
            10.hBox,
            // Pager dots for chart navigation
            showPagerDots(),
            // Vertical spacing of 25 pixels
            25.hBox,
            // Text displaying 'Total Balance' with medium style
            Text('Total Balance', style: mediumTextStyle(22)),
            // Vertical spacing of 4 pixels
            4.hBox,
            // Text displaying balance amount with bold style
            Text('\$ 16,033.44', style: boldTextStyle(22)),
            // Vertical spacing of 16 pixels
            16.hBox,
            // Text displaying 'Transactions' with semi-bold style
            Text('Transactions', style: semiBoldTextStyle(18)),
            // Vertical spacing of 10 pixels
            10.hBox,
            // Widget to display transaction profile photos
            showTransactionProfilePhotos(),
            // Vertical spacing of 20 pixels
            20.hBox,
            // Row for transaction history title and navigation icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text displaying 'Transaction history' with semi-bold style
                Text('Transaction history', style: semiBoldTextStyle(18)),
                // Forward arrow icon
                Icon(Icons.arrow_forward_ios_rounded, size: 17),
              ],
            ),
            // Vertical spacing of 10 pixels
            10.hBox,
            // Map dummy transaction data to TransactionDetailsTile widgets
            ...TransactionModel.dummyData.map((TransactionModel transaction) {
              return TransactionDetailsTile(transaction: transaction);
            }),
          ],
        ).pOnly(l: 25, r: 25, b: 100), // Padding for the column
      ),
    );
  }

  // Widget to display transaction profile photos
  Widget showTransactionProfilePhotos() {
    return SizedBox(
      // Fixed height for the profile photos row
      height: 60,
      // Full width for the row
      width: double.infinity,
      child: Row(
        // Space profile photos evenly
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Loop to display three profile widgets
          for (int index = 1; index < 4; index++)
            ProfileWidget(
              // Asset path for profile image
              assetPath: 'assets/profile/profile_${index + 1}.jpeg',
              // Online status based on odd index
              isOnline: index.isOdd,
            ),
          // Profile widget with count display
          ProfileWidget(
            assetPath: 'assets/profile/profile_5.jpeg',
            showCount: true, // Show count overlay
            count: '7', // Display count of 7
          ),
          // Container for 'more' icon
          ClipRRect(
            // Rounded corners for the container
            borderRadius: BorderRadius.circular(40),
            child: Container(
              // Fixed width and height for the icon container
              width: 60,
              height: 60,
              // Light grey background with transparency
              color: Colors.grey.shade300.withValues(alpha: 0.7),
              // More icon
              child: Icon(Icons.more_horiz_rounded, size: 27),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display pager dots for chart navigation
  Widget showPagerDots() {
    // Ensure selectedChart index is within valid range (0 to 2)
    selectedChart = selectedChart.clamp(0, 2);
    return Row(
      // Space elements evenly
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon for chart selection
        IconHolder(
          iconData: CupertinoIcons.chart_bar_alt_fill, // Chart icon
          iconColor: BankingColors.darkRed, // Icon color
          side: 50, // Size of the icon holder
          backgroundColor: BankingColors.veryLightRed, // Background color
          iconSize: 23, // Icon size
          radius: 13, // Border radius
        ),
        // Container for pager dots
        SizedBox(
          // Fixed height and width for dots
          height: 20,
          width: 75,
          child: Row(
            // Space dots evenly
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Loop to create three pager dots
              for (int index = 0; index < 3; index++)
                AnimatedContainer(
                  // Animation duration for smooth transitions
                  duration: const Duration(milliseconds: 500),
                  // Fixed width for each dot
                  width: 20,
                  decoration: BoxDecoration(
                    // Border for selected dot
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          selectedChart == index
                              ? BankingColors.lightGreen
                              : Colors.transparent,
                    ),
                  ),
                  // Inner container for the dot
                  child: Container(
                    decoration: BoxDecoration(
                      // Color based on selection state
                      color:
                          selectedChart == index
                              ? BankingColors.lightGreen
                              : BankingColors.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ).p(
                    selectedChart == index ? 4 : 3,
                  ), // Padding based on selection
                ),
            ],
          ),
        ),
        // Icon for copy action
        IconHolder(
          iconData: Icons.copy_rounded, // Copy icon
          iconColor: BankingColors.lightGreen, // Icon color
          side: 50, // Size of the icon holder
          backgroundColor: BankingColors.veryLightGreen, // Background color
          iconSize: 23, // Icon size
          radius: 13, // Border radius
        ),
      ],
    );
  }
}
