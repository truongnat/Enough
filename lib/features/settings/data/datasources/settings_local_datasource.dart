import '../../../../../services/storage/local_storage_service.dart';

class SettingsLocalDatasource {
  final LocalStorageService _storageService;
  static const String _settingsKey = 'reverse_alarm_app_settings';

  SettingsLocalDatasource(this._storageService);

  Future<Map<String, dynamic>?> getSettings() async {
    return _storageService.getSettings(_settingsKey);
  }

  Future<void> saveSettings(Map<String, dynamic> settingsJson) async {
    await _storageService.saveSettings(_settingsKey, settingsJson);
  }
}
