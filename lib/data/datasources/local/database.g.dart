// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
      'artist', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown Artist'));
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
      'album', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown Album'));
  static const VerificationMeta _albumArtistMeta =
      const VerificationMeta('albumArtist');
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
      'album_artist', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
      'genre', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _trackNumberMeta =
      const VerificationMeta('trackNumber');
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
      'track_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _discNumberMeta =
      const VerificationMeta('discNumber');
  @override
  late final GeneratedColumn<int> discNumber = GeneratedColumn<int>(
      'disc_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fileModifiedAtMeta =
      const VerificationMeta('fileModifiedAt');
  @override
  late final GeneratedColumn<DateTime> fileModifiedAt =
      GeneratedColumn<DateTime>('file_modified_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _artCachePathMeta =
      const VerificationMeta('artCachePath');
  @override
  late final GeneratedColumn<String> artCachePath = GeneratedColumn<String>(
      'art_cache_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateAddedMeta =
      const VerificationMeta('dateAdded');
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
      'date_added', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _playCountMeta =
      const VerificationMeta('playCount');
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
      'play_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastPlayedAtMeta =
      const VerificationMeta('lastPlayedAt');
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
      'last_played_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isMissingMeta =
      const VerificationMeta('isMissing');
  @override
  late final GeneratedColumn<bool> isMissing = GeneratedColumn<bool>(
      'is_missing', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_missing" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
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
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'songs';
  @override
  VerificationContext validateIntegrity(Insertable<Song> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));
    }
    if (data.containsKey('album')) {
      context.handle(
          _albumMeta, album.isAcceptableOrUnknown(data['album']!, _albumMeta));
    }
    if (data.containsKey('album_artist')) {
      context.handle(
          _albumArtistMeta,
          albumArtist.isAcceptableOrUnknown(
              data['album_artist']!, _albumArtistMeta));
    }
    if (data.containsKey('genre')) {
      context.handle(
          _genreMeta, genre.isAcceptableOrUnknown(data['genre']!, _genreMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    }
    if (data.containsKey('track_number')) {
      context.handle(
          _trackNumberMeta,
          trackNumber.isAcceptableOrUnknown(
              data['track_number']!, _trackNumberMeta));
    }
    if (data.containsKey('disc_number')) {
      context.handle(
          _discNumberMeta,
          discNumber.isAcceptableOrUnknown(
              data['disc_number']!, _discNumberMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    }
    if (data.containsKey('file_modified_at')) {
      context.handle(
          _fileModifiedAtMeta,
          fileModifiedAt.isAcceptableOrUnknown(
              data['file_modified_at']!, _fileModifiedAtMeta));
    } else if (isInserting) {
      context.missing(_fileModifiedAtMeta);
    }
    if (data.containsKey('art_cache_path')) {
      context.handle(
          _artCachePathMeta,
          artCachePath.isAcceptableOrUnknown(
              data['art_cache_path']!, _artCachePathMeta));
    }
    if (data.containsKey('date_added')) {
      context.handle(_dateAddedMeta,
          dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta));
    }
    if (data.containsKey('play_count')) {
      context.handle(_playCountMeta,
          playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta));
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
          _lastPlayedAtMeta,
          lastPlayedAt.isAcceptableOrUnknown(
              data['last_played_at']!, _lastPlayedAtMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('is_missing')) {
      context.handle(_isMissingMeta,
          isMissing.isAcceptableOrUnknown(data['is_missing']!, _isMissingMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist'])!,
      album: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album'])!,
      albumArtist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album_artist'])!,
      genre: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}genre'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year']),
      trackNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}track_number']),
      discNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}disc_number']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
      fileModifiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}file_modified_at'])!,
      artCachePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}art_cache_path']),
      dateAdded: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_added'])!,
      playCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}play_count'])!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_played_at']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      isMissing: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_missing'])!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final int id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final String genre;
  final int? year;
  final int? trackNumber;
  final int? discNumber;
  final int durationMs;
  final int fileSize;
  final DateTime fileModifiedAt;
  final String? artCachePath;
  final DateTime dateAdded;
  final int playCount;
  final DateTime? lastPlayedAt;
  final bool isFavorite;
  final bool isMissing;
  const Song(
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
      required this.playCount,
      this.lastPlayedAt,
      required this.isFavorite,
      required this.isMissing});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    map['title'] = Variable<String>(title);
    map['artist'] = Variable<String>(artist);
    map['album'] = Variable<String>(album);
    map['album_artist'] = Variable<String>(albumArtist);
    map['genre'] = Variable<String>(genre);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    if (!nullToAbsent || discNumber != null) {
      map['disc_number'] = Variable<int>(discNumber);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['file_size'] = Variable<int>(fileSize);
    map['file_modified_at'] = Variable<DateTime>(fileModifiedAt);
    if (!nullToAbsent || artCachePath != null) {
      map['art_cache_path'] = Variable<String>(artCachePath);
    }
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['play_count'] = Variable<int>(playCount);
    if (!nullToAbsent || lastPlayedAt != null) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_missing'] = Variable<bool>(isMissing);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      filePath: Value(filePath),
      title: Value(title),
      artist: Value(artist),
      album: Value(album),
      albumArtist: Value(albumArtist),
      genre: Value(genre),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      discNumber: discNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(discNumber),
      durationMs: Value(durationMs),
      fileSize: Value(fileSize),
      fileModifiedAt: Value(fileModifiedAt),
      artCachePath: artCachePath == null && nullToAbsent
          ? const Value.absent()
          : Value(artCachePath),
      dateAdded: Value(dateAdded),
      playCount: Value(playCount),
      lastPlayedAt: lastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayedAt),
      isFavorite: Value(isFavorite),
      isMissing: Value(isMissing),
    );
  }

  factory Song.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      album: serializer.fromJson<String>(json['album']),
      albumArtist: serializer.fromJson<String>(json['albumArtist']),
      genre: serializer.fromJson<String>(json['genre']),
      year: serializer.fromJson<int?>(json['year']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      discNumber: serializer.fromJson<int?>(json['discNumber']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      fileModifiedAt: serializer.fromJson<DateTime>(json['fileModifiedAt']),
      artCachePath: serializer.fromJson<String?>(json['artCachePath']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      playCount: serializer.fromJson<int>(json['playCount']),
      lastPlayedAt: serializer.fromJson<DateTime?>(json['lastPlayedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isMissing: serializer.fromJson<bool>(json['isMissing']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'album': serializer.toJson<String>(album),
      'albumArtist': serializer.toJson<String>(albumArtist),
      'genre': serializer.toJson<String>(genre),
      'year': serializer.toJson<int?>(year),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'discNumber': serializer.toJson<int?>(discNumber),
      'durationMs': serializer.toJson<int>(durationMs),
      'fileSize': serializer.toJson<int>(fileSize),
      'fileModifiedAt': serializer.toJson<DateTime>(fileModifiedAt),
      'artCachePath': serializer.toJson<String?>(artCachePath),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'playCount': serializer.toJson<int>(playCount),
      'lastPlayedAt': serializer.toJson<DateTime?>(lastPlayedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isMissing': serializer.toJson<bool>(isMissing),
    };
  }

  Song copyWith(
          {int? id,
          String? filePath,
          String? title,
          String? artist,
          String? album,
          String? albumArtist,
          String? genre,
          Value<int?> year = const Value.absent(),
          Value<int?> trackNumber = const Value.absent(),
          Value<int?> discNumber = const Value.absent(),
          int? durationMs,
          int? fileSize,
          DateTime? fileModifiedAt,
          Value<String?> artCachePath = const Value.absent(),
          DateTime? dateAdded,
          int? playCount,
          Value<DateTime?> lastPlayedAt = const Value.absent(),
          bool? isFavorite,
          bool? isMissing}) =>
      Song(
        id: id ?? this.id,
        filePath: filePath ?? this.filePath,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        album: album ?? this.album,
        albumArtist: albumArtist ?? this.albumArtist,
        genre: genre ?? this.genre,
        year: year.present ? year.value : this.year,
        trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
        discNumber: discNumber.present ? discNumber.value : this.discNumber,
        durationMs: durationMs ?? this.durationMs,
        fileSize: fileSize ?? this.fileSize,
        fileModifiedAt: fileModifiedAt ?? this.fileModifiedAt,
        artCachePath:
            artCachePath.present ? artCachePath.value : this.artCachePath,
        dateAdded: dateAdded ?? this.dateAdded,
        playCount: playCount ?? this.playCount,
        lastPlayedAt:
            lastPlayedAt.present ? lastPlayedAt.value : this.lastPlayedAt,
        isFavorite: isFavorite ?? this.isFavorite,
        isMissing: isMissing ?? this.isMissing,
      );
  Song copyWithCompanion(SongsCompanion data) {
    return Song(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      albumArtist:
          data.albumArtist.present ? data.albumArtist.value : this.albumArtist,
      genre: data.genre.present ? data.genre.value : this.genre,
      year: data.year.present ? data.year.value : this.year,
      trackNumber:
          data.trackNumber.present ? data.trackNumber.value : this.trackNumber,
      discNumber:
          data.discNumber.present ? data.discNumber.value : this.discNumber,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      fileModifiedAt: data.fileModifiedAt.present
          ? data.fileModifiedAt.value
          : this.fileModifiedAt,
      artCachePath: data.artCachePath.present
          ? data.artCachePath.value
          : this.artCachePath,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      isMissing: data.isMissing.present ? data.isMissing.value : this.isMissing,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileModifiedAt: $fileModifiedAt, ')
          ..write('artCachePath: $artCachePath, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isMissing: $isMissing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      isMissing);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.albumArtist == this.albumArtist &&
          other.genre == this.genre &&
          other.year == this.year &&
          other.trackNumber == this.trackNumber &&
          other.discNumber == this.discNumber &&
          other.durationMs == this.durationMs &&
          other.fileSize == this.fileSize &&
          other.fileModifiedAt == this.fileModifiedAt &&
          other.artCachePath == this.artCachePath &&
          other.dateAdded == this.dateAdded &&
          other.playCount == this.playCount &&
          other.lastPlayedAt == this.lastPlayedAt &&
          other.isFavorite == this.isFavorite &&
          other.isMissing == this.isMissing);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<String> title;
  final Value<String> artist;
  final Value<String> album;
  final Value<String> albumArtist;
  final Value<String> genre;
  final Value<int?> year;
  final Value<int?> trackNumber;
  final Value<int?> discNumber;
  final Value<int> durationMs;
  final Value<int> fileSize;
  final Value<DateTime> fileModifiedAt;
  final Value<String?> artCachePath;
  final Value<DateTime> dateAdded;
  final Value<int> playCount;
  final Value<DateTime?> lastPlayedAt;
  final Value<bool> isFavorite;
  final Value<bool> isMissing;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.fileModifiedAt = const Value.absent(),
    this.artCachePath = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isMissing = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.discNumber = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.fileSize = const Value.absent(),
    required DateTime fileModifiedAt,
    this.artCachePath = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.playCount = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isMissing = const Value.absent(),
  })  : filePath = Value(filePath),
        title = Value(title),
        fileModifiedAt = Value(fileModifiedAt);
  static Insertable<Song> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? albumArtist,
    Expression<String>? genre,
    Expression<int>? year,
    Expression<int>? trackNumber,
    Expression<int>? discNumber,
    Expression<int>? durationMs,
    Expression<int>? fileSize,
    Expression<DateTime>? fileModifiedAt,
    Expression<String>? artCachePath,
    Expression<DateTime>? dateAdded,
    Expression<int>? playCount,
    Expression<DateTime>? lastPlayedAt,
    Expression<bool>? isFavorite,
    Expression<bool>? isMissing,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
      if (trackNumber != null) 'track_number': trackNumber,
      if (discNumber != null) 'disc_number': discNumber,
      if (durationMs != null) 'duration_ms': durationMs,
      if (fileSize != null) 'file_size': fileSize,
      if (fileModifiedAt != null) 'file_modified_at': fileModifiedAt,
      if (artCachePath != null) 'art_cache_path': artCachePath,
      if (dateAdded != null) 'date_added': dateAdded,
      if (playCount != null) 'play_count': playCount,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isMissing != null) 'is_missing': isMissing,
    });
  }

  SongsCompanion copyWith(
      {Value<int>? id,
      Value<String>? filePath,
      Value<String>? title,
      Value<String>? artist,
      Value<String>? album,
      Value<String>? albumArtist,
      Value<String>? genre,
      Value<int?>? year,
      Value<int?>? trackNumber,
      Value<int?>? discNumber,
      Value<int>? durationMs,
      Value<int>? fileSize,
      Value<DateTime>? fileModifiedAt,
      Value<String?>? artCachePath,
      Value<DateTime>? dateAdded,
      Value<int>? playCount,
      Value<DateTime?>? lastPlayedAt,
      Value<bool>? isFavorite,
      Value<bool>? isMissing}) {
    return SongsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      discNumber: discNumber ?? this.discNumber,
      durationMs: durationMs ?? this.durationMs,
      fileSize: fileSize ?? this.fileSize,
      fileModifiedAt: fileModifiedAt ?? this.fileModifiedAt,
      artCachePath: artCachePath ?? this.artCachePath,
      dateAdded: dateAdded ?? this.dateAdded,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isMissing: isMissing ?? this.isMissing,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (discNumber.present) {
      map['disc_number'] = Variable<int>(discNumber.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (fileModifiedAt.present) {
      map['file_modified_at'] = Variable<DateTime>(fileModifiedAt.value);
    }
    if (artCachePath.present) {
      map['art_cache_path'] = Variable<String>(artCachePath.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isMissing.present) {
      map['is_missing'] = Variable<bool>(isMissing.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('discNumber: $discNumber, ')
          ..write('durationMs: $durationMs, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileModifiedAt: $fileModifiedAt, ')
          ..write('artCachePath: $artCachePath, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('playCount: $playCount, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isMissing: $isMissing')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverArtPathMeta =
      const VerificationMeta('coverArtPath');
  @override
  late final GeneratedColumn<String> coverArtPath = GeneratedColumn<String>(
      'cover_art_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isSmartMeta =
      const VerificationMeta('isSmart');
  @override
  late final GeneratedColumn<bool> isSmart = GeneratedColumn<bool>(
      'is_smart', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_smart" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _smartRuleMeta =
      const VerificationMeta('smartRule');
  @override
  late final GeneratedColumn<String> smartRule = GeneratedColumn<String>(
      'smart_rule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, coverArtPath, createdAt, updatedAt, isSmart, smartRule];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<Playlist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_art_path')) {
      context.handle(
          _coverArtPathMeta,
          coverArtPath.isAcceptableOrUnknown(
              data['cover_art_path']!, _coverArtPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_smart')) {
      context.handle(_isSmartMeta,
          isSmart.isAcceptableOrUnknown(data['is_smart']!, _isSmartMeta));
    }
    if (data.containsKey('smart_rule')) {
      context.handle(_smartRuleMeta,
          smartRule.isAcceptableOrUnknown(data['smart_rule']!, _smartRuleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      coverArtPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_art_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isSmart: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_smart'])!,
      smartRule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}smart_rule']),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final int id;
  final String name;
  final String? coverArtPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSmart;
  final String? smartRule;
  const Playlist(
      {required this.id,
      required this.name,
      this.coverArtPath,
      required this.createdAt,
      required this.updatedAt,
      required this.isSmart,
      this.smartRule});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || coverArtPath != null) {
      map['cover_art_path'] = Variable<String>(coverArtPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_smart'] = Variable<bool>(isSmart);
    if (!nullToAbsent || smartRule != null) {
      map['smart_rule'] = Variable<String>(smartRule);
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      coverArtPath: coverArtPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverArtPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSmart: Value(isSmart),
      smartRule: smartRule == null && nullToAbsent
          ? const Value.absent()
          : Value(smartRule),
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      coverArtPath: serializer.fromJson<String?>(json['coverArtPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSmart: serializer.fromJson<bool>(json['isSmart']),
      smartRule: serializer.fromJson<String?>(json['smartRule']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'coverArtPath': serializer.toJson<String?>(coverArtPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSmart': serializer.toJson<bool>(isSmart),
      'smartRule': serializer.toJson<String?>(smartRule),
    };
  }

  Playlist copyWith(
          {int? id,
          String? name,
          Value<String?> coverArtPath = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isSmart,
          Value<String?> smartRule = const Value.absent()}) =>
      Playlist(
        id: id ?? this.id,
        name: name ?? this.name,
        coverArtPath:
            coverArtPath.present ? coverArtPath.value : this.coverArtPath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isSmart: isSmart ?? this.isSmart,
        smartRule: smartRule.present ? smartRule.value : this.smartRule,
      );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      coverArtPath: data.coverArtPath.present
          ? data.coverArtPath.value
          : this.coverArtPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSmart: data.isSmart.present ? data.isSmart.value : this.isSmart,
      smartRule: data.smartRule.present ? data.smartRule.value : this.smartRule,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSmart: $isSmart, ')
          ..write('smartRule: $smartRule')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, coverArtPath, createdAt, updatedAt, isSmart, smartRule);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.coverArtPath == this.coverArtPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSmart == this.isSmart &&
          other.smartRule == this.smartRule);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> coverArtPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSmart;
  final Value<String?> smartRule;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.coverArtPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSmart = const Value.absent(),
    this.smartRule = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.coverArtPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSmart = const Value.absent(),
    this.smartRule = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Playlist> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? coverArtPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSmart,
    Expression<String>? smartRule,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (coverArtPath != null) 'cover_art_path': coverArtPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSmart != null) 'is_smart': isSmart,
      if (smartRule != null) 'smart_rule': smartRule,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? coverArtPath,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isSmart,
      Value<String?>? smartRule}) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      coverArtPath: coverArtPath ?? this.coverArtPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSmart: isSmart ?? this.isSmart,
      smartRule: smartRule ?? this.smartRule,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverArtPath.present) {
      map['cover_art_path'] = Variable<String>(coverArtPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSmart.present) {
      map['is_smart'] = Variable<bool>(isSmart.value);
    }
    if (smartRule.present) {
      map['smart_rule'] = Variable<String>(smartRule.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverArtPath: $coverArtPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSmart: $isSmart, ')
          ..write('smartRule: $smartRule')
          ..write(')'))
        .toString();
  }
}

class $PlaylistSongsTable extends PlaylistSongs
    with TableInfo<$PlaylistSongsTable, PlaylistSong> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistSongsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES playlists (id)'));
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
      'song_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES songs (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [playlistId, songId, sortOrder, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_songs';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistSong> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, songId};
  @override
  PlaylistSong map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistSong(
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}playlist_id'])!,
      songId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}song_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $PlaylistSongsTable createAlias(String alias) {
    return $PlaylistSongsTable(attachedDatabase, alias);
  }
}

class PlaylistSong extends DataClass implements Insertable<PlaylistSong> {
  final int playlistId;
  final int songId;
  final int sortOrder;
  final DateTime addedAt;
  const PlaylistSong(
      {required this.playlistId,
      required this.songId,
      required this.sortOrder,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<int>(playlistId);
    map['song_id'] = Variable<int>(songId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  PlaylistSongsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistSongsCompanion(
      playlistId: Value(playlistId),
      songId: Value(songId),
      sortOrder: Value(sortOrder),
      addedAt: Value(addedAt),
    );
  }

  factory PlaylistSong.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistSong(
      playlistId: serializer.fromJson<int>(json['playlistId']),
      songId: serializer.fromJson<int>(json['songId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<int>(playlistId),
      'songId': serializer.toJson<int>(songId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  PlaylistSong copyWith(
          {int? playlistId, int? songId, int? sortOrder, DateTime? addedAt}) =>
      PlaylistSong(
        playlistId: playlistId ?? this.playlistId,
        songId: songId ?? this.songId,
        sortOrder: sortOrder ?? this.sortOrder,
        addedAt: addedAt ?? this.addedAt,
      );
  PlaylistSong copyWithCompanion(PlaylistSongsCompanion data) {
    return PlaylistSong(
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      songId: data.songId.present ? data.songId.value : this.songId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSong(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, songId, sortOrder, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistSong &&
          other.playlistId == this.playlistId &&
          other.songId == this.songId &&
          other.sortOrder == this.sortOrder &&
          other.addedAt == this.addedAt);
}

class PlaylistSongsCompanion extends UpdateCompanion<PlaylistSong> {
  final Value<int> playlistId;
  final Value<int> songId;
  final Value<int> sortOrder;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const PlaylistSongsCompanion({
    this.playlistId = const Value.absent(),
    this.songId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistSongsCompanion.insert({
    required int playlistId,
    required int songId,
    required int sortOrder,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        songId = Value(songId),
        sortOrder = Value(sortOrder);
  static Insertable<PlaylistSong> custom({
    Expression<int>? playlistId,
    Expression<int>? songId,
    Expression<int>? sortOrder,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (songId != null) 'song_id': songId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistSongsCompanion copyWith(
      {Value<int>? playlistId,
      Value<int>? songId,
      Value<int>? sortOrder,
      Value<DateTime>? addedAt,
      Value<int>? rowid}) {
    return PlaylistSongsCompanion(
      playlistId: playlistId ?? this.playlistId,
      songId: songId ?? this.songId,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistSongsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayHistoryTable extends PlayHistory
    with TableInfo<$PlayHistoryTable, PlayHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
      'song_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES songs (id)'));
  static const VerificationMeta _playedAtMeta =
      const VerificationMeta('playedAt');
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
      'played_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationListenedMsMeta =
      const VerificationMeta('durationListenedMs');
  @override
  late final GeneratedColumn<int> durationListenedMs = GeneratedColumn<int>(
      'duration_listened_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
      'session_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, songId, playedAt, durationListenedMs, sessionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_history';
  @override
  VerificationContext validateIntegrity(Insertable<PlayHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(_playedAtMeta,
          playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta));
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    if (data.containsKey('duration_listened_ms')) {
      context.handle(
          _durationListenedMsMeta,
          durationListenedMs.isAcceptableOrUnknown(
              data['duration_listened_ms']!, _durationListenedMsMeta));
    } else if (isInserting) {
      context.missing(_durationListenedMsMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      songId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}song_id'])!,
      playedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}played_at'])!,
      durationListenedMs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}duration_listened_ms'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}session_id'])!,
    );
  }

  @override
  $PlayHistoryTable createAlias(String alias) {
    return $PlayHistoryTable(attachedDatabase, alias);
  }
}

class PlayHistoryData extends DataClass implements Insertable<PlayHistoryData> {
  final int id;
  final int songId;
  final DateTime playedAt;
  final int durationListenedMs;

  /// Numeric session identifier — each app launch produces a new value.
  final int sessionId;
  const PlayHistoryData(
      {required this.id,
      required this.songId,
      required this.playedAt,
      required this.durationListenedMs,
      required this.sessionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_id'] = Variable<int>(songId);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['duration_listened_ms'] = Variable<int>(durationListenedMs);
    map['session_id'] = Variable<int>(sessionId);
    return map;
  }

  PlayHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlayHistoryCompanion(
      id: Value(id),
      songId: Value(songId),
      playedAt: Value(playedAt),
      durationListenedMs: Value(durationListenedMs),
      sessionId: Value(sessionId),
    );
  }

  factory PlayHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayHistoryData(
      id: serializer.fromJson<int>(json['id']),
      songId: serializer.fromJson<int>(json['songId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      durationListenedMs: serializer.fromJson<int>(json['durationListenedMs']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songId': serializer.toJson<int>(songId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'durationListenedMs': serializer.toJson<int>(durationListenedMs),
      'sessionId': serializer.toJson<int>(sessionId),
    };
  }

  PlayHistoryData copyWith(
          {int? id,
          int? songId,
          DateTime? playedAt,
          int? durationListenedMs,
          int? sessionId}) =>
      PlayHistoryData(
        id: id ?? this.id,
        songId: songId ?? this.songId,
        playedAt: playedAt ?? this.playedAt,
        durationListenedMs: durationListenedMs ?? this.durationListenedMs,
        sessionId: sessionId ?? this.sessionId,
      );
  PlayHistoryData copyWithCompanion(PlayHistoryCompanion data) {
    return PlayHistoryData(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      durationListenedMs: data.durationListenedMs.present
          ? data.durationListenedMs.value
          : this.durationListenedMs,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryData(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('playedAt: $playedAt, ')
          ..write('durationListenedMs: $durationListenedMs, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, songId, playedAt, durationListenedMs, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayHistoryData &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.playedAt == this.playedAt &&
          other.durationListenedMs == this.durationListenedMs &&
          other.sessionId == this.sessionId);
}

class PlayHistoryCompanion extends UpdateCompanion<PlayHistoryData> {
  final Value<int> id;
  final Value<int> songId;
  final Value<DateTime> playedAt;
  final Value<int> durationListenedMs;
  final Value<int> sessionId;
  const PlayHistoryCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.durationListenedMs = const Value.absent(),
    this.sessionId = const Value.absent(),
  });
  PlayHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int songId,
    required DateTime playedAt,
    required int durationListenedMs,
    required int sessionId,
  })  : songId = Value(songId),
        playedAt = Value(playedAt),
        durationListenedMs = Value(durationListenedMs),
        sessionId = Value(sessionId);
  static Insertable<PlayHistoryData> custom({
    Expression<int>? id,
    Expression<int>? songId,
    Expression<DateTime>? playedAt,
    Expression<int>? durationListenedMs,
    Expression<int>? sessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (playedAt != null) 'played_at': playedAt,
      if (durationListenedMs != null)
        'duration_listened_ms': durationListenedMs,
      if (sessionId != null) 'session_id': sessionId,
    });
  }

  PlayHistoryCompanion copyWith(
      {Value<int>? id,
      Value<int>? songId,
      Value<DateTime>? playedAt,
      Value<int>? durationListenedMs,
      Value<int>? sessionId}) {
    return PlayHistoryCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      playedAt: playedAt ?? this.playedAt,
      durationListenedMs: durationListenedMs ?? this.durationListenedMs,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (durationListenedMs.present) {
      map['duration_listened_ms'] = Variable<int>(durationListenedMs.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('playedAt: $playedAt, ')
          ..write('durationListenedMs: $durationListenedMs, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }
}

class $QueueItemsTable extends QueueItems
    with TableInfo<$QueueItemsTable, QueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
      'song_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES songs (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCurrentMeta =
      const VerificationMeta('isCurrent');
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
      'is_current', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_current" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _positionMsMeta =
      const VerificationMeta('positionMs');
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
      'position_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, songId, sortOrder, isCurrent, positionMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_items';
  @override
  VerificationContext validateIntegrity(Insertable<QueueItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(_isCurrentMeta,
          isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta));
    }
    if (data.containsKey('position_ms')) {
      context.handle(
          _positionMsMeta,
          positionMs.isAcceptableOrUnknown(
              data['position_ms']!, _positionMsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      songId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}song_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isCurrent: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_current'])!,
      positionMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position_ms'])!,
    );
  }

  @override
  $QueueItemsTable createAlias(String alias) {
    return $QueueItemsTable(attachedDatabase, alias);
  }
}

class QueueItem extends DataClass implements Insertable<QueueItem> {
  /// Auto-increment PK so the same song can appear multiple times.
  final int id;
  final int songId;
  final int sortOrder;
  final bool isCurrent;
  final int positionMs;
  const QueueItem(
      {required this.id,
      required this.songId,
      required this.sortOrder,
      required this.isCurrent,
      required this.positionMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['song_id'] = Variable<int>(songId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_current'] = Variable<bool>(isCurrent);
    map['position_ms'] = Variable<int>(positionMs);
    return map;
  }

  QueueItemsCompanion toCompanion(bool nullToAbsent) {
    return QueueItemsCompanion(
      id: Value(id),
      songId: Value(songId),
      sortOrder: Value(sortOrder),
      isCurrent: Value(isCurrent),
      positionMs: Value(positionMs),
    );
  }

  factory QueueItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueItem(
      id: serializer.fromJson<int>(json['id']),
      songId: serializer.fromJson<int>(json['songId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'songId': serializer.toJson<int>(songId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isCurrent': serializer.toJson<bool>(isCurrent),
      'positionMs': serializer.toJson<int>(positionMs),
    };
  }

  QueueItem copyWith(
          {int? id,
          int? songId,
          int? sortOrder,
          bool? isCurrent,
          int? positionMs}) =>
      QueueItem(
        id: id ?? this.id,
        songId: songId ?? this.songId,
        sortOrder: sortOrder ?? this.sortOrder,
        isCurrent: isCurrent ?? this.isCurrent,
        positionMs: positionMs ?? this.positionMs,
      );
  QueueItem copyWithCompanion(QueueItemsCompanion data) {
    return QueueItem(
      id: data.id.present ? data.id.value : this.id,
      songId: data.songId.present ? data.songId.value : this.songId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
      positionMs:
          data.positionMs.present ? data.positionMs.value : this.positionMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueItem(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('positionMs: $positionMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, songId, sortOrder, isCurrent, positionMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueItem &&
          other.id == this.id &&
          other.songId == this.songId &&
          other.sortOrder == this.sortOrder &&
          other.isCurrent == this.isCurrent &&
          other.positionMs == this.positionMs);
}

class QueueItemsCompanion extends UpdateCompanion<QueueItem> {
  final Value<int> id;
  final Value<int> songId;
  final Value<int> sortOrder;
  final Value<bool> isCurrent;
  final Value<int> positionMs;
  const QueueItemsCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isCurrent = const Value.absent(),
    this.positionMs = const Value.absent(),
  });
  QueueItemsCompanion.insert({
    this.id = const Value.absent(),
    required int songId,
    required int sortOrder,
    this.isCurrent = const Value.absent(),
    this.positionMs = const Value.absent(),
  })  : songId = Value(songId),
        sortOrder = Value(sortOrder);
  static Insertable<QueueItem> custom({
    Expression<int>? id,
    Expression<int>? songId,
    Expression<int>? sortOrder,
    Expression<bool>? isCurrent,
    Expression<int>? positionMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isCurrent != null) 'is_current': isCurrent,
      if (positionMs != null) 'position_ms': positionMs,
    });
  }

  QueueItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? songId,
      Value<int>? sortOrder,
      Value<bool>? isCurrent,
      Value<int>? positionMs}) {
    return QueueItemsCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      sortOrder: sortOrder ?? this.sortOrder,
      isCurrent: isCurrent ?? this.isCurrent,
      positionMs: positionMs ?? this.positionMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isCurrent: $isCurrent, ')
          ..write('positionMs: $positionMs')
          ..write(')'))
        .toString();
  }
}

class $EqPresetsTable extends EqPresets
    with TableInfo<$EqPresetsTable, EqPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EqPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isBuiltinMeta =
      const VerificationMeta('isBuiltin');
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
      'is_builtin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_builtin" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _bandsJsonMeta =
      const VerificationMeta('bandsJson');
  @override
  late final GeneratedColumn<String> bandsJson = GeneratedColumn<String>(
      'bands_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, isBuiltin, bandsJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eq_presets';
  @override
  VerificationContext validateIntegrity(Insertable<EqPreset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_builtin')) {
      context.handle(_isBuiltinMeta,
          isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta));
    }
    if (data.containsKey('bands_json')) {
      context.handle(_bandsJsonMeta,
          bandsJson.isAcceptableOrUnknown(data['bands_json']!, _bandsJsonMeta));
    } else if (isInserting) {
      context.missing(_bandsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EqPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EqPreset(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isBuiltin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_builtin'])!,
      bandsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bands_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EqPresetsTable createAlias(String alias) {
    return $EqPresetsTable(attachedDatabase, alias);
  }
}

class EqPreset extends DataClass implements Insertable<EqPreset> {
  final int id;
  final String name;
  final bool isBuiltin;

  /// JSON-encoded List<double> of 10 band gains in dB.
  final String bandsJson;
  final DateTime createdAt;
  const EqPreset(
      {required this.id,
      required this.name,
      required this.isBuiltin,
      required this.bandsJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['bands_json'] = Variable<String>(bandsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EqPresetsCompanion toCompanion(bool nullToAbsent) {
    return EqPresetsCompanion(
      id: Value(id),
      name: Value(name),
      isBuiltin: Value(isBuiltin),
      bandsJson: Value(bandsJson),
      createdAt: Value(createdAt),
    );
  }

  factory EqPreset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EqPreset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      bandsJson: serializer.fromJson<String>(json['bandsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'bandsJson': serializer.toJson<String>(bandsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EqPreset copyWith(
          {int? id,
          String? name,
          bool? isBuiltin,
          String? bandsJson,
          DateTime? createdAt}) =>
      EqPreset(
        id: id ?? this.id,
        name: name ?? this.name,
        isBuiltin: isBuiltin ?? this.isBuiltin,
        bandsJson: bandsJson ?? this.bandsJson,
        createdAt: createdAt ?? this.createdAt,
      );
  EqPreset copyWithCompanion(EqPresetsCompanion data) {
    return EqPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      bandsJson: data.bandsJson.present ? data.bandsJson.value : this.bandsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EqPreset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('bandsJson: $bandsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isBuiltin, bandsJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EqPreset &&
          other.id == this.id &&
          other.name == this.name &&
          other.isBuiltin == this.isBuiltin &&
          other.bandsJson == this.bandsJson &&
          other.createdAt == this.createdAt);
}

class EqPresetsCompanion extends UpdateCompanion<EqPreset> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isBuiltin;
  final Value<String> bandsJson;
  final Value<DateTime> createdAt;
  const EqPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.bandsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EqPresetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isBuiltin = const Value.absent(),
    required String bandsJson,
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        bandsJson = Value(bandsJson);
  static Insertable<EqPreset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isBuiltin,
    Expression<String>? bandsJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (bandsJson != null) 'bands_json': bandsJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EqPresetsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<bool>? isBuiltin,
      Value<String>? bandsJson,
      Value<DateTime>? createdAt}) {
    return EqPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      bandsJson: bandsJson ?? this.bandsJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (bandsJson.present) {
      map['bands_json'] = Variable<String>(bandsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EqPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('bandsJson: $bandsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlaybackStatesTable extends PlaybackStates
    with TableInfo<$PlaybackStatesTable, PlaybackState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _shuffleMeta =
      const VerificationMeta('shuffle');
  @override
  late final GeneratedColumn<bool> shuffle = GeneratedColumn<bool>(
      'shuffle', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("shuffle" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _repeatModeMeta =
      const VerificationMeta('repeatMode');
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
      'repeat_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('off'));
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
      'volume', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.7));
  static const VerificationMeta _crossfadeSecondsMeta =
      const VerificationMeta('crossfadeSeconds');
  @override
  late final GeneratedColumn<int> crossfadeSeconds = GeneratedColumn<int>(
      'crossfade_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _eqEnabledMeta =
      const VerificationMeta('eqEnabled');
  @override
  late final GeneratedColumn<bool> eqEnabled = GeneratedColumn<bool>(
      'eq_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("eq_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _eqPresetIdMeta =
      const VerificationMeta('eqPresetId');
  @override
  late final GeneratedColumn<int> eqPresetId = GeneratedColumn<int>(
      'eq_preset_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES eq_presets (id)'));
  static const VerificationMeta _queueSourceTypeMeta =
      const VerificationMeta('queueSourceType');
  @override
  late final GeneratedColumn<String> queueSourceType = GeneratedColumn<String>(
      'queue_source_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _queueSourceIdMeta =
      const VerificationMeta('queueSourceId');
  @override
  late final GeneratedColumn<int> queueSourceId = GeneratedColumn<int>(
      'queue_source_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shuffle,
        repeatMode,
        volume,
        crossfadeSeconds,
        eqEnabled,
        eqPresetId,
        queueSourceType,
        queueSourceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_states';
  @override
  VerificationContext validateIntegrity(Insertable<PlaybackState> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shuffle')) {
      context.handle(_shuffleMeta,
          shuffle.isAcceptableOrUnknown(data['shuffle']!, _shuffleMeta));
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
          _repeatModeMeta,
          repeatMode.isAcceptableOrUnknown(
              data['repeat_mode']!, _repeatModeMeta));
    }
    if (data.containsKey('volume')) {
      context.handle(_volumeMeta,
          volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta));
    }
    if (data.containsKey('crossfade_seconds')) {
      context.handle(
          _crossfadeSecondsMeta,
          crossfadeSeconds.isAcceptableOrUnknown(
              data['crossfade_seconds']!, _crossfadeSecondsMeta));
    }
    if (data.containsKey('eq_enabled')) {
      context.handle(_eqEnabledMeta,
          eqEnabled.isAcceptableOrUnknown(data['eq_enabled']!, _eqEnabledMeta));
    }
    if (data.containsKey('eq_preset_id')) {
      context.handle(
          _eqPresetIdMeta,
          eqPresetId.isAcceptableOrUnknown(
              data['eq_preset_id']!, _eqPresetIdMeta));
    }
    if (data.containsKey('queue_source_type')) {
      context.handle(
          _queueSourceTypeMeta,
          queueSourceType.isAcceptableOrUnknown(
              data['queue_source_type']!, _queueSourceTypeMeta));
    }
    if (data.containsKey('queue_source_id')) {
      context.handle(
          _queueSourceIdMeta,
          queueSourceId.isAcceptableOrUnknown(
              data['queue_source_id']!, _queueSourceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackState(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      shuffle: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}shuffle'])!,
      repeatMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat_mode'])!,
      volume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}volume'])!,
      crossfadeSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}crossfade_seconds'])!,
      eqEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}eq_enabled'])!,
      eqPresetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}eq_preset_id']),
      queueSourceType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}queue_source_type']),
      queueSourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}queue_source_id']),
    );
  }

  @override
  $PlaybackStatesTable createAlias(String alias) {
    return $PlaybackStatesTable(attachedDatabase, alias);
  }
}

class PlaybackState extends DataClass implements Insertable<PlaybackState> {
  /// Always 1 — singleton row.
  final int id;
  final bool shuffle;
  final String repeatMode;

  /// Master volume 0.0–1.0. Default 0.7 per REQUIREMENTS §7.1.
  final double volume;
  final int crossfadeSeconds;
  final bool eqEnabled;
  final int? eqPresetId;
  final String? queueSourceType;
  final int? queueSourceId;
  const PlaybackState(
      {required this.id,
      required this.shuffle,
      required this.repeatMode,
      required this.volume,
      required this.crossfadeSeconds,
      required this.eqEnabled,
      this.eqPresetId,
      this.queueSourceType,
      this.queueSourceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shuffle'] = Variable<bool>(shuffle);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['volume'] = Variable<double>(volume);
    map['crossfade_seconds'] = Variable<int>(crossfadeSeconds);
    map['eq_enabled'] = Variable<bool>(eqEnabled);
    if (!nullToAbsent || eqPresetId != null) {
      map['eq_preset_id'] = Variable<int>(eqPresetId);
    }
    if (!nullToAbsent || queueSourceType != null) {
      map['queue_source_type'] = Variable<String>(queueSourceType);
    }
    if (!nullToAbsent || queueSourceId != null) {
      map['queue_source_id'] = Variable<int>(queueSourceId);
    }
    return map;
  }

  PlaybackStatesCompanion toCompanion(bool nullToAbsent) {
    return PlaybackStatesCompanion(
      id: Value(id),
      shuffle: Value(shuffle),
      repeatMode: Value(repeatMode),
      volume: Value(volume),
      crossfadeSeconds: Value(crossfadeSeconds),
      eqEnabled: Value(eqEnabled),
      eqPresetId: eqPresetId == null && nullToAbsent
          ? const Value.absent()
          : Value(eqPresetId),
      queueSourceType: queueSourceType == null && nullToAbsent
          ? const Value.absent()
          : Value(queueSourceType),
      queueSourceId: queueSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(queueSourceId),
    );
  }

  factory PlaybackState.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackState(
      id: serializer.fromJson<int>(json['id']),
      shuffle: serializer.fromJson<bool>(json['shuffle']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      volume: serializer.fromJson<double>(json['volume']),
      crossfadeSeconds: serializer.fromJson<int>(json['crossfadeSeconds']),
      eqEnabled: serializer.fromJson<bool>(json['eqEnabled']),
      eqPresetId: serializer.fromJson<int?>(json['eqPresetId']),
      queueSourceType: serializer.fromJson<String?>(json['queueSourceType']),
      queueSourceId: serializer.fromJson<int?>(json['queueSourceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shuffle': serializer.toJson<bool>(shuffle),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'volume': serializer.toJson<double>(volume),
      'crossfadeSeconds': serializer.toJson<int>(crossfadeSeconds),
      'eqEnabled': serializer.toJson<bool>(eqEnabled),
      'eqPresetId': serializer.toJson<int?>(eqPresetId),
      'queueSourceType': serializer.toJson<String?>(queueSourceType),
      'queueSourceId': serializer.toJson<int?>(queueSourceId),
    };
  }

  PlaybackState copyWith(
          {int? id,
          bool? shuffle,
          String? repeatMode,
          double? volume,
          int? crossfadeSeconds,
          bool? eqEnabled,
          Value<int?> eqPresetId = const Value.absent(),
          Value<String?> queueSourceType = const Value.absent(),
          Value<int?> queueSourceId = const Value.absent()}) =>
      PlaybackState(
        id: id ?? this.id,
        shuffle: shuffle ?? this.shuffle,
        repeatMode: repeatMode ?? this.repeatMode,
        volume: volume ?? this.volume,
        crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
        eqEnabled: eqEnabled ?? this.eqEnabled,
        eqPresetId: eqPresetId.present ? eqPresetId.value : this.eqPresetId,
        queueSourceType: queueSourceType.present
            ? queueSourceType.value
            : this.queueSourceType,
        queueSourceId:
            queueSourceId.present ? queueSourceId.value : this.queueSourceId,
      );
  PlaybackState copyWithCompanion(PlaybackStatesCompanion data) {
    return PlaybackState(
      id: data.id.present ? data.id.value : this.id,
      shuffle: data.shuffle.present ? data.shuffle.value : this.shuffle,
      repeatMode:
          data.repeatMode.present ? data.repeatMode.value : this.repeatMode,
      volume: data.volume.present ? data.volume.value : this.volume,
      crossfadeSeconds: data.crossfadeSeconds.present
          ? data.crossfadeSeconds.value
          : this.crossfadeSeconds,
      eqEnabled: data.eqEnabled.present ? data.eqEnabled.value : this.eqEnabled,
      eqPresetId:
          data.eqPresetId.present ? data.eqPresetId.value : this.eqPresetId,
      queueSourceType: data.queueSourceType.present
          ? data.queueSourceType.value
          : this.queueSourceType,
      queueSourceId: data.queueSourceId.present
          ? data.queueSourceId.value
          : this.queueSourceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackState(')
          ..write('id: $id, ')
          ..write('shuffle: $shuffle, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('volume: $volume, ')
          ..write('crossfadeSeconds: $crossfadeSeconds, ')
          ..write('eqEnabled: $eqEnabled, ')
          ..write('eqPresetId: $eqPresetId, ')
          ..write('queueSourceType: $queueSourceType, ')
          ..write('queueSourceId: $queueSourceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shuffle, repeatMode, volume,
      crossfadeSeconds, eqEnabled, eqPresetId, queueSourceType, queueSourceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackState &&
          other.id == this.id &&
          other.shuffle == this.shuffle &&
          other.repeatMode == this.repeatMode &&
          other.volume == this.volume &&
          other.crossfadeSeconds == this.crossfadeSeconds &&
          other.eqEnabled == this.eqEnabled &&
          other.eqPresetId == this.eqPresetId &&
          other.queueSourceType == this.queueSourceType &&
          other.queueSourceId == this.queueSourceId);
}

class PlaybackStatesCompanion extends UpdateCompanion<PlaybackState> {
  final Value<int> id;
  final Value<bool> shuffle;
  final Value<String> repeatMode;
  final Value<double> volume;
  final Value<int> crossfadeSeconds;
  final Value<bool> eqEnabled;
  final Value<int?> eqPresetId;
  final Value<String?> queueSourceType;
  final Value<int?> queueSourceId;
  const PlaybackStatesCompanion({
    this.id = const Value.absent(),
    this.shuffle = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.volume = const Value.absent(),
    this.crossfadeSeconds = const Value.absent(),
    this.eqEnabled = const Value.absent(),
    this.eqPresetId = const Value.absent(),
    this.queueSourceType = const Value.absent(),
    this.queueSourceId = const Value.absent(),
  });
  PlaybackStatesCompanion.insert({
    this.id = const Value.absent(),
    this.shuffle = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.volume = const Value.absent(),
    this.crossfadeSeconds = const Value.absent(),
    this.eqEnabled = const Value.absent(),
    this.eqPresetId = const Value.absent(),
    this.queueSourceType = const Value.absent(),
    this.queueSourceId = const Value.absent(),
  });
  static Insertable<PlaybackState> custom({
    Expression<int>? id,
    Expression<bool>? shuffle,
    Expression<String>? repeatMode,
    Expression<double>? volume,
    Expression<int>? crossfadeSeconds,
    Expression<bool>? eqEnabled,
    Expression<int>? eqPresetId,
    Expression<String>? queueSourceType,
    Expression<int>? queueSourceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shuffle != null) 'shuffle': shuffle,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (volume != null) 'volume': volume,
      if (crossfadeSeconds != null) 'crossfade_seconds': crossfadeSeconds,
      if (eqEnabled != null) 'eq_enabled': eqEnabled,
      if (eqPresetId != null) 'eq_preset_id': eqPresetId,
      if (queueSourceType != null) 'queue_source_type': queueSourceType,
      if (queueSourceId != null) 'queue_source_id': queueSourceId,
    });
  }

  PlaybackStatesCompanion copyWith(
      {Value<int>? id,
      Value<bool>? shuffle,
      Value<String>? repeatMode,
      Value<double>? volume,
      Value<int>? crossfadeSeconds,
      Value<bool>? eqEnabled,
      Value<int?>? eqPresetId,
      Value<String?>? queueSourceType,
      Value<int?>? queueSourceId}) {
    return PlaybackStatesCompanion(
      id: id ?? this.id,
      shuffle: shuffle ?? this.shuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      crossfadeSeconds: crossfadeSeconds ?? this.crossfadeSeconds,
      eqEnabled: eqEnabled ?? this.eqEnabled,
      eqPresetId: eqPresetId ?? this.eqPresetId,
      queueSourceType: queueSourceType ?? this.queueSourceType,
      queueSourceId: queueSourceId ?? this.queueSourceId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shuffle.present) {
      map['shuffle'] = Variable<bool>(shuffle.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (crossfadeSeconds.present) {
      map['crossfade_seconds'] = Variable<int>(crossfadeSeconds.value);
    }
    if (eqEnabled.present) {
      map['eq_enabled'] = Variable<bool>(eqEnabled.value);
    }
    if (eqPresetId.present) {
      map['eq_preset_id'] = Variable<int>(eqPresetId.value);
    }
    if (queueSourceType.present) {
      map['queue_source_type'] = Variable<String>(queueSourceType.value);
    }
    if (queueSourceId.present) {
      map['queue_source_id'] = Variable<int>(queueSourceId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackStatesCompanion(')
          ..write('id: $id, ')
          ..write('shuffle: $shuffle, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('volume: $volume, ')
          ..write('crossfadeSeconds: $crossfadeSeconds, ')
          ..write('eqEnabled: $eqEnabled, ')
          ..write('eqPresetId: $eqPresetId, ')
          ..write('queueSourceType: $queueSourceType, ')
          ..write('queueSourceId: $queueSourceId')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecommendationsTable extends Recommendations
    with TableInfo<$RecommendationsTable, Recommendation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
      'song_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES songs (id)'));
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _generatedAtMeta =
      const VerificationMeta('generatedAt');
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
      'generated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, category, songId, score, generatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendations';
  @override
  VerificationContext validateIntegrity(Insertable<Recommendation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
          _generatedAtMeta,
          generatedAt.isAcceptableOrUnknown(
              data['generated_at']!, _generatedAtMeta));
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recommendation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recommendation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      songId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}song_id'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      generatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}generated_at'])!,
    );
  }

  @override
  $RecommendationsTable createAlias(String alias) {
    return $RecommendationsTable(attachedDatabase, alias);
  }
}

class Recommendation extends DataClass implements Insertable<Recommendation> {
  final int id;
  final String category;
  final int songId;
  final double score;
  final DateTime generatedAt;
  const Recommendation(
      {required this.id,
      required this.category,
      required this.songId,
      required this.score,
      required this.generatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['song_id'] = Variable<int>(songId);
    map['score'] = Variable<double>(score);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  RecommendationsCompanion toCompanion(bool nullToAbsent) {
    return RecommendationsCompanion(
      id: Value(id),
      category: Value(category),
      songId: Value(songId),
      score: Value(score),
      generatedAt: Value(generatedAt),
    );
  }

  factory Recommendation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recommendation(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      songId: serializer.fromJson<int>(json['songId']),
      score: serializer.fromJson<double>(json['score']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'songId': serializer.toJson<int>(songId),
      'score': serializer.toJson<double>(score),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  Recommendation copyWith(
          {int? id,
          String? category,
          int? songId,
          double? score,
          DateTime? generatedAt}) =>
      Recommendation(
        id: id ?? this.id,
        category: category ?? this.category,
        songId: songId ?? this.songId,
        score: score ?? this.score,
        generatedAt: generatedAt ?? this.generatedAt,
      );
  Recommendation copyWithCompanion(RecommendationsCompanion data) {
    return Recommendation(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      songId: data.songId.present ? data.songId.value : this.songId,
      score: data.score.present ? data.score.value : this.score,
      generatedAt:
          data.generatedAt.present ? data.generatedAt.value : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recommendation(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('songId: $songId, ')
          ..write('score: $score, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, songId, score, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recommendation &&
          other.id == this.id &&
          other.category == this.category &&
          other.songId == this.songId &&
          other.score == this.score &&
          other.generatedAt == this.generatedAt);
}

class RecommendationsCompanion extends UpdateCompanion<Recommendation> {
  final Value<int> id;
  final Value<String> category;
  final Value<int> songId;
  final Value<double> score;
  final Value<DateTime> generatedAt;
  const RecommendationsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.songId = const Value.absent(),
    this.score = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  RecommendationsCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required int songId,
    required double score,
    required DateTime generatedAt,
  })  : category = Value(category),
        songId = Value(songId),
        score = Value(score),
        generatedAt = Value(generatedAt);
  static Insertable<Recommendation> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<int>? songId,
    Expression<double>? score,
    Expression<DateTime>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (songId != null) 'song_id': songId,
      if (score != null) 'score': score,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  RecommendationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? category,
      Value<int>? songId,
      Value<double>? score,
      Value<DateTime>? generatedAt}) {
    return RecommendationsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      songId: songId ?? this.songId,
      score: score ?? this.score,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('songId: $songId, ')
          ..write('score: $score, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScanFoldersTable extends ScanFolders
    with TableInfo<$ScanFoldersTable, ScanFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastScannedAtMeta =
      const VerificationMeta('lastScannedAt');
  @override
  late final GeneratedColumn<DateTime> lastScannedAt =
      GeneratedColumn<DateTime>('last_scanned_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, path, enabled, lastScannedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_folders';
  @override
  VerificationContext validateIntegrity(Insertable<ScanFolder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('last_scanned_at')) {
      context.handle(
          _lastScannedAtMeta,
          lastScannedAt.isAcceptableOrUnknown(
              data['last_scanned_at']!, _lastScannedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanFolder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
      lastScannedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_scanned_at']),
    );
  }

  @override
  $ScanFoldersTable createAlias(String alias) {
    return $ScanFoldersTable(attachedDatabase, alias);
  }
}

class ScanFolder extends DataClass implements Insertable<ScanFolder> {
  final int id;
  final String path;
  final bool enabled;
  final DateTime? lastScannedAt;
  const ScanFolder(
      {required this.id,
      required this.path,
      required this.enabled,
      this.lastScannedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || lastScannedAt != null) {
      map['last_scanned_at'] = Variable<DateTime>(lastScannedAt);
    }
    return map;
  }

  ScanFoldersCompanion toCompanion(bool nullToAbsent) {
    return ScanFoldersCompanion(
      id: Value(id),
      path: Value(path),
      enabled: Value(enabled),
      lastScannedAt: lastScannedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScannedAt),
    );
  }

  factory ScanFolder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanFolder(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      lastScannedAt: serializer.fromJson<DateTime?>(json['lastScannedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'enabled': serializer.toJson<bool>(enabled),
      'lastScannedAt': serializer.toJson<DateTime?>(lastScannedAt),
    };
  }

  ScanFolder copyWith(
          {int? id,
          String? path,
          bool? enabled,
          Value<DateTime?> lastScannedAt = const Value.absent()}) =>
      ScanFolder(
        id: id ?? this.id,
        path: path ?? this.path,
        enabled: enabled ?? this.enabled,
        lastScannedAt:
            lastScannedAt.present ? lastScannedAt.value : this.lastScannedAt,
      );
  ScanFolder copyWithCompanion(ScanFoldersCompanion data) {
    return ScanFolder(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      lastScannedAt: data.lastScannedAt.present
          ? data.lastScannedAt.value
          : this.lastScannedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanFolder(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('enabled: $enabled, ')
          ..write('lastScannedAt: $lastScannedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, path, enabled, lastScannedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanFolder &&
          other.id == this.id &&
          other.path == this.path &&
          other.enabled == this.enabled &&
          other.lastScannedAt == this.lastScannedAt);
}

class ScanFoldersCompanion extends UpdateCompanion<ScanFolder> {
  final Value<int> id;
  final Value<String> path;
  final Value<bool> enabled;
  final Value<DateTime?> lastScannedAt;
  const ScanFoldersCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.enabled = const Value.absent(),
    this.lastScannedAt = const Value.absent(),
  });
  ScanFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    this.enabled = const Value.absent(),
    this.lastScannedAt = const Value.absent(),
  }) : path = Value(path);
  static Insertable<ScanFolder> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<bool>? enabled,
    Expression<DateTime>? lastScannedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (enabled != null) 'enabled': enabled,
      if (lastScannedAt != null) 'last_scanned_at': lastScannedAt,
    });
  }

  ScanFoldersCompanion copyWith(
      {Value<int>? id,
      Value<String>? path,
      Value<bool>? enabled,
      Value<DateTime?>? lastScannedAt}) {
    return ScanFoldersCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      enabled: enabled ?? this.enabled,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (lastScannedAt.present) {
      map['last_scanned_at'] = Variable<DateTime>(lastScannedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanFoldersCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('enabled: $enabled, ')
          ..write('lastScannedAt: $lastScannedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SongsTable songs = $SongsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistSongsTable playlistSongs = $PlaylistSongsTable(this);
  late final $PlayHistoryTable playHistory = $PlayHistoryTable(this);
  late final $QueueItemsTable queueItems = $QueueItemsTable(this);
  late final $EqPresetsTable eqPresets = $EqPresetsTable(this);
  late final $PlaybackStatesTable playbackStates = $PlaybackStatesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $RecommendationsTable recommendations =
      $RecommendationsTable(this);
  late final $ScanFoldersTable scanFolders = $ScanFoldersTable(this);
  late final SongDao songDao = SongDao(this as AppDatabase);
  late final PlaylistDao playlistDao = PlaylistDao(this as AppDatabase);
  late final PlaybackDao playbackDao = PlaybackDao(this as AppDatabase);
  late final QueueDao queueDao = QueueDao(this as AppDatabase);
  late final PlayHistoryDao playHistoryDao =
      PlayHistoryDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final ScanFolderDao scanFolderDao = ScanFolderDao(this as AppDatabase);
  late final EqPresetDao eqPresetDao = EqPresetDao(this as AppDatabase);
  late final RecommendationsDao recommendationsDao =
      RecommendationsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        songs,
        playlists,
        playlistSongs,
        playHistory,
        queueItems,
        eqPresets,
        playbackStates,
        settings,
        recommendations,
        scanFolders
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$SongsTableCreateCompanionBuilder = SongsCompanion Function({
  Value<int> id,
  required String filePath,
  required String title,
  Value<String> artist,
  Value<String> album,
  Value<String> albumArtist,
  Value<String> genre,
  Value<int?> year,
  Value<int?> trackNumber,
  Value<int?> discNumber,
  Value<int> durationMs,
  Value<int> fileSize,
  required DateTime fileModifiedAt,
  Value<String?> artCachePath,
  Value<DateTime> dateAdded,
  Value<int> playCount,
  Value<DateTime?> lastPlayedAt,
  Value<bool> isFavorite,
  Value<bool> isMissing,
});
typedef $$SongsTableUpdateCompanionBuilder = SongsCompanion Function({
  Value<int> id,
  Value<String> filePath,
  Value<String> title,
  Value<String> artist,
  Value<String> album,
  Value<String> albumArtist,
  Value<String> genre,
  Value<int?> year,
  Value<int?> trackNumber,
  Value<int?> discNumber,
  Value<int> durationMs,
  Value<int> fileSize,
  Value<DateTime> fileModifiedAt,
  Value<String?> artCachePath,
  Value<DateTime> dateAdded,
  Value<int> playCount,
  Value<DateTime?> lastPlayedAt,
  Value<bool> isFavorite,
  Value<bool> isMissing,
});

final class $$SongsTableReferences
    extends BaseReferences<_$AppDatabase, $SongsTable, Song> {
  $$SongsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistSongsTable, List<PlaylistSong>>
      _playlistSongsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.playlistSongs,
              aliasName:
                  $_aliasNameGenerator(db.songs.id, db.playlistSongs.songId));

  $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
    final manager = $$PlaylistSongsTableTableManager($_db, $_db.playlistSongs)
        .filter((f) => f.songId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlayHistoryTable, List<PlayHistoryData>>
      _playHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.playHistory,
          aliasName: $_aliasNameGenerator(db.songs.id, db.playHistory.songId));

  $$PlayHistoryTableProcessedTableManager get playHistoryRefs {
    final manager = $$PlayHistoryTableTableManager($_db, $_db.playHistory)
        .filter((f) => f.songId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playHistoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$QueueItemsTable, List<QueueItem>>
      _queueItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.queueItems,
          aliasName: $_aliasNameGenerator(db.songs.id, db.queueItems.songId));

  $$QueueItemsTableProcessedTableManager get queueItemsRefs {
    final manager = $$QueueItemsTableTableManager($_db, $_db.queueItems)
        .filter((f) => f.songId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecommendationsTable, List<Recommendation>>
      _recommendationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recommendations,
              aliasName:
                  $_aliasNameGenerator(db.songs.id, db.recommendations.songId));

  $$RecommendationsTableProcessedTableManager get recommendationsRefs {
    final manager =
        $$RecommendationsTableTableManager($_db, $_db.recommendations)
            .filter((f) => f.songId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_recommendationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SongsTableFilterComposer extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get album => $composableBuilder(
      column: $table.album, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get albumArtist => $composableBuilder(
      column: $table.albumArtist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get genre => $composableBuilder(
      column: $table.genre, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get trackNumber => $composableBuilder(
      column: $table.trackNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discNumber => $composableBuilder(
      column: $table.discNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fileModifiedAt => $composableBuilder(
      column: $table.fileModifiedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artCachePath => $composableBuilder(
      column: $table.artCachePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get playCount => $composableBuilder(
      column: $table.playCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
      column: $table.lastPlayedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMissing => $composableBuilder(
      column: $table.isMissing, builder: (column) => ColumnFilters(column));

  Expression<bool> playlistSongsRefs(
      Expression<bool> Function($$PlaylistSongsTableFilterComposer f) f) {
    final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playlistSongs,
        getReferencedColumn: (t) => t.songId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistSongsTableFilterComposer(
              $db: $db,
              $table: $db.playlistSongs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> playHistoryRefs(
      Expression<bool> Function($$PlayHistoryTableFilterComposer f) f) {
    final $$PlayHistoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playHistory,
        getReferencedColumn: (t) => t.songId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlayHistoryTableFilterComposer(
              $db: $db,
              $table: $db.playHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> queueItemsRefs(
      Expression<bool> Function($$QueueItemsTableFilterComposer f) f) {
    final $$QueueItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.queueItems,
        getReferencedColumn: (t) => t.songId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QueueItemsTableFilterComposer(
              $db: $db,
              $table: $db.queueItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> recommendationsRefs(
      Expression<bool> Function($$RecommendationsTableFilterComposer f) f) {
    final $$RecommendationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recommendations,
        getReferencedColumn: (t) => t.songId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecommendationsTableFilterComposer(
              $db: $db,
              $table: $db.recommendations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SongsTableOrderingComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get album => $composableBuilder(
      column: $table.album, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get albumArtist => $composableBuilder(
      column: $table.albumArtist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get genre => $composableBuilder(
      column: $table.genre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get trackNumber => $composableBuilder(
      column: $table.trackNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discNumber => $composableBuilder(
      column: $table.discNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fileModifiedAt => $composableBuilder(
      column: $table.fileModifiedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artCachePath => $composableBuilder(
      column: $table.artCachePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
      column: $table.dateAdded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get playCount => $composableBuilder(
      column: $table.playCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
      column: $table.lastPlayedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMissing => $composableBuilder(
      column: $table.isMissing, builder: (column) => ColumnOrderings(column));
}

class $$SongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SongsTable> {
  $$SongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
      column: $table.albumArtist, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get trackNumber => $composableBuilder(
      column: $table.trackNumber, builder: (column) => column);

  GeneratedColumn<int> get discNumber => $composableBuilder(
      column: $table.discNumber, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get fileModifiedAt => $composableBuilder(
      column: $table.fileModifiedAt, builder: (column) => column);

  GeneratedColumn<String> get artCachePath => $composableBuilder(
      column: $table.artCachePath, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
      column: $table.lastPlayedAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<bool> get isMissing =>
      $composableBuilder(column: $table.isMissing, builder: (column) => column);

  Expression<T> playlistSongsRefs<T extends Object>(
      Expression<T> Function($$PlaylistSongsTableAnnotationComposer a) f) {
    final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playlistSongs,
        getReferencedColumn: (t) => t.songId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistSongsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlistSongs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> playHistoryRefs<T extends Object>(
      Expression<T> Function($$PlayHistoryTableAnnotationComposer a) f) {
    final $$PlayHistoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playHistory,
        getReferencedColumn: (t) => t.songId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlayHistoryTableAnnotationComposer(
              $db: $db,
              $table: $db.playHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> queueItemsRefs<T extends Object>(
      Expression<T> Function($$QueueItemsTableAnnotationComposer a) f) {
    final $$QueueItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.queueItems,
        getReferencedColumn: (t) => t.songId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QueueItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.queueItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> recommendationsRefs<T extends Object>(
      Expression<T> Function($$RecommendationsTableAnnotationComposer a) f) {
    final $$RecommendationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recommendations,
        getReferencedColumn: (t) => t.songId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecommendationsTableAnnotationComposer(
              $db: $db,
              $table: $db.recommendations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SongsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SongsTable,
    Song,
    $$SongsTableFilterComposer,
    $$SongsTableOrderingComposer,
    $$SongsTableAnnotationComposer,
    $$SongsTableCreateCompanionBuilder,
    $$SongsTableUpdateCompanionBuilder,
    (Song, $$SongsTableReferences),
    Song,
    PrefetchHooks Function(
        {bool playlistSongsRefs,
        bool playHistoryRefs,
        bool queueItemsRefs,
        bool recommendationsRefs})> {
  $$SongsTableTableManager(_$AppDatabase db, $SongsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> artist = const Value.absent(),
            Value<String> album = const Value.absent(),
            Value<String> albumArtist = const Value.absent(),
            Value<String> genre = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<int?> trackNumber = const Value.absent(),
            Value<int?> discNumber = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<DateTime> fileModifiedAt = const Value.absent(),
            Value<String?> artCachePath = const Value.absent(),
            Value<DateTime> dateAdded = const Value.absent(),
            Value<int> playCount = const Value.absent(),
            Value<DateTime?> lastPlayedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isMissing = const Value.absent(),
          }) =>
              SongsCompanion(
            id: id,
            filePath: filePath,
            title: title,
            artist: artist,
            album: album,
            albumArtist: albumArtist,
            genre: genre,
            year: year,
            trackNumber: trackNumber,
            discNumber: discNumber,
            durationMs: durationMs,
            fileSize: fileSize,
            fileModifiedAt: fileModifiedAt,
            artCachePath: artCachePath,
            dateAdded: dateAdded,
            playCount: playCount,
            lastPlayedAt: lastPlayedAt,
            isFavorite: isFavorite,
            isMissing: isMissing,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String filePath,
            required String title,
            Value<String> artist = const Value.absent(),
            Value<String> album = const Value.absent(),
            Value<String> albumArtist = const Value.absent(),
            Value<String> genre = const Value.absent(),
            Value<int?> year = const Value.absent(),
            Value<int?> trackNumber = const Value.absent(),
            Value<int?> discNumber = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            required DateTime fileModifiedAt,
            Value<String?> artCachePath = const Value.absent(),
            Value<DateTime> dateAdded = const Value.absent(),
            Value<int> playCount = const Value.absent(),
            Value<DateTime?> lastPlayedAt = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<bool> isMissing = const Value.absent(),
          }) =>
              SongsCompanion.insert(
            id: id,
            filePath: filePath,
            title: title,
            artist: artist,
            album: album,
            albumArtist: albumArtist,
            genre: genre,
            year: year,
            trackNumber: trackNumber,
            discNumber: discNumber,
            durationMs: durationMs,
            fileSize: fileSize,
            fileModifiedAt: fileModifiedAt,
            artCachePath: artCachePath,
            dateAdded: dateAdded,
            playCount: playCount,
            lastPlayedAt: lastPlayedAt,
            isFavorite: isFavorite,
            isMissing: isMissing,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SongsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {playlistSongsRefs = false,
              playHistoryRefs = false,
              queueItemsRefs = false,
              recommendationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistSongsRefs) db.playlistSongs,
                if (playHistoryRefs) db.playHistory,
                if (queueItemsRefs) db.queueItems,
                if (recommendationsRefs) db.recommendations
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistSongsRefs)
                    await $_getPrefetchedData<Song, $SongsTable, PlaylistSong>(
                        currentTable: table,
                        referencedTable:
                            $$SongsTableReferences._playlistSongsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SongsTableReferences(db, table, p0)
                                .playlistSongsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.songId == item.id),
                        typedResults: items),
                  if (playHistoryRefs)
                    await $_getPrefetchedData<Song, $SongsTable,
                            PlayHistoryData>(
                        currentTable: table,
                        referencedTable:
                            $$SongsTableReferences._playHistoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SongsTableReferences(db, table, p0)
                                .playHistoryRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.songId == item.id),
                        typedResults: items),
                  if (queueItemsRefs)
                    await $_getPrefetchedData<Song, $SongsTable, QueueItem>(
                        currentTable: table,
                        referencedTable:
                            $$SongsTableReferences._queueItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SongsTableReferences(db, table, p0)
                                .queueItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.songId == item.id),
                        typedResults: items),
                  if (recommendationsRefs)
                    await $_getPrefetchedData<Song, $SongsTable,
                            Recommendation>(
                        currentTable: table,
                        referencedTable: $$SongsTableReferences
                            ._recommendationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SongsTableReferences(db, table, p0)
                                .recommendationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.songId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SongsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SongsTable,
    Song,
    $$SongsTableFilterComposer,
    $$SongsTableOrderingComposer,
    $$SongsTableAnnotationComposer,
    $$SongsTableCreateCompanionBuilder,
    $$SongsTableUpdateCompanionBuilder,
    (Song, $$SongsTableReferences),
    Song,
    PrefetchHooks Function(
        {bool playlistSongsRefs,
        bool playHistoryRefs,
        bool queueItemsRefs,
        bool recommendationsRefs})>;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> coverArtPath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isSmart,
  Value<String?> smartRule,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> coverArtPath,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isSmart,
  Value<String?> smartRule,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistSongsTable, List<PlaylistSong>>
      _playlistSongsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.playlistSongs,
              aliasName: $_aliasNameGenerator(
                  db.playlists.id, db.playlistSongs.playlistId));

  $$PlaylistSongsTableProcessedTableManager get playlistSongsRefs {
    final manager = $$PlaylistSongsTableTableManager($_db, $_db.playlistSongs)
        .filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistSongsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverArtPath => $composableBuilder(
      column: $table.coverArtPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSmart => $composableBuilder(
      column: $table.isSmart, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get smartRule => $composableBuilder(
      column: $table.smartRule, builder: (column) => ColumnFilters(column));

  Expression<bool> playlistSongsRefs(
      Expression<bool> Function($$PlaylistSongsTableFilterComposer f) f) {
    final $$PlaylistSongsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playlistSongs,
        getReferencedColumn: (t) => t.playlistId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistSongsTableFilterComposer(
              $db: $db,
              $table: $db.playlistSongs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverArtPath => $composableBuilder(
      column: $table.coverArtPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSmart => $composableBuilder(
      column: $table.isSmart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get smartRule => $composableBuilder(
      column: $table.smartRule, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get coverArtPath => $composableBuilder(
      column: $table.coverArtPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSmart =>
      $composableBuilder(column: $table.isSmart, builder: (column) => column);

  GeneratedColumn<String> get smartRule =>
      $composableBuilder(column: $table.smartRule, builder: (column) => column);

  Expression<T> playlistSongsRefs<T extends Object>(
      Expression<T> Function($$PlaylistSongsTableAnnotationComposer a) f) {
    final $$PlaylistSongsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playlistSongs,
        getReferencedColumn: (t) => t.playlistId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistSongsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlistSongs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlaylistsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, $$PlaylistsTableReferences),
    Playlist,
    PrefetchHooks Function({bool playlistSongsRefs})> {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> coverArtPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSmart = const Value.absent(),
            Value<String?> smartRule = const Value.absent(),
          }) =>
              PlaylistsCompanion(
            id: id,
            name: name,
            coverArtPath: coverArtPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSmart: isSmart,
            smartRule: smartRule,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> coverArtPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isSmart = const Value.absent(),
            Value<String?> smartRule = const Value.absent(),
          }) =>
              PlaylistsCompanion.insert(
            id: id,
            name: name,
            coverArtPath: coverArtPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isSmart: isSmart,
            smartRule: smartRule,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaylistsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({playlistSongsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistSongsRefs) db.playlistSongs
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistSongsRefs)
                    await $_getPrefetchedData<Playlist, $PlaylistsTable,
                            PlaylistSong>(
                        currentTable: table,
                        referencedTable: $$PlaylistsTableReferences
                            ._playlistSongsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlaylistsTableReferences(db, table, p0)
                                .playlistSongsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.playlistId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlaylistsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    Playlist,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (Playlist, $$PlaylistsTableReferences),
    Playlist,
    PrefetchHooks Function({bool playlistSongsRefs})>;
typedef $$PlaylistSongsTableCreateCompanionBuilder = PlaylistSongsCompanion
    Function({
  required int playlistId,
  required int songId,
  required int sortOrder,
  Value<DateTime> addedAt,
  Value<int> rowid,
});
typedef $$PlaylistSongsTableUpdateCompanionBuilder = PlaylistSongsCompanion
    Function({
  Value<int> playlistId,
  Value<int> songId,
  Value<int> sortOrder,
  Value<DateTime> addedAt,
  Value<int> rowid,
});

final class $$PlaylistSongsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistSongsTable, PlaylistSong> {
  $$PlaylistSongsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias(
          $_aliasNameGenerator(db.playlistSongs.playlistId, db.playlists.id));

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager($_db, $_db.playlists)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs
      .createAlias($_aliasNameGenerator(db.playlistSongs.songId, db.songs.id));

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<int>('song_id')!;

    final manager = $$SongsTableTableManager($_db, $_db.songs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlaylistSongsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableFilterComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableFilterComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistSongsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableOrderingComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableOrderingComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistSongsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistSongsTable> {
  $$PlaylistSongsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableAnnotationComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistSongsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistSongsTable,
    PlaylistSong,
    $$PlaylistSongsTableFilterComposer,
    $$PlaylistSongsTableOrderingComposer,
    $$PlaylistSongsTableAnnotationComposer,
    $$PlaylistSongsTableCreateCompanionBuilder,
    $$PlaylistSongsTableUpdateCompanionBuilder,
    (PlaylistSong, $$PlaylistSongsTableReferences),
    PlaylistSong,
    PrefetchHooks Function({bool playlistId, bool songId})> {
  $$PlaylistSongsTableTableManager(_$AppDatabase db, $PlaylistSongsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistSongsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistSongsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistSongsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> playlistId = const Value.absent(),
            Value<int> songId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistSongsCompanion(
            playlistId: playlistId,
            songId: songId,
            sortOrder: sortOrder,
            addedAt: addedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int playlistId,
            required int songId,
            required int sortOrder,
            Value<DateTime> addedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistSongsCompanion.insert(
            playlistId: playlistId,
            songId: songId,
            sortOrder: sortOrder,
            addedAt: addedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaylistSongsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({playlistId = false, songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (playlistId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.playlistId,
                    referencedTable:
                        $$PlaylistSongsTableReferences._playlistIdTable(db),
                    referencedColumn:
                        $$PlaylistSongsTableReferences._playlistIdTable(db).id,
                  ) as T;
                }
                if (songId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.songId,
                    referencedTable:
                        $$PlaylistSongsTableReferences._songIdTable(db),
                    referencedColumn:
                        $$PlaylistSongsTableReferences._songIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlaylistSongsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistSongsTable,
    PlaylistSong,
    $$PlaylistSongsTableFilterComposer,
    $$PlaylistSongsTableOrderingComposer,
    $$PlaylistSongsTableAnnotationComposer,
    $$PlaylistSongsTableCreateCompanionBuilder,
    $$PlaylistSongsTableUpdateCompanionBuilder,
    (PlaylistSong, $$PlaylistSongsTableReferences),
    PlaylistSong,
    PrefetchHooks Function({bool playlistId, bool songId})>;
typedef $$PlayHistoryTableCreateCompanionBuilder = PlayHistoryCompanion
    Function({
  Value<int> id,
  required int songId,
  required DateTime playedAt,
  required int durationListenedMs,
  required int sessionId,
});
typedef $$PlayHistoryTableUpdateCompanionBuilder = PlayHistoryCompanion
    Function({
  Value<int> id,
  Value<int> songId,
  Value<DateTime> playedAt,
  Value<int> durationListenedMs,
  Value<int> sessionId,
});

final class $$PlayHistoryTableReferences
    extends BaseReferences<_$AppDatabase, $PlayHistoryTable, PlayHistoryData> {
  $$PlayHistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs
      .createAlias($_aliasNameGenerator(db.playHistory.songId, db.songs.id));

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<int>('song_id')!;

    final manager = $$SongsTableTableManager($_db, $_db.songs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlayHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
      column: $table.playedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationListenedMs => $composableBuilder(
      column: $table.durationListenedMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableFilterComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlayHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
      column: $table.playedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationListenedMs => $composableBuilder(
      column: $table.durationListenedMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableOrderingComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlayHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get durationListenedMs => $composableBuilder(
      column: $table.durationListenedMs, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableAnnotationComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlayHistoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayHistoryTable,
    PlayHistoryData,
    $$PlayHistoryTableFilterComposer,
    $$PlayHistoryTableOrderingComposer,
    $$PlayHistoryTableAnnotationComposer,
    $$PlayHistoryTableCreateCompanionBuilder,
    $$PlayHistoryTableUpdateCompanionBuilder,
    (PlayHistoryData, $$PlayHistoryTableReferences),
    PlayHistoryData,
    PrefetchHooks Function({bool songId})> {
  $$PlayHistoryTableTableManager(_$AppDatabase db, $PlayHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> songId = const Value.absent(),
            Value<DateTime> playedAt = const Value.absent(),
            Value<int> durationListenedMs = const Value.absent(),
            Value<int> sessionId = const Value.absent(),
          }) =>
              PlayHistoryCompanion(
            id: id,
            songId: songId,
            playedAt: playedAt,
            durationListenedMs: durationListenedMs,
            sessionId: sessionId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int songId,
            required DateTime playedAt,
            required int durationListenedMs,
            required int sessionId,
          }) =>
              PlayHistoryCompanion.insert(
            id: id,
            songId: songId,
            playedAt: playedAt,
            durationListenedMs: durationListenedMs,
            sessionId: sessionId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlayHistoryTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (songId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.songId,
                    referencedTable:
                        $$PlayHistoryTableReferences._songIdTable(db),
                    referencedColumn:
                        $$PlayHistoryTableReferences._songIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlayHistoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayHistoryTable,
    PlayHistoryData,
    $$PlayHistoryTableFilterComposer,
    $$PlayHistoryTableOrderingComposer,
    $$PlayHistoryTableAnnotationComposer,
    $$PlayHistoryTableCreateCompanionBuilder,
    $$PlayHistoryTableUpdateCompanionBuilder,
    (PlayHistoryData, $$PlayHistoryTableReferences),
    PlayHistoryData,
    PrefetchHooks Function({bool songId})>;
typedef $$QueueItemsTableCreateCompanionBuilder = QueueItemsCompanion Function({
  Value<int> id,
  required int songId,
  required int sortOrder,
  Value<bool> isCurrent,
  Value<int> positionMs,
});
typedef $$QueueItemsTableUpdateCompanionBuilder = QueueItemsCompanion Function({
  Value<int> id,
  Value<int> songId,
  Value<int> sortOrder,
  Value<bool> isCurrent,
  Value<int> positionMs,
});

final class $$QueueItemsTableReferences
    extends BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItem> {
  $$QueueItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs
      .createAlias($_aliasNameGenerator(db.queueItems.songId, db.songs.id));

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<int>('song_id')!;

    final manager = $$SongsTableTableManager($_db, $_db.songs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$QueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCurrent => $composableBuilder(
      column: $table.isCurrent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => ColumnFilters(column));

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableFilterComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
      column: $table.isCurrent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => ColumnOrderings(column));

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableOrderingComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
      column: $table.positionMs, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableAnnotationComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QueueItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QueueItemsTable,
    QueueItem,
    $$QueueItemsTableFilterComposer,
    $$QueueItemsTableOrderingComposer,
    $$QueueItemsTableAnnotationComposer,
    $$QueueItemsTableCreateCompanionBuilder,
    $$QueueItemsTableUpdateCompanionBuilder,
    (QueueItem, $$QueueItemsTableReferences),
    QueueItem,
    PrefetchHooks Function({bool songId})> {
  $$QueueItemsTableTableManager(_$AppDatabase db, $QueueItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> songId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isCurrent = const Value.absent(),
            Value<int> positionMs = const Value.absent(),
          }) =>
              QueueItemsCompanion(
            id: id,
            songId: songId,
            sortOrder: sortOrder,
            isCurrent: isCurrent,
            positionMs: positionMs,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int songId,
            required int sortOrder,
            Value<bool> isCurrent = const Value.absent(),
            Value<int> positionMs = const Value.absent(),
          }) =>
              QueueItemsCompanion.insert(
            id: id,
            songId: songId,
            sortOrder: sortOrder,
            isCurrent: isCurrent,
            positionMs: positionMs,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QueueItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (songId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.songId,
                    referencedTable:
                        $$QueueItemsTableReferences._songIdTable(db),
                    referencedColumn:
                        $$QueueItemsTableReferences._songIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$QueueItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QueueItemsTable,
    QueueItem,
    $$QueueItemsTableFilterComposer,
    $$QueueItemsTableOrderingComposer,
    $$QueueItemsTableAnnotationComposer,
    $$QueueItemsTableCreateCompanionBuilder,
    $$QueueItemsTableUpdateCompanionBuilder,
    (QueueItem, $$QueueItemsTableReferences),
    QueueItem,
    PrefetchHooks Function({bool songId})>;
typedef $$EqPresetsTableCreateCompanionBuilder = EqPresetsCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> isBuiltin,
  required String bandsJson,
  Value<DateTime> createdAt,
});
typedef $$EqPresetsTableUpdateCompanionBuilder = EqPresetsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> isBuiltin,
  Value<String> bandsJson,
  Value<DateTime> createdAt,
});

final class $$EqPresetsTableReferences
    extends BaseReferences<_$AppDatabase, $EqPresetsTable, EqPreset> {
  $$EqPresetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaybackStatesTable, List<PlaybackState>>
      _playbackStatesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.playbackStates,
              aliasName: $_aliasNameGenerator(
                  db.eqPresets.id, db.playbackStates.eqPresetId));

  $$PlaybackStatesTableProcessedTableManager get playbackStatesRefs {
    final manager = $$PlaybackStatesTableTableManager($_db, $_db.playbackStates)
        .filter((f) => f.eqPresetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playbackStatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EqPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $EqPresetsTable> {
  $$EqPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
      column: $table.isBuiltin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bandsJson => $composableBuilder(
      column: $table.bandsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> playbackStatesRefs(
      Expression<bool> Function($$PlaybackStatesTableFilterComposer f) f) {
    final $$PlaybackStatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playbackStates,
        getReferencedColumn: (t) => t.eqPresetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaybackStatesTableFilterComposer(
              $db: $db,
              $table: $db.playbackStates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EqPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $EqPresetsTable> {
  $$EqPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
      column: $table.isBuiltin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bandsJson => $composableBuilder(
      column: $table.bandsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$EqPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EqPresetsTable> {
  $$EqPresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<String> get bandsJson =>
      $composableBuilder(column: $table.bandsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> playbackStatesRefs<T extends Object>(
      Expression<T> Function($$PlaybackStatesTableAnnotationComposer a) f) {
    final $$PlaybackStatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playbackStates,
        getReferencedColumn: (t) => t.eqPresetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaybackStatesTableAnnotationComposer(
              $db: $db,
              $table: $db.playbackStates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EqPresetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EqPresetsTable,
    EqPreset,
    $$EqPresetsTableFilterComposer,
    $$EqPresetsTableOrderingComposer,
    $$EqPresetsTableAnnotationComposer,
    $$EqPresetsTableCreateCompanionBuilder,
    $$EqPresetsTableUpdateCompanionBuilder,
    (EqPreset, $$EqPresetsTableReferences),
    EqPreset,
    PrefetchHooks Function({bool playbackStatesRefs})> {
  $$EqPresetsTableTableManager(_$AppDatabase db, $EqPresetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EqPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EqPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EqPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isBuiltin = const Value.absent(),
            Value<String> bandsJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              EqPresetsCompanion(
            id: id,
            name: name,
            isBuiltin: isBuiltin,
            bandsJson: bandsJson,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<bool> isBuiltin = const Value.absent(),
            required String bandsJson,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              EqPresetsCompanion.insert(
            id: id,
            name: name,
            isBuiltin: isBuiltin,
            bandsJson: bandsJson,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EqPresetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({playbackStatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playbackStatesRefs) db.playbackStates
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playbackStatesRefs)
                    await $_getPrefetchedData<EqPreset, $EqPresetsTable,
                            PlaybackState>(
                        currentTable: table,
                        referencedTable: $$EqPresetsTableReferences
                            ._playbackStatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EqPresetsTableReferences(db, table, p0)
                                .playbackStatesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.eqPresetId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EqPresetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EqPresetsTable,
    EqPreset,
    $$EqPresetsTableFilterComposer,
    $$EqPresetsTableOrderingComposer,
    $$EqPresetsTableAnnotationComposer,
    $$EqPresetsTableCreateCompanionBuilder,
    $$EqPresetsTableUpdateCompanionBuilder,
    (EqPreset, $$EqPresetsTableReferences),
    EqPreset,
    PrefetchHooks Function({bool playbackStatesRefs})>;
typedef $$PlaybackStatesTableCreateCompanionBuilder = PlaybackStatesCompanion
    Function({
  Value<int> id,
  Value<bool> shuffle,
  Value<String> repeatMode,
  Value<double> volume,
  Value<int> crossfadeSeconds,
  Value<bool> eqEnabled,
  Value<int?> eqPresetId,
  Value<String?> queueSourceType,
  Value<int?> queueSourceId,
});
typedef $$PlaybackStatesTableUpdateCompanionBuilder = PlaybackStatesCompanion
    Function({
  Value<int> id,
  Value<bool> shuffle,
  Value<String> repeatMode,
  Value<double> volume,
  Value<int> crossfadeSeconds,
  Value<bool> eqEnabled,
  Value<int?> eqPresetId,
  Value<String?> queueSourceType,
  Value<int?> queueSourceId,
});

final class $$PlaybackStatesTableReferences
    extends BaseReferences<_$AppDatabase, $PlaybackStatesTable, PlaybackState> {
  $$PlaybackStatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EqPresetsTable _eqPresetIdTable(_$AppDatabase db) =>
      db.eqPresets.createAlias(
          $_aliasNameGenerator(db.playbackStates.eqPresetId, db.eqPresets.id));

  $$EqPresetsTableProcessedTableManager? get eqPresetId {
    final $_column = $_itemColumn<int>('eq_preset_id');
    if ($_column == null) return null;
    final manager = $$EqPresetsTableTableManager($_db, $_db.eqPresets)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eqPresetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlaybackStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get shuffle => $composableBuilder(
      column: $table.shuffle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeatMode => $composableBuilder(
      column: $table.repeatMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get crossfadeSeconds => $composableBuilder(
      column: $table.crossfadeSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get eqEnabled => $composableBuilder(
      column: $table.eqEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get queueSourceType => $composableBuilder(
      column: $table.queueSourceType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get queueSourceId => $composableBuilder(
      column: $table.queueSourceId, builder: (column) => ColumnFilters(column));

  $$EqPresetsTableFilterComposer get eqPresetId {
    final $$EqPresetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eqPresetId,
        referencedTable: $db.eqPresets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EqPresetsTableFilterComposer(
              $db: $db,
              $table: $db.eqPresets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaybackStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get shuffle => $composableBuilder(
      column: $table.shuffle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeatMode => $composableBuilder(
      column: $table.repeatMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get crossfadeSeconds => $composableBuilder(
      column: $table.crossfadeSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get eqEnabled => $composableBuilder(
      column: $table.eqEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get queueSourceType => $composableBuilder(
      column: $table.queueSourceType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get queueSourceId => $composableBuilder(
      column: $table.queueSourceId,
      builder: (column) => ColumnOrderings(column));

  $$EqPresetsTableOrderingComposer get eqPresetId {
    final $$EqPresetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eqPresetId,
        referencedTable: $db.eqPresets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EqPresetsTableOrderingComposer(
              $db: $db,
              $table: $db.eqPresets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaybackStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackStatesTable> {
  $$PlaybackStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get shuffle =>
      $composableBuilder(column: $table.shuffle, builder: (column) => column);

  GeneratedColumn<String> get repeatMode => $composableBuilder(
      column: $table.repeatMode, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<int> get crossfadeSeconds => $composableBuilder(
      column: $table.crossfadeSeconds, builder: (column) => column);

  GeneratedColumn<bool> get eqEnabled =>
      $composableBuilder(column: $table.eqEnabled, builder: (column) => column);

  GeneratedColumn<String> get queueSourceType => $composableBuilder(
      column: $table.queueSourceType, builder: (column) => column);

  GeneratedColumn<int> get queueSourceId => $composableBuilder(
      column: $table.queueSourceId, builder: (column) => column);

  $$EqPresetsTableAnnotationComposer get eqPresetId {
    final $$EqPresetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eqPresetId,
        referencedTable: $db.eqPresets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EqPresetsTableAnnotationComposer(
              $db: $db,
              $table: $db.eqPresets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaybackStatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaybackStatesTable,
    PlaybackState,
    $$PlaybackStatesTableFilterComposer,
    $$PlaybackStatesTableOrderingComposer,
    $$PlaybackStatesTableAnnotationComposer,
    $$PlaybackStatesTableCreateCompanionBuilder,
    $$PlaybackStatesTableUpdateCompanionBuilder,
    (PlaybackState, $$PlaybackStatesTableReferences),
    PlaybackState,
    PrefetchHooks Function({bool eqPresetId})> {
  $$PlaybackStatesTableTableManager(
      _$AppDatabase db, $PlaybackStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<bool> shuffle = const Value.absent(),
            Value<String> repeatMode = const Value.absent(),
            Value<double> volume = const Value.absent(),
            Value<int> crossfadeSeconds = const Value.absent(),
            Value<bool> eqEnabled = const Value.absent(),
            Value<int?> eqPresetId = const Value.absent(),
            Value<String?> queueSourceType = const Value.absent(),
            Value<int?> queueSourceId = const Value.absent(),
          }) =>
              PlaybackStatesCompanion(
            id: id,
            shuffle: shuffle,
            repeatMode: repeatMode,
            volume: volume,
            crossfadeSeconds: crossfadeSeconds,
            eqEnabled: eqEnabled,
            eqPresetId: eqPresetId,
            queueSourceType: queueSourceType,
            queueSourceId: queueSourceId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<bool> shuffle = const Value.absent(),
            Value<String> repeatMode = const Value.absent(),
            Value<double> volume = const Value.absent(),
            Value<int> crossfadeSeconds = const Value.absent(),
            Value<bool> eqEnabled = const Value.absent(),
            Value<int?> eqPresetId = const Value.absent(),
            Value<String?> queueSourceType = const Value.absent(),
            Value<int?> queueSourceId = const Value.absent(),
          }) =>
              PlaybackStatesCompanion.insert(
            id: id,
            shuffle: shuffle,
            repeatMode: repeatMode,
            volume: volume,
            crossfadeSeconds: crossfadeSeconds,
            eqEnabled: eqEnabled,
            eqPresetId: eqPresetId,
            queueSourceType: queueSourceType,
            queueSourceId: queueSourceId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaybackStatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({eqPresetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (eqPresetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.eqPresetId,
                    referencedTable:
                        $$PlaybackStatesTableReferences._eqPresetIdTable(db),
                    referencedColumn:
                        $$PlaybackStatesTableReferences._eqPresetIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlaybackStatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaybackStatesTable,
    PlaybackState,
    $$PlaybackStatesTableFilterComposer,
    $$PlaybackStatesTableOrderingComposer,
    $$PlaybackStatesTableAnnotationComposer,
    $$PlaybackStatesTableCreateCompanionBuilder,
    $$PlaybackStatesTableUpdateCompanionBuilder,
    (PlaybackState, $$PlaybackStatesTableReferences),
    PlaybackState,
    PrefetchHooks Function({bool eqPresetId})>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$RecommendationsTableCreateCompanionBuilder = RecommendationsCompanion
    Function({
  Value<int> id,
  required String category,
  required int songId,
  required double score,
  required DateTime generatedAt,
});
typedef $$RecommendationsTableUpdateCompanionBuilder = RecommendationsCompanion
    Function({
  Value<int> id,
  Value<String> category,
  Value<int> songId,
  Value<double> score,
  Value<DateTime> generatedAt,
});

final class $$RecommendationsTableReferences extends BaseReferences<
    _$AppDatabase, $RecommendationsTable, Recommendation> {
  $$RecommendationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SongsTable _songIdTable(_$AppDatabase db) => db.songs.createAlias(
      $_aliasNameGenerator(db.recommendations.songId, db.songs.id));

  $$SongsTableProcessedTableManager get songId {
    final $_column = $_itemColumn<int>('song_id')!;

    final manager = $$SongsTableTableManager($_db, $_db.songs)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_songIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecommendationsTableFilterComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnFilters(column));

  $$SongsTableFilterComposer get songId {
    final $$SongsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableFilterComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecommendationsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnOrderings(column));

  $$SongsTableOrderingComposer get songId {
    final $$SongsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableOrderingComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecommendationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => column);

  $$SongsTableAnnotationComposer get songId {
    final $$SongsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.songId,
        referencedTable: $db.songs,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SongsTableAnnotationComposer(
              $db: $db,
              $table: $db.songs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecommendationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecommendationsTable,
    Recommendation,
    $$RecommendationsTableFilterComposer,
    $$RecommendationsTableOrderingComposer,
    $$RecommendationsTableAnnotationComposer,
    $$RecommendationsTableCreateCompanionBuilder,
    $$RecommendationsTableUpdateCompanionBuilder,
    (Recommendation, $$RecommendationsTableReferences),
    Recommendation,
    PrefetchHooks Function({bool songId})> {
  $$RecommendationsTableTableManager(
      _$AppDatabase db, $RecommendationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecommendationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecommendationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecommendationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> songId = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
          }) =>
              RecommendationsCompanion(
            id: id,
            category: category,
            songId: songId,
            score: score,
            generatedAt: generatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String category,
            required int songId,
            required double score,
            required DateTime generatedAt,
          }) =>
              RecommendationsCompanion.insert(
            id: id,
            category: category,
            songId: songId,
            score: score,
            generatedAt: generatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecommendationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({songId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (songId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.songId,
                    referencedTable:
                        $$RecommendationsTableReferences._songIdTable(db),
                    referencedColumn:
                        $$RecommendationsTableReferences._songIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecommendationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecommendationsTable,
    Recommendation,
    $$RecommendationsTableFilterComposer,
    $$RecommendationsTableOrderingComposer,
    $$RecommendationsTableAnnotationComposer,
    $$RecommendationsTableCreateCompanionBuilder,
    $$RecommendationsTableUpdateCompanionBuilder,
    (Recommendation, $$RecommendationsTableReferences),
    Recommendation,
    PrefetchHooks Function({bool songId})>;
typedef $$ScanFoldersTableCreateCompanionBuilder = ScanFoldersCompanion
    Function({
  Value<int> id,
  required String path,
  Value<bool> enabled,
  Value<DateTime?> lastScannedAt,
});
typedef $$ScanFoldersTableUpdateCompanionBuilder = ScanFoldersCompanion
    Function({
  Value<int> id,
  Value<String> path,
  Value<bool> enabled,
  Value<DateTime?> lastScannedAt,
});

class $$ScanFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastScannedAt => $composableBuilder(
      column: $table.lastScannedAt, builder: (column) => ColumnFilters(column));
}

class $$ScanFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastScannedAt => $composableBuilder(
      column: $table.lastScannedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ScanFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastScannedAt => $composableBuilder(
      column: $table.lastScannedAt, builder: (column) => column);
}

class $$ScanFoldersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanFoldersTable,
    ScanFolder,
    $$ScanFoldersTableFilterComposer,
    $$ScanFoldersTableOrderingComposer,
    $$ScanFoldersTableAnnotationComposer,
    $$ScanFoldersTableCreateCompanionBuilder,
    $$ScanFoldersTableUpdateCompanionBuilder,
    (ScanFolder, BaseReferences<_$AppDatabase, $ScanFoldersTable, ScanFolder>),
    ScanFolder,
    PrefetchHooks Function()> {
  $$ScanFoldersTableTableManager(_$AppDatabase db, $ScanFoldersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<DateTime?> lastScannedAt = const Value.absent(),
          }) =>
              ScanFoldersCompanion(
            id: id,
            path: path,
            enabled: enabled,
            lastScannedAt: lastScannedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String path,
            Value<bool> enabled = const Value.absent(),
            Value<DateTime?> lastScannedAt = const Value.absent(),
          }) =>
              ScanFoldersCompanion.insert(
            id: id,
            path: path,
            enabled: enabled,
            lastScannedAt: lastScannedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScanFoldersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScanFoldersTable,
    ScanFolder,
    $$ScanFoldersTableFilterComposer,
    $$ScanFoldersTableOrderingComposer,
    $$ScanFoldersTableAnnotationComposer,
    $$ScanFoldersTableCreateCompanionBuilder,
    $$ScanFoldersTableUpdateCompanionBuilder,
    (ScanFolder, BaseReferences<_$AppDatabase, $ScanFoldersTable, ScanFolder>),
    ScanFolder,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SongsTableTableManager get songs =>
      $$SongsTableTableManager(_db, _db.songs);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistSongsTableTableManager get playlistSongs =>
      $$PlaylistSongsTableTableManager(_db, _db.playlistSongs);
  $$PlayHistoryTableTableManager get playHistory =>
      $$PlayHistoryTableTableManager(_db, _db.playHistory);
  $$QueueItemsTableTableManager get queueItems =>
      $$QueueItemsTableTableManager(_db, _db.queueItems);
  $$EqPresetsTableTableManager get eqPresets =>
      $$EqPresetsTableTableManager(_db, _db.eqPresets);
  $$PlaybackStatesTableTableManager get playbackStates =>
      $$PlaybackStatesTableTableManager(_db, _db.playbackStates);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$RecommendationsTableTableManager get recommendations =>
      $$RecommendationsTableTableManager(_db, _db.recommendations);
  $$ScanFoldersTableTableManager get scanFolders =>
      $$ScanFoldersTableTableManager(_db, _db.scanFolders);
}
