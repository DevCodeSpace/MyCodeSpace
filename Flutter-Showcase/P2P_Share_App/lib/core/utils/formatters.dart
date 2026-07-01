import 'package:intl/intl.dart';

class Formatters {
  static String fileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(size >= 100 ? 0 : 1)} ${units[unitIndex]}';
  }

  static String speed(double bytesPerSecond) {
    if (bytesPerSecond <= 0) return '0 MB/s';
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
  }

  static String eta(int seconds) {
    if (seconds <= 0) return 'Almost done';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes == 0) return '${remainingSeconds}s left';
    return '${minutes}m ${remainingSeconds}s left';
  }

  static String date(DateTime value) {
    return DateFormat('dd MMM, hh:mm a').format(value);
  }

  static String time(DateTime value) {
    return DateFormat('hh:mm a').format(value);
  }

  static String relativeTime(DateTime value) {
    final now = DateTime.now();
    final difference = now.difference(value);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';

    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return DateFormat('dd MMM').format(value);
  }
}
