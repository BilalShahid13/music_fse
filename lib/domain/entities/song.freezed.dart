// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Song {
  int get id;
  String get filePath;
  String get title;
  String get artist;
  String get album;
  String get albumArtist;
  String get genre;
  int? get year;
  int? get trackNumber;
  int? get discNumber;
  int get durationMs;
  int get fileSize;
  DateTime get fileModifiedAt;

  /// Absolute path to the cached 300×300 thumbnail, or null if none.
  String? get artCachePath;
  DateTime get dateAdded;
  int get playCount;
  DateTime? get lastPlayedAt;
  bool get isFavorite;

  /// True when the source file could not be found on disk.
  /// Set by the playback layer when file-not-found is encountered.
  bool get isMissing;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SongCopyWith<Song> get copyWith =>
      _$SongCopyWithImpl<Song>(this as Song, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Song &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.album, album) || other.album == album) &&
            (identical(other.albumArtist, albumArtist) ||
                other.albumArtist == albumArtist) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.trackNumber, trackNumber) ||
                other.trackNumber == trackNumber) &&
            (identical(other.discNumber, discNumber) ||
                other.discNumber == discNumber) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.fileModifiedAt, fileModifiedAt) ||
                other.fileModifiedAt == fileModifiedAt) &&
            (identical(other.artCachePath, artCachePath) ||
                other.artCachePath == artCachePath) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.lastPlayedAt, lastPlayedAt) ||
                other.lastPlayedAt == lastPlayedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isMissing, isMissing) ||
                other.isMissing == isMissing));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        filePath,
        title,
        artist,
        album,
        albumArtist,
        genre,
        year,
        trackNumber,
        discNumber,
        durationMs,
        fileSize,
        fileModifiedAt,
        artCachePath,
        dateAdded,
        playCount,
        lastPlayedAt,
        isFavorite,
        isMissing
      ]);

  @override
  String toString() {
    return 'Song(id: $id, filePath: $filePath, title: $title, artist: $artist, album: $album, albumArtist: $albumArtist, genre: $genre, year: $year, trackNumber: $trackNumber, discNumber: $discNumber, durationMs: $durationMs, fileSize: $fileSize, fileModifiedAt: $fileModifiedAt, artCachePath: $artCachePath, dateAdded: $dateAdded, playCount: $playCount, lastPlayedAt: $lastPlayedAt, isFavorite: $isFavorite, isMissing: $isMissing)';
  }
}

/// @nodoc
abstract mixin class $SongCopyWith<$Res> {
  factory $SongCopyWith(Song value, $Res Function(Song) _then) =
      _$SongCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String filePath,
      String title,
      String artist,
      String album,
      String albumArtist,
      String genre,
      int? year,
      int? trackNumber,
      int? discNumber,
      int durationMs,
      int fileSize,
      DateTime fileModifiedAt,
      String? artCachePath,
      DateTime dateAdded,
      int playCount,
      DateTime? lastPlayedAt,
      bool isFavorite,
      bool isMissing});
}

/// @nodoc
class _$SongCopyWithImpl<$Res> implements $SongCopyWith<$Res> {
  _$SongCopyWithImpl(this._self, this._then);

  final Song _self;
  final $Res Function(Song) _then;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? filePath = null,
    Object? title = null,
    Object? artist = null,
    Object? album = null,
    Object? albumArtist = null,
    Object? genre = null,
    Object? year = freezed,
    Object? trackNumber = freezed,
    Object? discNumber = freezed,
    Object? durationMs = null,
    Object? fileSize = null,
    Object? fileModifiedAt = null,
    Object? artCachePath = freezed,
    Object? dateAdded = null,
    Object? playCount = null,
    Object? lastPlayedAt = freezed,
    Object? isFavorite = null,
    Object? isMissing = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      filePath: null == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _self.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      album: null == album
          ? _self.album
          : album // ignore: cast_nullable_to_non_nullable
              as String,
      albumArtist: null == albumArtist
          ? _self.albumArtist
          : albumArtist // ignore: cast_nullable_to_non_nullable
              as String,
      genre: null == genre
          ? _self.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      trackNumber: freezed == trackNumber
          ? _self.trackNumber
          : trackNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      discNumber: freezed == discNumber
          ? _self.discNumber
          : discNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      durationMs: null == durationMs
          ? _self.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      fileSize: null == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      fileModifiedAt: null == fileModifiedAt
          ? _self.fileModifiedAt
          : fileModifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      artCachePath: freezed == artCachePath
          ? _self.artCachePath
          : artCachePath // ignore: cast_nullable_to_non_nullable
              as String?,
      dateAdded: null == dateAdded
          ? _self.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as DateTime,
      playCount: null == playCount
          ? _self.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayedAt: freezed == lastPlayedAt
          ? _self.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFavorite: null == isFavorite
          ? _self.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isMissing: null == isMissing
          ? _self.isMissing
          : isMissing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Song].
extension SongPatterns on Song {
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
    TResult Function(_Song value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
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
    TResult Function(_Song value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song():
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
    TResult? Function(_Song value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
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
            int id,
            String filePath,
            String title,
            String artist,
            String album,
            String albumArtist,
            String genre,
            int? year,
            int? trackNumber,
            int? discNumber,
            int durationMs,
            int fileSize,
            DateTime fileModifiedAt,
            String? artCachePath,
            DateTime dateAdded,
            int playCount,
            DateTime? lastPlayedAt,
            bool isFavorite,
            bool isMissing)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
        return $default(
            _that.id,
            _that.filePath,
            _that.title,
            _that.artist,
            _that.album,
            _that.albumArtist,
            _that.genre,
            _that.year,
            _that.trackNumber,
            _that.discNumber,
            _that.durationMs,
            _that.fileSize,
            _that.fileModifiedAt,
            _that.artCachePath,
            _that.dateAdded,
            _that.playCount,
            _that.lastPlayedAt,
            _that.isFavorite,
            _that.isMissing);
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
    TResult Function(
            int id,
            String filePath,
            String title,
            String artist,
            String album,
            String albumArtist,
            String genre,
            int? year,
            int? trackNumber,
            int? discNumber,
            int durationMs,
            int fileSize,
            DateTime fileModifiedAt,
            String? artCachePath,
            DateTime dateAdded,
            int playCount,
            DateTime? lastPlayedAt,
            bool isFavorite,
            bool isMissing)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song():
        return $default(
            _that.id,
            _that.filePath,
            _that.title,
            _that.artist,
            _that.album,
            _that.albumArtist,
            _that.genre,
            _that.year,
            _that.trackNumber,
            _that.discNumber,
            _that.durationMs,
            _that.fileSize,
            _that.fileModifiedAt,
            _that.artCachePath,
            _that.dateAdded,
            _that.playCount,
            _that.lastPlayedAt,
            _that.isFavorite,
            _that.isMissing);
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
            int id,
            String filePath,
            String title,
            String artist,
            String album,
            String albumArtist,
            String genre,
            int? year,
            int? trackNumber,
            int? discNumber,
            int durationMs,
            int fileSize,
            DateTime fileModifiedAt,
            String? artCachePath,
            DateTime dateAdded,
            int playCount,
            DateTime? lastPlayedAt,
            bool isFavorite,
            bool isMissing)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Song() when $default != null:
        return $default(
            _that.id,
            _that.filePath,
            _that.title,
            _that.artist,
            _that.album,
            _that.albumArtist,
            _that.genre,
            _that.year,
            _that.trackNumber,
            _that.discNumber,
            _that.durationMs,
            _that.fileSize,
            _that.fileModifiedAt,
            _that.artCachePath,
            _that.dateAdded,
            _that.playCount,
            _that.lastPlayedAt,
            _that.isFavorite,
            _that.isMissing);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Song implements Song {
  const _Song(
      {required this.id,
      required this.filePath,
      required this.title,
      required this.artist,
      required this.album,
      required this.albumArtist,
      required this.genre,
      this.year,
      this.trackNumber,
      this.discNumber,
      required this.durationMs,
      required this.fileSize,
      required this.fileModifiedAt,
      this.artCachePath,
      required this.dateAdded,
      this.playCount = 0,
      this.lastPlayedAt,
      this.isFavorite = false,
      this.isMissing = false});

  @override
  final int id;
  @override
  final String filePath;
  @override
  final String title;
  @override
  final String artist;
  @override
  final String album;
  @override
  final String albumArtist;
  @override
  final String genre;
  @override
  final int? year;
  @override
  final int? trackNumber;
  @override
  final int? discNumber;
  @override
  final int durationMs;
  @override
  final int fileSize;
  @override
  final DateTime fileModifiedAt;

  /// Absolute path to the cached 300×300 thumbnail, or null if none.
  @override
  final String? artCachePath;
  @override
  final DateTime dateAdded;
  @override
  @JsonKey()
  final int playCount;
  @override
  final DateTime? lastPlayedAt;
  @override
  @JsonKey()
  final bool isFavorite;

  /// True when the source file could not be found on disk.
  /// Set by the playback layer when file-not-found is encountered.
  @override
  @JsonKey()
  final bool isMissing;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SongCopyWith<_Song> get copyWith =>
      __$SongCopyWithImpl<_Song>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Song &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.album, album) || other.album == album) &&
            (identical(other.albumArtist, albumArtist) ||
                other.albumArtist == albumArtist) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.trackNumber, trackNumber) ||
                other.trackNumber == trackNumber) &&
            (identical(other.discNumber, discNumber) ||
                other.discNumber == discNumber) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.fileModifiedAt, fileModifiedAt) ||
                other.fileModifiedAt == fileModifiedAt) &&
            (identical(other.artCachePath, artCachePath) ||
                other.artCachePath == artCachePath) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount) &&
            (identical(other.lastPlayedAt, lastPlayedAt) ||
                other.lastPlayedAt == lastPlayedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.isMissing, isMissing) ||
                other.isMissing == isMissing));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        filePath,
        title,
        artist,
        album,
        albumArtist,
        genre,
        year,
        trackNumber,
        discNumber,
        durationMs,
        fileSize,
        fileModifiedAt,
        artCachePath,
        dateAdded,
        playCount,
        lastPlayedAt,
        isFavorite,
        isMissing
      ]);

  @override
  String toString() {
    return 'Song(id: $id, filePath: $filePath, title: $title, artist: $artist, album: $album, albumArtist: $albumArtist, genre: $genre, year: $year, trackNumber: $trackNumber, discNumber: $discNumber, durationMs: $durationMs, fileSize: $fileSize, fileModifiedAt: $fileModifiedAt, artCachePath: $artCachePath, dateAdded: $dateAdded, playCount: $playCount, lastPlayedAt: $lastPlayedAt, isFavorite: $isFavorite, isMissing: $isMissing)';
  }
}

/// @nodoc
abstract mixin class _$SongCopyWith<$Res> implements $SongCopyWith<$Res> {
  factory _$SongCopyWith(_Song value, $Res Function(_Song) _then) =
      __$SongCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String filePath,
      String title,
      String artist,
      String album,
      String albumArtist,
      String genre,
      int? year,
      int? trackNumber,
      int? discNumber,
      int durationMs,
      int fileSize,
      DateTime fileModifiedAt,
      String? artCachePath,
      DateTime dateAdded,
      int playCount,
      DateTime? lastPlayedAt,
      bool isFavorite,
      bool isMissing});
}

/// @nodoc
class __$SongCopyWithImpl<$Res> implements _$SongCopyWith<$Res> {
  __$SongCopyWithImpl(this._self, this._then);

  final _Song _self;
  final $Res Function(_Song) _then;

  /// Create a copy of Song
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? filePath = null,
    Object? title = null,
    Object? artist = null,
    Object? album = null,
    Object? albumArtist = null,
    Object? genre = null,
    Object? year = freezed,
    Object? trackNumber = freezed,
    Object? discNumber = freezed,
    Object? durationMs = null,
    Object? fileSize = null,
    Object? fileModifiedAt = null,
    Object? artCachePath = freezed,
    Object? dateAdded = null,
    Object? playCount = null,
    Object? lastPlayedAt = freezed,
    Object? isFavorite = null,
    Object? isMissing = null,
  }) {
    return _then(_Song(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      filePath: null == filePath
          ? _self.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _self.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      album: null == album
          ? _self.album
          : album // ignore: cast_nullable_to_non_nullable
              as String,
      albumArtist: null == albumArtist
          ? _self.albumArtist
          : albumArtist // ignore: cast_nullable_to_non_nullable
              as String,
      genre: null == genre
          ? _self.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String,
      year: freezed == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      trackNumber: freezed == trackNumber
          ? _self.trackNumber
          : trackNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      discNumber: freezed == discNumber
          ? _self.discNumber
          : discNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      durationMs: null == durationMs
          ? _self.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      fileSize: null == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      fileModifiedAt: null == fileModifiedAt
          ? _self.fileModifiedAt
          : fileModifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      artCachePath: freezed == artCachePath
          ? _self.artCachePath
          : artCachePath // ignore: cast_nullable_to_non_nullable
              as String?,
      dateAdded: null == dateAdded
          ? _self.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as DateTime,
      playCount: null == playCount
          ? _self.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayedAt: freezed == lastPlayedAt
          ? _self.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFavorite: null == isFavorite
          ? _self.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      isMissing: null == isMissing
          ? _self.isMissing
          : isMissing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
