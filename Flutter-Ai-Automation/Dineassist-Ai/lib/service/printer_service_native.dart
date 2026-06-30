import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:restaurant_order/model/order_model.dart';

Future<bool> sendPrintJob(
  String ip,
  CapabilityProfile profile,
  RestaurantOrderModel order,
  String tableId,
) async {
  final printer = NetworkPrinter(PaperSize.mm80, profile);
  final result = await printer.connect(ip, port: 9100, timeout: const Duration(seconds: 10));

  if (result != PosPrintResult.success) return false;

  _buildReceipt(printer, order, tableId);
  printer.disconnect();
  return true;
}

void _buildReceipt(NetworkPrinter printer, RestaurantOrderModel order, String tableId) {
  printer.text(
    "DineAssist AI",
    styles: const PosStyles(bold: true, height: PosTextSize.size2, width: PosTextSize.size2, align: PosAlign.center),
  );
  printer.text("Premium AI Restaurant", styles: const PosStyles(align: PosAlign.center));
  if (tableId.isNotEmpty) {
    printer.text("Table: $tableId", styles: const PosStyles(align: PosAlign.center, bold: true));
  }
  printer.text("--------------------------------", styles: const PosStyles(align: PosAlign.center));

  for (var item in order.items) {
    printer.row([
      PosColumn(text: "${item.quantity}x ${item.name}", width: 8),
      PosColumn(
        text: "Rs ${(item.price * item.quantity).toStringAsFixed(0)}",
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
  }

  printer.text("--------------------------------", styles: const PosStyles(align: PosAlign.center));
  printer.row([
    PosColumn(text: "TOTAL", width: 6, styles: const PosStyles(bold: true)),
    PosColumn(
      text: "Rs ${order.total.toStringAsFixed(0)}",
      width: 6,
      styles: const PosStyles(bold: true, align: PosAlign.right),
    ),
  ]);
  printer.text("--------------------------------", styles: const PosStyles(align: PosAlign.center));
  printer.text("Thank you for dining with us!", styles: const PosStyles(align: PosAlign.center));
  printer.feed(2);
  printer.cut();
}

Future<List<String>> scanForPrinters(String subnet, {int port = 9100}) async {
  // Native scanning is handled by WifiPrinterScanner in wifiscan_service_native.dart
  return [];
}
