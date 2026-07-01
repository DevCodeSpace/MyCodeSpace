import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Renders [text] with every occurrence of [query] highlighted in yellow.
class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;

    if (query.trim().isEmpty) {
      return Text(text, style: base);
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          backgroundColor: AppColors.highlight,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ));
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(style: base, children: spans),
    );
  }
}
