import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF7FAFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF0F5FF);
  static const Color panel = Color(0xFFFFFFFF);
  static const Color panelBlue = Color(0xFFEAF3FF);
  static const Color textPrimary = Color(0xFF142033);
  static const Color textMuted = Color(0xFF6F7D92);
  static const Color textSoft = Color(0xFF2E6BFF);
  static const Color gold = Color(0xFF2F7BFF);
  static const Color goldSoft = Color(0xFF7FB0FF);
  static const Color coral = Color(0xFF5B8CFF);
  static const Color border = Color(0x1F2F7BFF);
  static const Color borderGold = Color(0x332F7BFF);

  static ThemeData build() {
    final baseText = GoogleFonts.promptTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      textTheme: baseText.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      colorScheme: const ColorScheme.light(
        primary: gold,
        secondary: coral,
        surface: surface,
        error: coral,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.88),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      splashFactory: NoSplash.splashFactory,
    );
  }

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F9FF), Color(0xFFEAF3FF)],
  );

  static BoxDecoration frostedDecoration({Color? color, BorderRadius? radius}) {
    return BoxDecoration(
      color: (color ?? panel).withValues(alpha: 0.96),
      borderRadius: radius ?? BorderRadius.circular(28),
      border: Border.all(color: borderGold.withValues(alpha: 0.35)),
      boxShadow: [
        BoxShadow(
          color: gold.withValues(alpha: 0.06),
          blurRadius: 32,
          spreadRadius: -6,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: gold.withValues(alpha: 0.08),
          blurRadius: 32,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  static ImageFilter get blur => ImageFilter.blur(sigmaX: 16, sigmaY: 16);
}
