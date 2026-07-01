import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../models/player.dart';

/// A single coloured disc with a glossy radial gradient.
/// Winning discs pulse with a coloured border ring instead of a shadow glow.
class DiscWidget extends StatelessWidget {
  final Player player;
  final double size;
  final bool isWinning;

  const DiscWidget({
    super.key,
    required this.player,
    required this.size,
    this.isWinning = false,
  });

  @override
  Widget build(BuildContext context) {
    final disc = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Enhanced radial gradient for 3D depth — no shadow needed.
        gradient: RadialGradient(
          center: const Alignment(-0.30, -0.35),
          radius: 1.0,
          colors: [
            Color.lerp(player.color, Colors.white, 0.35)!,
            player.color,
            player.shadowColor,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner ring detail
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.14),
                width: 1.2,
              ),
            ),
          ),
          // Top-left glossy highlight spot
          Positioned(
            top: size * 0.11,
            left: size * 0.16,
            child: Container(
              width: size * 0.20,
              height: size * 0.13,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(size * 0.07),
              ),
            ),
          ),
        ],
      ),
    );

    if (!isWinning) return disc;

    return _PulsingRing(color: player.color, child: disc);
  }
}

/// Animates a pulsing coloured border ring around winning discs.
class _PulsingRing extends StatefulWidget {
  final Widget child;
  final Color color;

  const _PulsingRing({required this.child, required this.color});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: GameConstants.winPulseDuration)
        ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 0.45 + 0.55 * t),
              width: 2.0 + 4.0 * t,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
