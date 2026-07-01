import 'package:flutter/material.dart';

/// Centralized color palette — vibrant bright theme.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF7C3AED);        // Vibrant violet
  static const Color primaryDark = Color(0xFF5B21B6);    // Deep violet

  // Board
  static const Color boardBlue = Color(0xFF1D4ED8);      // Electric cobalt blue
  static const Color boardBlueDark = Color(0xFF1E3A8A);  // Deep navy
  static const Color boardShadow = Color(0xFF1E3A8A);    // Legacy ref

  // Players (Bright & vivid)
  static const Color playerRed = Color(0xFFEF4444);      // Bright red
  static const Color playerRedDark = Color(0xFFB91C1C);  // Deep red
  static const Color playerYellow = Color(0xFFFBBF24);   // Bright amber gold
  static const Color playerYellowDark = Color(0xFFD97706); // Deep amber

  // Light theme
  static const Color lightBackground = Color(0xFFF5F3FF); // Violet 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1E1B4B);       // Indigo 950

  // Dark theme
  static const Color darkBackground = Color(0xFF1E0A4E);  // Deep purple-black
  static const Color darkSurface = Color(0xFF2D1B69);     // Dark medium purple
  static const Color darkText = Color(0xFFF5F3FF);        // Violet 50

  // Accents
  static const Color winGlow = Color(0xFF10B981);         // Emerald
  static const Color emptyHoleLight = Color(0xFFDDD6FE);  // Violet 200
  static const Color emptyHoleDark = Color(0xFF1E0A4E);   // Deep dark

  // Home screen gradient
  static const Color homeBgTop = Color(0xFF6D28D9);      // Violet 700
  static const Color homeBgBottom = Color(0xFF1D4ED8);   // Blue 700
}
