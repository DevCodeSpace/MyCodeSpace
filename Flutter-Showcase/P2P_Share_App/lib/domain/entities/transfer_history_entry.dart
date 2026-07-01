import 'shared_file.dart';

enum TransferDirection { sent, received }

enum TransferRecordStatus { completed, cancelled, failed, inProgress }

class TransferHistoryEntry {
  const TransferHistoryEntry({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileCategory,
    required this.direction,
    required this.status,
    required this.peerName,
    required this.timestamp,
  });

  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final FileCategory fileCategory;
  final TransferDirection direction;
  final TransferRecordStatus status;
  final String peerName;
  final DateTime timestamp;
}
