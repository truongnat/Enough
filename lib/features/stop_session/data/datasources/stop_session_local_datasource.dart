import '../../../../../services/storage/local_storage_service.dart';
import '../../domain/entities/stop_session.dart';
import '../models/stop_session_model.dart';

class StopSessionLocalDatasource {
  final LocalStorageService _storageService;
  static const String _sessionKey = 'active_session';

  StopSessionLocalDatasource(this._storageService);

  Future<Map<String, dynamic>?> getActiveSession() async {
    return _storageService.getSettings(_sessionKey);
  }

  Future<void> saveActiveSession(Map<String, dynamic> sessionJson) async {
    await _storageService.saveSettings(_sessionKey, sessionJson);
  }

  Future<void> deleteActiveSession() async {
    await _storageService.saveSettings(_sessionKey, {});
  }

  Future<List<StopSession>> getAllSessions() async {
    final sessionsJson = _storageService.getSessions();
    return sessionsJson.map((json) => StopSessionModel.fromJson(json)).toList();
  }
}
