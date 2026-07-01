import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ocr_service.dart';
import '../utils/app_colors.dart';
import '../widgets/action_card.dart';
import 'live_scanner_screen.dart';
import 'photo_text_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _ocr = OcrService();
  bool _isProcessing = false;

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _openLiveScanner() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LiveScannerScreen()),
      );
    } else if (status.isPermanentlyDenied) {
      _showPermissionDenied('Camera');
    } else {
      _showSnack('Camera permission is required to scan.');
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final recognized = await _ocr.recognizeFromFile(File(file.path));
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoTextScreen(
            imageFile: File(file.path),
            recognizedText: recognized,
          ),
        ),
      );
    } catch (e) {
      if (mounted) _showSnack('Could not process image. Please try again.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPermissionDenied(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name permission denied. Enable it in Settings.'),
        action: SnackBarAction(label: 'Open Settings', onPressed: openAppSettings),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), margin: const EdgeInsets.all(16)),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('TextLens Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _showAbout,
            tooltip: 'About',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                _buildBanner(),
                const SizedBox(height: 28),
                _buildSectionTitle('Scan Options'),
                const SizedBox(height: 12),
                ActionCard(
                  title: 'Live Scanner',
                  subtitle: 'Real-time OCR with live camera',
                  icon: Icons.camera_alt_rounded,
                  color: AppColors.primary,
                  onTap: _openLiveScanner,
                ),
                const SizedBox(height: 12),
                ActionCard(
                  title: 'Upload Image',
                  subtitle: 'Pick a photo from your gallery',
                  icon: Icons.photo_library_rounded,
                  color: AppColors.secondary,
                  onTap: _pickFromGallery,
                ),
                const SizedBox(height: 28),
                _buildSectionTitle('How It Works'),
                const SizedBox(height: 12),
                _buildStep(
                  number: '1',
                  title: 'Scan or Upload',
                  desc: 'Use the camera for real-time scanning or pick an image from your gallery.',
                  icon: Icons.camera_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                _buildStep(
                  number: '2',
                  title: 'AI Extracts Text',
                  desc: 'ML Kit automatically recognizes and extracts every word.',
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 10),
                _buildStep(
                  number: '3',
                  title: 'Search & Share',
                  desc: 'Highlight words instantly, then copy or share the result.',
                  icon: Icons.search_rounded,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_isProcessing) _buildLoader(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/logo/logo_text_pro.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to TextLens Pro',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Scan text with your camera or upload an image',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: color, size: 18),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: const Center(
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 14),
                Text(
                  'Extracting text…',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('TextLens Pro'),
        content: const Text(
          'Scan, extract and search text from any image using on-device AI — no internet needed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
