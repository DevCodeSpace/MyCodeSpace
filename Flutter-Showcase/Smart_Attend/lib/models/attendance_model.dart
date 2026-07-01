// lib/app/models/attendance_model.dart

enum AttendanceStatus { present, late, checkedOut }

class AttendanceRecord {
  final String id;
  final String faceId;       // FID-XXXX from flutter_face_liveness
  final String employeeName; // resolved from faceId → local DB
  final String department;
  final DateTime checkInTime;
  DateTime? checkOutTime;
  AttendanceStatus status;
  final double confidenceScore;

  AttendanceRecord({
    required this.id,
    required this.faceId,
    required this.employeeName,
    required this.department,
    required this.checkInTime,
    required this.confidenceScore,
    this.checkOutTime,
    required this.status,
  });

  String get checkInFormatted  => _fmt(checkInTime);
  String get checkOutFormatted => checkOutTime != null ? _fmt(checkOutTime!) : '--:--';

  String get duration {
    if (checkOutTime == null) return 'Active';
    final d = checkOutTime!.difference(checkInTime);
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }

  String _fmt(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String get statusLabel {
    switch (status) {
      case AttendanceStatus.present:   return 'Present';
      case AttendanceStatus.late:      return 'Late';
      case AttendanceStatus.checkedOut: return 'Checked Out';
    }
  }
}
