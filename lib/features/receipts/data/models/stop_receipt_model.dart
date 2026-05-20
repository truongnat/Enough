import '../../domain/entities/stop_receipt.dart';
import '../../../alarms/domain/entities/stop_type.dart';

class StopReceiptModel {
  static StopReceipt fromJson(Map<String, dynamic> json) {
    return StopReceipt(
      id: json['id'] as String,
      alarmId: json['alarmId'] as String,
      sessionId: json['sessionId'] as String,
      stopType: StopType.values.firstWhere(
        (e) => e.name == json['stopType'],
        orElse: () => StopType.custom,
      ),
      title: json['title'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      savedFromMessages: List<String>.from(json['savedFromMessages'] as List),
      resultMessage: json['resultMessage'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static Map<String, dynamic> toJson(StopReceipt receipt) {
    return {
      'id': receipt.id,
      'alarmId': receipt.alarmId,
      'sessionId': receipt.sessionId,
      'stopType': receipt.stopType.name,
      'title': receipt.title,
      'startedAt': receipt.startedAt.toIso8601String(),
      'completedAt': receipt.completedAt.toIso8601String(),
      'savedFromMessages': receipt.savedFromMessages,
      'resultMessage': receipt.resultMessage,
      'createdAt': receipt.createdAt.toIso8601String(),
    };
  }
}
