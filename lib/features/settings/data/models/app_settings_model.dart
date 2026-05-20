import '../../domain/entities/app_settings.dart';
import '../../../alarms/domain/entities/stop_mode.dart';

class AppSettingsModel {
  static AppSettings fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultMode: StopMode.values.firstWhere(
        (e) => e.name == json['defaultMode'],
        orElse: () => StopMode.meme,
      ),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      defaultSnoozeMinutes: json['defaultSnoozeMinutes'] as int? ?? 10,
      firstLaunchCompleted: json['firstLaunchCompleted'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toJson(AppSettings settings) {
    return {
      'defaultMode': settings.defaultMode.name,
      'notificationsEnabled': settings.notificationsEnabled,
      'defaultSnoozeMinutes': settings.defaultSnoozeMinutes,
      'firstLaunchCompleted': settings.firstLaunchCompleted,
    };
  }
}
