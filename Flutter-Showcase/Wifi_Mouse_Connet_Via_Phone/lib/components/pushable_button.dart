import 'package:flutter/material.dart';

/// Using [ShadowDegree] with values [ShadowDegree.dark] or [ShadowDegree.light]
/// to get a darker version of the used color.
/// [duration] in milliseconds
///
class PushableButton extends StatefulWidget {
  final Color color;
  final Widget child;
  final double? width;
  final int duration;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final VoidCallback onPressed;
  final ShadowDegree shadowDegree;

  const PushableButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.height = 40,
    this.width,
    this.duration = 70,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.color = Colors.blue,
    this.shadowDegree = ShadowDegree.light,
  });

  @override
  _PushableButtonState createState() => _PushableButtonState();
}

class _PushableButtonState extends State<PushableButton> {
  static const Curve _curve = Curves.easeIn;
  static const double _shadowHeight = 6;
  double _position = 6;

  @override
  Widget build(BuildContext context) {
    final double height = widget.height - _shadowHeight;

    return GestureDetector(
      onTapDown: _pressed,
      onTapUp: _unPressedOnTapUp,
      onTapCancel: _unPressed,
      // width here is required for centering the button in parent
      child: SizedBox(
        width: widget.width,
        height: height + _shadowHeight,
        child: Stack(
          children: <Widget>[
            // background shadow serves as drop shadow
            // width is necessary for bottom shadow
            Positioned(
              bottom: 0,
              left: 0, // Stretch to fill width
              right: 0,
              child: Container(
                height: height,
                width: widget.width,
                decoration: BoxDecoration(color: darken(widget.color, widget.shadowDegree), borderRadius: widget.borderRadius),
              ),
            ),
            AnimatedPositioned(
              curve: _curve,
              duration: Duration(milliseconds: widget.duration),
              bottom: _position,
              left: 0, // Stretch to fill width
              right: 0,
              child: Container(
                height: height,
                width: widget.width,
                decoration: BoxDecoration(color: widget.color, borderRadius: widget.borderRadius),
                child: Center(child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pressed(_) {
    setState(() {
      _position = 0;
    });
  }

  void _unPressedOnTapUp(_) => _unPressed();

  void _unPressed() {
    setState(() {
      _position = 6;
    });
    widget.onPressed();
  }
}

// Get a darker color from any entered color.
// Thanks to @NearHuscarl on StackOverflow
Color darken(Color color, ShadowDegree degree) {
  double amount = degree == ShadowDegree.dark ? 0.3 : 0.12;
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

enum ShadowDegree { light, dark }
