import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../controllers/connection_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/action_card.dart';
import '../widgets/app_dock_nav.dart';
import '../widgets/app_shell.dart';
import '../widgets/brand_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/frosted_panel.dart';
import '../widgets/history_entry_sheet.dart';
import '../widgets/history_tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionController = Get.find<ConnectionController>();
    return AppShell(
      activeTab: DockTab.home,
      child: Column(
        children: [
          const BrandHeader(showBell: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
              children: [
                Obx(
                  () => FrostedPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: AppTheme.panelBlue,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Icon(
                                      Icons.radar_rounded,
                                      color: AppTheme.gold,
                                      size: 30,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB38A),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.panel,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    connectionController.isConnected.value
                                        ? 'Connected to ${connectionController.connectedDevice.value?.name ?? 'NODE'}'
                                        : 'Ready to Pair',
                                    style: const TextStyle(
                                      color: AppTheme.textSoft,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    connectionController.isConnected.value
                                        ? (connectionController.connectedDevice.value?.name ?? 'X-PHANTOM_NODE').toUpperCase()
                                        : 'SEARCHING FOR NODES...',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (connectionController.isConnected.value) ...[
                              _SecondaryButtonPill(
                                label: 'Disconnect',
                                onTap: connectionController.confirmDisconnect,
                              ),
                              const SizedBox(width: 12),
                            ],
                            PrimaryButtonPill(
                              label: connectionController.isConnected.value
                                  ? 'Switch Node'
                                  : 'Scan Network',
                              onTap: () => Get.toNamed(AppRoutes.discovery),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: ActionCard(
                          title: 'Send Files',
                          subtitle: 'Deploy data pack',
                          icon: Icons.arrow_outward_rounded,
                          onTap: () => Get.toNamed(AppRoutes.send),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ActionCard(
                          title: 'Receive',
                          subtitle: 'Accept incoming',
                          icon: Icons.download_rounded,
                          onTap: () => Get.toNamed(AppRoutes.discovery),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.history),
                      child: const Text(
                        'VIEW VAULT',
                        style: TextStyle(color: AppTheme.textSoft),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (controller.recentTransfers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: EmptyState(
                        icon: Icons.history_toggle_off_rounded,
                        title: 'No activity yet',
                        subtitle: 'Your latest transfers will appear here.',
                      ),
                    );
                  }
                  return Column(
                    children: controller.recentTransfers.take(3).map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: HistoryTile(
                          entry: entry,
                          onTap: () => HistoryEntrySheet.showDetails(entry),
                          onLongPress: () =>
                              HistoryEntrySheet.showActions(entry),
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 14),
                Obx(() {
                  final items = controller.recentTransfers.length;
                  final totalVolume = controller.recentTransfers.fold<int>(
                    0,
                    (sum, entry) => sum + entry.fileSize,
                  );
                  final nodes = controller.recentTransfers
                      .map((entry) => entry.peerName)
                      .toSet()
                      .length;
                  return Row(
                    children: [
                      Expanded(
                        child: _StatPanel(label: 'ITEMS', value: '$items'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPanel(
                          label: 'VOLUME',
                          value: Formatters.fileSize(totalVolume),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPanel(
                          label: 'NODES',
                          value: nodes.toString().padLeft(2, '0'),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.goldSoft,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryButtonPill extends StatelessWidget {
  const PrimaryButtonPill({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.gold,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.background,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButtonPill extends StatelessWidget {
  const _SecondaryButtonPill({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.panelBlue,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
