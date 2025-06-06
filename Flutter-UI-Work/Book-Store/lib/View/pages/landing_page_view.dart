// Importing necessary packages for widgets, exports, text styles, and extensions
import 'package:book_store/Core/widgets/all_books_widget.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

import '../../Export/export.dart';

// import '../../Export/export.dart';

// Defines the LandingPageView as a stateless widget
class LandingPageView extends StatelessWidget {
  // Callback function to open a specific tab
  final Function(int) openTab;
  // Constructor with required openTab callback and optional key parameter
  const LandingPageView({required this.openTab, super.key});

  @override
  // Builds the UI for the LandingPageView
  Widget build(BuildContext context) {
    // Returns a SizedBox to constrain the widget to screen dimensions
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      // Clips the content with rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        // ListView for scrollable content
        child: ListView(
          padding: const EdgeInsets.all(0), // Removes default padding
          children: [
            // Container for the main content section
            Container(
              height: 675,
              // Applies a gradient background image
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/gradient.png'),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              width: MediaQuery.of(context).size.width,
              // Column to arrange content vertically
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Clipped container for the top books section
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 90,
                      color:
                          BookStoreColors
                              .pillarBackgroundColor, // Sets background color
                      // Row to arrange image and text
                      child: Row(
                        children: [
                          // SizedBox for pillar image
                          SizedBox(
                            width: 80,
                            // Displays pillar image from assets
                            child: Image.asset(
                              'images/pillar.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),

                          10.wBox,
                          // Expanded widget for text content
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Displays title for top classic books
                                Text(
                                  'Top 50 Classic books',
                                  style: boldTextStyle(
                                    color: BookStoreColors.darkBrown,
                                    16,
                                  ),
                                ),
                                // Displays description for classic books
                                Text(
                                  'Discover the most influential books in classic literature.',
                                  style: mediumTextStyle(
                                    color: BookStoreColors.darkBrown.withValues(
                                      alpha: .8,
                                    ),
                                    13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).pH(15), // Applies horizontal padding of 15 units
                    ),
                  ),
                  // Adds vertical spacing of 60 units
                  60.hBox,
                  // Expanded widget for main promotional content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Centered title for bestsellers
                        Center(
                          child: Text(
                            '2023 year 100 most famous Bestsellers',
                            textAlign: TextAlign.center,
                            style: boldTextStyle(color: Colors.white, 30),
                          ),
                        ).pH(20), // Applies horizontal padding of 20 units
                        // Adds vertical spacing of 10 units
                        10.hBox,
                        // Centered description for bestsellers
                        Center(
                          child: Text(
                            'List of the most famous books of the year based on customers and the number of sales.',
                            textAlign: TextAlign.center,
                            style: semiBoldTextStyle(color: Colors.white, 15),
                          ),
                        ).pH(20), // Applies horizontal padding of 20 units
                        // Adds vertical spacing of 20 units
                        20.hBox,
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
                              // Displays 'View all' text
                              child: Text(
                                'View all',
                                style: semiBoldTextStyle(
                                  color: Colors.white,
                                  14,
                                ),
                              ).pSymmetric(
                                h: 45,
                                v: 10,
                              ), // Applies symmetric padding
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Custom widget to display all books
                  AllBooksWidget(),
                ],
              ).pOnly(
                t: 20,
                l: 20,
                r: 20,
              ), // Applies padding to top, left, and right
            ),
          ],
        ),
      ),
    ).pOnly(
      l: 28,
      r: 28,
      t: 75,
      b: 100,
    ); // Applies padding to the entire widget
  }
}
