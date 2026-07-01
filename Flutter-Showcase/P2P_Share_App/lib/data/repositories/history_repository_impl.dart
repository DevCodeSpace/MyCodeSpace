import 'dart:async';

import '../../domain/entities/transfer_history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/local/history_local_data_source.dart';
import '../models/transfer_history_entry_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required this.localDataSource});

  final HistoryLocalDataSource localDataSource;
  final StreamController<List<TransferHistoryEntry>> _historyController =
      StreamController<List<TransferHistoryEntry>>.broadcast();

  @override
  Future<List<TransferHistoryEntry>> loadHistory() async {
    final entries = await localDataSource.loadHistory();
    return entries.reversed.toList();
  }

  @override
  Stream<List<TransferHistoryEntry>> watchHistory() async* {
    yield await loadHistory();
    yield* _historyController.stream;
  }

  @override
  Future<void> saveEntries(List<TransferHistoryEntry> entries) async {
    final existingEntries = await localDataSource.loadHistory();
    final updated = [
      ...existingEntries,
      ...entries.map(TransferHistoryModel.fromEntity),
    ];
    await localDataSource.saveHistory(updated.take(60).toList());
    _historyController.add(await loadHistory());
  }

  @override
  Future<void> deleteEntry(String id) async {
    final existingEntries = await localDataSource.loadHistory();
    final updated = existingEntries.where((entry) => entry.id != id).toList();
    await localDataSource.saveHistory(updated);
    _historyController.add(await loadHistory());
  }
}
