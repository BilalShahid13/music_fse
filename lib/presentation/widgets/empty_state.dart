import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Reusable empty-state placeholder for any screen or list that has no content.
///
/// Spec (REQUIREMENTS §6.13 / §6.3a):
/// - Centered column layout
/// - Icon: 48×48, [textTertiary] color
/// - Title: 18sp [textSecondary]
/// - Subtitle: 14sp [textTertiary] (optional)
/// - Action button: accent-colored outlined/filled button (optional)
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// Lucide icon to display.
  final IconData icon;

  /// Primary message (18sp).
  final String title;

  /// Secondary descriptive message (14sp, optional).
  final String? subtitle;

  /// Label for the CTA button. Only rendered when [onAction] is also provided.
  final String? actionLabel;

  /// Callback for the CTA button.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final tt = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: ext.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: tt.titleMedium?.copyWith(color: ext.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: tt.bodyMedium?.copyWith(color: ext.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(backgroundColor: accent),
                child: Text(
                  actionLabel!,
                  style: tt.labelLarge?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
