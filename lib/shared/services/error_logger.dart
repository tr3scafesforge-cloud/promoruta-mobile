import 'package:logger/logger.dart';
import 'package:promoruta/core/models/app_error.dart';

/// Structured error logging service.
///
/// Provides consistent error logging with structured context including
/// timestamp, operation name, error type, and stack trace.
class ErrorLogger {
  final Logger _logger;

  ErrorLogger({Logger? logger})
      : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 0,
                errorMethodCount: 5,
                lineLength: 80,
                colors: true,
                printEmojis: true,
              ),
            );

  /// Logs an error with structured context.
  ///
  /// [operation] - The operation that failed (e.g., 'token_refresh', 'fetch_campaigns')
  /// [error] - The error that occurred
  /// [stackTrace] - Optional stack trace
  /// [context] - Additional context data as key-value pairs
  void logError(
    String operation,
    Object error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final errorInfo = _ErrorInfo(
      timestamp: DateTime.now(),
      operation: operation,
      errorType: _getErrorType(error),
      message: _getErrorMessage(error),
      context: context,
    );

    _logger.e(
      _formatErrorInfo(errorInfo),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs a warning with structured context.
  void logWarning(
    String operation,
    String message, {
    Map<String, dynamic>? context,
  }) {
    final warningInfo = _ErrorInfo(
      timestamp: DateTime.now(),
      operation: operation,
      errorType: 'Warning',
      message: message,
      context: context,
    );

    _logger.w(_formatErrorInfo(warningInfo));
  }

  /// Logs a retry attempt.
  void logRetry(
    String operation, {
    required int attempt,
    required int maxAttempts,
    required Duration backoffDuration,
    Object? error,
  }) {
    _logger.i(
      '[Retry] $operation - Attempt $attempt/$maxAttempts, '
      'waiting ${backoffDuration.inMilliseconds}ms',
    );
  }

  /// Logs a successful retry.
  void logRetrySuccess(
    String operation, {
    required int attemptsTaken,
  }) {
    _logger.i(
      '[Retry Success] $operation - Succeeded after $attemptsTaken attempts',
    );
  }

  /// Logs a final retry failure.
  void logRetryExhausted(
    String operation, {
    required int maxAttempts,
    Object? error,
  }) {
    _logger.e(
      '[Retry Exhausted] $operation - Failed after $maxAttempts attempts',
      error: error,
    );
  }

  String _getErrorType(Object error) {
    if (error is AppError) {
      return switch (error) {
        NetworkError() => 'NetworkError',
        ParsingError() => 'ParsingError',
        AuthError() => 'AuthError',
        ServerError() => 'ServerError',
        ValidationError() => 'ValidationError',
        NotFoundError() => 'NotFoundError',
        UnknownError() => 'UnknownError',
      };
    }
    return error.runtimeType.toString();
  }

  String _getErrorMessage(Object error) {
    if (error is AppError) {
      return error.message;
    }
    return error.toString();
  }

  String _formatErrorInfo(_ErrorInfo info) {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════════════════');
    buffer.writeln('Timestamp: ${info.timestamp.toIso8601String()}');
    buffer.writeln('Operation: ${info.operation}');
    buffer.writeln('Error Type: ${info.errorType}');
    buffer.writeln('Message: ${info.message}');

    if (info.context != null && info.context!.isNotEmpty) {
      buffer.writeln('Context:');
      for (final entry in info.context!.entries) {
        buffer.writeln('  ${entry.key}: ${entry.value}');
      }
    }

    buffer.write('═══════════════════════════════════════════════════════');
    return buffer.toString();
  }
}

class _ErrorInfo {
  final DateTime timestamp;
  final String operation;
  final String errorType;
  final String message;
  final Map<String, dynamic>? context;

  const _ErrorInfo({
    required this.timestamp,
    required this.operation,
    required this.errorType,
    required this.message,
    this.context,
  });
}
