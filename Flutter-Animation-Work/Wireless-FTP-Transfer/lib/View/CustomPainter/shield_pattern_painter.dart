import 'package:animations_app/Export/export.dart';
import 'dart:math' as math;

class ShieldPatternPainter extends CustomPainter {
  final Paint _paint;
  final double progress;

  ShieldPatternPainter({required Color color, required this.progress})
      : _paint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    for (var i = 0; i < 3; i++) {
      final scale = 1 - (i * 0.2);
      final path = Path();
      final points = List.generate(6, (index) {
        final angle = (index / 6) * 2 * math.pi + progress * math.pi;
        return Offset(
          center.dx + radius * scale * math.cos(angle),
          center.dy + radius * scale * math.sin(angle),
        );
      });

      path.moveTo(points[0].dx, points[0].dy);
      for (var j = 1; j < points.length; j++) {
        path.lineTo(points[j].dx, points[j].dy);
      }
      path.close();
      canvas.drawPath(path, _paint);
    }
  }

  @override
  bool shouldRepaint(ShieldPatternPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
