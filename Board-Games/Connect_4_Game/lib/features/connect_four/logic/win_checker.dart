import '../../../core/constants/game_constants.dart';

/// Result of a winner check.
class WinResult {
  final bool hasWinner;
  final List<List<int>> winningCells;

  const WinResult.none() : hasWinner = false, winningCells = const [];
  const WinResult.win(this.winningCells) : hasWinner = true;
}

/// Pure win-detection helpers. No state.
class WinChecker {
  WinChecker._();

  static const List<List<int>> _directions = [
    [0, 1], // horizontal
    [1, 0], // vertical
    [1, 1], // diagonal down-right
    [-1, 1], // diagonal up-right
  ];

  /// Detect a win starting from the most recently placed disc at (row, col).
  static WinResult checkWinner(List<List<int>> board, int row, int col) {
    final player = board[row][col];
    if (player == GameConstants.empty) return const WinResult.none();

    for (final dir in _directions) {
      final cells = _collectLine(board, row, col, dir[0], dir[1], player);
      if (cells.length >= GameConstants.winStreak) {
        return WinResult.win(cells.take(GameConstants.winStreak).toList());
      }
    }
    return const WinResult.none();
  }

  /// Collect a contiguous line through (row,col) in [dRow,dCol] direction
  /// (and its inverse) of cells matching [player].
  static List<List<int>> _collectLine(List<List<int>> board, int row, int col, int dRow, int dCol, int player) {
    final cells = <List<int>>[
      [row, col],
    ];

    // Forward direction
    int r = row + dRow, c = col + dCol;
    while (_inBounds(r, c) && board[r][c] == player) {
      cells.add([r, c]);
      r += dRow;
      c += dCol;
    }

    // Backward direction
    r = row - dRow;
    c = col - dCol;
    while (_inBounds(r, c) && board[r][c] == player) {
      cells.insert(0, [r, c]);
      r -= dRow;
      c -= dCol;
    }

    return cells;
  }

  static bool _inBounds(int row, int col) => row >= 0 && row < GameConstants.rows && col >= 0 && col < GameConstants.columns;
}
