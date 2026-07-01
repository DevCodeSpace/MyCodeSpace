import 'device.dart';

class PairingRequest {
  const PairingRequest({required this.requestId, required this.sender});

  final String requestId;
  final Device sender;
}
