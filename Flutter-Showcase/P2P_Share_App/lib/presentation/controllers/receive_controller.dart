import 'package:get/get.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/share_manifest.dart';
import '../../domain/repositories/connection_repository.dart';
import 'transfer_controller.dart';

class ReceiveController extends GetxController {
  ReceiveController({
    required this.connectionRepository,
    required this.transferController,
  });

  final ConnectionRepository connectionRepository;
  final TransferController transferController;

  final discoveredPeers = <Device>[].obs;
  final isScanning = false.obs;
  final manualIp = ''.obs;
  final incomingManifest = Rxn<ShareManifest>();
  final connectionMessage = 'Listening for nearby senders.'.obs;

  Future<void> discoverPeers() async {
    isScanning.value = true;
    connectionMessage.value = 'Searching for nearby devices...';
    discoveredPeers.assignAll(await connectionRepository.discoverPeers());
    connectionMessage.value = discoveredPeers.isEmpty
        ? 'No nearby devices found.'
        : 'Nearby devices discovered.';
    isScanning.value = false;
  }

  Future<void> inspectPeer(String ipAddress) async {
    connectionMessage.value = 'Requesting file manifest from $ipAddress...';
    incomingManifest.value = await connectionRepository.fetchManifest(
      ipAddress,
    );
    manualIp.value = ipAddress;
    connectionMessage.value = 'Incoming files are ready to review.';
  }

  Future<void> acceptIncomingTransfer() async {
    final manifest = incomingManifest.value;
    if (manifest == null) return;

    await transferController.startReceiving(
      ipAddress: manualIp.value,
      manifest: manifest,
    );
  }
}
