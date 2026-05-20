import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get formattedHourMinute {
    return DateFormat('HH:mm').format(this);
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String get relativeDayHeader {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(year, month, day);

    if (checkDate == today) {
      return 'Hôm nay';
    } else if (checkDate == yesterday) {
      return 'Hôm qua';
    } else {
      return DateFormat('EEEE, dd/MM/yyyy', 'vi').format(this);
    }
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension DurationExt on Duration {
  String get formattedDuration {
    final hrs = inHours;
    final mins = inMinutes.remainder(60);
    if (hrs > 0) {
      return '${hrs}h ${mins}m';
    }
    return '${mins}m';
  }
}
