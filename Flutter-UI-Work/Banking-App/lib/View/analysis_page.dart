// Importing necessary packages for styling, widgets, and extensions
import 'package:banking_app/Core/Theme/text_style.dart';
import 'package:banking_app/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

// Defines the AnalysisPage as a stateless widget
class AnalysisPage extends StatelessWidget {
  // Constructor with optional key parameter
  const AnalysisPage({super.key});

  @override
  // Builds the UI for the AnalysisPage
  Widget build(BuildContext context) {
    // Returns a Scaffold widget as the main structure
    return Scaffold(
      // Sets the background color of the scaffold to white
      backgroundColor: Colors.white,
      // Uses SingleChildScrollView to allow scrolling content
      body: SingleChildScrollView(
        // Column to arrange children vertically
        child: Column(
          // Aligns children to the start (left) of the column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adds vertical spacing of 55 units
            55.hBox,
            // Custom Header widget with empty heading and 'Dashboard' subheading
            Header(heading: '    ', subHeading: 'Dashboard'),
            // Adds vertical spacing of 15 units
            15.hBox,
            // Displays 'Total Balance' text with specific styling
            Text(
              'Total Balance',
              style: regularTextStyle(22, color: BankingColors.darkBlueGrey),
            ),
            // Adds vertical spacing of 10 units
            10.hBox,
            // Custom widget to display total balance information
            TotalBalanceWidget(),
            // Adds vertical spacing of 28 units
            28.hBox,
            // Custom widget to display positions and cash information
            PositionsAndCashWidget(),
            // Adds vertical spacing of 20 units
            20.hBox,
            // Row to arrange 'Token Bonus' title and badge horizontally
            Row(
              children: [
                // Displays 'Token Bonus' text with semi-bold styling
                Text(
                  'Token Bonus',
                  style: semiBoldTextStyle(17, color: Colors.grey.shade700),
                ),
                // Adds horizontal spacing of 10 units
                10.wBox,
                // Container for the 'Today' badge
                Container(
                  // Applies decoration with light green background and rounded corners
                  decoration: BoxDecoration(
                    color: BankingColors.lightGreen,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  // Displays 'Today' text with padding and specific styling
                  child: Text(
                    'Today',
                    style: mediumTextStyle(10, color: Colors.white),
                  ).pSymmetric(h: 10, v: 3),
                ),
              ],
            ),
            // Adds vertical spacing of 15 units
            15.hBox,
            // Row to arrange token bonus widgets horizontally
            Row(
              children: [
                // Custom widget for the left part of token bonus
                TokenBonusLeftWidget(),
                // Adds horizontal spacing of 20 units
                20.wBox,
                // Custom widget for the right part of token bonus
                TokenBonusRightWidget(),
              ],
            ),
          ],
          // Applies bottom padding of 120 units and horizontal padding of 25 units
        ).pOnly(b: 120).pH(25),
      ),
    );
  }
}
