import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:promoruta/core/models/app_error.dart';
import 'package:promoruta/shared/constants/time_thresholds.dart';
import 'package:promoruta/shared/services/error_logger.dart';

/// Service for retrying operations with exponential backoff.
///
/// Retries transient errors (network timeouts, 5xx errors) with increasing
/// delays. Non-transient errors (401, 422) fail immediately without retry.
class RetryService {
  final ErrorLogger _errorLogger;

  RetryService({ErrorLogger? errorLogger})
      : _errorLogger = errorLogger ?? ErrorLogger();

  /// Retries an async operation with exponential backoff.
  ///
  /// [operation] - The async operation to retry
  /// [operationName] - Name for logging purposes
  /// [maxRetries] - Maximum number of retry attempts (default from TimeThresholds)
  /// [baseDelay] - Initial delay duration (default from TimeThresholds)
  /// [maxDelay] - Maximum delay duration (default from TimeThresholds)
  ///
  /// Returns the result of the operation if successful.
  /// Throws the last error if all retries are exhausted.
  Future<T> retryAsync<T>(
    Future<T> Function() operation, {
    required String operationName,
    int? maxRetries,
    Duration? baseDelay,
    Duration? maxDelay,
  }) async {
    final maxAttempts = maxRetries ?? TimeThresholds.maxRetryAttempts;
    final baseDuration = baseDelay ?? TimeThresholds.retryDelayBase;
    final maxDuration = maxDelay ?? TimeThresholds.retryDelayMax;

    Object? lastError;
    StackTrace? lastStackTrace;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        lastError = e;
        lastStackTrace = stackTrace;

        // Check if error is transient (retryable)
        if (!_isTransientError(e)) {
          _errorLogger.logError(
            operationName,
            e,
            stackTrace: stackTrace,
            context: {'attempt': attempt, 'transient': false},
          );
          rethrow;
        }

        // Last attempt - don't retry
        if (attempt == maxAttempts) {
          _errorLogger.logRetryExhausted(
            operationName,
            maxAttempts: maxAttempts,
            error: e,
          );
          rethrow;
        }

        // Calculate backoff delay with exponential increase
        final backoffMultiplier = 1 << (attempt - 1); // 2^(attempt-1)
        var delay = baseDuration * backoffMultiplier;
        if (delay > maxDuration) {
          delay = maxDuration;
        }

        _errorLogger.logRetry(
          operationName,
          attempt: attempt,
          maxAttempts: maxAttempts,
          backoffDuration: delay,
          error: e,
        );

        await Future.delayed(delay);
      }
    }

    // Should not reach here, but just in case
    throw lastError ?? UnknownError(
      message: 'Retry failed with no error captured',
      stackTrace: lastStackTrace,
    );
  }

  /// Determines if an error is transient and can be retried.
  bool _isTransientError(Object error) {
    // DioException handling
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return true;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            return _isTransientStatusCode(statusCode);
          }
          return false;
        case DioExceptionType.cancel:
        case DioExceptionType.badCertificate:
        case DioExceptionType.unknown:
          return false;
      }
    }

    // AppError handling
    if (error is AppError) {
      return switch (error) {
        NetworkError(:final isTransient) => isTransient,
        ServerError(:final isTransient) => isTransient,
        // Non-retryable errors
        AuthError() => false,
        ValidationError() => false,
        NotFoundError() => false,
        ParsingError() => false,
        UnknownError() => false,
      };
    }

    // Socket/IO exceptions are usually transient
    if (error is SocketException) {
      return true;
    }

    // TimeoutException is transient
    if (error is TimeoutException) {
      return true;
    }

    return false;
  }

  /// Determines if an HTTP status code represents a transient error.
  bool _isTransientStatusCode(int statusCode) {
    // 5xx server errors (except 501 Not Implemented)
    if (statusCode >= 500 && statusCode != 501) {
      return true;
    }

    // 429 Too Many Requests
    if (statusCode == 429) {
      return true;
    }

    // 408 Request Timeout
    if (statusCode == 408) {
      return true;
    }

    return false;
  }
}
