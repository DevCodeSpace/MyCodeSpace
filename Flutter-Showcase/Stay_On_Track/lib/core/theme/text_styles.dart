import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class GlacierTextStyles {
  static TextStyle get display => GoogleFonts.rethinkSans(fontSize: 48, fontWeight: FontWeight.w700, color: GlacierColors.onSurface, letterSpacing: -0.02 * 48, height: 56 / 48);

  static TextStyle get headline => GoogleFonts.rethinkSans(fontSize: 24, fontWeight: FontWeight.w600, color: GlacierColors.onSurface, letterSpacing: -0.01 * 24, height: 32 / 24);

  static TextStyle get titleLarge => GoogleFonts.rethinkSans(fontSize: 20, fontWeight: FontWeight.w600, color: GlacierColors.onSurface);

  static TextStyle get titleMedium => GoogleFonts.rethinkSans(fontSize: 16, fontWeight: FontWeight.w600, color: GlacierColors.onSurface);

  static TextStyle get bodyLarge => GoogleFonts.rethinkSans(fontSize: 16, fontWeight: FontWeight.w400, color: GlacierColors.onSurface, height: 24 / 16);

  static TextStyle get bodyMedium => GoogleFonts.rethinkSans(fontSize: 14, fontWeight: FontWeight.w400, color: GlacierColors.onSurfaceVariant, height: 1.4);

  static TextStyle get bodySmall => GoogleFonts.rethinkSans(fontSize: 12, fontWeight: FontWeight.w400, color: GlacierColors.onSurfaceVariant);

  static TextStyle get labelLarge => GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w500, color: GlacierColors.primary, letterSpacing: 0.05 * 13, height: 16 / 13);

  static TextStyle get labelMedium => GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w500, color: GlacierColors.onSurfaceVariant, letterSpacing: 0.5);

  static TextStyle get labelSmall => GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w700, color: GlacierColors.onSurfaceVariant, letterSpacing: 1.2);
}
