import 'dart:typed_data';

enum FileCategory { image, video, audio, document, app }

class SharedFile {
  const SharedFile({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.category,
    this.isFolder = false,
    this.secondaryLabel,
    this.thumbnailBytes,
    this.durationMillis,
  });

  final String id;
  final String name;
  final String path;
  final int size;
  final FileCategory category;
  final bool isFolder;
  final String? secondaryLabel;
  final Uint8List? thumbnailBytes;
  final int? durationMillis;
}
