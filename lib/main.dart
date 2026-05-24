import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'services/storage/local_storage_service.dart';
import 'services/notifications/notification_service.dart';
import 'app/di/providers.dart';
import 'debug/store_screenshot_seed.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = LocalStorageService();
  await storageService.init();

  // Seed demo data in SCREENSHOT_MODE (safe because flag is only set via --dart-define)
  const screenshotMode = String.fromEnvironment('SCREENSHOT_MODE', defaultValue: 'false') == 'true';
  if (screenshotMode) {
    await StoreScreenshotSeed.seedDemoData(storageService);
  }

  final notificationService = NotificationService();
  await notificationService.initialize();
  // Permission request moved to save alarm/settings

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const App(),
    ),
  );
}
