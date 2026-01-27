import 'package:flutter/material.dart';

/// Empty state view shown when no challenges exist
class EmptyStateView extends StatelessWidget {
  /// Callback when add challenge button is pressed
  final VoidCallback onAddChallenge;

  const EmptyStateView({
    super.key,
    required this.onAddChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 80,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Challenges',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start your first 30-day challenge and build a lasting habit!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAddChallenge,
              icon: const Icon(Icons.add),
              label: const Text('Add Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
