import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
import '../../../../services/alarm_runtime/alarm_runtime_controller.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../receipts/presentation/controllers/receipts_controller.dart';
import '../../../alarms/domain/entities/stop_mode.dart';
import '../../../alarms/domain/entities/stop_type.dart';
import '../../../stop_session/domain/entities/stop_session_status.dart';
import '../controllers/stop_session_controller.dart';

class StopSessionScreen extends ConsumerStatefulWidget {
  final String? alarmId;

  const StopSessionScreen({super.key, this.alarmId});

  @override
  ConsumerState<StopSessionScreen> createState() => _StopSessionScreenState();
}

class _StopSessionScreenState extends ConsumerState<StopSessionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(alarmRuntimeControllerProvider.notifier)
          .dismissModal(stopRinging: true);
      ref
          .read(stopSessionControllerProvider.notifier)
          .loadSession(widget.alarmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stopSessionControllerProvider);
    final notifier = ref.read(stopSessionControllerProvider.notifier);
    final router = ref.watch(routerProvider);
    final horizontalPadding = Responsive.horizontalPadding(context);
    final compact = Responsive.compactMode(context);

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text('Error: ${state.error}', style: AppTextStyles.bodyLarge),
        ),
      );
    }

    if (state.isCompleted) {
      return _buildResultState(
        title: 'ĐÃ DỪNG THÀNH CÔNG!',
        message: 'Cơ thể vẫn là con người. Não vẫn còn đủ pin cho ngày mai.',
        icon: Icons.verified_rounded,
        iconColor: AppColors.success,
        actionLabel: 'Về trang chủ',
        onTap: () => _goHomeAndRefresh(router),
      );
    }

    if (state.isSnoozed) {
      return _buildResultState(
        title: 'ĐÃ HOÃN',
        message:
            'Mày vừa xin thêm thời gian. Hy vọng lần tới là lần cuối cùng.',
        icon: Icons.snooze_rounded,
        iconColor: AppColors.warning,
        actionLabel: 'Về trang chủ',
        onTap: () => _goHomeAndRefresh(router),
      );
    }

    return PopScope(
      canPop: state.session?.status != StopSessionStatus.active,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && state.session?.status == StopSessionStatus.active) {
          _showExitConfirmDialog(router);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AppGradientBackground(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: SafeArea(
            bottom: true,
            child: Column(
              children: [
                Row(
                  children: [
                    AppRoundIconButton(
                      icon: Icons.close_rounded,
                      onTap: () {
                        if (state.session?.status == StopSessionStatus.active) {
                          _showExitConfirmDialog(router);
                        } else {
                          router.go('/');
                        }
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: compact ? 10 : 18,
                      bottom: 24,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ĐẾN GIỜ DỪNG!',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _screenTitle(state).toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.stopTitle.copyWith(
                            fontSize: compact
                                ? 32
                                : AppTextStyles.stopTitle.fontSize,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: compact ? 14 : 18),
                        Center(
                          child: Container(
                            width: compact ? 180 : 220,
                            height: compact ? 160 : 220,
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
                                color: AppColors.of(
                                  context,
                                  AppColors.border,
                                  AppColors.lightBorder,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _stopTypeIcon(
                                  state.alarm?.stopType ?? StopType.custom,
                                ),
                                size: 80,
                                color: AppColors.primary.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 14 : 18),
                        AppGlassCard(
                          child: Text(
                            _quoteForState(state),
                            maxLines: compact ? 4 : 5,
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
                        SizedBox(height: compact ? 14 : 18),
                        _buildProtocolCard(context, state, notifier),
                        SizedBox(height: compact ? 18 : 22),
                        AppPrimaryButton(
                          label: 'Tôi đã dừng lại!',
                          onTap: state.session?.canComplete == true
                              ? () => notifier.completeSession()
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppSecondaryButton(
                          label: 'Cho tôi thêm 10 phút nữa...',
                          onTap: () => notifier.snoozeSession(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Đây là lần thứ ${state.session?.snoozeCount ?? 0} bạn snooze hôm nay.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.of(
                              context,
                              AppColors.textSecondary,
                              AppColors.lightTextSecondary,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProtocolCard(
    BuildContext context,
    StopSessionState state,
    StopSessionController notifier,
  ) {
    final protocol = state.protocol;
    final session = state.session;
    if (protocol == null || session == null) return const SizedBox.shrink();

    return AppGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Stop Coding Protocol',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${session.checkedStepIndexes.length} / ${protocol.steps.length}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.of(
                    context,
                    AppColors.textSecondary,
                    AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...protocol.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isChecked = session.checkedStepIndexes.contains(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => notifier.toggleStep(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.of(
                      context,
                      AppColors.cardBgElevated,
                      AppColors.lightCardBgElevated,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.of(
                        context,
                        AppColors.border,
                        AppColors.lightBorder,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isChecked
                              ? AppColors.success
                              : AppColors.of(
                                  context,
                                  AppColors.backgroundSecondary,
                                  AppColors.lightBackgroundSecondary,
                                ),
                          border: Border.all(
                            color: isChecked
                                ? AppColors.success
                                : AppColors.of(
                                    context,
                                    AppColors.border,
                                    AppColors.lightBorder,
                                  ),
                          ),
                        ),
                        child: isChecked
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isChecked
                                ? AppColors.of(
                                    context,
                                    AppColors.textTertiary,
                                    AppColors.lightTextTertiary,
                                  )
                                : AppColors.of(
                                    context,
                                    AppColors.textPrimary,
                                    AppColors.lightTextPrimary,
                                  ),
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultState({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    final horizontalPadding = Responsive.horizontalPadding(context);
    final compact = Responsive.compactMode(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppGradientBackground(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: Center(
                child: AppGlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: compact ? 60 : 72, color: iconColor),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        maxLines: compact ? 4 : 5,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.of(
                            context,
                            AppColors.textSecondary,
                            AppColors.lightTextSecondary,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppPrimaryButton(label: actionLabel, onTap: onTap),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _screenTitle(StopSessionState state) {
    final stopType = state.session?.stopType ?? state.alarm?.stopType;
    return stopType?.displayName ?? 'Stop';
  }

  String _quoteForState(StopSessionState state) {
    final mode = state.alarm?.mode ?? StopMode.general;
    return Copywriting.getStopSessionMessage(mode.name);
  }

  IconData _stopTypeIcon(StopType type) {
    switch (type) {
      case StopType.coding:
        return Icons.front_hand_outlined;
      case StopType.working:
        return Icons.work_off_outlined;
      case StopType.scrolling:
        return Icons.phone_disabled_outlined;
      case StopType.overthinking:
        return Icons.self_improvement_outlined;
      case StopType.sleep:
        return Icons.bedtime_outlined;
      case StopType.custom:
        return Icons.pause_circle_outline_rounded;
    }
  }

  void _showExitConfirmDialog(GoRouter router) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.of(
          context,
          AppColors.cardBg,
          AppColors.lightCardBg,
        ),
        title: const Text('Rời phiên dừng?'),
        content: const Text(
          'Nếu thoát bây giờ, bạn sẽ bỏ dở alarm moment này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              router.go('/');
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  Future<void> _goHomeAndRefresh(GoRouter router) async {
    await ref.read(homeControllerProvider.notifier).refresh();
    ref.read(historyControllerProvider.notifier).refresh();
    await ref.read(receiptsControllerProvider.notifier).loadReceipts();
    if (mounted) {
      router.go('/');
    }
  }
}
