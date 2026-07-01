import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../providers/game_controller.dart';
import 'disc_widget.dart';

/// Animated banner showing the current player's turn or end-game state.
class PlayerTurnWidget extends ConsumerWidget {
  const PlayerTurnWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final player = state.currentPlayer;

    final String label;
    final Color accent;
    if (state.winner != null) {
      label = '${state.winner!.label} Wins!';
      accent = state.winner!.color;
    } else if (state.isDraw) {
      label = AppStrings.draw;
      accent = Colors.grey;
    } else {
      label = '${player.label}\'s Turn';
      accent = player.color;
    }

    return AnimatedSwitcher(
      duration: GameConstants.turnSwitchDuration,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.2), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey('$label-${player.value}'),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: accent.withValues(alpha: 0.75), width: 2.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.winner != null) DiscWidget(player: state.winner!, size: 22) else if (!state.isDraw) DiscWidget(player: player, size: 22),
            if (!state.isDraw || state.winner != null) const SizedBox(width: 10),
            Text(
              label,
              style: context.textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
