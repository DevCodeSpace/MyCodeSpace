import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    hide TextBlock;

/// A single detected text line mapped to screen space.
class DetectedTextBlock {
  final String text;
  final Rect screenRect;

  DetectedTextBlock({
    required this.text,
    required this.screenRect,
  });
}

/// Paints Google Lens style highlights over detected text blocks.
class ScanOverlayPainter extends CustomPainter {
  final List<DetectedTextBlock> blocks;
  final int? selectedIndex;

  const ScanOverlayPainter({
    required this.blocks,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final selected = i == selectedIndex;

      // Lens style highlight: Very subtle white/blue glow
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: selected ? 0.25 : 0.08);

      final rRect = RRect.fromRectAndRadius(
          block.screenRect, const Radius.circular(4));
      
      canvas.drawRRect(rRect, paint);

      if (selected) {
        _drawSelectionHandles(canvas, block.screenRect);
      }
    }
  }

  void _drawSelectionHandles(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = const Color(0xFF4285F4) // Google Blue
      ..style = PaintingStyle.fill;

    const double dotSize = 8.0;
    
    // Draw circles at top-left and bottom-right to simulate selection handles
    canvas.drawCircle(rect.topLeft, dotSize / 2, paint);
    canvas.drawCircle(rect.bottomRight, dotSize / 2, paint);
    
    // Draw a thin border
    final borderPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), borderPaint);
  }

  @override
  bool shouldRepaint(ScanOverlayPainter old) =>
      old.blocks != blocks || 
      old.selectedIndex != selectedIndex;
}

/// Converts ML Kit bounding boxes → screen-space [DetectedTextBlock] list.
List<DetectedTextBlock> buildTextBlocks({
  required RecognizedText recognizedText,
  required Size imageSize,
  required Size widgetSize,
  required InputImageRotation rotation,
}) {
  final result = <DetectedTextBlock>[];
  for (final block in recognizedText.blocks) {
    for (final line in block.lines) {
      result.add(DetectedTextBlock(
        text: line.text,
        screenRect:
            _toScreen(line.boundingBox, imageSize, widgetSize, rotation),
      ));
    }
  }
  return result;
}

Rect _toScreen(
  Rect r,
  Size img,
  Size widget,
  InputImageRotation rot,
) {
  double l, t, right, b;
  switch (rot) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      // ML Kit already returns boxes in display-corrected (portrait) space.
      // Image logical dimensions are swapped relative to the buffer.
      final sx = widget.width / img.height;
      final sy = widget.height / img.width;
      l = r.left * sx;
      t = r.top * sy;
      right = r.right * sx;
      b = r.bottom * sy;
      break;
    case InputImageRotation.rotation180deg:
      final sx = widget.width / img.width;
      final sy = widget.height / img.height;
      l = (img.width - r.right) * sx;
      t = (img.height - r.bottom) * sy;
      right = (img.width - r.left) * sx;
      b = (img.height - r.top) * sy;
      break;
    default:
      final sx = widget.width / img.width;
      final sy = widget.height / img.height;
      l = r.left * sx;
      t = r.top * sy;
      right = r.right * sx;
      b = r.bottom * sy;
  }
  return Rect.fromLTRB(l, t, right, b);
}
