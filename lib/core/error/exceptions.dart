/// Base class for all exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException([String message = 'Server error occurred', String? code]) 
    : super(message, code: code);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException([String message = 'Cache error occurred', String? code]) 
    : super(message, code: code);
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException([String message = 'Network error occurred', String? code]) 
    : super(message, code: code);
}

/// Firebase-related exceptions
class FirebaseAppException extends AppException {
  const FirebaseAppException([String message = 'Firebase error occurred', String? code]) 
    : super(message, code: code);
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException([String message = 'Authentication failed', String? code]) 
    : super(message, code: code);
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException([String message = 'Permission denied', String? code]) 
    : super(message, code: code);
}