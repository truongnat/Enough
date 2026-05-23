import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/stop_receipt.dart';
import '../controllers/receipts_controller.dart';

class ReceiptsScreen extends ConsumerStatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  ConsumerState<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends ConsumerState<ReceiptsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptsControllerProvider);
    final notifier = ref.read(receiptsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(Copywriting.historyLabel)),
      body: Column(
        children: [
          _buildFilterChips(state, notifier),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredReceipts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: AppColors.of(
                            context,
                            AppColors.textTertiary,
                            AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          Copywriting.emptyHistory,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : _buildReceiptsList(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ReceiptsState state, ReceiptsController notifier) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', Copywriting.filterAll, notifier),
            const SizedBox(width: 8.0),
            _buildFilterChip('success', Copywriting.filterSuccess, notifier),
            const SizedBox(width: 8.0),
            _buildFilterChip('snooze', Copywriting.filterSnooze, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    ReceiptsController notifier,
  ) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        notifier.filterByStatus(value);
      },
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.of(
        context,
        AppColors.background,
        AppColors.lightBackground,
      ),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected
            ? AppColors.of(
                context,
                AppColors.background,
                AppColors.lightBackground,
              )
            : AppColors.of(
                context,
                AppColors.textPrimary,
                AppColors.lightTextPrimary,
              ),
      ),
      backgroundColor: AppColors.of(
        context,
        AppColors.cardBgElevated,
        AppColors.lightCardBgElevated,
      ),
    );
  }

  Widget _buildReceiptsList(ReceiptsState state, ReceiptsController notifier) {
    final groupedReceipts = _groupReceiptsByDate(state.filteredReceipts);

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groupedReceipts.length,
      itemBuilder: (context, index) {
        final group = groupedReceipts[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group['date'],
              style: AppTextStyles.labelSecondary(
                AppColors.of(
                  context,
                  AppColors.textSecondary,
                  AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            ...group['receipts'].map<Widget>(
              (receipt) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildReceiptCard(receipt, notifier),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        );
      },
    );
  }

  Widget _buildReceiptCard(StopReceipt receipt, ReceiptsController notifier) {
    return AppCard(
      onTap: () => context.push('/receipt/${receipt.id}'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Icon(Icons.check_circle, color: AppColors.success),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt.stopType.displayName,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 8.0),
                Text(
                  _formatTime(receipt.completedAt),
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
          Icon(
            Icons.chevron_right,
            color: AppColors.of(
              context,
              AppColors.textTertiary,
              AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupReceiptsByDate(List<StopReceipt> receipts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayReceipts = <StopReceipt>[];
    final yesterdayReceipts = <StopReceipt>[];
    final olderReceipts = <StopReceipt>[];

    for (final receipt in receipts) {
      final receiptDate = DateTime(
        receipt.completedAt.year,
        receipt.completedAt.month,
        receipt.completedAt.day,
      );

      if (receiptDate == today) {
        todayReceipts.add(receipt);
      } else if (receiptDate == yesterday) {
        yesterdayReceipts.add(receipt);
      } else {
        olderReceipts.add(receipt);
      }
    }

    final groups = <Map<String, dynamic>>[];

    if (todayReceipts.isNotEmpty) {
      groups.add({
        'date': Copywriting.todayLabelHistory,
        'receipts': todayReceipts,
      });
    }

    if (yesterdayReceipts.isNotEmpty) {
      groups.add({
        'date': Copywriting.yesterdayLabel,
        'receipts': yesterdayReceipts,
      });
    }

    if (olderReceipts.isNotEmpty) {
      groups.add({'date': Copywriting.olderLabel, 'receipts': olderReceipts});
    }

    return groups;
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
