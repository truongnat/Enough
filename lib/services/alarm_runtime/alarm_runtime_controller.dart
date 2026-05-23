import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/di/providers.dart';
import '../../features/alarms/domain/entities/stop_alarm.dart';
import '../../features/alarms/domain/repositories/alarm_repository.dart';
import '../../features/settings/domain/entities/app_settings.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../services/notifications/notification_payload.dart';
import '../../services/notifications/notification_service.dart';
import 'alarm_ringing_service.dart';

class AlarmRuntimeState {
  final String? activeAlarmId;
  final StopAlarm? activeAlarm;
  final String? activeOccurrenceKey;
  final bool isRinging;
  final bool shouldShowAlarmModal;
  final String? error;

  const AlarmRuntimeState({
    this.activeAlarmId,
    this.activeAlarm,
    this.activeOccurrenceKey,
    this.isRinging = false,
    this.shouldShowAlarmModal = false,
    this.error,
  });

  factory AlarmRuntimeState.initial() => const AlarmRuntimeState();

  AlarmRuntimeState copyWith({
    String? activeAlarmId,
    StopAlarm? activeAlarm,
    String? activeOccurrenceKey,
    bool? isRinging,
    bool? shouldShowAlarmModal,
    String? error,
    bool clearActive = false,
  }) {
    return AlarmRuntimeState(
      activeAlarmId: clearActive ? null : (activeAlarmId ?? this.activeAlarmId),
      activeAlarm: clearActive ? null : (activeAlarm ?? this.activeAlarm),
      activeOccurrenceKey: clearActive
          ? null
          : (activeOccurrenceKey ?? this.activeOccurrenceKey),
      isRinging: isRinging ?? this.isRinging,
      shouldShowAlarmModal: shouldShowAlarmModal ?? this.shouldShowAlarmModal,
      error: error,
    );
  }
}

class AlarmRuntimeController extends StateNotifier<AlarmRuntimeState> {
  static const Duration foregroundDueTolerance = Duration(minutes: 3);

  AlarmRuntimeController(
    this._alarmRepository,
    this._settingsRepository,
    this._notificationService,
    this._ringingService,
  ) : super(AlarmRuntimeState.initial());

  final AlarmRepository _alarmRepository;
  final SettingsRepository _settingsRepository;
  final NotificationService _notificationService;
  final AlarmRingingService _ringingService;

  Timer? _monitorTimer;
  final Set<String> _triggeredOccurrenceKeys = <String>{};
  DateTime? _lastCheckAt;
  bool _isForeground = true;
  bool _isChecking = false;

  void startMonitoring() {
    _lastCheckAt = DateTime.now().subtract(const Duration(seconds: 20));
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_isForeground) {
        checkDueAlarms();
      }
    });
    unawaited(checkDueAlarms());
  }

  void handleLifecycleChange(AppLifecycleState lifecycleState) {
    _isForeground = lifecycleState == AppLifecycleState.resumed;
    if (_isForeground) {
      unawaited(checkDueAlarms());
    }
  }

  Future<void> checkDueAlarms() async {
    if (_isChecking || !_isForeground) return;
    _isChecking = true;
    try {
      if (state.shouldShowAlarmModal || state.activeAlarmId != null) return;
      final alarms = await _alarmRepository.getAlarms();
      final now = DateTime.now();
      final lastCheck =
          _lastCheckAt ?? now.subtract(const Duration(seconds: 20));
      _lastCheckAt = now;

      for (final alarm in alarms) {
        if (!alarm.isEnabled) continue;
        final occurrence = _findDueOccurrence(alarm, now, lastCheck);
        if (occurrence == null) continue;

        final occurrenceKey = _occurrenceKey(alarm.id, occurrence);
        if (_triggeredOccurrenceKeys.contains(occurrenceKey)) continue;

        _triggeredOccurrenceKeys.add(occurrenceKey);
        await triggerForegroundAlarm(
          alarmId: alarm.id,
          occurrenceKey: occurrenceKey,
          alarm: alarm,
        );
        break;
      }
    } catch (error) {
      state = state.copyWith(error: error.toString());
    } finally {
      _isChecking = false;
    }
  }

  Future<void> triggerForegroundAlarm({
    required String alarmId,
    String? occurrenceKey,
    StopAlarm? alarm,
  }) async {
    final resolvedAlarm = alarm ?? await _findAlarm(alarmId);
    if (resolvedAlarm == null) {
      state = state.copyWith(error: 'Alarm $alarmId not found');
      return;
    }

    await _ringingService.startRinging(
      alarmId: alarmId,
      mode: resolvedAlarm.mode,
    );
    state = state.copyWith(
      activeAlarmId: alarmId,
      activeAlarm: resolvedAlarm,
      activeOccurrenceKey: occurrenceKey,
      isRinging: true,
      shouldShowAlarmModal: true,
      error: null,
    );
  }

  Future<void> stopAlarm() async {
    await _ringingService.stopRinging();
    state = state.copyWith(
      isRinging: false,
      shouldShowAlarmModal: false,
      clearActive: true,
      error: null,
    );
  }

  Future<void> snoozeAlarm() async {
    final alarm = state.activeAlarm;
    if (alarm == null) {
      await stopAlarm();
      return;
    }

    final settings =
        await _settingsRepository.getSettings() ??
        AppSettings.defaultSettings();
    await _notificationService.scheduleAlarmSnoozeFromAlarm(
      alarm,
      settings.defaultSnoozeMinutes,
    );
    await stopAlarm();
  }

  Future<void> dismissModal({bool stopRinging = false}) async {
    if (stopRinging) {
      await _ringingService.stopRinging();
    }
    state = state.copyWith(
      isRinging: stopRinging ? false : state.isRinging,
      shouldShowAlarmModal: false,
      error: null,
    );
  }

  Future<bool> handleNotificationPayload(
    String payload,
    GoRouter router,
  ) async {
    try {
      final notificationPayload = NotificationPayload.fromJson(payload);
      if (notificationPayload.alarmId.isEmpty) return false;

      switch (notificationPayload.action) {
        case NotificationPayload.actionStopAlarm:
          await stopAlarm();
          router.push('/session?alarmId=${notificationPayload.alarmId}');
          return true;
        case NotificationPayload.actionSnoozeAlarm:
          final alarm = await _findAlarm(notificationPayload.alarmId);
          if (alarm != null) {
            final settings =
                await _settingsRepository.getSettings() ??
                AppSettings.defaultSettings();
            await _notificationService.scheduleAlarmSnoozeFromAlarm(
              alarm,
              settings.defaultSnoozeMinutes,
            );
          }
          await stopAlarm();
          return true;
        case NotificationPayload.actionOpenStopSession:
        case NotificationPayload.actionOpenSnoozedSession:
          await stopAlarm();
          return false;
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> disposeRuntime() async {
    _monitorTimer?.cancel();
    await _ringingService.dispose();
  }

  Future<StopAlarm?> _findAlarm(String alarmId) async {
    final alarms = await _alarmRepository.getAlarms();
    for (final alarm in alarms) {
      if (alarm.id == alarmId) return alarm;
    }
    return null;
  }

  DateTime? _findDueOccurrence(
    StopAlarm alarm,
    DateTime now,
    DateTime lastCheck,
  ) {
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.timeOfDayHour,
      alarm.timeOfDayMinute,
    );

    final isTodayScheduled =
        alarm.repeatDays.isEmpty ||
        alarm.repeatDays.any((day) => day.isoValue == now.weekday);
    if (!isTodayScheduled) return null;
    if (scheduled.isAfter(now)) return null;
    if (scheduled.isBefore(lastCheck.subtract(const Duration(seconds: 2)))) {
      return null;
    }
    if (now.difference(scheduled) > foregroundDueTolerance) {
      return null;
    }
    return scheduled;
  }

  String _occurrenceKey(String alarmId, DateTime scheduledAt) {
    return '$alarmId|${scheduledAt.toIso8601String()}';
  }
}

final alarmRingingServiceProvider = Provider<AlarmRingingService>((ref) {
  final service = AlarmRingingService();
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
});

final alarmRuntimeControllerProvider =
    StateNotifierProvider<AlarmRuntimeController, AlarmRuntimeState>((ref) {
      final alarmRepository = ref.watch(alarmRepositoryProvider);
      final settingsRepository = ref.watch(settingsRepositoryProvider);
      final notificationService = ref.watch(notificationServiceProvider);
      final ringingService = ref.watch(alarmRingingServiceProvider);

      final controller = AlarmRuntimeController(
        alarmRepository,
        settingsRepository,
        notificationService,
        ringingService,
      );
      ref.onDispose(() {
        unawaited(controller.disposeRuntime());
      });
      return controller;
    });
