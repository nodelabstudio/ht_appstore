import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      await repository.markComplete(challengeId);
      return await repository.getAllChallenges();
    });
  }

  /// Undo today's completion
  Future<void> undoTodayCompletion(String challengeId) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeRepositoryProvider);
      await repository.undoTodayCompletion(challengeId);
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
