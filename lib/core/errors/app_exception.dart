abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => '[$code] $message';
}

class DatabaseException extends AppException {
  DatabaseException(String message, [String? code]) : super(message, code ?? 'DB_ERROR');
}

class NotificationException extends AppException {
  NotificationException(String message, [String? code]) : super(message, code ?? 'NOTIFICATION_ERROR');
}

class ValidationException extends AppException {
  ValidationException(String message, [String? code]) : super(message, code ?? 'VALIDATION_ERROR');
}
