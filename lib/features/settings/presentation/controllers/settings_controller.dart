import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import '../../../alarms/domain/entities/stop_mode.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../services/storage/local_storage_service.dart';
import '../../../../services/notifications/notification_service.dart';
import '../../../../app/di/providers.dart';

class SettingsController extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;
  final LocalStorageService _storageService;
  final NotificationService _notificationService;

  SettingsController(
    this._repository,
    this._storageService,
    this._notificationService,
  ) : super(SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);

    try {
      final settings =
          await _repository.getSettings() ?? AppSettings.defaultSettings();
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setDefaultMode(StopMode mode) async {
    final current = state.settings;
    if (current == null) return;

    final updated = current.copyWith(defaultMode: mode);
    await _repository.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = state.settings;
    if (current == null) return;

    if (enabled) {
      // Request notification permission when enabling
      await _notificationService.requestPermissionsIfNeeded();
    }

    final updated = current.copyWith(notificationsEnabled: enabled);
    await _repository.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> setDefaultSnoozeMinutes(int minutes) async {
    final current = state.settings;
    if (current == null) return;

    final updated = current.copyWith(defaultSnoozeMinutes: minutes);
    await _repository.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.settings;
    if (current == null) return;

    final updated = current.copyWith(themeMode: mode);
    await _repository.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<void> setUserName(String? name) async {
    final current = state.settings;
    if (current == null) return;

    final trimmedName = name?.trim();
    final updated = current.copyWith(
      userName: trimmedName?.isEmpty ?? true ? null : trimmedName,
    );
    await _repository.saveSettings(updated);
    state = state.copyWith(settings: updated);
  }

  Future<Map<String, dynamic>> exportData() async {
    return _storageService.exportAllData();
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // Cancel all notifications before importing
    await _notificationService.cancelAll();
    await _storageService.importData(data);
    await loadSettings();
  }

  Future<void> resetAllData() async {
    try {
      // Cancel all notifications before clearing data
      await _notificationService.cancelAll();
      await _storageService.clearAllData();
      await loadSettings();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

class SettingsState {
  final AppSettings? settings;
  final bool isLoading;
  final String? error;

  SettingsState({this.settings, required this.isLoading, this.error});

  factory SettingsState.initial() {
    return SettingsState(settings: null, isLoading: false, error: null);
  }

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      final repository = ref.watch(settingsRepositoryProvider);
      final storageService = ref.watch(storageServiceProvider);
      final notificationService = ref.watch(notificationServiceProvider);
      return SettingsController(
        repository,
        storageService,
        notificationService,
      );
    });
