import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../../features/alarms/domain/entities/stop_alarm.dart';
import '../../features/stop_session/domain/entities/stop_session.dart';
import 'notification_payload.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final ValueNotifier<String?> pendingNotificationPayload =
      ValueNotifier<String?>(null);

  NotificationService();

  Future<void> initialize() async {
    // 1. Initialize Timezones
    tz.initializeTimeZones();
    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.toString()));
    } catch (_) {
      // Fallback if failed
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    // 2. Configure Android & iOS Initialization Settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 3. Initialize plugin
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          pendingNotificationPayload.value = response.payload;
        }
      },
    );
  }

  Future<bool> requestPermissionsIfNeeded() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        final alarmGranted = await androidImplementation.requestExactAlarmsPermission();
        return (granted ?? false) && (alarmGranted ?? false);
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

  // Generate unique notification ID per day to support weekly repeating
  int _getNotificationId(String alarmId, int? dayValue) {
    final baseHash = alarmId.hashCode.abs() % 100000;
    return baseHash * 10 + (dayValue ?? 0);
  }

  Future<void> scheduleStopAlarm(StopAlarm alarm) async {
    // Cancel existing first to prevent duplication
    await cancelStopAlarm(alarm.id);

    if (!alarm.isEnabled) return;

    final now = DateTime.now();
    final nextTrigger = alarm.getNextTrigger(now);
    final tzTrigger = tz.TZDateTime.from(nextTrigger, tz.local);

    final payload = NotificationPayload(
      alarmId: alarm.id,
      category: alarm.stopType.name,
      title: alarm.title.isNotEmpty ? alarm.title : alarm.stopType.displayName,
    ).toJson();

    const androidDetails = AndroidNotificationDetails(
      'reverse_alarms_channel',
      'Stop Protocols',
      channelDescription: 'High importance alarms forcing you to stop bad habits.',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (alarm.repeatDays.isEmpty) {
      // One-time alarm
      final id = _getNotificationId(alarm.id, 0);
      try {
        await _localNotifications.zonedSchedule(
          id,
          'ĐỦ RỒI! ${alarm.stopType.displayName.toUpperCase()}',
          'Mở máy lên và hoàn thành quy trình dừng ngay lập tức.',
          tzTrigger,
          details,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        // Fallback not needed for v21 API
      }
    } else {
      // Repeating alarms: Schedule a weekly zoned schedule for each checked day
      for (final day in alarm.repeatDays) {
        final id = _getNotificationId(alarm.id, day.isoValue);
        
        // Find next trigger for this specific day of week
        var targetDate = DateTime(
          now.year,
          now.month,
          now.day,
          alarm.timeOfDayHour,
          alarm.timeOfDayMinute,
        );
        int diff = day.isoValue - now.weekday;
        if (diff < 0) {
          diff += 7;
        } else if (diff == 0) {
          if (!targetDate.isAfter(now)) {
            diff = 7;
          }
        }
        targetDate = targetDate.add(Duration(days: diff));
        final tzDayTrigger = tz.TZDateTime.from(targetDate, tz.local);

        await _localNotifications.zonedSchedule(
          id,
          'ĐỦ RỒI! ${alarm.stopType.displayName.toUpperCase()}',
          'Mở máy lên và hoàn thành quy trình dừng ngay lập tức.',
          tzDayTrigger,
          details,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelStopAlarm(String alarmId) async {
    // Cancel the 0 (one-time) and 1 to 7 repeating notification IDs
    for (int dayVal = 0; dayVal <= 7; dayVal++) {
      final id = _getNotificationId(alarmId, dayVal);
      await _localNotifications.cancel(id);
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
    // Schedule a snooze alarm in the next X minutes
    final now = DateTime.now();
    final snoozeTrigger = now.add(Duration(minutes: minutes));
    final tzTrigger = tz.TZDateTime.from(snoozeTrigger, tz.local);

    final payload = NotificationPayload(
      alarmId: session.alarmId,
      category: session.stopType.name,
      title: 'Snoozed: ${session.stopType.displayName}',
    ).toJson();

    const androidDetails = AndroidNotificationDetails(
      'reverse_snooze_channel',
      'Stop Protocol Snooze',
      channelDescription: 'Snoozed notifications reminding you to stop.',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    // Cancel any active snooze for this alarm first
    final id = _getNotificationId(session.alarmId, 9); // Use 9 for snooze ID
    await _localNotifications.cancel(id);

    await _localNotifications.zonedSchedule(
      id,
      'BẠN ĐANG TRÌ HOÃN! ${session.stopType.displayName.toUpperCase()}',
      'Đã trễ $minutes phút. Đừng tự dối lòng nữa!',
      tzTrigger,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelSnooze(String alarmId) async {
    final id = _getNotificationId(alarmId, 9);
    await _localNotifications.cancel(id);
  }
}
