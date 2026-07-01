import 'package:authenticator/modules/authentication/scan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ScannerController controller = Get.put(ScannerController());
  final MobileScannerController scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    controller.resetScanState();
  }

  @override
  void dispose() {
    scannerController.dispose();
    controller.resetScanState();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final raw = barcode?.rawValue;

    if (raw == null || raw.isEmpty) {
      return;
    }

    final added = controller.handleScan(raw);

    if (added) {
      await scannerController.stop();
      return;
    }

    if (!mounted) {
      return;
    }

    Get.snackbar(
      'Invalid QR',
      'Scan a valid authenticator QR code.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF111827),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'SCAN CODE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: scannerController, onDetect: _handleDetection),
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 260,
                    width: 260,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: CustomPaint(size: const Size(260, 260), painter: ScannerCornerPainter()),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text('Align QR code within the frame', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _scannerActionButton(icon: Icons.flash_on_rounded, onTap: () => scannerController.toggleTorch()),
                    const SizedBox(width: 40),
                    _scannerActionButton(icon: Icons.flip_camera_ios_rounded, onTap: () => scannerController.switchCamera()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scannerActionButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E).withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: const Color(0xFF10B981), size: 28),
      ),
    );
  }
}

class ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 40.0;
    final path = Path();

    path.moveTo(0, cornerLength);
    path.lineTo(0, 0);
    path.lineTo(cornerLength, 0);

    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, cornerLength);

    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width - cornerLength, size.height);

    path.moveTo(cornerLength, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
