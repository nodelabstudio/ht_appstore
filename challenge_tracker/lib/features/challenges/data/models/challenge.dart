import 'package:hive/hive.dart';

part 'challenge.g.dart';

@HiveType(typeId: 0)
class Challenge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String packId;

  @HiveField(3)
  final int startDateUtc; // Unix timestamp in seconds

  @HiveField(4)
  final List<int> completionDatesUtc; // List of UTC timestamps (Hive doesn't support Set)

  @HiveField(5)
  final int? reminderTimeMinutes; // Minutes since midnight (null = no reminder)

  @HiveField(6)
  final bool isStreakFrozen; // Forgiveness feature - freeze streak for today

  Challenge({
    required this.id,
    required this.name,
    required this.packId,
    required this.startDateUtc,
    List<int>? completionDatesUtc,
    this.reminderTimeMinutes,
    this.isStreakFrozen = false,
  }) : completionDatesUtc = completionDatesUtc ?? [];

  // Sentinel value to distinguish "not provided" from "set to null"
  static const _unset = -1;

  // Immutable copy helper
  Challenge copyWith({
    String? id,
    String? name,
    String? packId,
    int? startDateUtc,
    List<int>? completionDatesUtc,
    int? reminderTimeMinutes = _unset,
    bool? isStreakFrozen,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      packId: packId ?? this.packId,
      startDateUtc: startDateUtc ?? this.startDateUtc,
      completionDatesUtc: completionDatesUtc ?? List.from(this.completionDatesUtc),
      reminderTimeMinutes: reminderTimeMinutes == _unset
          ? this.reminderTimeMinutes
          : reminderTimeMinutes,
      isStreakFrozen: isStreakFrozen ?? this.isStreakFrozen,
    );
  }

  /// Computed: number of unique completed days (not total entries)
  /// Uses UTC dates for consistency with storage format.
  /// Deduplicates via Set conversion to handle any legacy duplicate entries.
  int get completedDays {
    final uniqueDays = completionDatesUtc
        .map((ts) {
          final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
          return DateTime.utc(date.year, date.month, date.day);
        })
        .toSet();
    return uniqueDays.length;
  }

  /// Computed: progress as fraction (0.0 to 1.0)
  /// Based on unique completed days, not raw completion count.
  double get progress => completedDays / 30.0;

  /// Computed: current day number in the challenge (1-30)
  /// Based on days elapsed since start date (inclusive).
  /// Start date = Day 1, next day = Day 2, etc.
  /// Uses local date normalized to UTC for consistent comparison.
  int get currentDay {
    // Denormalize stored start date
    final start = DateTime.fromMillisecondsSinceEpoch(startDateUtc * 1000, isUtc: true);
    final startDate = DateTime.utc(start.year, start.month, start.day);

    // Normalize today to UTC
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    // Calculate inclusive day count (+1 makes start date = Day 1)
    final daysSinceStart = today.difference(startDate).inDays + 1;
    return daysSinceStart.clamp(1, 30);
  }
}
