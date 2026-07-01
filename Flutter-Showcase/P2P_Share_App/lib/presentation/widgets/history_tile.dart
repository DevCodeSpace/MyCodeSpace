import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transfer_history_entry.dart';
import 'file_type_badge.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.entry,
    this.compact = false,
    this.onTap,
    this.onLongPress,
  });

  final TransferHistoryEntry entry;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (entry.status) {
      TransferRecordStatus.completed => AppTheme.gold,
      TransferRecordStatus.cancelled => AppTheme.textMuted,
      TransferRecordStatus.failed => AppTheme.coral,
      TransferRecordStatus.inProgress => const Color(0xFFC49A74),
    };
    final directionIcon = entry.direction == TransferDirection.sent
        ? Icons.north_east_rounded
        : Icons.south_west_rounded;
    final directionLabel = entry.direction == TransferDirection.sent
        ? 'Sent'
        : 'Received';

    final child = compact
        ? _CompactHistoryCard(
            entry: entry,
            directionIcon: directionIcon,
            directionLabel: directionLabel,
            statusColor: statusColor,
          )
        : _ExpandedHistoryTile(
            entry: entry,
            directionIcon: directionIcon,
            directionLabel: directionLabel,
            statusColor: statusColor,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(compact ? 24 : 22),
        splashColor: AppTheme.gold.withValues(alpha: 0.08),
        highlightColor: AppTheme.textPrimary.withValues(alpha: 0.03),
        child: child,
      ),
    );
  }
}

class _ExpandedHistoryTile extends StatelessWidget {
  const _ExpandedHistoryTile({
    required this.entry,
    required this.directionIcon,
    required this.directionLabel,
    required this.statusColor,
  });

  final TransferHistoryEntry entry;
  final IconData directionIcon;
  final String directionLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.panel.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          FileTypeBadge(category: entry.fileCategory),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      Formatters.fileSize(entry.fileSize),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    _MetaPill(
                      icon: directionIcon,
                      label: directionLabel,
                      color: AppTheme.textMuted,
                    ),
                    Text(
                      entry.peerName,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.time(entry.timestamp),
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _labelForStatus(entry.status).toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactHistoryCard extends StatelessWidget {
  const _CompactHistoryCard({
    required this.entry,
    required this.directionIcon,
    required this.directionLabel,
    required this.statusColor,
  });

  final TransferHistoryEntry entry;
  final IconData directionIcon;
  final String directionLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FileTypeBadge(category: entry.fileCategory),
              const Spacer(),
              _MetaPill(
                icon: directionIcon,
                label: directionLabel,
                color: AppTheme.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            entry.fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.fileSize(entry.fileSize),
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  Formatters.relativeTime(entry.timestamp),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _labelForStatus(entry.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _labelForStatus(TransferRecordStatus status) {
  return switch (status) {
    TransferRecordStatus.completed => 'Completed',
    TransferRecordStatus.cancelled => 'Cancelled',
    TransferRecordStatus.failed => 'Failed',
    TransferRecordStatus.inProgress => 'In Progress',
  };
}
