import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Provides the app-wide [ThemeData] for light and dark modes.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.playerRed,
        surface: AppColors.lightSurface,
      ),
      textTheme: GoogleFonts.silkscreenTextTheme(base.textTheme).apply(
        bodyColor: AppColors.lightText,
        displayColor: AppColors.lightText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.silkscreen(
          color: AppColors.lightText,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.primary.withValues(alpha: 0.18),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.playerYellow,
        surface: AppColors.darkSurface,
      ),
      textTheme: GoogleFonts.silkscreenTextTheme(
        base.textTheme,
      ).apply(bodyColor: AppColors.darkText, displayColor: AppColors.darkText),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.silkscreen(
          color: AppColors.darkText,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: AppColors.primary.withValues(alpha: 0.25),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        checkmarkColor: AppColors.primary,
      ),
    );
  }
}
