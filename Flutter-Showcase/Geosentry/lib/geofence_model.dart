import 'dart:math';

class GeofenceModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final GeofenceStatus status;
  final DateTime createdAt;
  final String? description;
  final int color;
  final String? areaName; // ← reverse-geocoded real area name

  GeofenceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isActive = true,
    this.status = GeofenceStatus.outside,
    required this.createdAt,
    this.description,
    this.color = 0xFF2196F3,
    this.areaName,
  });

  GeofenceModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
    GeofenceStatus? status,
    DateTime? createdAt,
    String? description,
    int? color,
    String? areaName,
  }) {
    return GeofenceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      color: color ?? this.color,
      areaName: areaName ?? this.areaName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'radius': radius,
    'isActive': isActive,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'description': description,
    'color': color,
    'areaName': areaName,
  };

  factory GeofenceModel.fromJson(Map<String, dynamic> json) => GeofenceModel(
    id: json['id'],
    name: json['name'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    radius: json['radius'],
    isActive: json['isActive'] ?? true,
    status: GeofenceStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => GeofenceStatus.outside),
    createdAt: DateTime.parse(json['createdAt']),
    description: json['description'],
    color: json['color'] ?? 0xFF2196F3,
    areaName: json['areaName'],
  );

  double distanceTo(double lat, double lng) {
    const R = 6371000.0;
    final dLat = _toRad(lat - latitude);
    final dLng = _toRad(lng - longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_toRad(latitude)) * cos(_toRad(lat)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  bool containsPoint(double lat, double lng) => distanceTo(lat, lng) <= radius;

  double _toRad(double deg) => deg * pi / 180;
}

enum GeofenceStatus { inside, outside, unknown }

class GeofenceEvent {
  final String geofenceId;
  final String geofenceName;
  final GeofenceEventType type;
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  GeofenceEvent({required this.geofenceId, required this.geofenceName, required this.type, required this.timestamp, required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {
    'geofenceId': geofenceId,
    'geofenceName': geofenceName,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  };

  factory GeofenceEvent.fromJson(Map<String, dynamic> json) => GeofenceEvent(
    geofenceId: json['geofenceId'],
    geofenceName: json['geofenceName'],
    type: GeofenceEventType.values.firstWhere((e) => e.name == json['type']),
    timestamp: DateTime.parse(json['timestamp']),
    latitude: json['latitude'],
    longitude: json['longitude'],
  );
}

enum GeofenceEventType { entered, exited, dwelled }
