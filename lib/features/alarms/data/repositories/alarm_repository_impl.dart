import '../../domain/entities/stop_alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../datasources/alarm_local_datasource.dart';
import '../models/stop_alarm_model.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmLocalDatasource _datasource;

  AlarmRepositoryImpl(this._datasource);

  @override
  Future<List<StopAlarm>> getAlarms() async {
    try {
      final jsonList = await _datasource.getAlarms();
      return jsonList.map((json) => StopAlarmModel.fromJson(json)).toList();
    } catch (e) {
      print('[AlarmRepository] Error getting alarms: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveAlarm(StopAlarm alarm) async {
    final json = StopAlarmModel.toJson(alarm);
    await _datasource.saveAlarm(alarm.id, json);
  }

  @override
  Future<void> deleteAlarm(String id) async {
    await _datasource.deleteAlarm(id);
  }

  @override
  Future<StopAlarm?> getAlarmById(String id) async {
    final alarms = await getAlarms();
    try {
      return alarms.firstWhere((a) => a.id == id);
    } catch (e) {
      print('[AlarmRepository] Alarm not found: $id');
      return null;
    }
  }
}
