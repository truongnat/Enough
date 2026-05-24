import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
import '../../../receipts/domain/entities/stop_receipt.dart';
import '../../../stop_session/domain/entities/stop_session.dart';
import '../../../stop_session/domain/entities/stop_session_status.dart';
import '../controllers/history_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final notifier = ref.read(historyControllerProvider.notifier);
    final horizontalPadding = Responsive.horizontalPadding(context);
    final compact = Responsive.compactMode(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppGradientBackground(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              const AppPageHeader(
                title: 'Lịch sử',
                leading: SizedBox(width: 44, height: 44),
              ),
              Padding(
                padding: EdgeInsets.only(top: 6, bottom: compact ? 12 : 14),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Tất cả',
                        selected: state.selectedFilter == 'all',
                        onTap: () => notifier.setFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Thành công',
                        selected: state.selectedFilter == 'success',
                        onTap: () => notifier.setFilter('success'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Snooze',
                        selected: state.selectedFilter == 'snooze',
                        onTap: () => notifier.setFilter('snooze'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.filteredSessions.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có lịch sử nào để kể.',
                          textAlign: TextAlign.center,
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
                        padding: const EdgeInsets.only(bottom: 120),
                        children: [
                          ..._buildGroupedSections(
                            context,
                            state.filteredSessions,
                            state.receipts,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedSections(
    BuildContext context,
    List<StopSession> sessions,
    List<StopReceipt> receipts,
  ) {
    final today = <StopSession>[];
    final yesterday = <StopSession>[];
    final earlier = <StopSession>[];
    final now = DateTime.now();
    final startToday = DateTime(now.year, now.month, now.day);
    final startYesterday = startToday.subtract(const Duration(days: 1));

    for (final session in sessions) {
      final date = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );
      if (date == startToday) {
        today.add(session);
      } else if (date == startYesterday) {
        yesterday.add(session);
      } else {
        earlier.add(session);
      }
    }

    final sections = <Widget>[];
    if (today.isNotEmpty) {
      sections
        ..add(_sectionLabel(context, 'Hôm nay'))
        ..add(_groupCard(context, today, receipts));
    }
    if (yesterday.isNotEmpty) {
      sections
        ..add(const SizedBox(height: 16))
        ..add(_sectionLabel(context, 'Hôm qua'))
        ..add(_groupCard(context, yesterday, receipts));
    }
    if (earlier.isNotEmpty) {
      sections
        ..add(const SizedBox(height: 16))
        ..add(_sectionLabel(context, 'Gần đây'))
        ..add(_groupCard(context, earlier, receipts));
    }
    return sections;
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.of(
            context,
            AppColors.textSecondary,
            AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _groupCard(
    BuildContext context,
    List<StopSession> sessions,
    List<StopReceipt> receipts,
  ) {
    return AppGlassCard(
      child: Column(
        children: sessions.map((session) {
          final receipt = _findReceiptForSession(session, receipts);
          final statusColor = _getStatusColor(session.status);
          final time =
              '${session.startedAt.hour.toString().padLeft(2, '0')}:${session.startedAt.minute.toString().padLeft(2, '0')}';
          final statusText = _getStatusText(session.status);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: receipt == null
                  ? null
                  : () => context.push('/receipt/${receipt.id}'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.of(
                            context,
                            AppColors.textSecondary,
                            AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        session.stopType.displayName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: session.status == StopSessionStatus.completed
                              ? AppColors.primary
                              : AppColors.of(
                                  context,
                                  AppColors.textPrimary,
                                  AppColors.lightTextPrimary,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (session.status == StopSessionStatus.completed)
                      Icon(Icons.check_rounded, color: statusColor)
                    else
                      Text(
                        statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: statusColor,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  StopReceipt? _findReceiptForSession(
    StopSession session,
    List<StopReceipt> receipts,
  ) {
    for (final receipt in receipts) {
      if (receipt.sessionId == session.id) return receipt;
    }
    return null;
  }

  Color _getStatusColor(StopSessionStatus status) {
    switch (status) {
      case StopSessionStatus.completed:
        return AppColors.success;
      case StopSessionStatus.snoozed:
        return AppColors.warning;
      case StopSessionStatus.missed:
        return AppColors.error;
      case StopSessionStatus.active:
        return AppColors.primary;
    }
  }

  String _getStatusText(StopSessionStatus status) {
    switch (status) {
      case StopSessionStatus.completed:
        return 'Thành công';
      case StopSessionStatus.snoozed:
        return 'Snooze';
      case StopSessionStatus.missed:
        return 'Missed';
      case StopSessionStatus.active:
        return 'Active';
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSegmentedChip(label: label, isSelected: selected, onTap: onTap);
  }
}
