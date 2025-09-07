/// A generic result class that represents either success or failure
sealed class Result<T> {
  const Result();
}

/// Represents a successful result with data
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';
}

/// Represents a failed result with error information
class Error<T> extends Result<T> {
  final String message;
  final String? code;

  const Error({required this.message, this.code});

  @override
  String toString() =>
      'Error(message: $message${code != null ? ', code: $code' : ''})';
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Returns true if the result is successful
  bool get isSuccess => this is Success<T>;

  /// Returns true if the result is an error
  bool get isError => this is Error<T>;

  /// Returns the data if successful, null otherwise
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// Returns the error message if failed, null otherwise
  String? get errorOrNull => isError ? (this as Error<T>).message : null;

  /// Returns the data if successful, or the provided default value
  T dataOr(T defaultValue) =>
      isSuccess ? (this as Success<T>).data : defaultValue;

  /// Executes a function if the result is successful
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      try {
        return Success(mapper((this as Success<T>).data));
      } catch (e) {
        return Error(message: e.toString());
      }
    }
    return Error(
      message: (this as Error<T>).message,
      code: (this as Error<T>).code,
    );
  }

  /// Executes a function if the result is successful, otherwise returns the error
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    if (isSuccess) {
      return mapper((this as Success<T>).data);
    }
    return Error(
      message: (this as Error<T>).message,
      code: (this as Error<T>).code,
    );
  }
}
