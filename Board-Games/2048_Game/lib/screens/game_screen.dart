import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_controller.dart';
import '../models/tile_model.dart';
import '../theme/app_theme.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_overlay.dart';
import '../widgets/score_card_widget.dart';

class GameScreen extends StatefulWidget {
  final int gridSize;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const GameScreen({
    super.key,
    required this.gridSize,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _ctrl;

  // Swipe tracking — one move per gesture
  Offset? _dragStart;
  bool _movedThisGesture = false;
  static const double _swipeThreshold = 30.0;

  @override
  void initState() {
    super.initState();
    _ctrl = GameController(gridSize: widget.gridSize);
    _ctrl.addListener(_onGameChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onGameChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onGameChanged() => setState(() {});

  void _handleSwipe(SwipeDirection dir) {
    HapticFeedback.lightImpact();
    _ctrl.move(dir);
  }

  void _onPanStart(DragStartDetails d) {
    _dragStart = d.localPosition;
    _movedThisGesture = false;
  }

  void _onPanEnd(DragEndDetails d) {
    _dragStart = null;
    _movedThisGesture = false;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    // Block further moves once one has already fired this gesture
    if (_dragStart == null || _movedThisGesture) return;
    final delta = d.localPosition - _dragStart!;
    if (delta.distance < _swipeThreshold) return;

    final dx = delta.dx.abs();
    final dy = delta.dy.abs();

    final SwipeDirection dir;
    if (dx > dy) {
      dir = delta.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      dir = delta.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }

    _movedThisGesture = true; // lock until next gesture
    _handleSwipe(dir);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final screenW = MediaQuery.of(context).size.width;
    final boardSize = (screenW - 48).clamp(200.0, 420.0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              ctrl: _ctrl,
              isDark: isDark,
              onBack: () => Navigator.pop(context),
              onToggleTheme: widget.onToggleTheme,
            ),
            const SizedBox(height: 30),

            ListenableBuilder(
              listenable: _ctrl,
              builder: (context, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center, // center align
                children: [
                  ScoreCardWidget(label: 'SCORE', score: _ctrl.score),
                  const SizedBox(width: 10),
                  ScoreCardWidget(label: 'BEST', score: _ctrl.bestScore),
                ],
              ),
            ),

            // Board area with swipe + overlay
            Expanded(
              child: Center(
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GameBoardWidget(controller: _ctrl, boardSize: boardSize),
                      if (_ctrl.status != GameStatus.playing)
                        SizedBox(
                          width: boardSize,
                          height: boardSize,
                          child: GameOverlay(
                            status: _ctrl.status,
                            onRestart: () => _ctrl.newGame(),
                            onContinue: () {
                              setState(() => _ctrl.status = GameStatus.playing);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: _ActionRow(
                isDark: isDark,
                onUndo: () {
                  HapticFeedback.lightImpact();
                  _ctrl.undo();
                },
                onRestart: () {
                  HapticFeedback.mediumImpact();
                  _ctrl.newGame();
                },
              ),
            ),
            const SizedBox(height: 50),
            _SwipeHint(isDark: isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final GameController ctrl;
  final bool isDark;
  final VoidCallback onBack;
  final VoidCallback onToggleTheme;

  const _Header({
    required this.ctrl,
    required this.isDark,
    required this.onBack,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back button
          _NavBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
            isDark: isDark,
          ),
          const SizedBox(width: 12),

          // Title
          Text(
            '2048',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
            ),
          ),

          const Spacer(),

          // Score cards
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool isDark;
  final VoidCallback onUndo;
  final VoidCallback onRestart;

  const _ActionRow({
    required this.isDark,
    required this.onUndo,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionBtn(
            icon: Icons.undo_rounded,
            label: 'Undo',
            isDark: isDark,
            onTap: onUndo,
          ),
          const SizedBox(width: 12),
          _ActionBtn(
            icon: Icons.refresh_rounded,
            label: 'Restart',
            isDark: isDark,
            onTap: onRestart,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColors.cardShadowDark,
          //     blurRadius: 6,
          //     offset: const Offset(2, 2),
          //   ),
          //   BoxShadow(
          //     color: AppColors.cardShadowLight,
          //     blurRadius: 6,
          //     offset: const Offset(-2, -2),
          //   ),
          // ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _NavBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppColors.cardShadowDark,
          //     blurRadius: 6,
          //     offset: const Offset(2, 2),
          //   ),
          //   BoxShadow(
          //     color: AppColors.cardShadowLight,
          //     blurRadius: 6,
          //     offset: const Offset(-2, -2),
          //   ),
          // ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textDark),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  final bool isDark;
  const _SwipeHint({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.swipe_rounded,
          size: 16,
          color: AppColors.textMuted.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 6),
        Text(
          'Swipe to move tiles',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textMuted.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
