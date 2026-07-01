import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:screencast_pro/app/routes/app_routes.dart';

import '../../controllers/tv_cast_controller.dart';
import '../../models/tv_device.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../shared/casting_controls.dart';
import '../shared/casting_header.dart';

/// TV Casting screen — discovers smart TVs on the same WiFi and casts the
/// Android screen to them.
///
/// Casting works without any app installed on the TV:
///   - LG webOS TVs open their built-in browser via the SSAP WebSocket API.
///   - Samsung Tizen TVs open the Internet app via the REST API.
///   - Generic DLNA TVs receive the stream via UPnP AVTransport SOAP calls.
///
/// This view is display-only; all logic lives in [TvCastController].
class TvCastView extends GetView<TvCastController> {
  const TvCastView({super.key});

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
        title: Text('Cast to TV', style: boldPoppins(17, textColor: Colors.white)),
      ),
      // Obx switches between the idle intro screen and the active casting screen
      // based on whether the MJPEG server is currently running.
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
// _IdleView — shown before the user starts casting
// ══════════════════════════════════════════════════════════════════════════════

/// Explains the feature and provides the "Scan & Start Casting" button.
/// Displayed when [TvCastController.isStreaming] is false.
class _IdleView extends StatelessWidget {
  final TvCastController controller;
  const _IdleView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero icon + tagline ────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Purple radial glow behind the cast icon
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      Colors.deepPurple.withValues(alpha: 0.30),
                      Colors.deepPurple.withValues(alpha: 0.06),
                    ]),
                    border: Border.all(
                        color: Colors.deepPurple.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: const Icon(Icons.cast_connected_rounded,
                      size: 40, color: Colors.deepPurpleAccent),
                ),
                const SizedBox(height: 20),
                Text('Cast to Your Smart TV',
                    style: boldPoppins(22, textColor: Colors.white)),
                const SizedBox(height: 10),
                Text(
                  'No app needed on the TV.\n'
                  'Works with LG, Samsung, and DLNA compatible TVs\n'
                  'connected to the same WiFi.',
                  style: regularPoppins(14, textColor: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── How it works ───────────────────────────────────────────────────
          _SectionLabel('HOW IT WORKS'),
          const SizedBox(height: 12),
          const _HowItWorksCard(),

          const SizedBox(height: 28),

          // ── Compatible TV list ─────────────────────────────────────────────
          _SectionLabel('WORKS WITH'),
          const SizedBox(height: 12),
          const _TvCompatRow(),

          const SizedBox(height: 36),

          // ── Start button ───────────────────────────────────────────────────
          // Disabled while the startup phase is in progress to prevent double-tap.
          Obx(() {
            final busy = controller.isStarting.value;
            return ElevatedButton.icon(
              onPressed: busy ? null : controller.startCasting,
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cast_rounded),
              label: Text(busy ? 'Starting…' : 'Scan & Start Casting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 58),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle: boldPoppins(17),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _ActiveView — shown while the MJPEG server is running
// ══════════════════════════════════════════════════════════════════════════════

/// Displays the pulsing live header, the stream URL, the TV discovery list,
/// and the cast status.  Shown when [TvCastController.isStreaming] is true.
class _ActiveView extends StatelessWidget {
  final TvCastController controller;
  const _ActiveView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // ── Pulsing "NOW CASTING" header with elapsed timer ────────────────
          CastingHeader(
            pulseController: controller.pulseCtrl,
            elapsed:         controller.elapsed,
            accentColor:     Colors.deepPurpleAccent,
            title:           'CASTING TO TV — SEARCHING NEARBY',
          ),
          const SizedBox(height: 16),

          // ── Stream URL card — shows the LAN URL and a copy button ──────────
          Obx(() => _UrlCard(url: controller.streamUrl.value)),
          const SizedBox(height: 16),

          // ── TV discovery section — scanning spinner or TV tile list ────────
          // NOT wrapped in Obx here — _TvScanSection owns its own Obx internally
          // so that reactive reads happen inside the tracking scope.
          _TvScanSection(controller: controller),
          const SizedBox(height: 16),

          // ── Cast status card — connecting / connected / failed ─────────────
          Obx(() {
            final status = controller.castStatus.value;
            final tv     = controller.selectedTv.value;
            // Only show once the user has tapped a TV
            if (status == TvCastStatus.idle || tv == null) {
              return const SizedBox.shrink();
            }
            return _CastStatusCard(status: status, tv: tv);
          }),
          const SizedBox(height: 20),

          // ── Stop casting button ────────────────────────────────────────────
          CastingControls(
            onStop:      controller.stopAll,
            accentColor: Colors.deepPurple,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _TvScanSection — TV list / scanning state
// ══════════════════════════════════════════════════════════════════════════════

/// Shows a scanning spinner while SSDP/UDP discovery runs, then lists all
/// discovered TVs and Mac/PC receivers. Each tile calls
/// [TvCastController.castToTv] when tapped.
///
/// The [Obx] is placed INSIDE this widget so all reactive reads
/// (isScanning, discoveredTvs, selectedTv) happen within GetX's tracking scope,
/// which prevents the "improper use of GetX/Obx" assertion.
class _TvScanSection extends StatelessWidget {
  final TvCastController controller;
  const _TvScanSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Obx here — all .value accesses below are inside the tracking scope
    return Obx(() {
      final scanning      = controller.isScanning.value;
      final tvs           = controller.discoveredTvs.toList();
      final selectedTvIp  = controller.selectedTv.value?.ip;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with a "Rescan" button on the right
            Row(
              children: [
                Text(
                  'NEARBY DEVICES',
                  style: regularPoppins(11, textColor: Colors.white38)
                      .copyWith(letterSpacing: 1.5),
                ),
                const Spacer(),
                if (!scanning)
                  GestureDetector(
                    onTap: controller.rescan,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded,
                            color: Colors.deepPurpleAccent, size: 16),
                        const SizedBox(width: 4),
                        Text('Rescan',
                            style: regularPoppins(12,
                                textColor: Colors.deepPurpleAccent)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Content: spinner → empty state → device tiles
            if (scanning)
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.deepPurpleAccent),
                  ),
                  const SizedBox(width: 12),
                  // Flexible prevents overflow when text is longer than remaining width
                  Flexible(
                    child: Text('Scanning for TVs and Macs on your network…',
                        style: regularPoppins(13, textColor: Colors.white54)),
                  ),
                ],
              )
            else if (tvs.isEmpty)
              // ── Empty state — shown after scan completes with 0 results ──
              _EmptyDevicesPanel(controller: controller)
            else
              // One tile per device; tapping begins the cast attempt
              for (final tv in tvs)
                _TvTile(
                  tv:         tv,
                  onTap:      () => controller.castToTv(tv),
                  isSelected: selectedTvIp == tv.ip,
                ),
          ],
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _TvTile — single discovered TV row
// ══════════════════════════════════════════════════════════════════════════════

/// One row in the discovered-TV list.  Highlights in purple when this TV has
/// been selected for casting.
class _TvTile extends StatelessWidget {
  final TvDevice     tv;
  final VoidCallback onTap;
  final bool         isSelected;

  const _TvTile({
    required this.tv,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          // Highlight the selected TV with a purple tint
          color: isSelected
              ? Colors.deepPurple.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurpleAccent.withValues(alpha: 0.60)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            Icon(
              tv.icon,
              color: isSelected ? Colors.deepPurpleAccent : Colors.white60,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tv.name,
                    style: boldPoppins(14, textColor: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${tv.platformLabel} · ${tv.ip}',
                    style: regularPoppins(12, textColor: Colors.white38),
                  ),
                ],
              ),
            ),
            // Checkmark when selected, cast icon otherwise
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.cast_rounded,
              color: isSelected ? Colors.deepPurpleAccent : Colors.white30,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _EmptyDevicesPanel — shown when the scan completes with 0 results
// ══════════════════════════════════════════════════════════════════════════════

/// Replaces the plain "no devices found" text with two actionable sections:
///
/// 1. **Manual Connect** — lets the user type a device IP directly.
///    Sends a unicast UDP probe to that IP, bypassing the broadcast-forwarding
///    limitation that hides Mac/PC receivers on Ethernet from a WiFi phone.
///    If the ScreenCast Pro receiver is running → auto-connects.
///    If not running → shows instructions to open the stream URL manually.
///
/// 2. **Without Receiver** — jumps to the browser-casting screen so the user
///    can open the MJPEG URL on any Mac/PC browser without installing a
///    receiver app.
class _EmptyDevicesPanel extends StatelessWidget {
  final TvCastController controller;
  const _EmptyDevicesPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Auto-discovery hint ────────────────────────────────────────────
        Text(
          'No devices found automatically.\n'
          '• Smart TV: make sure it is on and on the same WiFi.\n'
          '• Mac on Ethernet: use manual connect below.',
          style: regularPoppins(12, textColor: Colors.white38),
        ),

        const SizedBox(height: 16),
        const Divider(color: Colors.white10),
        const SizedBox(height: 14),

        // ── Section: Manual connect via IP ─────────────────────────────────
        Text(
          'CONNECT MANUALLY',
          style: regularPoppins(11, textColor: Colors.white38)
              .copyWith(letterSpacing: 1.4),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the IP of your Mac or TV (e.g. 192.168.1.17).\n'
          'Works even when Mac is on Ethernet and phone is on WiFi.',
          style: regularPoppins(12, textColor: Colors.white54),
        ),
        const SizedBox(height: 10),

        // IP input row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.manualIpController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: regularPoppins(14, textColor: Colors.white),
                decoration: InputDecoration(
                  hintText: '192.168.1.17',
                  hintStyle: regularPoppins(14, textColor: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Colors.deepPurpleAccent, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Connect button — shows spinner while the probe is in flight
            Obx(() {
              final busy = controller.isManualConnecting.value;
              return ElevatedButton(
                onPressed: busy ? null : controller.connectToManualIp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cast_rounded, size: 20),
              );
            }),
          ],
        ),

        const SizedBox(height: 16),
        const Divider(color: Colors.white10),
        const SizedBox(height: 14),

        // ── Section: Without receiver — open URL manually ─────────────────
        Text(
          'WITHOUT RECEIVER APP',
          style: regularPoppins(11, textColor: Colors.white38)
              .copyWith(letterSpacing: 1.4),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                color: Colors.deepPurpleAccent, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Copy the stream URL (shown at the top of this screen) and '
                'open it in any browser on your Mac, TV, or phone. '
                'No app needed on the receiving side.',
                style: regularPoppins(12, textColor: Colors.white54),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Quick escape hatch for the "without receiver" flow.
        // This takes the user to the browser-casting screen, where the phone
        // acts as a local HTTP server and any Mac/PC browser can open the URL.
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.publicStream),
            icon: const Icon(Icons.language_rounded, size: 18),
            label: const Text('Cast Without Receiver'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.deepPurpleAccent.withValues(alpha: 0.45)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _CastStatusCard — connection state banner
// ══════════════════════════════════════════════════════════════════════════════

/// Coloured banner below the TV list showing connecting / connected / failed.
class _CastStatusCard extends StatelessWidget {
  final TvCastStatus status;
  final TvDevice     tv;

  const _CastStatusCard({required this.status, required this.tv});

  @override
  Widget build(BuildContext context) {
    // Derive colour and label from the current status
    final Color  color;
    final String label;
    final Widget leadingWidget;

    switch (status) {
      case TvCastStatus.connecting:
        color         = Colors.orange;
        label         = 'Connecting to ${tv.name}…';
        leadingWidget = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
        );
      case TvCastStatus.connected:
        color         = Colors.greenAccent;
        label         = 'Casting to ${tv.name}';
        leadingWidget = const Icon(Icons.check_circle_rounded,
            color: Colors.greenAccent, size: 20);
      case TvCastStatus.failed:
        color         = Colors.redAccent;
        label         = 'Failed — could not reach ${tv.name}';
        leadingWidget = const Icon(Icons.error_outline_rounded,
            color: Colors.redAccent, size: 20);
      case TvCastStatus.idle:
        return const SizedBox.shrink(); // Should not be rendered (guarded above)
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          leadingWidget,
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: regularPoppins(13, textColor: color)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _UrlCard — live stream URL with copy button
// ══════════════════════════════════════════════════════════════════════════════

/// Displays the MJPEG stream URL with a one-tap copy button.
/// The user can share this URL manually in case auto-cast fails.
class _UrlCard extends StatelessWidget {
  final String? url;
  const _UrlCard({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, color: Colors.white38, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              url ?? '…',
              style: boldPoppins(15, textColor: Colors.deepPurpleAccent),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Copy URL to clipboard — useful when opening manually on the TV
          IconButton(
            icon: const Icon(Icons.copy_all_rounded, color: Colors.white60, size: 20),
            tooltip: 'Copy URL',
            onPressed: url == null
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: url!));
                    Get.snackbar(
                      'Copied',
                      url!,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.grey.shade800,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Small layout helpers
// ══════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: regularPoppins(11, textColor: Colors.white38)
          .copyWith(letterSpacing: 1.5),
    );
  }
}


class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Tap "Scan & Start Casting" your phone starts an MJPEG stream server.',
      'The app discovers smart TVs on your WiFi via SSDP/UPnP.',
      'Tap a TV name the TV opens its browser to your live stream. No app needed.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numbered circle
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.withValues(alpha: 0.20),
                    border: Border.all(
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.40)),
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                        style: boldPoppins(12,
                            textColor: Colors.deepPurpleAccent)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(steps[i],
                      style: regularPoppins(13, textColor: Colors.white70)),
                ),
              ],
            ),
            if (i < steps.length - 1)
              const Divider(color: Colors.white10, height: 20),
          ],
        ],
      ),
    );
  }
}

/// Horizontal row of compatible TV/platform chips.
class _TvCompatRow extends StatelessWidget {
  const _TvCompatRow();

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.tv_rounded,             label: 'LG webOS'),
      (icon: Icons.tv_rounded,             label: 'Samsung'),
      (icon: Icons.cast_rounded,           label: 'DLNA TV'),
      (icon: Icons.smart_display_rounded,  label: 'Smart TV'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 15, color: Colors.deepPurpleAccent),
                const SizedBox(width: 6),
                Text(item.label,
                    style: regularPoppins(12, textColor: Colors.white60)),
              ],
            ),
          ),
      ],
    );
  }
}
