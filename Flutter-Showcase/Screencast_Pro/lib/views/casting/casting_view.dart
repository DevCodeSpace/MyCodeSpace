import '../../utils/import_to_export.dart';
import '../../controllers/casting_controller.dart';

// CastingView is the full-screen status panel shown on Android while a WiFi
// screen-cast session is in progress.
//
// UI sections (top to bottom):
//   • Top bar     — "NOW CASTING" label + back/stop button
//   • Pulse icon  — animated glow on the receiver's device icon
//   • Device label — receiver name + "Connected via WiFi" indicator
//   • Stream panel — WebSocket status: connecting / error / live (FPS + elapsed)
//   • Stop button  — confirms before disconnecting and returning to device list
class CastingView extends GetView<CastingController> {
  const CastingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // Header with dismiss arrow and "NOW CASTING" label
              _TopBar(onBack: controller.confirmStop),
              const SizedBox(height: 16),

              // Animated pulse icon — visual heartbeat showing the session is live
              _PulseIcon(controller: controller),
              const SizedBox(height: 16),

              // Receiver name + green "Connected via WiFi" dot
              _DeviceLabel(controller: controller),
              const SizedBox(height: 20),

              // Live stream status panel (connecting → error → streaming with FPS)
              _StreamPanel(controller: controller),

              const Spacer(),

              // "Stop Casting" button — shows a confirmation dialog before stopping
              _StopButton(onStop: controller.confirmStop),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white, size: 30),
          onPressed: onBack,
        ),
        Text(
          'NOW CASTING',
          style: regularPoppins(12, textColor: Colors.white54)
              .copyWith(letterSpacing: 2.5),
        ),
        const SizedBox(width: 48), // Balances the icon button so title stays centred
      ],
    );
  }
}

// ── Animated pulse icon ───────────────────────────────────────────────────────

// Uses CastingController.pulseCtrl (a looping AnimationController) to
// produce a gently breathing glow effect around the receiver's device icon.
class _PulseIcon extends StatelessWidget {
  final CastingController controller;

  const _PulseIcon({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.pulseCtrl,
      builder: (context, _) {
        final p = controller.pulseCtrl.value; // 0.0 … 1.0 (reversed loop)
        return Container(
          width: 160, height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              controller.accent.withValues(alpha: 0.25 + p * 0.15),
              controller.accent.withValues(alpha: 0.05),
              Colors.transparent,
            ]),
          ),
          child: Center(
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.accent.withValues(alpha: 0.12),
                border: Border.all(
                  color: controller.accent.withValues(alpha: 0.5 + p * 0.3),
                  width: 2,
                ),
              ),
              // Icon changes based on the receiver device type (laptop, computer, etc.)
              child: Icon(controller.device.icon, color: controller.accent, size: 40),
            ),
          ),
        );
      },
    );
  }
}

// ── Device label ──────────────────────────────────────────────────────────────

// Shows the receiver's name and a connection-type indicator below the pulse icon.
class _DeviceLabel extends StatelessWidget {
  final CastingController controller;

  const _DeviceLabel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          controller.device.name,
          style: boldPoppins(22, textColor: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Green dot = active connection
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Connected via WiFi',
              style: regularPoppins(13, textColor: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Live stream panel ─────────────────────────────────────────────────────────

// Shows the current WebSocket state: connecting → error → actively streaming.
// When streaming, displays FPS, elapsed time, and the receiver's IP address.
class _StreamPanel extends StatelessWidget {
  final CastingController controller;

  const _StreamPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Obx(() {
        // ── Error state ──────────────────────────────────────────────────────
        if (controller.streamError.value != null) {
          return Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.streamError.value!,
                  style: regularPoppins(13, textColor: Colors.white70),
                ),
              ),
            ],
          );
        }

        // ── Connecting state ─────────────────────────────────────────────────
        if (!controller.isStreamConnected.value) {
          return Row(
            children: [
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: controller.accent),
              ),
              const SizedBox(width: 14),
              Text('Connecting to Mac...',
                  style: regularPoppins(14, textColor: Colors.white70)),
            ],
          );
        }

        // ── Streaming state ──────────────────────────────────────────────────
        return Column(
          children: [
            Row(
              children: [
                // Screen-share icon
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: controller.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.screen_share_rounded,
                      color: controller.accent, size: 26),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Screen Share — Live',
                          style: semiboldPoppins(15, textColor: Colors.white)),
                      const SizedBox(height: 3),
                      // FPS and elapsed time — updated every second via Obx
                      Obx(() => Text(
                        '${controller.streamFps.value.toInt()} fps  •  '
                        '${controller.formatElapsed()}',
                        style: regularPoppins(12, textColor: Colors.white54),
                      )),
                    ],
                  ),
                ),

                // Red "● LIVE" badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('● LIVE',
                      style: boldPoppins(11, textColor: Colors.redAccent)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Elapsed-time progress bar — cycles every 60 seconds
            Obx(() {
              final secs = controller.elapsed.value.inSeconds;
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: (secs % 60) / 60,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(controller.accent),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(controller.formatElapsed(),
                          style: regularPoppins(11, textColor: Colors.white54)),
                      // Show receiver IP so user can verify the connection
                      Text(controller.device.host,
                          style: regularPoppins(11, textColor: Colors.white24)),
                    ],
                  ),
                ],
              );
            }),
          ],
        );
      }),
    );
  }
}

// ── Stop button ───────────────────────────────────────────────────────────────

// Outlined button at the bottom of the screen.
// Triggers CastingController.confirmStop() which shows an AlertDialog.
class _StopButton extends StatelessWidget {
  final VoidCallback onStop;

  const _StopButton({required this.onStop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onStop,
        icon: const Icon(Icons.cast_rounded, size: 18),
        label: Text('Stop Casting', style: mediumPoppins(15 , textColor: Colors.white)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
