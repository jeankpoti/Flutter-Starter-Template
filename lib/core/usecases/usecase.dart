import '../utils/result.dart';

/// Base class for all use cases
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Use case that doesn't require parameters
abstract class NoParamsUseCase<Type> {
  Future<Result<Type>> call();
}

/// Synchronous use case with parameters
abstract class SyncUseCase<Type, Params> {
  Result<Type> call(Params params);
}

/// Synchronous use case without parameters
abstract class SyncNoParamsUseCase<Type> {
  Result<Type> call();
}

/// No parameters class for use cases that don't need input
class NoParams {
  const NoParams();
}