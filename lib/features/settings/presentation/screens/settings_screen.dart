import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';
import '../../domain/entities/app_settings.dart';
import '../../../alarms/domain/entities/stop_mode.dart';
import '../controllers/settings_controller.dart';
import 'privacy_policy_screen.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  ? Center(
                      child: Text(
                        'Error loading settings',
                        style: TextStyle(
                          color: AppColors.of(
                            context,
                            AppColors.textSecondary,
                            AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppSectionTitle(title: 'GIAO DIỆN & CẤU HÌNH'),
                          const SizedBox(height: 8.0),
                          _buildUserNameCard(settings, notifier),
                          const SizedBox(height: 16.0),
                          _buildThemeCard(settings, notifier),
                          const SizedBox(height: 16.0),
                          _buildDefaultModeCard(settings, notifier),
                          const SizedBox(height: 16.0),
                          _buildSnoozeCard(settings, notifier),
                          const SizedBox(height: 32.0),
                          const AppSectionTitle(title: 'HỆ THỐNG'),
                          const SizedBox(height: 8.0),
                          _buildExportCard(notifier),
                          const SizedBox(height: 16.0),
                          _buildImportCard(notifier),
                          const SizedBox(height: 16.0),
                          _buildResetCard(notifier),
                          const SizedBox(height: 16.0),
                          _buildPrivacyPolicyCard(),
                          const SizedBox(height: 24.0),
                          Center(
                            child: Text(
                              'Phiên bản $_appVersion',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.of(
                                  context,
                                  AppColors.textSecondary,
                                  AppColors.lightTextSecondary,
                                ),
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

  Widget _buildUserNameCard(AppSettings settings, SettingsController notifier) {
    final controller = TextEditingController(text: settings.userName ?? '');

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tên của bạn',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.of(
                context,
                AppColors.textPrimary,
                AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Được hiển thị trong lời chào trên màn hình chính.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.of(
                context,
                AppColors.textSecondary,
                AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: controller,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.of(
                context,
                AppColors.textPrimary,
                AppColors.lightTextPrimary,
              ),
            ),
            decoration: InputDecoration(
              hintText: 'Nhập tên của bạn...',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.of(
                  context,
                  AppColors.textSecondary,
                  AppColors.lightTextSecondary,
                ),
              ),
              filled: true,
              fillColor: AppColors.of(
                context,
                AppColors.cardBgElevated,
                AppColors.lightCardBgElevated,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: AppColors.of(
                    context,
                    AppColors.border,
                    AppColors.lightBorder,
                  ),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: AppColors.of(
                    context,
                    AppColors.border,
                    AppColors.lightBorder,
                  ),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onSubmitted: (value) {
              notifier.setUserName(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(AppSettings settings, SettingsController notifier) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chủ đề',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.of(
                context,
                AppColors.textPrimary,
                AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Chọn giao diện ứng dụng.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.of(
                context,
                AppColors.textSecondary,
                AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ThemeMode.values.map((mode) {
              final isSelected = settings.themeMode == mode;
              IconData icon;
              switch (mode) {
                case ThemeMode.light:
                  icon = Icons.light_mode_outlined;
                  break;
                case ThemeMode.dark:
                  icon = Icons.dark_mode_outlined;
                  break;
                case ThemeMode.system:
                  icon = Icons.brightness_auto_outlined;
                  break;
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () => notifier.setThemeMode(mode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.of(
                                context,
                                AppColors.cardBgElevated,
                                AppColors.lightCardBgElevated,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.of(
                                  context,
                                  AppColors.border,
                                  AppColors.lightBorder,
                                ),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.of(
                                context,
                                AppColors.textSecondary,
                                AppColors.lightTextSecondary,
                              ),
                      ),
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

  Widget _buildDefaultModeCard(
    AppSettings settings,
    SettingsController notifier,
  ) {
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Copywriting.defaultModeLabel, style: AppTextStyles.labelLarge),
          const SizedBox(height: 4.0),
          Text(
            'Chế độ mặc định được áp dụng khi tạo báo thức mới.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.of(
                context,
                AppColors.textSecondary,
                AppColors.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: StopMode.values.map((mode) {
              final isSelected = settings.defaultMode == mode;
              IconData icon;
              switch (mode) {
                case StopMode.general:
                  icon = Icons.bedtime_outlined;
                  break;
                case StopMode.strict:
                  icon = Icons.local_fire_department_outlined;
                  break;
                case StopMode.meme:
                  icon = Icons.sentiment_satisfied_alt_outlined;
                  break;
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () => notifier.setDefaultMode(mode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.of(
                                context,
                                AppColors.cardBgElevated,
                                AppColors.lightCardBgElevated,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.of(
                                  context,
                                  AppColors.border,
                                  AppColors.lightBorder,
                                ),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.of(
                                context,
                                AppColors.textSecondary,
                                AppColors.lightTextSecondary,
                              ),
                      ),
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

  Widget _buildSnoozeCard(AppSettings settings, SettingsController notifier) {
    return AppSurfaceCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian báo lại',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.of(
                      context,
                      AppColors.textPrimary,
                      AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Thời gian báo lại khi tạm hoãn.',
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
          DropdownButton<int>(
            value: settings.defaultSnoozeMinutes,
            dropdownColor: AppColors.of(
              context,
              AppColors.cardBgElevated,
              AppColors.lightCardBgElevated,
            ),
            underline: const SizedBox.shrink(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
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
            content: const Text(
              'Tất cả báo thức, lịch sử và thống kê sẽ bị xóa hoàn toàn và không thể khôi phục.',
            ),
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
              const SnackBar(
                content: Text('Đã xóa toàn bộ dữ liệu thành công'),
              ),
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
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Xóa toàn bộ dữ liệu ứng dụng.',
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
          Icon(
            Icons.chevron_right,
            color: AppColors.of(
              context,
              AppColors.textSecondary,
              AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(SettingsController notifier) {
    return AppSurfaceCard(
      onTap: () async {
        try {
          final data = await notifier.exportData();
          final jsonString = jsonEncode(data);
          final timestamp = DateTime.now().toIso8601String().split('T')[0];

          // Save to temporary file
          final directory = await getTemporaryDirectory();
          final file = File(
            '${directory.path}/reverse_alarm_backup_$timestamp.json',
          );
          await file.writeAsString(jsonString);

          // Share the file
          await Share.shareXFiles([
            XFile(file.path),
          ], subject: 'Reverse Alarm Backup - $timestamp');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xuất dữ liệu thành công')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Lỗi xuất dữ liệu: $e')));
          }
        }
      },
      child: Row(
        children: [
          const Icon(Icons.file_upload_outlined, color: AppColors.primary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xuất dữ liệu',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.of(
                      context,
                      AppColors.textPrimary,
                      AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Xuất toàn bộ dữ liệu ra file JSON.',
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
          Icon(
            Icons.chevron_right,
            color: AppColors.of(
              context,
              AppColors.textSecondary,
              AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportCard(SettingsController notifier) {
    return AppSurfaceCard(
      onTap: () async {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['json'],
          );

          if (result != null && result.files.single.path != null) {
            final file = result.files.single;
            final jsonString = await file.xFile.readAsString();
            final data = jsonDecode(jsonString) as Map<String, dynamic>;

            if (!mounted) return;

            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Nhập dữ liệu?'),
                content: const Text(
                  'Dữ liệu hiện tại sẽ bị ghi đè. Bạn có chắc chắn muốn tiếp tục?',
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
                    child: const Text('Nhập dữ liệu'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await notifier.importData(data);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã nhập dữ liệu thành công')),
                );
              }
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Lỗi nhập dữ liệu: $e')));
          }
        }
      },
      child: Row(
        children: [
          const Icon(Icons.file_download_outlined, color: AppColors.primary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhập dữ liệu',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.of(
                      context,
                      AppColors.textPrimary,
                      AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Nhập dữ liệu từ file JSON.',
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
          Icon(
            Icons.chevron_right,
            color: AppColors.of(
              context,
              AppColors.textSecondary,
              AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyCard() {
    return AppSurfaceCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
        );
      },
      child: Row(
        children: [
          const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chính sách bảo mật',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.of(
                      context,
                      AppColors.textPrimary,
                      AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Xem chính sách bảo mật của ứng dụng.',
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
          Icon(
            Icons.chevron_right,
            color: AppColors.of(
              context,
              AppColors.textSecondary,
              AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
