import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/product_components.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/alarm/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: AppConstants.paddingXL),
              if (homeState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView(
                    children: [
                      _buildNextAlarmCard(homeState),
                      const SizedBox(height: AppConstants.paddingL),
                      _buildTodayCard(homeState),
                      const SizedBox(height: AppConstants.paddingL),
                      _buildLatestReceiptCard(homeState),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = Copywriting.getGreeting(hour);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: AppConstants.paddingXS),
        Text(
          Copywriting.sloganLabel,
          style: AppTextStyles.bodySecondary(AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildNextAlarmCard(HomeState state) {
    final alarm = state.nextAlarm;
    
    if (alarm == null) {
      return AppSurfaceCard(
        child: EmptyState(
          message: Copywriting.noAlarmLabel,
          actionLabel: Copywriting.createFirstAlarm,
          onAction: () => context.push('/alarm/create'),
          icon: Icons.alarm_off,
        ),
      );
    }

    final now = DateTime.now();
    final nextTrigger = alarm.getNextTrigger(now);
    final timeUntil = nextTrigger.difference(now);
    
    String timeLabel;
    if (timeUntil.inHours > 0) {
      timeLabel = '${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m';
    } else {
      timeLabel = '${timeUntil.inMinutes}m';
    }

    return AppSurfaceCard(
      onTap: () => context.push('/alarm/edit/${alarm.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.nextAlarmLabel,
            style: AppTextStyles.labelSecondary(AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            alarm.formattedTime,
            style: AppTextStyles.alarmTime,
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            alarm.stopType.displayName,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppConstants.paddingXS),
              Text(
                'Còn $timeLabel',
                style: AppTextStyles.bodySecondary(AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(HomeState state) {
    return AppSurfaceCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Copywriting.todayLabel,
                style: AppTextStyles.labelSecondary(AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.paddingXS),
              Text(
                '${state.stoppedCount} ${Copywriting.timesLabel}',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestReceiptCard(HomeState state) {
    final receipt = state.latestReceipt;
    
    if (receipt == null) {
      return AppSurfaceCard(
        child: EmptyState(
          message: Copywriting.noReceiptLabel,
          icon: Icons.receipt_long,
        ),
      );
    }

    return AppSurfaceCard(
      onTap: () => context.push('/receipt/${receipt.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.latestReceiptLabel,
            style: AppTextStyles.labelSecondary(AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            receipt.stopType.displayName,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            _formatTime(receipt.completedAt),
            style: AppTextStyles.bodySecondary(AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
