enum RepeatDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  int get isoValue {
    switch (this) {
      case RepeatDay.monday:
        return 1;
      case RepeatDay.tuesday:
        return 2;
      case RepeatDay.wednesday:
        return 3;
      case RepeatDay.thursday:
        return 4;
      case RepeatDay.friday:
        return 5;
      case RepeatDay.saturday:
        return 6;
      case RepeatDay.sunday:
        return 7;
    }
  }

  String get shortName {
    switch (this) {
      case RepeatDay.monday:
        return 'T2';
      case RepeatDay.tuesday:
        return 'T3';
      case RepeatDay.wednesday:
        return 'T4';
      case RepeatDay.thursday:
        return 'T5';
      case RepeatDay.friday:
        return 'T6';
      case RepeatDay.saturday:
        return 'T7';
      case RepeatDay.sunday:
        return 'CN';
    }
  }

  String get displayName {
    switch (this) {
      case RepeatDay.monday:
        return 'Thứ Hai';
      case RepeatDay.tuesday:
        return 'Thứ Ba';
      case RepeatDay.wednesday:
        return 'Thứ Tư';
      case RepeatDay.thursday:
        return 'Thứ Năm';
      case RepeatDay.friday:
        return 'Thứ Sáu';
      case RepeatDay.saturday:
        return 'Thứ Bảy';
      case RepeatDay.sunday:
        return 'Chủ Nhật';
    }
  }

  static RepeatDay fromIsoValue(int value) {
    switch (value) {
      case 1:
        return RepeatDay.monday;
      case 2:
        return RepeatDay.tuesday;
      case 3:
        return RepeatDay.wednesday;
      case 4:
        return RepeatDay.thursday;
      case 5:
        return RepeatDay.friday;
      case 6:
        return RepeatDay.saturday;
      case 7:
      default:
        return RepeatDay.sunday;
    }
  }
}
