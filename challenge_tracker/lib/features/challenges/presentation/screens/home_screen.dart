import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/challenge_list_notifier.dart';
import '../widgets/challenge_grid_item.dart';
import '../widgets/empty_state_view.dart';
import 'challenge_detail_screen.dart';
import 'pack_selection_screen.dart';

/// Main home screen displaying grid of active challenges
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(challengeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('30-Day Challenges'),
        centerTitle: true,
      ),
      body: challengesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(context, ref, error),
        data: (challenges) {
          if (challenges.isEmpty) {
            return EmptyStateView(
              onAddChallenge: () => _navigateToAddChallenge(context),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(challengeListProvider.notifier).refresh();
            },
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0, // Square tiles
              children: challenges.map((challenge) {
                return ChallengeGridItem(
                  challenge: challenge,
                  onTap: () => _navigateToChallengeDetail(context, challenge.id),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: challengesAsync.maybeWhen(
        data: (challenges) => challenges.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => _navigateToAddChallenge(context),
                child: const Icon(Icons.add),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(challengeListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to pack selection screen to add a new challenge
  void _navigateToAddChallenge(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PackSelectionScreen(),
      ),
    );
  }

  /// Navigate to challenge detail screen
  void _navigateToChallengeDetail(BuildContext context, String challengeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(challengeId: challengeId),
      ),
    );
  }
}
