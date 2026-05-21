import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle _base = TextStyle(
    fontFamily: 'SF Pro Display',
    color: AppColors.textPrimary,
  );

  // Headings
  static TextStyle get h1 => _base.copyWith(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        height: 1.05,
        letterSpacing: -1.2,
      );

  static TextStyle get h2 => _base.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.8,
      );

  static TextStyle get h3 => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get h4 => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // Body
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // Labels
  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 0.6,
      );

  // Special
  static TextStyle get alarmTime => _base.copyWith(
        fontSize: 58,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: -2.5,
      );

  static TextStyle get stopTitle => _base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: -1.4,
      );

  static TextStyle get receiptTitle => _base.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.0,
        letterSpacing: 1.1,
      );

  static TextStyle get receiptBody => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get overline => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 1.2,
      );

  // Secondary text
  static TextStyle bodySecondary(Color color) => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle labelSecondary(Color color) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );
}
