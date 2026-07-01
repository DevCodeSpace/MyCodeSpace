import '../../../core/utils/board_utils.dart';
import 'move.dart';
import 'player.dart';

/// Immutable snapshot of the game.
class GameState {
  final List<List<int>> board;
  final Player currentPlayer;
  final Player? winner;
  final bool isDraw;
  final int moveCount;
  final List<Move> history;
  final List<List<int>> winningCells; // list of [row,col] pairs
  final Move? lastMove;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.winner,
    required this.isDraw,
    required this.moveCount,
    required this.history,
    required this.winningCells,
    required this.lastMove,
  });

  bool get isGameOver => winner != null || isDraw;

  factory GameState.initial() {
    return GameState(
      board: BoardUtils.createEmptyBoard(),
      currentPlayer: Player.red,
      winner: null,
      isDraw: false,
      moveCount: 0,
      history: const [],
      winningCells: const [],
      lastMove: null,
    );
  }

  GameState copyWith({
    List<List<int>>? board,
    Player? currentPlayer,
    Player? winner,
    bool clearWinner = false,
    bool? isDraw,
    int? moveCount,
    List<Move>? history,
    List<List<int>>? winningCells,
    Move? lastMove,
    bool clearLastMove = false,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: clearWinner ? null : (winner ?? this.winner),
      isDraw: isDraw ?? this.isDraw,
      moveCount: moveCount ?? this.moveCount,
      history: history ?? this.history,
      winningCells: winningCells ?? this.winningCells,
      lastMove: clearLastMove ? null : (lastMove ?? this.lastMove),
    );
  }
}
