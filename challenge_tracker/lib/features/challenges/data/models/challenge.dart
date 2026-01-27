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

  // Immutable copy helper
  Challenge copyWith({
    String? id,
    String? name,
    String? packId,
    int? startDateUtc,
    List<int>? completionDatesUtc,
    int? reminderTimeMinutes,
    bool? isStreakFrozen,
  }) {
    return Challenge(
      id: id ?? this.id,
      name: name ?? this.name,
      packId: packId ?? this.packId,
      startDateUtc: startDateUtc ?? this.startDateUtc,
      completionDatesUtc: completionDatesUtc ?? List.from(this.completionDatesUtc),
      reminderTimeMinutes: reminderTimeMinutes ?? this.reminderTimeMinutes,
      isStreakFrozen: isStreakFrozen ?? this.isStreakFrozen,
    );
  }

  // Computed: number of completions
  int get completedDays => completionDatesUtc.length;

  // Computed: progress as fraction (0.0 to 1.0)
  double get progress => completedDays / 30.0;

  // Computed: day number (1-30)
  int get currentDay => completedDays + 1;
}
