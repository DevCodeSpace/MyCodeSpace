import 'package:codex_share/presentation/widgets/app_dock_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/shared_file.dart';
import '../controllers/connection_controller.dart';
import '../controllers/send_controller.dart';
import '../widgets/app_shell.dart';
import '../widgets/brand_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/frosted_panel.dart';
import '../widgets/history_entry_sheet.dart';
import '../widgets/history_tile.dart';
import '../widgets/primary_action_button.dart';

class SendScreen extends GetView<SendController> {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionController = Get.find<ConnectionController>();
    return AppShell(
      activeTab: DockTab.vault,
      bottomNavigationBar: Obx(() {
        final isConnected = connectionController.isConnected.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            border: Border(top: Border.all(color: AppTheme.borderGold.withValues(alpha: 0.1)).top),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Selection Info
                SizedBox(
                  width: 130,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${controller.selectedFiles.length} Items', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        'SIZE: ${controller.totalSelectedSizeLabel}',
                        style: TextStyle(color: AppTheme.gold.withValues(alpha: 0.7), fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Action Button
                Expanded(
                  child: PrimaryActionButton(
                    label: controller.isPreparing.value
                        ? 'Sending...'
                        : isConnected
                        ? 'Send to ${connectionController.connectedDevice.value?.name ?? 'Device'}'
                        : 'Connect Device',
                    icon: isConnected ? Icons.arrow_forward_rounded : Icons.radar_rounded,
                    enabled: controller.selectedFiles.isNotEmpty && !controller.isPreparing.value,
                    onTap: controller.sendSelectedFiles,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            const BrandHeader(),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 400) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          children: [
                            Obx(
                              () => FrostedPanel(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 82,
                                      height: 82,
                                      decoration: BoxDecoration(color: AppTheme.panelBlue, borderRadius: BorderRadius.circular(24)),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Icon(
                                              connectionController.isConnected.value ? Icons.laptop_mac_rounded : Icons.portable_wifi_off_rounded,
                                              color: AppTheme.goldSoft,
                                              size: 34,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: AppTheme.goldSoft,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppTheme.panel, width: 2),
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
                                          const Text('CONNECTED TO', style: TextStyle(color: AppTheme.textMuted, letterSpacing: 1.5, fontSize: 12)),
                                          const SizedBox(height: 6),
                                          Text(
                                            connectionController.isConnected.value
                                                ? (connectionController.connectedDevice.value?.name ?? 'VALKYRIE-01 PRO').toUpperCase()
                                                : 'NO PAIRED DEVICE',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => Get.toNamed(AppRoutes.discovery),
                                      icon: const Icon(Icons.sync_alt_rounded, color: AppTheme.goldSoft),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                    // 1. Library Header (Always visible tabs)
                    Obx(() {
                      final tab = controller.activeTab.value;
                      final sectionTitle = tab == SendLibraryTab.images
                          ? 'Recent Media'
                          : tab == SendLibraryTab.videos
                          ? 'Video Library'
                          : tab == SendLibraryTab.files
                          ? 'Document Vault'
                          : 'Installed Applications';

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(
                          child: _LibraryHeader(title: sectionTitle, controller: controller),
                        ),
                      );
                    }),

                    // 2. Tab Content
                    Obx(() {
                      final tab = controller.activeTab.value;
                      final visibleFiles = controller.visibleFiles;
                      final isLoading = controller.isLoadingLibrary.value;

                      if (tab == SendLibraryTab.recent) {
                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          sliver: SliverToBoxAdapter(child: _RecentTabView(controller: controller)),
                        );
                      }

                      if (isLoading) {
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverToBoxAdapter(
                            child: _PanelItemWrapper(
                              isLast: true,
                              child: Container(height: 200, alignment: Alignment.center, child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                          ),
                        );
                      }

                      if (visibleFiles.isEmpty) {
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverToBoxAdapter(
                            child: _PanelItemWrapper(
                              isLast: true,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: EmptyState(
                                  icon: Icons.layers_clear_rounded,
                                  title: 'Nothing surfaced yet',
                                  subtitle: 'Grant storage access and your device library will appear here.',
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final isGrid = tab == SendLibraryTab.images || tab == SendLibraryTab.videos;

                      return SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = (constraints.crossAxisExtent / 110).floor().clamp(3, 8);
                          
                          // Determine items for grid or list
                          final List<dynamic> listItems = [];
                          if (isGrid) {
                            for (var i = 0; i < visibleFiles.length; i += crossAxisCount) {
                              listItems.add(visibleFiles.sublist(i, i + crossAxisCount > visibleFiles.length ? visibleFiles.length : i + crossAxisCount));
                            }
                          } else {
                            listItems.addAll(visibleFiles);
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((context, index) {
                                final isLast = index == listItems.length - 1;
                                final item = listItems[index];

                                return _PanelItemWrapper(
                                  isLast: isLast,
                                  child: isGrid ? _MediaRow(files: item as List<SharedFile>, controller: controller, columns: crossAxisCount) : _FileTile(file: item as SharedFile, controller: controller),
                                );
                              }, childCount: listItems.length),
                            ),
                          );
                        },
                      );
                    }),
                    Obx(() {
                      if (controller.isLoadingMore.value) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox(height: 100));
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({required this.title, required this.controller});

  final String title;
  final SendController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: AppTheme.frostedDecoration(
        radius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: SendLibraryTab.values.map((tab) {
                final isActive = controller.activeTab.value == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _LibraryTabChip(label: _tabLabel(tab), active: isActive, onTap: () => controller.setActiveTab(tab)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(color: AppTheme.surfaceRaised, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: controller.searchTextController,
                    onChanged: controller.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search files and packages...',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      border: InputBorder.none,
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return IconButton(
                          onPressed: controller.clearSearch,
                          icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 20),
                        );
                      }),
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              if (controller.activeTab.value == SendLibraryTab.files && controller.pathHistory.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: controller.navigateBack,
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.gold),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelItemWrapper extends StatelessWidget {
  const _PanelItemWrapper({required this.child, required this.isLast});

  final Widget child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: Border(
          left: BorderSide(color: AppTheme.borderGold.withValues(alpha: 0.35)),
          right: BorderSide(color: AppTheme.borderGold.withValues(alpha: 0.35)),
          bottom: isLast ? BorderSide(color: AppTheme.borderGold.withValues(alpha: 0.35)) : BorderSide.none,
        ),
        borderRadius: isLast ? const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)) : null,
      ),
      child: child,
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({required this.files, required this.controller, required this.columns});

  final List<SharedFile> files;
  final SendController controller;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ...files.map(
            (file) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: AspectRatio(
                  aspectRatio: 0.78,
                  child: _MediaItem(file: file, controller: controller),
                ),
              ),
            ),
          ),
          // Fill empty spots if last row has < columns items
          ...List.generate(columns - files.length, (_) => const Expanded(child: SizedBox())),
        ],
      ),
    );
  }
}

class _MediaItem extends StatelessWidget {
  const _MediaItem({required this.file, required this.controller});

  final SharedFile file;
  final SendController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.isSelected(file);
      return GestureDetector(
        onTap: () => controller.toggleSelection(file),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? AppTheme.gold.withValues(alpha: 0.42) : Colors.white.withValues(alpha: 0.06)),
            color: Colors.white.withValues(alpha: 0.04),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _FilePreview(file: file),
              Positioned(right: 10, top: 10, child: _SelectionIndicator(selected: selected)),
              if (file.durationMillis != null)
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Text(
                    _formatDuration(file.durationMillis!),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({required this.file, required this.controller});

  final SharedFile file;
  final SendController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Obx(() {
        final selected = controller.isSelected(file);
        return InkWell(
          onTap: file.isFolder ? () => controller.navigateToDirectory(file) : () => controller.toggleSelection(file),
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? AppTheme.panelBlue : AppTheme.panel.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: selected ? AppTheme.gold.withValues(alpha: 0.50) : AppTheme.gold.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                _FilePreview(file: file, small: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        file.secondaryLabel ?? Formatters.fileSize(file.size),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!file.isFolder) _SelectionIndicator(selected: selected),
                if (file.isFolder) const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// class _SelectionList extends StatelessWidget {
//   const _SelectionList({required this.controller, required this.files});

//   final SendController controller;
//   final List<SharedFile> files;

//   @override
//   Widget build(BuildContext context) {
//     return const SliverToBoxAdapter(
//       child: SizedBox.shrink(),
//     ); // Replaced by _FileTile in main list
//   }
// }

// class _MediaGrid extends StatelessWidget {
//   const _MediaGrid({required this.controller, required this.files});

//   final SendController controller;
//   final List<SharedFile> files;

//   @override
//   Widget build(BuildContext context) {
//     return const SliverToBoxAdapter(
//       child: SizedBox.shrink(),
//     ); // Replaced by _MediaRow in main list
//   }
// }

class _RecentTabView extends StatelessWidget {
  const _RecentTabView({required this.controller});

  final SendController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.recentEntries.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 26),
          child: EmptyState(icon: Icons.history_rounded, title: 'No recent transfers', subtitle: 'Completed sends and receives will appear here for quick reuse.'),
        );
      }

      return Column(
        children: controller.recentEntries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: HistoryTile(entry: entry, onTap: () => HistoryEntrySheet.showDetails(entry), onLongPress: () => HistoryEntrySheet.showActions(entry)),
          );
        }).toList(),
      );
    });
  }
}

class _LibraryTabChip extends StatelessWidget {
  const _LibraryTabChip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: active ? AppTheme.gold : AppTheme.panelBlue,
          border: Border.all(color: active ? AppTheme.gold.withValues(alpha: 0.32) : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(
          label,
          style: TextStyle(color: active ? AppTheme.background : AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppTheme.goldSoft : Colors.transparent,
        border: Border.all(color: selected ? AppTheme.goldSoft : Colors.white.withValues(alpha: 0.16)),
      ),
      child: selected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
    );
  }
}

class _FilePreview extends StatelessWidget {
  const _FilePreview({required this.file, this.small = false});

  final SharedFile file;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SendController>();
    final radius = BorderRadius.circular(small ? 16 : 20);
    final iconSize = small ? 20.0 : 30.0;
    final dimension = small ? 48.0 : double.infinity;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: small ? dimension : null,
        height: small ? dimension : null,
        child: Obx(() {
          final cachedBytes = controller.thumbnailCache[file.path];

          if (cachedBytes != null) {
            return Image.memory(cachedBytes, fit: BoxFit.cover);
          }

          // If not in cache and it's a category that should have a thumbnail, trigger load
          if (file.category == FileCategory.image || file.category == FileCategory.video || file.category == FileCategory.app) {
            // Trigger loading if not already loading
            controller.getThumbnail(file);

            return Container(
              color: const Color(0xFF221C1A),
              alignment: Alignment.center,
              child: Icon(_iconFor(file.category), color: AppTheme.gold.withValues(alpha: 0.5), size: iconSize),
            );
          }

          return Container(
            color: const Color(0xFF221C1A),
            alignment: Alignment.center,
            child: Icon(file.isFolder ? Icons.folder_rounded : _iconFor(file.category), color: AppTheme.gold, size: iconSize),
          );
        }),
      ),
    );
  }

  IconData _iconFor(FileCategory category) {
    return switch (category) {
      FileCategory.app => Icons.android_rounded,
      FileCategory.image => Icons.image_rounded,
      FileCategory.video => Icons.videocam_rounded,
      FileCategory.audio => Icons.graphic_eq_rounded,
      FileCategory.document => Icons.insert_drive_file_rounded,
    };
  }
}

String _tabLabel(SendLibraryTab tab) {
  return switch (tab) {
    SendLibraryTab.apps => 'Apps',
    SendLibraryTab.files => 'Files',
    SendLibraryTab.images => 'Images',
    SendLibraryTab.videos => 'Videos',
    SendLibraryTab.recent => 'Recent',
  };
}

String _formatDuration(int durationMillis) {
  final totalSeconds = (durationMillis / 1000).round();
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
