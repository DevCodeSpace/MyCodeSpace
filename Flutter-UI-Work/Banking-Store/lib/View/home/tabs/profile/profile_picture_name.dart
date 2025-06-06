// Importing necessary packages for styling, extensions, and Flutter material widgets
import 'package:banking_store/Export/export.dart';
import 'package:dart_extensions_pro/dart_extensions_pro.dart';

// Defines the ProfilePictureWidget as a stateless widget
class ProfilePictureWidget extends StatelessWidget {
  // Constructor with optional key parameter
  const ProfilePictureWidget({super.key});

  @override
  // Builds the UI for the ProfilePictureWidget
  Widget build(BuildContext context) {
    // Returns a Row to arrange the profile picture and text horizontally
    return Row(
      // Aligns children to the start (left) of the row
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Clips the profile image with a circular border
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          // Displays a profile image from assets
          child: Image.asset(
            'assets/profile/profile.jpg',
            width: 85,
            height: 85,
          ),
        ),
        // Adds horizontal spacing of 30 units
        30.wBox,
        // Column to arrange greeting text vertically
        Column(
          // Aligns text to the start (left) of the column
          crossAxisAlignment: CrossAxisAlignment.start,
          // Centers text vertically within the column
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Displays a welcome message with specific styling
            Text(
              'Welcome back,',
              style: regularTextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                15,
              ),
            ),
            // Displays the user's name with bold styling
            Text('Mr Beast', style: boldTextStyle(color: Colors.white, 33)),
          ],
        ),
      ],
    );
  }
}
