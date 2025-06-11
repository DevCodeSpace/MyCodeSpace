import 'package:flutter/material.dart';

/// A custom container widget that applies a Neumorphic-style design.
/// It creates a soft, embossed or extruded look using shadows.
class NeumorphicContainer extends StatelessWidget {
  /// The child widget to display inside the container.
  final Widget child;

  /// Optional width of the container.
  final double? width;

  /// Optional height of the container.
  final double? height;

  /// The border radius of the container. Defaults to 20.
  final double borderRadius;

  /// Optional background color of the container.
  final Color? color;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Sets the width of the container if provided
      height: height, // Sets the height of the container if provided
      decoration: BoxDecoration(
        color: color ?? Color(0xFFE0E5EC), // Background color with a default light grey
        borderRadius: BorderRadius.circular(borderRadius), // Rounded corners
        boxShadow: [
          // Bottom-right shadow for depth
          BoxShadow(
            color: Color(0xFFA3B1C6), // Slightly darker shadow
            offset: Offset(5, 5), // Positioning of the shadow
            blurRadius: 10, // Softness of the shadow
          ),
          // Top-left highlight for the "light source" effect
          BoxShadow(
            color: Colors.white, // Lighter shadow for the highlight
            offset: Offset(-5, -5), // Positioning of the highlight
            blurRadius: 10, // Softness of the highlight
          ),
        ],
      ),
      child: child, // Places the provided child widget inside the container
    );
  }
}
