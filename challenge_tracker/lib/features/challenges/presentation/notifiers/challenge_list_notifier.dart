import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/streak_calculator.dart';
import '../../../widgets/data/services/widget_data_service.dart';
import '../../data/models/challenge.dart';
import '../../data/models/challenge_pack.dart';
import '../../data/repositories/challenge_repository.dart';

/// Provider for ChallengeListNotifier (standard Riverpod AsyncNotifier, not code-generated)
final challengeListProvider =
    AsyncNotifierProvider<ChallengeListNotifier, List<Challenge>>(
  ChallengeListNotifier.new,
);

class ChallengeListNotifier extends AsyncNotifier<List<Challenge>> {
  @override
  Future<List<Challenge>> build() async {
    // Initial load from repository
    final repository = ref.read(challengeRepositoryProvider);
    return await repository.getAllChallenges();
  }

  /// Update widget with current challenge data.
  /// Called after completion/undo to keep widget in sync.
  Future<void> _updateWidgetWithChallenge(Challenge challenge) async {
    final pack = ChallengePack.presets.firstWhere(
      (p) => p.id == challenge.packId,
      orElse: () => ChallengePack.presets.first,
    );

    final streakCount = StreakCalculator.calculateStreak(
      challenge.completionDatesUtc,
      challenge.startDateUtc,
    );
    final isCompletedToday = StreakCalculator.isCompletedToday(
      challenge.completionDatesUtc,
    );

    await WidgetDataService().updateWidgetData(
      challengeId: challenge.id,
      challengeName: challenge.name,
      streakCount: streakCount,
      isCompletedToday: isCompletedToday,
      progressPercent: challenge.progress,
      packEmoji: pack.emoji,
    );
  }

  /// Reload challenges from storage
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeRepositoryProvider);
      return await repository.getAllChallenges();
    });
  }

  /// Create new challenge from pack
  Future<void> createChallenge({
    required ChallengePack pack,
    required int startDateUtc,
    int? reminderTimeMinutes,
  }) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeRepositoryProvider);
      await repository.createChallenge(
        pack: pack,
        startDateUtc: startDateUtc,
        reminderTimeMinutes: reminderTimeMinutes,
      );
      return await repository.getAllChallenges();
    });
  }

  /// Mark challenge complete for today
  Future<void> markComplete(String challengeId) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeRepositoryProvider);
      final updatedChallenge = await repository.markComplete(challengeId);

      // Update widget with the completed challenge
      await _updateWidgetWithChallenge(updatedChallenge);

      return await repository.getAllChallenges();
    });
  }

  /// Undo today's completion
  Future<void> undoTodayCompletion(String challengeId) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeRepositoryProvider);
      final updatedChallenge = await repository.undoTodayCompletion(challengeId);

      // Update widget with the reverted challenge (if undo was successful)
      if (updatedChallenge != null) {
        await _updateWidgetWithChallenge(updatedChallenge);
      }

      return await repository.getAllChallenges();
    });
  }

  /// Toggle streak freeze
  Future<void> toggleStreakFreeze(String challengeId) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeRepositoryProvider);
      await repository.toggleStreakFreeze(challengeId);
      return await repository.getAllChallenges();
    });
  }

  /// Delete challenge
  Future<void> deleteChallenge(String challengeId) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeRepositoryProvider);
      await repository.deleteChallenge(challengeId);
      return await repository.getAllChallenges();
    });
  }
}

/// Provider for single challenge by ID (derived from list)
final challengeByIdProvider = Provider.family<Challenge?, String>((ref, id) {
  final challengesAsync = ref.watch(challengeListProvider);
  return challengesAsync.maybeWhen(
    data: (challenges) {
      try {
        return challenges.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});
