import '../entities/stop_alarm.dart';

abstract class AlarmRepository {
  Future<List<StopAlarm>> getAlarms();
  Future<void> saveAlarm(StopAlarm alarm);
  Future<void> deleteAlarm(String id);
  Future<StopAlarm?> getAlarmById(String id);
}
