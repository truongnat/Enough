import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/alarm_controller.dart';
import 'alarm_form.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_components.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class EditAlarmScreen extends ConsumerStatefulWidget {
  final String alarmId;

  const EditAlarmScreen({super.key, required this.alarmId});

  @override
  ConsumerState<EditAlarmScreen> createState() => _EditAlarmScreenState();
}

class _EditAlarmScreenState extends ConsumerState<EditAlarmScreen> {
  late final TextEditingController _customLabelController;

  @override
  void initState() {
    super.initState();
    _customLabelController = TextEditingController();
    Future.microtask(() {
      ref.read(alarmControllerProvider.notifier).loadAlarm(widget.alarmId);
    });
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alarmControllerProvider);
    final notifier = ref.read(alarmControllerProvider.notifier);
    final horizontalPadding = Responsive.horizontalPadding(context);
    final compact = Responsive.compactMode(context);

    // Sync state to controller text
    if (state.customTypeLabel != null &&
        _customLabelController.text != state.customTypeLabel) {
      _customLabelController.text = state.customTypeLabel!;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: AppGradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppPageHeader(
                title: 'Sửa Stop Alarm',
                actions: [
                  AppRoundIconButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardBg,
                          title: const Text('Xóa Alarm?'),
                          content: const Text(
                            'Bạn có chắc chắn muốn xóa báo thức này? Hành động này không thể hoàn tác.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await notifier.deleteAlarm(widget.alarmId);
                        if (context.mounted) {
                          await ref
                              .read(homeControllerProvider.notifier)
                              .refresh();
                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tinh chỉnh nhịp dừng cho đúng mood và đúng giờ.',
                    maxLines: compact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    140 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: AlarmForm(
                    state: state,
                    notifier: notifier,
                    customLabelController: _customLabelController,
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    compact ? 12 : 16,
                  ),
                  child: AppPrimaryButton(
                    label: 'Lưu thay đổi',
                    isLoading: state.isSaving,
                    icon: Icons.check_rounded,
                    onTap: state.isSaving
                        ? null
                        : () async {
                            final success = await notifier.saveAlarm();
                            if (success && context.mounted) {
                              await ref
                                  .read(homeControllerProvider.notifier)
                                  .refresh();
                              if (context.mounted) {
                                context.pop();
                              }
                            }
                          },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
