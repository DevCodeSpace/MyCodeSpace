import 'dart:async';

import 'package:get/get.dart';

import '../../domain/entities/transfer_history_entry.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryController extends GetxController {
  HistoryController({required this.historyRepository});

  final HistoryRepository historyRepository;
  StreamSubscription<List<TransferHistoryEntry>>? _historySubscription;

  final entries = <TransferHistoryEntry>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _historySubscription = historyRepository.watchHistory().listen((items) {
      entries.assignAll(items);
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _historySubscription?.cancel();
    super.onClose();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    entries.assignAll(await historyRepository.loadHistory());
    isLoading.value = false;
  }

  Future<void> deleteEntry(String id) => historyRepository.deleteEntry(id);

  List<TransferHistoryEntry> entriesForGroup(String group) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return entries.where((entry) {
      final day = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      return switch (group) {
        'Today' => day == today,
        'Yesterday' => day == yesterday,
        'Older' => day.isBefore(yesterday),
        _ => false,
      };
    }).toList();
  }
}
