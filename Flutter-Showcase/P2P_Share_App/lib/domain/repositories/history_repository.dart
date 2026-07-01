import '../entities/transfer_history_entry.dart';

abstract class HistoryRepository {
  Future<List<TransferHistoryEntry>> loadHistory();
  Stream<List<TransferHistoryEntry>> watchHistory();
  Future<void> saveEntries(List<TransferHistoryEntry> entries);
  Future<void> deleteEntry(String id);
}
