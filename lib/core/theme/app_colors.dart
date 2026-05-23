import 'package:flutter/material.dart';

class AppColors {
  // Dark theme colors
  static const Color background = Color(0xFF07090B);
  static const Color backgroundSecondary = Color(0xFF0C0F12);
  static const Color cardBg = Color(0xFF15181B);
  static const Color cardBgElevated = Color(0xFF1D2226);
  static const Color cardBgGlass = Color(0xCC13171A);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightBackgroundSecondary = Color(0xFFE8E8ED);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightCardBgElevated = Color(0xFFF2F2F7);
  static const Color lightCardBgGlass = Color(0xCCFFFFFF);

  static const Color primary = Color(0xFFE76F3C);
  static const Color primaryDark = Color(0xFFB84D24);
  static const Color primaryLight = Color(0xFFFFA27D);
  static const Color primarySoft = Color(0x24E76F3C);

  static const Color success = Color(0xFF53C58A);
  static const Color error = Color(0xFFF06464);
  static const Color warning = Color(0xFFF5A84B);

  // Dark theme text colors
  static const Color textPrimary = Color(0xFFF5F1EA);
  static const Color textSecondary = Color(0xFFA7A19A);
  static const Color textTertiary = Color(0xFF6D6862);

  // Light theme text colors
  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF636366);
  static const Color lightTextTertiary = Color(0xFF8E8E93);

  static const Color paper = Color(0xFFEFE1C9);
  static const Color paperText = Color(0xFF201B16);
  static const Color stamp = Color(0xFFB34D2B);

  // Dark theme border colors
  static const Color border = Color(0x14FFFFFF);
  static const Color divider = Color(0x1FFFFFFF);

  // Light theme border colors
  static const Color lightBorder = Color(0x33000000);
  static const Color lightDivider = Color(0x4D000000);

  static const LinearGradient screenGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0E1114), background],
  );

  static const LinearGradient lightScreenGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8E8ED), lightBackground],
  );

  // Helper to get color based on theme brightness
  static Color of(BuildContext context, Color darkColor, Color lightColor) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkColor : lightColor;
  }

  static LinearGradient screenGlowOf(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? screenGlow : lightScreenGlow;
  }
}
