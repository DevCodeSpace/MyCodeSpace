import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/game_button.dart';
import '../models/player.dart';
import '../providers/game_controller.dart';

class WinnerDialog extends ConsumerWidget {
  final Player? winner;
  final bool isDraw;
  final VoidCallback onMainMenu;

  const WinnerDialog({
    super.key,
    required this.winner,
    required this.isDraw,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title;
    final Color color;

    if (winner != null) {
      title = "${winner!.label} Wins!";
      color = winner!.color;
    } else if (isDraw) {
      title = AppStrings.draw;
      color = Colors.grey;
    } else {
      title = "Game Over";
      color = Colors.white;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 20),

            GameButton(
              label: "Play Again",
              icon: Icons.replay,
              cornerRadius: 6,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: () {
                Navigator.pop(context);
                ref.read(gameControllerProvider.notifier).resetGame();
              },
            ),

            const SizedBox(height: 10),

            GameButton(
              label: "Main Menu",
              filled: false,
              cornerRadius: 6,
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: () {
                Navigator.pop(context);
                onMainMenu();
              },
            ),
          ],
        ),
      ),
    );
  }
}
