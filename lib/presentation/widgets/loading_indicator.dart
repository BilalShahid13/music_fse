import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Simple centered loading spinner.
///
/// Used while async data (library scan results, playlist contents, etc.) is
/// still loading. Renders a [CircularProgressIndicator] in the accent color
/// with an optional descriptive [message] below.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});

  /// Optional text shown below the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accent),
            strokeWidth: 2.5,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: tt.bodyMedium?.copyWith(color: ext.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
