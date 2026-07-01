import '../entities/share_manifest.dart';
import '../entities/shared_file.dart';
import '../entities/transfer_session.dart';

abstract class TransferRepository {
  Stream<TransferSession> watchSession();
  TransferSession get currentSession;
  Future<void> startSharing(List<SharedFile> files);
  Future<void> downloadFiles({
    required String ipAddress,
    required ShareManifest manifest,
  });
  Future<void> pauseOrResume();
  Future<void> cancel();
}
