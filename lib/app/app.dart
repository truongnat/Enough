import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import '../core/responsive/responsive.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/product_components.dart';
import '../services/alarm_runtime/alarm_runtime_controller.dart';
import '../services/notifications/notification_service.dart';
import '../services/notifications/notification_tap_controller.dart';
import '../features/settings/presentation/controllers/settings_controller.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  StreamSubscription<String?>? _notificationTapSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(alarmRuntimeControllerProvider.notifier).startMonitoring();
    _listenToNotificationTaps();
  }

  void _listenToNotificationTaps() {
    _notificationTapSub = NotificationService.notificationTapStream.listen((
      payload,
    ) async {
      if (payload == null || !mounted) return;

      final router = ref.read(routerProvider);
      final handled = await ref
          .read(alarmRuntimeControllerProvider.notifier)
          .handleNotificationPayload(payload, router);

      if (!handled && mounted) {
        ref
            .read(notificationTapControllerProvider.notifier)
            .handleNotificationTap(payload, router);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref
        .read(alarmRuntimeControllerProvider.notifier)
        .handleLifecycleChange(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationTapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settingsState = ref.watch(settingsControllerProvider);
    final themeMode = settingsState.settings?.themeMode ?? ThemeMode.dark;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final clampedMedia = Responsive.clampTextScale(context);
        return MediaQuery(
          data: clampedMedia,
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const _ForegroundAlarmModalHost(),
            ],
          ),
        );
      },
    );
  }
}

class _ForegroundAlarmModalHost extends ConsumerWidget {
  const _ForegroundAlarmModalHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtimeState = ref.watch(alarmRuntimeControllerProvider);
    if (!runtimeState.shouldShowAlarmModal ||
        runtimeState.activeAlarm == null) {
      return const SizedBox.shrink();
    }

    final alarm = runtimeState.activeAlarm!;
    final runtime = ref.read(alarmRuntimeControllerProvider.notifier);
    final router = ref.read(routerProvider);

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.74),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AppGlassCard(
                borderRadius: BorderRadius.circular(30),
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ĐẾN GIỜ DỪNG!',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      alarm.stopType.displayName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.stopTitle,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 190,
                      height: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.25),
                            AppColors.warning.withValues(alpha: 0.15),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.of(
                            context,
                            AppColors.border,
                            AppColors.lightBorder,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_active_rounded,
                              size: 72,
                              color: AppColors.primary.withValues(alpha: 0.9),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.access_alarms_rounded,
                              size: 36,
                              color: AppColors.warning.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mày không phải máy. Đừng tự biến mình thành server 24/7.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.of(
                          context,
                          AppColors.textSecondary,
                          AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    AppPrimaryButton(
                      label: 'Tôi đã dừng lại',
                      onTap: () async {
                        final alarmId = runtimeState.activeAlarmId;
                        await runtime.stopAlarm();
                        if (alarmId != null && context.mounted) {
                          router.push('/session?alarmId=$alarmId');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    AppSecondaryButton(
                      label: 'Cho tôi thêm 10 phút nữa...',
                      onTap: () async {
                        await runtime.snoozeAlarm();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
