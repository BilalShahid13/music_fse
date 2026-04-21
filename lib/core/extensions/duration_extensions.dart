/// Formatting extensions on [Duration] for music player display.
extension DurationFormatExtension on Duration {
  /// Formats as `m:ss` or `h:mm:ss`.
  ///
  /// Examples: `3:07`, `1:02:44`
  String toDisplayString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final mm = minutes.toString().padLeft(hours > 0 ? 2 : 1, '0');
    final ss = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$mm:$ss';
    }
    return '$mm:$ss';
  }

  /// Formats the remaining time relative to [total] as `-m:ss` or `-h:mm:ss`.
  ///
  /// Used in the Now Playing progress bar to show time remaining.
  /// Example: given `this = 1:23` and `total = 3:47` → `"-2:24"`
  String toRemainingString(Duration total) {
    final remaining = total - this;
    if (remaining.isNegative) return '-0:00';
    final formatted = remaining.toDisplayString();
    return '-$formatted';
  }

  /// Formats as `Xh Ym` for playlist or album total durations.
  ///
  /// Examples: `1h 24m`, `47m`
  String toHoursMinutes() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    }
    return '${minutes}m';
  }
}
