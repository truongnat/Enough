import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(
              title: 'Thống kê',
              leading: SizedBox.shrink(), // No back button on main tab
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.weeklyStats == null
                      ? const Center(child: Text('No data available', style: TextStyle(color: AppColors.textSecondary)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(AppConstants.paddingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWeeklySummary(state),
                              const SizedBox(height: AppConstants.paddingL),
                              const AppSectionTitle(title: 'TỔNG QUAN TUẦN NÀY'),
                              const SizedBox(height: 8.0),
                              _buildStatsChart(state),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(StatsState state) {
    final stats = state.weeklyStats!;
    return Row(
      children: [
        Expanded(
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tổng phiên dừng',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${stats.totalStoppedCount}',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thời gian bảo vệ',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${stats.totalProtectedTimeMinutes} m',
                  style: AppTextStyles.h2.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsChart(StatsState state) {
    final stats = state.weeklyStats!;
    // Map day index logically (1 = T2, 2 = T3...)
    final List<String> dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân bố tần suất dừng',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          ...List.generate(7, (index) {
            final dayNum = index + 1;
            final count = stats.dailyStoppedCounts[dayNum] ?? 0;
            final percentage = stats.totalStoppedCount == 0 ? 0.0 : count / stats.totalStoppedCount;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(dayNames[index], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.cardBgElevated,
                        color: AppColors.primary,
                        minHeight: 8.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text('$count', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
