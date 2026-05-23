import 'stop_session_status.dart';
import '../../../alarms/domain/entities/stop_type.dart';
import '../../../alarms/domain/entities/stop_mode.dart';

class StopSession {
  final String id;
  final String alarmId;
  final StopType stopType;
  final DateTime startedAt;
  final DateTime? completedAt;
  final StopSessionStatus status;
  final int snoozeCount;
  final List<int> checkedStepIndexes;

  StopSession({
    required this.id,
    required this.alarmId,
    required this.stopType,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.snoozeCount,
    required this.checkedStepIndexes,
  });

  // Complete rule: User must check at least 1 protocol step to complete.
  bool get canComplete => checkedStepIndexes.isNotEmpty;

  // Missed rule: If session has been active for more than 2 hours without complete/snooze, it is missed.
  bool isMissed(DateTime now) {
    if (status != StopSessionStatus.active) return false;
    return now.difference(startedAt).inHours >= 2;
  }

  // Witty Quotes provider based on StopMode and index/random
  static String getWittyQuote(StopMode mode, int seed) {
    final List<String> quotes;
    switch (mode) {
      case StopMode.general:
        quotes = [
          'Đủ rồi. Phần còn lại để ngày mai.',
          'Bạn không cần giải quyết mọi thứ tối nay.',
          'Dừng đúng lúc cũng là một kỹ năng.',
          'Nghỉ ngơi là chuẩn bị cho sự vượt trội của ngày mai.',
        ];
        break;
      case StopMode.strict:
        quotes = [
          'Mày đang không productivity nữa. Mày đang tự bào pin não.',
          'Đây không còn là cố gắng. Đây là sa lầy.',
          'Đóng lại. Mai xử lý tiếp.',
          'Kiệt sức không phải là vinh quang. Dừng lại đi.',
        ];
        break;
      case StopMode.meme:
        quotes = [
          'Đóng VSCode đi chiến thần.',
          'Bug này không chạy mất đâu.',
          'Không có video thứ 87 nào cứu đời mày lúc này.',
          'Não không phải server chạy 24/7.',
          'Ngủ đi, deadline vẫn ở đó chờ ngày mai.',
        ];
        break;
    }
    return quotes[seed % quotes.length];
  }

  StopSession copyWith({
    String? id,
    String? alarmId,
    StopType? stopType,
    DateTime? startedAt,
    DateTime? completedAt,
    StopSessionStatus? status,
    int? snoozeCount,
    List<int>? checkedStepIndexes,
  }) {
    return StopSession(
      id: id ?? this.id,
      alarmId: alarmId ?? this.alarmId,
      stopType: stopType ?? this.stopType,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      checkedStepIndexes: checkedStepIndexes ?? this.checkedStepIndexes,
    );
  }
}
