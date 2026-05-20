enum StopType {
  coding,
  working,
  scrolling,
  overthinking,
  sleep,
  custom;

  String get displayName {
    switch (this) {
      case StopType.coding:
        return 'Stop Coding';
      case StopType.working:
        return 'Stop Working';
      case StopType.scrolling:
        return 'Stop Scrolling';
      case StopType.overthinking:
        return 'Stop Overthinking';
      case StopType.sleep:
        return 'Go Sleep';
      case StopType.custom:
        return 'Tự chọn';
    }
  }

  String get subtitle {
    switch (this) {
      case StopType.coding:
        return 'Đến lúc đứng dậy rồi';
      case StopType.working:
        return 'Bảo vệ sức lao động';
      case StopType.scrolling:
        return 'Thoát khỏi vô tận cuộn';
      case StopType.overthinking:
        return 'Giải thoát bộ não';
      case StopType.sleep:
        return 'Ngủ thôi, đừng cố quá';
      case StopType.custom:
        return 'Dừng thói quen xấu';
    }
  }
}
