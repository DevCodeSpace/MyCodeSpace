import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    hide TextBlock;
import 'package:url_launcher/url_launcher.dart';
import '../services/ocr_service.dart';
import '../utils/app_colors.dart';
import '../widgets/scan_overlay_painter.dart';
import 'photo_text_screen.dart';

class LiveScannerScreen extends StatefulWidget {
  const LiveScannerScreen({super.key});

  @override
  State<LiveScannerScreen> createState() => _LiveScannerScreenState();
}

class _LiveScannerScreenState extends State<LiveScannerScreen>
    with WidgetsBindingObserver {
  // ─── Camera ──────────────────────────────────────────────────────────────────
  CameraController? _ctrl;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;
  bool _isFlashOn = false;

  // ─── OCR ─────────────────────────────────────────────────────────────────────
  final _ocr = OcrService();
  bool _isProcessingFrame = false;
  DateTime _lastFrameTime = DateTime(0);

  RecognizedText? _recognized;

  // Converted blocks in screen coordinates
  List<DetectedTextBlock> _textBlocks = [];
  int? _selectedIndex;

  // Last known widget size — set by LayoutBuilder, read by _processFrame
  Size? _widgetSize;

  // ─── Capture ─────────────────────────────────────────────────────────────────
  bool _isCapturing = false;

  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _ctrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      ctrl.dispose();
      if (mounted) setState(() => _cameraReady = false);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showError('No cameras found on this device.');
        return;
      }

      final back = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      if (!mounted) return;

      _ctrl = controller;
      setState(() => _cameraReady = true);
      controller.startImageStream(_onCameraFrame);
    } catch (e) {
      if (mounted) _showError('Camera error: $e');
    }
  }

  // ─── Frame processing ─────────────────────────────────────────────────────────

  void _onCameraFrame(CameraImage image) {
    final now = DateTime.now();
    if (_isProcessingFrame ||
        now.difference(_lastFrameTime).inMilliseconds < 100) {
      return;
    }

    _isProcessingFrame = true;
    _lastFrameTime = now;
    _processFrame(image).then((_) => _isProcessingFrame = false);
  }

  Future<void> _processFrame(CameraImage image) async {
    final camera = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    final rotation = InputImageRotationValue.fromRawValue(
          camera.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;

    int totalLen = 0;
    for (final plane in image.planes) {
      totalLen += plane.bytes.length;
    }
    final bytes = Uint8List(totalLen);
    int offset = 0;
    for (final plane in image.planes) {
      bytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final result = await _ocr.recognizeFromInputImage(inputImage);
    if (!mounted || result == null) return;

    final imgSize = Size(image.width.toDouble(), image.height.toDouble());
    final ws = _widgetSize;
    final blocks = ws != null
        ? buildTextBlocks(
            recognizedText: result,
            imageSize: imgSize,
            widgetSize: ws,
            rotation: rotation,
          )
        : <DetectedTextBlock>[];

    setState(() {
      _recognized = result;
      _textBlocks = blocks;
    });
  }

  // ─── Flash ────────────────────────────────────────────────────────────────────

  Future<void> _toggleFlash() async {
    final ctrl = _ctrl;
    if (ctrl == null) return;
    try {
      setState(() => _isFlashOn = !_isFlashOn);
      await ctrl.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      setState(() => _isFlashOn = !_isFlashOn);
    }
  }

  // ─── Capture & navigate ───────────────────────────────────────────────────────

  Future<void> _capture() async {
    final ctrl = _ctrl;
    if (ctrl == null || !ctrl.value.isInitialized || _isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      await ctrl.stopImageStream();
      final photo = await ctrl.takePicture();
      final recognized = await _ocr.recognizeFromFile(File(photo.path));

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoTextScreen(
            imageFile: File(photo.path),
            recognizedText: recognized,
          ),
        ),
      );

      if (mounted && _ctrl != null && _ctrl!.value.isInitialized) {
        _ctrl!.startImageStream(_onCameraFrame);
      }
    } catch (e) {
      if (mounted) _showError('Capture failed. Please try again.');
      _ctrl?.startImageStream(_onCameraFrame);
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  // ─── Block tap → bottom sheet ─────────────────────────────────────────────────

  void _onBlockTap(int index) {
    setState(() => _selectedIndex = index);
    final text = _textBlocks[index].text;
    _showLensMenu(text, _textBlocks[index].screenRect);
  }

  void _showLensMenu(String text, Rect rect) {
    // Show the Google Lens style horizontal menu
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      builder: (_) => _LensHorizontalMenu(
        text: text,
        onCopy: () {
          Navigator.pop(context);
          _copyToClipboard(text);
        },
        onListen: () {
          Navigator.pop(context);
          // TODO: Implement TTS if needed
        },
        onSearch: () {
          Navigator.pop(context);
          _openSearch(text);
        },
      ),
    );
  }




  Future<void> _openSearch(String text) async {
    final encoded = Uri.encodeComponent(text);
    final uri = Uri.parse('https://www.google.com/search?q=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '"$text" copied',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyAllText() {
    if (_recognized == null || _recognized!.text.trim().isEmpty) return;
    _copyToClipboard(_recognized!.text.trim());
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _selectedIndex = null),
        child: Stack(
          children: [
            // 1. Camera preview — isolated so OCR setState never repaints it
            if (_cameraReady && _ctrl != null)
              RepaintBoundary(
                child: SizedBox.expand(child: CameraPreview(_ctrl!)),
              )
            else
              const Center(
                  child: CircularProgressIndicator(color: Colors.white)),

            // 2. Text overlay + tap targets
            if (_cameraReady)
              LayoutBuilder(builder: (ctx, constraints) {
                // Store size so _processFrame can build blocks off the UI thread
                _widgetSize = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(children: [
                  // Highlight layer: fade in when blocks arrive, fade out when gone
                  AnimatedOpacity(
                    opacity: _textBlocks.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomPaint(
                      size: _widgetSize!,
                      painter: ScanOverlayPainter(
                        blocks: _textBlocks,
                        selectedIndex: _selectedIndex,
                      ),
                    ),
                  ),
                  // Tap targets
                  ..._textBlocks.asMap().entries.map((e) {
                    final i = e.key;
                    final block = e.value;
                    return Positioned(
                      left: block.screenRect.left,
                      top: block.screenRect.top,
                      width: block.screenRect.width,
                      height: block.screenRect.height,
                      child: GestureDetector(
                        onTap: () => _onBlockTap(i),
                        child: const ColoredBox(color: Colors.transparent),
                      ),
                    );
                  }),
                ]);
              }),

            // 3. Top bar
            _buildTopBar(),

            // 4. Bottom bar
            _buildBottomBar(),

            // 5. Capturing overlay
            if (_isCapturing)
              Container(
                color: Colors.white.withValues(alpha: 0.12),
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Top bar: back · Translate chip · flash ───────────────────────────────────

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Row(
          children: [
            _CircleBtn(
              icon: Icons.arrow_back_ios_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            const Spacer(),
            _CircleBtn(
              icon: _isFlashOn
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              onTap: _toggleFlash,
              active: _isFlashOn,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom bar: status · copy-all · capture ──────────────────────────────────

  Widget _buildBottomBar() {
    final hasText = _recognized != null && _recognized!.text.trim().isNotEmpty;
    final blockCount = _textBlocks.length;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              // Status text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _cameraReady
                          ? (hasText
                              ? '$blockCount text line${blockCount != 1 ? 's' : ''} detected'
                              : 'Scanning for text…')
                          : 'Initializing camera…',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (hasText)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Tap any text to copy or translate',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Copy all
              if (hasText)
                _IconLabelBtn(
                  icon: Icons.copy_all_rounded,
                  label: 'Copy all',
                  onTap: _copyAllText,
                ),
              const SizedBox(width: 10),
              // Capture
              GestureDetector(
                onTap: _isCapturing ? null : _capture,
                child: _CaptureButton(isCapturing: _isCapturing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom sheet shown when a text block is tapped ──────────────────────────

class _LensHorizontalMenu extends StatelessWidget {
  final String text;
  final VoidCallback onCopy;
  final VoidCallback onListen;
  final VoidCallback onSearch;

  const _LensHorizontalMenu({
    required this.text,
    required this.onCopy,
    required this.onListen,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _LensMenuBtn(icon: Icons.copy_rounded, label: 'Copy', onTap: onCopy),
                _LensMenuBtn(icon: Icons.volume_up_rounded, label: 'Listen', onTap: onListen),
                _LensMenuBtn(icon: Icons.search_rounded, label: 'Search', onTap: onSearch),
                _LensMenuBtn(icon: Icons.more_vert_rounded, label: '', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _LensMenuBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LensMenuBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}


// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _IconLabelBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconLabelBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.50),
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final bool isCapturing;
  const _CaptureButton({required this.isCapturing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: isCapturing
          ? const Padding(
              padding: EdgeInsets.all(16),
              child:
                  CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
          : const Icon(Icons.camera_rounded, color: Colors.white, size: 28),
    );
  }
}
