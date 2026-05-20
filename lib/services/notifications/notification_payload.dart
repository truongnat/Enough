import 'dart:convert';

class NotificationPayload {
  final String alarmId;
  final String category;
  final String title;

  NotificationPayload({
    required this.alarmId,
    required this.category,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'alarmId': alarmId,
      'category': category,
      'title': title,
    };
  }

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      alarmId: map['alarmId'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationPayload.fromJson(String source) {
    return NotificationPayload.fromMap(json.decode(source));
  }
}
