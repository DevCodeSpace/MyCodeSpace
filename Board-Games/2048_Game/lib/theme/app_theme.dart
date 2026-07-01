import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Pastel Palette ──────────────────────────────────────────
  static const background  = Color(0xFFEFF1D9); // soft cream-yellow
  static const surface     = Color(0xFFDDECEF); // light sky blue (cards)
  static const boardBg     = Color(0xFF96DFCE); // mint teal (game board)
  static const cellEmpty   = Color(0xFFB6E8DE); // lighter mint (empty cells)
  static const accent      = Color(0xFF96DFCE); // mint (primary)
  static const accentAlt   = Color(0xFFF1EB86); // soft yellow (secondary / gradient end)
  static const pink        = Color(0xFFF8D5DB); // soft pink (score card)
  static const textDark    = Color(0xFF2C3A38); // dark teal-charcoal
  static const textLight   = Color(0xFFFFFFFF); // white
  static const textMuted   = Color(0xFF6B8B8A); // muted teal
  static const borderColor = Color(0xFFB8D4D8); // subtle blue-teal border
  static const borderSelected = Color(0xFF5ABFAE); // deeper mint border when selected

  // ── Dark mode ───────────────────────────────────────────────
  static const darkBackground = Color(0xFF1A2420);
  static const darkSurface    = Color(0xFF223330);
  static const darkBoard      = Color(0xFF1A3530);
  static const darkCell       = Color(0xFF1F4038);
  static const darkBorder     = Color(0xFF2E4E48);

  // ── Tile colors (classic 2048 progression) ──────────────────
  static const Map<int, Color> tileColors = {
    0:    cellEmpty,
    2:    Color(0xFFEEE4DA),
    4:    Color(0xFFEDE0C8),
    8:    Color(0xFFF2B179),
    16:   Color(0xFFF59563),
    32:   Color(0xFFF67C5F),
    64:   Color(0xFFF65E3B),
    128:  Color(0xFFEDCF72),
    256:  Color(0xFFEDCC61),
    512:  Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
    4096: Color(0xFF3E3933),
    8192: Color(0xFF3E3933),
  };

  static Color tileColor(int value) =>
      tileColors[value] ?? const Color(0xFF3E3933);

  static Color tileFontColor(int value) =>
      value <= 4 ? const Color(0xFF776E65) : textLight;
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(),
        fontFamily: GoogleFonts.poppins().fontFamily,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          surface: AppColors.darkBackground,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        fontFamily: GoogleFonts.poppins().fontFamily,
      );
}
