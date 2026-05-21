import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    // Sync state to controller text
    if (state.customTypeLabel != null && _customLabelController.text != state.customTypeLabel) {
      _customLabelController.text = state.customTypeLabel!;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Sửa Alarm',
              actions: [
                AppIconButton(
                  icon: Icons.delete_outline,
                  color: AppColors.error,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xóa Alarm?'),
                        content: const Text('Bạn có chắc chắn muốn xóa báo thức này? Hành động này không thể hoàn tác.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await notifier.deleteAlarm(widget.alarmId);
                      if (context.mounted) {
                        await ref.read(homeControllerProvider.notifier).refresh();
                        if (context.mounted) {
                          context.pop();
                        }
                      }
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AlarmForm(
                      state: state,
                      notifier: notifier,
                      customLabelController: _customLabelController,
                    ),
                    const SizedBox(height: 40.0),
                    if (state.error != null) ...[
                      Text(
                        state.error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    AppPrimaryButton(
                      label: 'LƯU ALARM',
                      isLoading: state.isSaving,
                      onTap: () async {
                        final success = await notifier.saveAlarm();
                        if (success && context.mounted) {
                          await ref.read(homeControllerProvider.notifier).refresh();
                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
