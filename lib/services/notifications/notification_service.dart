import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/alarms/domain/entities/stop_alarm.dart';
import '../../features/stop_session/domain/entities/stop_session.dart';
import 'notification_payload.dart';

class NotificationService {
  static const String alarmChannelId = 'reverse_alarm_alarm_channel';
  static const String snoozeChannelId = 'reverse_alarm_snooze_channel';
  static const String stopActionId = NotificationPayload.actionStopAlarm;
  static const String snoozeActionId = NotificationPayload.actionSnoozeAlarm;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final ValueNotifier<String?> pendingNotificationPayload =
      ValueNotifier<String?>(null);

  static final StreamController<String?> _notificationTapController =
      StreamController<String?>.broadcast();

  static Stream<String?> get notificationTapStream =>
      _notificationTapController.stream;

  NotificationService();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.toString()));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _handleBackgroundResponse,
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation == null) return;

    final alarmChannel = AndroidNotificationChannel(
      alarmChannelId,
      'Enough',
      description: 'High priority stop alarms with alarm-like behavior.',
      importance: Importance.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('reverse_alarm_ring'),
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      vibrationPattern: Int64List.fromList([0, 700, 250, 700, 250, 1200]),
    );

    final snoozeChannel = AndroidNotificationChannel(
      snoozeChannelId,
      'Enough Snooze',
      description: 'Snoozed Enough reminders.',
      importance: Importance.max,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('reverse_alarm_ring'),
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      vibrationPattern: Int64List.fromList([0, 500, 250, 800]),
    );

    await androidImplementation.createNotificationChannel(alarmChannel);
    await androidImplementation.createNotificationChannel(snoozeChannel);
  }

  Future<bool> requestPermissionsIfNeeded() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission();
        final exactAlarmGranted =
            await androidImplementation.requestExactAlarmsPermission();
        return (granted ?? false) && (exactAlarmGranted ?? false);
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return true;
  }

  int _getNotificationId(String alarmId, int? dayValue) {
    final baseHash = alarmId.hashCode.abs() % 100000;
    return baseHash * 10 + (dayValue ?? 0);
  }

  Future<void> scheduleStopAlarm(StopAlarm alarm) async {
    await cancelStopAlarm(alarm.id);
    if (!alarm.isEnabled) return;

    final now = DateTime.now();
    final nextTrigger = alarm.getNextTrigger(now);

    if (alarm.repeatDays.isEmpty) {
      final id = _getNotificationId(alarm.id, 0);
      final payload = _buildPayload(
        action: NotificationPayload.actionOpenStopSession,
        alarm: alarm,
        scheduledAt: nextTrigger,
      );
      await _localNotifications.zonedSchedule(
        id,
        'ĐẾN GIỜ DỪNG! ${alarm.stopType.displayName.toUpperCase()}',
        'Mở app và xác nhận bạn đã dừng lại hoặc snooze thêm 10 phút.',
        tz.TZDateTime.from(nextTrigger, tz.local),
        _alarmNotificationDetails(payload: payload),
        payload: payload.toJson(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return;
    }

    for (final day in alarm.repeatDays) {
      final nextDateForDay = _nextOccurrenceForWeekday(
        now: now,
        alarm: alarm,
        weekday: day.isoValue,
      );
      final payload = _buildPayload(
        action: NotificationPayload.actionOpenStopSession,
        alarm: alarm,
        scheduledAt: nextDateForDay,
      );

      await _localNotifications.zonedSchedule(
        _getNotificationId(alarm.id, day.isoValue),
        'ĐẾN GIỜ DỪNG! ${alarm.stopType.displayName.toUpperCase()}',
        'Mở app và hoàn thành quy trình dừng ngay bây giờ.',
        tz.TZDateTime.from(nextDateForDay, tz.local),
        _alarmNotificationDetails(payload: payload),
        payload: payload.toJson(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelStopAlarm(String alarmId) async {
    for (int dayVal = 0; dayVal <= 9; dayVal++) {
      await _localNotifications.cancel(_getNotificationId(alarmId, dayVal));
    }
  }

  Future<void> rescheduleAll(List<StopAlarm> alarms) async {
    for (final alarm in alarms) {
      if (alarm.isEnabled) {
        await scheduleStopAlarm(alarm);
      } else {
        await cancelStopAlarm(alarm.id);
      }
    }
  }

  Future<void> scheduleSnooze(StopSession session, int minutes) async {
    final snoozeTrigger = DateTime.now().add(Duration(minutes: minutes));
    final payload = NotificationPayload(
      action: NotificationPayload.actionOpenSnoozedSession,
      alarmId: session.alarmId,
      sessionId: session.id,
      category: session.stopType.name,
      title: 'Snoozed: ${session.stopType.displayName}',
      scheduledAt: snoozeTrigger.toIso8601String(),
      stopType: session.stopType.name,
    );

    final id = _getNotificationId(session.alarmId, 9);
    await _localNotifications.cancel(id);

    await _localNotifications.zonedSchedule(
      id,
      'HOÃN XONG RỒI. ${session.stopType.displayName.toUpperCase()}',
      'Đã tới lúc quay lại và thật sự dừng lại.',
      tz.TZDateTime.from(snoozeTrigger, tz.local),
      _snoozeNotificationDetails(payload: payload),
      payload: payload.toJson(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleAlarmSnoozeFromAlarm(StopAlarm alarm, int minutes) async {
    final snoozeTrigger = DateTime.now().add(Duration(minutes: minutes));
    final payload = _buildPayload(
      action: NotificationPayload.actionOpenStopSession,
      alarm: alarm,
      scheduledAt: snoozeTrigger,
    );

    final id = _getNotificationId(alarm.id, 9);
    await _localNotifications.cancel(id);

    await _localNotifications.zonedSchedule(
      id,
      'HOÃN 10 PHÚT: ${alarm.stopType.displayName.toUpperCase()}',
      'Không trốn được mãi đâu. Tới giờ là phải dừng.',
      tz.TZDateTime.from(snoozeTrigger, tz.local),
      _snoozeNotificationDetails(payload: payload),
      payload: payload.toJson(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  Future<void> cancelSnooze(String alarmId) async {
    await _localNotifications.cancel(_getNotificationId(alarmId, 9));
  }

  NotificationDetails _alarmNotificationDetails({
    required NotificationPayload payload,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        alarmChannelId,
        'Enough',
        channelDescription:
            'High priority alarms forcing you to stop right now.',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('reverse_alarm_ring'),
        enableVibration: true,
        vibrationPattern:
            Int64List.fromList([0, 700, 250, 700, 250, 1200]),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            stopActionId,
            'DỪNG',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            snoozeActionId,
            'HOÃN 10 PHÚT',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      ),
    );
  }

  NotificationDetails _snoozeNotificationDetails({
    required NotificationPayload payload,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        snoozeChannelId,
        'Enough Snooze',
        channelDescription: 'Snoozed stop alarm reminders.',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('reverse_alarm_ring'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 800]),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            stopActionId,
            'DỪNG',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            snoozeActionId,
            'HOÃN 10 PHÚT',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  NotificationPayload _buildPayload({
    required String action,
    required StopAlarm alarm,
    required DateTime scheduledAt,
  }) {
    return NotificationPayload(
      action: action,
      alarmId: alarm.id,
      sessionId: null,
      category: 'alarm',
      title: alarm.stopType.displayName,
      scheduledAt: scheduledAt.toIso8601String(),
      stopType: alarm.stopType.name,
    );
  }

  DateTime _nextOccurrenceForWeekday({
    required DateTime now,
    required StopAlarm alarm,
    required int weekday,
  }) {
    var targetDate = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.timeOfDayHour,
      alarm.timeOfDayMinute,
    );

    int diff = weekday - now.weekday;
    if (diff < 0) {
      diff += 7;
    } else if (diff == 0 && !targetDate.isAfter(now)) {
      diff = 7;
    }
    return targetDate.add(Duration(days: diff));
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = _mergeActionIntoPayload(
      response.payload,
      response.actionId,
    );
    if (payload != null && payload.isNotEmpty) {
      pendingNotificationPayload.value = payload;
      _notificationTapController.add(payload);
    }
  }

  @pragma('vm:entry-point')
  static void _handleBackgroundResponse(NotificationResponse response) {
    final payload = _mergeActionIntoPayload(
      response.payload,
      response.actionId,
    );
    if (payload != null && payload.isNotEmpty) {
      pendingNotificationPayload.value = payload;
      _notificationTapController.add(payload);
    }
  }

  static String? _mergeActionIntoPayload(String? rawPayload, String? actionId) {
    if (rawPayload == null || rawPayload.isEmpty) return rawPayload;
    try {
      final payload = NotificationPayload.fromJson(rawPayload);
      if (actionId != null && actionId.isNotEmpty) {
        return payload.copyWith(action: actionId).toJson();
      }
      return rawPayload;
    } catch (_) {
      return rawPayload;
    }
  }
}
