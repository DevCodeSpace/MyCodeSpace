class TileModel {
  final int id;
  int value;
  int row;
  int col;
  bool isNew;
  bool isMerged;

  TileModel({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
    this.isMerged = false,
  });

  TileModel copyWith({
    int? value,
    int? row,
    int? col,
    bool? isNew,
    bool? isMerged,
  }) {
    return TileModel(
      id: id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
    );
  }
}

enum SwipeDirection { left, right, up, down }

enum GameStatus { playing, won, over }
