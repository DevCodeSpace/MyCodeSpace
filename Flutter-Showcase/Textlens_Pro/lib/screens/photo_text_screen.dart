import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart' hide TextBlock;
import 'package:share_plus/share_plus.dart';

import '../utils/app_colors.dart';
import '../widgets/scan_overlay_painter.dart';

class PhotoTextScreen extends StatefulWidget {
  final File imageFile;
  final RecognizedText recognizedText;

  const PhotoTextScreen({
    super.key,
    required this.imageFile,
    required this.recognizedText,
  });

  @override
  State<PhotoTextScreen> createState() => _PhotoTextScreenState();
}

class _PhotoTextScreenState extends State<PhotoTextScreen> {
  Size? _imageSize;
  List<DetectedTextBlock> _textBlocks = [];

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final bytes = await widget.imageFile.readAsBytes();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    final image = await completer.future;
    if (mounted) {
      setState(() {
        _imageSize = Size(image.width.toDouble(), image.height.toDouble());
      });
      image.dispose();
    }
  }

  List<DetectedTextBlock> _buildBlocks(Size widgetSize) {
    final imageSize = _imageSize!;
    final widgetAspect = widgetSize.width / widgetSize.height;
    final imageAspect = imageSize.width / imageSize.height;

    double displayW, displayH;
    if (imageAspect > widgetAspect) {
      displayW = widgetSize.width;
      displayH = widgetSize.width / imageAspect;
    } else {
      displayH = widgetSize.height;
      displayW = widgetSize.height * imageAspect;
    }

    final offsetX = (widgetSize.width - displayW) / 2;
    final offsetY = (widgetSize.height - displayH) / 2;
    final scaleX = displayW / imageSize.width;
    final scaleY = displayH / imageSize.height;

    final result = <DetectedTextBlock>[];
    for (final block in widget.recognizedText.blocks) {
      for (final line in block.lines) {
        final r = line.boundingBox;
        result.add(DetectedTextBlock(
          text: line.text,
          screenRect: Rect.fromLTRB(
            offsetX + r.left * scaleX,
            offsetY + r.top * scaleY,
            offsetX + r.right * scaleX,
            offsetY + r.bottom * scaleY,
          ),
        ));
      }
    }

    // Sort into natural reading order (top→bottom, left→right).
    // SelectionArea extends selection in widget-tree order, so this order
    // must match reading order to avoid blocks being skipped during drag.
    result.sort((a, b) {
      final lineH = (a.screenRect.height + b.screenRect.height) / 2;
      final dy = a.screenRect.top - b.screenRect.top;
      // Same row if vertical overlap is less than half a line height
      if (dy.abs() < lineH * 0.5) {
        return (a.screenRect.left - b.screenRect.left).sign.toInt();
      }
      return dy.sign.toInt();
    });

    return result;
  }

  // Font size that fits inside the bounding-box height
  double _fontSize(Rect rect) => (rect.height * 0.70).clamp(8.0, 60.0);

  Future<void> _copyAll() async {
    final text = widget.recognizedText.text.trim();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('All text copied', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hasText = widget.recognizedText.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      // SelectionArea wraps the entire body so selection works anywhere on screen
      body: SelectionArea(
        child: Stack(
          children: [
            // 1. Photo — excluded from selection
            Positioned.fill(
              child: SelectionContainer.disabled(
                child: Image.file(widget.imageFile, fit: BoxFit.contain),
              ),
            ),

            // 2. Invisible Text widgets at exact bounding-box positions
            //    Positioned.fill guarantees the inner Stack covers the whole screen
            if (_imageSize != null)
              Positioned.fill(
                child: LayoutBuilder(builder: (ctx, constraints) {
                  _textBlocks = _buildBlocks(Size(constraints.maxWidth, constraints.maxHeight));
                  return Stack(
                    children: _textBlocks.asMap().entries.map((entry) {
                      final i = entry.key;
                      final block = entry.value;
                      final fs = _fontSize(block.screenRect);
                      return Positioned(
                        // Stable key keeps SelectionArea's internal state
                        // consistent across rebuilds
                        key: ValueKey(i),
                        left: block.screenRect.left,
                        top: block.screenRect.top,
                        width: block.screenRect.width,
                        height: block.screenRect.height,
                        child: Text(
                          block.text,
                          style: TextStyle(
                            fontSize: fs,
                            // Near-zero alpha instead of fully transparent so
                            // the renderer never omits the glyph hit-test rects
                            color: const Color(0x01FFFFFF),
                            height: 1.1,
                          ),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),

            // Loading spinner — excluded from selection
            if (_imageSize == null)
              Positioned.fill(
                child: SelectionContainer.disabled(
                  child: Container(
                    color: Colors.black38,
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
              ),

            // 3. Top bar — excluded from selection
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SelectionContainer.disabled(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Row(
                      children: [
                        _CircleBtn(
                          icon: Icons.arrow_back_ios_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        if (hasText) ...[
                          _CircleBtn(
                            icon: Icons.copy_all_rounded,
                            onTap: _copyAll,
                          ),
                          const SizedBox(width: 8),
                          _CircleBtn(
                            icon: Icons.share_rounded,
                            onTap: () => Share.share(widget.recognizedText.text.trim()),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. Bottom hint bar — excluded from selection
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SelectionContainer.disabled(
                  child: SafeArea(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Text(
                        hasText
                            ? 'Long press on text to select'
                            : _imageSize == null
                                ? 'Loading image…'
                                : 'No text detected in this image',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Circle button ────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.50),
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
