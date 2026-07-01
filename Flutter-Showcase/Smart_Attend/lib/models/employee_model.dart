// lib/app/models/employee_model.dart
//
// In a real app, this data comes from your backend.
// faceId is set AFTER first liveness scan (isFaceIdNew == true).

class EmployeeModel {
  final String id;
  final String name;
  final String department;
  final String designation;
  String? faceId; // null until enrolled via liveness
  String? faceImagePath; // local captured enrollment photo

  EmployeeModel({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
    this.faceId,
    this.faceImagePath,
  });

  String get initials =>
      name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();

  bool get isEnrolled => faceId != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'department': department,
    'designation': designation,
    'faceId': faceId,
    'faceImagePath': faceImagePath,
  };

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      faceId: json['faceId']?.toString(),
      faceImagePath: json['faceImagePath']?.toString(),
    );
  }
}
