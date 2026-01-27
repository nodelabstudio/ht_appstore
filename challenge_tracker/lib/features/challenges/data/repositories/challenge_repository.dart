import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/challenge.dart';
import '../models/challenge_pack.dart';
import '../services/hive_service.dart';
import '../../../../core/utils/streak_calculator.dart';

/// Provider for ChallengeRepository (standard Riverpod, not code-generated)
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(hiveService: HiveService());
});

class ChallengeRepository {
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();

  ChallengeRepository({required HiveService hiveService})
      : _hiveService = hiveService;

  /// Get all challenges
  Future<List<Challenge>> getAllChallenges() async {
    return await _hiveService.getAllChallenges();
  }

  /// Get single challenge by ID
  Future<Challenge?> getChallenge(String id) async {
    return await _hiveService.getChallenge(id);
  }

  /// Create new challenge from pack
  Future<Challenge> createChallenge({
    required ChallengePack pack,
    required int startDateUtc,
    int? reminderTimeMinutes,
  }) async {
    final challenge = Challenge(
      id: _uuid.v4(),
      name: pack.name,
      packId: pack.id,
      startDateUtc: startDateUtc,
      completionDatesUtc: [],
      reminderTimeMinutes: reminderTimeMinutes,
      isStreakFrozen: false,
    );

    await _hiveService.saveChallenge(challenge);
    return challenge;
  }

  /// Mark challenge complete for today
  /// Returns updated challenge
  Future<Challenge> markComplete(String challengeId) async {
    final challenge = await _hiveService.getChallenge(challengeId);
    if (challenge == null) {
      throw Exception('Challenge not found: $challengeId');
    }

    // Check if already completed today
    if (StreakCalculator.isCompletedToday(challenge.completionDatesUtc)) {
      return challenge; // Already done, no-op
    }

    // Add today's completion
    final utcTimestamp = StreakCalculator.getCurrentUtcTimestamp();
    final updatedCompletions = [...challenge.completionDatesUtc, utcTimestamp];

    final updatedChallenge = challenge.copyWith(
      completionDatesUtc: updatedCompletions,
      isStreakFrozen: false, // Unfreeze on completion
    );

    await _hiveService.saveChallenge(updatedChallenge);
    return updatedChallenge;
  }

  /// Undo completion for today (same day only)
  /// Returns updated challenge, or null if no completion to undo
  Future<Challenge?> undoTodayCompletion(String challengeId) async {
    final challenge = await _hiveService.getChallenge(challengeId);
    if (challenge == null) {
      throw Exception('Challenge not found: $challengeId');
    }

    // Find today's completion timestamp
    final todayTimestamp = StreakCalculator.getTodayCompletionTimestamp(
      challenge.completionDatesUtc,
    );

    if (todayTimestamp == null) {
      return null; // Nothing to undo
    }

    // Remove today's completion
    final updatedCompletions = challenge.completionDatesUtc
        .where((ts) => ts != todayTimestamp)
        .toList();

    final updatedChallenge = challenge.copyWith(
      completionDatesUtc: updatedCompletions,
    );

    await _hiveService.saveChallenge(updatedChallenge);
    return updatedChallenge;
  }

  /// Toggle streak freeze for today (forgiveness feature)
  Future<Challenge> toggleStreakFreeze(String challengeId) async {
    final challenge = await _hiveService.getChallenge(challengeId);
    if (challenge == null) {
      throw Exception('Challenge not found: $challengeId');
    }

    final updatedChallenge = challenge.copyWith(
      isStreakFrozen: !challenge.isStreakFrozen,
    );

    await _hiveService.saveChallenge(updatedChallenge);
    return updatedChallenge;
  }

  /// Update reminder time for challenge
  Future<Challenge> updateReminderTime(String challengeId, int? reminderTimeMinutes) async {
    final challenge = await _hiveService.getChallenge(challengeId);
    if (challenge == null) {
      throw Exception('Challenge not found: $challengeId');
    }

    final updatedChallenge = challenge.copyWith(
      reminderTimeMinutes: reminderTimeMinutes,
    );

    await _hiveService.saveChallenge(updatedChallenge);
    return updatedChallenge;
  }

  /// Delete challenge
  Future<void> deleteChallenge(String challengeId) async {
    await _hiveService.deleteChallenge(challengeId);
  }
}
