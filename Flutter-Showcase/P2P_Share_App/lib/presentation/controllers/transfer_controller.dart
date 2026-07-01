import 'dart:async';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../domain/entities/share_manifest.dart';
import '../../domain/entities/shared_file.dart';
import '../../domain/entities/transfer_session.dart';
import '../../domain/repositories/transfer_repository.dart';

class TransferController extends GetxController {
  TransferController({required this.transferRepository});

  final TransferRepository transferRepository;

  late final StreamSubscription<TransferSession> _subscription;
  final session = const TransferSession(
    role: TransferRole.sender,
    status: TransferStatus.idle,
    peerName: 'No active transfer',
    files: [],
    totalBytes: 0,
    transferredBytes: 0,
    speedBytesPerSecond: 0,
    etaSeconds: 0,
    ipAddress: '',
    activeFileName: null,
  ).obs;

  final errorText = RxnString();

  @override
  void onInit() {
    super.onInit();
    session.value = transferRepository.currentSession;
    _subscription = transferRepository.watchSession().listen((event) {
      session.value = event;
    });

    // Auto-redirect after transfer terminal state
    ever(session, (state) {
      if (state.status == TransferStatus.completed ||
          state.status == TransferStatus.failed ||
          state.status == TransferStatus.cancelled) {
        final isCancelled = state.status == TransferStatus.cancelled;

        Future.delayed(Duration(seconds: isCancelled ? 2 : 3), () {
          // Robust check for being on transfer screen
          final currentRoute = Get.currentRoute;
          if (currentRoute == AppRoutes.transfer || 
              currentRoute.endsWith(AppRoutes.transfer)) {
            if (isCancelled) {
              Get.offAllNamed(AppRoutes.home);
            } else {
              Get.offNamed(AppRoutes.history);
            }
          }
        });
      }
    });
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  Future<void> startSharing(List<SharedFile> files) async {
    errorText.value = null;
    try {
      await transferRepository.startSharing(files);
    } catch (error) {
      errorText.value = error.toString();
    }
  }

  Future<void> startReceiving({
    required String ipAddress,
    required ShareManifest manifest,
  }) async {
    errorText.value = null;
    try {
      await transferRepository.downloadFiles(
        ipAddress: ipAddress,
        manifest: manifest,
      );
    } catch (error) {
      errorText.value = error.toString();
    }
  }

  Future<void> pauseOrResume() => transferRepository.pauseOrResume();
  Future<void> cancel() => transferRepository.cancel();
}
