// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'album.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Album {
  String get name;
  String get artist;
  int? get year;
  String? get artCachePath;
  int get songCount;
  int get totalDurationMs;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AlbumCopyWith<Album> get copyWith =>
      _$AlbumCopyWithImpl<Album>(this as Album, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Album &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.artCachePath, artCachePath) ||
                other.artCachePath == artCachePath) &&
            (identical(other.songCount, songCount) ||
                other.songCount == songCount) &&
            (identical(other.totalDurationMs, totalDurationMs) ||
                other.totalDurationMs == totalDurationMs));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, artist, year, artCachePath,
      songCount, totalDurationMs);

  @override
  String toString() {
    return 'Album(name: $name, artist: $artist, year: $year, artCachePath: $artCachePath, songCount: $songCount, totalDurationMs: $totalDurationMs)';
  }
}

/// @nodoc
abstract mixin class $AlbumCopyWith<$Res> {
  factory $AlbumCopyWith(Album value, $Res Function(Album) _then) =
      _$AlbumCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String artist,
      int? year,
      String? artCachePath,
      int songCount,
      int totalDurationMs});
}

/// @nodoc
class _$AlbumCopyWithImpl<$Res> implements $AlbumCopyWith<$Res> {
  _$AlbumCopyWithImpl(this._self, this._then);

  final Album _self;
  final $Res Function(Album) _then;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? artist = null,
    Object? year = freezed,
    Object? artCachePath = freezed,
    Object? songCount = null,
    Object? totalDurationMs = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _self.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      artCachePath: freezed == artCachePath
          ? _self.artCachePath
          : artCachePath // ignore: cast_nullable_to_non_nullable
              as String?,
      songCount: null == songCount
          ? _self.songCount
          : songCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMs: null == totalDurationMs
          ? _self.totalDurationMs
          : totalDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [Album].
extension AlbumPatterns on Album {
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
    TResult Function(_Album value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Album() when $default != null:
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
    TResult Function(_Album value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Album():
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
    TResult? Function(_Album value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Album() when $default != null:
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
    TResult Function(String name, String artist, int? year,
            String? artCachePath, int songCount, int totalDurationMs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Album() when $default != null:
        return $default(_that.name, _that.artist, _that.year,
            _that.artCachePath, _that.songCount, _that.totalDurationMs);
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
    TResult Function(String name, String artist, int? year,
            String? artCachePath, int songCount, int totalDurationMs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Album():
        return $default(_that.name, _that.artist, _that.year,
            _that.artCachePath, _that.songCount, _that.totalDurationMs);
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
    TResult? Function(String name, String artist, int? year,
            String? artCachePath, int songCount, int totalDurationMs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Album() when $default != null:
        return $default(_that.name, _that.artist, _that.year,
            _that.artCachePath, _that.songCount, _that.totalDurationMs);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Album implements Album {
  const _Album(
      {required this.name,
      required this.artist,
      this.year,
      this.artCachePath,
      required this.songCount,
      required this.totalDurationMs});

  @override
  final String name;
  @override
  final String artist;
  @override
  final int? year;
  @override
  final String? artCachePath;
  @override
  final int songCount;
  @override
  final int totalDurationMs;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AlbumCopyWith<_Album> get copyWith =>
      __$AlbumCopyWithImpl<_Album>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Album &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.artCachePath, artCachePath) ||
                other.artCachePath == artCachePath) &&
            (identical(other.songCount, songCount) ||
                other.songCount == songCount) &&
            (identical(other.totalDurationMs, totalDurationMs) ||
                other.totalDurationMs == totalDurationMs));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, artist, year, artCachePath,
      songCount, totalDurationMs);

  @override
  String toString() {
    return 'Album(name: $name, artist: $artist, year: $year, artCachePath: $artCachePath, songCount: $songCount, totalDurationMs: $totalDurationMs)';
  }
}

/// @nodoc
abstract mixin class _$AlbumCopyWith<$Res> implements $AlbumCopyWith<$Res> {
  factory _$AlbumCopyWith(_Album value, $Res Function(_Album) _then) =
      __$AlbumCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String artist,
      int? year,
      String? artCachePath,
      int songCount,
      int totalDurationMs});
}

/// @nodoc
class __$AlbumCopyWithImpl<$Res> implements _$AlbumCopyWith<$Res> {
  __$AlbumCopyWithImpl(this._self, this._then);

  final _Album _self;
  final $Res Function(_Album) _then;

  /// Create a copy of Album
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? artist = null,
    Object? year = freezed,
    Object? artCachePath = freezed,
    Object? songCount = null,
    Object? totalDurationMs = null,
  }) {
    return _then(_Album(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _self.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      artCachePath: freezed == artCachePath
          ? _self.artCachePath
          : artCachePath // ignore: cast_nullable_to_non_nullable
              as String?,
      songCount: null == songCount
          ? _self.songCount
          : songCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalDurationMs: null == totalDurationMs
          ? _self.totalDurationMs
          : totalDurationMs // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
