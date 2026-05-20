class Copywriting {
  // Greetings based on time of day
  static String getGreeting(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour >= 12 && hour < 18) {
      return 'Chào buổi chiều';
    } else if (hour >= 18 && hour < 22) {
      return 'Chào buổi tối';
    } else {
      return 'Đêm rồi';
    }
  }

  // Home screen
  static const String nextAlarmLabel = 'Báo thức tiếp theo';
  static const String todayLabel = 'Hôm nay';
  static const String stoppedCountLabel = 'Đã dừng';
  static const String timesLabel = 'lần';
  static const String latestReceiptLabel = 'Biên lai gần nhất';
  static const String noAlarmLabel = 'Chưa có báo thức nào';
  static const String noReceiptLabel = 'Chưa có biên lai nào';
  static const String createFirstAlarm = 'Tạo báo thức đầu tiên';

  // Stop session
  static String getStopSessionTitle(String stopType) {
    return 'ĐỪNG $stopType NỮA!';
  }

  static String getStopSessionMessage(String mode) {
    switch (mode) {
      case 'gentle':
        return 'Đủ rồi. Phần còn lại để ngày mai.';
      case 'strict':
        return 'Mày đang không productivity nữa. Mày đang tự bào pin não.';
      case 'meme':
        return 'Đóng app lại đi chiến thần. Não không phải server 24/7.';
      default:
        return 'Đã đến giờ dừng. Hãy hoàn thành quy trình ngay.';
    }
  }

  static const String protocolLabel = 'Quy trình dừng';
  static const String completeButton = 'Tôi đã dừng lại';
  static const String snoozeButton = 'Cho tôi thêm 10 phút...';
  static const String snoozeWarning = 'Đừng tự dối lòng!';
  static const String mustCheckStep = 'Bạn cần tick ít nhất 1 bước để hoàn thành';

  // Receipt
  static const String receiptTitle = 'BIÊN LAI DỪNG';
  static const String receiptDateLabel = 'Ngày';
  static const String receiptTimeLabel = 'Thời gian';
  static const String receiptSavedLabel = 'Đã cứu bạn khỏi';
  static const String receiptResultLabel = 'Kết quả';
  static const String receiptResult = 'Human preserved';
  static const String deleteReceipt = 'Xóa biên lai';
  static const String shareReceipt = 'Chia sẻ';

  // History
  static const String historyLabel = 'Lịch sử';
  static const String todayLabelHistory = 'Hôm nay';
  static const String yesterdayLabel = 'Hôm qua';
  static const String olderLabel = 'Ngày cũ';
  static const String filterAll = 'Tất cả';
  static const String filterSuccess = 'Thành công';
  static const String filterSnooze = 'Hoãn';
  static const String statusSuccess = 'Đã dừng';
  static const String statusSnoozed = 'Đã hoãn';
  static const String statusMissed = 'Bỏ lỡ';
  static const String emptyHistory = 'Chưa có lịch sử nào';

  // Stats
  static const String statsLabel = 'Thống kê';
  static const String weeklySummary = 'Tóm tắt tuần';
  static const String totalStoppedLabel = 'Tổng đã dừng';
  static const String totalProtectedLabel = 'Thời gian bảo vệ';
  static const String successRateLabel = 'Tỷ lệ thành công';
  static const String minutesLabel = 'phút';
  static const String dailyChartLabel = 'Theo ngày';

  // Settings
  static const String settingsLabel = 'Cài đặt';
  static const String defaultModeLabel = 'Chế độ mặc định';
  static const String notificationsLabel = 'Thông báo';
  static const String snoozeMinutesLabel = 'Thời gian hoãn mặc định';
  static const String resetDataLabel = 'Xóa dữ liệu';
  static const String resetDataWarning = 'Hành động này sẽ xóa tất cả dữ liệu!';
  static const String aboutLabel = 'Về app';
  static const String versionLabel = 'Phiên bản';
  static const String sloganLabel = 'The alarm for stopping, not starting.';

  // Create/Edit Alarm
  static const String createAlarmLabel = 'Tạo báo thức';
  static const String editAlarmLabel = 'Sửa báo thức';
  static const String stopTypeLabel = 'Loại dừng';
  static const String timeLabel = 'Giờ';
  static const String repeatDaysLabel = 'Lặp lại';
  static const String modeLabel = 'Chế độ';
  static const String protocolLabelAlarm = 'Quy trình';
  static const String enabledLabel = 'Bật';
  static const String saveButton = 'Lưu';
  static const String cancelButton = 'Hủy';
  static const String deleteButton = 'Xóa';
  static const String customTypeHint = 'Nhập loại dừng tùy chỉnh...';

  // Common
  static const String confirm = 'Xác nhận';
  static const String cancel = 'Hủy';
  static const String delete = 'Xóa';
  static const String save = 'Lưu';
  static const String back = 'Quay lại';
  static const String done = 'Xong';
  static const String loading = 'Đang tải...';
  static const String error = 'Có lỗi xảy ra';
  static const String retry = 'Thử lại';
}
