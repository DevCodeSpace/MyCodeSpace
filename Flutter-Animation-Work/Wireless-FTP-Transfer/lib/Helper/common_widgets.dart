// ignore_for_file: deprecated_member_use

import 'package:animations_app/Export/export.dart';
import 'package:animations_app/Helper/transfer_option.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

// Widget to build a feature chip displaying a feature with a check icon
Widget buildFeatureChip(String feature) {
  return Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 12, vertical: 6), // Padding inside the chip
    decoration: BoxDecoration(
      color: Colors.white
          .withOpacity(0.95), // Slight transparency for the background color
      borderRadius: BorderRadius.circular(12), // Rounded corners for the chip
    ),
    child: Row(
      mainAxisSize:
          MainAxisSize.min, // Keep the chip size minimal to fit the content
      children: [
        Icon(
          Icons.check_circle_rounded, // Check circle icon
          size: 16, // Icon size
          color: Colors.green.shade600, // Green color for the check icon
        ),
        const SizedBox(width: 6), // Spacing between the icon and the text
        Text(
          feature, // Feature text
          style: const TextStyle(
            fontSize: 12, // Font size of the feature text
            fontWeight: FontWeight.w600, // Bold weight for the feature text
          ),
        ),
      ],
    ),
  );
}

// Builds a feature tag with icon and label
Widget buildFeatureTag(String label, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade100.withOpacity(0.3),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blue.shade600, // Icon color
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.blue.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// Function to build the animated header section
Widget buildAnimatedHeader() {
  return TweenAnimationBuilder(
    duration: const Duration(milliseconds: 800), // Set animation duration
    tween: Tween<double>(begin: 0, end: 1), // Define animation range
    builder: (context, double value, child) {
      return Transform.translate(
        offset: Offset(0, 50 * (1 - value)), // Slide animation effect
        child: Opacity(
          opacity: value, // Apply fade-in animation
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5), // Shadow effect
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildAnimatedIcon(), // Build the animated icon
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Method',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose the best method based on your needs. Both options provide secure and reliable file transfer.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Widget to build the animated icon with a rotating effect
Widget buildAnimatedIcon() {
  return TweenAnimationBuilder(
    // Animation duration set to 1200 milliseconds
    duration: const Duration(milliseconds: 1200),
    // Tween defines the range from 0 to 1, controlling the rotation angle
    tween: Tween<double>(begin: 0, end: 1),
    builder: (context, double value, child) {
      return Transform.rotate(
        // Rotating the icon based on the animation value
        angle: 2 * math.pi * value,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.tips_and_updates_rounded, // Icon to rotate
            color: Colors.blue.shade600, // Icon color
            size: 20, // Icon size
          ),
        ),
      );
    },
  );
}

// Widget to build a list of details with an arrow icon for each detail
Widget buildDetailsList(List<String> details) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align details to the left
    children: details.map((detail) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 4), // Vertical spacing between each detail
        child: Row(
          children: [
            Icon(
              Icons.arrow_right_rounded, // Arrow icon before each detail
              color: Colors.white
                  .withOpacity(0.7), // Slight transparency for the icon color
              size: 16, // Icon size
            ),
            const SizedBox(width: 4), // Spacing between the icon and text
            Text(
              detail, // Detail text
              style: TextStyle(
                color: Colors.white
                    .withOpacity(0.9), // Slight transparency for text color
                fontSize: 11, // Font size for the detail text
              ),
            ),
          ],
        ),
      );
    }).toList(), // Convert each detail to a widget in the list
  );
}

// Widget to build a list of features for each transfer option
Widget buildFeaturesList(List<String> features) {
  return Wrap(
    spacing: 8, // Horizontal spacing between feature chips
    runSpacing: 8, // Vertical spacing between feature chips
    children: features.asMap().entries.map((entry) {
      return TweenAnimationBuilder<double>(
        key: ValueKey(entry.value), // Key for better performance in animation
        duration: Duration(
            milliseconds:
                400 + (entry.key * 100)), // Staggered animation duration
        tween:
            Tween<double>(begin: 0, end: 1), // Fade-in effect for each feature
        builder: (context, value, child) {
          return Transform.scale(
            scale: value, // Scale the feature chip based on animation value
            child: child,
          );
        },
        child: buildFeatureChip(entry.value), // Feature chip widget
      );
    }).toList(),
  );
}

// Widget to build the header section of the transfer option card
Widget buildOptionHeader(TransferOption option) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white, // Icon background color
          borderRadius:
              BorderRadius.circular(12), // Rounded corners for the icon
        ),
        child: Icon(
          option.icon, // Option icon
          color: option.color, // Icon color
          size: 20,
          key: ValueKey(option.title), // Key for efficient widget rebuild
        ),
      ),
      const SizedBox(width: 12), // Spacing between the icon and text
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option.title, // Option title
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Title text color
              ),
            ),
            const SizedBox(height: 2),
            Text(
              option.description, // Option description
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9), // Description text color
              ),
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white
              .withOpacity(0.2), // Icon background with transparency
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1, // Border for the right icon
          ),
        ),
        child: const Icon(
          Icons.arrow_forward_ios_rounded, // Arrow icon for card action
          color: Colors.white,
          size: 16,
        ),
      ),
    ],
  );
}
