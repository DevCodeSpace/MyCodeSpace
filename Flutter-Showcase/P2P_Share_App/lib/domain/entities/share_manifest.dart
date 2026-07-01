import 'shared_file.dart';

class ShareManifest {
  const ShareManifest({
    required this.deviceName,
    required this.ipAddress,
    required this.port,
    required this.files,
    required this.totalBytes,
  });

  final String deviceName;
  final String ipAddress;
  final int port;
  final List<SharedFile> files;
  final int totalBytes;
}
