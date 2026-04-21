import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DropOverlay extends StatelessWidget {
  const DropOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final tt = Theme.of(context).textTheme;

    return Positioned.fill(
      child: Container(
        color: accent.withAlpha(30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.folderInput, size: 64, color: accent),
              const SizedBox(height: 16),
              Text(
                'Drop files here to add to library',
                style: tt.headlineSmall?.copyWith(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
