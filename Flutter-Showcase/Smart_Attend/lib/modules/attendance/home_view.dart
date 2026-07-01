// lib/app/modules/attendance/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/employee_model.dart';
import '../../routes/app_routes.dart';
import 'attendance_controller.dart';

class HomeView extends GetView<AttendanceController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: Column(
          children: [
            _HomeHeader(ctrl: controller),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _GlassStatsPanel(ctrl: controller),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), child: _HomeTabBar()),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _StaffTab(ctrl: controller),
                  _AttendanceTab(ctrl: controller),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.openUnifiedScan,
          backgroundColor: Color(0xFF0077B6),
          elevation: 0,
          child: Image.asset('assets/images/face-scan.png', color: Colors.white, height: 32),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final AttendanceController ctrl;
  const _HomeHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      height: topPadding + 168,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004D60), Color(0xFF00303D), Color(0xFF071828), Color(0xFF020C1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55,
            right: -35,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF00BCD4).withValues(alpha: 0.28), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [const Color(0xFF0077B6).withValues(alpha: 0.25), Colors.transparent]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 16, 12, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BCD4), Color(0xFF0077B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(color: const Color(0xFF00BCD4).withValues(alpha: 0.45), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.corporate_fare_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Smart Attend',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Attendance Management',
                            style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'History',
                      onPressed: () => Get.toNamed(AppRoutes.history),
                      icon: const Icon(Icons.history_rounded, color: Colors.white, size: 25),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.corporate_fare_rounded, color: Color(0xFF00BCD4), size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Team Dashboard',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00BCD4).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.today_rounded, color: Color(0xFF00BCD4), size: 13),
                          const SizedBox(width: 7),
                          Text(
                            ctrl.todayLabel.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTabBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFEAF0F7), borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [BoxShadow(color: const Color(0xFF0F1423).withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF0F1423),
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.badge_rounded, size: 18), SizedBox(width: 6), Text('Staff')],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.fact_check_rounded, size: 18), SizedBox(width: 6), Text('Attendance')],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glassmorphic Stats Panel ──────────────────────────────────────────
class _GlassStatsPanel extends StatelessWidget {
  final AttendanceController ctrl;
  const _GlassStatsPanel({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF0F1423).withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.white),
      ),
      child: Obx(
        () => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _StatBox('Present', ctrl.presentCount, const Color(0xFF00C853), Icons.check_circle_outline)),
              _VerticalDivider(),
              Expanded(child: _StatBox('Absent', ctrl.absentCount, const Color(0xFFFF3D00), Icons.cancel_outlined)),
              _VerticalDivider(),
              Expanded(child: _StatBox('Late', ctrl.lateCount, const Color(0xFFFFB300), Icons.alarm_outlined)),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: const Color(0xFFE2E8F0));
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatBox(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22, height: 1.0),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0),
        ),
      ],
    );
  }
}

class _StaffTab extends StatelessWidget {
  final AttendanceController ctrl;
  const _StaffTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final staff = ctrl.filteredEmployees;
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'STAFF DETAILS',
                  style: TextStyle(color: Color(0xFF8A99AD), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
              ),
              _AddStaffButton(onTap: () => _showStaffSheet(context, ctrl)),
            ],
          ),
          const SizedBox(height: 12),
          _StaffSummary(ctrl: ctrl),
          const SizedBox(height: 12),
          if (staff.isEmpty)
            const _HomeEmptyState(icon: Icons.search_off_rounded, title: 'No staff found')
          else
            ...staff.map((emp) => _StaffCard(emp: emp, ctrl: ctrl, onEdit: () => _showStaffSheet(context, ctrl, emp))),
        ],
      );
    });
  }
}

class _AttendanceTab extends StatelessWidget {
  final AttendanceController ctrl;
  const _AttendanceTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final staff = ctrl.homeFilteredEmployees;
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Row container to align the Section Title and Filter Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ATTENDANCE FLOW',
                style: TextStyle(color: Color(0xFF8A99AD), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
              ),

              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  value: ctrl.homeStatusFilter.value,
                  icon: const Icon(Icons.filter_list_rounded, size: 16, color: Color(0xFF475569)),
                  elevation: 3,
                  style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      ctrl.homeStatusFilter.value = newValue;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'present', child: Text('Present')),
                    DropdownMenuItem(value: 'absent', child: Text('Absent')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          if (staff.isEmpty)
            const _HomeEmptyState(icon: Icons.fact_check_outlined, title: 'No staff matches filter')
          else
            ...staff.map((emp) => _EmployeeCard(emp: emp, ctrl: ctrl)),
        ],
      );
    });
  }
}

class _StaffSummary extends StatelessWidget {
  final AttendanceController ctrl;
  const _StaffSummary({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniMetric(label: 'Total', value: '${ctrl.employees.length}', color: const Color(0xFF1E88E5)),
          ),
          _VerticalDivider(),
          Expanded(
            child: _MiniMetric(label: 'Registered', value: '${ctrl.employees.where((e) => e.isEnrolled).length}', color: const Color(0xFF00897B)),
          ),
          _VerticalDivider(),
          Expanded(
            child: _MiniMetric(label: 'Pending', value: '${ctrl.unregisteredCount}', color: const Color(0xFFFFB300)),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniMetric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
      ],
    );
  }
}

class _AddStaffButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddStaffButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF0F1423),
        foregroundColor: Colors.white,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
      label: const Text('Add Staff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }
}

// ── Premium Overhauled Staff Management Card ──────────────────────────────────
class _StaffCard extends StatelessWidget {
  final EmployeeModel emp;
  final AttendanceController ctrl;
  final VoidCallback onEdit;

  const _StaffCard({required this.emp, required this.ctrl, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final themeColor = _deptColor(emp.department);

    // Modern High-Contrast Color Token System
    const Color textPrimary = Color(0xFF0F172A); // Deep Slate
    const Color textSecondary = Color(0xFF64748B); // Cool Grey
    const Color borderMuted = Color(0xFFF1F5F9); // Ultra soft divider

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Premium curved dashboard look
        boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.7)),
      ),
      child: Stack(
        children: [
          // 🛠️ BACKGROUND GRAPHIC TINT: Subtle corner glow matching department colors
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(gradient: RadialGradient(colors: [themeColor.withValues(alpha: 0.05), Colors.transparent])),
            ),
          ),

          // Main Layout Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: Beautiful Framed Avatar Profile Anchor
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: themeColor.withValues(alpha: 0.15), width: 1.5),
                      ),
                      child: CircleAvatar(
                        key: ValueKey('staff-${emp.id}'),
                        radius: 24,
                        backgroundColor: themeColor.withValues(alpha: 0.08),
                        child: Text(
                          emp.initials,
                          style: TextStyle(color: themeColor, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Center Body: Hierarchical Text Block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            emp.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            emp.designation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Right Side: Micro Administrative Toolbar Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MicroActionButton(icon: Icons.edit_rounded, color: const Color(0xFF3B82F6), tooltip: 'Edit profile', onTap: onEdit),
                        const SizedBox(width: 6),
                        _MicroActionButton(
                          icon: Icons.delete_outline_rounded,
                          color: const Color(0xFFEF4444),
                          tooltip: 'Remove staff',
                          onTap: () => _confirmDeleteStaff(context, ctrl, emp),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: borderMuted, height: 1, thickness: 1.5),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(
                      label: emp.isEnrolled ? 'Verified' : 'Pending Face',
                      color: emp.isEnrolled ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      icon: emp.isEnrolled ? Icons.verified_rounded : Icons.pending_actions_rounded,
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'ID: ${emp.id}',
                        style: const TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                      ),
                    ),

                    _DeptTag(dept: emp.department, color: themeColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _deptColor(String dept) {
    const map = {
      'Engineering': Color(0xFF3B82F6), // Premium modern palette tones
      'Design': Color(0xFFEC4899),
      'Marketing': Color(0xFFF97316),
      'HR': Color(0xFF14B8A6),
      'Finance': Color(0xFF22C55E),
    };
    return map[dept] ?? Colors.indigo;
  }
}

// ── Refined Department Tag Pill ─────────────────────────────────────────────
class _DeptTag extends StatelessWidget {
  final String dept;
  final Color color;
  const _DeptTag({required this.dept, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(30)),
      child: Text(
        dept.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 0.6),
      ),
    );
  }
}

// ── Premium Minimalist Status Badge ────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ── Premium Micro Action Circle Button ──────────────────────────────────────────
class _MicroActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _MicroActionButton({required this.icon, required this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.06), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  const _HomeEmptyState({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 42),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

void _confirmDeleteStaff(BuildContext context, AttendanceController ctrl, EmployeeModel emp) {
  Get.dialog(
    AlertDialog(
      backgroundColor: const Color.fromARGB(255, 235, 237, 242),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.warning_rounded, color: Color(0xFFFF3D00), size: 24),
          SizedBox(width: 8),
          Text(
            'DELETE STAFF?',
            style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w900),
          ),
        ],
      ),
      content: Text(
        'Remove ${emp.name} from staff records? This will also delete saved face data and attendance state for this staff member.',
        style: const TextStyle(color: Colors.black, fontSize: 12, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => ctrl.deleteEmployee(emp.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3D00),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.delete_forever_rounded, size: 16),
          label: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

void _showStaffSheet(BuildContext context, AttendanceController ctrl, [EmployeeModel? emp]) {
  final isEdit = emp != null;
  final nameCtrl = TextEditingController(text: emp?.name ?? '');
  final roleCtrl = TextEditingController(text: emp?.designation ?? '');
  final selectedDept = (emp?.department ?? 'Engineering').obs;
  final departments = ['Engineering', 'Design', 'Marketing', 'HR', 'Finance'];

  Get.bottomSheet(
    Container(
      padding: EdgeInsets.fromLTRB(20, 22, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isEdit ? 'EDIT STAFF' : 'ADD STAFF',
              style: const TextStyle(color: Color(0xFF0F1423), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.7),
            ),
            const SizedBox(height: 18),
            _StaffTextField(controller: nameCtrl, label: 'FULL NAME', hint: 'e.g. John Doe', icon: Icons.person_outline_rounded),
            const SizedBox(height: 14),
            _StaffTextField(controller: roleCtrl, label: 'DESIGNATION / ROLE', hint: 'e.g. Software Engineer', icon: Icons.badge_outlined),
            const SizedBox(height: 14),
            const Text(
              'DEPARTMENT',
              style: TextStyle(color: Color(0xFF8A99AD), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<String>(
                initialValue: selectedDept.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.folder_shared_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: departments.map((dept) => DropdownMenuItem(value: dept, child: Text(dept))).toList(),
                onChanged: (value) {
                  if (value != null) selectedDept.value = value;
                },
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final role = roleCtrl.text.trim();
                if (name.isEmpty || role.isEmpty) {
                  Get.snackbar(
                    'Validation Failed',
                    'Please fill in all staff details.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withValues(alpha: 0.12),
                    colorText: Colors.red,
                    margin: const EdgeInsets.all(12),
                  );
                  return;
                }
                if (isEdit) {
                  ctrl.updateEmployee(emp.id, name: name, department: selectedDept.value, designation: role);
                } else {
                  ctrl.addEmployee(name: name, department: selectedDept.value, designation: role);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F1423),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
              label: Text(isEdit ? 'SAVE STAFF' : 'CREATE STAFF', style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _StaffTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  const _StaffTextField({required this.controller, required this.label, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A99AD), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ── Employee Card ─────────────────────────────────────────────────────
class _EmployeeCard extends StatelessWidget {
  final EmployeeModel emp;
  final AttendanceController ctrl;
  const _EmployeeCard({required this.emp, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isIn = ctrl.isCheckedIn(emp.id);
      final isOut = ctrl.isCheckedOut(emp.id);
      final enrolled = emp.isEnrolled;

      // Access observable to trigger rebuild on employee update
      ctrl.employees.length;

      final themeColor = _deptColor(emp.department);

      const Color textPrimary = Color(0xFF0F172A);
      const Color textSecondary = Color(0xFF64748B);
      const Color surfBackground = Color(0xFFF8FAFC);

      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // Ultra-modern soft curved geometry
          boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎴 LEFT SECTION: Core Profile Identity block
              Container(
                width: 110,
                decoration: BoxDecoration(
                  color: surfBackground,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CustomAvatarRing(
                      color: enrolled
                          ? (isIn ? (isOut ? const Color(0xFFF97316) : const Color(0xFF10B981)) : const Color(0xFF6366F1))
                          : const Color(0xFF94A3B8),
                      pulse: false, //enrolled && isIn && !isOut
                      child: CircleAvatar(
                        key: ValueKey(emp.id),
                        radius: 24,
                        backgroundColor: themeColor.withValues(alpha: 0.12),
                        child: Text(
                          emp.initials,
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // _DeptTag(dept: emp.department, color: themeColor),
                    Text(
                      emp.department,
                      style: TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),

              // 📄 RIGHT SECTION: Rich Info Data Grid & Interactive Controls
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Row: Identity Typography & Quick Status Badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emp.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textPrimary, letterSpacing: -0.4),
                                ),
                                // const SizedBox(height: 2),
                                Text(
                                  emp.designation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),

                          // Floating minimal status pill
                          if (isIn && !isOut) const _AnimatedWorkingIcon(),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Meta details workspace block
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: surfBackground, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID: ${emp.id}',
                              style: const TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                            ),
                            Text(
                              !enrolled ? 'Unregistered' : (!isIn ? 'Absent' : (isOut ? 'Shift Done' : 'On Clock')),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: !enrolled ? const Color(0xFF64748B) : (!isIn ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Contextual Action Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!enrolled)
                            Expanded(
                              child: _TactileBtn(
                                label: 'Begin Face Enrollment',
                                icon: Icons.face_retouching_natural,
                                backgroundColor: const Color(0xFF6366F1),
                                textColor: Colors.white,
                                onTap: () => ctrl.openEnroll(emp),
                              ),
                            ),
                          if (enrolled && !isOut) ...[
                            Expanded(
                              child: _TactileBtn(
                                label: !isIn ? 'Check In' : ctrl.getCheckInTime(emp.id),
                                icon: Icons.arrow_downward_rounded,
                                backgroundColor: !isIn ? const Color(0xFF22D3EE) : const Color(0xFFF1F5F9),
                                textColor: !isIn ? const Color(0xFF0F1423) : const Color(0xFF656F7E),
                                onTap: !isIn ? () => ctrl.openCheckIn(emp) : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TactileBtn(
                                label: 'Check Out',
                                icon: Icons.arrow_upward_rounded,
                                backgroundColor: isIn ? const Color(0xFFEA580C) : const Color(0xFFF1F5F9),
                                textColor: isIn ? Colors.white : const Color(0xFF94A3B8),
                                onTap: isIn ? () => ctrl.openCheckOut(emp) : null,
                              ),
                            ),
                          ],
                          if (enrolled && isOut)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(12)),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Shift Complete',
                                      style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ],
                                ),
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
        ),
      );
    });
  }

  Color _deptColor(String dept) {
    const map = {
      'Engineering': Color(0xFF3B82F6),
      'Design': Color(0xFFEC4899),
      'Marketing': Color(0xFFF97316),
      'HR': Color(0xFF14B8A6),
      'Finance': Color(0xFF22C55E),
    };
    return map[dept] ?? Colors.indigo;
  }
}

// ── Custom Pulsing Avatar Ring ────────────────────────────────────────
class _CustomAvatarRing extends StatefulWidget {
  final Color color;
  final bool pulse;
  final Widget child;

  const _CustomAvatarRing({required this.color, required this.pulse, required this.child});

  @override
  State<_CustomAvatarRing> createState() => _CustomAvatarRingState();
}

class _CustomAvatarRingState extends State<_CustomAvatarRing> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Adjusted duration to 1.4 seconds to match the snappy feel of your live dot animation
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    if (widget.pulse) _pulseController.repeat();
  }

  @override
  void didUpdateWidget(covariant _CustomAvatarRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.pulse && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Linear Interpolations matching your live micro-telemetry dot logic:
        // 1. Scale multiplier: goes from 0.0 to 1.0
        final double rippleProgress = _pulseController.value;
        // 2. Opacity multiplier: fades from 0.7 down to 0.0 smoothly over the curve
        final double rippleOpacity = 0.7 * (1.0 - _pulseController.value);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer dynamic ripple background ring
            if (widget.pulse)
              Container(
                width: 56 + (rippleProgress * 14),
                height: 56 + (rippleProgress * 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: rippleOpacity),
                ),
              ),

            // Fixed inner solid tracking ring housing the main child avatar
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.color, width: 2.0),
              ),
              child: widget.child,
            ),
          ],
        );
      },
    );
  }
}

// ── Overhauled Micro-Telemetry Status Dot ──────────────────────────────────────────────
class _AnimatedWorkingIcon extends StatefulWidget {
  const _AnimatedWorkingIcon();

  @override
  State<_AnimatedWorkingIcon> createState() => _AnimatedWorkingIconState();
}

class _AnimatedWorkingIconState extends State<_AnimatedWorkingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _ripple;
  late Animation<double> _rippleOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _ripple = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rippleOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 6 + (_ripple.value * 6),
                    height: 6 + (_ripple.value * 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981).withValues(alpha: _rippleOpacity.value * 0.5),
                    ),
                  ),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(color: Color(0xFF16A34A), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}

// ── Tactile Button Component ───────────────────────────────────────
class _TactileBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _TactileBtn({required this.label, required this.icon, required this.backgroundColor, required this.textColor, required this.onTap});

  @override
  State<_TactileBtn> createState() => _TactileBtnState();
}

class _TactileBtnState extends State<_TactileBtn> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool get _isEnabled => widget.onTap != null;

  void _onTapDown(TapDownDetails details) {
    if (_isEnabled) setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    if (_isEnabled) {
      setState(() => _scale = 1.0);
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (_isEnabled) setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isEnabled ? _scale : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(color: widget.backgroundColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.textColor, size: 14),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(color: widget.textColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: -0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
