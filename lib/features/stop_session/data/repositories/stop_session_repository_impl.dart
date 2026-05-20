import '../../domain/entities/stop_session.dart';
import '../../domain/repositories/stop_session_repository.dart';
import '../datasources/stop_session_local_datasource.dart';
import '../models/stop_session_model.dart';

class StopSessionRepositoryImpl implements StopSessionRepository {
  final StopSessionLocalDatasource datasource;

  StopSessionRepositoryImpl(this.datasource);

  @override
  Future<List<StopSession>> getSessions() async {
    return await datasource.getAllSessions();
  }

  @override
  Future<void> saveSession(StopSession session) async {
    final sessionJson = StopSessionModel.toJson(session);
    await datasource.saveActiveSession(sessionJson);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await datasource.deleteActiveSession();
  }

  @override
  Future<StopSession?> getSessionById(String sessionId) async {
    final sessions = await getSessions();
    try {
      return sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<StopSession>> getSessionsByAlarmId(String alarmId) async {
    final sessions = await getSessions();
    return sessions.where((s) => s.alarmId == alarmId).toList();
  }
}
