import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:restaurant_order/model/order_model.dart';

// Billing computer ka local WiFi IP — command: ipconfig getifaddr en0
const String _bridgeBase = 'http://192.168.1.88:8080';

Future<bool> sendPrintJob(String ip, CapabilityProfile profile, RestaurantOrderModel order, String tableId) async {
  final bytes = _buildReceiptBytes(profile, order, tableId);

  final response = await http.post(
    Uri.parse('$_bridgeBase/print'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'ip': ip, 'bytes': base64Encode(Uint8List.fromList(bytes))}),
  );

  return response.statusCode == 200;
}

List<int> _buildReceiptBytes(CapabilityProfile profile, RestaurantOrderModel order, String tableId) {
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  bytes += generator.text(
    "DineAssist AI",
    styles: const PosStyles(bold: true, height: PosTextSize.size2, width: PosTextSize.size2, align: PosAlign.center),
  );
  bytes += generator.text("Premium AI Restaurant", styles: const PosStyles(align: PosAlign.center));
  if (tableId.isNotEmpty) {
    bytes += generator.text("Table: $tableId", styles: const PosStyles(align: PosAlign.center, bold: true));
  }
  bytes += generator.text("--------------------------------", styles: const PosStyles(align: PosAlign.center));

  for (var item in order.items) {
    bytes += generator.row([
      PosColumn(text: "${item.quantity}x ${item.name}", width: 8),
      PosColumn(
        text: "Rs ${(item.price * item.quantity).toStringAsFixed(0)}",
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
  }

  bytes += generator.text("--------------------------------", styles: const PosStyles(align: PosAlign.center));
  bytes += generator.row([
    PosColumn(text: "TOTAL", width: 6, styles: const PosStyles(bold: true)),
    PosColumn(
      text: "Rs ${order.total.toStringAsFixed(0)}",
      width: 6,
      styles: const PosStyles(bold: true, align: PosAlign.right),
    ),
  ]);
  bytes += generator.text("--------------------------------", styles: const PosStyles(align: PosAlign.center));
  bytes += generator.text("Thank you for dining with us!", styles: const PosStyles(align: PosAlign.center));
  bytes += generator.feed(2);
  bytes += generator.cut();

  return bytes;
}

Future<List<String>> scanForPrinters(String subnet, {int port = 9100}) async {
  return [];
}
