enum GameMode { twoPlayers, vsAI }

enum AIDifficulty { easy, medium, hard }

class GameSettings {
  final bool soundEnabled;
  final bool darkMode;
  final GameMode mode;
  final AIDifficulty difficulty;

  const GameSettings({this.soundEnabled = true, this.darkMode = false, this.mode = GameMode.twoPlayers, this.difficulty = AIDifficulty.medium});

  GameSettings copyWith({bool? soundEnabled, bool? darkMode, GameMode? mode, AIDifficulty? difficulty}) {
    return GameSettings(soundEnabled: soundEnabled ?? this.soundEnabled, darkMode: darkMode ?? this.darkMode, mode: mode ?? this.mode, difficulty: difficulty ?? this.difficulty);
  }
}
