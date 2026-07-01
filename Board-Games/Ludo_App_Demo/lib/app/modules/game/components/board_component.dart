import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ludo_app/app/data/board_constants.dart';
import 'package:ludo_app/app/data/models/ludo_models.dart';
import '../ludo_game.dart';

class BoardComponent extends PositionComponent with HasGameReference<LudoGame> {
  @override
  Future<void> onLoad() async {
    size = game.size;
  }

  @override
  void render(Canvas canvas) {
    final cellSize = size.x / 15;

    // 1. Draw Background with subtle wooden texture
    _drawPremiumBackground(canvas);

    // 2. Draw Grid and Colored Areas
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        Rect rect = Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize);

        // Determine color
        Color? cellColor = _getCellColor(i, j);
        if (cellColor != null) {
          _drawGradientCell(canvas, rect, cellColor, i, j);
        } else {
          // Empty cell border
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(2)),
            Paint()
              ..color = Colors.black.withValues(alpha: 0.1)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
          );
        }

        // Draw Safe Icons
        if (BoardConstants.safeSpots.contains(Offset(i.toDouble(), j.toDouble()))) {
          _drawStar(canvas, rect.center, cellSize * 0.3, Colors.amber);
        }
      }
    }

    // 3. Draw Bases (Large squares)
    _drawPremiumBase(canvas, 0, 0, 6, 6, const Color(0xFFFF3D3D));
    _drawPremiumBase(canvas, 9, 0, 15, 6, const Color(0xFF2ECC71));
    _drawPremiumBase(canvas, 9, 9, 15, 15, const Color(0xFFFFD93D));
    _drawPremiumBase(canvas, 0, 9, 6, 15, const Color(0xFF3498DB));

    // 4. Draw Home (Center)
    _drawPremiumHomeCenter(canvas, cellSize);
  }

  void _drawPremiumBackground(Canvas canvas) {
    // Solid base
    // canvas.drawRect(size.toRect() , Paint()..color = Colors.white); // Old Lace / Parchment

    // // Subtle grain/texture
    // final paint = Paint()
    //   ..color = Colors.white.withValues(alpha: 0.05)
    //   ..strokeWidth = 1;

    // for (double i = 0; i < size.x; i += 4) {
    //   canvas.drawLine(Offset(i, 0), Offset(i, size.y), paint);
    // }
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        size.toRect(),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ),
      Paint()..color = Colors.white,
    );
  }

  void _drawGradientCell(Canvas canvas, Rect rect, Color color, int i, int j) {
    final gradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: 0.8), color]);

    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(2)), Paint()..shader = gradient.createShader(rect));

    // Inner highlight
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(4), const Radius.circular(2)), Paint()..color = Colors.white.withValues(alpha: 0.2));
  }

  Color? _getCellColor(int i, int j) {
    // Red Home Path
    if (j == 7 && i > 0 && i < 6) return const Color(0xFFFF3D3D);
    if (i == 1 && j == 6) return const Color(0xFFFF3D3D); // Red Start

    // Green Home Path
    if (i == 7 && j > 0 && j < 6) return const Color(0xFF2ECC71);
    if (i == 8 && j == 1) return const Color(0xFF2ECC71); // Green Start

    // Yellow Home Path
    if (j == 7 && i > 8 && i < 14) return const Color(0xFFFFD93D);
    if (i == 13 && j == 8) return const Color(0xFFFFD93D); // Yellow Start

    // Blue Home Path
    if (i == 7 && j > 8 && j < 14) return const Color(0xFF3498DB);
    if (i == 6 && j == 13) return const Color(0xFF3498DB); // Blue Start

    return null;
  }

  void _drawPremiumBase(Canvas canvas, int x1, int y1, int x2, int y2, Color color) {
    final cellSize = size.x / 15;
    Rect rect = Rect.fromLTWH(x1 * cellSize, y1 * cellSize, (x2 - x1) * cellSize, (y2 - y1) * cellSize);

    // Outer border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(12)),
      Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );

    // Inner area
    Rect innerRect = rect.deflate(cellSize * 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(8)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.1)],
        ).createShader(innerRect),
    );

    // Draw 4 token slots
    final centers = [
      Offset((x1 + 1.5) * cellSize, (y1 + 1.5) * cellSize),
      Offset((x2 - 1.5) * cellSize, (y1 + 1.5) * cellSize),
      Offset((x1 + 1.5) * cellSize, (y2 - 1.5) * cellSize),
      Offset((x2 - 1.5) * cellSize, (y2 - 1.5) * cellSize),
    ];

    for (var center in centers) {
      // Slot shadow
      canvas.drawCircle(center.translate(0, 2), cellSize * 0.7, Paint()..color = Colors.black.withValues(alpha: 0.1));
      // Slot base
      canvas.drawCircle(center, cellSize * 0.7, Paint()..color = Colors.white);
      // Slot inner border
      canvas.drawCircle(
        center,
        cellSize * 0.6,
        Paint()
          ..color = color.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawPremiumHomeCenter(Canvas canvas, double cellSize) {
    final center = Offset(7.5 * cellSize, 7.5 * cellSize);

    // Red -> Left
    _drawHomeTriangle(canvas, cellSize, LudoColor.red, [Offset(6 * cellSize, 6 * cellSize), Offset(6 * cellSize, 9 * cellSize), center]);
    // Green -> Top
    _drawHomeTriangle(canvas, cellSize, LudoColor.green, [Offset(6 * cellSize, 6 * cellSize), Offset(9 * cellSize, 6 * cellSize), center]);
    // Yellow -> Right
    _drawHomeTriangle(canvas, cellSize, LudoColor.yellow, [Offset(9 * cellSize, 6 * cellSize), Offset(9 * cellSize, 9 * cellSize), center]);
    // Blue -> Bottom
    _drawHomeTriangle(canvas, cellSize, LudoColor.blue, [Offset(9 * cellSize, 9 * cellSize), Offset(6 * cellSize, 9 * cellSize), center]);

    // Draw center crown or circle
    canvas.drawCircle(center, cellSize * 0.5, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      cellSize * 0.5,
      Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _drawStar(canvas, center, cellSize * 0.3, Colors.amber);
  }

  void _drawHomeTriangle(Canvas canvas, double cellSize, LudoColor ludoColor, List<Offset> points) {
    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..close();

    Color color = _getLudoColor(ludoColor);

    final rect = path.getBounds();
    canvas.drawPath(path, Paint()..shader = RadialGradient(colors: [color, color.withValues(alpha: 0.7)]).createShader(rect));

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  Color _getLudoColor(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return const Color(0xFFFF3D3D);
      case LudoColor.green:
        return const Color(0xFF2ECC71);
      case LudoColor.yellow:
        return const Color(0xFFFFD93D);
      case LudoColor.blue:
        return const Color(0xFF3498DB);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final double innerRadius = radius / 2.5;
    double rot = math.pi / 2 * 3;
    final double step = math.pi / 5;

    final starPath = Path()..moveTo(center.dx, center.dy - radius);
    for (int i = 0; i < 5; i++) {
      double x = center.dx + math.cos(rot) * radius;
      double y = center.dy + math.sin(rot) * radius;
      starPath.lineTo(x, y);
      rot += step;

      x = center.dx + math.cos(rot) * innerRadius;
      y = center.dy + math.sin(rot) * innerRadius;
      starPath.lineTo(x, y);
      rot += step;
    }
    starPath.lineTo(center.dx, center.dy - radius);
    starPath.close();

    canvas.drawPath(starPath, Paint()..color = color);
    canvas.drawPath(
      starPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
