import '../../domain/entities/stop_alarm.dart';
import '../../domain/entities/stop_type.dart';
import '../../domain/entities/stop_mode.dart';
import '../../domain/entities/repeat_day.dart';

class StopAlarmModel {
  static StopAlarm fromJson(Map<String, dynamic> json) {
    return StopAlarm(
      id: json['id'] as String,
      title: json['title'] as String,
      stopType: StopType.values.firstWhere(
        (e) => e.name == json['stopType'],
        orElse: () => StopType.custom,
      ),
      customTypeLabel: json['customTypeLabel'] as String?,
      timeOfDayHour: json['timeOfDayHour'] as int,
      timeOfDayMinute: json['timeOfDayMinute'] as int,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((d) => RepeatDay.values.firstWhere((e) => e.name == d))
              .toList() ??
          [],
      mode: StopMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => StopMode.gentle,
      ),
      protocolId: json['protocolId'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static Map<String, dynamic> toJson(StopAlarm alarm) {
    return {
      'id': alarm.id,
      'title': alarm.title,
      'stopType': alarm.stopType.name,
      'customTypeLabel': alarm.customTypeLabel,
      'timeOfDayHour': alarm.timeOfDayHour,
      'timeOfDayMinute': alarm.timeOfDayMinute,
      'repeatDays': alarm.repeatDays.map((d) => d.name).toList(),
      'mode': alarm.mode.name,
      'protocolId': alarm.protocolId,
      'isEnabled': alarm.isEnabled,
      'createdAt': alarm.createdAt.toIso8601String(),
      'updatedAt': alarm.updatedAt.toIso8601String(),
    };
  }
}
