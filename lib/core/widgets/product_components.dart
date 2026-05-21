import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../responsive/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.padding,
    this.safeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: const BoxDecoration(gradient: AppColors.screenGlow),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _GlowOrb(
              size: 260,
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            top: 120,
            right: -60,
            child: _GlowOrb(
              size: 180,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Positioned.fill(
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ],
      ),
    );

    if (!safeArea) return content;
    return SafeArea(child: content);
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final String? eyebrow;

  const AppPageHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.eyebrow,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.horizontalPadding(context);
    final compact = Responsive.compactMode(context);
    final resolvedLeading =
        leading ??
        (context.canPop()
            ? AppRoundIconButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => context.pop(),
              )
            : const SizedBox(width: 44, height: 44));

    final resolvedActions = actions ?? const <Widget>[];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        compact ? 10 : 14,
        horizontalPadding,
        8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 44, height: 44, child: resolvedLeading),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null)
                  Text(
                    eyebrow!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (resolvedActions.isEmpty)
            const SizedBox(width: 44, height: 44)
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: compact ? 96 : 120),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < resolvedActions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Flexible(child: resolvedActions[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AppRoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  const AppRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.backgroundColor,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.cardBgElevated,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: size * 0.42,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppRoundIconButton(
      icon: icon,
      onTap: onTap,
      color: color,
      backgroundColor: backgroundColor,
    );
  }
}

class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? color;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(28);
    Widget content = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBgGlass,
        borderRadius: radius,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(18),
        child: child,
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: radius, child: content),
      );
    }

    return content;
  }
}

class AppSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(padding: padding, onTap: onTap, child: child);
  }
}

class AppHeroCard extends StatelessWidget {
  final String label;
  final String title;
  final String emphasis;
  final String value;
  final String supporting;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppHeroCard({
    super.key,
    required this.label,
    required this.title,
    required this.emphasis,
    required this.value,
    required this.supporting,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return AppGlassCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 18 : 22),
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -20,
            child: _GlowOrb(
              size: 170,
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 16),
                    Row(
                      children: [
                        Container(
                          width: compact ? 36 : 40,
                          height: compact ? 36 : 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.primary,
                            size: compact ? 18 : 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            emphasis,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 12 : 16),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.alarmTime.copyWith(
                        fontSize: compact
                            ? 46
                            : AppTextStyles.alarmTime.fontSize,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      supporting,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null && !compact) ...[
                const SizedBox(width: 16),
                Flexible(child: trailing!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class AppIllustrationPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;
  final double width;
  final double height;

  const AppIllustrationPlaceholder({
    super.key,
    required this.icon,
    required this.label,
    this.width = 124,
    this.height = 132,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardBgElevated, AppColors.backgroundSecondary],
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: Column(
              children: [
                Icon(icon, color: AppColors.primaryLight, size: 40),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Text(
              'TODO',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppPill extends StatelessWidget {
  final String label;
  final Color? color;
  final bool filled;
  final IconData? icon;

  const AppPill({
    super.key,
    required this.label,
    this.color,
    this.filled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tone = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? tone.withValues(alpha: 0.18) : AppColors.cardBgElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: filled ? tone : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: tone),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: filled ? tone : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class AppSegmentedChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const AppSegmentedChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primarySoft
                : AppColors.cardBgElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final IconData? icon;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
    this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: padding ?? EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primarySoft
                : AppColors.cardBgElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Container(
                  width: compact ? 34 : 38,
                  height: compact ? 34 : 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              if (icon != null) const SizedBox(height: 12),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 16 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.background,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: AppColors.background),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? color;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    final activeColor = color ?? AppColors.primary;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: activeColor,
          side: BorderSide(
            color: activeColor.withValues(alpha: 0.72),
            width: 1.4,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 16 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(color: activeColor),
              ),
      ),
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  final String title;

  const AppSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.overline.copyWith(color: AppColors.textSecondary),
    );
  }
}

class AppSectionLabel extends StatelessWidget {
  final String title;
  final String? trailing;

  const AppSectionLabel({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: compact ? 8 : 12),
        if (trailing != null)
          Flexible(
            child: Text(
              trailing!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class AppReceiptPaper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppReceiptPaper({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 24 : 28),
        child: CustomPaint(
          painter: _ReceiptPaperPainter(),
          child: Padding(
            padding:
                padding ??
                EdgeInsets.fromLTRB(
                  compact ? 18 : 22,
                  compact ? 22 : 28,
                  compact ? 18 : 22,
                  compact ? 20 : 24,
                ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ReceiptPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = AppColors.paper;
    final path = Path()..moveTo(0, 12);

    for (double x = 0; x <= size.width; x += 12) {
      path.lineTo(x + 6, 0);
      path.lineTo(x + 12, 12);
    }

    path.lineTo(size.width, size.height - 12);

    for (double x = size.width; x >= 0; x -= 12) {
      path.lineTo(x - 6, size.height);
      path.lineTo(x - 12, size.height - 12);
    }

    path.close();
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppBottomActionBar extends StatelessWidget {
  final List<Widget> children;

  const AppBottomActionBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.compactMode(context);
    return AppGlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 8 : 10,
      ),
      borderRadius: BorderRadius.circular(24),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: compact ? 12 : 16,
        runSpacing: compact ? 10 : 12,
        children: children,
      ),
    );
  }
}
