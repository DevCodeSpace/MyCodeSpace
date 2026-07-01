import 'shared_file.dart';

enum TransferRole { sender, receiver }

enum TransferStatus {
  idle,
  waiting,
  requesting,
  transferring,
  paused,
  completed,
  cancelled,
  failed,
}

class TransferSession {
  const TransferSession({
    required this.role,
    required this.status,
    required this.peerName,
    required this.files,
    required this.totalBytes,
    required this.transferredBytes,
    required this.speedBytesPerSecond,
    required this.etaSeconds,
    required this.ipAddress,
    this.activeFileName,
    this.message,
    this.shareCode,
  });

  final TransferRole role;
  final TransferStatus status;
  final String peerName;
  final List<SharedFile> files;
  final int totalBytes;
  final int transferredBytes;
  final double speedBytesPerSecond;
  final int etaSeconds;
  final String ipAddress;
  final String? activeFileName;
  final String? message;
  final String? shareCode;

  double get progress => totalBytes == 0 ? 0 : transferredBytes / totalBytes;

  TransferSession copyWith({
    TransferRole? role,
    TransferStatus? status,
    String? peerName,
    List<SharedFile>? files,
    int? totalBytes,
    int? transferredBytes,
    double? speedBytesPerSecond,
    int? etaSeconds,
    String? ipAddress,
    String? activeFileName,
    String? message,
    String? shareCode,
  }) {
    return TransferSession(
      role: role ?? this.role,
      status: status ?? this.status,
      peerName: peerName ?? this.peerName,
      files: files ?? this.files,
      totalBytes: totalBytes ?? this.totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      speedBytesPerSecond: speedBytesPerSecond ?? this.speedBytesPerSecond,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      ipAddress: ipAddress ?? this.ipAddress,
      activeFileName: activeFileName ?? this.activeFileName,
      message: message ?? this.message,
      shareCode: shareCode ?? this.shareCode,
    );
  }
}
