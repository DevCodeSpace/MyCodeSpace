import '../../domain/entities/share_manifest.dart';
import '../../domain/entities/shared_file.dart';
import 'shared_file_model.dart';

class ShareManifestModel extends ShareManifest {
  const ShareManifestModel({
    required super.deviceName,
    required super.ipAddress,
    required super.port,
    required super.files,
    required super.totalBytes,
  });

  factory ShareManifestModel.fromJson(Map<String, dynamic> json) {
    final files = (json['files'] as List<dynamic>)
        .map((item) => SharedFileModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return ShareManifestModel(
      deviceName: json['deviceName'] as String,
      ipAddress: json['ipAddress'] as String,
      port: json['port'] as int,
      files: files,
      totalBytes: json['totalBytes'] as int,
    );
  }

  factory ShareManifestModel.fromEntity(ShareManifest manifest) {
    return ShareManifestModel(
      deviceName: manifest.deviceName,
      ipAddress: manifest.ipAddress,
      port: manifest.port,
      files: manifest.files,
      totalBytes: manifest.totalBytes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'ipAddress': ipAddress,
      'port': port,
      'totalBytes': totalBytes,
      'files': files
          .map(
            (SharedFile file) =>
                SharedFileModel.fromEntity(file).toJson(includePath: false),
          )
          .toList(),
    };
  }
}
