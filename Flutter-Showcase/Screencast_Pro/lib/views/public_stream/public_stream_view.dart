import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../controllers/public_stream_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../shared/casting_controls.dart';
import '../shared/casting_header.dart';

/// View for the "Cast Without Receiver" feature.
///
/// This screen allows the user to start a local MJPEG server and generates
/// a shareable URL. Instead of manually discovering devices via UDP, it heavily
/// relies on the native OS Quick Share / AirDrop to instantly push a popup
/// containing the stream link to nearby target devices.
class PublicStreamView extends GetView<PublicStreamController> {
  const PublicStreamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Cast Without Receiver', style: boldPoppins(17, textColor: Colors.white)),
      ),
      // Switches between the idle intro screen and the active sharing screen
      body: Obx(() {
        if (controller.isStreaming.value) {
          return _ActiveView(controller: controller);
        }
        return _IdleView(controller: controller);
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _IdleView — shown before the user starts the local HTTP server
// ══════════════════════════════════════════════════════════════════════════════

class _IdleView extends StatelessWidget {
  final PublicStreamController controller;
  const _IdleView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          // ── Hero Icon ────────────────────────────────────────────────────────
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withValues(alpha: 0.15),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.language_rounded, size: 45, color: Colors.greenAccent),
          ),
          const SizedBox(height: 24),
          Text('Browser & Quick Share', style: boldPoppins(22, textColor: Colors.white)),
          const SizedBox(height: 12),
          Text(
            'Cast to any phone, Mac, or PC without installing an app.\n\nOnce started, you can Quick Share the link to nearby devices for an instant native popup connection!',
            style: regularPoppins(14, textColor: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // ── Start Cast Button ────────────────────────────────────────────────
          Obx(() {
            final busy = controller.isStarting.value;
            return ElevatedButton.icon(
              onPressed: busy ? null : controller.startStream,
              icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cast_rounded),
              label: Text(busy ? 'Starting...' : 'Start Cast Server'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 58),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: boldPoppins(17),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _ActiveView — shown while streaming, contains Native Share & QR Code
// ══════════════════════════════════════════════════════════════════════════════

class _ActiveView extends StatelessWidget {
  final PublicStreamController controller;
  const _ActiveView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // ── Pulsing Live Header ──────────────────────────────────────────────
          CastingHeader(pulseController: controller.pulseCtrl, elapsed: controller.elapsed, accentColor: Colors.greenAccent, title: 'LIVE — READY TO SHARE'),
          const SizedBox(height: 24),

          // ── The Magic Feature: Native Quick Share Button ─────────────────────
          ElevatedButton.icon(
            onPressed: controller.shareStreamUrl,
            icon: const Icon(Icons.share_rounded, size: 24),
            label: Text('Quick Share to Nearby Device', style: boldPoppins(15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              shadowColor: Colors.blueAccent.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap above to trigger Android Quick Share or Apple AirDrop.\nThe target device will get a native popup to open the stream instantly!',
            style: regularPoppins(12, textColor: Colors.white54),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),
          const Divider(color: Colors.white10),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text('OR CONNECT MANUALLY', style: regularPoppins(11, textColor: Colors.white38).copyWith(letterSpacing: 1.5)),
          ),
          const SizedBox(height: 16),

          // ── Stream URL Card (Manual Copy) ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: Colors.white38, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.streamUrl.value ?? '...',
                      style: boldPoppins(15, textColor: Colors.greenAccent),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_all_rounded, color: Colors.white60, size: 20),
                  tooltip: 'Copy URL',
                  onPressed: () {
                    if (controller.streamUrl.value != null) {
                      Clipboard.setData(ClipboardData(text: controller.streamUrl.value!));
                      Get.snackbar('Copied', 'Stream URL copied to clipboard', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.grey.shade800, colorText: Colors.white);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── QR Code Card (Scan with Camera) ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Obx(
              () => QrImageView(
                data: controller.streamUrl.value ?? '',
                version: QrVersions.auto,
                size: 180.0,
                backgroundColor: Colors.white, // Critical so phones can scan the black QR code easily
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Scan with camera to open', style: regularPoppins(12, textColor: Colors.white38)),

          const SizedBox(height: 32),

          // ── Active Viewer Count ──────────────────────────────────────────────
          Obx(() {
            final count = controller.viewerCount.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.visibility_rounded, size: 18, color: count > 0 ? Colors.greenAccent : Colors.white38),
                const SizedBox(width: 8),
                Text('$count Viewer${count == 1 ? '' : 's'} Connected', style: boldPoppins(14, textColor: count > 0 ? Colors.greenAccent : Colors.white38)),
              ],
            );
          }),

          const SizedBox(height: 32),

          // ── Stop Casting Button ──────────────────────────────────────────────
          CastingControls(onStop: controller.stopStream, accentColor: Colors.green),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
