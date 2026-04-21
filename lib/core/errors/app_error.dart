import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

/// Sealed error hierarchy for the entire app.
///
/// All layers catch exceptions at their boundary and map them to one of these
/// variants. Business logic never throws — it returns [Result<T, AppError>].
@freezed
sealed class AppError with _$AppError {
  /// A database read/write operation failed.
  const factory AppError.database({required String message}) = DatabaseError;

  /// A file-system operation failed (I/O, permissions, missing file, etc.).
  const factory AppError.fileSystem({
    required String message,
    String? path,
  }) = FileSystemError;

  /// Audio metadata could not be read or parsed.
  const factory AppError.metadata({
    required String message,
    String? path,
  }) = MetadataError;

  /// The audio playback engine reported an error.
  const factory AppError.playback({required String message}) = PlaybackError;

  /// A native platform channel or FFI call failed.
  const factory AppError.platform({required String message}) = PlatformError;

  /// A requested resource (song, playlist, etc.) could not be found.
  const factory AppError.notFound({required String message}) = NotFoundError;

  /// User-supplied input failed validation.
  const factory AppError.validation({required String message}) = ValidationError;
}
