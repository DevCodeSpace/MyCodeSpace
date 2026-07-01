class Device {
  final String ip;
  final String name;

  Device({required this.ip, required this.name});

  Map<String, dynamic> toJson() => {'ip': ip, 'name': name};

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(ip: json['ip'], name: json['name']);
  }
}
