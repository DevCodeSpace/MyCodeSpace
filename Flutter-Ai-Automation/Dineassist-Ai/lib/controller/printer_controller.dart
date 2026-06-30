import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:restaurant_order/configuration/wifiscan_service.dart';
import 'package:restaurant_order/model/order_model.dart';
import 'package:restaurant_order/service/printer_service.dart';
import 'package:flutter/material.dart';

class PrinterController extends GetxController {
  var printerIp = '192.168.1.223'.obs;
  var isConnected = false.obs;
  var isPrinting = false.obs;

  CapabilityProfile? _capabilityProfile;

  Future<CapabilityProfile> _getProfile() async {
    _capabilityProfile ??= await CapabilityProfile.load();
    return _capabilityProfile!;
  }

  Future<void> printOrder(RestaurantOrderModel order, String tableId) async {
    isPrinting.value = true;
    try {
      final profile = await _getProfile();

      if (kIsWeb) {
        // Web: Node.js bridge server (localhost:8080) → TCP → Printer
        final success = await sendPrintJob(printerIp.value, profile, order, tableId);
        if (success) {
          _showSnackbar("Success", "Receipt printed via web bridge", Colors.green);
        } else {
          _showSnackbar("Print Error", "Bridge server se connect nahi hua. Node.js server chalu hai?", Colors.red);
        }
      } else {
        // App (Android/iOS/Desktop): Direct TCP → Printer
        final success = await sendPrintJob(printerIp.value, profile, order, tableId);
        if (success) {
          _showSnackbar("Success", "Receipt printed successfully", Colors.green);
        } else {
          _showSnackbar("Print Error", "Could not connect to printer at ${printerIp.value}", Colors.red);
        }
      }
    } catch (e) {
      _showSnackbar("Error", "Printing failed: $e", Colors.red);
    } finally {
      isPrinting.value = false;
    }
  }

  var isScanning = false.obs;
  var availablePrinters = <String>[].obs;

  Future<void> autoDetectPrinter() async {
    if (kIsWeb) {
      _showSnackbar("Not Supported", "Web pe printer scan nahi ho sakta. IP manually set karo.", Colors.orange);
      return;
    }

    isScanning.value = true;
    availablePrinters.clear();
    try {
      final subnet = printerIp.value.split('.').take(3).join('.');
      final printers = await WifiPrinterScanner.scanNetwork(subnet: subnet);
      availablePrinters.value = printers;
      if (printers.isNotEmpty) {
        printerIp.value = printers.first;
        _showSnackbar("Printer Found", "IP: ${printers.first}", Colors.green);
      } else {
        _showSnackbar("Not Found", "No printer found on network", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Error", "Scan failed: $e", Colors.red);
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> scanForPrinters(String subnet) async {
    if (kIsWeb) return;

    isScanning.value = true;
    availablePrinters.clear();
    try {
      final printers = await WifiPrinterScanner.scanNetwork(subnet: subnet);
      availablePrinters.value = printers;
    } catch (_) {
    } finally {
      isScanning.value = false;
    }
  }

  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withValues(alpha: 0.1),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
