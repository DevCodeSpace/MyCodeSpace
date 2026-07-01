import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/bindings/app_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBinding.ensureInitialized();
  runApp(const ShareSphereApp());
}
