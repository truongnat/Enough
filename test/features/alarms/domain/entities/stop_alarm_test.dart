import 'package:flutter_test/flutter_test.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_alarm.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_type.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_mode.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/repeat_day.dart';

void main() {
  group('StopAlarm - Next Alarm Calculation', () {
    test(
      'should return today if alarm time is in the future and no repeat days',
      () {
        final now = DateTime(2024, 1, 15, 10, 0); // 10:00 AM
        final alarm = StopAlarm(
          id: '1',
          title: 'Test Alarm',
          stopType: StopType.coding,
          timeOfDayHour: 14,
          timeOfDayMinute: 30,
          repeatDays: [],
          mode: StopMode.general,
          protocolId: 'proto1',
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        );

        final nextTrigger = alarm.getNextTrigger(now);

        expect(nextTrigger.year, equals(2024));
        expect(nextTrigger.month, equals(1));
        expect(nextTrigger.day, equals(15));
        expect(nextTrigger.hour, equals(14));
        expect(nextTrigger.minute, equals(30));
      },
    );

    test(
      'should return tomorrow if alarm time has passed today and no repeat days',
      () {
        final now = DateTime(2024, 1, 15, 16, 0); // 4:00 PM
        final alarm = StopAlarm(
          id: '1',
          title: 'Test Alarm',
          stopType: StopType.coding,
          timeOfDayHour: 14,
          timeOfDayMinute: 30,
          repeatDays: [],
          mode: StopMode.general,
          protocolId: 'proto1',
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        );

        final nextTrigger = alarm.getNextTrigger(now);

        expect(nextTrigger.day, equals(16)); // Next day
        expect(nextTrigger.hour, equals(14));
        expect(nextTrigger.minute, equals(30));
      },
    );

    test('should return correct day for weekly repeat alarm', () {
      // Monday (weekday 1)
      final now = DateTime(2024, 1, 15, 10, 0);
      final alarm = StopAlarm(
        id: '1',
        title: 'Test Alarm',
        stopType: StopType.coding,
        timeOfDayHour: 14,
        timeOfDayMinute: 30,
        repeatDays: [RepeatDay.wednesday], // Wednesday (weekday 3)
        mode: StopMode.general,
        protocolId: 'proto1',
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      );

      final nextTrigger = alarm.getNextTrigger(now);

      expect(nextTrigger.weekday, equals(3)); // Wednesday
      expect(nextTrigger.hour, equals(14));
      expect(nextTrigger.minute, equals(30));
    });

    test(
      'should return next week if today is the repeat day but time has passed',
      () {
        // Monday (weekday 1)
        final now = DateTime(2024, 1, 15, 16, 0);
        final alarm = StopAlarm(
          id: '1',
          title: 'Test Alarm',
          stopType: StopType.coding,
          timeOfDayHour: 14,
          timeOfDayMinute: 30,
          repeatDays: [RepeatDay.monday],
          mode: StopMode.general,
          protocolId: 'proto1',
          isEnabled: true,
          createdAt: now,
          updatedAt: now,
        );

        final nextTrigger = alarm.getNextTrigger(now);

        // Should be next Monday
        expect(nextTrigger.weekday, equals(1));
        expect(nextTrigger.day, equals(22)); // 7 days later
      },
    );

    test('should format time correctly', () {
      final alarm = StopAlarm(
        id: '1',
        title: 'Test Alarm',
        stopType: StopType.coding,
        timeOfDayHour: 9,
        timeOfDayMinute: 5,
        repeatDays: [],
        mode: StopMode.general,
        protocolId: 'proto1',
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(alarm.formattedTime, equals('09:05'));
    });
  });
}
