import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../responsive/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navHeight = compact ? 82.0 : 88.0;
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(16, 0, 16, compact ? 12 : 16),
        child: SizedBox(
          height: navHeight + bottomInset * 0.15,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                top: compact ? 14 : 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.of(
                      context,
                      AppColors.cardBgGlass,
                      AppColors.lightCardBgGlass,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.of(
                        context,
                        AppColors.border,
                        AppColors.lightBorder,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: brightness == Brightness.dark ? 0.28 : 0.08,
                        ),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 14,
                    vertical: compact ? 6 : 8,
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_rounded,
                        label: 'Trang chủ',
                        isActive: navigationShell.currentIndex == 0,
                        onTap: () => _goBranch(0),
                      ),
                      _NavItem(
                        icon: Icons.history_rounded,
                        label: 'Lịch sử',
                        isActive: navigationShell.currentIndex == 1,
                        onTap: () => _goBranch(1),
                      ),
                      const SizedBox(width: 74),
                      _NavItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Thống kê',
                        isActive: navigationShell.currentIndex == 2,
                        onTap: () => _goBranch(2),
                      ),
                      _NavItem(
                        icon: Icons.settings_rounded,
                        label: 'Cài đặt',
                        isActive: navigationShell.currentIndex == 3,
                        onTap: () => _goBranch(3),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/alarm/create'),
                child: Container(
                  width: compact ? 58 : 64,
                  height: compact ? 58 : 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primaryLight, AppColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 30,
                    color: brightness == Brightness.dark
                        ? AppColors.background
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    final color = isActive
        ? AppColors.primary
        : AppColors.of(
            context,
            AppColors.textTertiary,
            AppColors.lightTextTertiary,
          );
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 3 : 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: compact ? 18 : 20),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontSize: compact ? 8.5 : 9,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
