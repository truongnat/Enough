import 'stop_type.dart';
import 'stop_mode.dart';
import 'repeat_day.dart';

class StopAlarm {
  final String id;
  final String title;
  final StopType stopType;
  final String? customTypeLabel;
  final int timeOfDayHour;
  final int timeOfDayMinute;
  final List<RepeatDay> repeatDays;
  final StopMode mode;
  final String protocolId;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  StopAlarm({
    required this.id,
    required this.title,
    required this.stopType,
    this.customTypeLabel,
    required this.timeOfDayHour,
    required this.timeOfDayMinute,
    required this.repeatDays,
    required this.mode,
    required this.protocolId,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  // Next alarm rule implementation:
  // - Only sets trigger if isEnabled = true.
  // - If repeatDays is empty, treated as a one-time alarm.
  // - If repeatDays is not empty, calculates next weekday occurrence.
  // - If hour/minute today has passed, schedules for next occurrence.
  DateTime getNextTrigger(DateTime now) {
    final alarmTimeToday = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDayHour,
      timeOfDayMinute,
    );

    if (repeatDays.isEmpty) {
      if (alarmTimeToday.isAfter(now)) {
        return alarmTimeToday;
      } else {
        return alarmTimeToday.add(const Duration(days: 1));
      }
    } else {
      DateTime? nearest;
      for (final day in repeatDays) {
        final targetWeekday = day.isoValue;
        int diff = targetWeekday - now.weekday;

        if (diff < 0) {
          diff += 7;
        } else if (diff == 0) {
          if (!alarmTimeToday.isAfter(now)) {
            diff = 7; // Schedule for next week
          }
        }

        final nextTriggerDate = alarmTimeToday.add(Duration(days: diff));
        if (nearest == null || nextTriggerDate.isBefore(nearest)) {
          nearest = nextTriggerDate;
        }
      }
      return nearest!;
    }
  }

  // Helper to format time as HH:mm
  String get formattedTime {
    final hr = timeOfDayHour.toString().padLeft(2, '0');
    final min = timeOfDayMinute.toString().padLeft(2, '0');
    return '$hr:$min';
  }

  StopAlarm copyWith({
    String? id,
    String? title,
    StopType? stopType,
    String? customTypeLabel,
    int? timeOfDayHour,
    int? timeOfDayMinute,
    List<RepeatDay>? repeatDays,
    StopMode? mode,
    String? protocolId,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StopAlarm(
      id: id ?? this.id,
      title: title ?? this.title,
      stopType: stopType ?? this.stopType,
      customTypeLabel: customTypeLabel ?? this.customTypeLabel,
      timeOfDayHour: timeOfDayHour ?? this.timeOfDayHour,
      timeOfDayMinute: timeOfDayMinute ?? this.timeOfDayMinute,
      repeatDays: repeatDays ?? this.repeatDays,
      mode: mode ?? this.mode,
      protocolId: protocolId ?? this.protocolId,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
