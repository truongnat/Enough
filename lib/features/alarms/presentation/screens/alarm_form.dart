import 'package:flutter/material.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_type.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_mode.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/repeat_day.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_protocol.dart';
import 'package:reverse_alarm/features/alarms/presentation/controllers/alarm_controller.dart';
import 'package:reverse_alarm/core/theme/app_colors.dart';
import 'package:reverse_alarm/core/theme/app_text_styles.dart';
import 'package:reverse_alarm/core/widgets/product_components.dart';

class AlarmForm extends StatelessWidget {
  final AlarmState state;
  final AlarmController notifier;
  final TextEditingController customLabelController;

  const AlarmForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.customLabelController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: 'LOẠI HOẠT ĐỘNG'),
        StopTypeSelector(state: state, notifier: notifier),
        const SizedBox(height: 24.0),
        
        const AppSectionTitle(title: 'GIỜ THÔNG BÁO'),
        TimePickerPanel(state: state, notifier: notifier),
        const SizedBox(height: 24.0),
        
        const AppSectionTitle(title: 'LẶP LẠI'),
        RepeatDaySelector(state: state, notifier: notifier),
        const SizedBox(height: 24.0),
        
        const AppSectionTitle(title: 'CHẾ ĐỘ DỪNG'),
        StopModeSelector(state: state, notifier: notifier),
        const SizedBox(height: 24.0),
        
        const AppSectionTitle(title: 'GIAO THỨC DỪNG (PROTOCOL)'),
        ProtocolSelector(state: state, notifier: notifier),
        const SizedBox(height: 24.0),
        
        if (state.stopType == StopType.custom) ...[
          const AppSectionTitle(title: 'NHÃN TỰ ĐỊNH NGHĨA'),
          TextField(
            controller: customLabelController,
            onChanged: notifier.setCustomTypeLabel,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Đọc sách, Tập thể dục...',
            ),
          ),
          const SizedBox(height: 24.0),
        ],
        
        AlarmEnabledCard(state: state, notifier: notifier),
      ],
    );
  }
}

class StopTypeSelector extends StatelessWidget {
  final AlarmState state;
  final AlarmController notifier;

  const StopTypeSelector({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: StopType.values.map((type) {
        return AppChoiceChip(
          label: type.displayName,
          isSelected: state.stopType == type,
          onSelected: () {
            notifier.setStopType(type);
          },
        );
      }).toList(),
    );
  }
}

class TimePickerPanel extends StatelessWidget {
  final AlarmState state;
  final AlarmController notifier;

  const TimePickerPanel({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: InkWell(
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: state.hour, minute: state.minute),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: AppColors.background,
                    surface: AppColors.cardBg,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (time != null) {
            notifier.setTime(time.hour, time.minute);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, color: AppColors.primary, size: 28),
              const SizedBox(width: 12.0),
              Text(
                '${state.hour.toString().padLeft(2, '0')}:${state.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.alarmTime.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RepeatDaySelector extends StatelessWidget {
  final AlarmState state;
  final AlarmController notifier;

  const RepeatDaySelector({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
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
          const SizedBox(height: 16.0),
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
                borderRadius: BorderRadius.circular(24.0),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.cardBgElevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.shortName,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected ? AppColors.background : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12.0),
          Text(
            '“Nếu không chọn ngày nào, alarm sẽ chỉ báo một lần tiếp theo.”',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
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
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class StopModeSelector extends StatelessWidget {
  final AlarmState state;
  final AlarmController notifier;

  const StopModeSelector({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: StopMode.values.map((mode) {
        return AppChoiceChip(
          label: mode.name.toUpperCase(),
          isSelected: state.mode == mode,
          onSelected: () {
            notifier.setMode(mode);
            // Auto set default protocol for this mode and type
            final protocols = StopProtocol.getTemplatesFor(state.stopType);
            if (protocols.isNotEmpty) {
              notifier.setProtocol(protocols.first.id);
            }
          },
        );
      }).toList(),
    );
  }
}

class ProtocolSelector extends StatelessWidget {
  final AlarmState state;
  final AlarmController notifier;

  const ProtocolSelector({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final protocols = StopProtocol.getTemplatesFor(state.stopType);
    if (protocols.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No protocols available for this activity type', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Column(
      children: protocols.map((protocol) {
        final isSelected = state.protocolId == protocol.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: AppSurfaceCard(
            onTap: () => notifier.setProtocol(protocol.id),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Radio<String>(
                  value: protocol.id,
                  groupValue: state.protocolId,
                  onChanged: (val) {
                    if (val != null) notifier.setProtocol(val);
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        protocol.title,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        protocol.steps.join(' → '),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AlarmEnabledCard extends StatelessWidget {
  final AlarmState state;
  final AlarmController notifier;

  const AlarmEnabledCard({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kích hoạt thông báo',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
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
          const SizedBox(width: 16.0),
          Switch(
            value: state.isEnabled,
            onChanged: notifier.setEnabled,
          ),
        ],
      ),
    );
  }
}
