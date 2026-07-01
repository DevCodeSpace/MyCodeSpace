import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/game_button.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../providers/game_controller.dart';
import '../providers/score_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/disc_widget.dart';
import '../widgets/settings_sheet.dart';
import 'game_screen.dart';

/// Landing menu — choose mode and tap Play.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openSettings(BuildContext context) => showModalBottomSheet(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const SettingsSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.homeBgTop, AppColors.homeBgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _LogoBadge(),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.appTitle,
                    textAlign: TextAlign.center,
                    style: context.textStyles.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Drop. Connect. Conquer.',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _ModeCard(
                    title: AppStrings.twoPlayers,
                    subtitle: 'Pass-and-play with a friend',
                    icon: Icons.people_alt_rounded,
                    selected: settings.mode == GameMode.twoPlayers,
                    onTap: () => notifier.setMode(GameMode.twoPlayers),
                  ),
                  const SizedBox(height: 12),
                  _ModeCard(
                    title: AppStrings.singlePlayer,
                    subtitle: 'Challenge the AI',
                    icon: Icons.smart_toy_rounded,
                    selected: settings.mode == GameMode.vsAI,
                    onTap: () => notifier.setMode(GameMode.vsAI),
                  ),
                  if (settings.mode == GameMode.vsAI) ...[
                    const SizedBox(height: 16),
                    _DifficultySelector(current: settings.difficulty),
                  ],
                  const SizedBox(height: 32),
                  // ── Play button: square-ish radius ──────────────────
                  Row(
                    children: [
                      Expanded(
                        child: GameButton(
                          label: 'PLAY',
                          icon: Icons.play_arrow_rounded,
                          cornerRadius: 8,
                          color: const Color(0xFFF59E0B),
                          onPressed: () {
                            ref
                                .read(gameControllerProvider.notifier)
                                .resetGame();
                            ref.read(scoreProvider.notifier).reset();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const GameScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Settings FAB ───────────────────────────────────────────────────────────

class _SettingsFab extends StatefulWidget {
  final VoidCallback onTap;
  const _SettingsFab({required this.onTap});

  @override
  State<_SettingsFab> createState() => _SettingsFabState();
}

class _SettingsFabState extends State<_SettingsFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: _pressed ? 0.7 : 0.4),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.settings_outlined,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

// ─── Logo badge ──────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 18,
            left: 18,
            child: DiscWidget(player: Player.red, size: 36),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: DiscWidget(player: Player.yellow, size: 36),
          ),
          Positioned(
            bottom: 18,
            left: 18,
            child: DiscWidget(player: Player.yellow, size: 36),
          ),
          Positioned(
            bottom: 18,
            right: 18,
            child: DiscWidget(player: Player.red, size: 36),
          ),
        ],
      ),
    );
  }
}

// ─── Mode card ───────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: selected ? 0.22 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: selected ? 0.85 : 0.35),
          width: selected ? 2.0 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.10),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: selected ? 0.25 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.textStyles.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_off_rounded,
                  color: Colors.white.withValues(alpha: selected ? 1.0 : 0.50),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Difficulty selector ──────────────────────────────────────────────────────

class _DifficultySelector extends ConsumerWidget {
  final AIDifficulty current;
  const _DifficultySelector({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: AIDifficulty.values.map((d) {
        final selected = d == current;
        final label = d.name[0].toUpperCase() + d.name.substring(1);
        return GestureDetector(
          onTap: () => ref.read(settingsProvider.notifier).setDifficulty(d),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: selected ? 0.28 : 0.10),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: selected ? 0.9 : 0.35),
                width: selected ? 2.0 : 1.5,
              ),
            ),
            child: Text(
              label,
              style: context.textStyles.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
