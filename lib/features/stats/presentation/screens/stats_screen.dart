import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/stats_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Copywriting.statsLabel),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.weeklyStats == null
              ? const Center(child: Text('No data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    children: [
                      _buildWeeklySummary(state),
                      const SizedBox(height: AppConstants.paddingL),
                      _buildDailyChart(state),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWeeklySummary(StatsState state) {
    final stats = state.weeklyStats!;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.weeklySummary,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppConstants.paddingL),
          _buildStatRow(
            Copywriting.totalStoppedLabel,
            '${stats.totalStoppedCount}',
            Icons.check_circle,
            AppColors.success,
          ),
          const SizedBox(height: AppConstants.paddingM),
          _buildStatRow(
            Copywriting.totalProtectedLabel,
            '${stats.totalProtectedTimeMinutes} ${Copywriting.minutesLabel}',
            Icons.access_time,
            AppColors.primary,
          ),
          const SizedBox(height: AppConstants.paddingM),
          _buildStatRow(
            Copywriting.successRateLabel,
            '${stats.successRate.round()}%',
            Icons.trending_up,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.h3,
        ),
      ],
    );
  }

  Widget _buildDailyChart(StatsState state) {
    final stats = state.weeklyStats!;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.dailyChartLabel,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppConstants.paddingL),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(stats.dailyStoppedCounts),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 1 && index <= 7) {
                          final dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                          return Padding(
                            padding: const EdgeInsets.only(top: AppConstants.paddingS),
                            child: Text(
                              dayNames[index - 1],
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: stats.dailyStoppedCounts.entries.map((entry) {
                  final index = entry.key;
                  final count = entry.value;
                  return BarChartGroupData(
                    x: index.toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(Map<int, int> dailyCounts) {
    if (dailyCounts.isEmpty) return 5;
    final maxCount = dailyCounts.values.reduce((a, b) => a > b ? a : b);
    return maxCount > 0 ? (maxCount + 1).toDouble() : 5;
  }
}
