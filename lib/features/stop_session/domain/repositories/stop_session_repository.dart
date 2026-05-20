import '../entities/stop_session.dart';

abstract class StopSessionRepository {
  Future<List<StopSession>> getSessions();
  Future<void> saveSession(StopSession session);
  Future<void> deleteSession(String sessionId);
  Future<StopSession?> getSessionById(String sessionId);
  Future<List<StopSession>> getSessionsByAlarmId(String alarmId);
}
