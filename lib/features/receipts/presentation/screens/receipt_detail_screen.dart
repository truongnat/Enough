import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
import '../../../../core/widgets/receipt_widget.dart';
import '../controllers/receipts_controller.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final String receiptId;

  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(receiptsControllerProvider);
    final notifier = ref.read(receiptsControllerProvider.notifier);
    final horizontalPadding = Responsive.horizontalPadding(context);
    final compact = Responsive.compactMode(context);

    final receipt = state.receipts.firstWhere(
      (r) => r.id == receiptId,
      orElse: () => throw Exception('Receipt not found'),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppGradientBackground(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              AppPageHeader(
                title: 'Stop Receipt',
                actions: [
                  AppRoundIconButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    onTap: () =>
                        _showDeleteDialog(context, notifier, receipt.id),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: 12, bottom: compact ? 18 : 24),
                  child: Column(
                    children: [
                      const SizedBox(width: double.infinity),
                      ReceiptWidget(receipt: receipt),
                      const SizedBox(height: 18),
                      AppBottomActionBar(
                        children: [
                          _ActionItem(
                            icon: Icons.delete_outline_rounded,
                            label: 'Xóa',
                            onTap: () => _showDeleteDialog(
                              context,
                              notifier,
                              receipt.id,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ReceiptsController notifier,
    String receiptId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa biên lai'),
        content: const Text('Bạn có chắc muốn xóa biên lai này?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              notifier.deleteReceipt(receiptId);
              context.pop();
              context.pop();
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.of(
              context,
              AppColors.textPrimary,
              AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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
    );
  }
}
