import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/attendance_model.dart';
import '../../models/employee_model.dart';
import '../../routes/app_routes.dart';

enum ScanPurpose { enroll, checkIn, checkOut, unified }

class AttendanceController extends GetxController {
  static const _duplicateFaceThreshold = 0.88;
  static const _checkInMatchThreshold = 0.80;
  static const _checkOutMatchThreshold = 0.80;

  @override
  void onInit() {
    super.onInit();
    _loadStoredData();
  }

  Future<SharedPreferences> _getPrefs() => SharedPreferences.getInstance();

  static const _kEmployeesKey = 'app_staff_employees_v1';
  static const _kEmbeddingsKey = 'app_face_embeddings_v2';
  final Map<String, List<double>> _faceEmbeddings = {};

  Future<void> _loadStoredData() async {
    await _loadEmployees();
    await _loadEmbeddings();
  }

  Future<void> _loadEmployees() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_kEmployeesKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      employees.assignAll(decoded.map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>)).where((emp) => emp.id.isNotEmpty).toList());
      debugPrint('[AC] Loaded ${employees.length} staff records');
    } catch (e) {
      debugPrint('[AC] Staff load error: $e');
    }
  }

  Future<void> _saveEmployees() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_kEmployeesKey, jsonEncode(employees.map((emp) => emp.toJson()).toList()));
    } catch (e) {
      debugPrint('[AC] Staff save error: $e');
    }
  }

  Future<void> _loadEmbeddings() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_kEmbeddingsKey);
      if (raw == null) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _faceEmbeddings.addAll(decoded.map((k, v) => MapEntry(k, (v as List<dynamic>).map((e) => (e as num).toDouble()).toList())));
      final staffIds = employees.map((emp) => emp.id).toSet();
      _faceEmbeddings.removeWhere((id, _) => !staffIds.contains(id));
      var shouldSaveBiometricState = false;
      if (_faceEmbeddings.length != decoded.length) {
        shouldSaveBiometricState = true;
      }
      for (final emp in employees) {
        if (_faceEmbeddings.containsKey(emp.id)) {
          emp.faceId = emp.id;
          emp.faceImagePath = null;
        } else {
          emp.faceId = null;
          emp.faceImagePath = null;
        }
      }
      employees.refresh();
      if (shouldSaveBiometricState) {
        _saveEmbeddings();
      }
      debugPrint('[AC] Loaded ${_faceEmbeddings.length} face embeddings');
    } catch (e) {
      debugPrint('[AC] Embeddings load error: $e');
    }
  }

  Future<void> _saveEmbeddings() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_kEmbeddingsKey, jsonEncode(_faceEmbeddings));
    } catch (e) {
      debugPrint('[AC] Embeddings save error: $e');
    }
  }

  // ── Data ───────────────────────────────────────────────────
  final employees = <EmployeeModel>[].obs;
  final records = <AttendanceRecord>[].obs;

  final checkedInIds = <String>{}.obs;
  final checkedOutIds = <String>{}.obs;

  final Rxn<EmployeeModel> pendingEmployee = Rxn();
  final Rx<ScanPurpose> pendingPurpose = ScanPurpose.enroll.obs;

  // ── Filter State ──────────────────────────────────────────
  final searchQuery = ''.obs;
  final selectedStatus = Rxn<AttendanceStatus>();
  final selectedDepartment = ''.obs;
  final minConfidence = 0.0.obs;
  final sortBy = 'newest'.obs;

  // ── Employee Filter State ─────────────────────────────────
  final employeeSearchQuery = ''.obs;
  final selectedEmployeeDepartment = ''.obs;

  // ── Home View Status Filter State ─────────────────────────
  final homeStatusFilter = 'all'.obs;

  void toggleHomeStatusFilter(String filter) {
    if (homeStatusFilter.value == filter) {
      homeStatusFilter.value = 'all';
    } else {
      homeStatusFilter.value = filter;
    }
  }

  // ── Computed ───────────────────────────────────────────────
  int get presentCount => checkedInIds.length;
  int get absentCount => employees.length - checkedInIds.length;
  int get lateCount => records.where((r) => r.status == AttendanceStatus.late).length;
  int get unregisteredCount => employees.where((e) => !e.isEnrolled).length;
  int get checkedOutCount => checkedOutIds.length;

  List<EmployeeModel> get homeFilteredEmployees {
    final filter = homeStatusFilter.value;
    if (filter == 'all') return employees;
    return employees.where((emp) {
      final enrolled = emp.isEnrolled;
      final isIn = isCheckedIn(emp.id);
      final isOut = isCheckedOut(emp.id);
      if (filter == 'unregistered') return !enrolled;
      if (filter == 'present') return enrolled && isIn && !isOut;
      if (filter == 'absent') return enrolled && !isIn;
      if (filter == 'completed') return enrolled && isIn && isOut;
      return true;
    }).toList();
  }

  bool get isFilterActive =>
      searchQuery.isNotEmpty ||
      selectedStatus.value != null ||
      selectedDepartment.isNotEmpty ||
      minConfidence.value > 0.0 ||
      sortBy.value != 'newest';

  List<AttendanceRecord> get filteredRecords {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatus.value;
    final dept = selectedDepartment.value.trim().toLowerCase();
    final minConf = minConfidence.value;

    var list = records.where((r) {
      final matchesSearch = query.isEmpty || r.employeeName.toLowerCase().contains(query) || r.department.toLowerCase().contains(query);
      final matchesStatus = status == null || r.status == status;
      final matchesDept = dept.isEmpty || r.department.toLowerCase() == dept;
      final matchesConfidence = (r.confidenceScore * 100) >= minConf;
      return matchesSearch && matchesStatus && matchesDept && matchesConfidence;
    }).toList();

    if (sortBy.value == 'newest') {
      list.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    } else if (sortBy.value == 'oldest') {
      list.sort((a, b) => a.checkInTime.compareTo(b.checkInTime));
    } else if (sortBy.value == 'confidence') {
      list.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    }
    return list;
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedStatus.value = null;
    selectedDepartment.value = '';
    minConfidence.value = 0.0;
    sortBy.value = 'newest';
  }

  void seedDemoRecords() {
    if (records.isNotEmpty) return;
    final now = DateTime.now();

    records.add(
      AttendanceRecord(
        id: 'REC_EMP001',
        faceId: 'EMP001',
        employeeName: 'Rahul Sharma',
        department: 'Engineering',
        checkInTime: DateTime(now.year, now.month, now.day, 9, 5),
        confidenceScore: 0.98,
        status: AttendanceStatus.present,
      ),
    );
    checkedInIds.add('EMP001');

    records.add(
      AttendanceRecord(
        id: 'REC_EMP002',
        faceId: 'EMP002',
        employeeName: 'Priya Patel',
        department: 'Design',
        checkInTime: DateTime(now.year, now.month, now.day, 9, 42),
        confidenceScore: 0.95,
        status: AttendanceStatus.late,
      ),
    );
    checkedInIds.add('EMP002');

    final checkInAmit = DateTime(now.year, now.month, now.day, 8, 58);
    records.add(
      AttendanceRecord(
        id: 'REC_EMP003',
        faceId: 'EMP003',
        employeeName: 'Amit Verma',
        department: 'Marketing',
        checkInTime: checkInAmit,
        checkOutTime: DateTime(now.year, now.month, now.day, 17, 30),
        confidenceScore: 0.92,
        status: AttendanceStatus.checkedOut,
      ),
    );
    checkedInIds.add('EMP003');
    checkedOutIds.add('EMP003');

    final checkInSneha = DateTime(now.year, now.month, now.day, 9, 12);
    records.add(
      AttendanceRecord(
        id: 'REC_EMP004',
        faceId: 'EMP004',
        employeeName: 'Sneha Joshi',
        department: 'HR',
        checkInTime: checkInSneha,
        checkOutTime: DateTime(now.year, now.month, now.day, 17, 0),
        confidenceScore: 0.97,
        status: AttendanceStatus.checkedOut,
      ),
    );
    checkedInIds.add('EMP004');
    checkedOutIds.add('EMP004');

    records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
  }

  bool isCheckedIn(String empId) => checkedInIds.contains(empId);
  bool isCheckedOut(String empId) => checkedOutIds.contains(empId);

  String get todayLabel {
    final now = DateTime.now();
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${m[now.month - 1]} ${now.year}';
  }

  // ── Employee Management ───────────────────────────────────
  List<EmployeeModel> get filteredEmployees {
    final query = employeeSearchQuery.value.trim().toLowerCase();
    final dept = selectedEmployeeDepartment.value.trim().toLowerCase();
    return employees.where((emp) {
      final matchesSearch =
          query.isEmpty ||
          emp.name.toLowerCase().contains(query) ||
          emp.designation.toLowerCase().contains(query) ||
          emp.id.toLowerCase().contains(query);
      final matchesDept = dept.isEmpty || emp.department.toLowerCase() == dept;
      return matchesSearch && matchesDept;
    }).toList();
  }

  void addEmployee({required String name, required String department, required String designation}) {
    int nextNum = employees.length + 1;
    String id = 'EMP${nextNum.toString().padLeft(3, '0')}';
    while (employees.any((e) => e.id == id)) {
      nextNum++;
      id = 'EMP${nextNum.toString().padLeft(3, '0')}';
    }
    employees.add(EmployeeModel(id: id, name: name, department: department, designation: designation));
    employees.refresh();
    _saveEmployees();
    Get.back();
    _snack('🎉 Employee Added!', '$name has been registered under $department.', Colors.green);
  }

  void updateEmployee(String id, {required String name, required String department, required String designation}) {
    final idx = employees.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final existingFaceId = employees[idx].faceId;
    employees[idx] = EmployeeModel(id: id, name: name, department: department, designation: designation, faceId: existingFaceId);
    employees.refresh();
    for (var i = 0; i < records.length; i++) {
      if (records[i].faceId == id) {
        records[i] = AttendanceRecord(
          id: records[i].id,
          faceId: records[i].faceId,
          employeeName: name,
          department: department,
          checkInTime: records[i].checkInTime,
          checkOutTime: records[i].checkOutTime,
          status: records[i].status,
          confidenceScore: records[i].confidenceScore,
        );
      }
    }
    records.refresh();
    _saveEmployees();
    Get.back();
    _snack('📝 Employee Updated', '$name details have been successfully modified.', Colors.blue);
  }

  void deleteEmployee(String id) {
    final emp = employees.firstWhereOrNull((e) => e.id == id);
    if (emp == null) return;
    employees.removeWhere((e) => e.id == id);
    _faceEmbeddings.remove(id);
    _saveEmbeddings();
    checkedInIds.remove(id);
    checkedOutIds.remove(id);
    employees.refresh();
    _saveEmployees();
    Get.back();
    _snack('🗑️ Employee Removed', '${emp.name} has been removed from Smart Attend.', Colors.red);
  }

  void resetFaceId(String id) {
    final emp = employees.firstWhereOrNull((e) => e.id == id);
    if (emp == null) return;
    emp.faceId = null;
    emp.faceImagePath = null;
    _faceEmbeddings.remove(id);
    _saveEmbeddings();
    checkedInIds.remove(id);
    checkedOutIds.remove(id);
    records.removeWhere((r) => r.faceId == id);
    employees.refresh();
    records.refresh();
    _saveEmployees();
    Get.back();
    _snack('🔑 Biometrics Reset', 'Face data cleared. ${emp.name} requires re-enrollment.', Colors.orange);
  }

  // ── Navigate to Face Scan ─────────────────────────────────
  void openEnroll(EmployeeModel emp) {
    if (emp.isEnrolled) {
      _snack('Already Enrolled', '${emp.name} is already registered.', Colors.orange);
      return;
    }
    pendingEmployee.value = emp;
    pendingPurpose.value = ScanPurpose.enroll;
    pendingEmployee.refresh();
    Get.toNamed(AppRoutes.liveness);
  }

  void openCheckIn(EmployeeModel emp) {
    if (!emp.isEnrolled) {
      _snack('Not Enrolled', 'Please enroll ${emp.name} first.', Colors.orange);
      return;
    }
    if (isCheckedIn(emp.id)) {
      _snack('Already Checked In', '${emp.name} is already present today.', Colors.orange);
      return;
    }
    pendingEmployee.value = emp;
    pendingPurpose.value = ScanPurpose.checkIn;
    pendingEmployee.refresh();
    Get.toNamed(AppRoutes.liveness);
  }

  void openCheckOut(EmployeeModel emp) {
    if (!isCheckedIn(emp.id)) {
      _snack('Not Checked In', '${emp.name} has not checked in today.', Colors.orange);
      return;
    }
    if (isCheckedOut(emp.id)) {
      _snack('Already Checked Out', '${emp.name} has already checked out.', Colors.orange);
      return;
    }
    pendingEmployee.value = emp;
    pendingPurpose.value = ScanPurpose.checkOut;
    pendingEmployee.refresh();
    Get.toNamed(AppRoutes.liveness);
  }

  void openUnifiedScan() {
    pendingEmployee.value = null; // 1:N scan, no pre-selected employee
    pendingPurpose.value = ScanPurpose.unified;
    Get.toNamed(AppRoutes.liveness);
  }

  // ── Callback from FaceScanView ────────────────────────────

  Future<void> onFaceScanSuccess({required List<double> embedding}) async {
    _closeScanRoute();

    final emp = pendingEmployee.value;

    switch (pendingPurpose.value) {
      case ScanPurpose.enroll:
        if (emp == null) return;
        for (final entry in _faceEmbeddings.entries) {
          if (entry.key == emp.id) continue;
          final similarity = _cosineSimilarity(embedding, entry.value);
          if (similarity >= _duplicateFaceThreshold) {
            final other = employees.firstWhereOrNull((e) => e.id == entry.key);
            _snack(
              '⚠️ Duplicate Face',
              'This face matches ${other?.name ?? entry.key} (${(similarity * 100).toStringAsFixed(0)}%). Each employee needs a unique face.',
              Colors.orange,
            );
            pendingEmployee.value = null;
            return;
          }
        }
        emp.faceId = emp.id;
        emp.faceImagePath = null;
        _faceEmbeddings[emp.id] = embedding;
        await _saveEmbeddings();
        employees.refresh();
        await _saveEmployees();
        _snack('✅ Enrolled!', '${emp.name} face registered successfully.', Colors.green);
        break;

      case ScanPurpose.checkIn:
        if (emp == null) return;
        final stored = _faceEmbeddings[emp.id];
        if (stored == null) {
          _snack('❌ Not Enrolled', 'No face data found for ${emp.name}.', Colors.red);
          break;
        }
        final similarity = _cosineSimilarity(embedding, stored);
        if (similarity < _checkInMatchThreshold) {
          _snack('❌ Face Mismatch', 'Similarity ${(similarity * 100).toStringAsFixed(0)}% — face does not match ${emp.name}.', Colors.red);
          break;
        }
        _recordCheckIn(emp, similarity);
        break;

      case ScanPurpose.checkOut:
        if (emp == null) return;
        final stored = _faceEmbeddings[emp.id];
        if (stored == null) {
          _snack('❌ Not Enrolled', 'No face data found for ${emp.name}.', Colors.red);
          break;
        }
        final similarity = _cosineSimilarity(embedding, stored);
        if (similarity < _checkOutMatchThreshold) {
          _snack('❌ Face Mismatch', 'Similarity ${(similarity * 100).toStringAsFixed(0)}% — face does not match ${emp.name}.', Colors.red);
          break;
        }
        _recordCheckOut(emp, similarity);
        break;

      case ScanPurpose.unified:
        await processUnifiedScan(scannedEmbedding: embedding);
        break;
    }

    pendingEmployee.value = null;
  }

  void onLivenessFailed(String reason) {
    _closeScanRoute();
    if (reason != 'Cancelled by user') {
      _snack('Scan Failed', reason, Colors.red);
    }
    pendingEmployee.value = null;
  }

  void _closeScanRoute() {
    final nav = Get.key.currentState;
    if (nav?.canPop() ?? false) {
      nav!.pop();
    }
  }

  // ── Private helpers ───────────────────────────────────────

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0;
    double dot = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot.clamp(0.0, 1.0);
  }

  void _recordCheckIn(EmployeeModel emp, double score) {
    final now = DateTime.now();
    final isLate = now.hour > 9 || (now.hour == 9 && now.minute > 30);
    records.add(
      AttendanceRecord(
        id: '${emp.id}_${now.millisecondsSinceEpoch}',
        faceId: emp.id,
        employeeName: emp.name,
        department: emp.department,
        checkInTime: now,
        confidenceScore: score,
        status: isLate ? AttendanceStatus.late : AttendanceStatus.present,
      ),
    );
    checkedInIds.add(emp.id);
    _snack(
      '✅ Check-In Success!',
      '${emp.name} · ${_fmt(now)}${isLate ? ' (Late)' : ' (On Time)'}  •  ${(score * 100).toStringAsFixed(0)}% match',
      isLate ? Colors.orange : Colors.green,
    );
  }

  void _recordCheckOut(EmployeeModel emp, double score) {
    final idx = records.indexWhere((r) => r.faceId == emp.id && r.checkOutTime == null);
    if (idx == -1) {
      _snack('❌ No Check-In Record', 'No check-in record found for ${emp.name}.', Colors.red);
      return;
    }
    final now = DateTime.now();
    records[idx].checkOutTime = now;
    records[idx].status = AttendanceStatus.checkedOut;
    records.refresh();
    checkedOutIds.add(emp.id);
    _snack(
      '👋 Check-Out!',
      '${emp.name} · ${_fmt(now)}  •  Duration: ${records[idx].duration}  •  ${(score * 100).toStringAsFixed(0)}% match',
      Colors.blue,
    );
  }

  String getCheckInTime(String empId) {
    final rec = records.firstWhereOrNull((r) => r.faceId == empId && r.checkOutTime == null);
    if (rec == null) return '--:--';
    return _fmt(rec.checkInTime);
  }

  String getCheckOutTime(String empId) {
    final rec = records.firstWhereOrNull((r) => r.faceId == empId && r.checkOutTime != null);
    if (rec == null) return '--:--';
    return _fmt(rec.checkOutTime!);
  }

  String _fmt(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void _snack(String title, String msg, Color color) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withValues(alpha: 0.12),
      colorText: color,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  // ── Unified Smart Scan Logic ──────────────────────────────
  Future<void> processUnifiedScan({required List<double> scannedEmbedding}) async {
    if (_faceEmbeddings.isEmpty) {
      _snack('❌ System Empty', 'No employee biometrics are registered in the system yet.', Colors.red);
      return;
    }

    String? matchedEmpId;
    double highestSimilarity = 0.0;

    // 1. Identify the person (Find the closest matching face vector)
    for (final entry in _faceEmbeddings.entries) {
      final similarity = _cosineSimilarity(scannedEmbedding, entry.value);
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        matchedEmpId = entry.key;
      }
    }

    // 2. Validate if match exists
    if (matchedEmpId == null) {
      _snack('❌ Unregistered', 'Face structure could not be mapped to any record.', Colors.red);
      return;
    }

    final emp = employees.firstWhereOrNull((e) => e.id == matchedEmpId);
    if (emp == null) {
      _snack('❌ Data Conflict', 'Face matched an ID, but employee profile was not found.', Colors.red);
      return;
    }

    // 3. Dynamic Threshold check based on their current attendance state
    final bool alreadyCheckedIn = isCheckedIn(emp.id);
    final double requiredThreshold = alreadyCheckedIn ? _checkOutMatchThreshold : _checkInMatchThreshold;

    if (highestSimilarity < requiredThreshold) {
      _snack(
        '❌ Identity Unverified',
        'Matches ${emp.name} but similarity (${(highestSimilarity * 100).toStringAsFixed(0)}%) is below required ${(requiredThreshold * 100).toStringAsFixed(0)}%.',
        Colors.red,
      );
      return;
    }

    // 4. Dynamic routing state loop
    final bool alreadyCheckedOut = isCheckedOut(emp.id);

    if (!alreadyCheckedIn) {
      _recordCheckIn(emp, highestSimilarity);
    } else if (!alreadyCheckedOut) {
      _recordCheckOut(emp, highestSimilarity);
    } else {
      _snack('🏁 Duty Completed', '${emp.name} has already checked in and checked out for today.', Colors.purple);
    }
  }
}
