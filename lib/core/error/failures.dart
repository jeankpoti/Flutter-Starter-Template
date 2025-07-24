import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred', String? code]) 
    : super(message, code: code);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred', String? code]) 
    : super(message, code: code);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred', String? code]) 
    : super(message, code: code);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed', String? code]) 
    : super(message, code: code);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed', String? code]) 
    : super(message, code: code);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied', String? code]) 
    : super(message, code: code);
}

/// Generic failures for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred', String? code]) 
    : super(message, code: code);
}