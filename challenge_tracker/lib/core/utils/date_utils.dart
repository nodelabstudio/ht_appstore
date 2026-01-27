import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  /// Format UTC timestamp as local date string
  static String formatDate(int utcTimestamp) {
    final utcDateTime = DateTime.fromMillisecondsSinceEpoch(utcTimestamp * 1000, isUtc: true);
    final localDateTime = utcDateTime.toLocal();
    return DateFormat.yMMMd().format(localDateTime);
  }

  /// Format reminder time (minutes since midnight) as HH:MM
  static String formatReminderTime(int minutesSinceMidnight) {
    final hours = minutesSinceMidnight ~/ 60;
    final minutes = minutesSinceMidnight % 60;
    final time = TimeOfDay(hour: hours, minute: minutes);

    // Format as 12-hour with AM/PM
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  /// Convert TimeOfDay to minutes since midnight
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  /// Get current date as UTC timestamp at midnight
  static int getTodayUtcTimestamp() {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    return todayMidnight.toUtc().millisecondsSinceEpoch ~/ 1000;
  }
}
