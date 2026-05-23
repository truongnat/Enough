class WeeklyStats {
  final int totalSessions;
  final int completedCount;
  final int missedCount;
  final int snoozedCount;
  final double successRate;
  final double failureRate;
  final double snoozeRate;
  final int protectedTimeMinutes;
  final Map<int, int> dailyStoppedCounts; // 1 (Mon) -> 7 (Sun)

  WeeklyStats({
    required this.totalSessions,
    required this.completedCount,
    required this.missedCount,
    required this.snoozedCount,
    required this.successRate,
    required this.failureRate,
    required this.snoozeRate,
    required this.protectedTimeMinutes,
    required this.dailyStoppedCounts,
  });

  factory WeeklyStats.empty() {
    return WeeklyStats(
      totalSessions: 0,
      completedCount: 0,
      missedCount: 0,
      snoozedCount: 0,
      successRate: 0.0,
      failureRate: 0.0,
      snoozeRate: 0.0,
      protectedTimeMinutes: 0,
      dailyStoppedCounts: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0},
    );
  }
}

class DailyStat {
  final DateTime date;
  final int count;

  DailyStat({required this.date, required this.count});
}
