import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
import '../controllers/stats_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppGradientBackground(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppPageHeader(
                title: 'Thống kê',
                leading: SizedBox(width: 44, height: 44),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.weeklyStats == null
                    ? Center(
                        child: Text(
                          'No data available',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.of(
                              context,
                              AppColors.textSecondary,
                              AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 10, bottom: 120),
                        children: [
                          _buildSummary(context, state),
                          const SizedBox(height: 18),
                          _buildChart(context, state),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, StatsState state) {
    final stats = state.weeklyStats!;
    final protectedHours = stats.protectedTimeMinutes ~/ 60;
    final protectedMinutes = stats.protectedTimeMinutes % 60;

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê tuần này',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.of(
                context,
                AppColors.textPrimary,
                AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _metric(
                  context,
                  '${stats.completedCount}',
                  'Lần đã dừng',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _metric(
                  context,
                  '${protectedHours}h ${protectedMinutes}m',
                  'Năng lượng bảo vệ',
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _metric(
                  context,
                  '${stats.successRate.round()}%',
                  'Tỷ lệ thành công',
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.h3.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.of(
              context,
              AppColors.textSecondary,
              AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, StatsState state) {
    final stats = state.weeklyStats!;
    final maxCount = stats.dailyStoppedCounts.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nhịp dừng trong tuần',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.of(
                context,
                AppColors.textPrimary,
                AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final day = index + 1;
                final count = stats.dailyStoppedCounts[day] ?? 0;
                final factor = maxCount == 0
                    ? 0.12
                    : (count / maxCount).clamp(0.12, 1.0);
                final isHighlight = count == maxCount && count > 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.of(
                              context,
                              AppColors.textSecondary,
                              AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 96 * factor + 12,
                          decoration: BoxDecoration(
                            color: isHighlight
                                ? AppColors.warning
                                : AppColors.success.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          labels[index],
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.of(
                              context,
                              AppColors.textSecondary,
                              AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
