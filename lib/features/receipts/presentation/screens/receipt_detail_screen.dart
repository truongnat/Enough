import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
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
        backgroundColor: AppColors.of(
          context,
          AppColors.cardBg,
          AppColors.lightCardBg,
        ),
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
