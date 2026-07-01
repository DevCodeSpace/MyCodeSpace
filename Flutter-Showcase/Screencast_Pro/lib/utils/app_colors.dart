import 'package:flutter/material.dart';

class AppColors {
  // ── Background layers ──────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A1A); // Deepest dark layer (scaffold)
  static const Color surface = Color(0xFF12122A); // Card / panel background
  static const Color dialogBg = Color(0xFF1A1A2E); // Dialog / bottom-sheet background

  // ── Brand colours ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF); // Purple — app brand colour

  // Bluetooth section gradient
  static const Color bluetoothAccent = Color(0xFF1A73E8);
  static const Color bluetoothDark = Color(0xFF0D47A1);

  // WiFi section gradient
  static const Color wifiAccent = Color(0xFF00897B);
  static const Color wifiDark = Color(0xFF004D40);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Colors.white; // Headings and important text
  static const Color textSecondary = Color(0xFF8888AA); // Subtitles and hints
  static const Color blackColor = Color(0xFF000000); // Used as default in text_styles
}
