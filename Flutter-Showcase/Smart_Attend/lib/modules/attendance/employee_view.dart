// lib/app/modules/attendance/employee_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/employee_model.dart';
import 'attendance_controller.dart';

class EmployeeView extends GetView<AttendanceController> {
  const EmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1423),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "STAFF DIRECTORY & MANAGER",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Color(0xFF00E5FF),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF00E5FF),
            ),
            tooltip: 'Add Staff Member',
            onPressed: () => _showAddEditBottomSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final staff = controller.filteredEmployees;

        return Column(
          children: [
            // ── Premium Stat Summary Console Deck ───────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F1423),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                children: [
                  // Quick Summary Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ConsoleChip(
                        'Total Staff',
                        '${controller.employees.length}',
                        Colors.white,
                      ),
                      _VerticalDivider(),
                      _ConsoleChip(
                        'Biometrics Filed',
                        '${controller.employees.where((e) => e.isEnrolled).length}',
                        const Color(0xFF00BCD4),
                      ),
                      _VerticalDivider(),
                      _ConsoleChip(
                        'Unregistered',
                        '${controller.employees.where((e) => !e.isEnrolled).length}',
                        const Color(0xFFFFB300),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search & Quick Department Filter Row
                  Row(
                    children: [
                      Expanded(child: _SearchField(controller: controller)),
                      const SizedBox(width: 10),
                      _buildDepartmentMenuButton(),
                    ],
                  ),
                ],
              ),
            ),

            // ── Employee List Timeline / Feed ────────────────────────────────
            Expanded(
              child: staff.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                      itemCount: staff.length,
                      itemBuilder: (_, i) {
                        return _EmployeeManagerCard(
                          emp: staff[i],
                          ctrl: controller,
                          onEdit: () =>
                              _showAddEditBottomSheet(context, staff[i]),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00E5FF),
        foregroundColor: const Color(0xFF0F1423),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'ADD STAFF',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            fontSize: 12,
          ),
        ),
        elevation: 4,
        onPressed: () => _showAddEditBottomSheet(context),
      ),
    );
  }

  // ── Department Quick Filter Trigger ──────────────────────────────────────
  Widget _buildDepartmentMenuButton() {
    final depts = ['', 'Engineering', 'Design', 'Marketing', 'HR', 'Finance'];
    return Obx(() {
      final current = controller.selectedEmployeeDepartment.value;
      final isActive = current.isNotEmpty;
      return PopupMenuButton<String>(
        onSelected: (val) => controller.selectedEmployeeDepartment.value = val,
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E3B5E), width: 1.2),
        ),
        color: const Color(0xFF141A30),
        icon: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
                : const Color(0xFF1E294B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF00E5FF)
                  : const Color(0xFF2E3B5E),
              width: 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.filter_list_rounded,
            color: isActive ? const Color(0xFF00E5FF) : Colors.white,
            size: 20,
          ),
        ),
        itemBuilder: (context) {
          return depts.map((d) {
            final isSelected = d == current;
            final label = d.isEmpty ? 'ALL DEPARTMENTS' : d.toUpperCase();
            return PopupMenuItem<String>(
              value: d,
              child: Row(
                children: [
                  Icon(
                    d.isEmpty
                        ? Icons.grid_view_rounded
                        : Icons.folder_shared_rounded,
                    color: isSelected
                        ? const Color(0xFF00E5FF)
                        : Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
      );
    });
  }

  // ── Beautiful Empty Search / Registry State ──────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.05),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 36,
              color: Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'NO STAFF RECORDS FOUND',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'No employees match your search query or department filters. Reset filter or add a new staff member.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              controller.employeeSearchQuery.value = '';
              controller.selectedEmployeeDepartment.value = '';
            },
            icon: const Icon(
              Icons.refresh_rounded,
              size: 14,
              color: Color(0xFF0F1423),
            ),
            label: const Text(
              'RESET ACTIVE FILTERS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Color(0xFF0F1423),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Add / Edit Employee Bottom Sheet Form ────────────────────────────────
  void _showAddEditBottomSheet(BuildContext context, [EmployeeModel? emp]) {
    final isEdit = emp != null;
    final nameCtrl = TextEditingController(text: emp?.name ?? '');
    final desgCtrl = TextEditingController(text: emp?.designation ?? '');
    final selectedDept = (emp?.department ?? 'Engineering').obs;

    final depts = ['Engineering', 'Design', 'Marketing', 'HR', 'Finance'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Bar & Title
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_note_rounded : Icons.person_add_rounded,
                    color: const Color(0xFF1E88E5),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'EDIT STAFF RECORD' : 'NEW STAFF REGISTRY',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F1423),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isEdit
                    ? 'Modify employee details below.'
                    : 'Configure profile settings to issue a secure Employee ID.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              const Text(
                'FULL NAME',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. John Doe',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Designation Field
              const Text(
                'DESIGNATION / ROLE',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: desgCtrl,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Senior Software Engineer',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Department Selector (Dropdown)
              const Text(
                'DEPARTMENT BRANCH',
                style: TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDept.value,
                      isExpanded: true,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                      onChanged: (val) {
                        if (val != null) selectedDept.value = val;
                      },
                      items: depts.map((d) {
                        return DropdownMenuItem<String>(
                          value: d,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.folder_shared_outlined,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(d),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Primary Action Submit Button
              ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final desg = desgCtrl.text.trim();
                  final dept = selectedDept.value;

                  if (name.isEmpty || desg.isEmpty) {
                    Get.snackbar(
                      'Validation Failed',
                      'Please fill in all staff details.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withValues(alpha: 0.12),
                      colorText: Colors.red,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(12),
                    );
                    return;
                  }

                  if (isEdit) {
                    controller.updateEmployee(
                      emp.id,
                      name: name,
                      department: dept,
                      designation: desg,
                    );
                  } else {
                    controller.addEmployee(
                      name: name,
                      department: dept,
                      designation: desg,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF020C1E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isEdit ? 'SAVE CHANGES' : 'CREATE REGISTRY RECORD',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ── Employee Management Card ───────────────────────────────────────────
class _EmployeeManagerCard extends StatelessWidget {
  final EmployeeModel emp;
  final AttendanceController ctrl;
  final VoidCallback onEdit;

  const _EmployeeManagerCard({
    required this.emp,
    required this.ctrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final enrolled = emp.isEnrolled;
    final idColor = const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        // boxShadow: [BoxShadow(color: const Color(0xFF0F1423).withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: const Color(0xFFECEFF5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar Ring with captured face image
                CircleAvatar(
                  key: ValueKey(emp.id),
                  radius: 24,
                  backgroundColor: _deptColor(
                    emp.department,
                  ).withValues(alpha: 0.08),
                  child: Text(
                    emp.initials,
                    style: TextStyle(
                      color: _deptColor(emp.department),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Employee Details Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              emp.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          _DeptTag(
                            dept: emp.department,
                            color: _deptColor(emp.department),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${emp.designation} · ID: ${emp.id}',
                        style: TextStyle(
                          color: idColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Biometrics Status Ribbon
                      Row(
                        children: [
                          Icon(
                            enrolled
                                ? Icons.verified_user_rounded
                                : Icons.warning_amber_rounded,
                            color: enrolled
                                ? const Color(0xFF00C853)
                                : const Color(0xFFFFB300),
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            enrolled ? 'Biometrics Filed' : 'Pending Face Scan',
                            style: TextStyle(
                              color: enrolled
                                  ? const Color(0xFF00C853)
                                  : const Color(0xFFFFB300),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 8),

            // Card Tactile Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Reset Biometric Face Action (Only visible if faceId exists)
                if (enrolled)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _confirmResetBiometrics(context),
                      icon: const Icon(
                        Icons.lock_reset_rounded,
                        size: 14,
                        color: Colors.orange,
                      ),
                      label: const Text(
                        'Reset Face',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        backgroundColor: Colors.orange.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                if (enrolled) const SizedBox(width: 8),

                // Edit details button
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: Color(0xFF1E88E5),
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Color(0xFF1E88E5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: Colors.blue.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Delete employee button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _confirmRemoveEmployee(context),
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      size: 14,
                      color: Color(0xFFFF3D00),
                    ),
                    label: const Text(
                      'Remove',
                      style: TextStyle(
                        color: Color(0xFFFF3D00),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _deptColor(String dept) {
    const map = {
      'Engineering': Color(0xFF1E88E5),
      'Design': Color(0xFFD81B60),
      'Marketing': Color(0xFFFB8C00),
      'HR': Color(0xFF00ACC1),
      'Finance': Color(0xFF43A047),
    };
    return map[dept] ?? Colors.indigo;
  }

  // ── Confirmation Alerts ──────────────────────────────────────────────────
  void _confirmResetBiometrics(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF0F1423),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_reset_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text(
              'RESET BIOMETRICS?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to clear ${emp.name}\'s facial registry data? Today\'s attendance status will also be cleared, requiring them to perform a new liveness face scan.',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ctrl.resetFaceId(emp.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'RESET NOW',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveEmployee(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF0F1423),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: Color(0xFFFF3D00), size: 24),
            SizedBox(width: 8),
            Text(
              'REMOVE EMPLOYEE?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Text(
          'This action is permanent. Are you sure you want to completely remove ${emp.name} from the Smart Attend Attendance register? All biographical and facial data will be erased.',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ctrl.deleteEmployee(emp.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3D00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'REMOVE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Field Widget ──────────────────────────────────────────────────
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
    _textController = TextEditingController(
      text: widget.controller.employeeSearchQuery.value,
    );

    widget.controller.employeeSearchQuery.listen((val) {
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
      final query = widget.controller.employeeSearchQuery.value;
      final hasQuery = query.isNotEmpty;
      return Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF1E294B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasQuery ? const Color(0xFF00E5FF) : const Color(0xFF2E3B5E),
            width: 1.5,
          ),
          boxShadow: hasQuery
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _textController,
          onChanged: (val) => widget.controller.employeeSearchQuery.value = val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),

          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints(
              minWidth: 30,
              maxHeight: 15,
            ),
            hintText: 'Search staff by name or ID...',
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF00E5FF),
              size: 18,
            ),
            suffixIcon: hasQuery
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: Color(0xFFAABBCC),
                      size: 16,
                    ),
                    onPressed: () {
                      _textController.clear();
                      widget.controller.employeeSearchQuery.value = '';
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
          ),
        ),
      );
    });
  }
}

// ── Console Metric Display ───────────────────────────────────────────────
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
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ── Vertical Spacer Line ─────────────────────────────────────────────────
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: 1,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}

// ── Colored Department Tag Pill ──────────────────────────────────────────
class _DeptTag extends StatelessWidget {
  final String dept;
  final Color color;
  const _DeptTag({required this.dept, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        dept.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
