import '../../../alarms/domain/entities/stop_type.dart';

class StopReceipt {
  final String id;
  final String alarmId;
  final String sessionId;
  final StopType stopType;
  final String title;
  final DateTime startedAt;
  final DateTime completedAt;
  final List<String> savedFromMessages;
  final String resultMessage;
  final DateTime createdAt;

  StopReceipt({
    required this.id,
    required this.alarmId,
    required this.sessionId,
    required this.stopType,
    required this.title,
    required this.startedAt,
    required this.completedAt,
    required this.savedFromMessages,
    required this.resultMessage,
    required this.createdAt,
  });

  // Business logic: Generate prevented negative outcomes based on StopType
  static List<String> getPreventedItemsFor(StopType type) {
    switch (type) {
      case StopType.coding:
        return [
          '1 bug ngu ngốc lúc nửa đêm',
          '2 tiếng ngủ ngon bị đánh mất',
          '1 commit vội vã đầy hối hận',
        ];
      case StopType.working:
        return [
          '1 email gửi nhầm lúc cáu giận',
          '1.5 tiếng làm thêm không lương',
          'Những lời hứa lèo của sếp lúc nửa đêm',
        ];
      case StopType.scrolling:
        return [
          '50 video ngắn vô bổ lặp đi lặp lại',
          'Đôi mắt đỏ ngầu khô khốc',
          'Cơn đau vai gáy kinh niên lúc 1h sáng',
        ];
      case StopType.overthinking:
        return [
          '3 kịch bản lo sợ không bao giờ xảy ra',
          '1 buổi sáng thức dậy mệt mỏi',
          'Cơn nhức đầu vô ích lúc nửa đêm',
        ];
      case StopType.sleep:
        return [
          'Cơn thèm ăn khuya tăng cân',
          'Sự tàn phá nhan sắc và làn da',
          'Sự uể oải tột độ vào sáng mai',
        ];
      case StopType.custom:
        return [
          'Sự nuông chiều bản thân quá đà',
          'Sự lãng phí năng lượng quý giá',
          'Cảm giác tội lỗi khi thức dậy muộn',
        ];
    }
  }
}
