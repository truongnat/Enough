import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/app_settings.dart';
import '../../../alarms/domain/entities/stop_mode.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(
        title: Text(Copywriting.settingsLabel),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : settings == null
              ? const Center(child: Text('Error loading settings'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    children: [
                      _buildDefaultModeCard(settings, notifier),
                      const SizedBox(height: AppConstants.paddingL),
                      _buildNotificationsCard(settings, notifier),
                      const SizedBox(height: AppConstants.paddingL),
                      _buildSnoozeCard(settings, notifier),
                      const SizedBox(height: AppConstants.paddingL),
                      _buildResetCard(notifier),
                      const SizedBox(height: AppConstants.paddingL),
                      _buildAboutCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDefaultModeCard(AppSettings settings, SettingsController notifier) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.defaultModeLabel,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 12.0),
          ...StopMode.values.map((mode) {
            return RadioListTile<StopMode>(
              value: mode,
              groupValue: settings.defaultMode,
              onChanged: (value) => notifier.setDefaultMode(mode),
              title: Text(mode.displayName, style: AppTextStyles.bodyMedium),
              subtitle: Text(mode.description, style: AppTextStyles.bodySmall),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(AppSettings settings, SettingsController notifier) {
    return AppCard(
      child: SwitchListTile(
        value: settings.notificationsEnabled,
        onChanged: notifier.setNotificationsEnabled,
        title: Text(Copywriting.notificationsLabel, style: AppTextStyles.bodyMedium),
        subtitle: Text('Nhận thông báo khi đến giờ dừng', style: AppTextStyles.bodySmall),
        activeColor: AppColors.primary,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSnoozeCard(AppSettings settings, SettingsController notifier) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.snoozeMinutesLabel,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Wrap(
            spacing: AppConstants.paddingM,
            children: [5, 10, 15].map((minutes) {
              final isSelected = settings.defaultSnoozeMinutes == minutes;
              return InkWell(
                onTap: () => notifier.setDefaultSnoozeMinutes(minutes),
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingL,
                    vertical: AppConstants.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.cardBgElevated,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '$minutes phút',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.background : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResetCard(SettingsController notifier) {
    return AppCard(
      child: ListTile(
        leading: const Icon(
          Icons.delete_forever,
          color: AppColors.error,
        ),
        title: Text(
          Copywriting.resetDataLabel,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.error,
          ),
        ),
        subtitle: Text(
          Copywriting.resetDataWarning,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        onTap: () => _showResetDialog(notifier),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildAboutCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.aboutLabel,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            Copywriting.sloganLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              Text(
                '${Copywriting.versionLabel}: ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _appVersion,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetDialog(SettingsController notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả dữ liệu'),
        content: const Text('Hành động này sẽ xóa tất cả báo thức, lịch sử và cài đặt. Bạn có chắc không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              notifier.resetAllData();
              Navigator.of(context).pop();
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
