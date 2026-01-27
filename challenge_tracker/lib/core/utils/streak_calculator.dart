import 'package:timezone/timezone.dart' as tz;

class StreakCalculator {
  /// Calculate current streak from UTC timestamps
  /// Handles timezone changes and DST transitions
  static int calculateStreak(List<int> completionTimestampsUtc, int startDateUtc) {
    if (completionTimestampsUtc.isEmpty) return 0;

    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    final todayDate = _stripTime(now);

    // Convert UTC timestamps to local dates (as unique set)
    final completionDates = completionTimestampsUtc
        .map((utc) => _utcTimestampToLocalDate(utc, location))
        .toSet();

    // Grace period: check completion today or yesterday
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    // If not completed today AND not completed yesterday, streak is broken
    if (!completionDates.contains(todayDate) &&
        !completionDates.contains(yesterdayDate)) {
      return 0;
    }

    // Count consecutive days backwards from most recent completion
    int streak = 0;
    var checkDate = completionDates.contains(todayDate) ? todayDate : yesterdayDate;

    final startDate = _utcTimestampToLocalDate(startDateUtc, location);

    while (completionDates.contains(checkDate) && !checkDate.isBefore(startDate)) {
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
