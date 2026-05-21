import 'dart:convert';

class NotificationPayload {
  final String action;
  final String alarmId;
  final String? sessionId;
  final String? category;
  final String? title;
  final String? scheduledAt;
  final String? stopType;

  NotificationPayload({
    required this.action,
    required this.alarmId,
    this.sessionId,
    this.category,
    this.title,
    this.scheduledAt,
    this.stopType,
  });

  static const String actionOpenStopSession = 'openStopSession';
  static const String actionOpenSnoozedSession = 'openSnoozedSession';
  static const String actionStopAlarm = 'stopAlarm';
  static const String actionSnoozeAlarm = 'snoozeAlarm';

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'alarmId': alarmId,
      'sessionId': sessionId,
      'category': category,
      'title': title,
      'scheduledAt': scheduledAt,
      'stopType': stopType,
    };
  }

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      action: map['action'] ?? NotificationPayload.actionOpenStopSession,
      alarmId: map['alarmId'] ?? '',
      sessionId: map['sessionId'],
      category: map['category'],
      title: map['title'],
      scheduledAt: map['scheduledAt'],
      stopType: map['stopType'],
    );
  }

  NotificationPayload copyWith({
    String? action,
    String? alarmId,
    String? sessionId,
    String? category,
    String? title,
    String? scheduledAt,
    String? stopType,
  }) {
    return NotificationPayload(
      action: action ?? this.action,
      alarmId: alarmId ?? this.alarmId,
      sessionId: sessionId ?? this.sessionId,
      category: category ?? this.category,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      stopType: stopType ?? this.stopType,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationPayload.fromJson(String source) {
    return NotificationPayload.fromMap(json.decode(source));
  }
}
