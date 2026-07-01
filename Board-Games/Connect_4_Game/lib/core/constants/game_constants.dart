/// Core gameplay constants for Four in a Row.
class GameConstants {
  GameConstants._();

  static const int rows = 6;
  static const int columns = 7;
  static const int winStreak = 4;

  // Cell states
  static const int empty = 0;
  static const int playerRed = 1;
  static const int playerYellow = 2;

  // Animation durations
  static const Duration dropDuration = Duration(milliseconds: 420);
  static const Duration winPulseDuration = Duration(milliseconds: 900);
  static const Duration turnSwitchDuration = Duration(milliseconds: 200);
  static const Duration buttonTapDuration = Duration(milliseconds: 120);
}
