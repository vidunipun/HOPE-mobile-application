/// Base class for all exceptions in the application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException({required String message, String? code})
    : super(message: message, code: code);
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException({required String message, String? code})
    : super(message: message, code: code);
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException({required String message, String? code})
    : super(message: message, code: code);
}

/// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException({required String message, String? code})
    : super(message: message, code: code);
}

/// Storage related exceptions
class StorageException extends AppException {
  const StorageException({required String message, String? code})
    : super(message: message, code: code);
}

/// Generic server exception
class ServerException extends AppException {
  const ServerException({required String message, String? code})
    : super(message: message, code: code);
}
