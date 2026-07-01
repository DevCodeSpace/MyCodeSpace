// lib/app/modules/attendance/history_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/attendance_model.dart';
import 'attendance_controller.dart';

class HistoryView extends GetView<AttendanceController> {
  final isAdvancedExpanded = false.obs;

  HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1423),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "LOGS FEED · ${controller.todayLabel.toUpperCase()}",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Color(0xFF00E5FF)),
        ),
      ),
      body: Obx(() {
        if (controller.records.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint_rounded, size: 80, color: Color(0xFFCDD6E8)),
                SizedBox(height: 16),
                Text(
                  'NO BIOMETRIC SCANS FILED YET',
                  style: TextStyle(color: Color(0xFFAABBCC), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Beautiful Summary Console Deck (Summary + Filters) ───────────
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F1423),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                children: [
                  // Console Metrics Chips
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ConsoleChip('Staff', '${controller.employees.length}', Colors.white),
                        _VerticalDivider(),
                        _ConsoleChip('Present', '${controller.presentCount}', const Color(0xFF00C853)),
                        _VerticalDivider(),
                        _ConsoleChip('Absent', '${controller.absentCount}', const Color(0xFFFF3D00)),
                        _VerticalDivider(),
                        _ConsoleChip('Late', '${controller.lateCount}', const Color(0xFFFFB300)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar & Filter Toggle Row
                  Row(
                    children: [
                      Expanded(child: _SearchField(controller: controller)),
                      _buildAdvancedToggle(),
                    ],
                  ),

                  // Horizontal Quick Status Chips
                  _buildStatusQuickFilter(),

                  // Collapsible Advanced Settings Panel
                  _buildAdvancedPanel(),
                ],
              ),
            ),

            // ── Chronological Timeline Feed ──────────────────────────────
            Expanded(
              child: Obx(() {
                final records = controller.filteredRecords;
                if (records.isEmpty) {
                  return _buildEmptyFilterState();
                }

                return ListView.builder(
                  key: const PageStorageKey('logs_timeline_list'),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  itemCount: records.length,
                  itemBuilder: (_, i) {
                    final isFirst = i == 0;
                    final isLast = i == records.length - 1;
                    return _AnimatedFadeSlide(
                      key: ValueKey(records[i].id),
                      index: i,
                      child: _TimelineRecordTile(record: records[i], isFirst: isFirst, isLast: isLast),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  // ── Advanced Filters Toggle Button ─────────────────────────────────────────
  Widget _buildAdvancedToggle() {
    return Obx(() {
      final isExpanded = isAdvancedExpanded.value;
      final hasActiveFilter = controller.isFilterActive;
      return GestureDetector(
        onTap: () => isAdvancedExpanded.toggle(),
        child: Container(
          margin: const EdgeInsets.only(left: 10),
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: isExpanded ? const Color(0xFF00E5FF).withValues(alpha: 0.12) : const Color(0xFF1E294B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isExpanded ? const Color(0xFF00E5FF) : (hasActiveFilter ? const Color(0xFFFFB300) : const Color(0xFF2E3B5E)), width: 1.5),
            boxShadow: isExpanded ? [BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.15), blurRadius: 8, spreadRadius: 1)] : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Icon(Icons.tune_rounded, color: isExpanded ? const Color(0xFF00E5FF) : Colors.white, size: 20),
              ),
              if (hasActiveFilter && !isExpanded)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFFFFB300), shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  // ── Horizontal Quick Status Filter Chips ──────────────────────────────────
  Widget _buildStatusQuickFilter() {
    final statuses = [
      _StatusChipData('ALL', null, const Color(0xFF00E5FF), Icons.grid_view_rounded),
      _StatusChipData('PRESENT', AttendanceStatus.present, const Color(0xFF00C853), Icons.login_rounded),
      _StatusChipData('LATE', AttendanceStatus.late, const Color(0xFFFFB300), Icons.alarm_rounded),
      _StatusChipData('CHECKED OUT', AttendanceStatus.checkedOut, const Color(0xFF1E88E5), Icons.logout_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Obx(() {
        final current = controller.selectedStatus.value;
        return Row(
          children: statuses.map((s) {
            final isSelected = current == s.status;
            return GestureDetector(
              onTap: () => controller.selectedStatus.value = s.status,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? s.color.withValues(alpha: 0.15) : const Color(0xFF1E294B).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? s.color : const Color(0xFF2E3B5E), width: 1.5),
                  boxShadow: isSelected ? [BoxShadow(color: s.color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.icon, color: isSelected ? s.color : Colors.white54, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      s.label,
                      style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  // ── Collapsible Advanced Filter Settings Deck ──────────────────────────────
  Widget _buildAdvancedPanel() {
    return Obx(() {
      final isExpanded = isAdvancedExpanded.value;
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: isExpanded
            ? Container(
                margin: const EdgeInsets.only(top: 14, bottom: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E3B5E), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDepartmentFilter(),
                    const SizedBox(height: 16),
                    _buildConfidenceSlider(),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 12),
                    _buildSortingAndReset(),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }

  // ── Department Filter Pills ───────────────────────────────────────────────
  Widget _buildDepartmentFilter() {
    final depts = ['', 'Engineering', 'Design', 'Marketing', 'HR', 'Finance'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DEPARTMENT',
          style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Obx(() {
            final current = controller.selectedDepartment.value;
            return Row(
              children: depts.map((d) {
                final isSelected = (d.isEmpty && current.isEmpty) || (d.toLowerCase() == current.toLowerCase());
                final label = d.isEmpty ? 'ALL' : d.toUpperCase();
                return GestureDetector(
                  onTap: () => controller.selectedDepartment.value = d,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00E5FF).withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFF2E3B5E), width: 1.2),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ],
    );
  }

  // ── Facial Match Confidence Filter Slider ──────────────────────────────────
  Widget _buildConfidenceSlider() {
    return Obx(() {
      final val = controller.minConfidence.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MIN MATCH CONFIDENCE',
                style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0),
              ),
              Text(
                '${val.toStringAsFixed(0)}%+',
                style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              activeTrackColor: const Color(0xFF00E5FF),
              inactiveTrackColor: const Color(0xFF1E294B),
              thumbColor: const Color(0xFF00E5FF),
              overlayColor: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(value: val, min: 0, max: 100, divisions: 10, onChanged: (newVal) => controller.minConfidence.value = newVal),
          ),
        ],
      );
    });
  }

  // ── Sorting and Reset Panel ────────────────────────────────────────────────
  Widget _buildSortingAndReset() {
    final sortOptions = [
      {'label': 'NEWEST', 'value': 'newest'},
      {'label': 'OLDEST', 'value': 'oldest'},
      {'label': 'MATCH %', 'value': 'confidence'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sorting Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SORT BY',
              style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final current = controller.sortBy.value;
              return Row(
                children: sortOptions.map((opt) {
                  final isSelected = current == opt['value'];
                  return GestureDetector(
                    onTap: () => controller.sortBy.value = opt['value']!,
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E294B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : Colors.white10, width: 1),
                      ),
                      child: Text(
                        opt['label']!,
                        style: TextStyle(color: isSelected ? const Color(0xFF00E5FF) : Colors.white38, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),

        // Reset Button Column
        Obx(() {
          final hasActiveFilter = controller.isFilterActive;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hasActiveFilter ? 1.0 : 0.4,
            child: IgnorePointer(
              ignoring: !hasActiveFilter,
              child: TextButton.icon(
                onPressed: () => controller.resetFilters(),
                icon: const Icon(Icons.refresh_rounded, size: 12, color: Color(0xFFFF5252)),
                label: const Text(
                  'RESET ALL',
                  style: TextStyle(color: Color(0xFFFF5252), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: Color(0xFFFF5252), width: 0.8),
                  ),
                  backgroundColor: const Color(0xFFFF5252).withValues(alpha: 0.05),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Biometric Empty Scanner Pulse Filter State ─────────────────────────────
  Widget _buildEmptyFilterState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(scale: 0.9 + (value * 0.1), child: child),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cyber pulsing search radar icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB300).withValues(alpha: 0.05),
                border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.15), width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const _RadarRing(delay: 0),
                  const _RadarRing(delay: 1),
                  const Icon(Icons.fingerprint_rounded, size: 40, color: Color(0xFFFFB300)),
                  Positioned(
                    right: 22,
                    bottom: 22,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Color(0xFF0F1423), shape: BoxShape.circle),
                      child: const Icon(Icons.search, size: 14, color: Color(0xFF00E5FF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NO SCAN LOGS FOUND',
              style: TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'No biometric records match your active query or filters. Refine your options below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.resetFilters(),
              icon: const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF0F1423)),
              label: const Text(
                'RESET ACTIVE FILTERS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF0F1423)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                elevation: 2,
                shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Field StatefulWidget (Preserves keyboard focus perfectly) ──────────
class _SearchField extends StatefulWidget {
  final AttendanceController controller;
  const _SearchField({required this.controller});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.searchQuery.value);

    // Synchronize external clears (e.g. "RESET ALL" button)
    widget.controller.searchQuery.listen((val) {
      if (val.isEmpty && _textController.text.isNotEmpty) {
        _textController.clear();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final query = widget.controller.searchQuery.value;
      final hasQuery = query.isNotEmpty;
      return Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF1E294B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasQuery ? const Color(0xFF00E5FF) : const Color(0xFF2E3B5E), width: 1.5),
          boxShadow: hasQuery ? [BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.15), blurRadius: 8, spreadRadius: 1)] : null,
        ),
        child: TextField(
          controller: _textController,
          onChanged: (val) => widget.controller.searchQuery.value = val,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints(minWidth: 30, maxHeight: 15),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            hintText: 'Search by employee or department...',
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00E5FF), size: 18),
            suffixIcon: hasQuery
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Color(0xFFAABBCC), size: 16),
                    onPressed: () {
                      _textController.clear();
                      widget.controller.searchQuery.value = '';
                    },
                  )
                : null,
            border: InputBorder.none,
          ),
        ),
      );
    });
  }
}

// ── Status Chip Data ──────────────────────────────────────────────────────────
class _StatusChipData {
  final String label;
  final AttendanceStatus? status;
  final Color color;
  final IconData icon;
  const _StatusChipData(this.label, this.status, this.color, this.icon);
}

// ── Radar Pulse Ring Widget (Cyber radar effect for empty states) ─────────────
class _RadarRing extends StatefulWidget {
  final int delay;
  const _RadarRing({required this.delay});

  @override
  State<_RadarRing> createState() => _RadarRingState();
}

class _RadarRingState extends State<_RadarRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _scale = Tween<double>(begin: 0.6, end: 1.4).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(seconds: widget.delay), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5), width: 1),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Animated Entry Transition (Slide up + Fade) ──────────────────────────────
class _AnimatedFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedFadeSlide({required this.child, required this.index, super.key});

  @override
  State<_AnimatedFadeSlide> createState() => _AnimatedFadeSlideState();
}

class _AnimatedFadeSlideState extends State<_AnimatedFadeSlide> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn));

    // Staggered entry animation based on list index
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

// ── Vertical Divider ──────────────────────────────────────────────────────────
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 25, width: 1, color: Colors.white.withValues(alpha: 0.12));
  }
}

// ── Console Chip ─────────────────────────────────────────────────────────────
class _ConsoleChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ConsoleChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0),
        ),
      ],
    );
  }
}

// ── Timeline Record Tile (The visual chronological timeline) ─────────────────
class _TimelineRecordTile extends StatelessWidget {
  final AttendanceRecord record;
  final bool isFirst;
  final bool isLast;

  const _TimelineRecordTile({required this.record, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (record.status) {
      AttendanceStatus.present => const Color(0xFF00C853),
      AttendanceStatus.late => const Color(0xFFFFB300),
      AttendanceStatus.checkedOut => const Color(0xFF1E88E5),
    };

    final icon = switch (record.status) {
      AttendanceStatus.present => Icons.login_rounded,
      AttendanceStatus.late => Icons.alarm_rounded,
      AttendanceStatus.checkedOut => Icons.logout_rounded,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline Thread Connector Line ─────────────────────────────────
          Column(
            children: [
              // Top connection path
              Container(width: 2, height: 16, color: isFirst ? Colors.transparent : const Color(0xFFCBD5E1)),
              // Timeline Node (biometric pulse)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.12),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Icon(icon, color: statusColor, size: 14),
              ),
              // Bottom connection path
              Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : const Color(0xFFCBD5E1))),
            ],
          ),
          const SizedBox(width: 14),

          // ── Detailed Log Card ──────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF0F1423).withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
                border: Border.all(color: const Color(0xFFECEFF5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.employeeName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          record.department.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF8A99AD), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 8),
                        // Monospaced FaceID snippet
                        Row(
                          children: [
                            const Icon(Icons.fingerprint_rounded, size: 12, color: Colors.black26),
                            const SizedBox(width: 4),
                            Text(
                              'FID: ${record.faceId.length > 12 ? record.faceId.substring(0, 12) : record.faceId}…',
                              style: const TextStyle(fontSize: 10, color: Colors.black38, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Label Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          record.statusLabel.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Time stamps
                      Row(
                        children: [
                          const Icon(Icons.login, size: 10, color: Colors.green),
                          const SizedBox(width: 2),
                          Text(
                            record.checkInFormatted,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.logout, size: 10, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                            record.checkOutFormatted,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Confidence match level
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF00E5FF).withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '${(record.confidenceScore * 100).toStringAsFixed(0)}% MATCH',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF00B0FF), letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
