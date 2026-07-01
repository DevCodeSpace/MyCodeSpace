import 'package:flutter/material.dart';

import '../../utils/text_styles.dart';

/// Reusable "Stop Casting" full-width button.
///
/// Used on both [CastingView] (WiFi cast) and [PublicStreamView] (browser cast)
/// to keep the active-session stop action visually consistent.
class CastingControls extends StatelessWidget {
  /// Called when the user taps "Stop Casting".
  final VoidCallback onStop;

  /// Accent colour that tints the button background (matches each screen's theme).
  final Color accentColor;

  const CastingControls({
    super.key,
    required this.onStop,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onStop,
      icon: const Icon(Icons.stop_rounded),
      label: const Text('Stop Casting'),
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: boldPoppins(18),
      ),
    );
  }
}
