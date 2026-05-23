import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../../stop_session/domain/repositories/stop_session_repository.dart';
import '../../../stop_session/domain/entities/stop_session_status.dart';
import '../../../stop_session/domain/entities/stop_session.dart';
import '../../../../app/di/providers.dart';

class StatsController extends StateNotifier<StatsState> {
  final StopSessionRepository _sessionRepository;

  StatsController(this._sessionRepository) : super(StatsState.initial()) {
    loadStats();
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true);

    try {
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      // Get sessions from this week
      final sessions = await _sessionRepository.getSessions();
      final weeklySessions = sessions.where((s) {
        return s.startedAt.isAfter(weekStart) && s.startedAt.isBefore(weekEnd);
      }).toList();

      // Calculate stats
      final totalSessions = weeklySessions.length;
      final completedCount = weeklySessions
          .where((s) => s.status == StopSessionStatus.completed)
          .length;
      final missedCount = weeklySessions
          .where((s) => s.status == StopSessionStatus.missed)
          .length;
      final snoozedCount = weeklySessions
          .where((s) => s.status == StopSessionStatus.snoozed)
          .length;

      final successRate = totalSessions > 0
          ? (completedCount / totalSessions * 100)
          : 0.0;
      final failureRate = totalSessions > 0
          ? (missedCount / totalSessions * 100)
          : 0.0;
      final snoozeRate = totalSessions > 0
          ? (snoozedCount / totalSessions * 100)
          : 0.0;

      final protectedTimeMinutes =
          completedCount * 30; // 30 minutes per session

      // Daily breakdown based on completed sessions
      final dailyCounts = _calculateDailyStats(weeklySessions, weekStart);

      final weeklyStats = WeeklyStats(
        totalSessions: totalSessions,
        completedCount: completedCount,
        missedCount: missedCount,
        snoozedCount: snoozedCount,
        successRate: successRate,
        failureRate: failureRate,
        snoozeRate: snoozeRate,
        protectedTimeMinutes: protectedTimeMinutes,
        dailyStoppedCounts: dailyCounts,
      );

      state = state.copyWith(weeklyStats: weeklyStats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  DateTime _getWeekStart(DateTime date) {
    // Start from Monday
    final dayOfWeek = date.weekday;
    return DateTime(date.year, date.month, date.day - (dayOfWeek - 1));
  }

  Map<int, int> _calculateDailyStats(
    List<StopSession> sessions,
    DateTime weekStart,
  ) {
    final dailyCounts = <int, int>{};

    // Initialize all days with 0
    for (int i = 1; i <= 7; i++) {
      dailyCounts[i] = 0;
    }

    for (final session in sessions) {
      if (session.status == StopSessionStatus.completed) {
        final sessionDate = session.startedAt;
        final weekday = sessionDate.weekday; // 1 (Monday) to 7 (Sunday)
        if (weekday >= 1 && weekday <= 7) {
          dailyCounts[weekday] = (dailyCounts[weekday] ?? 0) + 1;
        }
      }
    }

    return dailyCounts;
  }
}

class StatsState {
  final WeeklyStats? weeklyStats;
  final bool isLoading;
  final String? error;

  StatsState({this.weeklyStats, required this.isLoading, this.error});

  factory StatsState.initial() {
    return StatsState(weeklyStats: null, isLoading: false, error: null);
  }

  StatsState copyWith({
    WeeklyStats? weeklyStats,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      weeklyStats: weeklyStats ?? this.weeklyStats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider
final statsControllerProvider =
    StateNotifierProvider<StatsController, StatsState>((ref) {
      final sessionRepository = ref.watch(stopSessionRepositoryProvider);
      return StatsController(sessionRepository);
    });
