import '../../domain/entities/stop_session.dart';
import '../../domain/entities/stop_session_status.dart';
import '../../../alarms/domain/entities/stop_type.dart';

class StopSessionModel {
  static StopSession fromJson(Map<String, dynamic> json) {
    return StopSession(
      id: json['id'] as String,
      alarmId: json['alarmId'] as String,
      stopType: StopType.values.firstWhere(
        (e) => e.name == json['stopType'],
        orElse: () => StopType.custom,
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      status: StopSessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StopSessionStatus.active,
      ),
      snoozeCount: json['snoozeCount'] as int? ?? 0,
      checkedStepIndexes: List<int>.from(json['checkedStepIndexes'] as List),
    );
  }

  static Map<String, dynamic> toJson(StopSession session) {
    return {
      'id': session.id,
      'alarmId': session.alarmId,
      'stopType': session.stopType.name,
      'startedAt': session.startedAt.toIso8601String(),
      'completedAt': session.completedAt?.toIso8601String(),
      'status': session.status.name,
      'snoozeCount': session.snoozeCount,
      'checkedStepIndexes': session.checkedStepIndexes,
    };
  }
}
