import 'package:codex_share/presentation/controllers/send_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';

enum DockTab { home, radar, vault, log }

class AppDockNav extends StatelessWidget {
  const AppDockNav({super.key, required this.active});

  final DockTab active;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 8, 18, 14),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _DockItem(
              icon: Icons.grid_view_rounded,
              label: 'Home',
              active: active == DockTab.home,
              onTap: () {
                _clearSelections();
                Get.offAllNamed(AppRoutes.home);
              },
            ),
            _DockItem(
              icon: Icons.radar_rounded,
              label: 'Radar',
              active: active == DockTab.radar,
              onTap: () {
                _clearSelections();
                Get.offAllNamed(AppRoutes.discovery);
              },
            ),
            _DockItem(
              icon: Icons.folder_open_rounded,
              label: 'Vault',
              active: active == DockTab.vault,
              onTap: () {
                _clearSelections();
                Get.offAllNamed(AppRoutes.send);
              },
            ),
            _DockItem(
              icon: Icons.history_toggle_off_rounded,
              label: 'Log',
              active: active == DockTab.log,
              onTap: () {
                _clearSelections();
                Get.offAllNamed(AppRoutes.history);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearSelections() {
    if (Get.isRegistered<SendController>()) {
      Get.find<SendController>().selectedFiles.clear();
    }
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.gold.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.16),
                    blurRadius: 24,
                    spreadRadius: -8,
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? AppTheme.gold : AppTheme.textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? AppTheme.gold : AppTheme.textMuted,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
