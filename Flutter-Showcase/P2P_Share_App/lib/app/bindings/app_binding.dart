import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/history_local_data_source.dart';
import '../../data/repositories/connection_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/transfer_repository_impl.dart';
import '../../data/services/connection_service.dart';
import '../../data/services/device_catalog_service.dart';
import '../../data/services/permission_service.dart';
import '../../data/services/transfer_service.dart';
import '../../domain/repositories/connection_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../presentation/controllers/connection_controller.dart';
import '../../presentation/controllers/history_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/receive_controller.dart';
import '../../presentation/controllers/send_controller.dart';
import '../../presentation/controllers/transfer_controller.dart';

class AppBinding extends Bindings {
  static Future<void> ensureInitialized() async {
    final preferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(preferences, permanent: true);
  }

  @override
  void dependencies() {
    final preferences = Get.find<SharedPreferences>();

    Get.put(HistoryLocalDataSource(preferences), permanent: true);
    Get.put(PermissionService(), permanent: true);
    Get.put(ConnectionService(), permanent: true);
    Get.put(DeviceCatalogService(), permanent: true);
    Get.put(
      TransferService(
        connectionService: Get.find<ConnectionService>(),
        deviceCatalogService: Get.find<DeviceCatalogService>(),
      ),
      permanent: true,
    );

    Get.put<HistoryRepository>(
      HistoryRepositoryImpl(
        localDataSource: Get.find<HistoryLocalDataSource>(),
      ),
      permanent: true,
    );
    Get.put<ConnectionRepository>(
      ConnectionRepositoryImpl(
        connectionService: Get.find<ConnectionService>(),
        transferService: Get.find<TransferService>(),
      ),
      permanent: true,
    );
    Get.put<TransferRepository>(
      TransferRepositoryImpl(
        transferService: Get.find<TransferService>(),
        historyRepository: Get.find<HistoryRepository>(),
        permissionService: Get.find<PermissionService>(),
      ),
      permanent: true,
    );

    Get.put(
      TransferController(transferRepository: Get.find<TransferRepository>()),
      permanent: true,
    );
    Get.put(
      ConnectionController(
        connectionRepository: Get.find<ConnectionRepository>(),
        transferController: Get.find<TransferController>(),
      ),
      permanent: true,
    );
    Get.lazyPut(
      () => HomeController(historyRepository: Get.find<HistoryRepository>()),
      fenix: true,
    );
    Get.put(
      SendController(
        transferController: Get.find<TransferController>(),
        connectionController: Get.find<ConnectionController>(),
        historyRepository: Get.find<HistoryRepository>(),
        permissionService: Get.find<PermissionService>(),
        deviceCatalogService: Get.find<DeviceCatalogService>(),
      ),
    );
    Get.lazyPut(
      () => ReceiveController(
        connectionRepository: Get.find<ConnectionRepository>(),
        transferController: Get.find<TransferController>(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => HistoryController(historyRepository: Get.find<HistoryRepository>()),
      fenix: true,
    );
  }
}
