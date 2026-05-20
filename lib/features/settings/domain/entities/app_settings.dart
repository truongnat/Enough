import '../../../alarms/domain/entities/stop_mode.dart';

class AppSettings {
  final StopMode defaultMode;
  final bool notificationsEnabled;
  final int defaultSnoozeMinutes;
  final bool firstLaunchCompleted;

  AppSettings({
    required this.defaultMode,
    required this.notificationsEnabled,
    required this.defaultSnoozeMinutes,
    required this.firstLaunchCompleted,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      defaultMode: StopMode.meme,
      notificationsEnabled: true,
      defaultSnoozeMinutes: 10,
      firstLaunchCompleted: false,
    );
  }

  AppSettings copyWith({
    StopMode? defaultMode,
    bool? notificationsEnabled,
    int? defaultSnoozeMinutes,
    bool? firstLaunchCompleted,
  }) {
    return AppSettings(
      defaultMode: defaultMode ?? this.defaultMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultSnoozeMinutes: defaultSnoozeMinutes ?? this.defaultSnoozeMinutes,
      firstLaunchCompleted: firstLaunchCompleted ?? this.firstLaunchCompleted,
    );
  }
}
