import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class GridSizeCard extends StatelessWidget {
  final int size;
  final bool isSelected;
  final VoidCallback onTap;

  const GridSizeCard({
    super.key,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.borderSelected
                : (isDark ? AppColors.darkBorder : AppColors.borderColor),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$size × $size',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? AppColors.textDark
                        : (isDark ? Colors.white : AppColors.textDark),
                  ),
                ),
                Text(
                  _modeLabel(size),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.textDark.withValues(alpha: 0.65)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            _MiniGrid(size: size, isSelected: isSelected, isDark: isDark),
          ],
        ),
      ),
    );
  }

  String _modeLabel(int s) {
    switch (s) {
      case 4:  return 'Classic';
      case 5:  return 'Medium';
      case 6:  return 'Large';
      default: return 'Expert';
    }
  }
}

class _MiniGrid extends StatelessWidget {
  final int size;
  final bool isSelected;
  final bool isDark;
  const _MiniGrid({
    required this.size,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const total = 58.0;
    return Container(
      width: total,
      height: total,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.borderSelected.withValues(alpha: 0.25)
            : (isDark ? AppColors.darkBoard : AppColors.boardBg),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppColors.borderSelected
              : (isDark ? AppColors.darkBorder : AppColors.borderColor),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: List.generate(
          size,
          (r) => Expanded(
            child: Row(
              children: List.generate(
                size,
                (c) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.45)
                          : (isDark ? AppColors.darkCell : AppColors.cellEmpty),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
