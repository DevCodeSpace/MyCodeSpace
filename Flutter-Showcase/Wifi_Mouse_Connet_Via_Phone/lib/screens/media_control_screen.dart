import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mouse_demo/controllers/trackpad_controller.dart';
import 'package:mouse_demo/helper/preference_helper.dart';
import 'package:mouse_demo/theme/app_colors.dart';

class MediaControlScreen extends GetView<TrackpadController> {
  const MediaControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.desktopName.value.toUpperCase()),
            Text(controller.ipAddress.value, style: TextStyle(fontSize: 14, color: AppColors.primary)),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Media Controls', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(color: PreferenceHelper.isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight, borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.skip_previous_rounded),
                          tooltip: 'Previous',
                          onPressed: () => controller.send({"type": "key_tap", "key": "audio_prev"}),
                        ),
                        IconButton.filled(
                          iconSize: 56,
                          icon: const Icon(Icons.play_arrow_rounded),
                          tooltip: 'Play/Pause',
                          onPressed: () => controller.send({"type": "key_tap", "key": "audio_play"}),
                        ),
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.skip_next_rounded),
                          tooltip: 'Next',
                          onPressed: () => controller.send({"type": "key_tap", "key": "audio_next"}),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(Icons.volume_down_rounded),
                          tooltip: 'Volume Down',
                          onPressed: () => controller.send({"type": "key_tap", "key": "audio_vol_down"}),
                        ),
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(Icons.volume_off_rounded),
                          tooltip: 'Mute / Unmute',
                          onPressed: () => controller.send({"type": "key_tap", "key": "audio_mute"}),
                        ),
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(Icons.volume_up_rounded),
                          tooltip: 'Volume Up',
                          onPressed: () => controller.send({"type": "key_tap", "key": "audio_vol_up"}),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
