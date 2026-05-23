import 'package:flutter/material.dart';
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
      themeMode: _parseThemeMode(json['themeMode'] as String?),
      userName: json['userName'] as String?,
    );
  }

  static Map<String, dynamic> toJson(AppSettings settings) {
    return {
      'defaultMode': settings.defaultMode.name,
      'notificationsEnabled': settings.notificationsEnabled,
      'defaultSnoozeMinutes': settings.defaultSnoozeMinutes,
      'firstLaunchCompleted': settings.firstLaunchCompleted,
      'themeMode': settings.themeMode.name,
      'userName': settings.userName,
    };
  }

  static ThemeMode _parseThemeMode(String? value) {
    if (value == null) {
      // Backward compatibility: if themeMode not in old data, default to dark
      return ThemeMode.dark;
    }
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }
}
