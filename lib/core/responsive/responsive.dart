import 'package:flutter/material.dart';

class Responsive {
  const Responsive._();

  static bool isSmallPhone(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width < 375 || size.height < 700;
  }

  static bool compactMode(BuildContext context) => isSmallPhone(context);

  static double horizontalPadding(BuildContext context) {
    return isSmallPhone(context) ? 16 : 20;
  }

  static double sectionSpacing(BuildContext context) {
    return isSmallPhone(context) ? 16 : 22;
  }

  static MediaQueryData clampTextScale(BuildContext context) {
    final media = MediaQuery.of(context);
    return media.copyWith(
      textScaler: media.textScaler.clamp(
        minScaleFactor: 1.0,
        maxScaleFactor: 1.15,
      ),
    );
  }
}
