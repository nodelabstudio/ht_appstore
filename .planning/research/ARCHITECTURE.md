# Architecture Patterns

**Domain:** Habit/Streak Tracker iOS App (Flutter)
**Researched:** 2026-01-26
**Confidence:** HIGH

## Recommended Architecture

Flutter habit tracker with **Feature-First + MVVM/Clean Architecture hybrid** using Riverpod state management, Hive local persistence, and WidgetKit extension.

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer (Flutter)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Home Screen  │  │ Stats Screen │  │ Detail Screen│          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         └─────────────────┼─────────────────┘                   │
│                           │                                      │
│  ┌────────────────────────▼─────────────────────────────┐       │
│  │         View Models (AsyncNotifiers)                  │       │
│  │  - ChallengeListNotifier                              │       │
│  │  - ChallengeDetailNotifier                            │       │
│  │  - StatsNotifier                                      │       │
│  │  - EntitlementNotifier                                │       │
│  └────────────────────────┬─────────────────────────────┘       │
└─────────────────────────┬─┼───────────────────────────────────┬─┘
                          │ │                                   │
┌─────────────────────────▼─▼───────────────────────────────────▼─┐
│                    Data Layer (Repositories)                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐│
│  │   Challenge      │  │    Entitlement   │  │  Notification  ││
│  │   Repository     │  │    Repository    │  │  Repository    ││
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬───────┘│
│           │                     │                      │        │
│  ┌────────▼─────────┐  ┌────────▼─────────┐  ┌────────▼───────┐│
│  │  Hive Service    │  │ RevenueCat Svc   │  │  LocalNotif    ││
│  │  (Local DB)      │  │ (IAP/Entitle)    │  │  Service       ││
│  └──────────────────┘  └──────────────────┘  └────────────────┘│
└──────────────────────────────────────────────────────────────────┘
                          │
                          │ (App Groups / UserDefaults)
                          │
┌─────────────────────────▼─────────────────────────────────────────┐
│                    WidgetKit Extension (Swift)                     │
│  ┌──────────────────────┐                                          │
│  │  TimelineProvider    │ Reads shared data via App Groups         │
│  └──────────────────────┘                                          │
└────────────────────────────────────────────────────────────────────┘
```

## Component Boundaries

| Component | Responsibility | Communicates With | Data Flow |
|-----------|---------------|-------------------|-----------|
| **Screens (Views)** | Render UI, handle user interactions | View Models only | Read-only UI state |
| **View Models (AsyncNotifiers)** | State management, business logic, command handlers | Repositories | Exposes streams/futures, receives user commands |
| **Repositories** | Single source of truth, data transformation, caching | Services | Polls services, returns domain models |
| **Services** | External API wrappers, platform integrations | Platform/packages | Stateless async operations |
| **WidgetKit Extension** | Native iOS widget display | App Groups (read-only) | Reads shared UserDefaults/files |

### Critical Boundaries

**View → View Model:**
- One-to-one relationship
- Views NEVER contain business logic
- Only simple conditionals for rendering, layout, animation

**View Model → Repository:**
- Many-to-many relationship
- View models call repositories, never services directly
- Repositories return domain models (Challenge, ChallengePack), not DTOs

**Repository → Service:**
- Many-to-many relationship
- Repositories coordinate multiple services if needed
- Services remain stateless

**Flutter App ↔ Widget Extension:**
- **Unidirectional data flow** (Flutter writes, Widget reads)
- No direct communication
- Shared via App Groups container

## Data Flow

### Challenge Completion Flow

```
User taps complete
    ↓
View calls command: challengeDetailNotifier.markComplete(date)
    ↓
View Model updates state optimistically
    ↓
View Model calls: challengeRepository.markComplete(challengeId, date)
    ↓
Repository updates domain model (adds date to completions Set)
    ↓
Repository persists via: hiveService.updateChallenge(challenge)
    ↓
Repository writes to App Groups: sharedStorage.syncChallenges([challenge])
    ↓
Repository triggers notification scheduling: notificationRepository.scheduleDaily(challenge)
    ↓
View Model emits new state
    ↓
UI rebuilds with updated completion status
    ↓
Widget Extension reads shared data on next timeline refresh
```

### Entitlement Check Flow

```
App launches
    ↓
EntitlementNotifier initializes
    ↓
EntitlementNotifier calls: entitlementRepository.checkEntitlement()
    ↓
Repository calls: revenueCatService.getCustomerInfo()
    ↓
Repository transforms to domain model: Entitlement(isPro: bool)
    ↓
Repository caches result in Hive for offline access
    ↓
EntitlementNotifier emits entitlement state
    ↓
UI conditionally shows premium features or paywall
```

### Widget Extension Update Flow

```
iOS Timeline refresh triggered (every 5-15 minutes)
    ↓
TimelineProvider.getTimeline() called (Swift)
    ↓
Read from App Groups: UserDefaults(suiteName: "group.com.app.habit")
    ↓
Parse challenge data (JSON → Swift models)
    ↓
Calculate streak, completion status
    ↓
Generate TimelineEntry with widget views
    ↓
WidgetKit displays updated widget
```

## Feature-Based Folder Structure

```
lib/
├── main.dart
├── app.dart                          # Root App widget
│
├── core/                             # Shared across features
│   ├── config/
│   │   ├── app_groups.dart          # App Groups configuration
│   │   └── theme.dart
│   ├── providers/                    # Global Riverpod providers
│   │   ├── hive_provider.dart
│   │   └── revenuecat_provider.dart
│   ├── widgets/                      # Reusable widgets
│   │   ├── habit_card.dart
│   │   └── streak_indicator.dart
│   └── utils/
│       ├── date_utils.dart
│       └── streak_calculator.dart
│
├── features/
│   ├── challenges/                   # Challenge management feature
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── challenge.dart   # Domain model (Hive type adapter)
│   │   │   │   └── challenge_pack.dart
│   │   │   ├── repositories/
│   │   │   │   └── challenge_repository.dart
│   │   │   └── services/
│   │   │       ├── hive_service.dart
│   │   │       └── shared_storage_service.dart  # App Groups
│   │   ├── presentation/
│   │   │   ├── notifiers/
│   │   │   │   ├── challenge_list_notifier.dart
│   │   │   │   └── challenge_detail_notifier.dart
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── detail_screen.dart
│   │   │   │   └── add_screen.dart
│   │   │   └── widgets/
│   │   │       ├── challenge_list_item.dart
│   │   │       └── completion_calendar.dart
│   │   └── domain/                   # Optional: complex business rules
│   │       └── streak_calculator.dart
│   │
│   ├── stats/                        # Statistics feature
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── stats_repository.dart
│   │   └── presentation/
│   │       ├── notifiers/
│   │       │   └── stats_notifier.dart
│   │       └── screens/
│   │           └── stats_screen.dart
│   │
│   ├── notifications/                # Notification feature
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── notification_repository.dart
│   │   │   └── services/
│   │   │       └── local_notification_service.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── settings_screen.dart
│   │
│   └── monetization/                 # IAP/Paywall feature
│       ├── data/
│       │   ├── models/
│       │   │   └── entitlement.dart
│       │   ├── repositories/
│       │   │   └── entitlement_repository.dart
│       │   └── services/
│       │       └── revenuecat_service.dart
│       └── presentation/
│           ├── notifiers/
│           │   └── entitlement_notifier.dart
│           └── screens/
│               └── paywall_screen.dart
│
└── widget_shared/                    # Shared with WidgetKit
    ├── models/                       # Simplified models for widget
    │   └── widget_challenge_dto.dart
    └── serializers/
        └── json_serializer.dart
```

### iOS Side Structure

```
ios/
├── Runner/                           # Main Flutter app target
│   └── AppDelegate.swift
│
├── HabitWidget/                      # WidgetKit extension target
│   ├── HabitWidget.swift             # Widget definition
│   ├── TimelineProvider.swift        # Data provider
│   ├── Models/
│   │   └── WidgetChallenge.swift
│   └── Info.plist
│
└── Shared/                           # Shared between targets
    └── AppGroups.swift               # App Groups constants
```

## Patterns to Follow

### Pattern 1: AsyncNotifier for State Management

**What:** Riverpod's AsyncNotifier provides reactive state management with built-in loading/error/success states.

**When:** Use for all view models that fetch or mutate data.

**Example:**
```dart
@riverpod
class ChallengeList extends _$ChallengeList {
  @override
  Future<List<Challenge>> build() async {
    // Initial load
    final repository = ref.read(challengeRepositoryProvider);
    return repository.getChallenges();
  }

  // Commands (mutations)
  Future<void> markComplete(String challengeId, DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(challengeRepositoryProvider);
      await repository.markComplete(challengeId, date);
      return repository.getChallenges(); // Reload
    });
  }
}
```

**Why:** Eliminates boilerplate for loading states, provides compile-time safety, automatically handles async errors.

### Pattern 2: Repository Pattern with Hive

**What:** Repositories abstract Hive database details and provide domain model interfaces.

**When:** Always. Never call Hive directly from view models.

**Example:**
```dart
class ChallengeRepository {
  final HiveService _hiveService;
  final SharedStorageService _sharedStorage;

  Stream<List<Challenge>> watchChallenges() {
    return _hiveService.watchBox<Challenge>()
      .map((box) => box.values.toList());
  }

  Future<void> markComplete(String id, DateTime date) async {
    final challenge = await _hiveService.get<Challenge>(id);
    final updated = challenge.copyWith(
      completions: {...challenge.completions, date},
    );
    await _hiveService.put(id, updated);

    // Sync to widget
    await _sharedStorage.syncChallenges([updated]);
  }
}
```

**Why:** Enables testing (mock repository), centralizes data logic, handles cross-cutting concerns (widget sync, caching).

### Pattern 3: App Groups Shared Storage

**What:** Write to UserDefaults with App Groups suite name to share data with WidgetKit.

**When:** After every data mutation that affects widget display.

**Example:**
```dart
class SharedStorageService {
  static const String _groupId = 'group.com.yourapp.habit';
  static const String _challengesKey = 'challenges_data';

  Future<void> syncChallenges(List<Challenge> challenges) async {
    final defaults = NSUserDefaults(suiteName: _groupId);

    // Convert to widget-friendly DTO
    final widgetDTOs = challenges.map((c) => {
      'id': c.id,
      'name': c.name,
      'streak': c.currentStreak,
      'completedToday': c.isCompletedToday,
    }).toList();

    await defaults.setObject(_challengesKey, jsonEncode(widgetDTOs));
  }
}
```

**Swift side:**
```swift
struct TimelineProvider: TimelineProvider {
    func getTimeline(completion: @escaping (Timeline<Entry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.yourapp.habit")
        if let data = defaults?.string(forKey: "challenges_data"),
           let challenges = parseChallenges(data) {
            // Generate timeline entries
        }
    }
}
```

**Why:** WidgetKit runs in separate process, App Groups is the only way to share data between app and extension.

### Pattern 4: Notification Scheduling via Repository

**What:** Centralize notification logic in a dedicated repository/service.

**When:** Schedule notifications after marking habits complete or when user updates settings.

**Example:**
```dart
class NotificationRepository {
  final FlutterLocalNotificationsPlugin _notifications;

  Future<void> scheduleDaily(Challenge challenge) async {
    if (!challenge.notificationsEnabled) return;

    await _notifications.zonedSchedule(
      challenge.id.hashCode,
      'Time for ${challenge.name}!',
      'Keep your ${challenge.currentStreak} day streak going',
      _nextInstanceOfTime(challenge.reminderTime),
      NotificationDetails(...),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
```

**Why:** Encapsulates notification complexity, handles timezone awareness, testable.

### Pattern 5: Entitlement-Gated Features

**What:** Use Riverpod to provide entitlement state throughout app, gate premium features at UI level.

**When:** Wrap premium features with entitlement checks.

**Example:**
```dart
@riverpod
class Entitlement extends _$Entitlement {
  @override
  Future<EntitlementState> build() async {
    final repository = ref.read(entitlementRepositoryProvider);
    return repository.checkEntitlement();
  }
}

// In UI:
class AddChallengeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(entitlementProvider);

    return entitlement.when(
      data: (state) {
        if (!state.isPro && challenges.length >= 3) {
          return PaywallScreen(); // Redirect to paywall
        }
        return AddChallengeForm();
      },
      loading: () => LoadingIndicator(),
      error: (e, _) => ErrorView(e),
    );
  }
}
```

**Why:** Centralized entitlement logic, automatic UI updates when subscription changes, supports offline caching.

## Anti-Patterns to Avoid

### Anti-Pattern 1: UI-Based Feature Organization

**What:** Organizing features by screens (e.g., `home_feature/`, `detail_feature/`) instead of functional domains.

**Why bad:** Causes code duplication when multiple screens share logic, makes it unclear where shared models belong, results in scattered feature code.

**Instead:** Organize by domain capabilities (e.g., `challenges/`, `stats/`, `monetization/`). A single feature can contain multiple screens.

### Anti-Pattern 2: Direct Hive Access from View Models

**What:** Calling `Hive.box<Challenge>()` directly in AsyncNotifiers/view models.

**Why bad:**
- Impossible to test without Hive initialization
- Ties business logic to storage implementation
- Bypasses opportunity for widget sync, caching, transformations

**Instead:** Always access data through repositories. Repositories encapsulate Hive and provide clean interfaces.

### Anti-Pattern 3: Embedding PaywallView in Modals

**What:** Using `showModalBottomSheet()` or `showDialog()` to display RevenueCat's PaywallView widget.

**Why bad:** RevenueCat documentation explicitly warns against this. PaywallView manages its own presentation lifecycle and conflicts with Flutter's modal overlay system.

**Instead:** Navigate to a full-screen PaywallScreen using `Navigator.push()` or `go_router.push('/paywall')`.

### Anti-Pattern 4: Widget Extension Writing Data

**What:** Allowing WidgetKit extension to modify challenge data (e.g., marking complete from widget).

**Why bad:**
- Creates bi-directional data flow, complicating state management
- Widget process has limited execution time
- Requires complex synchronization to prevent conflicts
- Notification scheduling requires main app

**Instead:** Make widgets read-only displays. For interactive widgets, use URL schemes to deep-link into the main app to perform actions.

### Anti-Pattern 5: Synchronous Widget Data Sync

**What:** Writing to App Groups only when user explicitly triggers sync, or batch syncing on app termination.

**Why bad:**
- Widget displays stale data between syncs
- User sees inconsistent state between app and widget
- Termination sync unreliable (iOS may kill app without warning)

**Instead:** Sync to App Groups immediately after every data mutation. It's fast (UserDefaults is memory-mapped) and ensures consistency.

### Anti-Pattern 6: Business Logic in Widgets

**What:** Calculating streaks, determining completion status, or handling date logic in widget `build()` methods.

**Why bad:**
- Violates MVVM separation of concerns
- Logic becomes impossible to test without widget tests
- Duplicated across multiple screens
- State management bypassed, causing bugs

**Instead:** Move ALL logic to view models or repositories. Widgets should only contain rendering and simple conditionals for layout.

## Build Order Dependencies

The architecture implies a specific build order to minimize rework:

### Phase 1: Foundation (Core Data Layer)

**Build first:**
1. Domain models (Challenge, ChallengePack, Entitlement)
2. Hive service (database wrapper)
3. Challenge repository (basic CRUD)

**Why first:** Everything else depends on data models and persistence.

**Milestone:** Can store and retrieve challenges locally.

### Phase 2: Core Features (View Models + Basic UI)

**Build second:**
1. ChallengeListNotifier + home screen
2. Basic challenge completion logic
3. Streak calculation utilities

**Why second:** Need working data layer before adding UI.

**Milestone:** Can view and complete challenges (no widget, no notifications yet).

### Phase 3: Widget Extension

**Build third:**
1. App Groups shared storage service
2. Sync logic in repository
3. Swift TimelineProvider
4. Basic widget UI

**Why third:** Requires working challenge completion flow to test. Widget displays data but doesn't need notifications/monetization.

**Milestone:** Widget displays current challenges and streaks.

### Phase 4: Notifications

**Build fourth:**
1. Notification repository
2. Scheduling logic
3. Settings screen for notification preferences

**Why fourth:** Independent of widget, depends on challenge completion flow.

**Milestone:** Daily reminders working.

### Phase 5: Monetization

**Build fifth:**
1. RevenueCat service
2. Entitlement repository
3. Entitlement notifier
4. Paywall screen
5. Entitlement checks throughout app

**Why fifth:** Most independent feature. Can build entire app, then gate features.

**Milestone:** Paywall displays, purchases unlock features.

### Phase 6: Polish

**Build last:**
1. Stats screen
2. Detail screen enhancements
3. Animations/transitions
4. Onboarding

**Why last:** Pure UI polish, no architectural dependencies.

**Milestone:** Production-ready app.

## Critical Implementation Details

### App Groups Configuration

**Required for widget data sharing:**

1. Enable App Groups capability in Xcode for both targets:
   - Runner (main app)
   - HabitWidget (extension)

2. Use same group identifier: `group.com.yourcompany.appname`

3. Access via Flutter:
```dart
// Using shared_preferences_app_group plugin
final prefs = await SharedPreferencesAppGroup.get('group.com.yourcompany.appname');
```

4. Access in Swift:
```swift
let defaults = UserDefaults(suiteName: "group.com.yourcompany.appname")
```

### Hive Type Adapters

**Domain models must have Hive type adapters:**

```dart
import 'package:hive/hive.dart';

part 'challenge.g.dart'; // Generated file

@HiveType(typeId: 0)
class Challenge {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Set<DateTime> completions;

  // Computed properties (not persisted)
  int get currentStreak => _calculateStreak();
  bool get isCompletedToday => completions.contains(_todayDate());
}

// Run: flutter pub run build_runner build
```

### Riverpod Code Generation

**Use Riverpod Generator for compile-time safety:**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_repository.g.dart';

@riverpod
ChallengeRepository challengeRepository(ChallengeRepositoryRef ref) {
  return ChallengeRepository(
    hiveService: ref.watch(hiveServiceProvider),
    sharedStorage: ref.watch(sharedStorageProvider),
  );
}

// Run: flutter pub run build_runner watch
```

### Widget Timeline Refresh

**WidgetKit controls refresh timing:**

- System decides when to call `getTimeline()`
- Typically every 5-15 minutes for small widgets
- More frequent for complications (Apple Watch)
- App can request reload via:
```dart
WidgetKit.reloadAllTimelines() // Not available in Flutter
```

**Workaround:** Write to App Groups immediately; widget will display updated data on next system refresh.

## Scalability Considerations

| Concern | Current Scale (100 users) | At 10K users | At 1M users |
|---------|---------------------------|--------------|-------------|
| **Data Storage** | Hive local-only works fine | Still local-only (no backend needed for habit tracking) | Consider optional cloud sync for multi-device |
| **Widget Performance** | Direct App Groups read sufficient | Same approach works | Same approach works |
| **Notification Scheduling** | Schedule all at once | Same | Same (local notifications don't scale with users) |
| **RevenueCat API** | Free tier sufficient (< 10K MTU) | Paid tier required | Enterprise tier |
| **State Management** | Riverpod handles easily | No changes needed | No changes needed |

**Key insight:** Habit tracker is **local-first by nature**. Architecture doesn't need to change with scale because there's no server-side data coordination.

## Testing Strategy

### Unit Tests (Highest ROI)

Test in isolation:
- Repositories (mock services)
- View models (mock repositories)
- Streak calculation utilities
- Date utilities

### Integration Tests

Test together:
- Repository + Hive service
- Repository + shared storage service
- Full feature flows (mark complete → persist → sync to widget)

### Widget Tests (Flutter)

Test UI:
- Screen rendering with different states (loading, error, success)
- User interactions (button taps trigger commands)
- Conditional rendering (paywall appears when needed)

### Skip

- Testing Hive directly (covered by integration tests)
- Testing RevenueCat service (external service, mock in tests)
- Testing WidgetKit (Swift code, test in Xcode if needed)

## Sources

**Official Documentation (HIGH confidence):**
- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/guide) - MVVM pattern, component boundaries
- [Flutter iOS App Extensions](https://docs.flutter.dev/platform-integration/ios/app-extensions) - App Groups, widget data sharing
- [Flutter App Architecture with Riverpod](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/) - Layer structure, AsyncNotifier pattern
- [Flutter Project Structure: Feature-First vs Layer-First](https://codewithandrea.com/articles/flutter-project-structure/) - Folder organization
- [RevenueCat Displaying Paywalls](https://www.revenuecat.com/docs/tools/paywalls/displaying-paywalls) - PaywallView integration

**Community Best Practices (MEDIUM confidence):**
- [Flutter Riverpod Clean Architecture Template](https://dev.to/ssoad/flutter-riverpod-clean-architecture-the-ultimate-production-ready-template-for-scalable-apps-gdh) - Feature-first structure
- [Flutter Repository Pattern](https://codewithandrea.com/articles/flutter-repository-pattern/) - Repository abstraction
- [Hive in Flutter with Clean Architecture](https://ms3byoussef.medium.com/hive-in-flutter-a-detailed-guide-with-injectable-freezed-and-cubit-in-clean-architecture-c5c12ce8e00c) - Hive integration patterns
- [Flutter Local Notifications Integration](https://github.com/mahmoodhamdi/Flutter-Local-Notifications-Integration-Guide) - Notification scheduling patterns

**Domain Research (LOW-MEDIUM confidence, validated against official docs):**
- Multiple GitHub habit tracker examples confirmed feature-first structure is common
- Community consensus: MVVM/Clean Architecture hybrid with Riverpod is 2026 standard
- App Groups pattern verified in official Flutter docs
