import 'package:animations_app/Export/export.dart';

class AnimationConfig {
  final bool iconRotation;
  final bool patternMovement;
  final bool scalePulse;
  final bool fadeTransition;
  final double rotationSpeed;
  final double scaleRange;
  final Duration pulseDuration;
  final Curve rotationCurve;
  final Curve scaleCurve;

  const AnimationConfig({
    this.iconRotation = true,
    this.patternMovement = true,
    this.scalePulse = true,
    this.fadeTransition = true,
    this.rotationSpeed = 1.0,
    this.scaleRange = 0.2,
    this.pulseDuration = const Duration(milliseconds: 1500),
    this.rotationCurve = Curves.linear,
    this.scaleCurve = Curves.easeInOutBack,
  });

  AnimationConfig copyWith({
    bool? iconRotation,
    bool? patternMovement,
    bool? scalePulse,
    bool? fadeTransition,
    double? rotationSpeed,
    double? scaleRange,
    Duration? pulseDuration,
    Curve? rotationCurve,
    Curve? scaleCurve,
  }) {
    return AnimationConfig(
      iconRotation: iconRotation ?? this.iconRotation,
      patternMovement: patternMovement ?? this.patternMovement,
      scalePulse: scalePulse ?? this.scalePulse,
      fadeTransition: fadeTransition ?? this.fadeTransition,
      rotationSpeed: rotationSpeed ?? this.rotationSpeed,
      scaleRange: scaleRange ?? this.scaleRange,
      pulseDuration: pulseDuration ?? this.pulseDuration,
      rotationCurve: rotationCurve ?? this.rotationCurve,
      scaleCurve: scaleCurve ?? this.scaleCurve,
    );
  }
}
