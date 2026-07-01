import 'package:flutter/material.dart';

class TagHelper {
  TagHelper._();

  // Premium neon/pastel palette for visually stunning tag categories
  static const List<Color> _tagColors = [
    Color(0xFF6366F1), // Cyber Indigo
    Color(0xFF10B981), // Emerald Mint
    Color(0xFF06B6D4), // Ocean Cyan
    Color(0xFF8B5CF6), // Electric Violet
    Color(0xFFEC4899), // Hot Pink
    Color(0xFFF97316), // Sunset Orange
    Color(0xFFF59E0B), // Amber Yellow
    Color(0xFFF43F5E), // Rose Coral
    Color(0xFF14B8A6), // Teal Splash
    Color(0xFF3B82F6), // Dodger Blue
  ];

  /// Get a premium, deterministic color for any tag string.
  /// This ensures a tag like "Work" always has the same color.
  static Color getTagColor(String tag) {
    if (tag.isEmpty) return _tagColors[0];
    
    // Simple, robust string hash
    int hash = 0;
    for (int i = 0; i < tag.length; i++) {
      hash = tag.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    final index = hash.abs() % _tagColors.length;
    return _tagColors[index];
  }

  /// Generates a premium dark-blended gradient for the hashtag background
  static LinearGradient getTagGradient(String tag) {
    final baseColor = getTagColor(tag);
    return LinearGradient(
      colors: [
        baseColor,
        baseColor.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
