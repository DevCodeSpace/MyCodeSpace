// Importing Flutter material package
import 'package:flutter/material.dart';

// Custom StatelessWidget to create a Neumorphic-styled container
class NeumorphicContainer extends StatelessWidget {
  // Child widget to be displayed inside the container
  final Widget child;

  // Optional width and height for the container
  final double? width;
  final double? height;

  // Radius for rounding the container's corners
  final double borderRadius;

  // Optional background color for the container
  final Color? color;

  // Constructor with named parameters and a default borderRadius value
  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 25,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Set container dimensions if provided
      width: width,
      height: height,
      // Decoration for Neumorphic effect
      decoration: BoxDecoration(
        // Set background color or use default light gray
        color: color ?? Color(0xFFE0E5EC),
        // Apply border radius
        borderRadius: BorderRadius.circular(borderRadius),
        // Neumorphic shadow effect: light and dark shadows
        boxShadow: [
          // Dark shadow for bottom-right
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(5, 5),
            blurRadius: 10,
          ),
          // Light shadow for top-left
          BoxShadow(
            color: Colors.white,
            offset: Offset(-5, -5),
            blurRadius: 10,
          ),
        ],
      ),
      // Embed the child widget inside the styled container
      child: child,
    );
  }
}
