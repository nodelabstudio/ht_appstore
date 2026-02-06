import 'package:flutter_test/flutter_test.dart';
import 'package:challenge_tracker/features/challenges/data/models/challenge.dart';

void main() {
  group('Challenge model', () {
    group('completedDays', () {
      test('returns 0 for empty completion list', () {
        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [],
        );

        expect(challenge.completedDays, equals(0));
      });

      test('returns count of unique days', () {
        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [
            DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000,
            DateTime.utc(2026, 1, 21).millisecondsSinceEpoch ~/ 1000,
            DateTime.utc(2026, 1, 22).millisecondsSinceEpoch ~/ 1000,
          ],
        );

        expect(challenge.completedDays, equals(3));
      });

      test('deduplicates entries for same day', () {
        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [
            DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000,
            DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000, // Duplicate
            DateTime.utc(2026, 1, 21).millisecondsSinceEpoch ~/ 1000,
          ],
        );

        // Should be 2, not 3 (deduplication)
        expect(challenge.completedDays, equals(2));
      });
    });

    group('progress', () {
      test('returns 0.0 for no completions', () {
        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [],
        );

        expect(challenge.progress, equals(0.0));
      });

      test('returns 0.5 for 15 completions', () {
        final completions = List.generate(15, (i) {
          return DateTime.utc(2026, 1, 20 + i).millisecondsSinceEpoch ~/ 1000;
        });

        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: completions,
        );

        expect(challenge.progress, equals(0.5));
      });

      test('returns 1.0 for 30 completions', () {
        final completions = List.generate(30, (i) {
          return DateTime.utc(2026, 1, 1 + i).millisecondsSinceEpoch ~/ 1000;
        });

        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: completions,
        );

        expect(challenge.progress, equals(1.0));
      });
    });

    group('currentDay', () {
      test('returns 1 for challenge starting today', () {
        final now = DateTime.now();
        final todayUtc = DateTime.utc(now.year, now.month, now.day);

        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: todayUtc.millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [],
        );

        expect(challenge.currentDay, equals(1));
      });

      test('returns 6 for challenge started 5 days ago', () {
        final now = DateTime.now();
        final fiveDaysAgo = DateTime.utc(now.year, now.month, now.day)
            .subtract(const Duration(days: 5));

        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: fiveDaysAgo.millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [],
        );

        // 5 days ago + today = 6 days inclusive
        expect(challenge.currentDay, equals(6));
      });

      test('clamps to 30 for old challenges', () {
        final now = DateTime.now();
        final longAgo = DateTime.utc(now.year, now.month, now.day)
            .subtract(const Duration(days: 100));

        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: longAgo.millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [],
        );

        expect(challenge.currentDay, equals(30)); // Clamped to 30
      });

      test('clamps to 1 minimum', () {
        // Edge case: start date in the future (shouldn't happen but test the clamp)
        final now = DateTime.now();
        final tomorrow = DateTime.utc(now.year, now.month, now.day)
            .add(const Duration(days: 1));

        final challenge = Challenge(
          id: 'test-1',
          name: 'Test Challenge',
          packId: 'pack-1',
          startDateUtc: tomorrow.millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [],
        );

        expect(challenge.currentDay, equals(1)); // Clamped to 1
      });
    });

    group('copyWith', () {
      test('preserves all fields when called with no arguments', () {
        final original = Challenge(
          id: 'test-1',
          name: 'Original',
          packId: 'pack-1',
          startDateUtc: 1000000,
          completionDatesUtc: [1, 2, 3],
          reminderTimeMinutes: 540,
          isStreakFrozen: true,
        );

        final copy = original.copyWith();

        expect(copy.id, equals(original.id));
        expect(copy.name, equals(original.name));
        expect(copy.packId, equals(original.packId));
        expect(copy.startDateUtc, equals(original.startDateUtc));
        expect(copy.completionDatesUtc, equals(original.completionDatesUtc));
        expect(copy.reminderTimeMinutes, equals(original.reminderTimeMinutes));
        expect(copy.isStreakFrozen, equals(original.isStreakFrozen));
      });

      test('updates specified fields', () {
        final original = Challenge(
          id: 'test-1',
          name: 'Original',
          packId: 'pack-1',
          startDateUtc: 1000000,
          completionDatesUtc: [1, 2, 3],
          reminderTimeMinutes: 540,
          isStreakFrozen: false,
        );

        final updated = original.copyWith(
          completionDatesUtc: [1, 2, 3, 4],
          isStreakFrozen: true,
        );

        expect(updated.id, equals(original.id)); // Unchanged
        expect(updated.completionDatesUtc, equals([1, 2, 3, 4])); // Updated
        expect(updated.isStreakFrozen, isTrue); // Updated
      });
    });
  });
}
