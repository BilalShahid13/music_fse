// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QueueItem {
  Song get song;
  int get sortOrder;
  bool get isCurrent;

  /// Position within this item, used for resume-from-queue on app restart.
  int get positionMs;

  /// Create a copy of QueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QueueItemCopyWith<QueueItem> get copyWith =>
      _$QueueItemCopyWithImpl<QueueItem>(this as QueueItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QueueItem &&
            (identical(other.song, song) || other.song == song) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
            (identical(other.positionMs, positionMs) ||
                other.positionMs == positionMs));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, song, sortOrder, isCurrent, positionMs);

  @override
  String toString() {
    return 'QueueItem(song: $song, sortOrder: $sortOrder, isCurrent: $isCurrent, positionMs: $positionMs)';
  }
}

/// @nodoc
abstract mixin class $QueueItemCopyWith<$Res> {
  factory $QueueItemCopyWith(QueueItem value, $Res Function(QueueItem) _then) =
      _$QueueItemCopyWithImpl;
  @useResult
  $Res call({Song song, int sortOrder, bool isCurrent, int positionMs});

  $SongCopyWith<$Res> get song;
}

/// @nodoc
class _$QueueItemCopyWithImpl<$Res> implements $QueueItemCopyWith<$Res> {
  _$QueueItemCopyWithImpl(this._self, this._then);

  final QueueItem _self;
  final $Res Function(QueueItem) _then;

  /// Create a copy of QueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? song = null,
    Object? sortOrder = null,
    Object? isCurrent = null,
    Object? positionMs = null,
  }) {
    return _then(_self.copyWith(
      song: null == song
          ? _self.song
          : song // ignore: cast_nullable_to_non_nullable
              as Song,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isCurrent: null == isCurrent
          ? _self.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      positionMs: null == positionMs
          ? _self.positionMs
          : positionMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of QueueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SongCopyWith<$Res> get song {
    return $SongCopyWith<$Res>(_self.song, (value) {
      return _then(_self.copyWith(song: value));
    });
  }
}

/// Adds pattern-matching-related methods to [QueueItem].
extension QueueItemPatterns on QueueItem {
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
    TResult Function(_QueueItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QueueItem() when $default != null:
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
    TResult Function(_QueueItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QueueItem():
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
    TResult? Function(_QueueItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QueueItem() when $default != null:
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
    TResult Function(Song song, int sortOrder, bool isCurrent, int positionMs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QueueItem() when $default != null:
        return $default(
            _that.song, _that.sortOrder, _that.isCurrent, _that.positionMs);
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
    TResult Function(Song song, int sortOrder, bool isCurrent, int positionMs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QueueItem():
        return $default(
            _that.song, _that.sortOrder, _that.isCurrent, _that.positionMs);
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
    TResult? Function(Song song, int sortOrder, bool isCurrent, int positionMs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QueueItem() when $default != null:
        return $default(
            _that.song, _that.sortOrder, _that.isCurrent, _that.positionMs);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _QueueItem implements QueueItem {
  const _QueueItem(
      {required this.song,
      required this.sortOrder,
      this.isCurrent = false,
      this.positionMs = 0});

  @override
  final Song song;
  @override
  final int sortOrder;
  @override
  @JsonKey()
  final bool isCurrent;

  /// Position within this item, used for resume-from-queue on app restart.
  @override
  @JsonKey()
  final int positionMs;

  /// Create a copy of QueueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QueueItemCopyWith<_QueueItem> get copyWith =>
      __$QueueItemCopyWithImpl<_QueueItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QueueItem &&
            (identical(other.song, song) || other.song == song) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
            (identical(other.positionMs, positionMs) ||
                other.positionMs == positionMs));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, song, sortOrder, isCurrent, positionMs);

  @override
  String toString() {
    return 'QueueItem(song: $song, sortOrder: $sortOrder, isCurrent: $isCurrent, positionMs: $positionMs)';
  }
}

/// @nodoc
abstract mixin class _$QueueItemCopyWith<$Res>
    implements $QueueItemCopyWith<$Res> {
  factory _$QueueItemCopyWith(
          _QueueItem value, $Res Function(_QueueItem) _then) =
      __$QueueItemCopyWithImpl;
  @override
  @useResult
  $Res call({Song song, int sortOrder, bool isCurrent, int positionMs});

  @override
  $SongCopyWith<$Res> get song;
}

/// @nodoc
class __$QueueItemCopyWithImpl<$Res> implements _$QueueItemCopyWith<$Res> {
  __$QueueItemCopyWithImpl(this._self, this._then);

  final _QueueItem _self;
  final $Res Function(_QueueItem) _then;

  /// Create a copy of QueueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? song = null,
    Object? sortOrder = null,
    Object? isCurrent = null,
    Object? positionMs = null,
  }) {
    return _then(_QueueItem(
      song: null == song
          ? _self.song
          : song // ignore: cast_nullable_to_non_nullable
              as Song,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isCurrent: null == isCurrent
          ? _self.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      positionMs: null == positionMs
          ? _self.positionMs
          : positionMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of QueueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SongCopyWith<$Res> get song {
    return $SongCopyWith<$Res>(_self.song, (value) {
      return _then(_self.copyWith(song: value));
    });
  }
}

// dart format on
