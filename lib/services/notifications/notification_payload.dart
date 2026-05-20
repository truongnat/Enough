import 'dart:convert';

class NotificationPayload {
  final String action;
  final String alarmId;
  final String? sessionId;
  final String? category;
  final String? title;

  NotificationPayload({
    required this.action,
    required this.alarmId,
    this.sessionId,
    this.category,
    this.title,
  });

  static const String actionOpenStopSession = 'openStopSession';
  static const String actionOpenSnoozedSession = 'openSnoozedSession';

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'alarmId': alarmId,
      'sessionId': sessionId,
      'category': category,
      'title': title,
    };
  }

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      action: map['action'] ?? NotificationPayload.actionOpenStopSession,
      alarmId: map['alarmId'] ?? '',
      sessionId: map['sessionId'],
      category: map['category'],
      title: map['title'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationPayload.fromJson(String source) {
    return NotificationPayload.fromMap(json.decode(source));
  }
}
