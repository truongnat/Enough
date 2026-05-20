import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(
              title: 'Cài đặt',
              leading: SizedBox.shrink(), // No back button on main tab
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : settings == null
                      ? const Center(child: Text('Error loading settings', style: TextStyle(color: AppColors.textSecondary)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(AppConstants.paddingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppSectionTitle(title: 'GIAO DIỆN & CẤU HÌNH'),
                              const SizedBox(height: 8.0),
                              _buildDefaultModeCard(settings, notifier),
                              const SizedBox(height: 16.0),
                              _buildSnoozeCard(settings, notifier),
                              const SizedBox(height: 32.0),
                              const AppSectionTitle(title: 'HỆ THỐNG'),
                              const SizedBox(height: 8.0),
                              _buildResetCard(notifier),
                              const SizedBox(height: 24.0),
                              Center(
                                child: Text(
                                  'Phiên bản $_appVersion',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultModeCard(AppSettings settings, SettingsController notifier) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Copywriting.defaultModeLabel,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Chế độ mặc định được áp dụng khi tạo báo thức mới.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: StopMode.values.map((mode) {
              final isSelected = settings.defaultMode == mode;
              return AppChoiceChip(
                label: mode.name.toUpperCase(),
                isSelected: isSelected,
                onSelected: () => notifier.setDefaultMode(mode),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeCard(AppSettings settings, SettingsController notifier) {
    return AppSurfaceCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thời gian báo lại',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Thời gian báo lại khi tạm hoãn.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          DropdownButton<int>(
            value: settings.defaultSnoozeMinutes,
            dropdownColor: AppColors.cardBgElevated,
            underline: const SizedBox.shrink(),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            items: [5, 10, 15, 20, 30].map((mins) {
              return DropdownMenuItem<int>(
                value: mins,
                child: Text('$mins phút'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) notifier.setDefaultSnoozeMinutes(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResetCard(SettingsController notifier) {
    return AppSurfaceCard(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa toàn bộ dữ liệu?'),
            content: const Text('Tất cả báo thức, lịch sử và thống kê sẽ bị xóa hoàn toàn và không thể khôi phục.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Xóa hết'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await notifier.resetAllData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu thành công')),
            );
          }
        }
      },
      child: Row(
        children: [
          const Icon(Icons.delete_forever, color: AppColors.error),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Copywriting.resetDataLabel,
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Xóa toàn bộ dữ liệu ứng dụng.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
