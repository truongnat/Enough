import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message, [String? scope]) {
    if (kDebugMode) {
      debugPrint(
        'ℹ️ [ReverseAlarm]${scope != null ? ' [$scope]' : ''}: $message',
      );
    }
  }

  static void warning(String message, [String? scope]) {
    if (kDebugMode) {
      debugPrint(
        '⚠️ [ReverseAlarm]${scope != null ? ' [$scope]' : ''}: $message',
      );
    }
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    String? scope,
  ]) {
    if (kDebugMode) {
      debugPrint(
        '❌ [ReverseAlarm]${scope != null ? ' [$scope]' : ''}: $message',
      );
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
