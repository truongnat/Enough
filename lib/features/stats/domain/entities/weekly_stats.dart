class WeeklyStats {
  final int totalStoppedCount;
  final int totalProtectedTimeMinutes;
  final double successRate;
  final Map<int, int> dailyStoppedCounts; // 1 (Mon) -> 7 (Sun)

  WeeklyStats({
    required this.totalStoppedCount,
    required this.totalProtectedTimeMinutes,
    required this.successRate,
    required this.dailyStoppedCounts,
  });

  factory WeeklyStats.empty() {
    return WeeklyStats(
      totalStoppedCount: 0,
      totalProtectedTimeMinutes: 0,
      successRate: 0.0,
      dailyStoppedCounts: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0},
    );
  }
}

class DailyStat {
  final DateTime date;
  final int count;

  DailyStat({
    required this.date,
    required this.count,
  });
}
