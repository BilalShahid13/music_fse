// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayHistoryEntry {
  int get id;
  int get songId;
  DateTime get playedAt;

  /// How many milliseconds of the track were actually listened to.
  int get durationListenedMs;

  /// Numeric session identifier — incremented each time the app launches.
  int get sessionId;

  /// Create a copy of PlayHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlayHistoryEntryCopyWith<PlayHistoryEntry> get copyWith =>
      _$PlayHistoryEntryCopyWithImpl<PlayHistoryEntry>(
          this as PlayHistoryEntry, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlayHistoryEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.songId, songId) || other.songId == songId) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt) &&
            (identical(other.durationListenedMs, durationListenedMs) ||
                other.durationListenedMs == durationListenedMs) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, songId, playedAt, durationListenedMs, sessionId);

  @override
  String toString() {
    return 'PlayHistoryEntry(id: $id, songId: $songId, playedAt: $playedAt, durationListenedMs: $durationListenedMs, sessionId: $sessionId)';
  }
}

/// @nodoc
abstract mixin class $PlayHistoryEntryCopyWith<$Res> {
  factory $PlayHistoryEntryCopyWith(
          PlayHistoryEntry value, $Res Function(PlayHistoryEntry) _then) =
      _$PlayHistoryEntryCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      int songId,
      DateTime playedAt,
      int durationListenedMs,
      int sessionId});
}

/// @nodoc
class _$PlayHistoryEntryCopyWithImpl<$Res>
    implements $PlayHistoryEntryCopyWith<$Res> {
  _$PlayHistoryEntryCopyWithImpl(this._self, this._then);

  final PlayHistoryEntry _self;
  final $Res Function(PlayHistoryEntry) _then;

  /// Create a copy of PlayHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? songId = null,
    Object? playedAt = null,
    Object? durationListenedMs = null,
    Object? sessionId = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      songId: null == songId
          ? _self.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as int,
      playedAt: null == playedAt
          ? _self.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationListenedMs: null == durationListenedMs
          ? _self.durationListenedMs
          : durationListenedMs // ignore: cast_nullable_to_non_nullable
              as int,
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PlayHistoryEntry].
extension PlayHistoryEntryPatterns on PlayHistoryEntry {
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
    TResult Function(_PlayHistoryEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlayHistoryEntry() when $default != null:
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
    TResult Function(_PlayHistoryEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlayHistoryEntry():
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
    TResult? Function(_PlayHistoryEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlayHistoryEntry() when $default != null:
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
    TResult Function(int id, int songId, DateTime playedAt,
            int durationListenedMs, int sessionId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlayHistoryEntry() when $default != null:
        return $default(_that.id, _that.songId, _that.playedAt,
            _that.durationListenedMs, _that.sessionId);
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
    TResult Function(int id, int songId, DateTime playedAt,
            int durationListenedMs, int sessionId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlayHistoryEntry():
        return $default(_that.id, _that.songId, _that.playedAt,
            _that.durationListenedMs, _that.sessionId);
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
    TResult? Function(int id, int songId, DateTime playedAt,
            int durationListenedMs, int sessionId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlayHistoryEntry() when $default != null:
        return $default(_that.id, _that.songId, _that.playedAt,
            _that.durationListenedMs, _that.sessionId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PlayHistoryEntry implements PlayHistoryEntry {
  const _PlayHistoryEntry(
      {required this.id,
      required this.songId,
      required this.playedAt,
      required this.durationListenedMs,
      required this.sessionId});

  @override
  final int id;
  @override
  final int songId;
  @override
  final DateTime playedAt;

  /// How many milliseconds of the track were actually listened to.
  @override
  final int durationListenedMs;

  /// Numeric session identifier — incremented each time the app launches.
  @override
  final int sessionId;

  /// Create a copy of PlayHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlayHistoryEntryCopyWith<_PlayHistoryEntry> get copyWith =>
      __$PlayHistoryEntryCopyWithImpl<_PlayHistoryEntry>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlayHistoryEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.songId, songId) || other.songId == songId) &&
            (identical(other.playedAt, playedAt) ||
                other.playedAt == playedAt) &&
            (identical(other.durationListenedMs, durationListenedMs) ||
                other.durationListenedMs == durationListenedMs) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, songId, playedAt, durationListenedMs, sessionId);

  @override
  String toString() {
    return 'PlayHistoryEntry(id: $id, songId: $songId, playedAt: $playedAt, durationListenedMs: $durationListenedMs, sessionId: $sessionId)';
  }
}

/// @nodoc
abstract mixin class _$PlayHistoryEntryCopyWith<$Res>
    implements $PlayHistoryEntryCopyWith<$Res> {
  factory _$PlayHistoryEntryCopyWith(
          _PlayHistoryEntry value, $Res Function(_PlayHistoryEntry) _then) =
      __$PlayHistoryEntryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      int songId,
      DateTime playedAt,
      int durationListenedMs,
      int sessionId});
}

/// @nodoc
class __$PlayHistoryEntryCopyWithImpl<$Res>
    implements _$PlayHistoryEntryCopyWith<$Res> {
  __$PlayHistoryEntryCopyWithImpl(this._self, this._then);

  final _PlayHistoryEntry _self;
  final $Res Function(_PlayHistoryEntry) _then;

  /// Create a copy of PlayHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? songId = null,
    Object? playedAt = null,
    Object? durationListenedMs = null,
    Object? sessionId = null,
  }) {
    return _then(_PlayHistoryEntry(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      songId: null == songId
          ? _self.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as int,
      playedAt: null == playedAt
          ? _self.playedAt
          : playedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationListenedMs: null == durationListenedMs
          ? _self.durationListenedMs
          : durationListenedMs // ignore: cast_nullable_to_non_nullable
              as int,
      sessionId: null == sessionId
          ? _self.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
