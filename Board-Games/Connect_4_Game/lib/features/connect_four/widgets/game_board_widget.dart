import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/game_controller.dart';
import 'board_cell_widget.dart';

class GameBoardWidget extends ConsumerStatefulWidget {
  const GameBoardWidget({super.key});

  @override
  ConsumerState<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends ConsumerState<GameBoardWidget> {
  int? _hoveredCol;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider);
    final lastMove = ref.watch(lastMoveProvider);
    final winning = ref.watch(winningCellsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = GameConstants.columns;
        const rows = GameConstants.rows;
        const aspect = cols / rows;

        double boardWidth = constraints.maxWidth;
        double boardHeight = boardWidth / aspect;

        if (boardHeight > constraints.maxHeight) {
          boardHeight = constraints.maxHeight;
          boardWidth = boardHeight * aspect;
        }

        final cellSize = boardWidth / cols;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔥 GAME TITLE
            Text(
              "CONNECT 4",
              style: context.textStyles.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            /// 🔥 CARROM FRAME
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7B4F2A), // wood
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.boardBlue,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
                child: SizedBox(
                  width: boardWidth,
                  height: boardHeight,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(cellSize * 0.05),
                        child: Column(
                          children: List.generate(rows, (r) {
                            return Expanded(
                              child: Row(
                                children: List.generate(cols, (c) {
                                  final isWinning = winning.any(
                                      (pair) =>
                                          pair[0] == r &&
                                          pair[1] == c);

                                  final isLast = lastMove != null &&
                                      lastMove.row == r &&
                                      lastMove.column == c;

                                  return Expanded(
                                    child: BoardCellWidget(
                                      row: r,
                                      column: c,
                                      value: state.board[r][c],
                                      isWinning: isWinning,
                                      isLastMove: isLast,
                                      cellSize: cellSize,
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ),

                      /// TAP + HOVER
                      Row(
                        children: List.generate(cols, (c) {
                          return Expanded(
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _hoveredCol = c),
                              onExit: (_) =>
                                  setState(() => _hoveredCol = null),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: state.isGameOver
                                    ? null
                                    : () => ref
                                        .read(gameControllerProvider
                                            .notifier)
                                        .dropDisc(c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  color: _hoveredCol == c
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}