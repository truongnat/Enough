import '../../../receipts/domain/repositories/receipt_repository.dart';
import '../../../stop_session/data/datasources/stop_session_local_datasource.dart';
import '../../../stop_session/domain/entities/stop_session_status.dart';

class GetTodayStats {
  final ReceiptRepository receiptRepository;
  final StopSessionLocalDatasource sessionDatasource;

  GetTodayStats(this.receiptRepository, this.sessionDatasource);

  Future<Map<String, int>> call() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final sessions = await sessionDatasource.getAllSessions();
    
    int stoppedCount = 0;
    
    // Count completed sessions from today
    for (final session in sessions) {
      if (session.status == StopSessionStatus.completed) {
        final sessionDate = DateTime(
          session.startedAt.year,
          session.startedAt.month,
          session.startedAt.day,
        );
        if (sessionDate == today) {
          stoppedCount++;
        }
      }
    }
    
    return {
      'stoppedCount': stoppedCount,
    };
  }
}
