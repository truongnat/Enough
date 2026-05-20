import '../../../alarms/domain/entities/stop_alarm.dart';
import '../../../alarms/domain/repositories/alarm_repository.dart';

class GetNextAlarm {
  final AlarmRepository repository;

  GetNextAlarm(this.repository);

  Future<StopAlarm?> call() async {
    final alarms = await repository.getAlarms();
    final now = DateTime.now();
    
    StopAlarm? nextAlarm;
    DateTime? nearestTrigger;

    for (final alarm in alarms) {
      if (!alarm.isEnabled) continue;
      
      final trigger = alarm.getNextTrigger(now);
      if (nearestTrigger == null || trigger.isBefore(nearestTrigger)) {
        nearestTrigger = trigger;
        nextAlarm = alarm;
      }
    }

    return nextAlarm;
  }
}
