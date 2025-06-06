import 'package:animations_app/Export/export.dart';
import 'dart:math' as math;

class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color color;

  WavePainter({required this.waveAnimation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final height = size.height;
    final width = size.width;
    final waveHeight = height * 0.1;

    path.moveTo(0, height * 0.8);
    for (double i = 0; i < width; i++) {
      path.lineTo(
        i,
        height * 0.8 +
            math.sin(i / 50 + waveAnimation) * waveHeight +
            math.cos(i / 30 + waveAnimation) * waveHeight * 0.5,
      );
    }
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
