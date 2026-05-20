import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/receipt_widget.dart';
import '../controllers/receipts_controller.dart';
import '../../../../app/router/app_router.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final String receiptId;

  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(receiptsControllerProvider);
    final notifier = ref.read(receiptsControllerProvider.notifier);
    final router = ref.watch(routerProvider);

    final receipt = state.receipts.firstWhere(
      (r) => r.id == receiptId,
      orElse: () => throw Exception('Receipt not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biên lai'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ReceiptWidget(
                receipt: receipt,
                onDelete: () => _showDeleteDialog(context, notifier, receipt.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ReceiptsController notifier, String receiptId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa biên lai'),
        content: const Text('Bạn có chắc muốn xóa biên lai này?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Hủy'),
          ),
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
