enum DeviceKind { phone, tablet, desktop, unknown }

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.lastSeen,
    this.kind = DeviceKind.phone,
    this.isConnected = false,
  });

  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final DateTime lastSeen;
  final DeviceKind kind;
  final bool isConnected;

  Device copyWith({
    String? id,
    String? name,
    String? ipAddress,
    int? port,
    DateTime? lastSeen,
    DeviceKind? kind,
    bool? isConnected,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      lastSeen: lastSeen ?? this.lastSeen,
      kind: kind ?? this.kind,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
