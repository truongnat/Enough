import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/alarm_controller.dart';
import 'alarm_form.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_components.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class CreateAlarmScreen extends ConsumerStatefulWidget {
  const CreateAlarmScreen({super.key});

  @override
  ConsumerState<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends ConsumerState<CreateAlarmScreen> {
  late final TextEditingController _customLabelController;

  @override
  void initState() {
    super.initState();
    _customLabelController = TextEditingController();
    // Reset state to initial for create
    Future.microtask(() {
      ref.read(alarmControllerProvider.notifier).resetState();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: 'Tạo Alarm'),
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
