// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:reverse_alarm/app/app.dart';
import 'package:reverse_alarm/app/di/providers.dart';
import 'package:reverse_alarm/services/storage/local_storage_service.dart';
import 'package:reverse_alarm/services/notifications/notification_service.dart';

/// Fake PathProvider that returns a real temp directory so Hive can
/// initialise without Flutter engine bindings.
class _FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String _dir;
  _FakePathProviderPlatform(this._dir);

  @override
  Future<String?> getApplicationDocumentsPath() async => _dir;

  @override
  Future<String?> getTemporaryPath() async => _dir;

  @override
  Future<String?> getApplicationSupportPath() async => _dir;
}

void main() {
  late Directory tempDir;
  late LocalStorageService storageService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Point path_provider at a real temp directory so Hive can init.
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);

    // Initialise Hive and open boxes (mirrors what main() does).
    await Hive.initFlutter(tempDir.path);
    storageService = LocalStorageService();
    await storageService.init();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // NotificationService is created but NOT initialized — platform channels
    // are unavailable in the test environment. The service gracefully handles
    // missing channels (no-ops in test mode).
    final notificationService = NotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const App(),
      ),
    );

    // Pump one frame so the widget tree settles without waiting on timers.
    // The Timer.periodic in AlarmRuntimeController is not advanced here.
    await tester.pump(Duration.zero);
  });
}
