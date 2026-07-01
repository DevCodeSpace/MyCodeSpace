import '../../domain/entities/share_manifest.dart';
import '../../domain/entities/shared_file.dart';
import '../../domain/entities/transfer_history_entry.dart';
import '../../domain/entities/transfer_session.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../services/permission_service.dart';
import '../services/transfer_service.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl({
    required this.transferService,
    required this.historyRepository,
    required this.permissionService,
  });

  final TransferService transferService;
  final HistoryRepository historyRepository;
  final PermissionService permissionService;
  String? _lastSavedSignature;

  @override
  TransferSession get currentSession => transferService.currentSession;

  @override
  Future<void> cancel() async {
    await transferService.cancel();
  }

  @override
  Future<void> downloadFiles({
    required String ipAddress,
    required ShareManifest manifest,
  }) async {
    final hasPermission = await permissionService.ensureTransferPermissions();
    if (!hasPermission) {
      throw Exception('Storage permission is required to receive files.');
    }

    await transferService.downloadFiles(
      ipAddress: ipAddress,
      manifest: manifest,
    );
  }

  @override
  Future<void> pauseOrResume() {
    return transferService.pauseOrResume();
  }

  @override
  Future<void> startSharing(List<SharedFile> files) async {
    await transferService.startSharing(files);
  }

  @override
  Stream<TransferSession> watchSession() async* {
    await for (final session in transferService.watchSession()) {
      await _persistIfNeeded(session);
      yield session;
    }
  }

  Future<void> _persistIfNeeded(TransferSession session) async {
    final status = session.status;
    if (status != TransferStatus.completed &&
        status != TransferStatus.cancelled &&
        status != TransferStatus.failed) {
      return;
    }

    final signature =
        '${session.role.name}-${status.name}-${session.totalBytes}-${session.files.length}-${session.peerName}';
    if (_lastSavedSignature == signature) return;
    _lastSavedSignature = signature;

    final direction = session.role == TransferRole.sender
        ? TransferDirection.sent
        : TransferDirection.received;
    final recordStatus = switch (status) {
      TransferStatus.completed => TransferRecordStatus.completed,
      TransferStatus.cancelled => TransferRecordStatus.cancelled,
      TransferStatus.failed => TransferRecordStatus.failed,
      _ => TransferRecordStatus.completed,
    };

    final entries = await transferService.buildHistoryEntries(
      direction: direction,
      status: recordStatus,
    );
    if (entries.isNotEmpty) {
      await historyRepository.saveEntries(entries);
    }
  }
}
