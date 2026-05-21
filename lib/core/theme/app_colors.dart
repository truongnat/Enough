import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF07090B);
  static const Color backgroundSecondary = Color(0xFF0C0F12);
  static const Color cardBg = Color(0xFF15181B);
  static const Color cardBgElevated = Color(0xFF1D2226);
  static const Color cardBgGlass = Color(0xCC13171A);

  static const Color primary = Color(0xFFE76F3C);
  static const Color primaryDark = Color(0xFFB84D24);
  static const Color primaryLight = Color(0xFFFFA27D);
  static const Color primarySoft = Color(0x24E76F3C);

  static const Color success = Color(0xFF53C58A);
  static const Color error = Color(0xFFF06464);
  static const Color warning = Color(0xFFF5A84B);

  static const Color textPrimary = Color(0xFFF5F1EA);
  static const Color textSecondary = Color(0xFFA7A19A);
  static const Color textTertiary = Color(0xFF6D6862);

  static const Color paper = Color(0xFFEFE1C9);
  static const Color paperText = Color(0xFF201B16);
  static const Color stamp = Color(0xFFB34D2B);

  static const Color border = Color(0x14FFFFFF);
  static const Color divider = Color(0x1FFFFFFF);

  static const LinearGradient screenGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0E1114),
      background,
    ],
  );
}
