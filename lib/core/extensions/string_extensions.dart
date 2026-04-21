/// String utility extensions.
extension StringCapitalizeExtension on String {
  /// Returns this string with the first character uppercased.
  ///
  /// Returns an empty string unchanged.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns `true` if this string is not null and not empty after trimming.
  bool get hasContent => trim().isNotEmpty;
}

/// Returns a greeting period ('morning' | 'afternoon' | 'evening') based on
/// the provided [hour] (0–23).
///
/// Used by the Home screen to select the correct ARB greeting key:
/// - 05:00–11:59 → `'morning'`
/// - 12:00–17:59 → `'afternoon'`
/// - 18:00–04:59 → `'evening'`
String getTimeGreeting(int hour) {
  if (hour >= 5 && hour < 12) return 'morning';
  if (hour >= 12 && hour < 18) return 'afternoon';
  return 'evening';
}
