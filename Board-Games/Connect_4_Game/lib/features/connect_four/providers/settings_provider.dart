import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_settings.dart';

/// Holds user-level preferences (theme, sound, mode, AI difficulty).
class SettingsNotifier extends Notifier<GameSettings> {
  @override
  GameSettings build() => const GameSettings();

  void toggleSound() => state = state.copyWith(soundEnabled: !state.soundEnabled);
  void toggleDarkMode() => state = state.copyWith(darkMode: !state.darkMode);
  void setMode(GameMode mode) => state = state.copyWith(mode: mode);
  void setDifficulty(AIDifficulty d) => state = state.copyWith(difficulty: d);
}

final settingsProvider = NotifierProvider<SettingsNotifier, GameSettings>(SettingsNotifier.new);
