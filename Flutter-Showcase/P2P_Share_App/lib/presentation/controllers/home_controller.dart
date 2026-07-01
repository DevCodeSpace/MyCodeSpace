import 'dart:async';

import 'package:get/get.dart';

import '../../domain/entities/transfer_history_entry.dart';
import '../../domain/repositories/history_repository.dart';

class HomeController extends GetxController {
  HomeController({required this.historyRepository});

  final HistoryRepository historyRepository;
  StreamSubscription<List<TransferHistoryEntry>>? _historySubscription;

  final recentTransfers = <TransferHistoryEntry>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _historySubscription = historyRepository.watchHistory().listen((entries) {
      recentTransfers.assignAll(entries.take(8));
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _historySubscription?.cancel();
    super.onClose();
  }

  Future<void> loadRecentTransfers() async {
    isLoading.value = true;
    final entries = await historyRepository.loadHistory();
    recentTransfers.assignAll(entries.take(8));
    isLoading.value = false;
  }
}
