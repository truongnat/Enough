import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../../receipts/domain/repositories/receipt_repository.dart';
import '../../../stop_session/data/datasources/stop_session_local_datasource.dart';
import '../../../../app/di/providers.dart';

class StatsController extends StateNotifier<StatsState> {
  final ReceiptRepository _receiptRepository;
  final StopSessionLocalDatasource _sessionDatasource;

  StatsController(
    this._receiptRepository,
    this._sessionDatasource,
  ) : super(StatsState.initial()) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);

    try {
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      // Get receipts from this week
      final allReceipts = await _receiptRepository.getReceipts();
      final weeklyReceipts = allReceipts.where((r) {
        return r.completedAt.isAfter(weekStart) && r.completedAt.isBefore(weekEnd);
      }).toList();

      // Get sessions from this week
      final sessions = await _sessionDatasource.getAllSessions();
      final weeklySessions = sessions.where((s) {
        return s.startedAt.isAfter(weekStart) && s.startedAt.isBefore(weekEnd);
      }).toList();

      // Calculate stats
      final totalStopped = weeklyReceipts.length;
      final totalSessions = weeklySessions.length;
      final successRate = totalSessions > 0 
          ? (totalStopped / totalSessions * 100).round() 
          : 0;
      final protectedTime = totalStopped * 30; // 30 minutes per session

      // Daily breakdown
      final dailyCounts = _calculateDailyStats(weeklyReceipts, weekStart);

      final weeklyStats = WeeklyStats(
        totalStoppedCount: totalStopped,
        totalProtectedTimeMinutes: protectedTime,
        successRate: successRate.toDouble(),
        dailyStoppedCounts: dailyCounts,
      );

      state = state.copyWith(
        weeklyStats: weeklyStats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  DateTime _getWeekStart(DateTime date) {
    // Start from Monday
    final dayOfWeek = date.weekday;
    return DateTime(date.year, date.month, date.day - (dayOfWeek - 1));
  }

  Map<int, int> _calculateDailyStats(List receipts, DateTime weekStart) {
    final dailyCounts = <int, int>{};
    
    // Initialize all days with 0
    for (int i = 1; i <= 7; i++) {
      dailyCounts[i] = 0;
    }
    
    for (final receipt in receipts) {
      final receiptDate = receipt.completedAt;
      final weekday = receiptDate.weekday; // 1 (Monday) to 7 (Sunday)
      if (weekday >= 1 && weekday <= 7) {
        dailyCounts[weekday] = (dailyCounts[weekday] ?? 0) + 1;
      }
    }

    return dailyCounts;
  }
}

class StatsState {
  final WeeklyStats? weeklyStats;
  final bool isLoading;
  final String? error;

  StatsState({
    this.weeklyStats,
    required this.isLoading,
    this.error,
  });

  factory StatsState.initial() {
    return StatsState(
      weeklyStats: null,
      isLoading: false,
      error: null,
    );
  }

  StatsState copyWith({
    WeeklyStats? weeklyStats,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      weeklyStats: weeklyStats ?? this.weeklyStats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Provider
final statsControllerProvider = StateNotifierProvider<StatsController, StatsState>((ref) {
  final receiptRepository = ref.watch(receiptRepositoryProvider);
  final sessionDatasource = ref.watch(stopSessionLocalDatasourceProvider);
  return StatsController(
    receiptRepository, 
    sessionDatasource
  );
});
