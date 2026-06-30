class WifiPrinterScanner {
  static Future<List<String>> scanNetwork({
    String subnet = "192.168.1",
    int port = 9100,
    Duration timeout = const Duration(milliseconds: 200),
  }) async {
    return []; // Web pe TCP scan possible nahi
  }
}
