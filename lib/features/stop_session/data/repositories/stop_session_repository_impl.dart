import '../../domain/entities/stop_session.dart';
import '../../domain/repositories/stop_session_repository.dart';
import '../datasources/stop_session_local_datasource.dart';
import '../models/stop_session_model.dart';

class StopSessionRepositoryImpl implements StopSessionRepository {
  final StopSessionLocalDatasource datasource;

  StopSessionRepositoryImpl(this.datasource);

  @override
  Future<List<StopSession>> getSessions() async {
    try {
      return await datasource.getAllSessions();
    } catch (e) {
      print('[StopSessionRepository] Error getting sessions: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveSession(StopSession session) async {
    try {
      final sessionJson = StopSessionModel.toJson(session);
      await datasource.saveSession(session.id, sessionJson);
    } catch (e) {
      print('[StopSessionRepository] Error saving session: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await datasource.deleteSession(sessionId);
    } catch (e) {
      print('[StopSessionRepository] Error deleting session: $e');
      rethrow;
    }
  }

  @override
  Future<StopSession?> getSessionById(String sessionId) async {
    try {
      final sessions = await getSessions();
      return sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      print('[StopSessionRepository] Session not found: $sessionId');
      return null;
    }
  }

  @override
  Future<List<StopSession>> getSessionsByAlarmId(String alarmId) async {
    try {
      final sessions = await getSessions();
      return sessions.where((s) => s.alarmId == alarmId).toList();
    } catch (e) {
      print('[StopSessionRepository] Error getting sessions by alarmId: $e');
      rethrow;
    }
  }
}
