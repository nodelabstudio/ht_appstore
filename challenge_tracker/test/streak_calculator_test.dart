import 'package:flutter_test/flutter_test.dart';
import 'package:challenge_tracker/core/utils/streak_calculator.dart';

void main() {
  group('StreakCalculator', () {
    group('calculateStreak', () {
      test('returns 0 for empty completion list', () {
        final startDate = DateTime.utc(2026, 1, 20).millisecondsSinceEpoch ~/ 1000;
        expect(StreakCalculator.calculateStreak([], startDate), equals(0));
      });

      test('returns 1 for single completion on current day', () {
        // Use actual current date for this test
        final now = DateTime.now();
        final todayUtc = DateTime.utc(now.year, now.month, now.day);
        final startDate = todayUtc.subtract(const Duration(days: 5)).millisecondsSinceEpoch ~/ 1000;
        final todayTs = todayUtc.millisecondsSinceEpoch ~/ 1000;

        expect(
          StreakCalculator.calculateStreak([todayTs], startDate),
          equals(1),
        );
      });

      test('returns 3 for three consecutive days ending today', () {
        final now = DateTime.now();
        final todayUtc = DateTime.utc(now.year, now.month, now.day);
        final startDate = todayUtc.subtract(const Duration(days: 10)).millisecondsSinceEpoch ~/ 1000;

        final completions = [
          todayUtc.subtract(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000,
          todayUtc.subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
          todayUtc.millisecondsSinceEpoch ~/ 1000,
        ];

        expect(
          StreakCalculator.calculateStreak(completions, startDate),
          equals(3),
        );
      });

      test('returns streak when yesterday completed but not today (grace period)', () {
        final now = DateTime.now();
        final todayUtc = DateTime.utc(now.year, now.month, now.day);
        final startDate = todayUtc.subtract(const Duration(days: 10)).millisecondsSinceEpoch ~/ 1000;

        final completions = [
          todayUtc.subtract(const Duration(days: 3)).millisecondsSinceEpoch ~/ 1000,
          todayUtc.subtract(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000,
          todayUtc.subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000,
          // No completion for today
        ];

        expect(
          StreakCalculator.calculateStreak(completions, startDate),
          equals(3),
        );
      });

      test('returns 0 when last completion was 2+ days ago', () {
        final now = DateTime.now();
        final todayUtc = DateTime.utc(now.year, now.month, now.day);
        final startDate = todayUtc.subtract(const Duration(days: 10)).millisecondsSinceEpoch ~/ 1000;

        final completions = [
          todayUtc.subtract(const Duration(days: 4)).millisecondsSinceEpoch ~/ 1000,
          todayUtc.subtract(const Duration(days: 3)).millisecondsSinceEpoch ~/ 1000,
          todayUtc.subtract(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000,
          // Gap: yesterday and today missing
        ];

        expect(
          StreakCalculator.calculateStreak(completions, startDate),
          equals(0),
        );
      });

      test('ignores completions before start date', () {
        final now = DateTime.now();
        final todayUtc = DateTime.utc(now.year, now.month, now.day);
        // Start date is yesterday
        final startDate = todayUtc.subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;

        final completions = [
          todayUtc.subtract(const Duration(days: 2)).millisecondsSinceEpoch ~/ 1000, // Before start - should be ignored
          todayUtc.subtract(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000, // Start date
          todayUtc.millisecondsSinceEpoch ~/ 1000, // Today
        ];

        // Only yesterday and today should count (2 days)
        expect(
          StreakCalculator.calculateStreak(completions, startDate),
          equals(2),
        );
      });
    });

    group('isCompletedToday', () {
      test('returns false for empty list', () {
        expect(StreakCalculator.isCompletedToday([]), isFalse);
      });

      test('returns true when today is in list', () {
        final now = DateTime.now();
        final todayUtc = DateTime.utc(now.year, now.month, now.day);
        final todayTs = todayUtc.millisecondsSinceEpoch ~/ 1000;

        expect(StreakCalculator.isCompletedToday([todayTs]), isTrue);
      });

      test('returns false when only yesterday is in list', () {
        final now = DateTime.now();
        final yesterdayUtc = DateTime.utc(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));
        final yesterdayTs = yesterdayUtc.millisecondsSinceEpoch ~/ 1000;

        expect(StreakCalculator.isCompletedToday([yesterdayTs]), isFalse);
      });
    });

    group('getTodayUtcTimestamp', () {
      test('returns UTC midnight timestamp for local date', () {
        final timestamp = StreakCalculator.getTodayUtcTimestamp();

        // Convert back and verify it's midnight UTC
        final resultDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
        expect(resultDate.hour, equals(0));
        expect(resultDate.minute, equals(0));
        expect(resultDate.second, equals(0));

        // Verify it matches today's local date
        final now = DateTime.now();
        expect(resultDate.year, equals(now.year));
        expect(resultDate.month, equals(now.month));
        expect(resultDate.day, equals(now.day));
      });
    });

    group('calculateBestStreak', () {
      test('returns longest consecutive run', () {
        final startDate = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000;
        final completions = [
          // First run: 3 days
          DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000,
          DateTime.utc(2026, 1, 2).millisecondsSinceEpoch ~/ 1000,
          DateTime.utc(2026, 1, 3).millisecondsSinceEpoch ~/ 1000,
          // Gap
          // Second run: 5 days
          DateTime.utc(2026, 1, 10).millisecondsSinceEpoch ~/ 1000,
          DateTime.utc(2026, 1, 11).millisecondsSinceEpoch ~/ 1000,
          DateTime.utc(2026, 1, 12).millisecondsSinceEpoch ~/ 1000,
          DateTime.utc(2026, 1, 13).millisecondsSinceEpoch ~/ 1000,
          DateTime.utc(2026, 1, 14).millisecondsSinceEpoch ~/ 1000,
        ];

        expect(
          StreakCalculator.calculateBestStreak(completions, startDate),
          equals(5),
        );
      });

      test('handles duplicate timestamps for same day', () {
        final startDate = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000;
        final completions = [
          DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000,
          DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000, // Duplicate
          DateTime.utc(2026, 1, 2).millisecondsSinceEpoch ~/ 1000,
        ];

        expect(
          StreakCalculator.calculateBestStreak(completions, startDate),
          equals(2), // Not 3
        );
      });

      test('returns 0 for empty list', () {
        final startDate = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch ~/ 1000;
        expect(StreakCalculator.calculateBestStreak([], startDate), equals(0));
      });

      test('ignores completions before start date', () {
        final startDate = DateTime.utc(2026, 1, 5).millisecondsSinceEpoch ~/ 1000;
        final completions = [
          DateTime.utc(2026, 1, 3).millisecondsSinceEpoch ~/ 1000, // Before start
          DateTime.utc(2026, 1, 4).millisecondsSinceEpoch ~/ 1000, // Before start
          DateTime.utc(2026, 1, 5).millisecondsSinceEpoch ~/ 1000, // Start date
          DateTime.utc(2026, 1, 6).millisecondsSinceEpoch ~/ 1000,
        ];

        // Only Jan 5 and 6 count
        expect(
          StreakCalculator.calculateBestStreak(completions, startDate),
          equals(2),
        );
      });
    });
  });
}
