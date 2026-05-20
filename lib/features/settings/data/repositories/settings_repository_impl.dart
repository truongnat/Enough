import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<AppSettings?> getSettings() async {
    final settingsJson = await _datasource.getSettings();
    if (settingsJson == null) return null;
    return AppSettingsModel.fromJson(settingsJson);
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final settingsJson = AppSettingsModel.toJson(settings);
    await _datasource.saveSettings(settingsJson);
  }
}
