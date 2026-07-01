import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Represents a Connect 4 player.
enum Player {
  red(GameConstants.playerRed, 'Red', AppColors.playerRed, AppColors.playerRedDark),
  yellow(GameConstants.playerYellow, 'Yellow', AppColors.playerYellow, AppColors.playerYellowDark);

  final int value;
  final String label;
  final Color color;
  final Color shadowColor;

  const Player(this.value, this.label, this.color, this.shadowColor);

  Player get opponent => this == Player.red ? Player.yellow : Player.red;

  static Player? fromValue(int value) {
    if (value == GameConstants.playerRed) return Player.red;
    if (value == GameConstants.playerYellow) return Player.yellow;
    return null;
  }
}
