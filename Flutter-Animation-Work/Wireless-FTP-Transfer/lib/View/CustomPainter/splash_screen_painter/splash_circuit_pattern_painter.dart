import 'package:animations_app/Export/export.dart';
import 'dart:math' as math;

class CircuitPatternPainter extends CustomPainter {
  final Color color;
  final double progress;

  CircuitPatternPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) / 2;

    // Draw circuit pattern
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + progress * 2 * math.pi;
      final startX = centerX + math.cos(angle) * radius * 0.5;
      final startY = centerY + math.sin(angle) * radius * 0.5;
      final endX = centerX + math.cos(angle) * radius;
      final endY = centerY + math.sin(angle) * radius;

      final path = Path()
        ..moveTo(startX, startY)
        ..lineTo(endX, endY);

      // Add connecting lines
      if (i % 2 == 0) {
        final nextAngle = ((i + 1) / 8) * 2 * math.pi + progress * 2 * math.pi;
        final nextX = centerX + math.cos(nextAngle) * radius;
        final nextY = centerY + math.sin(nextAngle) * radius;
        path.lineTo(nextX, nextY);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CircuitPatternPainter oldDelegate) =>
      color != oldDelegate.color || progress != oldDelegate.progress;
}
