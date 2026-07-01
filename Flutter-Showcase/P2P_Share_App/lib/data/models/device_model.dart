import '../../domain/entities/device.dart';

class DeviceModel extends Device {
  const DeviceModel({
    required super.id,
    required super.name,
    required super.ipAddress,
    required super.port,
    required super.lastSeen,
    super.kind,
    super.isConnected,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final type = (json['kind'] as String?) ?? 'phone';
    return DeviceModel(
      id: json['id'] as String? ?? json['ipAddress'] as String? ?? '',
      name: json['deviceName'] as String? ?? 'Nearby device',
      ipAddress: json['ipAddress'] as String? ?? '',
      port: (json['port'] as num?)?.toInt() ?? 0,
      lastSeen: DateTime.now(),
      kind: switch (type) {
        'tablet' => DeviceKind.tablet,
        'desktop' => DeviceKind.desktop,
        'phone' => DeviceKind.phone,
        _ => DeviceKind.unknown,
      },
      isConnected: json['isConnected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceName': name,
      'ipAddress': ipAddress,
      'port': port,
      'kind': kind.name,
      'isConnected': isConnected,
    };
  }
}
