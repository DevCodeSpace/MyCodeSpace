import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart';

class TransferProgress {
  final String fileName;
  final double progress;
  final int bytesSent;
  final int totalBytes;
  final bool isComplete;
  final bool hasError;

  TransferProgress({
    required this.fileName,
    required this.progress,
    required this.bytesSent,
    required this.totalBytes,
    this.isComplete = false,
    this.hasError = false,
  });
}

class FileTransferService extends GetxService {
  final Rx<TransferProgress?> currentTransfer = Rx<TransferProgress?>(null);

  // Constants for optimization
  static const int defaultChunkSize =
      490; // Optimized for common MTU settings minus header
  static const int maxRetries = 3;

  /// Sends a file via Bluetooth characteristic
  Future<void> sendFile(
    BluetoothDevice device,
    BluetoothCharacteristic characteristic,
    File file,
  ) async {
    final fileName = file.path.split('/').last;
    final bytes = await file.readAsBytes();
    final totalSize = bytes.length;

    // 1. Request MTU for speed (Android only, iOS is automatic)
    if (Platform.isAndroid) {
      await device.requestMtu(512);
    }

    int offset = 0;
    int chunkIndex = 0;

    currentTransfer.value = TransferProgress(
      fileName: fileName,
      progress: 0.0,
      bytesSent: 0,
      totalBytes: totalSize,
    );

    try {
      while (offset < totalSize) {
        int end = offset + defaultChunkSize;
        if (end > totalSize) {
          end = totalSize;
        }

        final chunkData = bytes.sublist(offset, end);

        // Header: [TotalChunks (4 bytes), CurrentIndex (4 bytes), Data...]
        // For simplicity in this demo, we just send the raw chunk or a wrapped one
        bool success = await _sendChunkWithRetry(characteristic, chunkData);

        if (!success) {
          throw Exception(
            'Failed to send chunk $chunkIndex after $maxRetries retries',
          );
        }

        offset = end;
        chunkIndex++;

        currentTransfer.value = TransferProgress(
          fileName: fileName,
          progress: offset / totalSize,
          bytesSent: offset,
          totalBytes: totalSize,
          isComplete: offset == totalSize,
        );
      }
    } catch (e) {
      currentTransfer.value = TransferProgress(
        fileName: fileName,
        progress: offset / totalSize,
        bytesSent: offset,
        totalBytes: totalSize,
        hasError: true,
      );
      rethrow;
    }
  }

  Future<bool> _sendChunkWithRetry(
    BluetoothCharacteristic characteristic,
    List<int> data,
  ) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        // Use writeWithoutResponse for speed if supported, else write
        await characteristic.write(
          data,
          withoutResponse: characteristic.properties.writeWithoutResponse,
        );
        return true;
      } catch (e) {
        attempts++;
        await Future.delayed(Duration(milliseconds: 100 * attempts));
      }
    }
    return false;
  }

  /// Receiver logic: Collects incoming bytes and rebuilds file
  final Map<String, List<int>> _receiveBuffers = {};

  void handleIncomingData(String deviceId, List<int> data) async {
    if (!_receiveBuffers.containsKey(deviceId)) {
      _receiveBuffers[deviceId] = [];
    }

    _receiveBuffers[deviceId]!.addAll(data);

    // In a real protocol, you'd check for a 'EOF' or 'TotalSize' header
    // For this service, we assume the caller manages when the file is finished
  }

  Future<File?> assembleFile(String deviceId, String fileName) async {
    final data = _receiveBuffers[deviceId];
    if (data == null || data.isEmpty) return null;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(data);

    _receiveBuffers.remove(deviceId);
    return file;
  }
}
