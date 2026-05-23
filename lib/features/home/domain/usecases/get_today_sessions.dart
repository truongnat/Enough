import '../../../stop_session/domain/entities/stop_session.dart';
import '../../../stop_session/domain/repositories/stop_session_repository.dart';

class GetTodaySessions {
  final StopSessionRepository repository;

  GetTodaySessions(this.repository);

  Future<List<StopSession>> call() async {
    final allSessions = await repository.getSessions();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return allSessions.where((session) {
      return !session.startedAt.isBefore(startOfDay) &&
          session.startedAt.isBefore(endOfDay);
    }).toList();
  }
}
