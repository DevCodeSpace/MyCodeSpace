import 'device.dart';

class TransferRequest {
  const TransferRequest({required this.requestId, required this.sender});

  final String requestId;
  final Device sender;
}
