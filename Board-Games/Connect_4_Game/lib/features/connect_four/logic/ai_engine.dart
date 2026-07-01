import 'dart:math';

import '../../../core/constants/game_constants.dart';
import '../../../core/utils/board_utils.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import 'win_checker.dart';

/// Deterministic AI opponent. Strategy varies by [AIDifficulty].
class AIEngine {
  final AIDifficulty difficulty;
  final Random _random;

  AIEngine(this.difficulty, {Random? random}) : _random = random ?? Random();

  /// Returns the chosen column. Returns -1 if no legal moves.
  int chooseColumn(List<List<int>> board, Player aiPlayer) {
    final legalCols = _legalColumns(board);
    if (legalCols.isEmpty) return -1;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _easy(board, aiPlayer, legalCols);
      case AIDifficulty.medium:
        return _medium(board, aiPlayer, legalCols);
      case AIDifficulty.hard:
        return _hard(board, aiPlayer);
    }
  }

  // Easy: any random legal move.
  int _easy(List<List<int>> board, Player ai, List<int> legal) {
    return legal[_random.nextInt(legal.length)];
  }

  // Medium: take an immediate win, otherwise block opponent's win, else random.
  int _medium(List<List<int>> board, Player ai, List<int> legal) {
    final winNow = _findWinningMove(board, ai.value, legal);
    if (winNow != null) return winNow;

    final blockMove = _findWinningMove(board, ai.opponent.value, legal);
    if (blockMove != null) return blockMove;

    // Slight center preference.
    const center = GameConstants.columns ~/ 2;
    if (legal.contains(center)) return center;

    return legal[_random.nextInt(legal.length)];
  }

  // Hard: shallow minimax with alpha-beta pruning.
  int _hard(List<List<int>> board, Player ai) {
    const depth = 5;
    final result = _minimax(BoardUtils.cloneBoard(board), depth, -1000000, 1000000, true, ai);
    return result.column;
  }

  _MinimaxResult _minimax(List<List<int>> board, int depth, int alpha, int beta, bool maximizing, Player ai) {
    final legal = _legalColumns(board);
    final terminal = _terminalScore(board, ai);

    if (terminal != null) {
      return _MinimaxResult(-1, terminal);
    }
    if (depth == 0 || legal.isEmpty) {
      return _MinimaxResult(-1, _heuristic(board, ai));
    }

    // Order moves: center first for better pruning.
    legal.sort((a, b) => (a - GameConstants.columns ~/ 2).abs() - (b - GameConstants.columns ~/ 2).abs());

    int bestCol = legal.first;
    if (maximizing) {
      int value = -1000000;
      for (final col in legal) {
        final row = BoardUtils.lowestEmptyRow(board, col);
        if (row == -1) continue;
        board[row][col] = ai.value;
        final score = _minimax(board, depth - 1, alpha, beta, false, ai).score;
        board[row][col] = GameConstants.empty;
        if (score > value) {
          value = score;
          bestCol = col;
        }
        if (value > alpha) alpha = value;
        if (alpha >= beta) break;
      }
      return _MinimaxResult(bestCol, value);
    } else {
      int value = 1000000;
      for (final col in legal) {
        final row = BoardUtils.lowestEmptyRow(board, col);
        if (row == -1) continue;
        board[row][col] = ai.opponent.value;
        final score = _minimax(board, depth - 1, alpha, beta, true, ai).score;
        board[row][col] = GameConstants.empty;
        if (score < value) {
          value = score;
          bestCol = col;
        }
        if (value < beta) beta = value;
        if (alpha >= beta) break;
      }
      return _MinimaxResult(bestCol, value);
    }
  }

  /// Returns +inf if AI wins, -inf if opponent wins, 0 for draw, else null.
  int? _terminalScore(List<List<int>> board, Player ai) {
    // Check every cell because we don't track last move here.
    for (int r = 0; r < GameConstants.rows; r++) {
      for (int c = 0; c < GameConstants.columns; c++) {
        if (board[r][c] == GameConstants.empty) continue;
        final result = WinChecker.checkWinner(board, r, c);
        if (result.hasWinner) {
          return board[r][c] == ai.value ? 100000 : -100000;
        }
      }
    }
    if (BoardUtils.isBoardFull(board)) return 0;
    return null;
  }

  /// Heuristic that scores windows of 4 across the board.
  int _heuristic(List<List<int>> board, Player ai) {
    int score = 0;
    final aiVal = ai.value;
    final oppVal = ai.opponent.value;

    // Center column control.
    const center = GameConstants.columns ~/ 2;
    for (int r = 0; r < GameConstants.rows; r++) {
      if (board[r][center] == aiVal) score += 3;
    }

    // Score all 4-cell windows.
    for (int r = 0; r < GameConstants.rows; r++) {
      for (int c = 0; c < GameConstants.columns; c++) {
        // Horizontal
        if (c + 3 < GameConstants.columns) {
          score += _scoreWindow([board[r][c], board[r][c + 1], board[r][c + 2], board[r][c + 3]], aiVal, oppVal);
        }
        // Vertical
        if (r + 3 < GameConstants.rows) {
          score += _scoreWindow([board[r][c], board[r + 1][c], board[r + 2][c], board[r + 3][c]], aiVal, oppVal);
        }
        // Diagonal down-right
        if (r + 3 < GameConstants.rows && c + 3 < GameConstants.columns) {
          score += _scoreWindow([board[r][c], board[r + 1][c + 1], board[r + 2][c + 2], board[r + 3][c + 3]], aiVal, oppVal);
        }
        // Diagonal up-right
        if (r - 3 >= 0 && c + 3 < GameConstants.columns) {
          score += _scoreWindow([board[r][c], board[r - 1][c + 1], board[r - 2][c + 2], board[r - 3][c + 3]], aiVal, oppVal);
        }
      }
    }
    return score;
  }

  int _scoreWindow(List<int> window, int ai, int opp) {
    int aiCount = 0, oppCount = 0, empty = 0;
    for (final v in window) {
      if (v == ai) {
        aiCount++;
      } else if (v == opp) {
        oppCount++;
      } else {
        empty++;
      }
    }
    if (aiCount == 4) return 1000;
    if (aiCount == 3 && empty == 1) return 50;
    if (aiCount == 2 && empty == 2) return 10;
    if (oppCount == 3 && empty == 1) return -80;
    if (oppCount == 4) return -1000;
    return 0;
  }

  /// Find a column where [player] would immediately win, else null.
  int? _findWinningMove(List<List<int>> board, int player, List<int> legal) {
    for (final col in legal) {
      final row = BoardUtils.lowestEmptyRow(board, col);
      if (row == -1) continue;
      board[row][col] = player;
      final result = WinChecker.checkWinner(board, row, col);
      board[row][col] = GameConstants.empty;
      if (result.hasWinner) return col;
    }
    return null;
  }

  List<int> _legalColumns(List<List<int>> board) {
    final cols = <int>[];
    for (int c = 0; c < GameConstants.columns; c++) {
      if (BoardUtils.lowestEmptyRow(board, c) != -1) cols.add(c);
    }
    return cols;
  }
}

class _MinimaxResult {
  final int column;
  final int score;
  const _MinimaxResult(this.column, this.score);
}
