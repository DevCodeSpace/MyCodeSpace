import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../providers/settings_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                "Settings",
                style: context.textStyles.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                value: settings.darkMode,
                onChanged: (_) => notifier.toggleDarkMode(),
                title: const Text("Dark Mode"),
              ),

              SwitchListTile(
                value: settings.soundEnabled,
                onChanged: (_) => notifier.toggleSound(),
                title: const Text("Sound"),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}