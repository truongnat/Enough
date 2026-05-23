import 'package:flutter/material.dart';
import '../../../alarms/domain/entities/stop_mode.dart';

class AppSettings {
  final StopMode defaultMode;
  final bool notificationsEnabled;
  final int defaultSnoozeMinutes;
  final bool firstLaunchCompleted;
  final ThemeMode themeMode;
  final String? userName;

  AppSettings({
    required this.defaultMode,
    required this.notificationsEnabled,
    required this.defaultSnoozeMinutes,
    required this.firstLaunchCompleted,
    required this.themeMode,
    this.userName,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      defaultMode: StopMode.meme,
      notificationsEnabled: true,
      defaultSnoozeMinutes: 10,
      firstLaunchCompleted: false,
      themeMode: ThemeMode.system,
      userName: null,
    );
  }

  AppSettings copyWith({
    StopMode? defaultMode,
    bool? notificationsEnabled,
    int? defaultSnoozeMinutes,
    bool? firstLaunchCompleted,
    ThemeMode? themeMode,
    String? userName,
  }) {
    return AppSettings(
      defaultMode: defaultMode ?? this.defaultMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultSnoozeMinutes: defaultSnoozeMinutes ?? this.defaultSnoozeMinutes,
      firstLaunchCompleted: firstLaunchCompleted ?? this.firstLaunchCompleted,
      themeMode: themeMode ?? this.themeMode,
      userName: userName ?? this.userName,
    );
  }
}
