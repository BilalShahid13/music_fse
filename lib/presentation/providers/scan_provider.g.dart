// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives library scanning and exposes live progress via [ScanState].
///
/// Call [startScan] to initiate a scan. Only one scan may run at a time — a
/// second call while scanning is in progress is a no-op.

@ProviderFor(ScanNotifier)
final scanProvider = ScanNotifierProvider._();

/// Drives library scanning and exposes live progress via [ScanState].
///
/// Call [startScan] to initiate a scan. Only one scan may run at a time — a
/// second call while scanning is in progress is a no-op.
final class ScanNotifierProvider
    extends $NotifierProvider<ScanNotifier, ScanState> {
  /// Drives library scanning and exposes live progress via [ScanState].
  ///
  /// Call [startScan] to initiate a scan. Only one scan may run at a time — a
  /// second call while scanning is in progress is a no-op.
  ScanNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scanProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scanNotifierHash();

  @$internal
  @override
  ScanNotifier create() => ScanNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScanState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScanState>(value),
    );
  }
}

String _$scanNotifierHash() => r'c4d083849bb4de4fc1b0ce689fcf834bb181b528';

/// Drives library scanning and exposes live progress via [ScanState].
///
/// Call [startScan] to initiate a scan. Only one scan may run at a time — a
/// second call while scanning is in progress is a no-op.

abstract class _$ScanNotifier extends $Notifier<ScanState> {
  ScanState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScanState, ScanState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ScanState, ScanState>, ScanState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
