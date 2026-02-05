/// A Result type for consistent error handling across the application.
///
/// This sealed class represents either a successful value [Success] or a
/// failure [Failure]. It provides type-safe error handling without exceptions.
///
/// Example usage:
/// ```dart
/// final result = await repository.fetchData();
/// result.fold(
///   (data) => print('Success: $data'),
///   (error) => print('Error: ${error.message}'),
/// );
/// ```
sealed class Result<T, E> {
  const Result._();

  /// Creates a successful result with the given [value].
  factory Result.success(T value) = Success<T, E>;

  /// Creates a failure result with the given [error].
  factory Result.failure(E error) = Failure<T, E>;

  /// Returns true if this is a [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Returns true if this is a [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// Returns the success value, or null if this is a [Failure].
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  /// Returns the error, or null if this is a [Success].
  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// Folds the result into a single value.
  ///
  /// If this is a [Success], applies [onSuccess] to the value.
  /// If this is a [Failure], applies [onFailure] to the error.
  R fold<R>(R Function(T value) onSuccess, R Function(E error) onFailure) {
    return switch (this) {
      Success(:final value) => onSuccess(value),
      Failure(:final error) => onFailure(error),
    };
  }

  /// Transforms the success value using [f], leaving failures unchanged.
  Result<U, E> mapSuccess<U>(U Function(T value) f) {
    return switch (this) {
      Success(:final value) => Result.success(f(value)),
      Failure(:final error) => Result.failure(error),
    };
  }

  /// Transforms the error using [f], leaving successes unchanged.
  Result<T, F> mapFailure<F>(F Function(E error) f) {
    return switch (this) {
      Success(:final value) => Result.success(value),
      Failure(:final error) => Result.failure(f(error)),
    };
  }

  /// Chains another Result-returning operation on success.
  ///
  /// If this is a [Success], applies [f] to the value and returns the result.
  /// If this is a [Failure], returns the failure unchanged.
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) f) {
    return switch (this) {
      Success(:final value) => f(value),
      Failure(:final error) => Result.failure(error),
    };
  }

  /// Returns the success value, or [defaultValue] if this is a [Failure].
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(:final value) => value,
      Failure() => defaultValue,
    };
  }

  /// Returns the success value, or computes it from [orElse] if this is a [Failure].
  T getOrElseCompute(T Function(E error) orElse) {
    return switch (this) {
      Success(:final value) => value,
      Failure(:final error) => orElse(error),
    };
  }
}

/// Represents a successful result containing a [value].
final class Success<T, E> extends Result<T, E> {
  /// The successful value.
  final T value;

  /// Creates a successful result with the given [value].
  const Success(this.value) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result containing an [error].
final class Failure<T, E> extends Result<T, E> {
  /// The error that caused the failure.
  final E error;

  /// Creates a failure result with the given [error].
  const Failure(this.error) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Failure($error)';
}
