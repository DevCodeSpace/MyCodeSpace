import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tile_model.dart';

class GameController extends ChangeNotifier {
  int gridSize;
  List<TileModel> tiles = [];
  final List<int> _mergeTracker = [];
  int score = 0;
  int bestScore = 0;
  GameStatus status = GameStatus.playing;
  int _idCounter = 0;
  final List<_GameSnapshot> _history = [];
  final Random _rng = Random();

  GameController({this.gridSize = 4}) {
    _loadBestScore();
    newGame();
  }

  // ── Public API ──────────────────────────────────────────────

  void newGame() {
    tiles = [];
    score = 0;
    status = GameStatus.playing;
    _history.clear();
    _spawnTile();
    _spawnTile();
    notifyListeners();
  }

  void changeGridSize(int size) {
    gridSize = size;
    newGame();
  }

  void undo() {
    if (_history.isEmpty) return;
    final snap = _history.removeLast();
    tiles = snap.tiles;
    score = snap.score;
    status = GameStatus.playing;
    _history.clear(); // one undo per move — cleared after use
    notifyListeners();
  }

  bool move(SwipeDirection dir) {
    _mergeTracker.clear();
    _clearTransientFlags();
    _saveSnapshot();
    final moved = _applyMove(dir);
    if (!moved) {
      _history.removeLast();
      return false;
    }
    _spawnTile();
    _checkGameOver();
    if (score > bestScore) {
      bestScore = score;
      _saveBestScore();
    }
    notifyListeners();
    return true;
  }

  // ── Board helpers ────────────────────────────────────────────

  List<List<int>> get _grid {
    final g = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    for (final t in tiles) {
      g[t.row][t.col] = t.value;
    }
    return g;
  }

  TileModel? tileAt(int row, int col) {
    try {
      return tiles.firstWhere((t) => t.row == row && t.col == col);
    } catch (_) {
      return null;
    }
  }

  // ── Internal move engine ─────────────────────────────────────

  bool _applyMove(SwipeDirection dir) {
    bool moved = false;
    final newTiles = <TileModel>[];

    for (int line = 0; line < gridSize; line++) {
      final sourceTiles = _lineTiles(dir, line);
      final compact = sourceTiles.whereType<TileModel>().toList();

      int targetIndex = 0;
      int i = 0;
      while (i < compact.length) {
        final current = compact[i];

        if (i + 1 < compact.length && current.value == compact[i + 1].value) {
          final mergedValue = current.value * 2;
          score += mergedValue;
          _mergeTracker.add(mergedValue);

          if (mergedValue == 2048 && status == GameStatus.playing) {
            status = GameStatus.won;
          }

          final position = _linePosition(dir, line, targetIndex);
          final mergedTile = current.copyWith(
            value: mergedValue,
            row: position.$1,
            col: position.$2,
            isNew: false,
            isMerged: true,
          );

          if (mergedTile.row != current.row ||
              mergedTile.col != current.col ||
              mergedTile.value != current.value) {
            moved = true;
          }

          newTiles.add(mergedTile);
          targetIndex++;
          i += 2;
          continue;
        }

        final position = _linePosition(dir, line, targetIndex);
        final movedTile = current.copyWith(
          row: position.$1,
          col: position.$2,
          isNew: false,
          isMerged: false,
        );

        if (movedTile.row != current.row || movedTile.col != current.col) {
          moved = true;
        }

        newTiles.add(movedTile);
        targetIndex++;
        i++;
      }
    }

    tiles = newTiles;
    return moved;
  }

  void _spawnTile() {
    final empty = <_Cell>[];
    final grid = _grid;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == 0) empty.add(_Cell(r, c));
      }
    }
    if (empty.isEmpty) return;
    final cell = empty[_rng.nextInt(empty.length)];
    tiles.add(
      TileModel(
        id: _nextId(),
        value: _rng.nextInt(10) < 9 ? 2 : 4,
        row: cell.row,
        col: cell.col,
        isNew: true,
      ),
    );
  }

  void _checkGameOver() {
    if (status != GameStatus.playing) return;
    final grid = _grid;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == 0) return;
        if (c + 1 < gridSize && grid[r][c] == grid[r][c + 1]) return;
        if (r + 1 < gridSize && grid[r][c] == grid[r + 1][c]) return;
      }
    }
    status = GameStatus.over;
  }

  void _clearTransientFlags() {
    for (final t in tiles) {
      t.isNew = false;
      t.isMerged = false;
    }
  }

  List<TileModel?> _lineTiles(SwipeDirection dir, int line) {
    return List.generate(gridSize, (index) {
      final position = _linePosition(dir, line, index);
      return tileAt(position.$1, position.$2);
    });
  }

  (int, int) _linePosition(SwipeDirection dir, int line, int index) {
    return switch (dir) {
      SwipeDirection.left => (line, index),
      SwipeDirection.right => (line, gridSize - 1 - index),
      SwipeDirection.up => (index, line),
      SwipeDirection.down => (gridSize - 1 - index, line),
    };
  }

  void _saveSnapshot() {
    _history.add(
      _GameSnapshot(
        tiles: tiles
            .map(
              (t) =>
                  TileModel(id: t.id, value: t.value, row: t.row, col: t.col),
            )
            .toList(),
        score: score,
      ),
    );
    if (_history.length > 10) _history.removeAt(0);
  }

  int _nextId() => _idCounter++;

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('best_score_$gridSize') ?? 0;
    notifyListeners();
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score_$gridSize', bestScore);
  }
}

class _Cell {
  final int row, col;
  _Cell(this.row, this.col);
}

class _GameSnapshot {
  final List<TileModel> tiles;
  final int score;
  _GameSnapshot({required this.tiles, required this.score});
}
