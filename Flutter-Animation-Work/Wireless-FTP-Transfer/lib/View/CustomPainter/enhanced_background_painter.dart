// ignore_for_file: deprecated_member_use

import 'package:animations_app/Export/export.dart';
import 'dart:math' as math;

class EnhancedBackgroundPainter extends CustomPainter {
  final double animation; // Animation progress value, used for dynamic effect
  final Color primaryColor; // Primary color for drawing elements
  final Color secondaryColor; // Secondary color for drawing elements

  EnhancedBackgroundPainter({
    required this.animation, // Constructor to initialize the animation value
    required this.primaryColor, // Constructor to initialize the primary color
    required this.secondaryColor, // Constructor to initialize the secondary color
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill; // Paint object for filling shapes

    // Draw animated circles with oscillating position and size
    for (var i = 0; i < 5; i++) {
      final centerX =
          size.width * (0.2 + (i * 0.2)); // Horizontal position based on index
      final centerY = size.height *
          (0.2 +
              (math.sin(animation + i) *
                  0.1)); // Vertical position with animation effect
      final radius = 25.0 +
          (math.cos(animation + i) * 10); // Radius oscillates with animation

      // Alternate colors for circles
      paint.color = i % 2 == 0 ? primaryColor : secondaryColor;
      canvas.drawCircle(
          Offset(centerX, centerY), radius, paint); // Draw the circle on canvas
    }

    // Draw animated waves with oscillating paths
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke // Stroke for wave lines
      ..strokeWidth = 2.0; // Set wave stroke width

    for (var i = 0; i < 3; i++) {
      final path = Path(); // Create a new path for each wave
      // Wave color changes based on index and opacity decreases for each subsequent wave
      wavePaint.color = (i % 2 == 0 ? primaryColor : secondaryColor)
          .withOpacity(0.5 - (i * 0.1));

      path.moveTo(
          0, size.height * 0.5); // Start the wave from the middle of the height

      // Create wave path with sine function to make the wave oscillate
      for (double x = 0; x <= size.width; x += 10) {
        final y = math.sin(x * 0.01 + animation + i) *
                20 + // Sine wave calculation for Y
            size.height * 0.5 + // Center the wave vertically
            (i * 20); // Shift each wave vertically based on index
        path.lineTo(x, y); // Add points to the path
      }

      // Draw the wave on canvas
      canvas.drawPath(path, wavePaint);
    }

    // Draw floating particles with animation effect
    final particlePaint = Paint()
      ..style = PaintingStyle.fill; // Paint object for particles

    for (var i = 0; i < 20; i++) {
      final x = size.width *
          (math.cos(animation * 0.5 + i) * 0.3 +
              0.5); // X position based on cosine wave
      final y = size.height *
          (math.sin(animation * 0.5 + i) * 0.3 +
              0.5); // Y position based on sine wave
      final radius = 2.0 +
          math.cos(animation + i) *
              1.0; // Particle radius oscillates with animation

      // Set color for particles with alternating primary and secondary colors
      particlePaint.color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withOpacity(0.3);
      canvas.drawCircle(
          Offset(x, y), radius, particlePaint); // Draw each particle
    }
  }

  @override
  bool shouldRepaint(EnhancedBackgroundPainter oldDelegate) {
    return oldDelegate.animation !=
        animation; // Repaint if the animation value changes
  }
}
