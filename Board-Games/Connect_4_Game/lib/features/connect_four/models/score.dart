/// Tracks ongoing match score across rounds.
class Score {
  final int red;
  final int yellow;
  final int draws;

  const Score({this.red = 0, this.yellow = 0, this.draws = 0});

  Score copyWith({int? red, int? yellow, int? draws}) => Score(red: red ?? this.red, yellow: yellow ?? this.yellow, draws: draws ?? this.draws);
}
