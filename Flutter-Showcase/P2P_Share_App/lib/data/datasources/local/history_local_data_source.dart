import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/transfer_history_entry_model.dart';

class HistoryLocalDataSource {
  HistoryLocalDataSource(this.preferences);

  final SharedPreferences preferences;

  Future<List<TransferHistoryModel>> loadHistory() async {
    final raw = preferences.getString(AppConstants.historyStorageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (entry) =>
              TransferHistoryModel.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> saveHistory(List<TransferHistoryModel> entries) async {
    final encoded = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    await preferences.setString(AppConstants.historyStorageKey, encoded);
  }
}
