import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
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
    final currentIndex = ValueNotifier<int>(0);

    return Scaffold(
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
      bottomNavigationBar: _buildBottomNavigationBar(currentIndex),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
      return AppCard(
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

    return AppCard(
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
    return AppCard(
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
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
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
      return AppCard(
        child: EmptyState(
          message: Copywriting.noReceiptLabel,
          icon: Icons.receipt_long,
        ),
      );
    }

    return AppCard(
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

  Widget _buildBottomNavigationBar(ValueNotifier<int> currentIndex) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: (index) {
          currentIndex.value = index;
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/history');
              break;
            case 3:
              context.go('/stats');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => context.push('/alarm/create'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add,
          size: 32,
          color: AppColors.background,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
