import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../domain/entities/transfer_history_entry.dart';
import '../controllers/history_controller.dart';
import '../widgets/app_dock_nav.dart';
import '../widgets/app_shell.dart';
import '../widgets/brand_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/history_entry_sheet.dart';
import '../widgets/history_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final List<String> _tabs = ['All', 'Sent', 'Received'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    return AppShell(
      activeTab: DockTab.log,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandHeader(showSearch: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logs',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TRANSACTION REGISTRY',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    letterSpacing: 1.8,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 56,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.panelBlue,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.12),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final tabWidth = (constraints.maxWidth) / _tabs.length;
                      return Stack(
                        children: [
                          // Sliding Background
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            left: _currentIndex * tabWidth,
                            width: tabWidth,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.gold.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    spreadRadius: -4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Tab Text Items
                          Row(
                            children: _tabs.asMap().entries.map((entry) {
                              final index = entry.key;
                              final label = entry.value;
                              final active = _currentIndex == index;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _onTabTapped(index),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      style: TextStyle(
                                        color: active
                                            ? AppTheme.gold
                                            : AppTheme.textMuted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                      child: Text(label),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                _buildHistoryList(controller, 'All'),
                _buildHistoryList(controller, 'Sent'),
                _buildHistoryList(controller, 'Received'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(HistoryController controller, String filter) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final entries = _applyFilter(controller.entries, filter);
      if (entries.isEmpty) {
        return const EmptyState(
          icon: Icons.history_toggle_off_rounded,
          title: 'No logs yet',
          subtitle: 'Completed transfers will settle here.',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: HistoryTile(
              entry: entry,
              onTap: () => HistoryEntrySheet.showDetails(entry),
              onLongPress: () => HistoryEntrySheet.showActions(entry),
            ),
          );
        },
      );
    });
  }

  List<TransferHistoryEntry> _applyFilter(
    List<TransferHistoryEntry> entries,
    String filter,
  ) {
    return switch (filter) {
      'Sent' =>
        entries
            .where((entry) => entry.direction == TransferDirection.sent)
            .toList(),
      'Received' =>
        entries
            .where((entry) => entry.direction == TransferDirection.received)
            .toList(),
      _ => entries,
    };
  }
}
