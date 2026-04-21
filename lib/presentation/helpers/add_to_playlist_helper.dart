import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../pages/dialogs/add_to_playlist_dialog.dart';
import '../pages/dialogs/text_input_dialog.dart';
import '../providers/playlist_provider.dart';
import '../providers/toast_provider.dart';
import '../providers/use_case_providers.dart';

/// Shared helper for the "Add to Playlist" context menu action.
///
/// Shows the playlist picker dialog, and if "Create New" is chosen,
/// shows a text input dialog for the playlist name. Adds the song
/// to the chosen/created playlist and shows a toast.
///
/// Used by 9+ context menus across the app (DRY extraction per CLAUDE.md §7.1).
Future<void> handleAddToPlaylist(
  BuildContext context,
  WidgetRef ref,
  int songId,
) async {
  final l10n = AppLocalizations.of(context)!;
  final playlist = await showAddToPlaylistDialog(context);
  if (playlist == null || !context.mounted) return;

  if (playlist.id == kCreateNewPlaylistSentinelId) {
    final name = await showTextInputDialog(
      context,
      title: l10n.ctxNewPlaylist,
      hint: l10n.playlistNameHint,
      confirmLabel: l10n.create,
      cancelLabel: l10n.cancel,
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    final newId = await ref.read(playlistsProvider().notifier).createPlaylist(name.trim());
    if (newId > 0) {
      await ref.read(playlistSongsProvider(newId).notifier).addSong(songId);
      ref.read(toastProvider.notifier).show(l10n.addedToPlaylist(name.trim()));
    }
  } else {
    await ref.read(playlistSongsProvider(playlist.id).notifier).addSong(songId);
    ref.read(toastProvider.notifier).show(l10n.addedToPlaylist(playlist.name));
  }
}

/// Shared helper for bulk "Add to Playlist" actions.
///
/// Reuses the same picker flow as [handleAddToPlaylist], but adds each selected
/// song to the chosen playlist and surfaces a bulk toast.
Future<void> handleAddManyToPlaylist(
  BuildContext context,
  WidgetRef ref,
  List<int> songIds,
) async {
  if (songIds.isEmpty) return;

  final l10n = AppLocalizations.of(context)!;
  final playlist = await showAddToPlaylistDialog(context);
  if (playlist == null || !context.mounted) return;

  var targetPlaylistId = playlist.id;
  var targetPlaylistName = playlist.name;

  if (playlist.id == kCreateNewPlaylistSentinelId) {
    final name = await showTextInputDialog(
      context,
      title: l10n.ctxNewPlaylist,
      hint: l10n.playlistNameHint,
      confirmLabel: l10n.create,
      cancelLabel: l10n.cancel,
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;

    final trimmedName = name.trim();
    final newId = await ref.read(playlistsProvider().notifier).createPlaylist(trimmedName);
    if (newId <= 0) return;

    targetPlaylistId = newId;
    targetPlaylistName = trimmedName;
  }

  final addSongToPlaylist = ref.read(addSongToPlaylistProvider);
  for (final songId in songIds) {
    await addSongToPlaylist.call(targetPlaylistId, songId);
  }

  ref.invalidate(playlistSongsProvider(targetPlaylistId));
  ref.read(toastProvider.notifier).show(
        l10n.addedManyToPlaylist(songIds.length, targetPlaylistName),
      );
}
