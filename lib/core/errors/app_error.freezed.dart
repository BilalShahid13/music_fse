// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppError {
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppErrorCopyWith<AppError> get copyWith =>
      _$AppErrorCopyWithImpl<AppError>(this as AppError, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AppError(message: $message)';
  }
}

/// @nodoc
abstract mixin class $AppErrorCopyWith<$Res> {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) _then) =
      _$AppErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppErrorCopyWithImpl<$Res> implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._self, this._then);

  final AppError _self;
  final $Res Function(AppError) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_self.copyWith(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AppError].
extension AppErrorPatterns on AppError {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DatabaseError value)? database,
    TResult Function(FileSystemError value)? fileSystem,
    TResult Function(MetadataError value)? metadata,
    TResult Function(PlaybackError value)? playback,
    TResult Function(PlatformError value)? platform,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DatabaseError() when database != null:
        return database(_that);
      case FileSystemError() when fileSystem != null:
        return fileSystem(_that);
      case MetadataError() when metadata != null:
        return metadata(_that);
      case PlaybackError() when playback != null:
        return playback(_that);
      case PlatformError() when platform != null:
        return platform(_that);
      case NotFoundError() when notFound != null:
        return notFound(_that);
      case ValidationError() when validation != null:
        return validation(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DatabaseError value) database,
    required TResult Function(FileSystemError value) fileSystem,
    required TResult Function(MetadataError value) metadata,
    required TResult Function(PlaybackError value) playback,
    required TResult Function(PlatformError value) platform,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
  }) {
    final _that = this;
    switch (_that) {
      case DatabaseError():
        return database(_that);
      case FileSystemError():
        return fileSystem(_that);
      case MetadataError():
        return metadata(_that);
      case PlaybackError():
        return playback(_that);
      case PlatformError():
        return platform(_that);
      case NotFoundError():
        return notFound(_that);
      case ValidationError():
        return validation(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DatabaseError value)? database,
    TResult? Function(FileSystemError value)? fileSystem,
    TResult? Function(MetadataError value)? metadata,
    TResult? Function(PlaybackError value)? playback,
    TResult? Function(PlatformError value)? platform,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
  }) {
    final _that = this;
    switch (_that) {
      case DatabaseError() when database != null:
        return database(_that);
      case FileSystemError() when fileSystem != null:
        return fileSystem(_that);
      case MetadataError() when metadata != null:
        return metadata(_that);
      case PlaybackError() when playback != null:
        return playback(_that);
      case PlatformError() when platform != null:
        return platform(_that);
      case NotFoundError() when notFound != null:
        return notFound(_that);
      case ValidationError() when validation != null:
        return validation(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? database,
    TResult Function(String message, String? path)? fileSystem,
    TResult Function(String message, String? path)? metadata,
    TResult Function(String message)? playback,
    TResult Function(String message)? platform,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case DatabaseError() when database != null:
        return database(_that.message);
      case FileSystemError() when fileSystem != null:
        return fileSystem(_that.message, _that.path);
      case MetadataError() when metadata != null:
        return metadata(_that.message, _that.path);
      case PlaybackError() when playback != null:
        return playback(_that.message);
      case PlatformError() when platform != null:
        return platform(_that.message);
      case NotFoundError() when notFound != null:
        return notFound(_that.message);
      case ValidationError() when validation != null:
        return validation(_that.message);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) database,
    required TResult Function(String message, String? path) fileSystem,
    required TResult Function(String message, String? path) metadata,
    required TResult Function(String message) playback,
    required TResult Function(String message) platform,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
  }) {
    final _that = this;
    switch (_that) {
      case DatabaseError():
        return database(_that.message);
      case FileSystemError():
        return fileSystem(_that.message, _that.path);
      case MetadataError():
        return metadata(_that.message, _that.path);
      case PlaybackError():
        return playback(_that.message);
      case PlatformError():
        return platform(_that.message);
      case NotFoundError():
        return notFound(_that.message);
      case ValidationError():
        return validation(_that.message);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? database,
    TResult? Function(String message, String? path)? fileSystem,
    TResult? Function(String message, String? path)? metadata,
    TResult? Function(String message)? playback,
    TResult? Function(String message)? platform,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
  }) {
    final _that = this;
    switch (_that) {
      case DatabaseError() when database != null:
        return database(_that.message);
      case FileSystemError() when fileSystem != null:
        return fileSystem(_that.message, _that.path);
      case MetadataError() when metadata != null:
        return metadata(_that.message, _that.path);
      case PlaybackError() when playback != null:
        return playback(_that.message);
      case PlatformError() when platform != null:
        return platform(_that.message);
      case NotFoundError() when notFound != null:
        return notFound(_that.message);
      case ValidationError() when validation != null:
        return validation(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class DatabaseError implements AppError {
  const DatabaseError({required this.message});

  @override
  final String message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DatabaseErrorCopyWith<DatabaseError> get copyWith =>
      _$DatabaseErrorCopyWithImpl<DatabaseError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DatabaseError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AppError.database(message: $message)';
  }
}

/// @nodoc
abstract mixin class $DatabaseErrorCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory $DatabaseErrorCopyWith(
          DatabaseError value, $Res Function(DatabaseError) _then) =
      _$DatabaseErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$DatabaseErrorCopyWithImpl<$Res>
    implements $DatabaseErrorCopyWith<$Res> {
  _$DatabaseErrorCopyWithImpl(this._self, this._then);

  final DatabaseError _self;
  final $Res Function(DatabaseError) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(DatabaseError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class FileSystemError implements AppError {
  const FileSystemError({required this.message, this.path});

  @override
  final String message;
  final String? path;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FileSystemErrorCopyWith<FileSystemError> get copyWith =>
      _$FileSystemErrorCopyWithImpl<FileSystemError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FileSystemError &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.path, path) || other.path == path));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, path);

  @override
  String toString() {
    return 'AppError.fileSystem(message: $message, path: $path)';
  }
}

/// @nodoc
abstract mixin class $FileSystemErrorCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory $FileSystemErrorCopyWith(
          FileSystemError value, $Res Function(FileSystemError) _then) =
      _$FileSystemErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String message, String? path});
}

/// @nodoc
class _$FileSystemErrorCopyWithImpl<$Res>
    implements $FileSystemErrorCopyWith<$Res> {
  _$FileSystemErrorCopyWithImpl(this._self, this._then);

  final FileSystemError _self;
  final $Res Function(FileSystemError) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? path = freezed,
  }) {
    return _then(FileSystemError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class MetadataError implements AppError {
  const MetadataError({required this.message, this.path});

  @override
  final String message;
  final String? path;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MetadataErrorCopyWith<MetadataError> get copyWith =>
      _$MetadataErrorCopyWithImpl<MetadataError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MetadataError &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.path, path) || other.path == path));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, path);

  @override
  String toString() {
    return 'AppError.metadata(message: $message, path: $path)';
  }
}

/// @nodoc
abstract mixin class $MetadataErrorCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory $MetadataErrorCopyWith(
          MetadataError value, $Res Function(MetadataError) _then) =
      _$MetadataErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String message, String? path});
}

/// @nodoc
class _$MetadataErrorCopyWithImpl<$Res>
    implements $MetadataErrorCopyWith<$Res> {
  _$MetadataErrorCopyWithImpl(this._self, this._then);

  final MetadataError _self;
  final $Res Function(MetadataError) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? path = freezed,
  }) {
    return _then(MetadataError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      path: freezed == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class PlaybackError implements AppError {
  const PlaybackError({required this.message});

  @override
  final String message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlaybackErrorCopyWith<PlaybackError> get copyWith =>
      _$PlaybackErrorCopyWithImpl<PlaybackError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlaybackError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AppError.playback(message: $message)';
  }
}

/// @nodoc
abstract mixin class $PlaybackErrorCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory $PlaybackErrorCopyWith(
          PlaybackError value, $Res Function(PlaybackError) _then) =
      _$PlaybackErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$PlaybackErrorCopyWithImpl<$Res>
    implements $PlaybackErrorCopyWith<$Res> {
  _$PlaybackErrorCopyWithImpl(this._self, this._then);

  final PlaybackError _self;
  final $Res Function(PlaybackError) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(PlaybackError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class PlatformError implements AppError {
  const PlatformError({required this.message});

  @override
  final String message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlatformErrorCopyWith<PlatformError> get copyWith =>
      _$PlatformErrorCopyWithImpl<PlatformError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlatformError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AppError.platform(message: $message)';
  }
}

/// @nodoc
abstract mixin class $PlatformErrorCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory $PlatformErrorCopyWith(
          PlatformError value, $Res Function(PlatformError) _then) =
      _$PlatformErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$PlatformErrorCopyWithImpl<$Res>
    implements $PlatformErrorCopyWith<$Res> {
  _$PlatformErrorCopyWithImpl(this._self, this._then);

  final PlatformError _self;
  final $Res Function(PlatformError) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(PlatformError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class NotFoundError implements AppError {
  const NotFoundError({required this.message});

  @override
  final String message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotFoundErrorCopyWith<NotFoundError> get copyWith =>
      _$NotFoundErrorCopyWithImpl<NotFoundError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotFoundError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AppError.notFound(message: $message)';
  }
}

/// @nodoc
abstract mixin class $NotFoundErrorCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory $NotFoundErrorCopyWith(
          NotFoundError value, $Res Function(NotFoundError) _then) =
      _$NotFoundErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$NotFoundErrorCopyWithImpl<$Res>
    implements $NotFoundErrorCopyWith<$Res> {
  _$NotFoundErrorCopyWithImpl(this._self, this._then);

  final NotFoundError _self;
  final $Res Function(NotFoundError) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(NotFoundError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ValidationError implements AppError {
  const ValidationError({required this.message});

  @override
  final String message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ValidationErrorCopyWith<ValidationError> get copyWith =>
      _$ValidationErrorCopyWithImpl<ValidationError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ValidationError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'AppError.validation(message: $message)';
  }
}

/// @nodoc
abstract mixin class $ValidationErrorCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(
          ValidationError value, $Res Function(ValidationError) _then) =
      _$ValidationErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._self, this._then);

  final ValidationError _self;
  final $Res Function(ValidationError) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(ValidationError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
