import '../error/failures.dart';

/// Result class for structured error handling
sealed class Result<T> {
  const Result();
}

/// Success case containing data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Error case containing failure information
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Extension methods for easier Result handling
extension ResultExtensions<T> on Result<T> {
  /// Check if result is successful
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is error
  bool get isError => this is Error<T>;
  
  /// Get data if successful, null otherwise
  T? get data => isSuccess ? (this as Success<T>).data : null;
  
  /// Get failure if error, null otherwise
  Failure? get failure => isError ? (this as Error<T>).failure : null;
  
  /// Pattern matching helper for handling both success and error cases
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Error<T>(:final failure) => error(failure),
    };
  }
  
  /// Map success value to another type
  Result<R> map<R>(R Function(T) mapper) {
    return switch (this) {
      Success<T>(:final data) => Success(mapper(data)),
      Error<T>() => Error(failure!),
    };
  }
  
  /// Flat map for chaining operations that return Result
  Result<R> flatMap<R>(Result<R> Function(T) mapper) {
    return switch (this) {
      Success<T>(:final data) => mapper(data),
      Error<T>() => Error(failure!),
    };
  }
  
  /// Get data or throw if error
  T getOrThrow() {
    return switch (this) {
      Success<T>(:final data) => data,
      Error<T>(:final failure) => throw Exception(failure.message),
    };
  }
  
  /// Get data or return default value if error
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T>(:final data) => data,
      Error<T>() => defaultValue,
    };
  }
}