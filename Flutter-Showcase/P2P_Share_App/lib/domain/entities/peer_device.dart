class PeerDevice {
  const PeerDevice({
    required this.name,
    required this.ipAddress,
    required this.port,
    required this.lastSeen,
  });

  final String name;
  final String ipAddress;
  final int port;
  final DateTime lastSeen;
}
