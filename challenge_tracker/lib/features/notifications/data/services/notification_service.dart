import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Singleton service for managing local notifications.
///
/// Handles timezone-aware scheduling for daily challenge reminders.
/// Permission is deferred until user consents via pre-permission dialog.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service.
  ///
  /// Detects local timezone and configures the plugin.
  /// Does NOT request permission - call [requestPermission] separately.
  Future<void> init() async {
    if (_isInitialized) return;

    // Detect and set local timezone
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // iOS settings - defer permission request
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// Handle notification tap.
  ///
  /// Payload contains challengeId - navigation handled via deep linking.
  void _onNotificationTap(NotificationResponse response) {
    // Payload contains challengeId
    // Deep linking wired in Plan 02-04
  }

  /// Request notification permission from the user.
  ///
  /// Returns true if permission was granted.
  /// Should be called after showing pre-permission dialog.
  Future<bool> requestPermission() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  /// Schedule a daily reminder for a challenge.
  ///
  /// The notification will repeat daily at the specified time.
  /// Uses timezone-aware scheduling for correct local time.
  Future<void> scheduleDailyReminder({
    required String challengeId,
    required String challengeName,
    required int hourOfDay,
    required int minute,
  }) async {
    final notificationId = _notificationIdFromChallengeId(challengeId);
    final scheduledTime = _nextInstanceOfTime(hourOfDay, minute);

    await _plugin.zonedSchedule(
      id: notificationId,
      title: 'Time for your challenge!',
      body: 'Complete "$challengeName" today',
      scheduledDate: scheduledTime,
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
      payload: challengeId,
    );
  }

  /// Cancel the notification for a specific challenge.
  Future<void> cancelNotification(String challengeId) async {
    await _plugin.cancel(id: _notificationIdFromChallengeId(challengeId));
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Convert challenge ID to notification ID.
  ///
  /// Notification IDs must be 32-bit integers.
  int _notificationIdFromChallengeId(String challengeId) {
    return challengeId.hashCode.abs() % 2147483647;
  }

  /// Get the next occurrence of a specific time.
  ///
  /// If the time has already passed today, returns tomorrow's time.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
