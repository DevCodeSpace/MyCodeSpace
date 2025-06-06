// Importing necessary packages for colors, styles, exports, routes, extensions, and dotted border
import 'package:biosphere_app/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

// Defines the LandingPage as a stateless widget
class LandingPage extends StatelessWidget {
  // Constructor with optional key parameter
  const LandingPage({super.key});

  @override
  // Builds the UI for the LandingPage
  Widget build(BuildContext context) {
    // Returns a Scaffold widget as the main structure
    return Scaffold(
      // Sets the background color to light blue
      backgroundColor: HealthifyColors.lightBlue,
      // Stack to layer decorative elements and content
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
          // Positioned cube image centered horizontally
          Positioned(
            width: 300,
            height: 300,
            bottom: 190,
            left:
                (MediaQuery.of(context).size.width / 2) -
                150, // Centers the image
            child: Image(image: AssetImage('assets/cube.png')),
          ),
          // Positioned column for main content
          Positioned.fill(
            child: Column(
              children: [
                // Adds vertical spacing of 70 units
                70.hBox,
                // Header row with title and info icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Displays 'BioSphere' title
                    Text(
                      'BioSphere',
                      style: GoogleFonts.charmonman(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                    // Container for info icon
                    Container(
                      height: 50,
                      width: 50,
                      // White background with circular shape
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(Icons.info_outline_rounded, size: 24),
                    ),
                  ],
                ),
                // Adds vertical spacing of 20 units
                20.hBox,
                // Subheader text
                Text(
                  'REVOLUTIONARY JOURNEY',
                  style: customTextStyle(
                    14,
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                // Adds vertical spacing of 5 units
                5.hBox,
                // RichText for stylized main heading
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Unreveling',
                    style: customTextStyle(
                      53,
                      color: Colors.white,
                      fontWeight: FontWeight.w200,
                    ).copyWith(letterSpacing: -4.5, wordSpacing: 5),
                    children: [
                      // Text span for 'the code' with black color
                      TextSpan(
                        text: '\nthe code',
                        style: TextStyle(color: Colors.black),
                      ),
                      // Text span for 'of life today' with default style
                      TextSpan(text: '\nof life today'),
                    ],
                  ),
                ),
              ],
            ).pH(20), // Applies horizontal padding of 20 units
          ),
          // Positioned column for bottom content
          Positioned(
            width: MediaQuery.of(context).size.width,
            bottom: 50,
            // Column for description text and buttons
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RichText for stylized description
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    text: 'Dance of',
                    style: customTextStyle(
                      17,
                      color: Colors.black.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w300,
                    ).copyWith(letterSpacing: -0.5, wordSpacing: 2),
                    children: [
                      // Text span for 'genes' with white color
                      TextSpan(
                        text: ' genes',
                        style: TextStyle(color: Colors.white),
                      ),
                      // Text span for 'and'
                      TextSpan(text: '\nand'),
                      // Text span for 'technology' with white color
                      TextSpan(
                        text: ' technology',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Adds vertical spacing of 25 units
                25.hBox,
                // GestureDetector for navigation buttons
                GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.homePage); // Navigates to HomePage
                  },
                  // SizedBox for button row
                  child: SizedBox(
                    height: 55,
                    // Row for 'Start' and 'Sign Up' buttons
                    child: Row(
                      children: [
                        // Expanded widget for 'Start' button
                        Expanded(
                          child: Container(
                            // White background with rounded corners
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            // Centers the 'START' text
                            child: Center(
                              child: Text(
                                'START',
                                style: regularTextStyle(
                                  color: Colors.black,
                                  15,
                                ).copyWith(letterSpacing: -0.8),
                              ),
                            ),
                          ),
                        ),
                        // Adds horizontal spacing of 20 units
                        20.wBox,
                        // Expanded widget for 'Sign Up' button
                        Expanded(
                          child: Container(
                            // Transparent background with white border
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            // Centers the 'SIGN UP' text
                            child: Center(
                              child: Text(
                                'SIGN UP',
                                style: regularTextStyle(
                                  color: Colors.black,
                                  15,
                                ).copyWith(letterSpacing: -0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).pH(20), // Applies horizontal padding of 20 units
          ),
        ],
      ),
    );
  }
}
