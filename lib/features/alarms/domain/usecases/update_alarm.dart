import '../../../../core/errors/app_exception.dart';
import '../entities/stop_alarm.dart';
import '../repositories/alarm_repository.dart';

class UpdateAlarm {
  final AlarmRepository _repository;

  UpdateAlarm(this._repository);

  Future<void> call(StopAlarm alarm) async {
    if (alarm.timeOfDayHour < 0 || alarm.timeOfDayHour > 23) {
      throw ValidationException('Giờ báo thức không hợp lệ (0-23)');
    }
    if (alarm.timeOfDayMinute < 0 || alarm.timeOfDayMinute > 59) {
      throw ValidationException('Phút báo thức không hợp lệ (0-59)');
    }

    await _repository.saveAlarm(alarm);
  }
}
