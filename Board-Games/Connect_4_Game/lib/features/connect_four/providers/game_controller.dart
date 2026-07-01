import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/utils/board_utils.dart';
import '../logic/ai_engine.dart';
import '../logic/win_checker.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../models/move.dart';
import '../models/player.dart';
import 'score_provider.dart';
import 'settings_provider.dart';

// Top-level so compute() can spawn it in a background isolate.
// Pure Dart — no Flutter platform channels required.
int _runAI(
    ({List<List<int>> board, String difficulty, int playerValue}) params) {
  final difficulty =
      AIDifficulty.values.firstWhere((d) => d.name == params.difficulty);
  final player = Player.fromValue(params.playerValue)!;
  return AIEngine(difficulty).chooseColumn(params.board, player);
}

/// Central game state controller. Holds the immutable [GameState] and exposes
/// imperative actions (drop, undo, reset). Schedules AI moves when in vsAI.
class GameController extends Notifier<GameState> {
  Timer? _aiTimer;

  @override
  GameState build() {
    ref.onDispose(() => _aiTimer?.cancel());
    return GameState.initial();
  }

  /// Drop a disc into [column] for the current player.
  /// Returns true if the move was accepted.
  bool dropDisc(int column) {
    if (state.isGameOver) return false;
    if (column < 0 || column >= GameConstants.columns) return false;

    final row = BoardUtils.lowestEmptyRow(state.board, column);
    if (row == -1) return false;

    final newBoard = BoardUtils.cloneBoard(state.board);
    final player = state.currentPlayer;
    newBoard[row][column] = player.value;

    final move = Move(row: row, column: column, player: player);
    final newHistory = List<Move>.from(state.history)..add(move);

    final winResult = WinChecker.checkWinner(newBoard, row, column);
    final draw = !winResult.hasWinner && BoardUtils.isBoardFull(newBoard);

    state = state.copyWith(
      board: newBoard,
      history: newHistory,
      moveCount: state.moveCount + 1,
      lastMove: move,
      currentPlayer: winResult.hasWinner || draw ? player : player.opponent,
      winner: winResult.hasWinner ? player : null,
      isDraw: draw,
      winningCells: winResult.hasWinner ? winResult.winningCells : const [],
    );

    if (state.isGameOver) {
      _recordScore();
    } else {
      _maybeTriggerAI();
    }
    return true;
  }

  /// Undoes the last move. In vsAI mode undoes both AI + human moves together.
  void undoMove() {
    if (state.history.isEmpty) return;

    final settings = ref.read(settingsProvider);
    final undoCount =
        (settings.mode == GameMode.vsAI && state.history.length >= 2 && !state.isGameOver)
            ? 2
            : 1;

    final newHistory = List<Move>.from(state.history);
    final newBoard = BoardUtils.cloneBoard(state.board);

    for (int i = 0; i < undoCount && newHistory.isNotEmpty; i++) {
      final last = newHistory.removeLast();
      newBoard[last.row][last.column] = GameConstants.empty;
    }

    final next =
        newHistory.isEmpty ? Player.red : newHistory.last.player.opponent;

    state = GameState(
      board: newBoard,
      currentPlayer: next,
      winner: null,
      isDraw: false,
      moveCount: newHistory.length,
      history: newHistory,
      winningCells: const [],
      lastMove: newHistory.isEmpty ? null : newHistory.last,
    );
  }

  /// Reset the board, keep the score.
  void resetGame() {
    _aiTimer?.cancel();
    state = GameState.initial();
    _maybeTriggerAI();
  }

  /// Start a brand-new match — resets board and score.
  void newMatch() {
    _aiTimer?.cancel();
    ref.read(scoreProvider.notifier).reset();
    state = GameState.initial();
    _maybeTriggerAI();
  }

  void _recordScore() {
    final scoreNotifier = ref.read(scoreProvider.notifier);
    if (state.winner != null) {
      scoreNotifier.addWin(state.winner!);
    } else if (state.isDraw) {
      scoreNotifier.addDraw();
    }
  }

  /// Schedule the AI move off the main thread via [compute].
  void _maybeTriggerAI() {
    final settings = ref.read(settingsProvider);
    if (settings.mode != GameMode.vsAI) return;
    if (state.isGameOver) return;
    if (state.currentPlayer != Player.yellow) return;

    _aiTimer?.cancel();
    // 280 ms feel-good delay so the human can see the disc they just dropped.
    _aiTimer = Timer(const Duration(milliseconds: 280), () async {
      if (state.isGameOver || state.currentPlayer != Player.yellow) return;

      // Capture a snapshot so the isolate works on stable data.
      final boardSnapshot = BoardUtils.cloneBoard(state.board);
      final col = await compute(
        _runAI,
        (
          board: boardSnapshot,
          difficulty: settings.difficulty.name,
          playerValue: Player.yellow.value,
        ),
      );

      // Re-check after async gap — player may have reset/undone.
      if (state.isGameOver || state.currentPlayer != Player.yellow) return;
      if (col >= 0) dropDisc(col);
    });
  }
}

final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);

/// Selector — current player only. Avoids rebuilds on board changes.
final currentPlayerProvider = Provider<Player>((ref) {
  return ref.watch(gameControllerProvider.select((s) => s.currentPlayer));
});

/// Selector — winning cells only.
final winningCellsProvider = Provider<List<List<int>>>((ref) {
  return ref.watch(gameControllerProvider.select((s) => s.winningCells));
});

/// Selector — last move (used for animating the most recent disc).
final lastMoveProvider = Provider<Move?>((ref) {
  return ref.watch(gameControllerProvider.select((s) => s.lastMove));
});
