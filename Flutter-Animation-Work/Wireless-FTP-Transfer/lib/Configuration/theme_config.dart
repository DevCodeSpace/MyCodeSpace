import 'package:animations_app/Export/export.dart';

class ThemeConfig {
  final List<Color>? gradientColors;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextStyle? bulletPointStyle;
  final ButtonStyle? buttonStyle;
  final double iconOpacity;
  final double patternOpacity;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;

  const ThemeConfig({
    this.gradientColors,
    this.titleStyle,
    this.descriptionStyle,
    this.bulletPointStyle,
    this.buttonStyle,
    this.iconOpacity = 1.0,
    this.patternOpacity = 0.2,
    this.borderRadius,
    this.shadows,
  });

  ThemeConfig copyWith({
    List<Color>? gradientColors,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    TextStyle? bulletPointStyle,
    ButtonStyle? buttonStyle,
    double? iconOpacity,
    double? patternOpacity,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
  }) {
    return ThemeConfig(
      gradientColors: gradientColors ?? this.gradientColors,
      titleStyle: titleStyle ?? this.titleStyle,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      bulletPointStyle: bulletPointStyle ?? this.bulletPointStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      iconOpacity: iconOpacity ?? this.iconOpacity,
      patternOpacity: patternOpacity ?? this.patternOpacity,
      borderRadius: borderRadius ?? this.borderRadius,
      shadows: shadows ?? this.shadows,
    );
  }
}
