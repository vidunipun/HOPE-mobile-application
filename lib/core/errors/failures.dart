/// Base class for all failures in the application
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure({required String message, String? code})
    : super(message: message, code: code);
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure({required String message, String? code})
    : super(message: message, code: code);
}

/// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message, String? code})
    : super(message: message, code: code);
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure({required String message, String? code})
    : super(message: message, code: code);
}

/// Storage related failures
class StorageFailure extends Failure {
  const StorageFailure({required String message, String? code})
    : super(message: message, code: code);
}

/// Generic server failure
class ServerFailure extends Failure {
  const ServerFailure({required String message, String? code})
    : super(message: message, code: code);
}
