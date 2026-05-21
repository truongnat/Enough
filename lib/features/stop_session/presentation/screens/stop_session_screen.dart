import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
import '../../../alarms/domain/entities/stop_mode.dart';
import '../../../stop_session/domain/entities/stop_session_status.dart';
import '../controllers/stop_session_controller.dart';
import '../../../../app/router/app_router.dart';

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
      ref.read(stopSessionControllerProvider.notifier).loadSession(widget.alarmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stopSessionControllerProvider);
    final notifier = ref.read(stopSessionControllerProvider.notifier);
    final router = ref.watch(routerProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${state.error}'),
        ),
      );
    }

    if (state.isCompleted) {
      return _buildCompletionScreen(state, router);
    }

    if (state.isSnoozed) {
      return _buildSnoozeScreen(state, router);
    }

    return PopScope(
      canPop: state.session?.status != StopSessionStatus.active,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && state.session?.status == StopSessionStatus.active) {
          _showExitConfirmDialog(router);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              AppPageHeader(
                title: 'Phiên dừng',
                leading: AppIconButton(
                  icon: Icons.close,
                  onTap: () {
                    if (state.session?.status == StopSessionStatus.active) {
                      _showExitConfirmDialog(router);
                    } else {
                      router.go('/');
                    }
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(state),
                      const SizedBox(height: 16.0),
                      _buildMessage(state),
                      const SizedBox(height: 24.0),
                      _buildProtocolChecklist(state, notifier),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildActionButtons(state, notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(StopSessionState state) {
    final stopType = state.session?.stopType ?? state.alarm?.stopType;
    if (stopType == null) return const SizedBox.shrink();
    
    return Text(
      Copywriting.getStopSessionTitle(stopType.displayName.toUpperCase()),
      style: AppTextStyles.stopTitle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(StopSessionState state) {
    final mode = state.alarm?.mode ?? StopMode.gentle;
    final message = Copywriting.getStopSessionMessage(mode.name);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBgElevated,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProtocolChecklist(StopSessionState state, StopSessionController notifier) {
    final protocol = state.protocol;
    final session = state.session;
    if (protocol == null || session == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.protocolLabel,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 12.0),
          ...protocol.steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isChecked = session.checkedStepIndexes.contains(index);
            
            return InkWell(
              onTap: () => notifier.toggleStep(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isChecked ? AppColors.success : AppColors.cardBgElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isChecked ? AppColors.success : AppColors.border,
                        ),
                      ),
                      child: isChecked
                          ? const Icon(Icons.check, size: 16, color: AppColors.background)
                          : null,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        step,
                        style: AppTextStyles.bodyMedium.copyWith(
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? AppColors.textTertiary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(StopSessionState state, StopSessionController notifier) {
    final session = state.session;
    final canComplete = session?.canComplete ?? false;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canComplete ? () => notifier.completeSession() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canComplete ? AppColors.success : AppColors.cardBgElevated,
              foregroundColor: canComplete ? AppColors.background : AppColors.textTertiary,
            ),
            child: Text(Copywriting.completeButton),
          ),
        ),
        const SizedBox(height: 12.0),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => notifier.snoozeSession(),
            child: Text(Copywriting.snoozeButton),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen(StopSessionState state, GoRouter router) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Đã dừng',
              leading: AppIconButton(
                icon: Icons.close,
                onTap: () => router.go('/'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 100,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'ĐÃ DỪNG THÀNH CÔNG!',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      Copywriting.getStopSessionMessage(StopMode.gentle.name),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),
                    AppPrimaryButton(
                      label: Copywriting.back,
                      onTap: () => router.go('/'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeScreen(StopSessionState state, GoRouter router) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Đã hoãn',
              leading: AppIconButton(
                icon: Icons.close,
                onTap: () => router.go('/'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 100,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      'ĐÃ HOÃN',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      Copywriting.snoozeWarning,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),
                    AppPrimaryButton(
                      label: Copywriting.back,
                      onTap: () => router.go('/'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmDialog(GoRouter router) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thoát phiên dừng?'),
        content: const Text('Bạn chưa hoàn thành protocol. Phiên này sẽ vẫn được lưu để xử lý sau.'),
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
}
