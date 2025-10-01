import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/local_storage_service.dart';

Future<void> bootstrap(Future<void> Function() runAppCallback) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await LocalStorageService.instance.init();

  // Temporarily disable Firebase for development
  if (kDebugMode) {
    debugPrint('Firebase initialization skipped for development');
  }

  await runAppCallback();
}