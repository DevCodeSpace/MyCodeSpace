import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tile_model.dart';
import '../theme/app_theme.dart';

class GameOverlay extends StatelessWidget {
  final GameStatus status;
  final VoidCallback onRestart;
  final VoidCallback onContinue;

  const GameOverlay({
    super.key,
    required this.status,
    required this.onRestart,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    if (status == GameStatus.playing) return const SizedBox.shrink();

    final isWon = status == GameStatus.won;
    final overlayColor = isWon
        ? AppColors.accentAlt.withValues(alpha: 0.92)
        : AppColors.textDark.withValues(alpha: 0.88);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: Container(
        decoration: BoxDecoration(
          color: overlayColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isWon
                ? AppColors.borderSelected
                : AppColors.borderColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWon ? '🎉 You Won!' : 'Game Over',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: isWon ? AppColors.textDark : Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isWon ? 'Brilliant!' : 'No more moves',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isWon
                    ? AppColors.textDark.withValues(alpha: 0.7)
                    : Colors.white70,
              ),
            ),
            const SizedBox(height: 28),
            if (isWon)
              _OverlayBtn(
                label: 'Keep Going',
                outlined: true,
                isWon: true,
                onTap: onContinue,
              ),
            const SizedBox(height: 10),
            _OverlayBtn(
              label: 'New Game',
              outlined: false,
              isWon: isWon,
              onTap: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayBtn extends StatelessWidget {
  final String label;
  final bool outlined;
  final bool isWon;
  final VoidCallback onTap;
  const _OverlayBtn({
    required this.label,
    required this.onTap,
    required this.isWon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final solidBg    = isWon ? AppColors.textDark : Colors.white;
    final solidText  = isWon ? Colors.white : AppColors.textDark;
    final outlineBorder = isWon ? AppColors.textDark : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 13),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : solidBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: outlined ? outlineBorder : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: outlined ? outlineBorder : solidText,
          ),
        ),
      ),
    );
  }
}
