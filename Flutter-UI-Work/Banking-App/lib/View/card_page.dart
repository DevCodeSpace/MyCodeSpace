// Importing necessary packages for the cards page functionality
import 'package:banking_app/Core/Theme/text_style.dart'; // Text styles for consistent typography
import 'package:banking_app/Export/export.dart'; // Consolidated imports for the app
import 'package:dart_extensions_pro/dart_extensions_pro.dart'; // Extension methods for Dart

// CardsPage widget, a stateful widget for the cards overview screen
class CardsPage extends StatefulWidget {
  // Constructor with optional key for widget identification
  const CardsPage({super.key});

  @override
  // Creates the state for the CardsPage widget
  State<CardsPage> createState() => _CardsPageState();
}

// State class for the CardsPage widget
class _CardsPageState extends State<CardsPage> {
  // Variable to track the selected chart index
  int selectedChart = 0;
  // Boolean to control visibility of client box
  bool clientBox = true;

  @override
  // Builds the UI for the cards page
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
            // Header widget with placeholder heading and 'Overview' subheading
            Header(heading: '    ', subHeading: 'Overview'),
            // Vertical spacing of 16 pixels
            16.hBox,
            // Row for greeting text
            Row(
              children: [
                // Text displaying 'Hey' with regular style
                Text(
                  'Hey',
                  style: regularTextStyle(
                    28,
                    color: BankingColors.darkBlueGrey,
                  ),
                ),
                // Text displaying 'John!' with semi-bold style
                Text(
                  ' John!',
                  style: semiBoldTextStyle(28, color: Colors.black),
                ),
              ],
            ),
            // Vertical spacing of 10 pixels
            10.hBox,
            // Text prompting user action with regular style
            Text(
              'What will you do today?',
              style: regularTextStyle(15, color: BankingColors.darkBlueGrey),
            ),
            // Vertical spacing of 20 pixels
            20.hBox,
            // Container for search bar
            Container(
              // Fixed height for the search bar
              height: 55,
              // Styling with border, white background, rounded corners, and shadow
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: .8),
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100.withValues(alpha: .6),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              // Row containing text field and search icon
              child: Row(
                children: [
                  // Text field for search input
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        // Hint text for search
                        hintText: 'Search here',
                        // Hint text style
                        hintStyle: regularTextStyle(16, color: Colors.black54),
                        // Remove default border
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  // Container for search icon
                  Container(
                    // Fixed size for the icon container
                    height: 50,
                    width: 50,
                    // Styling with dark red background and rounded corners
                    decoration: BoxDecoration(
                      color: BankingColors.darkRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Search icon
                    child: Icon(Icons.search_rounded, color: Colors.white),
                  ),
                ],
              ).pOnly(l: 20, r: 2, t: 2, b: 2), // Padding for the row
            ),
            // Vertical spacing of 20 pixels
            20.hBox,
            // Widget for displaying card spending chart
            CardSpendingsChartWidget(),
            // Vertical spacing of 20 pixels
            20.hBox,
            // Row for displaying clients count and cards widgets
            Row(
              // Space widgets evenly
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Widget for displaying clients count
                ClientsCountWidget(),
                // Widget for displaying user's cards
                YourCardsWidget(),
              ],
            ),
          ],
        ).pOnly(l: 25, r: 25, b: 120), // Padding for the column
      ),
    );
  }
}
