import 'package:flutter/material.dart';
import '../../features/receipts/domain/entities/stop_receipt.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ReceiptWidget extends StatelessWidget {
  final StopReceipt receipt;
  final VoidCallback? onDelete;

  const ReceiptWidget({
    super.key,
    required this.receipt,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Receipt header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BIÊN LAI DỪNG',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.textTertiary,
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppConstants.paddingS),
          
          // Receipt content
          _buildRow('Loại', receipt.title),
          const SizedBox(height: AppConstants.paddingXS),
          _buildRow('Ngày', _formatDate(receipt.completedAt)),
          const SizedBox(height: AppConstants.paddingXS),
          _buildRow('Thời gian', _formatTimeRange(receipt.startedAt, receipt.completedAt)),
          const SizedBox(height: AppConstants.paddingM),
          
          // Saved from
          Text(
            'Đã cứu bạn khỏi:',
            style: AppTextStyles.labelSmall,
          ),
          const SizedBox(height: AppConstants.paddingXS),
          ...receipt.savedFromMessages.map((msg) => Padding(
                padding: const EdgeInsets.only(left: AppConstants.paddingS, bottom: AppConstants.paddingXS),
                child: Text(
                  '• $msg',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )),
          const SizedBox(height: AppConstants.paddingM),
          
          // Result
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.success),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  receipt.resultMessage,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }
}
