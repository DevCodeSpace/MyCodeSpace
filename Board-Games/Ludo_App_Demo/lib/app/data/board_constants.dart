import 'package:flutter/material.dart';
import 'package:ludo_app/app/data/models/ludo_models.dart';

class BoardConstants {
  static const int gridSize = 15;

  // Safe spots in (x, y) coordinates
  static const List<Offset> safeSpots = [Offset(1, 6), Offset(2, 8), Offset(6, 13), Offset(8, 12), Offset(13, 8), Offset(12, 6), Offset(8, 1), Offset(6, 2)];

  // Starting positions for each color in the path
  // These are indexes in the common path
  static const Map<LudoColor, int> startIndexes = {LudoColor.red: 0, LudoColor.green: 13, LudoColor.yellow: 26, LudoColor.blue: 39};

  // The common path (52 steps)
  static final List<Offset> commonPath = [
    // Red starts at (1, 6)
    const Offset(1, 6), const Offset(2, 6), const Offset(3, 6), const Offset(4, 6), const Offset(5, 6),
    const Offset(6, 5), const Offset(6, 4), const Offset(6, 3), const Offset(6, 2), const Offset(6, 1), const Offset(6, 0),
    const Offset(7, 0), const Offset(8, 0),
    const Offset(8, 1), const Offset(8, 2), const Offset(8, 3), const Offset(8, 4), const Offset(8, 5),
    const Offset(9, 6), const Offset(10, 6), const Offset(11, 6), const Offset(12, 6), const Offset(13, 6), const Offset(14, 6),
    const Offset(14, 7), const Offset(14, 8),
    const Offset(13, 8), const Offset(12, 8), const Offset(11, 8), const Offset(10, 8), const Offset(9, 8),
    const Offset(8, 9), const Offset(8, 10), const Offset(8, 11), const Offset(8, 12), const Offset(8, 13), const Offset(8, 14),
    const Offset(7, 14), const Offset(6, 14),
    const Offset(6, 13), const Offset(6, 12), const Offset(6, 11), const Offset(6, 10), const Offset(6, 9),
    const Offset(5, 8), const Offset(4, 8), const Offset(3, 8), const Offset(2, 8), const Offset(1, 8), const Offset(0, 8),
    const Offset(0, 7), const Offset(0, 6),
  ];

  // Home paths for each color
  static final Map<LudoColor, List<Offset>> homePaths = {
    LudoColor.red: [const Offset(1, 7), const Offset(2, 7), const Offset(3, 7), const Offset(4, 7), const Offset(5, 7), const Offset(6, 7)],
    LudoColor.green: [const Offset(7, 1), const Offset(7, 2), const Offset(7, 3), const Offset(7, 4), const Offset(7, 5), const Offset(7, 6)],
    LudoColor.yellow: [const Offset(13, 7), const Offset(12, 7), const Offset(11, 7), const Offset(10, 7), const Offset(9, 7), const Offset(8, 7)],
    LudoColor.blue: [const Offset(7, 13), const Offset(7, 12), const Offset(7, 11), const Offset(7, 10), const Offset(7, 9), const Offset(7, 8)],
  };

  // Base positions for each color (where tokens start)
  static final Map<LudoColor, List<Offset>> basePositions = {
    LudoColor.red: [const Offset(1.5, 1.5), const Offset(4.5, 1.5), const Offset(1.5, 4.5), const Offset(4.5, 4.5)],
    LudoColor.green: [const Offset(10.5, 1.5), const Offset(13.5, 1.5), const Offset(10.5, 4.5), const Offset(13.5, 4.5)],
    LudoColor.yellow: [const Offset(10.5, 10.5), const Offset(13.5, 10.5), const Offset(10.5, 13.5), const Offset(13.5, 13.5)],
    LudoColor.blue: [const Offset(1.5, 10.5), const Offset(4.5, 10.5), const Offset(1.5, 13.5), const Offset(4.5, 13.5)],
  };

  // Final positions in the home center triangles
  static final Map<LudoColor, List<Offset>> homeFinishPositions = {
    LudoColor.red: [const Offset(6.7, 7.2), const Offset(6.7, 7.8), const Offset(7.1, 7.2), const Offset(7.1, 7.8)],
    LudoColor.green: [const Offset(7.2, 6.7), const Offset(7.8, 6.7), const Offset(7.2, 7.1), const Offset(7.8, 7.1)],
    LudoColor.yellow: [const Offset(8.3, 7.2), const Offset(8.3, 7.8), const Offset(7.9, 7.2), const Offset(7.9, 7.8)],
    LudoColor.blue: [const Offset(7.2, 8.3), const Offset(7.8, 8.3), const Offset(7.2, 7.9), const Offset(7.8, 7.9)],
  };
}
