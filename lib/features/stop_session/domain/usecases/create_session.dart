import '../entities/stop_session.dart';
import '../repositories/stop_session_repository.dart';

class CreateSession {
  final StopSessionRepository repository;

  CreateSession(this.repository);

  Future<void> call(StopSession session) async {
    await repository.saveSession(session);
  }
}
