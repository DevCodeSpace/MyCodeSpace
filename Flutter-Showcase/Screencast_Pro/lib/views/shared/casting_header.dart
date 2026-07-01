import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/text_styles.dart';

/// Reusable animated header shown at the top of any active casting screen.
///
/// Displays a pulsing WiFi icon, a subtitle [title], and a live elapsed-time
/// clock driven by the reactive [elapsed] observable.
class CastingHeader extends StatelessWidget {
  /// Looping animation controller that drives the icon fade/pulse effect.
  final AnimationController pulseController;

  /// Reactive elapsed duration — the clock updates automatically via [Obx].
  final Rx<Duration> elapsed;

  /// Colour used for the icon and to tint the time display.
  final Color accentColor;

  /// Small label shown above the timer, e.g. "NOW CASTING TO BROWSER".
  final String title;

  const CastingHeader({
    super.key,
    required this.pulseController,
    required this.elapsed,
    required this.accentColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pulsing WiFi tethering icon — visual heartbeat confirming a live session.
        FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1.0).animate(pulseController),
          child: Icon(Icons.wifi_tethering, size: 80, color: accentColor),
        ),
        const SizedBox(height: 20),

        // Screen label — e.g. "NOW CASTING TO BROWSER"
        Text(title, style: regularPoppins(13, textColor: Colors.white54)),
        const SizedBox(height: 8),

        // Live elapsed timer — rebuilt every second via Obx
        Obx(() {
          final time = elapsed.value;
          final min = time.inMinutes.remainder(60).toString().padLeft(2, '0');
          final sec = time.inSeconds.remainder(60).toString().padLeft(2, '0');
          return Text(
            '$min:$sec',
            style: boldPoppins(48, textColor: Colors.white),
          );
        }),
      ],
    );
  }
}
