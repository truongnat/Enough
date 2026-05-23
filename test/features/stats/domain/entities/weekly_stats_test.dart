import 'package:flutter_test/flutter_test.dart';
import 'package:reverse_alarm/features/stats/domain/entities/weekly_stats.dart';

void main() {
  group('WeeklyStats', () {
    test('should create empty stats with correct defaults', () {
      final stats = WeeklyStats.empty();

      expect(stats.totalSessions, equals(0));
      expect(stats.completedCount, equals(0));
      expect(stats.missedCount, equals(0));
      expect(stats.snoozedCount, equals(0));
      expect(stats.successRate, equals(0.0));
      expect(stats.failureRate, equals(0.0));
      expect(stats.snoozeRate, equals(0.0));
      expect(stats.protectedTimeMinutes, equals(0));
      expect(stats.dailyStoppedCounts.length, equals(7));
    });

    test('should create stats with provided values', () {
      final stats = WeeklyStats(
        totalSessions: 10,
        completedCount: 8,
        missedCount: 1,
        snoozedCount: 1,
        successRate: 80.0,
        failureRate: 10.0,
        snoozeRate: 10.0,
        protectedTimeMinutes: 240,
        dailyStoppedCounts: {1: 2, 2: 3, 3: 1, 4: 2, 5: 1, 6: 1, 7: 0},
      );

      expect(stats.totalSessions, equals(10));
      expect(stats.completedCount, equals(8));
      expect(stats.missedCount, equals(1));
      expect(stats.snoozedCount, equals(1));
      expect(stats.successRate, equals(80.0));
      expect(stats.failureRate, equals(10.0));
      expect(stats.snoozeRate, equals(10.0));
      expect(stats.protectedTimeMinutes, equals(240));
      expect(stats.dailyStoppedCounts[1], equals(2));
    });
  });
}
