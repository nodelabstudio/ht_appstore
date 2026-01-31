import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz; // Import for tz.TZDateTime
import 'package:challenge_tracker/features/challenges/data/models/challenge.dart';
import 'package:challenge_tracker/features/challenges/presentation/notifiers/challenge_list_notifier.dart';
import 'package:challenge_tracker/features/stats/presentation/screens/stats_screen.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for tests with a direct path, bypassing path_provider
    Hive.init('./test_hive_db');

    // Initialize timezone data
    tz.initializeTimeZones();
    // Set a default timezone for tests, e.g., America/New_York
    tz.setLocalLocation(tz.getLocation('America/New_York'));
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk(); // Clean up Hive data after all tests
  });

  group('StatsScreen', () {
    testWidgets('displays loading indicator when stats are loading', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StatsScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays "No Challenges Yet" when challenge list is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeListProvider.overrideWith(
              () => _MockChallengeListNotifier(AsyncValue.data([])),
            ),
          ],
          child: const MaterialApp(
            home: StatsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle(); // Wait for data to settle

      expect(find.text('Overall Stats'), findsOneWidget);
      expect(find.text('Total Completions'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2)); // Total completions and best streak
    });

    testWidgets('displays correct stats when challenges are present', (tester) async {
      final mockChallenges = [
        Challenge(
          id: '1',
          name: 'Read Book',
          packId: 'pack1',
          startDateUtc: DateTime(2025, 1, 1).millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [
            DateTime(2025, 1, 1).millisecondsSinceEpoch ~/ 1000,
            DateTime(2025, 1, 2).millisecondsSinceEpoch ~/ 1000,
            DateTime(2025, 1, 3).millisecondsSinceEpoch ~/ 1000,
          ],
          reminderTimeMinutes: null,
          isStreakFrozen: false,
        ),
        Challenge(
          id: '2',
          name: 'Workout',
          packId: 'pack2',
          startDateUtc: DateTime(2025, 1, 10).millisecondsSinceEpoch ~/ 1000,
          completionDatesUtc: [
            DateTime(2025, 1, 10).millisecondsSinceEpoch ~/ 1000,
            DateTime(2025, 1, 11).millisecondsSinceEpoch ~/ 1000,
          ],
          reminderTimeMinutes: null,
          isStreakFrozen: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            challengeListProvider.overrideWith(
              () => _MockChallengeListNotifier(AsyncValue.data(mockChallenges)),
            ),
          ],
          child: const MaterialApp(
            home: StatsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle(); // Wait for data to settle

      expect(find.text('Overall Stats'), findsOneWidget);
      expect(find.text('Total Completions'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // 3 + 2 = 5
      expect(find.text('Best Overall Streak'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Best streak is 3 from 'Read Book'
    });
  });
}

// Mock ChallengeListNotifier for testing
class _MockChallengeListNotifier extends ChallengeListNotifier {
  final AsyncValue<List<Challenge>> _initialState;

  _MockChallengeListNotifier(this._initialState);

  @override
  Future<List<Challenge>> build() async {
    return _initialState.value ?? [];
  }
}
