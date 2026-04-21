import 'dart:async';

import 'package:flutter/foundation.dart';

/// Delays execution of [action] until [delay] has elapsed without a new call.
///
/// Typically used to throttle search-as-you-type so a query is only sent after
/// the user stops typing.
///
/// Always call [dispose] when the owning widget is disposed.
///
/// ```dart
/// final _debouncer = Debouncer(delay: const Duration(milliseconds: 300));
///
/// void _onSearchChanged(String query) {
///   _debouncer(() => ref.read(searchProvider.notifier).search(query));
/// }
///
/// @override
/// void dispose() {
///   _debouncer.dispose();
///   super.dispose();
/// }
/// ```
final class Debouncer {
  Debouncer({required this.delay});

  final Duration delay;

  Timer? _timer;

  /// Schedule [action] to run after [delay]. Cancels any pending invocation.
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending invocation and release the timer resource.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels any pending invocation without releasing the debouncer.
  /// The debouncer remains usable after calling this method.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
