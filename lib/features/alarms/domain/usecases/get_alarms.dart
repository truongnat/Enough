import '../entities/stop_alarm.dart';
import '../repositories/alarm_repository.dart';

class GetAlarms {
  final AlarmRepository _repository;

  GetAlarms(this._repository);

  Future<List<StopAlarm>> call() async {
    return _repository.getAlarms();
  }
}
