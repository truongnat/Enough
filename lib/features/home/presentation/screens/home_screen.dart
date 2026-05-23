import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
import '../../../alarms/domain/entities/repeat_day.dart';
import '../../../alarms/domain/entities/stop_alarm.dart';
import '../../../alarms/domain/entities/stop_type.dart';
import '../../../stop_session/domain/entities/stop_session.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final alarms = homeState.alarms;
    final hasAlarms = alarms.isNotEmpty;
    final horizontalPadding = Responsive.horizontalPadding(context);
    final sectionSpacing = Responsive.sectionSpacing(context);
    final compact = Responsive.compactMode(context);
    final bottomPadding = 120.0 + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppGradientBackground(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SafeArea(
          bottom: false,
          child: homeState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: compact ? 10 : 12,
                        bottom: bottomPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildTopBar(context, ref),
                          SizedBox(height: compact ? 14 : 18),
                          _buildHeadline(context),
                          SizedBox(height: sectionSpacing),
                          if (hasAlarms) ...[
                            if (homeState.nextAlarm != null)
                              _buildNextAlarmHero(context, homeState),
                            SizedBox(height: compact ? 16 : 18),
                            _buildTodayCard(context, homeState),
                            SizedBox(height: compact ? 16 : 18),
                            _buildLatestReceiptCard(context, homeState),
                            SizedBox(height: compact ? 18 : 20),
                            _buildAllAlarmsSection(context, alarms),
                          ] else ...[
                            _buildEmptyOnboardingCard(context),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
    final greeting = _greetingForHour(DateTime.now().hour);
    final settingsState = ref.watch(settingsControllerProvider);
    final userName = settingsState.settings?.userName;
    final displayName = userName?.isNotEmpty == true ? userName : null;
    final themeMode = settingsState.settings?.themeMode ?? ThemeMode.system;

    return Row(
      children: [
        Expanded(
          child: Text(
            displayName != null ? '$greeting, $displayName 👋' : '$greeting 👋',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.of(
                context,
                AppColors.textSecondary,
                AppColors.lightTextSecondary,
              ),
            ),
          ),
        ),
        AppRoundIconButton(
          icon: _getThemeIcon(themeMode),
          onTap: () {
            final newMode = _getNextThemeMode(themeMode);
            ref.read(settingsControllerProvider.notifier).setThemeMode(newMode);
          },
          backgroundColor: AppColors.of(
            context,
            AppColors.cardBgGlass,
            AppColors.lightCardBgGlass,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Text(
      'Hôm nay bạn muốn dừng điều gì?',
      maxLines: compact ? 3 : 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.h1.copyWith(
        fontSize: compact ? 32 : AppTextStyles.h1.fontSize,
        color: AppColors.of(
          context,
          AppColors.textPrimary,
          AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildNextAlarmHero(BuildContext context, HomeState state) {
    final alarm = state.nextAlarm!;
    final nextTrigger = alarm.getNextTrigger(DateTime.now());
    final timeLabel = _formatCountdown(nextTrigger.difference(DateTime.now()));
    final compact = Responsive.compactMode(context);

    return AppHeroCard(
      label: 'Tiếp theo',
      title: alarm.stopType.subtitle,
      emphasis: alarm.stopType.displayName.toUpperCase(),
      value: alarm.formattedTime,
      supporting: 'Còn $timeLabel',
      icon: _stopTypeIcon(alarm.stopType),
      onTap: () => context.push('/alarm/edit/${alarm.id}'),
      trailing: compact
          ? null
          : Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _stopTypeIcon(alarm.stopType),
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyOnboardingCard(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return AppGlassCard(
      borderRadius: BorderRadius.circular(30),
      padding: EdgeInsets.all(compact ? 24 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 100 : 120,
            height: compact ? 100 : 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.alarm_add_rounded,
              size: compact ? 48 : 56,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: compact ? 20 : 24),
          Text(
            'Bắt đầu hành trình dừng thói quen',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.of(
                context,
                AppColors.textPrimary,
                AppColors.lightTextPrimary,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: compact ? 8 : 12),
          Text(
            'Tạo Stop Alarm đầu tiên để bắt đầu theo dõi và cải thiện thói quen của bạn.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.of(
                context,
                AppColors.textSecondary,
                AppColors.lightTextSecondary,
              ),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compact ? 20 : 24),
          AppPrimaryButton(
            label: 'Tạo Stop Alarm',
            onTap: () => context.push('/alarm/create'),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(BuildContext context, HomeState state) {
    final protectedMinutes = state.stoppedCount * 130;
    final protectedHours = protectedMinutes ~/ 60;
    final remainingMinutes = protectedMinutes % 60;
    final compact = Responsive.compactMode(context);
    final visibleSessions = state.safeTodaySessions.take(3).toList();

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã dừng hôm nay',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.of(
                          context,
                          AppColors.textSecondary,
                          AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${state.stoppedCount} lần',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: compact ? 34 : 42,
                        color: AppColors.of(
                          context,
                          AppColors.textPrimary,
                          AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bạn đã bảo vệ được ${protectedHours}h ${remainingMinutes.toString().padLeft(2, '0')}m năng lượng quý giá ✨',
                      maxLines: compact ? 3 : 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
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
              SizedBox(width: compact ? 12 : 16),
              Container(
                width: compact ? 68 : 82,
                height: compact ? 68 : 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySoft,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.warning,
                  size: 34,
                ),
              ),
            ],
          ),
          if (visibleSessions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: AppColors.of(
                context,
                AppColors.divider,
                AppColors.lightDivider,
              ),
            ),
            const SizedBox(height: 12),
            ...visibleSessions.map(
              (session) => _buildSessionItem(context, session, compact),
            ),
            if (state.safeTodaySessions.length > 3) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.go('/history'),
                child: Text(
                  'Xem tất cả (${state.safeTodaySessions.length})',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    StopSession session,
    bool compact,
  ) {
    final time =
        '${session.startedAt.hour.toString().padLeft(2, '0')}:${session.startedAt.minute.toString().padLeft(2, '0')}';
    final icon = _stopTypeIcon(session.stopType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.stopType.displayName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.bodySmall.copyWith(
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
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
        ],
      ),
    );
  }

  Widget _buildLatestReceiptCard(BuildContext context, HomeState state) {
    final receipt = state.latestReceipt;
    final compact = Responsive.compactMode(context);
    if (receipt == null) {
      return AppGlassCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.of(
                  context,
                  AppColors.cardBgElevated,
                  AppColors.lightCardBgElevated,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: AppColors.of(
                  context,
                  AppColors.textSecondary,
                  AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stop Receipt mới nhất',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.of(
                        context,
                        AppColors.textSecondary,
                        AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chưa có biên lai nào được tạo.',
                    maxLines: compact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.of(
                        context,
                        AppColors.textPrimary,
                        AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AppGlassCard(
      onTap: () => context.push('/receipt/${receipt.id}'),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _stopTypeIcon(receipt.stopType),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stop Receipt mới nhất',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.of(
                      context,
                      AppColors.textSecondary,
                      AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  receipt.stopType.displayName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(receipt.completedAt),
                  style: AppTextStyles.bodyMedium.copyWith(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(receipt.startedAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.of(
                    context,
                    AppColors.textTertiary,
                    AppColors.lightTextTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const AppPill(
                label: 'Thành công',
                color: AppColors.success,
                filled: true,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllAlarmsSection(BuildContext context, List<StopAlarm> alarms) {
    final visibleAlarms = alarms.take(3).toList();
    final compact = Responsive.compactMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionLabel(
          title: 'ALL STOP ALARMS',
          trailing: alarms.length > 3
              ? 'Xem thêm (${alarms.length - 3})'
              : null,
        ),
        const SizedBox(height: 12),
        ...visibleAlarms.map(
          (alarm) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppGlassCard(
              onTap: () => context.push('/alarm/edit/${alarm.id}'),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 14 : 16,
                vertical: compact ? 12 : 14,
              ),
              borderRadius: BorderRadius.circular(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 42 : 48,
                    height: compact ? 42 : 48,
                    decoration: BoxDecoration(
                      color: alarm.isEnabled
                          ? AppColors.primarySoft
                          : AppColors.of(
                              context,
                              AppColors.cardBgElevated,
                              AppColors.lightCardBgElevated,
                            ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _stopTypeIcon(alarm.stopType),
                      color: alarm.isEnabled
                          ? AppColors.primary
                          : AppColors.of(
                              context,
                              AppColors.textSecondary,
                              AppColors.lightTextSecondary,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                alarm.formattedTime,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h4.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact
                                      ? 18
                                      : AppTextStyles.h4.fontSize,
                                  color: AppColors.of(
                                    context,
                                    AppColors.textPrimary,
                                    AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getRepeatSummary(alarm.repeatDays),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.of(
                                    context,
                                    AppColors.textSecondary,
                                    AppColors.lightTextSecondary,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alarm.stopType.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.of(
                              context,
                              AppColors.textPrimary,
                              AppColors.lightTextPrimary,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppPill(
                    label: alarm.isEnabled ? 'BẬT' : 'TẮT',
                    color: alarm.isEnabled
                        ? AppColors.primary
                        : AppColors.of(
                            context,
                            AppColors.textTertiary,
                            AppColors.lightTextTertiary,
                          ),
                    filled: alarm.isEnabled,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCountdown(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} giờ ${duration.inMinutes % 60} phút';
    }
    return '${duration.inMinutes} phút';
  }

  String _getRepeatSummary(List<RepeatDay> repeatDays) {
    if (repeatDays.isEmpty) return 'Một lần';
    if (repeatDays.length == 7) return 'Hàng ngày';

    final isoValues = repeatDays.map((d) => d.isoValue).toList()..sort();
    if (isoValues.length == 5 &&
        isoValues[0] == 1 &&
        isoValues[1] == 2 &&
        isoValues[2] == 3 &&
        isoValues[3] == 4 &&
        isoValues[4] == 5) {
      return 'Ngày thường';
    }

    if (isoValues.length == 2 && isoValues[0] == 6 && isoValues[1] == 7) {
      return 'Cuối tuần';
    }

    return repeatDays.map((d) => d.shortName).join(', ');
  }

  String _greetingForHour(int hour) {
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  ThemeMode _getNextThemeMode(ThemeMode current) {
    switch (current) {
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
      case ThemeMode.system:
        return ThemeMode.light;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _stopTypeIcon(StopType type) {
    switch (type) {
      case StopType.coding:
        return Icons.laptop_mac_rounded;
      case StopType.working:
        return Icons.work_outline_rounded;
      case StopType.scrolling:
        return Icons.phone_android_rounded;
      case StopType.overthinking:
        return Icons.psychology_alt_outlined;
      case StopType.sleep:
        return Icons.dark_mode_outlined;
      case StopType.custom:
        return Icons.auto_awesome_outlined;
    }
  }
}
