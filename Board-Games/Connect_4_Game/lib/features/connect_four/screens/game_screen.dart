import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/game_button.dart';
import '../providers/game_controller.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/player_turn_widget.dart';
import '../widgets/scoreboard_widget.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/winner_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(gameControllerProvider, (prev, next) {
      if (next.isGameOver && !_dialogShown) {
        _dialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.6),
            builder: (_) => WinnerDialog(
              winner: next.winner,
              isDraw: next.isDraw,
              onMainMenu: () => Navigator.of(context).maybePop(),
            ),
          ).then((_) => _dialogShown = false);
        });
      } else if (!next.isGameOver) {
        _dialogShown = false;
      }
    });

    final state = ref.watch(gameControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _GradientAppBar(context: context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.homeBgTop, AppColors.homeBgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ✅ HEADER (same feel as home spacing)
              // const PlayerTurnWidget(),
              // const SizedBox(height: 10),
              // const ScoreboardWidget(),
const _TopGameInfoCard(),
              const SizedBox(height: 16),

              // ✅ BOARD
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: RepaintBoundary(child: const GameBoardWidget()),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ CONTROLS (UPDATED)
              _Controls(
                undoEnabled: state.history.isNotEmpty && !state.isGameOver,
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── APP BAR ─────────────────────────────────────────
class _TopGameInfoCard extends StatelessWidget {
  const _TopGameInfoCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: 0.95),

          borderRadius: BorderRadius.circular(18),

          /// 🔥 subtle border (premium feel)
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.15),
            width: 1.5,
          ),

          /// 🔥 soft elevation
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            /// 🎯 TURN
            PlayerTurnWidget(),

            SizedBox(height: 10),

            /// 🎯 SCORE
            ScoreboardWidget(),
          ],
        ),
      ),
    );
  }
}

class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BuildContext context;
  const _GradientAppBar({required this.context});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext ctx) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
  padding: const EdgeInsets.only(left: 10,right: 10,top: 15),
  child: SquareGameButton(
    icon: Icons.arrow_back_rounded,
    color: Colors.white,
    onPressed: () => Navigator.of(context).maybePop(),
  ),
),
      title: Text(
        AppStrings.appTitle,
        style: ctx.textStyles.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => showModalBottomSheet(
            context: ctx,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const SettingsSheet(),
          ),
        ),
      ],
    );
  }
}

// ─── CONTROLS (MAIN CHANGE HERE) ─────────────────────

class _Controls extends ConsumerWidget {
  final bool undoEnabled;
  const _Controls({required this.undoEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gameControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 🔥 ROW: Undo + Reset
          Row(
            children: [
              Expanded(
                child: GameButton(
                  label: AppStrings.undo,
                  icon: Icons.undo_rounded,
                  filled: false,
                  color: Colors.white,
                  cornerRadius: 6,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: undoEnabled ? controller.undoMove : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GameButton(
                  label: AppStrings.reset,
                  icon: Icons.refresh_rounded,
                  color: AppColors.playerRed,
                  cornerRadius: 6,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: controller.resetGame,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔥 SINGLE FULL WIDTH: New Match
          Row(
            children: [
              Expanded(
                child: GameButton(
                  label: AppStrings.newMatch,
                  icon: Icons.restart_alt_rounded,
                  filled: false,
                  color: Colors.white,
                  cornerRadius: 6,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: controller.newMatch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class SquareGameButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool filled;
  final double size;

  const SquareGameButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.filled = false,
    this.size = 44, // 🔥 square size
  });

  @override
  State<SquareGameButton> createState() => _SquareGameButtonState();
}

class _SquareGameButtonState extends State<SquareGameButton> {
  bool _pressed = false;
  static const double _depth = 4;

  Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final alpha = disabled ? 0.45 : 1.0;

    final rawBase = widget.color ?? Colors.white;
    final base = rawBase.withValues(alpha: alpha);
    final dark = _darken(rawBase).withValues(alpha: alpha);

    final fg = widget.filled ? Colors.white : base;

    final gradient = widget.filled
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _pressed
                ? [dark, dark, dark, dark]
                : [base, base, dark, dark],
            stops: const [0.0, 0.8, 0.8, 1.0],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _pressed
                ? [
                    base.withValues(alpha: 0.2),
                    base.withValues(alpha: 0.2),
                    base.withValues(alpha: 0.2),
                    base.withValues(alpha: 0.2),
                  ]
                : [
                    base.withValues(alpha: 0.08),
                    base.withValues(alpha: 0.08),
                    base.withValues(alpha: 0.24),
                    base.withValues(alpha: 0.24),
                  ],
            stops: const [0.0, 0.8, 0.8, 1.0],
          );

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
        width: widget.size,
        height: widget.size,

        padding: EdgeInsets.only(
          top: _pressed ? 8 + _depth : 8,
          bottom: _pressed ? 8 : 8 + _depth,
        ),

        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(6), // 🔥 square sharp
          border: widget.filled ? null : Border.all(color: base, width: 2),
        ),

        child: Center(
          child: Icon(widget.icon, color: fg, size: 20),
        ),
      ),
    );
  }
}