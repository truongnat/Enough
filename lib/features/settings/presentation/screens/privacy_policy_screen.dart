import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_components.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AppPageHeader(
                title: 'Chính sách bảo mật',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSection(
                      context,
                      'Giới thiệu',
                      'Enough là ứng dụng giúp bạn quản lý và theo dõi các thói quen cần dừng. Chúng tôi cam kết bảo vệ quyền riêng tư của bạn.',
                    ),
                    _buildSection(
                      context,
                      'Dữ liệu thu thập',
                      'Ứng dụng chỉ thu thập dữ liệu được lưu trữ cục bộ trên thiết bị của bạn, bao gồm:\n'
                      '• Thông tin báo thức (thời gian, loại, chế độ)\n'
                      '• Lịch sử các lần dừng thành công\n'
                      '• Thống kê sử dụng\n'
                      '• Cài đặt cá nhân\n\n'
                      'Chúng tôi không thu thập, lưu trữ hay truyền tải bất kỳ dữ liệu nào đến máy chủ bên ngoài.',
                    ),
                    _buildSection(
                      context,
                      'Quyền truy cập',
                      'Ứng dụng yêu cầu các quyền sau:\n'
                      '• Thông báo: Để gửi lời nhắc báo thức\n'
                      '• Lưu trữ: Để lưu dữ liệu cục bộ\n\n'
                      'Tất cả các quyền này chỉ được sử dụng cho mục đích hoạt động của ứng dụng.',
                    ),
                    _buildSection(
                      context,
                      'Dữ liệu cá nhân',
                    'Ứng dụng không yêu cầu thông tin định danh cá nhân như tên, email, số điện thoại hay địa chỉ. '
                    'Tên người dùng (nếu có) chỉ được lưu cục bộ và dùng để hiển thị lời chào cá nhân hóa.',
                    ),
                    _buildSection(
                      context,
                      'Bảo mật dữ liệu',
                      'Tất cả dữ liệu của bạn được lưu trữ cục bộ trên thiết bị và được bảo vệ bằng cơ chế bảo mật của hệ điều hành. '
                      'Bạn có thể xuất dữ liệu để sao lưu hoặc nhập dữ liệu từ file JSON.',
                    ),
                    _buildSection(
                      context,
                      'Xóa dữ liệu',
                      'Bạn có thể xóa toàn bộ dữ liệu của ứng dụng bất cứ lúc nào thông qua tính năng "Xóa toàn bộ dữ liệu" trong màn hình Cài đặt. '
                      'Hành động này sẽ xóa vĩnh viễn tất cả báo thức, lịch sử và thống kê.',
                    ),
                    _buildSection(
                      context,
                      'Chia sẻ dữ liệu',
                      'Chúng tôi không chia sẻ dữ liệu của bạn với bất kỳ bên thứ ba nào. '
                      'Tính năng xuất dữ liệu chỉ cho phép bạn chia sẻ file JSON với chính bạn hoặc người mà bạn tin tưởng.',
                    ),
                    _buildSection(
                      context,
                      'Thay đổi chính sách',
                      'Chúng tôi có thể cập nhật chính sách bảo mật này trong các phiên bản tương lai. '
                      'Mọi thay đổi quan trọng sẽ được thông báo trong ứng dụng.',
                    ),
                    _buildSection(
                      context,
                      'Liên hệ',
                      'Nếu bạn có câu hỏi hoặc thắc mắc về chính sách bảo mật, vui lòng liên hệ qua email hỗ trợ của ứng dụng.',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.of(context, AppColors.textPrimary, AppColors.lightTextPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.of(context, AppColors.textSecondary, AppColors.lightTextSecondary),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
