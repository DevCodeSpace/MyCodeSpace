import 'package:flutter/material.dart';

class GlacierColors {
  static const Color background = Color(0xFF050811);
  static const Color surface = Color(0xFF0B1326);
  static const Color surfaceContainer = Color(0xFF171F33);
  static const Color surfaceContainerHigh = Color(0xFF222A3D);
  static const Color surfaceContainerHighest = Color(0xFF2D3449);
  static const Color surfaceContainerLow = Color(0xFF131B2E);
  static const Color surfaceContainerLowest = Color(0xFF060E20);
  static const Color surfaceDim = Color(0xFF0B1326);
  static const Color surfaceBright = Color(0xFF31394D);

  static const Color primary = Color(0xFFD2BBFF);
  static const Color onPrimary = Color(0xFF3F008E);
  static const Color primaryContainer = Color(0xFF7C3AED);
  static const Color onPrimaryContainer = Color(0xFFEDE0FF);

  static const Color secondary = Color(0xFFDDB7FF);
  static const Color onSecondary = Color(0xFF490080);
  static const Color secondaryContainer = Color(0xFF6F00BE);
  static const Color onSecondaryContainer = Color(0xFFD6A9FF);

  static const Color tertiary = Color(0xFFC3C0FF);
  static const Color onTertiary = Color(0xFF1D00A5);
  static const Color tertiaryContainer = Color(0xFF564EEC);
  static const Color onTertiaryContainer = Color(0xFFE6E3FF);

  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  static const Color outline = Color(0xFF958DA1);
  static const Color outlineVariant = Color(0xFF4A4455);
  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color onSurfaceVariant = Color(0xFFCCC3D8);
  static const Color inverseSurface = Color(0xFFDAE2FD);
  static const Color inverseOnSurface = Color(0xFF283044);

  // Decorative gradients
  static const Gradient bgMeshGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0x33D2BBFF), // 20% opacity primary
      Color(0x1A0B1326), // 10% opacity background
    ],
  );

  static const Gradient bottomMeshGradient = RadialGradient(
    center: Alignment.bottomLeft,
    radius: 1.2,
    colors: [
      Color(0x26C3C0FF), // 15% opacity tertiary
      Color(0x000B1326), // transparent background
    ],
  );
}
