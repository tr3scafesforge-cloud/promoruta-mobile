/// Base class for all application errors.
///
/// This sealed class hierarchy provides structured error types that can be
/// used with [Result] for type-safe error handling.
sealed class AppError implements Exception {
  /// A human-readable error message.
  final String message;

  /// Optional underlying error that caused this error.
  final Object? cause;

  /// Optional stack trace from the underlying error.
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Network-related errors (timeout, no connection, connection reset).
final class NetworkError extends AppError {
  /// The HTTP status code, if available.
  final int? statusCode;

  /// Whether this is a transient error that may be retried.
  final bool isTransient;

  const NetworkError({
    required super.message,
    this.statusCode,
    this.isTransient = true,
    super.cause,
    super.stackTrace,
  });

  /// Creates a timeout error.
  factory NetworkError.timeout({Object? cause, StackTrace? stackTrace}) {
    return NetworkError(
      message: 'Request timed out',
      isTransient: true,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates a no connection error.
  factory NetworkError.noConnection({Object? cause, StackTrace? stackTrace}) {
    return NetworkError(
      message: 'No internet connection',
      isTransient: true,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates a connection reset error.
  factory NetworkError.connectionReset({Object? cause, StackTrace? stackTrace}) {
    return NetworkError(
      message: 'Connection was reset',
      isTransient: true,
      cause: cause,
      stackTrace: stackTrace,
    );
  }
}

/// JSON parsing and schema validation errors.
final class ParsingError extends AppError {
  /// The field that caused the parsing error, if known.
  final String? field;

  /// The expected type, if known.
  final String? expectedType;

  /// The actual type received, if known.
  final String? actualType;

  const ParsingError({
    required super.message,
    this.field,
    this.expectedType,
    this.actualType,
    super.cause,
    super.stackTrace,
  });

  /// Creates a parsing error for invalid JSON.
  factory ParsingError.invalidJson({Object? cause, StackTrace? stackTrace}) {
    return ParsingError(
      message: 'Invalid JSON response',
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates a parsing error for a missing field.
  factory ParsingError.missingField(String field,
      {Object? cause, StackTrace? stackTrace}) {
    return ParsingError(
      message: 'Missing required field: $field',
      field: field,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates a parsing error for a type mismatch.
  factory ParsingError.typeMismatch({
    required String field,
    required String expectedType,
    required String actualType,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return ParsingError(
      message: 'Type mismatch for field "$field": expected $expectedType, got $actualType',
      field: field,
      expectedType: expectedType,
      actualType: actualType,
      cause: cause,
      stackTrace: stackTrace,
    );
  }
}

/// Authentication and authorization errors (401, invalid token).
final class AuthError extends AppError {
  /// The type of authentication error.
  final AuthErrorType type;

  const AuthError({
    required super.message,
    required this.type,
    super.cause,
    super.stackTrace,
  });

  /// Creates an unauthorized error (401).
  factory AuthError.unauthorized({Object? cause, StackTrace? stackTrace}) {
    return AuthError(
      message: 'Authentication required',
      type: AuthErrorType.unauthorized,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates a forbidden error (403).
  factory AuthError.forbidden({Object? cause, StackTrace? stackTrace}) {
    return AuthError(
      message: 'Access denied',
      type: AuthErrorType.forbidden,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates an invalid token error.
  factory AuthError.invalidToken({Object? cause, StackTrace? stackTrace}) {
    return AuthError(
      message: 'Invalid or expired token',
      type: AuthErrorType.invalidToken,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates a token refresh failed error.
  factory AuthError.refreshFailed({Object? cause, StackTrace? stackTrace}) {
    return AuthError(
      message: 'Failed to refresh authentication token',
      type: AuthErrorType.refreshFailed,
      cause: cause,
      stackTrace: stackTrace,
    );
  }
}

/// Types of authentication errors.
enum AuthErrorType {
  /// 401 Unauthorized.
  unauthorized,

  /// 403 Forbidden.
  forbidden,

  /// Invalid or expired token.
  invalidToken,

  /// Token refresh failed.
  refreshFailed,
}

/// Server errors (500+).
final class ServerError extends AppError {
  /// The HTTP status code.
  final int statusCode;

  /// Whether this is a transient error that may be retried.
  final bool isTransient;

  const ServerError({
    required super.message,
    required this.statusCode,
    this.isTransient = true,
    super.cause,
    super.stackTrace,
  });

  /// Creates an internal server error (500).
  factory ServerError.internal({Object? cause, StackTrace? stackTrace}) {
    return ServerError(
      message: 'Internal server error',
      statusCode: 500,
      isTransient: true,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates a service unavailable error (503).
  factory ServerError.serviceUnavailable(
      {Object? cause, StackTrace? stackTrace}) {
    return ServerError(
      message: 'Service temporarily unavailable',
      statusCode: 503,
      isTransient: true,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Creates a bad gateway error (502).
  factory ServerError.badGateway({Object? cause, StackTrace? stackTrace}) {
    return ServerError(
      message: 'Bad gateway',
      statusCode: 502,
      isTransient: true,
      cause: cause,
      stackTrace: stackTrace,
    );
  }
}

/// Form/input validation errors (422).
final class ValidationError extends AppError {
  /// Validation errors by field name.
  final Map<String, List<String>> fieldErrors;

  const ValidationError({
    required super.message,
    this.fieldErrors = const {},
    super.cause,
    super.stackTrace,
  });

  /// Creates a validation error from field errors.
  factory ValidationError.fromFields(Map<String, List<String>> fieldErrors,
      {Object? cause, StackTrace? stackTrace}) {
    final message = fieldErrors.entries
        .map((e) => '${e.key}: ${e.value.join(", ")}')
        .join('; ');
    return ValidationError(
      message: message.isEmpty ? 'Validation failed' : message,
      fieldErrors: fieldErrors,
      cause: cause,
      stackTrace: stackTrace,
    );
  }

  /// Gets the first error for a specific field, or null if none.
  String? getFieldError(String field) {
    final errors = fieldErrors[field];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }
}

/// Not found errors (404).
final class NotFoundError extends AppError {
  /// The resource type that was not found.
  final String? resourceType;

  /// The identifier of the resource that was not found.
  final String? resourceId;

  const NotFoundError({
    required super.message,
    this.resourceType,
    this.resourceId,
    super.cause,
    super.stackTrace,
  });

  /// Creates a not found error for a specific resource.
  factory NotFoundError.resource(String resourceType, String resourceId,
      {Object? cause, StackTrace? stackTrace}) {
    return NotFoundError(
      message: '$resourceType not found: $resourceId',
      resourceType: resourceType,
      resourceId: resourceId,
      cause: cause,
      stackTrace: stackTrace,
    );
  }
}

/// Unknown or unexpected errors.
final class UnknownError extends AppError {
  const UnknownError({
    required super.message,
    super.cause,
    super.stackTrace,
  });

  /// Creates an unknown error from an exception.
  factory UnknownError.fromException(Object error, StackTrace? stackTrace) {
    return UnknownError(
      message: error.toString(),
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
