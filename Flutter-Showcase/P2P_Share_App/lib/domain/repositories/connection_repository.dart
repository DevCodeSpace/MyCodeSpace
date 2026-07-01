import '../entities/device.dart';
import '../entities/pairing_request.dart';
import '../entities/share_manifest.dart';
import '../entities/transfer_request.dart';

abstract class ConnectionRepository {
  Future<void> ensureRunning();
  Future<String?> getLocalIpAddress();
  Future<List<Device>> discoverPeers();
  Future<Device?> probePeer(String ipAddress);
  Future<ShareManifest> fetchManifest(String ipAddress);
  Future<Device?> sendPairingRequest(Device device);
  Future<bool> sendTransferRequest(Device device);
  Future<void> acceptPairingRequest(String requestId);
  Future<void> rejectPairingRequest(String requestId);
  Future<void> acceptTransferRequest(String requestId);
  Future<void> rejectTransferRequest(String requestId);
  Future<void> disconnect(Device device);
  Stream<PairingRequest> watchPairingRequests();
  Stream<TransferRequest> watchTransferRequests();
  Stream<Device> watchDisconnections();
}
