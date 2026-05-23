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
  final TextEditingController messageController;

  const AlarmForm({
    super.key,
    required this.state,
    required this.notifier,
    required this.customLabelController,
    required this.messageController,
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
        _buildMessageSection(context),
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
        Text(
          'Bạn muốn dừng điều gì?',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.of(
              context,
              AppColors.textPrimary,
              AppColors.lightTextPrimary,
            ),
          ),
        ),
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
          onTap: () => _showTimePickerBottomSheet(context, state, notifier),
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

  void _showTimePickerBottomSheet(
    BuildContext context,
    AlarmState state,
    AlarmController notifier,
  ) {
    int selectedHour = state.hour;
    int selectedMinute = state.minute;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.35,
        maxChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.of(
              context,
              AppColors.cardBg,
              AppColors.lightCardBg,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.of(
                    context,
                    AppColors.border,
                    AppColors.lightBorder,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Hủy',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        notifier.setTime(selectedHour, selectedMinute);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Xong',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTimeWheel(
                        context: context,
                        items: List.generate(24, (i) => i),
                        selectedValue: selectedHour,
                        onChanged: (value) => selectedHour = value,
                        formatter: (value) => value.toString().padLeft(2, '0'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        ':',
                        style: AppTextStyles.alarmTime.copyWith(
                          fontSize: 36,
                          color: AppColors.of(
                            context,
                            AppColors.textPrimary,
                            AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _buildTimeWheel(
                        context: context,
                        items: List.generate(60, (i) => i),
                        selectedValue: selectedMinute,
                        onChanged: (value) => selectedMinute = value,
                        formatter: (value) => value.toString().padLeft(2, '0'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeWheel({
    required BuildContext context,
    required List<int> items,
    required int selectedValue,
    required Function(int) onChanged,
    required String Function(int) formatter,
  }) {
    return ListWheelScrollView.useDelegate(
      itemExtent: 50,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      controller: FixedExtentScrollController(initialItem: selectedValue),
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final value = items[index];
          final isSelected = value == selectedValue;
          return Center(
            child: Text(
              formatter(value),
              style: AppTextStyles.alarmTime.copyWith(
                fontSize: 32,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.of(
                        context,
                        AppColors.textSecondary,
                        AppColors.lightTextSecondary,
                      ),
              ),
            ),
          );
        },
        childCount: items.length,
      ),
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
                            : AppColors.of(
                                context,
                                AppColors.cardBgElevated,
                                AppColors.lightCardBgElevated,
                              ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.of(
                                  context,
                                  AppColors.border,
                                  AppColors.lightBorder,
                                ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day.shortName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? AppColors.background
                              : AppColors.of(
                                  context,
                                  AppColors.textPrimary,
                                  AppColors.lightTextPrimary,
                                ),
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
                            : AppColors.of(
                                context,
                                AppColors.cardBgElevated,
                                AppColors.lightCardBgElevated,
                              ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.of(
                                  context,
                                  AppColors.border,
                                  AppColors.lightBorder,
                                ),
                        ),
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.check_rounded
                            : Icons.chevron_right_rounded,
                        size: 18,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.of(
                                context,
                                AppColors.textSecondary,
                                AppColors.lightTextSecondary,
                              ),
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
                                  : AppColors.of(
                                      context,
                                      AppColors.textPrimary,
                                      AppColors.lightTextPrimary,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            protocol.steps.join('  •  '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.of(
                                context,
                                AppColors.textSecondary,
                                AppColors.lightTextSecondary,
                              ),
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
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.of(
              context,
              AppColors.textPrimary,
              AppColors.lightTextPrimary,
            ),
          ),
          decoration: InputDecoration(
            hintText: 'Ví dụ: Đọc sách, tập thể dục...',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.of(
                context,
                AppColors.textSecondary,
                AppColors.lightTextSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(title: 'LỜI NHẮN (TÙY CHỌN)'),
        const SizedBox(height: 10),
        TextField(
          controller: messageController,
          onChanged: notifier.setMessage,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.of(
              context,
              AppColors.textPrimary,
              AppColors.lightTextPrimary,
            ),
          ),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Nhập lời nhắn cá nhân cho báo thức này...',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.of(
                context,
                AppColors.textSecondary,
                AppColors.lightTextSecondary,
              ),
            ),
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
                  : AppColors.of(
                      context,
                      AppColors.cardBgElevated,
                      AppColors.lightCardBgElevated,
                    ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              state.isEnabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: state.isEnabled
                  ? AppColors.primary
                  : AppColors.of(
                      context,
                      AppColors.textSecondary,
                      AppColors.lightTextSecondary,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kích hoạt alarm',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.of(
                      context,
                      AppColors.textPrimary,
                      AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Alarm vẫn được lưu kể cả khi tắt thông báo.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.of(
                      context,
                      AppColors.textSecondary,
                      AppColors.lightTextSecondary,
                    ),
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
      case StopMode.general:
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
        color: AppColors.of(
          context,
          AppColors.cardBgElevated,
          AppColors.lightCardBgElevated,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.of(context, AppColors.border, AppColors.lightBorder),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.alarmTime.copyWith(
          fontSize: compact ? 30 : 38,
          color: AppColors.of(
            context,
            AppColors.textPrimary,
            AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}
