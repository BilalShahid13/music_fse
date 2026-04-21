// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScanFolder {
  int get id;
  String get path;
  bool get enabled;
  DateTime? get lastScannedAt;

  /// Create a copy of ScanFolder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ScanFolderCopyWith<ScanFolder> get copyWith =>
      _$ScanFolderCopyWithImpl<ScanFolder>(this as ScanFolder, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ScanFolder &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.lastScannedAt, lastScannedAt) ||
                other.lastScannedAt == lastScannedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, path, enabled, lastScannedAt);

  @override
  String toString() {
    return 'ScanFolder(id: $id, path: $path, enabled: $enabled, lastScannedAt: $lastScannedAt)';
  }
}

/// @nodoc
abstract mixin class $ScanFolderCopyWith<$Res> {
  factory $ScanFolderCopyWith(
          ScanFolder value, $Res Function(ScanFolder) _then) =
      _$ScanFolderCopyWithImpl;
  @useResult
  $Res call({int id, String path, bool enabled, DateTime? lastScannedAt});
}

/// @nodoc
class _$ScanFolderCopyWithImpl<$Res> implements $ScanFolderCopyWith<$Res> {
  _$ScanFolderCopyWithImpl(this._self, this._then);

  final ScanFolder _self;
  final $Res Function(ScanFolder) _then;

  /// Create a copy of ScanFolder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? enabled = null,
    Object? lastScannedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      path: null == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastScannedAt: freezed == lastScannedAt
          ? _self.lastScannedAt
          : lastScannedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ScanFolder].
extension ScanFolderPatterns on ScanFolder {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ScanFolder value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScanFolder() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_ScanFolder value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanFolder():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ScanFolder value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanFolder() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id, String path, bool enabled, DateTime? lastScannedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ScanFolder() when $default != null:
        return $default(
            _that.id, _that.path, _that.enabled, _that.lastScannedAt);
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
  TResult when<TResult extends Object?>(
    TResult Function(int id, String path, bool enabled, DateTime? lastScannedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanFolder():
        return $default(
            _that.id, _that.path, _that.enabled, _that.lastScannedAt);
      case _:
        throw StateError('Unexpected subclass');
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id, String path, bool enabled, DateTime? lastScannedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ScanFolder() when $default != null:
        return $default(
            _that.id, _that.path, _that.enabled, _that.lastScannedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ScanFolder implements ScanFolder {
  const _ScanFolder(
      {required this.id,
      required this.path,
      this.enabled = true,
      this.lastScannedAt});

  @override
  final int id;
  @override
  final String path;
  @override
  @JsonKey()
  final bool enabled;
  @override
  final DateTime? lastScannedAt;

  /// Create a copy of ScanFolder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ScanFolderCopyWith<_ScanFolder> get copyWith =>
      __$ScanFolderCopyWithImpl<_ScanFolder>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ScanFolder &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.lastScannedAt, lastScannedAt) ||
                other.lastScannedAt == lastScannedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, path, enabled, lastScannedAt);

  @override
  String toString() {
    return 'ScanFolder(id: $id, path: $path, enabled: $enabled, lastScannedAt: $lastScannedAt)';
  }
}

/// @nodoc
abstract mixin class _$ScanFolderCopyWith<$Res>
    implements $ScanFolderCopyWith<$Res> {
  factory _$ScanFolderCopyWith(
          _ScanFolder value, $Res Function(_ScanFolder) _then) =
      __$ScanFolderCopyWithImpl;
  @override
  @useResult
  $Res call({int id, String path, bool enabled, DateTime? lastScannedAt});
}

/// @nodoc
class __$ScanFolderCopyWithImpl<$Res> implements _$ScanFolderCopyWith<$Res> {
  __$ScanFolderCopyWithImpl(this._self, this._then);

  final _ScanFolder _self;
  final $Res Function(_ScanFolder) _then;

  /// Create a copy of ScanFolder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? enabled = null,
    Object? lastScannedAt = freezed,
  }) {
    return _then(_ScanFolder(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      path: null == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastScannedAt: freezed == lastScannedAt
          ? _self.lastScannedAt
          : lastScannedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
