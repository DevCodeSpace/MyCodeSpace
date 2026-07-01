import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_app_usage/core/models/usage_model.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_icon_widget.dart';
import '../../core/services/usage_service.dart';
import 'apps_controller.dart';

class InstalledAppsView extends StatelessWidget {
  const InstalledAppsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AppsController());

    return Scaffold(
      backgroundColor: GlacierColors.background,
      appBar: AppBar(
        backgroundColor: GlacierColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Installed Apps',
          style: GlacierTextStyles.titleLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Permission Banner
            Obx(() {
              final service = Get.find<UsageService>();
              if (Platform.isAndroid && !service.isPermissionGranted.value) {
                return _PermissionBanner(service: service);
              }
              return const SizedBox.shrink();
            }),

            // Search Bar
            buildSearchField(controller),
            const SizedBox(height: 12),

            // Category Chips
            buildCategoryChips(controller),
            const SizedBox(height: 12),

            // App List
            Expanded(
              child: Obx(() {
                final list = controller.filteredApps;
                if (list.isEmpty) {
                  return _EmptyState();
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 90),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final app = list[index];
                    return buildAppTile(app);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchField(AppsController controller) {
    return TextField(
      controller: controller.searchController,
      style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface),
      decoration: InputDecoration(
        hintText: 'Search apps...',
        hintStyle: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.35)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(Icons.search_rounded, color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.5), size: 19),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: GlacierColors.surfaceBright.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: GlacierColors.surfaceBright.withValues(alpha: 0.4)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        filled: true,
        fillColor: GlacierColors.surfaceContainerLow.withValues(alpha: 0.25),
      ),
      onTapOutside: (_) => FocusScope.of(Get.context!).unfocus(),
    );
  }

  Widget buildCategoryChips(AppsController controller) {
    return SizedBox(
      height: 32,
      child: Obx(() {
        final selectedCategory = controller.selectedCategory.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = selectedCategory == category;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected ? GlacierColors.surfaceBright : GlacierColors.surfaceContainerLow.withValues(alpha: 0.25),
                border: Border.all(
                  color: isSelected ? GlacierColors.primary.withValues(alpha: 0.5) : GlacierColors.outlineVariant.withValues(alpha: 0.12),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () => controller.changeCategory(category),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        category,
                        style: GlacierTextStyles.bodySmall.copyWith(
                          color: isSelected ? GlacierColors.primary : GlacierColors.onSurfaceVariant.withValues(alpha: 0.6),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget buildAppTile(AppUsageInfo app) {
    final hours = app.elapsedMinutes ~/ 60;
    final minutes = (app.elapsedMinutes % 60).toInt();
    final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    final limitHours = app.limit != null ? app.limit!.limitMinutes ~/ 60 : 0;
    final limitMinutes = app.limit != null ? (app.limit!.limitMinutes % 60).toInt() : 0;
    final formattedLimit = limitHours > 0 && limitMinutes > 0
        ? 'Limit: ${limitHours}h ${limitMinutes}m'
        : limitHours > 0
        ? 'Limit: ${limitHours}h'
        : 'Limit: ${limitMinutes}m';

    final double usageRatio = app.limit != null ? (app.elapsedMinutes / app.limit!.limitMinutes).clamp(0.0, 1.0) : 0.0;

    final bool exceeded = app.isLimitExceeded == true;
    final Color accentColor = exceeded ? GlacierColors.error : GlacierColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.appDetails, arguments: app),
        borderRadius: BorderRadius.circular(16),
        splashColor: GlacierColors.primary.withValues(alpha: 0.06),
        highlightColor: GlacierColors.primary.withValues(alpha: 0.03),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [GlacierColors.surfaceContainerLow.withValues(alpha: 0.45), GlacierColors.surfaceContainerLow.withValues(alpha: 0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // App Icon
                          Hero(
                            tag: 'app_icon_${app.id}',
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: AppIconWidget(packageName: app.id, iconBytes: app.appIconBytes, iconData: app.icon, color: app.themeColor, size: 28),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // App name + category
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.name,
                                  style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.w700, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(app.category, style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.55), fontSize: 11)),
                              ],
                            ),
                          ),

                          // Time + status badge
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formattedTime,
                                style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.w800, fontSize: 15),
                              ),
                              if (app.limit != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    exceeded ? '⚠ Exceeded' : formattedLimit,
                                    style: GlacierTextStyles.labelSmall.copyWith(fontSize: 9, color: accentColor, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.chevron_right_rounded, color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.35), size: 18),
                        ],
                      ),

                      // Progress bar (only if limit is set)
                      if (app.limit != null) ...[const SizedBox(height: 10), _UsageProgressBar(ratio: usageRatio, exceeded: exceeded, accentColor: accentColor)],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Permission Banner ───────────────────────────────────────────────────────

class _PermissionBanner extends StatefulWidget {
  final UsageService service;
  const _PermissionBanner({required this.service});

  @override
  State<_PermissionBanner> createState() => _PermissionBannerState();
}

class _PermissionBannerState extends State<_PermissionBanner> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [GlacierColors.primary.withValues(alpha: 0.08), GlacierColors.primary.withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: GlacierColors.primary.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, _) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GlacierColors.primary.withValues(alpha: 0.1 + _pulseController.value * 0.12),
                ),
                child: const Icon(Icons.shield_outlined, color: GlacierColors.primary, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking Disabled',
                    style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    'Grant access to monitor real usage',
                    style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => widget.service.requestUsagePermission(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: GlacierColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GlacierColors.primary.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'Enable',
                  style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Usage Progress Bar ──────────────────────────────────────────────────────

class _UsageProgressBar extends StatefulWidget {
  final double ratio;
  final bool exceeded;
  final Color accentColor;

  const _UsageProgressBar({required this.ratio, required this.exceeded, required this.accentColor});

  @override
  State<_UsageProgressBar> createState() => _UsageProgressBarState();
}

class _UsageProgressBarState extends State<_UsageProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _barAnim = Tween<double>(begin: 0, end: widget.ratio).animate(CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () => _barController.forward());
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _barAnim,
      builder: (_, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final fillWidth = (trackWidth * _barAnim.value).clamp(0.0, trackWidth);

            return Container(
              height: 4,
              width: trackWidth,
              decoration: BoxDecoration(color: GlacierColors.surfaceContainerHigh.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(10)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: fillWidth,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: widget.exceeded ? [GlacierColors.error.withValues(alpha: 0.8), GlacierColors.error] : [widget.accentColor.withValues(alpha: 0.7), widget.accentColor],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: GlacierColors.surfaceContainerLow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: GlacierColors.outlineVariant.withValues(alpha: 0.15)),
            ),
            child: Icon(Icons.apps_rounded, color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.3), size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            'No matching apps found',
            style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text('Try a different search or category', style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.35), fontSize: 11)),
        ],
      ),
    );
  }
}
