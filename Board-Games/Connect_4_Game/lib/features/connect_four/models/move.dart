import 'player.dart';

/// A single recorded move - used for undo and replay.
class Move {
  final int row;
  final int column;
  final Player player;

  const Move({required this.row, required this.column, required this.player});

  @override
  String toString() => 'Move(${player.label} -> [$row,$column])';
}
