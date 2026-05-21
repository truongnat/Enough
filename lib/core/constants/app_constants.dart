class AppConstants {
  static const String appName = 'Enough';
  static const String appSubtitle = 'Reverse Alarm';
  static const String slogan = 'The alarm for stopping, not starting.';
  static const String appVersion = '1.0.0';

  // Spacing & Sizing
  static const double paddingNone = 0.0;
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;
  static const double padding3XL = 32.0;
  
  // Card & Container Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radius3XL = 28.0;

  // Animations & Delays
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // Business Logic Defaults
  static const int defaultSnoozeMinutes = 10;
  static const int maxSnoozeCount = 3;
  static const int missedThresholdHours = 2;
}
