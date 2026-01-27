import 'package:promoruta/core/result.dart';

/// Base class for use cases.
/// Use cases represent business logic operations.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Base class for use cases that don't require parameters.
abstract class UseCaseNoParams<T> {
  Future<T> call();
}

/// Base class for use cases that don't return a value.
abstract class UseCaseVoid<Params> {
  Future<void> call(Params params);
}

/// Base class for use cases that don't require parameters and don't return a value.
abstract class UseCaseVoidNoParams {
  Future<void> call();
}

/// Base class for use cases that return a Result.
abstract class UseCaseResult<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Base class for use cases that don't require parameters and return a Result.
abstract class UseCaseResultNoParams<T> {
  Future<Result<T>> call();
}

/// Base class for use cases that don't return a value but return a Result.
abstract class UseCaseResultVoid<Params> {
  Future<Result<void>> call(Params params);
}

/// Base class for use cases that don't require parameters and don't return a value but return a Result.
abstract class UseCaseResultVoidNoParams {
  Future<Result<void>> call();
}
