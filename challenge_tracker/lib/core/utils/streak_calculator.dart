class StreakCalculator {
  /// Calculate current streak from UTC timestamps
  /// Uses local dates stored as UTC midnight for comparison
  static int calculateStreak(List<int> completionTimestampsUtc, int startDateUtc) {
    if (completionTimestampsUtc.isEmpty) return 0;

    // Convert timestamps to UTC date strings for Set comparison
    final completionDates = completionTimestampsUtc
        .map((ts) {
          final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
          return DateTime.utc(date.year, date.month, date.day);
        })
        .toSet();

    // Get today and yesterday in local time, as UTC dates
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime? streakAnchorDate;
    if (completionDates.contains(today)) {
      streakAnchorDate = today;
    } else if (completionDates.contains(yesterday)) {
      streakAnchorDate = yesterday;
    } else {
      return 0; // No active streak
    }

    // Get challenge start date
    final startDate = DateTime.fromMillisecondsSinceEpoch(startDateUtc * 1000, isUtc: true);
    final challengeStartDate = DateTime.utc(startDate.year, startDate.month, startDate.day);

    int streak = 0;
    var checkDate = streakAnchorDate;

    while (completionDates.contains(checkDate) &&
           !checkDate.isBefore(challengeStartDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Check if challenge completed today
  /// Compares local date against stored UTC dates
  static bool isCompletedToday(List<int> completionTimestampsUtc) {
    if (completionTimestampsUtc.isEmpty) return false;

    // Get today's local date, then compare against stored UTC dates
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);

    return completionTimestampsUtc.any((ts) {
      final completionDate = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
      return completionDate.year == todayUtc.year &&
             completionDate.month == todayUtc.month &&
             completionDate.day == todayUtc.day;
    });
  }

  /// Get today's completion timestamp if exists, null otherwise
  static int? getTodayCompletionTimestamp(List<int> completionTimestampsUtc) {
    if (completionTimestampsUtc.isEmpty) return null;

    // Get today's local date as UTC for comparison
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);

    for (final ts in completionTimestampsUtc) {
      final completionDate = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
      if (completionDate.year == todayUtc.year &&
          completionDate.month == todayUtc.month &&
          completionDate.day == todayUtc.day) {
        return ts;
      }
    }
    return null;
  }

  /// Get today's date as UTC midnight timestamp (seconds)
  /// Stores local date as UTC midnight for consistency with storage format
  static int getTodayUtcTimestamp() {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
  }

  /// Calculate the best (longest) streak from UTC timestamps
  /// Uses local dates stored as UTC midnight for comparison
  static int calculateBestStreak(List<int> completionTimestampsUtc, int startDateUtc) {
    if (completionTimestampsUtc.isEmpty) return 0;

    // Get challenge start date
    final startDateTime = DateTime.fromMillisecondsSinceEpoch(startDateUtc * 1000, isUtc: true);
    final startDate = DateTime.utc(startDateTime.year, startDateTime.month, startDateTime.day);

    // Convert UTC timestamps to UTC dates and sort them
    final completionDates = completionTimestampsUtc
        .map((ts) {
          final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true);
          return DateTime.utc(date.year, date.month, date.day);
        })
        .toSet() // Use set to handle duplicate completions on same day
        .where((date) => !date.isBefore(startDate)) // Ignore completions before the start date
        .toList()
      ..sort((a, b) => a.compareTo(b));

    if (completionDates.isEmpty) {
      return 0;
    }

    int bestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < completionDates.length; i++) {
      final difference = completionDates[i].difference(completionDates[i - 1]);
      if (difference.inDays == 1) {
        currentStreak++;
      } else if (difference.inDays > 1) {
        currentStreak = 1;
      }
      // If difference is 0, it's the same day, so streak doesn't change

      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    }

    return bestStreak;
  }
}
