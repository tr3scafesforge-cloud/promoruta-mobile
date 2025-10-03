/// Base class for use cases.
/// Use cases represent business logic operations.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Base class for use cases that don't require parameters.
abstract class UseCaseNoParams<Type> {
  Future<Type> call();
}

/// Base class for use cases that don't return a value.
abstract class UseCaseVoid<Params> {
  Future<void> call(Params params);
}

/// Base class for use cases that don't require parameters and don't return a value.
abstract class UseCaseVoidNoParams {
  Future<void> call();
}