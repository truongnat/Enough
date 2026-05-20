import '../entities/stop_session.dart';
import '../repositories/stop_session_repository.dart';

class GetSession {
  final StopSessionRepository repository;

  GetSession(this.repository);

  Future<StopSession?> call(String sessionId) async {
    return await repository.getSessionById(sessionId);
  }
}
