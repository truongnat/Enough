import 'package:flutter/material.dart';
import 'package:reverse_alarm/core/responsive/responsive.dart';
import 'package:reverse_alarm/core/theme/app_colors.dart';
import 'package:reverse_alarm/core/theme/app_text_styles.dart';
import 'package:reverse_alarm/core/widgets/product_components.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/repeat_day.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_mode.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_protocol.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_type.dart';
import 'package:reverse_alarm/features/alarms/presentation/controllers/alarm_controller.dart';

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
    final sectionSpacing = Responsive.sectionSpacing(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStopTypeSection(context),
        SizedBox(height: sectionSpacing),
        _buildTimeSection(context),
        SizedBox(height: sectionSpacing),
        _buildRepeatSection(context),
        SizedBox(height: sectionSpacing),
        _buildModeSection(context),
        SizedBox(height: sectionSpacing),
        _buildProtocolSection(context),
        if (state.stopType == StopType.custom) ...[
          SizedBox(height: sectionSpacing),
          _buildCustomLabelSection(context),
        ],
        SizedBox(height: sectionSpacing),
        _buildEnabledSection(context),
        if (state.error != null) ...[
          const SizedBox(height: 18),
          Text(
            state.error!,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildStopTypeSection(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bạn muốn dừng điều gì?', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: StopType.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) {
            final type = StopType.values[index];
            return AppChoiceChip(
              label: type.displayName,
              subtitle: type.subtitle,
              icon: _stopTypeIcon(type),
              isSelected: state.stopType == type,
              onSelected: () => notifier.setStopType(type),
              padding: EdgeInsets.all(compact ? 12 : 14),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: 'THỜI GIAN'),
        const SizedBox(height: 10),
        GestureDetector(
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
          child: AppGlassCard(
            child: Row(
              children: [
                Expanded(
                  child: _TimeBox(value: state.hour.toString().padLeft(2, '0')),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
                  child: Text(
                    ':',
                    style: AppTextStyles.alarmTime.copyWith(
                      fontSize: compact ? 30 : 40,
                    ),
                  ),
                ),
                Expanded(
                  child: _TimeBox(
                    value: state.minute.toString().padLeft(2, '0'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatSection(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: 'LẶP LẠI'),
        const SizedBox(height: 10),
        AppGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _quickChip(
                    'Hàng ngày',
                    () => notifier.setRepeatDays(RepeatDay.values.toList()),
                  ),
                  _quickChip(
                    'Ngày thường',
                    () => notifier.setRepeatDays([
                      RepeatDay.monday,
                      RepeatDay.tuesday,
                      RepeatDay.wednesday,
                      RepeatDay.thursday,
                      RepeatDay.friday,
                    ]),
                  ),
                  _quickChip(
                    'Cuối tuần',
                    () => notifier.setRepeatDays([
                      RepeatDay.saturday,
                      RepeatDay.sunday,
                    ]),
                  ),
                  _quickChip('Xóa', () => notifier.setRepeatDays([])),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: compact ? 8 : 10,
                runSpacing: compact ? 8 : 10,
                children: RepeatDay.values.map((day) {
                  final isSelected = state.repeatDays.contains(day);
                  return GestureDetector(
                    onTap: () {
                      final newDays = List<RepeatDay>.from(state.repeatDays);
                      if (isSelected) {
                        newDays.remove(day);
                      } else {
                        newDays.add(day);
                      }
                      notifier.setRepeatDays(newDays);
                    },
                    child: Container(
                      width: compact ? 34 : 38,
                      height: compact ? 34 : 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardBgElevated,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day.shortName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.background
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: 'CHẾ ĐỘ'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: StopMode.values.map((mode) {
            final isSelected = state.mode == mode;
            return SizedBox(
              width:
                  (MediaQuery.sizeOf(context).width -
                      (Responsive.horizontalPadding(context) * 2) -
                      10) /
                  2,
              child: AppSegmentedChip(
                label: mode.displayName,
                icon: _modeIcon(mode),
                isSelected: isSelected,
                onTap: () {
                  notifier.setMode(mode);
                  final protocols = StopProtocol.getTemplatesFor(
                    state.stopType,
                  );
                  if (protocols.isNotEmpty) {
                    notifier.setProtocol(protocols.first.id);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProtocolSection(BuildContext context) {
    final protocols = StopProtocol.getTemplatesFor(state.stopType);
    final selected = protocols.firstWhere(
      (protocol) => protocol.id == state.protocolId,
      orElse: () => protocols.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: 'RITUAL SAU KHI BÁO'),
        const SizedBox(height: 10),
        Column(
          children: protocols.map((protocol) {
            final isSelected = selected.id == protocol.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppGlassCard(
                onTap: () => notifier.setProtocol(protocol.id),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primarySoft
                            : AppColors.cardBgElevated,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.check_rounded
                            : Icons.chevron_right_rounded,
                        size: 18,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            protocol.title,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            protocol.steps.join('  •  '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomLabelSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: 'NHÃN TỰ CHỌN'),
        const SizedBox(height: 10),
        TextField(
          controller: customLabelController,
          onChanged: notifier.setCustomTypeLabel,
          style: AppTextStyles.bodyLarge,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: Đọc sách, tập thể dục...',
          ),
        ),
      ],
    );
  }

  Widget _buildEnabledSection(BuildContext context) {
    return AppGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: state.isEnabled
                  ? AppColors.primarySoft
                  : AppColors.cardBgElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              state.isEnabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: state.isEnabled
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kích hoạt alarm', style: AppTextStyles.labelLarge),
                const SizedBox(height: 4),
                Text(
                  'Alarm vẫn được lưu kể cả khi tắt thông báo.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: state.isEnabled, onChanged: notifier.setEnabled),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return AppSegmentedChip(label: label, isSelected: false, onTap: onTap);
  }

  IconData _stopTypeIcon(StopType type) {
    switch (type) {
      case StopType.coding:
        return Icons.laptop_mac_rounded;
      case StopType.working:
        return Icons.work_outline_rounded;
      case StopType.scrolling:
        return Icons.phone_android_rounded;
      case StopType.overthinking:
        return Icons.psychology_alt_outlined;
      case StopType.sleep:
        return Icons.dark_mode_outlined;
      case StopType.custom:
        return Icons.add_rounded;
    }
  }

  IconData _modeIcon(StopMode mode) {
    switch (mode) {
      case StopMode.gentle:
        return Icons.bedtime_outlined;
      case StopMode.strict:
        return Icons.local_fire_department_outlined;
      case StopMode.meme:
        return Icons.sentiment_satisfied_alt_outlined;
    }
  }
}

class _TimeBox extends StatelessWidget {
  final String value;

  const _TimeBox({required this.value});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: compact ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.cardBgElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.alarmTime.copyWith(fontSize: compact ? 30 : 38),
      ),
    );
  }
}
