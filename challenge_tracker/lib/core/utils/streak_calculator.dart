import 'package:timezone/timezone.dart' as tz;

class StreakCalculator {
  /// Calculate current streak from UTC timestamps
  /// Handles timezone changes and DST transitions
  static int calculateStreak(List<int> completionTimestampsUtc, int startDateUtc) {
    if (completionTimestampsUtc.isEmpty) return 0;

    final location = tz.local;
    final completionDates = completionTimestampsUtc
        .map((utc) => _utcTimestampToLocalDate(utc, location))
        .toSet();

    final now = tz.TZDateTime.now(location);
    final today = _stripTime(now);
    final yesterday = today.subtract(const Duration(days: 1));

    tz.TZDateTime? streakAnchorDate;
    if (completionDates.contains(today)) {
      streakAnchorDate = today;
    } else if (completionDates.contains(yesterday)) {
      streakAnchorDate = yesterday;
    } else {
      return 0; // No active streak
    }

    int streak = 0;
    var checkDate = streakAnchorDate;
    final challengeStartDate = _utcTimestampToLocalDate(startDateUtc, location);

    while (completionDates.contains(checkDate) &&
           !checkDate.isBefore(challengeStartDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Check if challenge completed today in user's timezone
  static bool isCompletedToday(List<int> completionTimestampsUtc) {
    if (completionTimestampsUtc.isEmpty) return false;

    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    final todayDate = _stripTime(now);

    return completionTimestampsUtc.any((utc) {
      final completionDate = _utcTimestampToLocalDate(utc, location);
      return completionDate == todayDate;
    });
  }

  /// Get today's completion timestamp if exists, null otherwise
  static int? getTodayCompletionTimestamp(List<int> completionTimestampsUtc) {
    if (completionTimestampsUtc.isEmpty) return null;

    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    final todayDate = _stripTime(now);

    for (final utc in completionTimestampsUtc) {
      final completionDate = _utcTimestampToLocalDate(utc, location);
      if (completionDate == todayDate) {
        return utc;
      }
    }
    return null;
  }

  /// Store current completion as UTC timestamp (seconds)
  static int getCurrentUtcTimestamp() {
    return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  /// Calculate the best (longest) streak from UTC timestamps
  /// Handles timezone changes and DST transitions
  static int calculateBestStreak(List<int> completionTimestampsUtc, int startDateUtc) {
    if (completionTimestampsUtc.isEmpty) return 0;

    final location = tz.local;
    final startDate = _utcTimestampToLocalDate(startDateUtc, location);

    // Convert UTC timestamps to local dates and sort them
    final completionDates = completionTimestampsUtc
        .map((utc) => _utcTimestampToLocalDate(utc, location))
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


  /// Convert UTC timestamp to local date (stripped of time)
  static tz.TZDateTime _utcTimestampToLocalDate(int utcTimestamp, tz.Location location) {
    final utcDateTime = DateTime.fromMillisecondsSinceEpoch(utcTimestamp * 1000, isUtc: true);
    final localDateTime = tz.TZDateTime.from(utcDateTime, location);
    return _stripTime(localDateTime);
  }

  /// Strip time component, return date-only
  static tz.TZDateTime _stripTime(tz.TZDateTime dateTime) {
    return tz.TZDateTime(
      dateTime.location,
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
  }
}
