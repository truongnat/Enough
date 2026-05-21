import 'package:flutter/material.dart';
import '../../features/receipts/domain/entities/stop_receipt.dart';
import '../responsive/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'product_components.dart';

class ReceiptWidget extends StatelessWidget {
  final StopReceipt receipt;
  final VoidCallback? onDelete;

  const ReceiptWidget({super.key, required this.receipt, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return AppReceiptPaper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'STOP RECEIPT',
              style: AppTextStyles.receiptTitle.copyWith(
                color: AppColors.paperText,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0x44201B16), thickness: 1, height: 1),
          const SizedBox(height: 18),
          _FieldRow(
            label: 'Đã dừng',
            value: receipt.stopType.displayName.toUpperCase(),
            accent: true,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              SizedBox(
                width: compact ? double.infinity : 140,
                child: _FieldRow(
                  label: 'Thời gian',
                  value: _formatTimeRange(
                    receipt.startedAt,
                    receipt.completedAt,
                  ),
                ),
              ),
              SizedBox(
                width: compact ? double.infinity : 120,
                child: _FieldRow(
                  label: 'Ngày',
                  value: _formatDate(receipt.completedAt),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0x33201B16), thickness: 1, height: 1),
          const SizedBox(height: 18),
          Text(
            'Bạn đã tránh được:',
            style: AppTextStyles.receiptBody.copyWith(
              color: AppColors.paperText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...receipt.savedFromMessages.map(
            (msg) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.sentiment_satisfied_alt,
                      color: AppColors.stamp,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      msg,
                      style: AppTextStyles.receiptBody.copyWith(
                        color: AppColors.paperText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0x33201B16), thickness: 1, height: 1),
          const SizedBox(height: 16),
          Text(
            'Kết quả:',
            style: AppTextStyles.receiptBody.copyWith(
              color: AppColors.paperText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 16,
            spacing: 16,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: compact
                      ? MediaQuery.sizeOf(context).width - 80
                      : 220,
                ),
                child: Text(
                  '${receipt.resultMessage} ✅',
                  style: AppTextStyles.receiptBody.copyWith(
                    color: AppColors.paperText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Transform.rotate(
                angle: -0.16,
                child: Container(
                  width: compact ? 72 : 88,
                  height: compact ? 72 : 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.stamp, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'GOOD\nJOB!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.stamp,
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 11 : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    final startStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _FieldRow({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.paperText.withValues(alpha: 0.72),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          softWrap: true,
          style: AppTextStyles.receiptBody.copyWith(
            color: accent ? AppColors.primaryDark : AppColors.paperText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
