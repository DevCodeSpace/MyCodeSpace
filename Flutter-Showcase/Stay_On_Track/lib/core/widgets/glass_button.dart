import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'glass_container.dart';

class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double width;
  final double height;
  final double borderRadius;
  final bool primary;

  const GlassButton({super.key, required this.text, this.onPressed, this.icon, this.width = double.infinity, this.height = 56.0, this.borderRadius = 16.0, this.primary = true});

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = widget.primary ? GlacierColors.primary.withValues(alpha: 0.1) : Colors.transparent;
    final defaultBorderColor = widget.primary ? GlacierColors.primary.withValues(alpha: 0.3) : GlacierColors.outline.withValues(alpha: 0.2);

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GlassContainer(
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius,
          opacity: 0.1,
          borderColor: defaultBorderColor,
          borderWidth: widget.onPressed == null ? 0 : 1.5,
          child: Container(
            color: defaultBgColor,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
                Text(
                  widget.text,
                  style: GlacierTextStyles.titleMedium.copyWith(
                    color: GlacierColors.primary.withValues(alpha: widget.onPressed == null ? 0.4 : 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
