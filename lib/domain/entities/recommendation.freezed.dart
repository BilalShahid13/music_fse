// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Recommendation {
  int get id;

  /// Logical group name, e.g. 'recently_liked', 'hidden_gems', 'upbeat'.
  String get category;
  int get songId;

  /// Higher is more relevant for this category.
  double get score;
  DateTime get generatedAt;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecommendationCopyWith<Recommendation> get copyWith =>
      _$RecommendationCopyWithImpl<Recommendation>(
          this as Recommendation, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Recommendation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.songId, songId) || other.songId == songId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, category, songId, score, generatedAt);

  @override
  String toString() {
    return 'Recommendation(id: $id, category: $category, songId: $songId, score: $score, generatedAt: $generatedAt)';
  }
}

/// @nodoc
abstract mixin class $RecommendationCopyWith<$Res> {
  factory $RecommendationCopyWith(
          Recommendation value, $Res Function(Recommendation) _then) =
      _$RecommendationCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String category,
      int songId,
      double score,
      DateTime generatedAt});
}

/// @nodoc
class _$RecommendationCopyWithImpl<$Res>
    implements $RecommendationCopyWith<$Res> {
  _$RecommendationCopyWithImpl(this._self, this._then);

  final Recommendation _self;
  final $Res Function(Recommendation) _then;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? songId = null,
    Object? score = null,
    Object? generatedAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      songId: null == songId
          ? _self.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      generatedAt: null == generatedAt
          ? _self.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Recommendation].
extension RecommendationPatterns on Recommendation {
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
    TResult Function(_Recommendation value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Recommendation() when $default != null:
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
    TResult Function(_Recommendation value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Recommendation():
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
    TResult? Function(_Recommendation value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Recommendation() when $default != null:
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
    TResult Function(int id, String category, int songId, double score,
            DateTime generatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Recommendation() when $default != null:
        return $default(_that.id, _that.category, _that.songId, _that.score,
            _that.generatedAt);
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
    TResult Function(int id, String category, int songId, double score,
            DateTime generatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Recommendation():
        return $default(_that.id, _that.category, _that.songId, _that.score,
            _that.generatedAt);
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
    TResult? Function(int id, String category, int songId, double score,
            DateTime generatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Recommendation() when $default != null:
        return $default(_that.id, _that.category, _that.songId, _that.score,
            _that.generatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Recommendation implements Recommendation {
  const _Recommendation(
      {required this.id,
      required this.category,
      required this.songId,
      required this.score,
      required this.generatedAt});

  @override
  final int id;

  /// Logical group name, e.g. 'recently_liked', 'hidden_gems', 'upbeat'.
  @override
  final String category;
  @override
  final int songId;

  /// Higher is more relevant for this category.
  @override
  final double score;
  @override
  final DateTime generatedAt;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecommendationCopyWith<_Recommendation> get copyWith =>
      __$RecommendationCopyWithImpl<_Recommendation>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Recommendation &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.songId, songId) || other.songId == songId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, category, songId, score, generatedAt);

  @override
  String toString() {
    return 'Recommendation(id: $id, category: $category, songId: $songId, score: $score, generatedAt: $generatedAt)';
  }
}

/// @nodoc
abstract mixin class _$RecommendationCopyWith<$Res>
    implements $RecommendationCopyWith<$Res> {
  factory _$RecommendationCopyWith(
          _Recommendation value, $Res Function(_Recommendation) _then) =
      __$RecommendationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String category,
      int songId,
      double score,
      DateTime generatedAt});
}

/// @nodoc
class __$RecommendationCopyWithImpl<$Res>
    implements _$RecommendationCopyWith<$Res> {
  __$RecommendationCopyWithImpl(this._self, this._then);

  final _Recommendation _self;
  final $Res Function(_Recommendation) _then;

  /// Create a copy of Recommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? songId = null,
    Object? score = null,
    Object? generatedAt = null,
  }) {
    return _then(_Recommendation(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      songId: null == songId
          ? _self.songId
          : songId // ignore: cast_nullable_to_non_nullable
              as int,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      generatedAt: null == generatedAt
          ? _self.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
