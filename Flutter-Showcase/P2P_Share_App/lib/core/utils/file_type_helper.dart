import '../../domain/entities/shared_file.dart';

class FileTypeHelper {
  static FileCategory detect(String name) {
    final lower = name.toLowerCase();
    if (_matches(lower, ['.png', '.jpg', '.jpeg', '.gif', '.webp', '.heic'])) {
      return FileCategory.image;
    }
    if (_matches(lower, ['.mp4', '.mov', '.mkv', '.avi', '.webm'])) {
      return FileCategory.video;
    }
    if (_matches(lower, ['.mp3', '.wav', '.aac', '.m4a', '.flac'])) {
      return FileCategory.audio;
    }
    if (_matches(lower, ['.apk'])) {
      return FileCategory.app;
    }
    return FileCategory.document;
  }

  static bool _matches(String value, List<String> extensions) {
    return extensions.any(value.endsWith);
  }
}
