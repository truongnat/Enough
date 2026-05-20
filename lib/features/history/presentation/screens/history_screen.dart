import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
import '../../../stop_session/domain/entities/stop_session.dart';
import '../../../stop_session/domain/entities/stop_session_status.dart';
import '../controllers/history_controller.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyControllerProvider);
    final notifier = ref.read(historyControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: Copywriting.historyLabel,
              leading: const SizedBox.shrink(), // No leading back button on main tab
            ),
            _buildFilterChips(state, notifier),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.filteredSessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.history,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                Copywriting.emptyHistory,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: state.filteredSessions.length,
                          itemBuilder: (context, index) {
                            final session = state.filteredSessions[index];
                            return _buildSessionCard(session, state.receipts);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(HistoryState state, HistoryController notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Wrap(
        spacing: 8.0,
        children: ['all', 'success', 'snooze', 'missed'].map((filter) {
          final isSelected = state.selectedFilter == filter;
          return FilterChip(
            label: Text(filter.toUpperCase()),
            selected: isSelected,
            onSelected: (_) => notifier.setFilter(filter),
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            checkmarkColor: AppColors.primary,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionCard(StopSession session, List receipts) {
    final dynamic matchingReceipt = receipts.firstWhere(
      (dynamic r) => r.sessionId == session.id,
      orElse: () => null,
    );
    final hasReceipt = matchingReceipt != null;
    final statusColor = _getStatusColor(session.status);
    final statusText = _getStatusText(session.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppSurfaceCard(
        onTap: hasReceipt
            ? () => context.push('/receipt/${matchingReceipt.id}')
            : null,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                _getStatusIcon(session.status),
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.stopType.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    DateFormat('dd/MM/yyyy - HH:mm').format(session.startedAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    statusText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (hasReceipt)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
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
        return 'Completed';
      case StopSessionStatus.snoozed:
        return 'Snoozed';
      case StopSessionStatus.missed:
        return 'Missed';
      case StopSessionStatus.active:
        return 'Active';
    }
  }

  IconData _getStatusIcon(StopSessionStatus status) {
    switch (status) {
      case StopSessionStatus.completed:
        return Icons.check_circle;
      case StopSessionStatus.snoozed:
        return Icons.snooze;
      case StopSessionStatus.missed:
        return Icons.cancel;
      case StopSessionStatus.active:
        return Icons.play_circle;
    }
  }
}
