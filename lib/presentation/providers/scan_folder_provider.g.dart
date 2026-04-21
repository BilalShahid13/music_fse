// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_folder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All registered scan directories, ordered by path.

@ProviderFor(ScanFoldersNotifier)
final scanFoldersProvider = ScanFoldersNotifierProvider._();

/// All registered scan directories, ordered by path.
final class ScanFoldersNotifierProvider
    extends $AsyncNotifierProvider<ScanFoldersNotifier, List<ScanFolder>> {
  /// All registered scan directories, ordered by path.
  ScanFoldersNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scanFoldersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scanFoldersNotifierHash();

  @$internal
  @override
  ScanFoldersNotifier create() => ScanFoldersNotifier();
}

String _$scanFoldersNotifierHash() =>
    r'58e43bbbd0cc368dbb96f4c20bb7300b17eb1405';

/// All registered scan directories, ordered by path.

abstract class _$ScanFoldersNotifier extends $AsyncNotifier<List<ScanFolder>> {
  FutureOr<List<ScanFolder>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ScanFolder>>, List<ScanFolder>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ScanFolder>>, List<ScanFolder>>,
        AsyncValue<List<ScanFolder>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// True when at least one scan folder is configured.
///
/// Used by the onboarding flow to decide whether to show the folder picker.

@ProviderFor(hasScanFolders)
final hasScanFoldersProvider = HasScanFoldersProvider._();

/// True when at least one scan folder is configured.
///
/// Used by the onboarding flow to decide whether to show the folder picker.

final class HasScanFoldersProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True when at least one scan folder is configured.
  ///
  /// Used by the onboarding flow to decide whether to show the folder picker.
  HasScanFoldersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hasScanFoldersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasScanFoldersHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasScanFolders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasScanFoldersHash() => r'22a8f9e02d78ecdf1fb98549289692ac80e64c22';
