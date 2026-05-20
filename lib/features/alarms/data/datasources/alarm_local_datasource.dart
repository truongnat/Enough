import '../../../../../services/storage/local_storage_service.dart';

class AlarmLocalDatasource {
  final LocalStorageService _storageService;

  AlarmLocalDatasource(this._storageService);

  Future<List<Map<String, dynamic>>> getAlarms() async {
    return _storageService.getAlarms();
  }

  Future<void> saveAlarm(String id, Map<String, dynamic> alarmJson) async {
    await _storageService.saveAlarm(id, alarmJson);
  }

  Future<void> deleteAlarm(String id) async {
    await _storageService.deleteAlarm(id);
  }
}
