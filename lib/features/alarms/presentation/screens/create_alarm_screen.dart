import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/stop_type.dart';
import '../../domain/entities/stop_mode.dart';
import '../../domain/entities/repeat_day.dart';
import '../../domain/entities/stop_protocol.dart';
import '../controllers/alarm_controller.dart';

class CreateAlarmScreen extends ConsumerStatefulWidget {
  const CreateAlarmScreen({super.key});

  @override
  ConsumerState<CreateAlarmScreen> createState() => _CreateAlarmScreenState();
}

class _CreateAlarmScreenState extends ConsumerState<CreateAlarmScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(alarmControllerProvider);
    final notifier = ref.read(alarmControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(Copywriting.createAlarmLabel),
        actions: [
          if (controller.isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStopTypeSelector(controller, notifier),
            const SizedBox(height: 16.0),
            _buildTimePicker(controller, notifier),
            const SizedBox(height: 16.0),
            _buildRepeatDaysSelector(controller, notifier),
            const SizedBox(height: 16.0),
            _buildModeSelector(controller, notifier),
            const SizedBox(height: 16.0),
            _buildProtocolSelector(controller, notifier),
            const SizedBox(height: 16.0),
            _buildCustomTypeField(controller, notifier),
            const SizedBox(height: 16.0),
            _buildEnabledToggle(controller, notifier),
            const SizedBox(height: 48.0),
            _buildSaveButton(controller, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildStopTypeSelector(AlarmState state, AlarmController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copywriting.stopTypeLabel,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: StopType.values.map((type) {
            final isSelected = state.stopType == type;
            return InkWell(
              onTap: () => notifier.setStopType(type),
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardBgElevated,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  type.displayName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.background : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimePicker(AlarmState state, AlarmController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copywriting.timeLabel,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.cardBgElevated,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeButton(state.hour, (hour) => notifier.setTime(hour, state.minute), 0, 23),
              Text(':', style: AppTextStyles.alarmTime),
              _buildTimeButton(state.minute, (minute) => notifier.setTime(state.hour, minute), 0, 59),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton(int value, Function(int) onChanged, int min, int max) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          color: AppColors.primary,
        ),
        Container(
          width: 80,
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: AppTextStyles.h2,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildRepeatDaysSelector(AlarmState state, AlarmController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copywriting.repeatDaysLabel,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 8.0,
          children: [
            _buildQuickChip('Hàng ngày', () {
              notifier.setRepeatDays(RepeatDay.values.toList());
            }),
            _buildQuickChip('Ngày thường', () {
              notifier.setRepeatDays([
                RepeatDay.monday,
                RepeatDay.tuesday,
                RepeatDay.wednesday,
                RepeatDay.thursday,
                RepeatDay.friday,
              ]);
            }),
            _buildQuickChip('Cuối tuần', () {
              notifier.setRepeatDays([
                RepeatDay.saturday,
                RepeatDay.sunday,
              ]);
            }),
            _buildQuickChip('Xóa', () {
              notifier.setRepeatDays([]);
            }),
          ],
        ),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: RepeatDay.values.map((day) {
            final isSelected = state.repeatDays.contains(day);
            return InkWell(
              onTap: () {
                final newDays = List<RepeatDay>.from(state.repeatDays);
                if (isSelected) {
                  newDays.remove(day);
                } else {
                  newDays.add(day);
                }
                notifier.setRepeatDays(newDays);
              },
              borderRadius: BorderRadius.circular(16.0),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardBgElevated,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  day.shortName,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? AppColors.background : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Nếu không chọn ngày nào, alarm sẽ chỉ báo một lần tiếp theo.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: AppColors.cardBgElevated,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(AlarmState state, AlarmController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copywriting.modeLabel,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12.0),
        ...StopMode.values.map((mode) {
          return ListTile(
            title: Text(mode.displayName, style: AppTextStyles.bodyMedium),
            subtitle: Text(mode.description, style: AppTextStyles.bodySmall),
            leading: Radio<StopMode>(
              // ignore: deprecated_member_use
              value: mode,
              // ignore: deprecated_member_use
              groupValue: state.mode,
              // ignore: deprecated_member_use
              onChanged: (value) => notifier.setMode(mode),
              activeColor: AppColors.primary,
            ),
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildProtocolSelector(AlarmState state, AlarmController notifier) {
    final protocols = StopProtocol.getTemplatesFor(state.stopType);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Copywriting.protocolLabelAlarm,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12.0),
        ...protocols.map((protocol) {
          return ListTile(
            title: Text(protocol.title, style: AppTextStyles.bodyMedium),
            leading: Radio<String>(
              // ignore: deprecated_member_use
              value: protocol.id,
              // ignore: deprecated_member_use
              groupValue: state.protocolId,
              // ignore: deprecated_member_use
              onChanged: (value) => notifier.setProtocol(protocol.id),
              activeColor: AppColors.primary,
            ),
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildCustomTypeField(AlarmState state, AlarmController notifier) {
    if (state.stopType != StopType.custom) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tên loại dừng',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12.0),
        TextField(
          decoration: const InputDecoration(
            hintText: Copywriting.customTypeHint,
          ),
          style: AppTextStyles.bodyMedium,
          onChanged: notifier.setCustomTypeLabel,
        ),
      ],
    );
  }

  Widget _buildEnabledToggle(AlarmState state, AlarmController notifier) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kích hoạt thông báo',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Khi bật, app sẽ nhắc bạn dừng đúng giờ. Khi tắt, alarm vẫn được lưu nhưng sẽ không tạo thông báo.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.isEnabled,
            onChanged: notifier.setEnabled,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(AlarmState state, AlarmController notifier) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSaving ? null : () async {
          final success = await notifier.saveAlarm();
          if (mounted && success) {
            context.pop();
          }
        },
        child: Text(Copywriting.saveButton),
      ),
    );
  }
}
