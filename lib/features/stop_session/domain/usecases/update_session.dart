import '../entities/stop_session.dart';
import '../repositories/stop_session_repository.dart';

class UpdateSession {
  final StopSessionRepository repository;

  UpdateSession(this.repository);

  Future<void> call(StopSession session) async {
    await repository.saveSession(session);
  }
}
