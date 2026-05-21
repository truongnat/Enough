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
    final horizontalPadding = Responsive.horizontalPadding(context);
    final compact = Responsive.compactMode(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: AppGradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const AppPageHeader(title: 'Tạo Stop Alarm'),
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
                    'Thiết kế alarm đủ đẹp để mày muốn quay lại chỉnh nó.',
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
                    label: 'Lưu Stop Alarm',
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
