import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player.dart';
import '../models/score.dart';

/// Tracks running score across multiple games.
class ScoreNotifier extends Notifier<Score> {
  @override
  Score build() => const Score();

  void addWin(Player winner) {
    state = winner == Player.red ? state.copyWith(red: state.red + 1) : state.copyWith(yellow: state.yellow + 1);
  }

  void addDraw() => state = state.copyWith(draws: state.draws + 1);

  void reset() => state = const Score();
}

final scoreProvider = NotifierProvider<ScoreNotifier, Score>(ScoreNotifier.new);
