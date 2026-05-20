import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../services/notifications/notification_service.dart';
import '../services/notifications/notification_tap_controller.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _listenToNotificationTaps();
  }

  void _listenToNotificationTaps() {
    NotificationService.notificationTapStream.listen((payload) {
      if (payload != null && mounted) {
        final router = ref.read(routerProvider);
        ref.read(notificationTapControllerProvider.notifier)
            .handleNotificationTap(payload, router);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Reverse Alarm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
