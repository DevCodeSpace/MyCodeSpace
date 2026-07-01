import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../models/player.dart';
import '../providers/score_provider.dart';
import 'disc_widget.dart';

/// Compact scoreboard - Red wins, Draws, Yellow wins.
class ScoreboardWidget extends ConsumerWidget {
  const ScoreboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ScoreItem(
            leading: const DiscWidget(player: Player.red, size: 22),
            value: score.red,
          ),
          const SizedBox(width: 16),
          _ScoreItem(
            leading: Text(
              'Draws',
              style: context.textStyles.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            value: score.draws,
          ),
          const SizedBox(width: 16),
          _ScoreItem(
            leading: const DiscWidget(player: Player.yellow, size: 22),
            value: score.yellow,
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final Widget leading;
  final int value;

  const _ScoreItem({required this.leading, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        const SizedBox(width: 8),
        Text(
          '$value',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
