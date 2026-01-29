import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/streak_calculator.dart';
import '../../challenges/presentation/notifiers/challenge_list_notifier.dart';

class ChallengeStats {
  final int totalCompletions;
  final int bestOverallStreak;

  ChallengeStats({
    required this.totalCompletions,
    required this.bestOverallStreak,
  });
}

final challengeStatsProvider = Provider<AsyncValue<ChallengeStats>>((ref) {
  final challengesAsync = ref.watch(challengeListProvider);

  return challengesAsync.when(
    data: (challenges) {
      if (challenges.isEmpty) {
        return AsyncValue.data(ChallengeStats(
          totalCompletions: 0,
          bestOverallStreak: 0,
        ));
      }

      int totalCompletions = 0;
      int bestOverallStreak = 0;

      for (final challenge in challenges) {
        totalCompletions += challenge.completionDatesUtc.length;

        // Assuming StreakCalculator has a method to calculate the best streak
        final currentChallengeBestStreak = StreakCalculator.calculateBestStreak(
          challenge.completionDatesUtc,
          challenge.startDateUtc,
        );

        if (currentChallengeBestStreak > bestOverallStreak) {
          bestOverallStreak = currentChallengeBestStreak;
        }
      }

      return AsyncValue.data(ChallengeStats(
        totalCompletions: totalCompletions,
        bestOverallStreak: bestOverallStreak,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});
