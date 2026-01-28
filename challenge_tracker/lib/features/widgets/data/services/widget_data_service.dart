import 'package:home_widget/home_widget.dart';

/// Service to bridge Flutter challenge data to iOS home screen widget.
/// Uses home_widget package to share data via App Groups UserDefaults.
class WidgetDataService {
  static final WidgetDataService _instance = WidgetDataService._internal();
  factory WidgetDataService() => _instance;
  WidgetDataService._internal();

  // Must match App Group ID in ChallengeWidget.swift
  static const String _appGroupId = 'group.com.challengetracker.shared';
  static const String _iOSWidgetName = 'ChallengeWidget';

  // UserDefaults keys - must match Swift code exactly
  static const String _keyChallengeName = 'challenge_name';
  static const String _keyStreakCount = 'streak_count';
  static const String _keyIsCompletedToday = 'is_completed_today';
  static const String _keyProgressPercent = 'progress_percent';
  static const String _keyChallengeId = 'challenge_id';
  static const String _keyPackEmoji = 'pack_emoji';

  bool _isInitialized = false;

  /// Initialize the widget data service with App Group ID.
  /// Must be called before using updateWidgetData or clearWidgetData.
  Future<void> init() async {
    if (_isInitialized) return;
    await HomeWidget.setAppGroupId(_appGroupId);
    _isInitialized = true;
  }

  /// Update widget with current challenge data.
  /// Call after challenge completion, undo, or when selected challenge changes.
  ///
  /// Parameters:
  /// - [challengeId]: Unique identifier for deep linking
  /// - [challengeName]: Display name of the challenge
  /// - [streakCount]: Current streak count
  /// - [isCompletedToday]: Whether today's task is complete
  /// - [progressPercent]: Progress as 0.0-1.0 (e.g., 10/30 = 0.33)
  /// - [packEmoji]: Emoji representing the challenge pack
  Future<void> updateWidgetData({
    required String challengeId,
    required String challengeName,
    required int streakCount,
    required bool isCompletedToday,
    required double progressPercent,
    required String packEmoji,
  }) async {
    await HomeWidget.saveWidgetData<String>(_keyChallengeId, challengeId);
    await HomeWidget.saveWidgetData<String>(_keyChallengeName, challengeName);
    await HomeWidget.saveWidgetData<int>(_keyStreakCount, streakCount);
    await HomeWidget.saveWidgetData<bool>(_keyIsCompletedToday, isCompletedToday);
    await HomeWidget.saveWidgetData<double>(_keyProgressPercent, progressPercent);
    await HomeWidget.saveWidgetData<String>(_keyPackEmoji, packEmoji);

    // Trigger widget refresh
    await HomeWidget.updateWidget(iOSName: _iOSWidgetName);
  }

  /// Clear widget data (e.g., when challenge is deleted or user signs out).
  Future<void> clearWidgetData() async {
    await HomeWidget.saveWidgetData<String?>(_keyChallengeId, null);
    await HomeWidget.saveWidgetData<String?>(_keyChallengeName, null);
    await HomeWidget.saveWidgetData<int?>(_keyStreakCount, null);
    await HomeWidget.saveWidgetData<bool?>(_keyIsCompletedToday, null);
    await HomeWidget.saveWidgetData<double?>(_keyProgressPercent, null);
    await HomeWidget.saveWidgetData<String?>(_keyPackEmoji, null);

    await HomeWidget.updateWidget(iOSName: _iOSWidgetName);
  }
}
