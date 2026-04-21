// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The central audio-engine state machine.
///
/// Architecture decisions:
/// - Dual [AudioPlayer] (A / B) supports crossfade without interrupting
///   the outgoing track.
/// - The internal [_queue] is a plain [List<Song>] mirrored from the
///   [PlaybackState] value object for performance. The value object is the
///   source of truth consumers observe; the list is the engine's working set.
/// - Queue persistence is debounced 2 s to avoid hammering the DB on rapid
///   track changes (e.g. skip-hold).
/// - Play-count accounting runs in-notifier so no separate isolate is needed.

@ProviderFor(PlaybackNotifier)
final playbackProvider = PlaybackNotifierProvider._();

/// The central audio-engine state machine.
///
/// Architecture decisions:
/// - Dual [AudioPlayer] (A / B) supports crossfade without interrupting
///   the outgoing track.
/// - The internal [_queue] is a plain [List<Song>] mirrored from the
///   [PlaybackState] value object for performance. The value object is the
///   source of truth consumers observe; the list is the engine's working set.
/// - Queue persistence is debounced 2 s to avoid hammering the DB on rapid
///   track changes (e.g. skip-hold).
/// - Play-count accounting runs in-notifier so no separate isolate is needed.
final class PlaybackNotifierProvider
    extends $NotifierProvider<PlaybackNotifier, PlaybackState> {
  /// The central audio-engine state machine.
  ///
  /// Architecture decisions:
  /// - Dual [AudioPlayer] (A / B) supports crossfade without interrupting
  ///   the outgoing track.
  /// - The internal [_queue] is a plain [List<Song>] mirrored from the
  ///   [PlaybackState] value object for performance. The value object is the
  ///   source of truth consumers observe; the list is the engine's working set.
  /// - Queue persistence is debounced 2 s to avoid hammering the DB on rapid
  ///   track changes (e.g. skip-hold).
  /// - Play-count accounting runs in-notifier so no separate isolate is needed.
  PlaybackNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'playbackProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playbackNotifierHash();

  @$internal
  @override
  PlaybackNotifier create() => PlaybackNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackState>(value),
    );
  }
}

String _$playbackNotifierHash() => r'5313976872f8d9cd40549301de0498b1c360cd57';

/// The central audio-engine state machine.
///
/// Architecture decisions:
/// - Dual [AudioPlayer] (A / B) supports crossfade without interrupting
///   the outgoing track.
/// - The internal [_queue] is a plain [List<Song>] mirrored from the
///   [PlaybackState] value object for performance. The value object is the
///   source of truth consumers observe; the list is the engine's working set.
/// - Queue persistence is debounced 2 s to avoid hammering the DB on rapid
///   track changes (e.g. skip-hold).
/// - Play-count accounting runs in-notifier so no separate isolate is needed.

abstract class _$PlaybackNotifier extends $Notifier<PlaybackState> {
  PlaybackState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PlaybackState, PlaybackState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PlaybackState, PlaybackState>,
        PlaybackState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// The song currently loaded in the player.

@ProviderFor(currentSong)
final currentSongProvider = CurrentSongProvider._();

/// The song currently loaded in the player.

final class CurrentSongProvider extends $FunctionalProvider<Song?, Song?, Song?>
    with $Provider<Song?> {
  /// The song currently loaded in the player.
  CurrentSongProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentSongProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentSongHash();

  @$internal
  @override
  $ProviderElement<Song?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Song? create(Ref ref) {
    return currentSong(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Song? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Song?>(value),
    );
  }
}

String _$currentSongHash() => r'58204af29339bc0ca6bc9e1cda3d00aba5aa95d3';

/// Whether the player is currently playing.

@ProviderFor(isPlaying)
final isPlayingProvider = IsPlayingProvider._();

/// Whether the player is currently playing.

final class IsPlayingProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the player is currently playing.
  IsPlayingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isPlayingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isPlayingHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isPlaying(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isPlayingHash() => r'1340513b4182f99c86255df0046d13cbc8f44b38';

/// Current playback position.

@ProviderFor(playbackPosition)
final playbackPositionProvider = PlaybackPositionProvider._();

/// Current playback position.

final class PlaybackPositionProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Current playback position.
  PlaybackPositionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'playbackPositionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playbackPositionHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return playbackPosition(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$playbackPositionHash() => r'd4f73da2ba9e1f7863927b78bae092f5ea367630';

/// Duration of the current track.

@ProviderFor(trackDuration)
final trackDurationProvider = TrackDurationProvider._();

/// Duration of the current track.

final class TrackDurationProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Duration of the current track.
  TrackDurationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'trackDurationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$trackDurationHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return trackDuration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$trackDurationHash() => r'0cce6d59ff33fe73220d968e878d1a7ce6af8f89';

/// Current master volume (0.0–1.0).

@ProviderFor(playbackVolume)
final playbackVolumeProvider = PlaybackVolumeProvider._();

/// Current master volume (0.0–1.0).

final class PlaybackVolumeProvider
    extends $FunctionalProvider<double, double, double> with $Provider<double> {
  /// Current master volume (0.0–1.0).
  PlaybackVolumeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'playbackVolumeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$playbackVolumeHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return playbackVolume(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$playbackVolumeHash() => r'b5e58332563370ab6012611cb3a1b802290d6126';

/// Whether shuffle is active.

@ProviderFor(isShuffle)
final isShuffleProvider = IsShuffleProvider._();

/// Whether shuffle is active.

final class IsShuffleProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether shuffle is active.
  IsShuffleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isShuffleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isShuffleHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isShuffle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isShuffleHash() => r'560919c71e315f33b28e21f00f773128d8aba6ec';

/// Current repeat mode.

@ProviderFor(repeatMode)
final repeatModeProvider = RepeatModeProvider._();

/// Current repeat mode.

final class RepeatModeProvider
    extends $FunctionalProvider<RepeatMode, RepeatMode, RepeatMode>
    with $Provider<RepeatMode> {
  /// Current repeat mode.
  RepeatModeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'repeatModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$repeatModeHash();

  @$internal
  @override
  $ProviderElement<RepeatMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RepeatMode create(Ref ref) {
    return repeatMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RepeatMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RepeatMode>(value),
    );
  }
}

String _$repeatModeHash() => r'fa571308c39eaa7b09fcbd3be55b2369448dffbe';

/// A snapshot of the current queue.

@ProviderFor(currentQueue)
final currentQueueProvider = CurrentQueueProvider._();

/// A snapshot of the current queue.

final class CurrentQueueProvider
    extends $FunctionalProvider<List<Song>, List<Song>, List<Song>>
    with $Provider<List<Song>> {
  /// A snapshot of the current queue.
  CurrentQueueProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentQueueProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentQueueHash();

  @$internal
  @override
  $ProviderElement<List<Song>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Song> create(Ref ref) {
    return currentQueue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Song> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Song>>(value),
    );
  }
}

String _$currentQueueHash() => r'9e6bd0f3df41ec604580c73c5e58e0880d92bfe1';

/// Whether the player is muted.

@ProviderFor(isMuted)
final isMutedProvider = IsMutedProvider._();

/// Whether the player is muted.

final class IsMutedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the player is muted.
  IsMutedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isMutedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isMutedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isMuted(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isMutedHash() => r'b63da985941b1845966377a16572f02ef2885b9d';
