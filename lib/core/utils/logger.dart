import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message, [String? scope]) {
    if (kDebugMode) {
      print('ℹ️ [ReverseAlarm]${scope != null ? ' [$scope]' : ''}: $message');
    }
  }

  static void warning(String message, [String? scope]) {
    if (kDebugMode) {
      print('⚠️ [ReverseAlarm]${scope != null ? ' [$scope]' : ''}: $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? scope]) {
    if (kDebugMode) {
      print('❌ [ReverseAlarm]${scope != null ? ' [$scope]' : ''}: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
}
