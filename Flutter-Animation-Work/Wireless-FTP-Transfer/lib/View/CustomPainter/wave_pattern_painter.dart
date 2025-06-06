import 'package:animations_app/Export/export.dart';
import 'dart:math' as math;

class WavePatternPainter extends CustomPainter {
  final Paint _paint;
  final double progress;

  WavePatternPainter({required Color color, required this.progress})
      : _paint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const waveHeight = 20.0;
    final frequency = 2 * math.pi / size.width;

    for (var i = 0; i < 3; i++) {
      path.reset();
      final phase = progress * 2 * math.pi + (i * math.pi / 3);

      path.moveTo(0, size.height / 2);
      for (var x = 0.0; x <= size.width; x++) {
        final y = size.height / 2 +
            math.sin(x * frequency + phase) * waveHeight * (1 - i * 0.2);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, _paint);
    }
  }

  @override
  bool shouldRepaint(WavePatternPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
