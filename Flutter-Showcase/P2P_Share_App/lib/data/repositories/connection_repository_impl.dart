import '../../domain/entities/device.dart';
import '../../domain/entities/pairing_request.dart';
import '../../domain/entities/share_manifest.dart';
import '../../domain/entities/transfer_request.dart';
import '../../domain/repositories/connection_repository.dart';
import '../services/connection_service.dart';
import '../services/transfer_service.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  ConnectionRepositoryImpl({
    required this.connectionService,
    required this.transferService,
  });

  final ConnectionService connectionService;
  final TransferService transferService;

  @override
  Future<void> acceptPairingRequest(String requestId) {
    return connectionService.acceptPairingRequest(requestId);
  }

  @override
  Future<void> acceptTransferRequest(String requestId) {
    return connectionService.acceptTransferRequest(requestId);
  }

  @override
  Future<List<Device>> discoverPeers() {
    return connectionService.discoverPeers();
  }

  @override
  Future<void> ensureRunning() {
    return connectionService.ensureRunning();
  }

  @override
  Future<ShareManifest> fetchManifest(String ipAddress) {
    return transferService.fetchManifest(ipAddress);
  }

  @override
  Future<String?> getLocalIpAddress() {
    return connectionService.getLocalIpAddress();
  }

  @override
  Future<Device?> probePeer(String ipAddress) {
    return connectionService.probePeer(ipAddress);
  }

  @override
  Future<void> rejectPairingRequest(String requestId) {
    return connectionService.rejectPairingRequest(requestId);
  }

  @override
  Future<void> rejectTransferRequest(String requestId) {
    return connectionService.rejectTransferRequest(requestId);
  }

  @override
  Future<Device?> sendPairingRequest(Device device) {
    return connectionService.sendPairingRequest(device);
  }

  @override
  Future<bool> sendTransferRequest(Device device) {
    return connectionService.sendTransferRequest(device);
  }

  @override
  Future<void> disconnect(Device device) {
    return connectionService.sendDisconnectRequest(device);
  }

  @override
  Stream<PairingRequest> watchPairingRequests() {
    return connectionService.watchPairingRequests();
  }

  @override
  Stream<TransferRequest> watchTransferRequests() {
    return connectionService.watchTransferRequests();
  }

  @override
  Stream<Device> watchDisconnections() {
    return connectionService.watchDisconnections();
  }
}
