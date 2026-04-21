// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackState {
  /// The song currently loaded in the player. Null when the queue is empty.
  Song? get currentSong;
  bool get isPlaying;
  Duration get position;
  Duration get duration;
  bool get isShuffle;
  RepeatMode get repeatMode;

  /// Master volume 0.0–1.0. Default 0.7 per REQUIREMENTS §7.1.
  double get volume;
  bool get isMuted;

  /// Crossfade duration in seconds (0 = disabled).
  int get crossfadeSeconds;
  bool get isEqEnabled;

  /// What populated the queue (e.g. an album or playlist).
  QueueSourceType? get queueSourceType;

  /// The ID of the source (playlist ID, album name hash, etc.).
  int? get queueSourceId;

  /// The current ordered queue of songs.
  List<Song> get queue;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlaybackStateCopyWith<PlaybackState> get copyWith =>
      _$PlaybackStateCopyWithImpl<PlaybackState>(
          this as PlaybackState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlaybackState &&
            (identical(other.currentSong, currentSong) ||
                other.currentSong == currentSong) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.isShuffle, isShuffle) ||
                other.isShuffle == isShuffle) &&
            (identical(other.repeatMode, repeatMode) ||
                other.repeatMode == repeatMode) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.crossfadeSeconds, crossfadeSeconds) ||
                other.crossfadeSeconds == crossfadeSeconds) &&
            (identical(other.isEqEnabled, isEqEnabled) ||
                other.isEqEnabled == isEqEnabled) &&
            (identical(other.queueSourceType, queueSourceType) ||
                other.queueSourceType == queueSourceType) &&
            (identical(other.queueSourceId, queueSourceId) ||
                other.queueSourceId == queueSourceId) &&
            const DeepCollectionEquality().equals(other.queue, queue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentSong,
      isPlaying,
      position,
      duration,
      isShuffle,
      repeatMode,
      volume,
      isMuted,
      crossfadeSeconds,
      isEqEnabled,
      queueSourceType,
      queueSourceId,
      const DeepCollectionEquality().hash(queue));

  @override
  String toString() {
    return 'PlaybackState(currentSong: $currentSong, isPlaying: $isPlaying, position: $position, duration: $duration, isShuffle: $isShuffle, repeatMode: $repeatMode, volume: $volume, isMuted: $isMuted, crossfadeSeconds: $crossfadeSeconds, isEqEnabled: $isEqEnabled, queueSourceType: $queueSourceType, queueSourceId: $queueSourceId, queue: $queue)';
  }
}

/// @nodoc
abstract mixin class $PlaybackStateCopyWith<$Res> {
  factory $PlaybackStateCopyWith(
          PlaybackState value, $Res Function(PlaybackState) _then) =
      _$PlaybackStateCopyWithImpl;
  @useResult
  $Res call(
      {Song? currentSong,
      bool isPlaying,
      Duration position,
      Duration duration,
      bool isShuffle,
      RepeatMode repeatMode,
      double volume,
      bool isMuted,
      int crossfadeSeconds,
      bool isEqEnabled,
      QueueSourceType? queueSourceType,
      int? queueSourceId,
      List<Song> queue});

  $SongCopyWith<$Res>? get currentSong;
}

/// @nodoc
class _$PlaybackStateCopyWithImpl<$Res>
    implements $PlaybackStateCopyWith<$Res> {
  _$PlaybackStateCopyWithImpl(this._self, this._then);

  final PlaybackState _self;
  final $Res Function(PlaybackState) _then;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentSong = freezed,
    Object? isPlaying = null,
    Object? position = null,
    Object? duration = null,
    Object? isShuffle = null,
    Object? repeatMode = null,
    Object? volume = null,
    Object? isMuted = null,
    Object? crossfadeSeconds = null,
    Object? isEqEnabled = null,
    Object? queueSourceType = freezed,
    Object? queueSourceId = freezed,
    Object? queue = null,
  }) {
    return _then(_self.copyWith(
      currentSong: freezed == currentSong
          ? _self.currentSong
          : currentSong // ignore: cast_nullable_to_non_nullable
              as Song?,
      isPlaying: null == isPlaying
          ? _self.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      isShuffle: null == isShuffle
          ? _self.isShuffle
          : isShuffle // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatMode: null == repeatMode
          ? _self.repeatMode
          : repeatMode // ignore: cast_nullable_to_non_nullable
              as RepeatMode,
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      isMuted: null == isMuted
          ? _self.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      crossfadeSeconds: null == crossfadeSeconds
          ? _self.crossfadeSeconds
          : crossfadeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isEqEnabled: null == isEqEnabled
          ? _self.isEqEnabled
          : isEqEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      queueSourceType: freezed == queueSourceType
          ? _self.queueSourceType
          : queueSourceType // ignore: cast_nullable_to_non_nullable
              as QueueSourceType?,
      queueSourceId: freezed == queueSourceId
          ? _self.queueSourceId
          : queueSourceId // ignore: cast_nullable_to_non_nullable
              as int?,
      queue: null == queue
          ? _self.queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<Song>,
    ));
  }

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SongCopyWith<$Res>? get currentSong {
    if (_self.currentSong == null) {
      return null;
    }

    return $SongCopyWith<$Res>(_self.currentSong!, (value) {
      return _then(_self.copyWith(currentSong: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PlaybackState].
extension PlaybackStatePatterns on PlaybackState {
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
    TResult Function(_PlaybackState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaybackState() when $default != null:
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
    TResult Function(_PlaybackState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaybackState():
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
    TResult? Function(_PlaybackState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaybackState() when $default != null:
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
            Song? currentSong,
            bool isPlaying,
            Duration position,
            Duration duration,
            bool isShuffle,
            RepeatMode repeatMode,
            double volume,
            bool isMuted,
            int crossfadeSeconds,
            bool isEqEnabled,
            QueueSourceType? queueSourceType,
            int? queueSourceId,
            List<Song> queue)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaybackState() when $default != null:
        return $default(
            _that.currentSong,
            _that.isPlaying,
            _that.position,
            _that.duration,
            _that.isShuffle,
            _that.repeatMode,
            _that.volume,
            _that.isMuted,
            _that.crossfadeSeconds,
            _that.isEqEnabled,
            _that.queueSourceType,
            _that.queueSourceId,
            _that.queue);
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
            Song? currentSong,
            bool isPlaying,
            Duration position,
            Duration duration,
            bool isShuffle,
            RepeatMode repeatMode,
            double volume,
            bool isMuted,
            int crossfadeSeconds,
            bool isEqEnabled,
            QueueSourceType? queueSourceType,
            int? queueSourceId,
            List<Song> queue)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaybackState():
        return $default(
            _that.currentSong,
            _that.isPlaying,
            _that.position,
            _that.duration,
            _that.isShuffle,
            _that.repeatMode,
            _that.volume,
            _that.isMuted,
            _that.crossfadeSeconds,
            _that.isEqEnabled,
            _that.queueSourceType,
            _that.queueSourceId,
            _that.queue);
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
            Song? currentSong,
            bool isPlaying,
            Duration position,
            Duration duration,
            bool isShuffle,
            RepeatMode repeatMode,
            double volume,
            bool isMuted,
            int crossfadeSeconds,
            bool isEqEnabled,
            QueueSourceType? queueSourceType,
            int? queueSourceId,
            List<Song> queue)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaybackState() when $default != null:
        return $default(
            _that.currentSong,
            _that.isPlaying,
            _that.position,
            _that.duration,
            _that.isShuffle,
            _that.repeatMode,
            _that.volume,
            _that.isMuted,
            _that.crossfadeSeconds,
            _that.isEqEnabled,
            _that.queueSourceType,
            _that.queueSourceId,
            _that.queue);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PlaybackState implements PlaybackState {
  const _PlaybackState(
      {this.currentSong,
      this.isPlaying = false,
      this.position = Duration.zero,
      this.duration = Duration.zero,
      this.isShuffle = false,
      this.repeatMode = RepeatMode.off,
      this.volume = 0.7,
      this.isMuted = false,
      this.crossfadeSeconds = 0,
      this.isEqEnabled = false,
      this.queueSourceType,
      this.queueSourceId,
      final List<Song> queue = const []})
      : _queue = queue;

  /// The song currently loaded in the player. Null when the queue is empty.
  @override
  final Song? currentSong;
  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey()
  final Duration position;
  @override
  @JsonKey()
  final Duration duration;
  @override
  @JsonKey()
  final bool isShuffle;
  @override
  @JsonKey()
  final RepeatMode repeatMode;

  /// Master volume 0.0–1.0. Default 0.7 per REQUIREMENTS §7.1.
  @override
  @JsonKey()
  final double volume;
  @override
  @JsonKey()
  final bool isMuted;

  /// Crossfade duration in seconds (0 = disabled).
  @override
  @JsonKey()
  final int crossfadeSeconds;
  @override
  @JsonKey()
  final bool isEqEnabled;

  /// What populated the queue (e.g. an album or playlist).
  @override
  final QueueSourceType? queueSourceType;

  /// The ID of the source (playlist ID, album name hash, etc.).
  @override
  final int? queueSourceId;

  /// The current ordered queue of songs.
  final List<Song> _queue;

  /// The current ordered queue of songs.
  @override
  @JsonKey()
  List<Song> get queue {
    if (_queue is EqualUnmodifiableListView) return _queue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_queue);
  }

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlaybackStateCopyWith<_PlaybackState> get copyWith =>
      __$PlaybackStateCopyWithImpl<_PlaybackState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlaybackState &&
            (identical(other.currentSong, currentSong) ||
                other.currentSong == currentSong) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.isShuffle, isShuffle) ||
                other.isShuffle == isShuffle) &&
            (identical(other.repeatMode, repeatMode) ||
                other.repeatMode == repeatMode) &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.crossfadeSeconds, crossfadeSeconds) ||
                other.crossfadeSeconds == crossfadeSeconds) &&
            (identical(other.isEqEnabled, isEqEnabled) ||
                other.isEqEnabled == isEqEnabled) &&
            (identical(other.queueSourceType, queueSourceType) ||
                other.queueSourceType == queueSourceType) &&
            (identical(other.queueSourceId, queueSourceId) ||
                other.queueSourceId == queueSourceId) &&
            const DeepCollectionEquality().equals(other._queue, _queue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentSong,
      isPlaying,
      position,
      duration,
      isShuffle,
      repeatMode,
      volume,
      isMuted,
      crossfadeSeconds,
      isEqEnabled,
      queueSourceType,
      queueSourceId,
      const DeepCollectionEquality().hash(_queue));

  @override
  String toString() {
    return 'PlaybackState(currentSong: $currentSong, isPlaying: $isPlaying, position: $position, duration: $duration, isShuffle: $isShuffle, repeatMode: $repeatMode, volume: $volume, isMuted: $isMuted, crossfadeSeconds: $crossfadeSeconds, isEqEnabled: $isEqEnabled, queueSourceType: $queueSourceType, queueSourceId: $queueSourceId, queue: $queue)';
  }
}

/// @nodoc
abstract mixin class _$PlaybackStateCopyWith<$Res>
    implements $PlaybackStateCopyWith<$Res> {
  factory _$PlaybackStateCopyWith(
          _PlaybackState value, $Res Function(_PlaybackState) _then) =
      __$PlaybackStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Song? currentSong,
      bool isPlaying,
      Duration position,
      Duration duration,
      bool isShuffle,
      RepeatMode repeatMode,
      double volume,
      bool isMuted,
      int crossfadeSeconds,
      bool isEqEnabled,
      QueueSourceType? queueSourceType,
      int? queueSourceId,
      List<Song> queue});

  @override
  $SongCopyWith<$Res>? get currentSong;
}

/// @nodoc
class __$PlaybackStateCopyWithImpl<$Res>
    implements _$PlaybackStateCopyWith<$Res> {
  __$PlaybackStateCopyWithImpl(this._self, this._then);

  final _PlaybackState _self;
  final $Res Function(_PlaybackState) _then;

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentSong = freezed,
    Object? isPlaying = null,
    Object? position = null,
    Object? duration = null,
    Object? isShuffle = null,
    Object? repeatMode = null,
    Object? volume = null,
    Object? isMuted = null,
    Object? crossfadeSeconds = null,
    Object? isEqEnabled = null,
    Object? queueSourceType = freezed,
    Object? queueSourceId = freezed,
    Object? queue = null,
  }) {
    return _then(_PlaybackState(
      currentSong: freezed == currentSong
          ? _self.currentSong
          : currentSong // ignore: cast_nullable_to_non_nullable
              as Song?,
      isPlaying: null == isPlaying
          ? _self.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      isShuffle: null == isShuffle
          ? _self.isShuffle
          : isShuffle // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatMode: null == repeatMode
          ? _self.repeatMode
          : repeatMode // ignore: cast_nullable_to_non_nullable
              as RepeatMode,
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as double,
      isMuted: null == isMuted
          ? _self.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      crossfadeSeconds: null == crossfadeSeconds
          ? _self.crossfadeSeconds
          : crossfadeSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isEqEnabled: null == isEqEnabled
          ? _self.isEqEnabled
          : isEqEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      queueSourceType: freezed == queueSourceType
          ? _self.queueSourceType
          : queueSourceType // ignore: cast_nullable_to_non_nullable
              as QueueSourceType?,
      queueSourceId: freezed == queueSourceId
          ? _self.queueSourceId
          : queueSourceId // ignore: cast_nullable_to_non_nullable
              as int?,
      queue: null == queue
          ? _self._queue
          : queue // ignore: cast_nullable_to_non_nullable
              as List<Song>,
    ));
  }

  /// Create a copy of PlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SongCopyWith<$Res>? get currentSong {
    if (_self.currentSong == null) {
      return null;
    }

    return $SongCopyWith<$Res>(_self.currentSong!, (value) {
      return _then(_self.copyWith(currentSong: value));
    });
  }
}

// dart format on
