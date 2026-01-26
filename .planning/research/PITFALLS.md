# Domain Pitfalls: Flutter Habit Tracker (iOS)

**Domain:** Habit/Streak Tracker Mobile App
**Stack:** Flutter + Riverpod + Hive + RevenueCat + WidgetKit
**Platform:** iOS only
**Timeline:** 14-day ship target
**Researched:** 2026-01-26

---

## Critical Pitfalls

Mistakes that cause rewrites, App Store rejection, or major production issues.

### Pitfall 1: Timezone-Naive Streak Logic

**What goes wrong:** Streak counters break when users travel across timezones, change device timezone settings, or during DST transitions. Users lose streaks on 23-hour or 25-hour days. Submissions at 12:30 AM may be logged as previous day, breaking multi-month streaks.

**Why it happens:** Developers store timestamps in local time instead of UTC, or perform date calculations using calendar arithmetic without accounting for DST. Race conditions near midnight create double-counting or missed days.

**Consequences:**
- Loss of user trust when hard-earned streaks vanish
- Negative App Store reviews citing "broken streak tracking"
- Support burden from angry users who traveled or hit DST edge cases
- Potential data inconsistency requiring migration

**Prevention:**
1. **Always store timestamps in UTC** (Unix time) in Hive database
2. **Always calculate in user's current timezone** for display and streak logic
3. **Define clear midnight boundary rules** with grace periods (e.g., actions within 2 hours after midnight count for previous day)
4. **Test DST transitions explicitly** - verify 23-hour and 25-hour days don't break streaks
5. **Test timezone changes** - users crossing UTC+8 to UTC-5 should maintain streaks
6. **Use proven date libraries** for timezone-aware calculations (avoid manual calendar math)

**Detection:**
- User reports: "I did my habit but lost my streak"
- Support tickets after DST changes (March/November)
- Analytics showing streak drops at midnight boundaries
- Users in different timezones report inconsistent behavior

**Phase Mapping:** Phase 1 (Core Data Model) must nail timezone handling - fixing this later requires data migration.

**Sources:**
- [How to Build a Streaks Feature - Trophy](https://trophy.so/blog/how-to-build-a-streaks-feature)
- [Implementing a Daily Streak System: A Practical Guide](https://tigerabrodi.blog/implementing-a-daily-streak-system-a-practical-guide)
- [Beware the Edge (cases) of Time!](https://codeofmatt.com/beware-the-edge-cases-of-time/)
- [LeetCode Streak Bug Report (12:30 AM issue)](https://github.com/LeetCode-Feedback/LeetCode-Feedback/issues/28204)

---

### Pitfall 2: WidgetKit Data Sharing Misconfiguration

**What goes wrong:** iOS home screen widget shows stale data, doesn't update when app completes a habit, or crashes with "file not found" errors. Widget displays placeholder content instead of actual streak data.

**Why it happens:**
- App Groups not configured for both Runner and Widget Extension targets
- Mismatched minimum iOS deployment versions between targets
- Build phases in wrong order (Embed Foundation Extensions must be above Run Script)
- Attempting to share data via regular file paths instead of App Group container

**Consequences:**
- Widget shows yesterday's data indefinitely
- Users mark habits as complete in app, widget still shows "incomplete"
- App Store rejection for non-functional widget
- Complete rewrite of data sharing layer if discovered late

**Prevention:**
1. **Configure App Groups for BOTH targets** in Xcode > Signing & Capabilities
   - Runner target: Add App Group capability
   - Widget Extension target: Add same App Group capability
   - Use identical group identifier (e.g., `group.com.yourapp.habittracker`)

2. **Match iOS deployment targets exactly**
   - Runner > General > Minimum Deployments = iOS 14.0
   - WidgetExtension > General > Minimum Deployments = iOS 14.0

3. **Reorder Build Phases** (critical!)
   - Open Runner target > Build Phases
   - Drag "Embed Foundation Extensions" ABOVE "Run Script"

4. **Use App Group paths for all shared data**
   ```dart
   // Via shared_preference_app_group plugin
   SharedPreferencesAppGroup.setString('group.com.yourapp', 'lastHabit', '2026-01-26');

   // Via path_provider for Hive
   final appGroupDir = await getApplicationDocumentsDirectory(); // Wrong!
   final appGroupDir = await getLibraryDirectory(); // Still wrong!
   // Use App Group container path from path_provider_ios
   ```

5. **Call WidgetKit reload after data changes**
   ```dart
   // After updating habit status
   WidgetKit.reloadAllTimelines();
   ```

6. **Test on physical device in Release mode** - Debug mode widgets may crash from memory constraints

**Detection:**
- Widget shows "No Data" or placeholder content
- Xcode build warnings about deployment target mismatches
- Widget doesn't update after app actions
- Build fails with "Extension not embedded" errors

**Phase Mapping:** Phase 2 (iOS Widget Integration) - set up correctly from the start; refactoring widget architecture later is extremely painful.

**Sources:**
- [Adding iOS app extensions - Flutter Docs](https://docs.flutter.dev/platform-integration/ios/app-extensions)
- [Flutter WidgetKit GitHub](https://github.com/fasky-software/flutter_widgetkit)
- [Sharing UserDefaults with widgets - Apple Developer Forums](https://developer.apple.com/forums/thread/651799)

---

### Pitfall 3: RevenueCat Configuration Errors

**What goes wrong:** "None of the products registered in the RevenueCat dashboard could be fetched from App Store Connect" (Error 23). Users see blank paywall or "Make sure you configure Purchases before trying to get the default instance" crash.

**Why it happens:**
- Product IDs in RevenueCat dashboard don't exactly match App Store Connect identifiers
- RevenueCat SDK not initialized before accessing customer info
- Testing in web/debug mode instead of TestFlight (RevenueCat can't fetch sandbox products in Flutter web)
- App Store Connect agreements not signed or subscriptions not approved yet
- Missing "Restore Purchases" button violates App Store guidelines

**Consequences:**
- App Store rejection for non-functional in-app purchases
- Loss of revenue when paywall fails silently
- User frustration with blank screens or crashes
- Emergency hotfix required post-launch
- 14-day timeline blown if discovered late

**Prevention:**
1. **Initialize RevenueCat early in main()**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();

     await Purchases.configure(
       PurchasesConfiguration("appl_YOUR_KEY_HERE")
         ..appUserID = null  // Anonymous IDs for MVP
         ..observerMode = false
     );

     runApp(MyApp());
   }
   ```

2. **Match Product IDs exactly** across 3 places:
   - App Store Connect subscription ID: `habit_tracker_monthly`
   - RevenueCat Dashboard product ID: `habit_tracker_monthly`
   - Flutter code reference: `habit_tracker_monthly`
   - Even one character difference = Configuration Error 23

3. **Test on TestFlight, not local builds**
   - Create TestFlight internal build for testing subscriptions
   - Add sandbox test accounts in App Store Connect
   - RevenueCat cannot fetch products in web/simulator for production mode

4. **Include required paywall elements** (App Store compliance):
   - Clear price and billing period display
   - "Restore Purchases" button
   - Link to subscription management page
   - Privacy policy and terms links

5. **Check error handling** for graceful degradation:
   ```dart
   try {
     final offerings = await Purchases.getOfferings();
     if (offerings.current == null) {
       // Show "offline mode" or "subscriptions unavailable"
     }
   } on PlatformException catch (e) {
     if (e.code == '23') {
       // Log Configuration Error to monitoring service
     }
   }
   ```

6. **Verify App Store Connect setup**
   - Paid Applications Agreement signed
   - Bank/tax info complete
   - Subscription in "Ready to Submit" status
   - At least one subscription price set

**Detection:**
- PlatformException with code "23" (CONFIGURATION_ERROR)
- "getCustomerInfo" throws MissingPluginException
- Offerings return null or empty
- TestFlight users see blank paywall screen
- App Store reviewer reports "subscriptions don't work"

**Phase Mapping:** Phase 4 (Monetization Setup) - allocate 2-3 days for RevenueCat integration testing, not "quick afternoon task."

**Sources:**
- [Troubleshooting RevenueCat SDKs - Official Docs](https://www.revenuecat.com/docs/test-and-launch/debugging/troubleshooting-the-sdks)
- [RevenueCat Flutter Issues - Community Forum](https://community.revenuecat.com/general-questions-7/working-setup-now-broken-revenuecat-flutter-288)
- [Flutter iOS Configuration Error - RevenueCat Community](https://community.revenuecat.com/sdks-51/flutter-ios-configuration-error-fetching-offerings-5965)

---

### Pitfall 4: App Store Review Rejection Traps

**What goes wrong:** App rejected for crashes, placeholder content, privacy violations, or subscription compliance issues. Rejection adds 2-7 days to timeline (resubmission + re-review).

**Why it happens:**
- Testing only in simulator, not real devices
- Leaving "Lorem Ipsum" or "Coming Soon" content
- Requesting notification permissions on app launch (instead of in context)
- Missing "Restore Purchases" button or subscription terms
- Privacy policy link returns 404
- App crashes when reviewer taps specific feature

**Consequences:**
- 14-day timeline becomes 21+ days
- Emergency bug fixes under pressure
- Potential second rejection if fixes incomplete
- Competitor launches first while you're stuck in review
- Team morale hit from avoidable rejection

**Prevention:**

**1. Test on Real Physical Device (Not Simulator)**
- Run full QA pass on actual iPhone before submission
- Apple specifically looks for crashes that only happen on device
- Test all user flows reviewer will try

**2. Complete Content Audit**
- Search codebase for "Lorem", "TODO", "Coming Soon", "Test"
- Every button must work (no "Feature Coming Soon" screens)
- All links in Settings/About must be live URLs
- Privacy Policy must be published and accessible

**3. Delayed Permission Requests (Critical)**
```dart
// WRONG - Triggers rejection
void main() {
  requestNotificationPermission(); // Asked on launch
  runApp(MyApp());
}

// RIGHT - Contextual request
void showNotificationSetup() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Enable Reminders?'),
      content: Text('Get daily reminders to maintain your streak'),
      actions: [
        // User understands WHY before permission prompt
        TextButton(
          onPressed: () => requestNotificationPermission(),
          child: Text('Enable'),
        ),
      ],
    ),
  );
}
```

**4. Subscription Compliance Checklist**
- [ ] Price clearly displayed on paywall
- [ ] Billing period clearly stated ("$4.99/month")
- [ ] "Restore Purchases" button present and functional
- [ ] Link to Apple subscription management page
- [ ] Auto-renewal terms disclosed
- [ ] Privacy policy link (live, not 404)
- [ ] Terms of service link (live, not 404)

**5. Privacy Policy Must Specify**
- What data is collected (email if login exists, usage analytics)
- Why data is collected
- Third-party services used (RevenueCat, analytics)
- How users can delete data
- Contact information

**6. Pre-Submission Device Test Protocol**
- Install production build on iPhone via TestFlight
- Complete full onboarding flow
- Create habit → mark complete → verify widget updates
- Attempt subscription purchase (sandbox mode)
- Tap "Restore Purchases" button
- Enable/disable notifications in Settings
- Force close app → reopen → verify data persistence
- Check all links in Settings screen

**7. Known 2026 Rejections to Avoid**
- Web view wrappers (Apple hates apps that are just web views)
- Metadata inconsistencies (price in description doesn't match in-app price)
- Crashes on iOS 18+ devices
- Apps not built with iOS 26 SDK (required as of April 2026)

**Detection:**
- App Store review notes: "App crashes when..."
- Rejection reason: "Guideline 2.1 - Performance - App Completeness"
- Rejection reason: "Guideline 5.1.1 - Data Collection and Storage"
- Rejection reason: "Guideline 3.1.2 - Business - Payments - Subscriptions"

**Phase Mapping:** Phase 5 (Pre-Launch Polish) - allocate 2 full days for device testing and compliance audit, NOT "quick check before submission."

**Sources:**
- [iOS App Store Review Guidelines 2026: Best Practices](https://crustlab.com/blog/ios-app-store-review-guidelines/)
- [Top 10 iOS App Rejection Reasons in 2026](https://betadrop.app/blog/ios-app-rejection-reasons-2026)
- [Getting Through iOS App Review - RevenueCat](https://www.revenuecat.com/blog/engineering/getting-through-app-review/)
- [App Store Review Guidelines - Apple (2026)](https://adapty.io/blog/how-to-pass-app-store-review/)

---

### Pitfall 5: Hive Database Corruption on Unclean Shutdown

**What goes wrong:** Users report "all my habits disappeared" after app crash or force quit. Hive database resets on simulator restart. Data corruption after concurrent writes from widget and app.

**Why it happens:**
- Hive is not thread-safe; concurrent access from app + widget extension causes race conditions
- Boxes not properly closed before app termination
- No transaction support; partial writes during crashes leave database inconsistent
- Relying on Hive to auto-save when it requires explicit commit

**Consequences:**
- User data loss = angry reviews + uninstalls
- Debugging "sometimes works, sometimes doesn't" issues
- Need emergency migration to more reliable database (Isar, SQLite)
- Loss of user trust in data persistence

**Prevention:**

**1. Implement Single-Writer Pattern**
```dart
// Use a lock/mutex for all Hive writes
final _hiveLock = Lock();

Future<void> saveHabit(Habit habit) async {
  await _hiveLock.synchronized(() async {
    final box = await Hive.openBox<Habit>('habits');
    await box.put(habit.id, habit);
    await box.close(); // Explicit close ensures flush to disk
  });
}
```

**2. Close Boxes After Every Operation**
```dart
// WRONG - Keeps box open indefinitely
final habitsBox = await Hive.openBox('habits');
habitsBox.put('key', value); // May not flush to disk

// RIGHT - Explicit close
final habitsBox = await Hive.openBox('habits');
await habitsBox.put('key', value);
await habitsBox.close(); // Forces write to disk
```

**3. Widget Extension Access Pattern**
```dart
// In widget extension, use read-only access
final box = await Hive.openBox('habits', readOnly: true);
final habits = box.values.toList();
await box.close();
// Never write from widget extension
```

**4. Implement Auto-Backup**
```dart
// Daily backup to prevent total data loss
Future<void> backupDatabase() async {
  final appDir = await getApplicationDocumentsDirectory();
  final hivePath = '${appDir.path}/habits.hive';
  final backupPath = '${appDir.path}/habits_backup_${DateTime.now().millisecondsSinceEpoch}.hive';

  await File(hivePath).copy(backupPath);

  // Keep only last 3 backups
  // Delete older backups
}
```

**5. Consider Migration to Isar Early**
- Hive's creator built Isar to fix these issues
- Isar has better thread-safety and crash recovery
- If timeline allows, start with Isar instead of Hive
- For 14-day timeline: stick with Hive but use locks aggressively

**6. Test Unclean Shutdowns**
- Force quit app during habit save operation
- Reopen → verify data intact
- Kill app process via Xcode during write
- Simulate widget writing while app writing

**Detection:**
- User reports: "My habits disappeared"
- Hive throws `HiveError: Box is already closed`
- Empty database after app restart
- Inconsistent data (habit shows as complete and incomplete simultaneously)
- Android Simulator DB resets on every restart (known issue)

**Phase Mapping:** Phase 1 (Core Data Model) - implement lock pattern from day 1; refactoring async code for locks later is painful.

**Confidence:** MEDIUM - Based on GitHub issues and community reports, not verified in large-scale production. Hive maintainer acknowledged issues when creating Isar.

**Sources:**
- [10 Flutter Hive Best Practices - CLIMB](https://climbtheladder.com/10-flutter-hive-best-practices/)
- [Hive Database Resets on Flutter Android Simulator - GitHub Issue](https://github.com/isar/hive/issues/620)
- [Migration from Hive to Isar - Medium Article](https://saropa-contacts.medium.com/the-long-road-a-flutter-database-migration-from-hive-to-isar-reflections-from-the-saropa-122b8e9b289c)
- [Hive Data Disappearing on Restart - GitHub Issue](https://github.com/isar/hive/issues/836)

---

## Moderate Pitfalls

Mistakes that cause delays or technical debt but are recoverable.

### Pitfall 6: WidgetKit Refresh Expectations Mismatch

**What goes wrong:** Developers expect widgets to update instantly when app data changes. Users expect real-time updates. Reality: widgets update on system-defined schedule with 40-70 refreshes per day budget.

**Why it happens:** Misunderstanding WidgetKit's deliberate limitations. System controls when widgets refresh to preserve battery life. Calling `reloadAllTimelines()` requests update but doesn't guarantee immediate refresh.

**Prevention:**
1. **Set correct expectations in UI/UX**
   - Don't promise "instant widget updates"
   - Show last update timestamp in widget
   - Document that widget "updates throughout the day"

2. **Optimize Timeline Generation**
   ```dart
   // Provide future timeline entries, not single entry
   TimelineProvider.getTimeline() {
     final entries = [
       TimelineEntry(date: now, habitData: current),
       TimelineEntry(date: now + 15.minutes, habitData: current),
       TimelineEntry(date: now + 30.minutes, habitData: current),
       TimelineEntry(date: now + 1.hour, habitData: current),
     ];
     return Timeline(
       entries: entries,
       policy: TimelineReloadPolicy.after(now + 2.hours),
     );
   }
   ```

3. **Call Reload Strategically**
   ```dart
   // After significant state changes
   void markHabitComplete(Habit habit) async {
     await saveHabit(habit);
     WidgetKit.reloadAllTimelines(); // Request update
     // But don't promise user it's instant!
   }
   ```

4. **Test Update Delays**
   - Mark habit complete in app
   - Return to home screen
   - Note actual delay until widget shows update (5 seconds to 5 minutes)
   - Document observed behavior for user expectations

**Detection:**
- User feedback: "Widget doesn't update fast enough"
- Support tickets about "broken widgets" that are actually just slow
- Widget shows stale data for 5-10 minutes after app changes

**Phase Mapping:** Phase 2 (Widget Integration) - document expected behavior upfront to avoid UX redesign later.

**Sources:**
- [Keeping an iOS Widget Up To Date in Flutter - Medium](https://medium.com/@aymen_farrah/keeping-an-ios-widget-up-to-date-in-flutter-bcc01f6d114f)
- [WidgetKit Timeline Reload Issues - GitHub Feedback](https://github.com/feedback-assistant/reports/issues/359)

---

### Pitfall 7: Notification Permission Rejection on First Launch

**What goes wrong:** Users decline notification permission because prompt appears before they understand app's value. Can't re-request permission; user must enable manually in Settings.

**Why it happens:** Requesting permission immediately on first launch without context. User doesn't know why app needs notifications yet.

**Prevention:**
1. **Pre-permission Education Screen**
   ```dart
   // Show custom dialog BEFORE system permission
   void showNotificationEducation() async {
     final result = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Never Miss a Habit'),
         content: Text('Daily reminders help you maintain your streak. '
                      'We'll notify you once per day at your chosen time.'),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context, false),
             child: Text('Not Now'),
           ),
           TextButton(
             onPressed: () => Navigator.pop(context, true),
             child: Text('Enable Reminders'),
           ),
         ],
       ),
     );

     if (result == true) {
       // Now request system permission
       await requestNotificationPermission();
     }
   }
   ```

2. **Delay Permission Request**
   - Don't ask on first app open
   - Ask after user creates first habit
   - Context: "Get reminded to complete [Habit Name] daily"

3. **Check Permission Status First**
   ```dart
   final status = await Permission.notification.status;
   if (status.isDenied) {
     // Show custom dialog
   } else if (status.isPermanentlyDenied) {
     // Show "Open Settings" button
   }
   ```

4. **Graceful Degradation**
   - App must work perfectly without notification permission
   - Don't show error messages repeatedly
   - Offer alternative: "Check app daily instead"

**Detection:**
- Low notification opt-in rates (<20%)
- Users decline permission immediately
- Support tickets: "How do I enable notifications I declined?"

**Phase Mapping:** Phase 3 (Notifications) - implement pre-permission education screen from start; poor opt-in rates are permanent.

**Sources:**
- [Flutter Notification Permissions - FlutterFire Docs](https://firebase.flutter.dev/docs/messaging/permissions/)
- [How to Handle Permissions in Flutter - freeCodeCamp](https://www.freecodecamp.org/news/how-to-handle-permissions-in-flutter-for-beginners/)

---

### Pitfall 8: Riverpod Provider Misuse Causing Unnecessary Rebuilds

**What goes wrong:** UI rebuilds constantly, draining battery and causing laggy performance. Using `ref.read` where `ref.watch` needed (or vice versa) causes bugs.

**Why it happens:**
- Using `ref.watch` in event handlers (rebuilds on every state change during the event)
- Watching entire state objects when only one field needed
- Not using `.select()` for granular subscriptions

**Prevention:**

**1. ref.watch vs ref.read**
```dart
// WRONG - ref.read in build method misses updates
@override
Widget build(BuildContext context, WidgetRef ref) {
  final habits = ref.read(habitsProvider); // Won't rebuild on changes!
  return ListView.builder(...);
}

// RIGHT - ref.watch in build method
@override
Widget build(BuildContext context, WidgetRef ref) {
  final habits = ref.watch(habitsProvider); // Rebuilds on state changes
  return ListView.builder(...);
}

// RIGHT - ref.read in event handlers
void onButtonPressed(WidgetRef ref) {
  ref.read(habitsProvider.notifier).addHabit(); // One-time read
}
```

**2. Use .select() for Granular Subscriptions**
```dart
// WRONG - Rebuilds when ANY habit changes
final habits = ref.watch(habitsProvider);
final firstHabit = habits.first;

// RIGHT - Rebuilds only when first habit changes
final firstHabit = ref.watch(
  habitsProvider.select((habits) => habits.firstOrNull)
);
```

**3. Avoid Watching in Loops**
```dart
// WRONG - Watches provider inside loop
for (var habit in habits) {
  final status = ref.watch(habitStatusProvider(habit.id)); // N watches!
}

// RIGHT - Watch once, compute inside
final allStatuses = ref.watch(allHabitStatusesProvider);
for (var habit in habits) {
  final status = allStatuses[habit.id];
}
```

**Detection:**
- Flutter DevTools shows excessive rebuilds
- Battery drain reports
- Laggy UI when scrolling lists
- Performance profiler shows build methods called hundreds of times

**Phase Mapping:** Phase 1 (State Setup) - establish ref.watch/read patterns early; refactoring state management later is extremely time-consuming.

**Confidence:** HIGH - Riverpod documentation and community best practices.

**Sources:**
- [Ultimate Guide to Flutter State Management in 2026 - Medium](https://medium.com/@satishparmarparmar486/the-ultimate-guide-to-flutter-state-management-in-2026-from-setstate-to-bloc-riverpod-561192c31e1c)
- [Flutter Riverpod 2.0: The Ultimate Guide - Code with Andrea](https://codewithandrea.com/articles/flutter-state-management-riverpod/)

---

### Pitfall 9: 14-Day Timeline Underestimating Integration Complexity

**What goes wrong:** RevenueCat setup takes 3 days instead of 4 hours. WidgetKit configuration takes 2 days instead of "afternoon task." App Store submission delayed because TestFlight build needed for subscription testing.

**Why it happens:** Underestimating third-party integration debugging time. Optimistic assumptions about "it should just work."

**Prevention:**

**Realistic Timeline Breakdown for 14-Day Target:**

| Phase | Optimistic | Realistic | Buffer |
|-------|-----------|-----------|--------|
| Flutter setup + basic UI | 1 day | 2 days | +1 day |
| Core habit logic + Hive | 2 days | 3 days | +1 day |
| iOS Widget integration | 1 day | 2 days | +1 day |
| Notifications setup | 0.5 day | 1 day | +0.5 day |
| RevenueCat integration | 0.5 day | 2-3 days | +2.5 days |
| Polish + device testing | 1 day | 2 days | +1 day |
| TestFlight + fixes | 1 day | 2 days | +1 day |
| **Total** | **7 days** | **14-16 days** | **+8.5 days** |

**Risk Factors for Timeline Blow:**
- RevenueCat Configuration Error 23 (adds 1-2 days debugging)
- App Groups misconfiguration (adds 0.5-1 day)
- App Store rejection (adds 2-7 days for resubmission)
- Timezone bug discovery (adds 1-2 days for proper fix)
- Hive data corruption (adds 1-3 days if migration needed)

**Mitigation Strategies:**
1. **Cut scope ruthlessly**
   - MVP = single habit type, basic widget, one subscription tier
   - Defer: multiple habit types, advanced analytics, family sharing

2. **Use pre-built components**
   - Don't design custom paywall; use RevenueCat's default UI
   - Don't design complex widget; use simple progress bar template

3. **Parallel work streams**
   - While TestFlight build reviews (1-2 days), polish UI
   - While App Store reviews (1-3 days), prep marketing materials

4. **Front-load risky integrations**
   - RevenueCat on Day 1-2 (not Day 10)
   - WidgetKit on Day 2-3 (not Day 11)
   - Know if these will fail early, not at deadline

**Detection:**
- "We're halfway through timeline but only 20% done"
- Integration debugging taking multiple days
- Discovering scope creep ("just add one more feature")

**Phase Mapping:** Applies to entire project; timeline pressure affects every phase.

**Sources:**
- [App Development Timeline: How Long Does It Take - Medium](https://medium.com/@flutterwtf/app-development-timeline-how-long-does-it-take-to-develop-an-app-d0fb500323ba)
- [Mobile App Development Timeline - Guarana Technologies](https://guarana-technologies.com/blog/mobile-app-development-timeline)

---

## Minor Pitfalls

Mistakes that cause annoyance but are quickly fixable.

### Pitfall 10: Forgetting iOS 26 SDK Requirement (April 2026 Deadline)

**What goes wrong:** App Store submission rejected with "Apps submitted to the App Store must be built with the iOS 26 SDK or later" error.

**Why it happens:** Flutter stable channel may lag behind latest Xcode/iOS SDK releases. Developer doesn't update Xcode before building for submission.

**Prevention:**
1. Check Flutter and Xcode versions before building
   ```bash
   flutter doctor -v
   xcodebuild -version
   ```

2. Update to Flutter stable with iOS 26 SDK support
   ```bash
   flutter upgrade
   flutter clean
   flutter pub get
   ```

3. Update Xcode from Mac App Store
   - Xcode 16.x includes iOS 26 SDK
   - Restart Xcode after updating

4. Verify build settings
   - Open `ios/Runner.xcworkspace`
   - Runner > Build Settings > iOS Deployment Target = 14.0
   - Base SDK = Latest iOS (iOS 26.x)

**Detection:**
- App Store Connect submission error
- Build warnings about deprecated APIs
- TestFlight upload fails

**Phase Mapping:** Phase 5 (Pre-Launch) - verify before first TestFlight upload.

---

### Pitfall 11: Hardcoding Habit Categories Instead of Data Model

**What goes wrong:** Want to add new habit category post-launch but it's hardcoded in enum. Requires app update to add categories users request.

**Why it happens:** Over-engineering enum-based categories instead of simple string/data model.

**Prevention:**
```dart
// WRONG - Hardcoded enum
enum HabitCategory { exercise, meditation, reading, water }

// RIGHT - Flexible data model
class Habit {
  final String category; // "Exercise", "Meditation", or user-defined
  final IconData icon;
}

// Provide defaults, but allow custom
final defaultCategories = [
  HabitCategory('Exercise', Icons.fitness_center),
  HabitCategory('Meditation', Icons.self_improvement),
];
```

**Detection:**
- User feedback: "I want to track [X] but there's no category"
- Realizing you need app update for simple content change

**Phase Mapping:** Phase 1 (Data Model) - use flexible strings, not restrictive enums.

---

### Pitfall 12: Not Testing Empty States

**What goes wrong:** New user opens app → sees blank screen with no guidance. Widget shows "No Data" with no call to action.

**Why it happens:** Developers test with populated data, never reset to empty state.

**Prevention:**
1. **Test Empty State Flow**
   - Uninstall app completely
   - Fresh install
   - What does user see before creating first habit?

2. **Design Empty States**
   ```dart
   if (habits.isEmpty) {
     return EmptyStateView(
       icon: Icons.check_circle_outline,
       title: 'Start Your First Habit',
       subtitle: 'Track your daily progress and build streaks',
       action: ElevatedButton(
         onPressed: () => showCreateHabitSheet(),
         child: Text('Create Habit'),
       ),
     );
   }
   ```

3. **Widget Empty State**
   - Show "Open app to create your first habit"
   - Not just "No Data"

**Detection:**
- Beta tester feedback: "I didn't know what to do"
- High uninstall rate from new users

**Phase Mapping:** Phase 4 (Polish) - test with cleared data before every build.

---

## Phase-Specific Warnings

Mapping pitfalls to development phases for proactive mitigation.

| Phase | Likely Pitfall | Mitigation Strategy |
|-------|---------------|---------------------|
| **Phase 1: Core Data Model** | Timezone-naive streak logic | Store UTC timestamps, calculate in local timezone. Test DST transitions. |
| **Phase 1: Core Data Model** | Hive database corruption | Implement lock pattern for concurrent access. Close boxes explicitly. |
| **Phase 1: Core Data Model** | Hardcoded categories | Use flexible data model with strings, not restrictive enums. |
| **Phase 2: iOS Widget Integration** | App Groups misconfiguration | Configure for BOTH targets from start. Verify with device test. |
| **Phase 2: iOS Widget Integration** | WidgetKit refresh expectations | Set correct user expectations. Document observed update delays. |
| **Phase 3: Notifications** | Permission rejection on launch | Implement pre-permission education screen. Delay request until contextual. |
| **Phase 4: Monetization** | RevenueCat Configuration Error 23 | Front-load integration (Days 1-2, not Day 10). Test on TestFlight early. |
| **Phase 4: Monetization** | Missing subscription compliance elements | Include Restore button, pricing disclosure, terms links from start. |
| **Phase 5: Pre-Launch Polish** | App Store rejection traps | Device testing protocol. Content audit. Privacy policy verification. |
| **Phase 5: Pre-Launch Polish** | iOS 26 SDK requirement | Verify Xcode and Flutter versions before building for submission. |
| **Phase 5: Pre-Launch Polish** | Empty state testing gaps | Reset app data and test new user flow before each build. |
| **Throughout Project** | 14-day timeline underestimation | Front-load risky integrations. Cut scope ruthlessly. Build buffer for debugging. |

---

## Testing Protocol Summary

**Before Every Major Milestone, Test:**

1. **Timezone Edge Cases**
   - [ ] Change device timezone to different UTC offset
   - [ ] Verify streak persists correctly
   - [ ] Complete habit at 11:50 PM → change timezone → verify not double-counted

2. **Widget Data Sharing**
   - [ ] Mark habit complete in app
   - [ ] Return to home screen
   - [ ] Verify widget updates (within 5-10 minutes)
   - [ ] Force quit app → verify widget still shows data

3. **Hive Data Persistence**
   - [ ] Create 3 habits with completion data
   - [ ] Force quit app (don't just background)
   - [ ] Reopen → verify all habits intact
   - [ ] Kill app process during save → verify no corruption

4. **RevenueCat Integration**
   - [ ] Open paywall screen
   - [ ] Verify subscription products load
   - [ ] Attempt sandbox purchase
   - [ ] Tap "Restore Purchases" → verify no crash

5. **App Store Compliance**
   - [ ] Fresh install on device
   - [ ] Complete onboarding without crashes
   - [ ] Verify all Settings links work (privacy policy, terms, support)
   - [ ] Notification permission appears in context, not on launch
   - [ ] Subscription paywall includes price, terms, Restore button

6. **Empty States**
   - [ ] Uninstall → reinstall
   - [ ] Verify helpful empty state UI appears
   - [ ] Widget shows sensible "Get started" message

---

## Research Confidence Assessment

| Pitfall Category | Confidence Level | Basis |
|------------------|------------------|-------|
| Timezone/Streak Logic | HIGH | Multiple authoritative articles + real bug reports |
| WidgetKit Data Sharing | HIGH | Official Flutter docs + Apple Developer Forums |
| RevenueCat Integration | HIGH | Official RevenueCat docs + community troubleshooting |
| App Store Review Issues | HIGH | Official Apple guidelines + 2026 rejection data |
| Hive Database Issues | MEDIUM | GitHub issues + community reports (not verified at scale) |
| Riverpod State Management | HIGH | Official docs + community best practices |
| Widget Refresh Timing | MEDIUM | Apple docs + developer feedback (system behavior varies) |
| Notification Permissions | HIGH | Official Firebase/Flutter docs |
| Timeline Estimation | MEDIUM | Industry articles + community feedback (project-dependent) |
| iOS SDK Requirements | HIGH | Official Apple 2026 requirement announcement |

---

## Quick Reference: Pitfall Prevention Checklist

Use this checklist during development to avoid common traps:

**Day 1-2 (Setup):**
- [ ] Initialize RevenueCat in main() before runApp()
- [ ] Configure Hive with lock pattern for concurrent writes
- [ ] Store timestamps as UTC integers, not DateTime objects
- [ ] Use flexible string-based categories, not hardcoded enums

**Day 2-3 (Widget Integration):**
- [ ] Add App Groups to BOTH Runner and Widget Extension targets
- [ ] Match iOS deployment targets exactly (14.0)
- [ ] Reorder Build Phases: Embed Extensions above Run Script
- [ ] Test widget data sharing on real device in Release mode

**Day 4 (Notifications):**
- [ ] Implement pre-permission education dialog
- [ ] Don't request permission on app launch
- [ ] Check permission status before requesting
- [ ] Test with permission denied → app still works

**Day 5-7 (RevenueCat):**
- [ ] Create TestFlight build for subscription testing
- [ ] Match Product IDs exactly across App Store + RevenueCat + code
- [ ] Include "Restore Purchases" button on paywall
- [ ] Display price, billing period, and terms clearly
- [ ] Test with sandbox account on TestFlight (not local build)

**Day 10-11 (Timezone Testing):**
- [ ] Test habit completion near midnight (11:55 PM)
- [ ] Change device timezone → verify streak intact
- [ ] Test on DST transition dates (spring forward, fall back)
- [ ] Verify grace period logic (actions at 12:30 AM)

**Day 12-13 (Pre-Submission):**
- [ ] Full device test on physical iPhone (not simulator)
- [ ] Search codebase for "TODO", "Lorem", "Coming Soon"
- [ ] Verify all Settings links return 200 (not 404)
- [ ] Privacy policy published and accessible
- [ ] Request notifications in context, not on launch
- [ ] Uninstall → reinstall → verify empty state UX

**Day 13-14 (Build for Submission):**
- [ ] Verify Xcode includes iOS 26 SDK (April 2026 requirement)
- [ ] `flutter doctor` shows no issues
- [ ] Build in Release mode, test on device
- [ ] Archive and upload to TestFlight
- [ ] Internal TestFlight test: complete purchase flow

---

## Sources

**Official Documentation:**
- [Flutter iOS App Extensions - Official Docs](https://docs.flutter.dev/platform-integration/ios/app-extensions)
- [RevenueCat Troubleshooting SDKs - Official Docs](https://www.revenuecat.com/docs/test-and-launch/debugging/troubleshooting-the-sdks)
- [Apple WidgetKit - Keeping a Widget Up to Date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date)
- [FlutterFire Notification Permissions](https://firebase.flutter.dev/docs/messaging/permissions/)

**Community & Technical Blogs:**
- [How to Build a Streaks Feature - Trophy](https://trophy.so/blog/how-to-build-a-streaks-feature)
- [Implementing a Daily Streak System - Tiger Abrodi](https://tigerabrodi.blog/implementing-a-daily-streak-system-a-practical-guide)
- [Beware the Edge Cases of Time - Code of Matt](https://codeofmatt.com/beware-the-edge-cases-of-time/)
- [Flutter Hive Best Practices - CLIMB](https://climbtheladder.com/10-flutter-hive-best-practices/)
- [Flutter Riverpod Ultimate Guide - Code with Andrea](https://codewithandrea.com/articles/flutter-state-management-riverpod/)

**App Store Guidelines & Reviews:**
- [iOS App Store Review Guidelines 2026 - Crustlab](https://crustlab.com/blog/ios-app-store-review-guidelines/)
- [Top 10 iOS App Rejection Reasons 2026 - Betadrop](https://betadrop.app/blog/ios-app-rejection-reasons-2026)
- [Getting Through iOS App Review - RevenueCat](https://www.revenuecat.com/blog/engineering/getting-through-app-review/)

**Issue Trackers & Bug Reports:**
- [LeetCode Streak Bug (12:30 AM issue) - GitHub](https://github.com/LeetCode-Feedback/LeetCode-Feedback/issues/28204)
- [Hive Database Resets on Restart - GitHub Issue](https://github.com/isar/hive/issues/620)
- [WidgetKit Timeline Reload Issues - GitHub Feedback](https://github.com/feedback-assistant/reports/issues/359)
- [RevenueCat Flutter Configuration Errors - Community Forum](https://community.revenuecat.com/sdks-51/flutter-ios-configuration-error-fetching-offerings-5965)

**Developer Forums:**
- [Sharing UserDefaults with Widgets - Apple Developer Forums](https://developer.apple.com/forums/thread/651799)
- [FreeCodeCamp Timezone Streak Issue](https://forum.freecodecamp.org/t/changing-my-computers-timezone-messes-with-the-streak-counts/701634)

**Timeline & Project Management:**
- [App Development Timeline - Medium (Flutter WTF)](https://medium.com/@flutterwtf/app-development-timeline-how-long-does-it-take-to-develop-an-app-d0fb500323ba)
- [Mobile App Development Timeline - Guarana Technologies](https://guarana-technologies.com/blog/mobile-app-development-timeline)

---

**End of PITFALLS.md**
