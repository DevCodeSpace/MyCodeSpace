import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/shared_file.dart';
import '../../domain/entities/transfer_session.dart';
import '../controllers/connection_controller.dart';
import '../controllers/transfer_controller.dart';
import '../widgets/app_dock_nav.dart';
import '../widgets/app_shell.dart';
import '../widgets/brand_header.dart';
import '../widgets/primary_action_button.dart';

class TransferScreen extends GetView<TransferController> {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionController = Get.find<ConnectionController>();
    return AppShell(
      activeTab: DockTab.log,
      child: Obx(() {
        final session = controller.session.value;
        final isTerminal = session.status == TransferStatus.completed ||
            session.status == TransferStatus.failed ||
            session.status == TransferStatus.cancelled;

        return Stack(
          children: [
            Column(
              children: [
                const BrandHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 140),
                    children: [
                      _ConnectionPill(
                        label:
                            connectionController.connectedDevice.value?.name ??
                            session.peerName,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        session.activeFileName == null
                            ? 'Preparing Transfer'
                            : '${session.role == TransferRole.sender ? 'Transferring' : 'Receiving'} ${session.activeFileName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final ringSize = (constraints.maxWidth * 0.58).clamp(
                            140.0,
                            200.0,
                          );
                          return _ProgressRing(
                            progress: session.progress,
                            size: ringSize,
                            label: session.role == TransferRole.sender
                                ? 'Uploaded'
                                : 'Received',
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Speed',
                              value: Formatters.speed(
                                session.speedBytesPerSecond,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _MetricCard(
                              label: 'Time Left',
                              value: _timeLeftText(session.etaSeconds),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      if (session.role == TransferRole.receiver)
                        Row(
                          children: [
                            Expanded(
                              child: PrimaryActionButton(
                                label: session.status == TransferStatus.paused
                                    ? 'Resume'
                                    : 'Pause',
                                icon: session.status == TransferStatus.paused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                enabled:
                                    session.status ==
                                        TransferStatus.transferring ||
                                    session.status == TransferStatus.paused,
                                onTap: controller.pauseOrResume,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _GhostAction(
                                label: 'Cancel',
                                icon: Icons.close_rounded,
                                onTap: controller.cancel,
                              ),
                            ),
                          ],
                        )
                      else
                        _GhostAction(
                          label: session.status == TransferStatus.completed
                              ? 'Close Session'
                              : 'Cancel',
                          icon: Icons.close_rounded,
                          onTap: controller.cancel,
                        ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Text(
                            'TRANSFER QUEUE (${session.files.length})',
                            style: const TextStyle(
                              color: AppTheme.textSoft,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            session.status == TransferStatus.completed
                                ? 'Completed'
                                : 'Auto-clear ON',
                            style: const TextStyle(
                              color: AppTheme.goldSoft,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...session.files.map(
                        (file) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _QueueCard(
                            file: file,
                            active: session.activeFileName == file.name,
                            pending:
                                session.activeFileName != null &&
                                session.activeFileName != file.name &&
                                session.status != TransferStatus.completed,
                            progress: session.activeFileName == file.name
                                ? session.progress
                                : 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isTerminal)
              _StatusOverlay(
                status: session.status,
              ),
          ],
        );
      }),
    );
  }
}

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.panelBlue,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_tethering_rounded, color: AppTheme.goldSoft),
            const SizedBox(width: 12),
            Text(
              'Connected to ${label.toUpperCase()}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.size,
    required this.label,
  });

  final double progress;
  final double size;
  final String label;

  @override
  Widget build(BuildContext context) {
    final normalized = progress.clamp(0.0, 1.0);
    final fontSize = (size * 0.16).clamp(32.0, 48.0);
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(
                value: 1,
                strokeWidth: 8,
                color: Color(0xFF31404A),
                backgroundColor: Color(0xFF31404A),
              ),
            ),
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: normalized,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                color: AppTheme.gold,
                backgroundColor: Colors.transparent,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(normalized * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.goldSoft,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    letterSpacing: 2.8,
                    color: AppTheme.goldSoft,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.panel.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.goldSoft,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.panelBlue,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textPrimary),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    required this.file,
    required this.active,
    required this.pending,
    required this.progress,
  });

  final SharedFile file;
  final bool active;
  final bool pending;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.panelBlue,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: active
              ? AppTheme.goldSoft
              : AppTheme.gold.withValues(alpha: 0.10),
          width: active ? 1.3 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_iconFor(file.category), color: AppTheme.goldSoft, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: active ? AppTheme.textPrimary : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                if (active)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      color: AppTheme.goldSoft,
                      backgroundColor: const Color(0xFF31404A),
                    ),
                  )
                else
                  Text(
                    Formatters.fileSize(file.size),
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            active
                ? 'Active'
                : pending
                ? 'Pending'
                : 'Done',
            style: TextStyle(
              color: active ? AppTheme.goldSoft : AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(FileCategory category) {
    return switch (category) {
      FileCategory.image => Icons.image_outlined,
      FileCategory.video => Icons.movie_creation_outlined,
      FileCategory.audio => Icons.headphones_rounded,
      FileCategory.document => Icons.description_outlined,
      FileCategory.app => Icons.inventory_2_outlined,
    };
  }
}

String _timeLeftText(int seconds) {
  if (seconds <= 0) return '00:00 sec';
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')} sec';
}

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.status});

  final TransferStatus status;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == TransferStatus.completed;
    final isCancelled = status == TransferStatus.cancelled;
    
    final color = isSuccess 
        ? Colors.green 
        : isCancelled 
            ? Colors.orange 
            : Colors.red;
            
    final icon = isSuccess 
        ? Icons.check_circle_rounded 
        : isCancelled 
            ? Icons.cancel_outlined 
            : Icons.error_outline_rounded;
            
    final title = isSuccess 
        ? 'DONE' 
        : isCancelled 
            ? 'TRANSFER CANCELED' 
            : 'TRANSFER FAILED';
            
    final subtitle = isSuccess
        ? 'All files secured.'
        : isCancelled
            ? 'The transfer was aborted. Redirecting...'
            : 'Something went wrong. Redirecting...';

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
