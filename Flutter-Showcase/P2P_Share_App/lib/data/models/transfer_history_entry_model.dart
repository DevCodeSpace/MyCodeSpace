import '../../domain/entities/transfer_history_entry.dart';
import '../../domain/entities/shared_file.dart';

class TransferHistoryModel extends TransferHistoryEntry {
  const TransferHistoryModel({
    required super.id,
    required super.fileName,
    required super.filePath,
    required super.fileSize,
    required super.fileCategory,
    required super.direction,
    required super.status,
    required super.peerName,
    required super.timestamp,
  });

  factory TransferHistoryModel.fromEntity(TransferHistoryEntry entry) {
    return TransferHistoryModel(
      id: entry.id,
      fileName: entry.fileName,
      filePath: entry.filePath,
      fileSize: entry.fileSize,
      fileCategory: entry.fileCategory,
      direction: entry.direction,
      status: entry.status,
      peerName: entry.peerName,
      timestamp: entry.timestamp,
    );
  }

  factory TransferHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransferHistoryModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String? ?? '',
      fileSize: json['fileSize'] as int,
      fileCategory: FileCategory.values.firstWhere(
        (value) => value.name == json['fileCategory'],
        orElse: () => FileCategory.document,
      ),
      direction: switch (json['direction']) {
        'sent' || 'sender' => TransferDirection.sent,
        'received' || 'receiver' => TransferDirection.received,
        _ => TransferDirection.received,
      },
      status: TransferRecordStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => TransferRecordStatus.completed,
      ),
      peerName: json['peerName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'fileCategory': fileCategory.name,
      'direction': direction.name,
      'status': status.name,
      'peerName': peerName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
