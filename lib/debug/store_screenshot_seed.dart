import '../features/alarms/domain/entities/stop_alarm.dart';
import '../features/alarms/domain/entities/stop_type.dart';
import '../features/alarms/domain/entities/stop_mode.dart';
import '../features/alarms/domain/entities/repeat_day.dart';
import '../features/receipts/domain/entities/stop_receipt.dart';
import '../features/stop_session/domain/entities/stop_session.dart';
import '../features/stop_session/domain/entities/stop_session_status.dart';
import '../services/storage/local_storage_service.dart';
import '../features/alarms/data/models/stop_alarm_model.dart';
import '../features/receipts/data/models/stop_receipt_model.dart';
import '../features/stop_session/data/models/stop_session_model.dart';

class StoreScreenshotSeed {
  static Future<void> seedDemoData(LocalStorageService storage) async {
    // Clear all existing data
    await storage.clearAllData();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Create 3 demo Stop Alarms
    final alarm1 = StopAlarm(
      id: 'demo_alarm_1',
      title: 'Dừng code trước khi ngủ',
      stopType: StopType.coding,
      timeOfDayHour: 23,
      timeOfDayMinute: 30,
      repeatDays: [
        RepeatDay.monday,
        RepeatDay.tuesday,
        RepeatDay.wednesday,
        RepeatDay.thursday,
        RepeatDay.friday,
      ],
      mode: StopMode.strict,
      protocolId: 'default',
      isEnabled: true,
      createdAt: today.subtract(const Duration(days: 30)),
      updatedAt: today.subtract(const Duration(days: 1)),
    );

    final alarm2 = StopAlarm(
      id: 'demo_alarm_2',
      title: 'Dừng lướt điện thoại',
      stopType: StopType.scrolling,
      timeOfDayHour: 22,
      timeOfDayMinute: 15,
      repeatDays: [
        RepeatDay.monday,
        RepeatDay.tuesday,
        RepeatDay.wednesday,
        RepeatDay.thursday,
        RepeatDay.friday,
        RepeatDay.saturday,
        RepeatDay.sunday,
      ],
      mode: StopMode.general,
      protocolId: 'default',
      isEnabled: true,
      createdAt: today.subtract(const Duration(days: 25)),
      updatedAt: today.subtract(const Duration(days: 2)),
    );

    final alarm3 = StopAlarm(
      id: 'demo_alarm_3',
      title: 'Đi ngủ đúng giờ',
      stopType: StopType.sleep,
      timeOfDayHour: 0,
      timeOfDayMinute: 0,
      repeatDays: [
        RepeatDay.monday,
        RepeatDay.tuesday,
        RepeatDay.wednesday,
        RepeatDay.thursday,
        RepeatDay.friday,
      ],
      mode: StopMode.general,
      protocolId: 'default',
      isEnabled: false,
      createdAt: today.subtract(const Duration(days: 20)),
      updatedAt: today.subtract(const Duration(days: 5)),
    );

    // Save alarms
    await storage.saveAlarm(
      alarm1.id,
      StopAlarmModel.toJson(alarm1),
    );
    await storage.saveAlarm(
      alarm2.id,
      StopAlarmModel.toJson(alarm2),
    );
    await storage.saveAlarm(
      alarm3.id,
      StopAlarmModel.toJson(alarm3),
    );

    // Create 2 demo Stop Sessions for today
    final session1 = StopSession(
      id: 'demo_session_1',
      alarmId: alarm1.id,
      stopType: StopType.coding,
      startedAt: today.add(const Duration(hours: 23, minutes: 30)),
      completedAt: today.add(const Duration(hours: 23, minutes: 45)),
      status: StopSessionStatus.completed,
      snoozeCount: 0,
      checkedStepIndexes: [0, 1],
    );

    final session2 = StopSession(
      id: 'demo_session_2',
      alarmId: alarm2.id,
      stopType: StopType.scrolling,
      startedAt: today.add(const Duration(hours: 22, minutes: 15)),
      completedAt: today.add(const Duration(hours: 22, minutes: 20)),
      status: StopSessionStatus.snoozed,
      snoozeCount: 1,
      checkedStepIndexes: [0],
    );

    await storage.saveSession(
      session1.id,
      StopSessionModel.toJson(session1),
    );
    await storage.saveSession(
      session2.id,
      StopSessionModel.toJson(session2),
    );

    // Create 1 demo Stop Receipt
    final receipt = StopReceipt(
      id: 'demo_receipt_1',
      alarmId: alarm1.id,
      sessionId: session1.id,
      stopType: StopType.coding,
      title: 'Dừng code',
      startedAt: today.add(const Duration(hours: 23, minutes: 30)),
      completedAt: today.add(const Duration(hours: 23, minutes: 45)),
      savedFromMessages: [],
      resultMessage: 'success',
      createdAt: today.add(const Duration(hours: 23, minutes: 45)),
    );

    await storage.saveReceipt(
      receipt.id,
      StopReceiptModel.toJson(receipt),
    );

    // Create weekly stats seed (store in settings for stats screen)
    final statsData = {
      'week_total_sessions': 12,
      'week_completed': 9,
      'week_snoozed': 2,
      'week_missed': 1,
      'total_time_minutes': 120,
      'today_completed': 2,
      'today_snoozed': 1,
    };
    await storage.saveSettings('weekly_stats', statsData);
  }

  static Future<void> seedAsync(LocalStorageService storage) async {
    await seedDemoData(storage);
  }
}
