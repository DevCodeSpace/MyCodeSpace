import 'package:get_it/get_it.dart';
import 'package:provider_boiler_plate/Services/api_services.dart';

import '../providers/auth_provider.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Register services
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Register providers
  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider());
}
