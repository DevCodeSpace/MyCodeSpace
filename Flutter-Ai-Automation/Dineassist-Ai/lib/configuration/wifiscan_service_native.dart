import 'dart:io';

class WifiPrinterScanner {
  static Future<List<String>> scanNetwork({String subnet = "192.168.1", int port = 9100, Duration timeout = const Duration(milliseconds: 200)}) async {
    final List<String> foundPrinters = [];

    for (int i = 1; i < 255; i++) {
      final String host = "$subnet.$i";
      try {
        final socket = await Socket.connect(host, port, timeout: timeout);
        foundPrinters.add(host);
        socket.destroy();
      } catch (_) {}
    }

    return foundPrinters;
  }
}
