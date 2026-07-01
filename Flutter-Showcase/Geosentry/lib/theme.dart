import 'package:flutter/material.dart';

class AppTheme {
  // ── Core Surfaces ─────────────────────────────────────────────────────────
  static const Color background      = Color(0xFFF8FAFC);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceVariant  = Color(0xFFEBEFF5);
  static const Color accent          = Color(0xFFE4ECF9);
  static const Color border          = Color(0x1411161F); // #11161F @ 8%
  static const Color input           = Color(0x1A11161F); // #11161F @ 10%

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color foreground      = Color(0xFF11161F);
  static const Color mutedForeground = Color(0xFF5D646F);

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary         = Color(0xFF0077EC);
  static const Color primaryFg       = Color(0xFFF9FCFF);
  static const Color cyan            = Color(0xFF009ABA);
  static const Color emerald         = Color(0xFF00A36D);
  static const Color purple          = Color(0xFF8658E1);
  static const Color danger          = Color(0xFFEE343B);

  // ── Semantic aliases ──────────────────────────────────────────────────────
  static const Color success         = emerald;
  static const Color warning         = Color(0xFFFF9500);
  static const Color inside          = emerald;
  static const Color outside         = danger;
  static const Color onSurface       = foreground;
  static const Color onSurfaceVariant= mutedForeground;

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007BFE), Color(0xFF00AFD5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF00A55E), Color(0xFF00BBAB)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF745AF4), Color(0xFFC168D5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const RadialGradient backgroundGradient = RadialGradient(
    colors: [Color(0xFFEBF7FF), Color(0xFFF8FAFC)],
    center: Alignment.topCenter,
    radius: 1.2,
  );

  // ── Geofence zone colours ─────────────────────────────────────────────────
  static const List<int> geofenceColors = [
    0xFF0077EC, // primary blue
    0xFF00A36D, // emerald
    0xFF009ABA, // cyan
    0xFF8658E1, // purple
    0xFFEE343B, // danger red
    0xFFFF9500, // amber
    0xFF745AF4, // violet
    0xFF00BBAB, // teal
  ];

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: cyan,
          surface: surface,
          onPrimary: primaryFg,
          onSurface: foreground,
          error: danger,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: foreground,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: foreground,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: primaryFg,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: input,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(color: mutedForeground),
          hintStyle: const TextStyle(color: mutedForeground),
          prefixIconColor: mutedForeground,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: border),
          ),
          titleTextStyle: const TextStyle(
            color: foreground,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: const TextStyle(
            color: mutedForeground,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: primary,
          thumbColor: primary,
          overlayColor: primary.withOpacity(0.1),
          inactiveTrackColor: surfaceVariant,
          trackHeight: 4,
          thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 10),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? Colors.white
                : mutedForeground,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? primary
                : surfaceVariant,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: foreground,
          contentTextStyle:
              const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dividerTheme: const DividerThemeData(
          color: border,
          thickness: 1,
        ),
        fontFamily: 'SF Pro Text',
      );
}