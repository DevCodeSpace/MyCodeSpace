import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/receiver_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';

// ReceiverView runs on the Mac (or Windows PC) receiver device.
//
// It has two states:
//   • Waiting  — No Android sender is connected.
//                Shows the Mac's local IP so the user can verify the network,
//                and step-by-step instructions.
//   • Streaming — An Android sender is casting.
//                 Displays each received PNG frame fullscreen with a live FPS badge.
class ReceiverView extends GetView<ReceiverController> {
  const ReceiverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      // Mobile me navigation ke liye back button, Mac me null (No AppBar)
      appBar: GetPlatform.isMobile
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: Obx(() {
        // Switch between waiting and streaming states reactively
        if (!controller.isConnected.value) {
          return _WaitingView(controller: controller);
        }
        return _StreamView(controller: controller);
      }),
    );
  }
}

// ── Waiting screen ────────────────────────────────────────────────────────────

// Shown on the Mac when no Android sender is connected yet.
// Displays the Mac's IP address and numbered setup steps.
class _WaitingView extends StatelessWidget {
  final ReceiverController controller;

  const _WaitingView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large cast icon as a visual anchor
          Icon(Icons.cast, size: 88, color: AppColors.primary.withValues(alpha: 0.35)),
          const SizedBox(height: 28),

          Text('Ready to Receive Cast', style: boldPoppins(26, textColor: Colors.white)),
          const SizedBox(height: 12),

          Text(
            'Open the app on your Android phone\n'
            'and tap this device in WiFi Casting.',
            style: regularPoppins(15, textColor: Colors.white38),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),

          // IP address badge — shows the Mac's local network address.
          // The Android sender connects to this IP via WebSocket on port 8765.
          Obx(
            () => controller.localIP.value.isEmpty
                ? const CircularProgressIndicator(color: AppColors.primary)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('Listening on', style: regularPoppins(12, textColor: Colors.white38)),
                        const SizedBox(height: 4),
                        // Shows IP:port so the user can confirm the Android app found the right device
                        Text('${controller.localIP.value}:8765', style: boldPoppins(20, textColor: AppColors.primary)),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 48),

          // Setup instructions broken into three numbered steps
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _StepBadge(number: '1', label: 'Same WiFi\nnetwork'),
              SizedBox(width: 24),
              _StepBadge(number: '2', label: 'Open app\non Android'),
              SizedBox(width: 24),
              _StepBadge(number: '3', label: 'WiFi Cast\n→ Select Device'),
            ],
          ),
        ],
      ),
    );
  }
}

// Numbered circle + label used in the setup instructions.
class _StepBadge extends StatelessWidget {
  final String number;
  final String label;

  const _StepBadge({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(number, style: boldPoppins(17, textColor: AppColors.primary)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: regularPoppins(11, textColor: Colors.white38),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Live stream screen ────────────────────────────────────────────────────────

// Shown when an Android sender is actively streaming frames to this Mac.
// The received PNG bytes are decoded and displayed fullscreen using Image.memory.
// gaplessPlayback: true prevents the white flash that would occur between frame updates.
class _StreamView extends StatelessWidget {
  final ReceiverController controller;

  const _StreamView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fullscreen frame display — updated on every frame received from Android
        Obx(() {
          final frame = controller.currentFrame.value;
          if (frame == null) {
            // Frame not yet received — show a loading spinner
            return const ColoredBox(
              color: Colors.black,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return SizedBox.expand(
            child: Image.memory(
              frame,
              fit: BoxFit.contain, // Preserve aspect ratio — letterbox if needed
              gaplessPlayback: true, // Smooth transition between consecutive frames
            ),
          );
        }),

        // "● LIVE  X fps" badge in the top-right corner
        Positioned(
          top: 16,
          right: 16,
          child: Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 10),
                  const SizedBox(width: 6),
                  // Shows real-time FPS count from ReceiverController
                  Text('LIVE  ${controller.fps.value} fps', style: semiboldPoppins(12, textColor: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
