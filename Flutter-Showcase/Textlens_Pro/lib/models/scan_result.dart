class ScanResult {
  final String fullText;
  final DateTime timestamp;
  final String source; // 'camera' or 'gallery'

  const ScanResult({
    required this.fullText,
    required this.timestamp,
    required this.source,
  });
}
