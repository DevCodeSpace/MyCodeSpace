import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxShape shape;
  final bool elevated;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.6,
    this.borderRadius = 16.0,
    this.borderColor = const Color(0x1AD2BBFF), // 10% opacity primary
    this.borderWidth = 1.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final panelOpacity = elevated ? 0.75 : opacity;
    final panelBlur = elevated ? 24.0 : blur;
    final finalBorderColor = elevated
        ? const Color(0x26D2BBFF) // 15% opacity primary
        : borderColor;

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(boxShadow: elevated ? [BoxShadow(color: const Color(0xFFD2BBFF).withValues(alpha: 0.05), blurRadius: 30, spreadRadius: 0)] : null),
      child: ClipRRect(
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: panelBlur, sigmaY: panelBlur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              shape: shape,
              color: GlacierColors.surface.withValues(alpha: panelOpacity),
              borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
              border: Border.all(color: finalBorderColor, width: borderWidth),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
