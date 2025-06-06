// Enhanced CustomPainter classes
import 'package:animations_app/Export/export.dart';

import 'dart:math' as math;

class CircuitPatternPainter extends CustomPainter {
  final Paint _paint;
  final double progress;

  CircuitPatternPainter({required Color color, required this.progress})
      : _paint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + progress * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final controlX =
            center.dx + radius * 1.2 * math.cos(angle - math.pi / 16);
        final controlY =
            center.dy + radius * 1.2 * math.sin(angle - math.pi / 16);
        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CircuitPatternPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
