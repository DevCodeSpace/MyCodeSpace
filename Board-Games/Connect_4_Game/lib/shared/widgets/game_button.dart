import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';

class GameButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool filled;

  final double? cornerRadius;

  /// ✅ NEW → custom padding support (for height control)
  final EdgeInsetsGeometry? padding;

  const GameButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.filled = true,
    this.cornerRadius,
    this.padding, // ✅ added
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _pressed = false;

  static const double _depth = 4.0;

  Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final alpha = disabled ? 0.45 : 1.0;

    final rawBase = widget.color ?? context.colors.primary;
    final base = rawBase.withValues(alpha: alpha);
    final dark = _darken(rawBase).withValues(alpha: alpha);

    final fg = widget.filled ? Colors.white : base;
    final radius = widget.cornerRadius ?? 6.0;
    final br = BorderRadius.circular(radius);

    final filledGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _pressed
          ? [dark, dark, dark, dark]
          : [base, base, dark, dark],
      stops: const [0.0, 0.80, 0.80, 1.0],
    );

    final outlineGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: _pressed
          ? [
              base.withValues(alpha: 0.20),
              base.withValues(alpha: 0.20),
              base.withValues(alpha: 0.20),
              base.withValues(alpha: 0.20),
            ]
          : [
              base.withValues(alpha: 0.08),
              base.withValues(alpha: 0.08),
              base.withValues(alpha: 0.24),
              base.withValues(alpha: 0.24),
            ],
      stops: const [0.0, 0.80, 0.80, 1.0],
    );

    /// ✅ default padding (same feel as before)
    final basePadding =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),

        /// ✅ 3D press effect (no change in total height)
        padding: EdgeInsets.only(
          left: basePadding.horizontal / 2,
          right: basePadding.horizontal / 2,
          top: _pressed
              ? basePadding.vertical / 2 + _depth
              : basePadding.vertical / 2,
          bottom: _pressed
              ? basePadding.vertical / 2
              : basePadding.vertical / 2 + _depth,
        ),

        decoration: BoxDecoration(
          gradient: widget.filled ? filledGradient : outlineGradient,
          borderRadius: br,
          border: widget.filled
              ? null
              : Border.all(color: base, width: 2.0),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.max, // ✅ FIX
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: fg, size: 18),
              const SizedBox(width: 6),
            ],

            /// ✅ FIX → prevents overflow
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textStyles.titleSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}