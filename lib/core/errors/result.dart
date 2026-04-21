import 'app_error.dart';

/// A discriminated union representing either a successful value or a failure.
///
/// Use at every layer boundary to propagate errors without throwing exceptions.
///
/// ```dart
/// final result = await repository.getSong(id);
/// result.when(
///   success: (song) => ...,
///   failure: (error) => ...,
/// );
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;

  // ---------------------------------------------------------------------------
  // Accessors
  // ---------------------------------------------------------------------------

  /// The wrapped value, or `null` if this is a [Failure].
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  /// The wrapped error, or `null` if this is a [Success].
  AppError? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  // ---------------------------------------------------------------------------
  // Transformation
  // ---------------------------------------------------------------------------

  /// Exhaustive pattern match — exactly one branch runs.
  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) =>
      switch (this) {
        Success(:final value) => success(value),
        Failure(:final error) => failure(error),
      };

  /// Transform the success value, leaving failures unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success(:final value) => Result.success(transform(value)),
        Failure(:final error) => Result.failure(error),
      };

  /// Chain a computation that itself returns a [Result].
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
        Success(:final value) => transform(value),
        Failure(:final error) => Result.failure(error),
      };
}

/// Represents a successful computation.
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed computation.
final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppError error;

  @override
  String toString() => 'Failure($error)';
}
