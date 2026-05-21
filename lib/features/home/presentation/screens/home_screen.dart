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
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: AppConstants.paddingL),
              if (homeState.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildNextAlarmCard(homeState),
                      const SizedBox(height: AppConstants.paddingL),
                      _buildAllAlarmsSection(homeState),
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

  Widget _buildAllAlarmsSection(HomeState state) {
    final alarms = state.alarms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: 'TẤT CẢ BÁO THỨC'),
        const SizedBox(height: 8.0),
        if (alarms.isEmpty)
          AppSurfaceCard(
            child: EmptyState(
              message: 'Chưa có báo thức nào được tạo.',
              actionLabel: 'Tạo báo thức đầu tiên',
              onAction: () => context.push('/alarm/create'),
              icon: Icons.alarm_add_outlined,
            ),
          )
        else
          ...alarms.map((alarm) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AppSurfaceCard(
                onTap: () => context.push('/alarm/edit/${alarm.id}'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            children: [
                              Text(
                                alarm.formattedTime,
                                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                _getRepeatSummary(alarm.repeatDays),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            alarm.stopType.displayName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: alarm.isEnabled
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.cardBgElevated,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: alarm.isEnabled ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        alarm.isEnabled ? 'BẬT' : 'TẮT',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: alarm.isEnabled ? AppColors.primary : AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  String _getRepeatSummary(List<dynamic> repeatDays) {
    if (repeatDays.isEmpty) return 'Một lần';
    if (repeatDays.length == 7) return 'Hàng ngày';
    
    // Check if it's weekdays (Monday to Friday)
    final isoValues = repeatDays.map((d) => d.isoValue as int).toList()..sort();
    if (isoValues.length == 5 &&
        isoValues[0] == 1 &&
        isoValues[1] == 2 &&
        isoValues[2] == 3 &&
        isoValues[3] == 4 &&
        isoValues[4] == 5) {
      return 'Ngày thường';
    }

    // Check if it's weekend (Saturday and Sunday)
    if (isoValues.length == 2 && isoValues[0] == 6 && isoValues[1] == 7) {
      return 'Cuối tuần';
    }

    // Otherwise show short names comma separated
    final List<String> shorts = repeatDays.map((d) => d.shortName as String).toList();
    return shorts.join(', ');
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
