import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation.freezed.dart';

/// A single recommendation entry linking a song to a named category.
///
/// The recommendation engine groups songs by category (e.g., 'by_mood',
/// 'recently_liked', 'hidden_gems'). The [score] drives ordering within a
/// category. [generatedAt] lets the provider decide when to refresh.
@freezed
abstract class Recommendation with _$Recommendation {
  const factory Recommendation({
    required int id,

    /// Logical group name, e.g. 'recently_liked', 'hidden_gems', 'upbeat'.
    required String category,
    required int songId,

    /// Higher is more relevant for this category.
    required double score,
    required DateTime generatedAt,
  }) = _Recommendation;
}
