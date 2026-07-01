import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/services/classic_bluetooth_chat_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/bluetooth_service.dart';
import 'core/services/file_transfer_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => BtService().init());
  await Get.putAsync(() => ClassicBluetoothChatService().init());
  Get.put(FileTransferService());

  runApp(const BluetoothChatApp());
}

class BluetoothChatApp extends StatelessWidget {
  const BluetoothChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bluetooth Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      getPages: AppPages.pages,
      initialRoute: AppRoutes.SPLASH,
      defaultTransition: Transition.fade,
    );
  }
}
