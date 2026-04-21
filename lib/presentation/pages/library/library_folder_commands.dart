import 'package:flutter/foundation.dart';

/// True when Folders tab can navigate one level up (inside a subfolder).
final ValueNotifier<bool> libraryFoldersCanGoUp = ValueNotifier<bool>(false);

/// Increment to request one-level up navigation in Folders tab.
final ValueNotifier<int> libraryFoldersGoUpRequest = ValueNotifier<int>(0);

void requestLibraryFoldersGoUp() {
  libraryFoldersGoUpRequest.value = libraryFoldersGoUpRequest.value + 1;
}
