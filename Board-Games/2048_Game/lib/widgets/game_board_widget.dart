import 'package:flutter/material.dart';

import '../models/game_controller.dart';
import '../theme/app_theme.dart';
import 'tile_widget.dart';

class GameBoardWidget extends StatelessWidget {
  final GameController controller;
  final double boardSize;

  const GameBoardWidget({
    super.key,
    required this.controller,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final n = controller.gridSize;
    const gap = 8.0;
    final tileSize = (boardSize - gap * (n + 1)) / n;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBoard : AppColors.boardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderSelected,
          width: 2,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Empty cells grid
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.zero,
              child: Column(
                children: List.generate(
                  n,
                  (r) => Row(
                    children: List.generate(
                      n,
                      (c) => Container(
                        width: tileSize,
                        height: tileSize,
                        margin: EdgeInsets.only(left: gap, top: gap),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCell
                              : AppColors.cellEmpty,
                          borderRadius: BorderRadius.circular(tileSize * 0.10),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tiles
          ...controller.tiles.map((tile) {
            final left = tile.col * (tileSize + gap) + gap;
            final top = tile.row * (tileSize + gap) + gap;

            return AnimatedPositioned(
              key: ValueKey(tile.id),
              duration: const Duration(milliseconds: 110),
              curve: Curves.easeOutCubic,
              left: left,
              top: top,
              child: TileWidget(tile: tile, size: tileSize),
            );
          }),
        ],
      ),
    );
  }
}
