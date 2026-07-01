import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transfer_history_entry.dart';
import '../controllers/history_controller.dart';
import '../controllers/send_controller.dart';
import 'file_type_badge.dart';

class HistoryEntrySheet {
  static Future<void> showDetails(TransferHistoryEntry entry) {
    return showModalBottomSheet<void>(
      context: Get.context!,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FileTypeBadge(category: entry.fileCategory),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        entry.fileName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _DetailRow(label: 'Status', value: _statusText(entry.status)),
                _DetailRow(
                  label: 'Direction',
                  value: entry.direction == TransferDirection.sent
                      ? 'Sent'
                      : 'Received',
                ),
                _DetailRow(
                  label: 'Size',
                  value: Formatters.fileSize(entry.fileSize),
                ),
                _DetailRow(label: 'Peer', value: entry.peerName),
                _DetailRow(
                  label: 'When',
                  value: Formatters.date(entry.timestamp),
                ),
                _DetailRow(
                  label: 'Path',
                  value: entry.filePath.isEmpty
                      ? 'Unavailable'
                      : entry.filePath,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showActions(TransferHistoryEntry entry) {
    return showModalBottomSheet<void>(
      context: Get.context!,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  leading: const Icon(
                    Icons.refresh_rounded,
                    color: AppTheme.gold,
                  ),
                  title: const Text('Share again'),
                  subtitle: const Text(
                    'Re-add this file to your sending tray if it still exists.',
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final sendController = Get.find<SendController>();
                    await sendController.shareAgain(entry);
                    if (Get.currentRoute != AppRoutes.send) {
                      Get.toNamed(AppRoutes.send);
                    }
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.coral,
                  ),
                  title: const Text('Delete from history'),
                  subtitle: const Text(
                    'Remove this transfer from your local log.',
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await Get.find<HistoryController>().deleteEntry(entry.id);
                  },
                ),
                if (entry.filePath.isNotEmpty &&
                    File(entry.filePath).existsSync())
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.textMuted,
                    ),
                    title: const Text('View details'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showDetails(entry);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusText(TransferRecordStatus status) {
  return switch (status) {
    TransferRecordStatus.completed => 'Completed',
    TransferRecordStatus.cancelled => 'Cancelled',
    TransferRecordStatus.failed => 'Failed',
    TransferRecordStatus.inProgress => 'In Progress',
  };
}
