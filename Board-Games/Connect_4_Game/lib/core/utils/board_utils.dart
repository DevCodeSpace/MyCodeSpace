import '../constants/game_constants.dart';

/// Stateless helpers for board manipulation.
class BoardUtils {
  BoardUtils._();

  /// Create an empty board (rows x columns) filled with [GameConstants.empty].
  static List<List<int>> createEmptyBoard() {
    return List.generate(GameConstants.rows, (_) => List.filled(GameConstants.columns, GameConstants.empty));
  }

  /// Deep copy of a 2D matrix so state remains immutable.
  static List<List<int>> cloneBoard(List<List<int>> board) {
    return board.map((row) => List<int>.from(row)).toList();
  }

  /// Returns the lowest empty row index for [column], or -1 if column is full.
  static int lowestEmptyRow(List<List<int>> board, int column) {
    for (int r = GameConstants.rows - 1; r >= 0; r--) {
      if (board[r][column] == GameConstants.empty) return r;
    }
    return -1;
  }

  static bool isBoardFull(List<List<int>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell == GameConstants.empty) return false;
      }
    }
    return true;
  }

  static int opponentOf(int player) => player == GameConstants.playerRed ? GameConstants.playerYellow : GameConstants.playerRed;
}
