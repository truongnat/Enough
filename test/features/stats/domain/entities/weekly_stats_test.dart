import 'package:flutter_test/flutter_test.dart';
import 'package:reverse_alarm/features/stats/domain/entities/weekly_stats.dart';

void main() {
  group('WeeklyStats', () {
    test('should create empty stats with correct defaults', () {
      final stats = WeeklyStats.empty();
      
      expect(stats.totalStoppedCount, equals(0));
      expect(stats.totalProtectedTimeMinutes, equals(0));
      expect(stats.successRate, equals(0.0));
      expect(stats.dailyStoppedCounts.length, equals(7));
    });

    test('should create stats with provided values', () {
      final stats = WeeklyStats(
        totalStoppedCount: 10,
        totalProtectedTimeMinutes: 300,
        successRate: 85.5,
        dailyStoppedCounts: {1: 2, 2: 3, 3: 1, 4: 2, 5: 1, 6: 1, 7: 0},
      );
      
      expect(stats.totalStoppedCount, equals(10));
      expect(stats.totalProtectedTimeMinutes, equals(300));
      expect(stats.successRate, equals(85.5));
      expect(stats.dailyStoppedCounts[1], equals(2));
    });
  });
}
