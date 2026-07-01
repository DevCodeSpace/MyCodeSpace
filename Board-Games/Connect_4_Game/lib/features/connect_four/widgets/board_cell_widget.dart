import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../models/player.dart';
import 'disc_widget.dart';

/// A single hole in the board. Renders the disc at this position (if any),
/// and animates the most recently dropped disc by sliding it down from above.
class BoardCellWidget extends StatelessWidget {
  final int row;
  final int column;
  final int value; // 0 empty, 1 red, 2 yellow
  final bool isWinning;
  final bool isLastMove;
  final double cellSize;

  const BoardCellWidget({super.key, required this.row, required this.column, required this.value, required this.isWinning, required this.isLastMove, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    final holeColor = context.isDark ? AppColors.emptyHoleDark : AppColors.emptyHoleLight;

    final player = Player.fromValue(value);

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsets.all(cellSize * 0.06),
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: holeColor,
              border: Border.all(color: Colors.black.withValues(alpha: 0.12), width: 1.5),
            ),
            child: Center(
              child: player == null
                  ? const SizedBox.shrink()
                  : _DiscDropAnimator(
                      key: ValueKey('disc-$row-$column-${player.value}'),
                      animate: isLastMove,
                      fallDistance: cellSize * (row + 1),
                      child: DiscWidget(player: player, size: cellSize * 0.78, isWinning: isWinning),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animates a disc falling from above into its slot.
class _DiscDropAnimator extends StatefulWidget {
  final Widget child;
  final bool animate;
  final double fallDistance;

  const _DiscDropAnimator({super.key, required this.child, required this.animate, required this.fallDistance});

  @override
  State<_DiscDropAnimator> createState() => _DiscDropAnimatorState();
}

class _DiscDropAnimatorState extends State<_DiscDropAnimator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: GameConstants.dropDuration);

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.bounceOut.transform(_controller.value);
        final dy = (1 - t) * -widget.fallDistance;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}
