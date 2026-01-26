# Technology Stack

**Project:** 30-Day Challenge Habit Tracker (iOS)
**Researched:** 2026-01-26
**Overall Confidence:** HIGH

## Core Stack (Already Decided)

### Framework
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Flutter | 3.38.6 | Cross-platform framework (iOS-only for this project) | Industry standard for mobile development, excellent iOS support, enables WidgetKit integration |
| Dart | 3.9+ | Programming language | Flutter's language, null-safe, excellent tooling |

### State Management
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Riverpod | 2.x | State management | Type-safe, testable, no BuildContext required, excellent for local-first apps |

### Local Storage
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Hive | 2.x | NoSQL local database | Fast, lightweight, no native dependencies, perfect for local-first architecture |

### Monetization
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| RevenueCat | Latest | In-app purchases & subscriptions | Handles subscription complexity, analytics, cross-platform receipt validation, best-in-class subscription management |

## Essential Supporting Libraries

### Notifications & Reminders
| Library | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| flutter_local_notifications | ^20.0.0 | Local push notifications for daily reminders | HIGH |
| timezone | ^0.11.0 | IANA timezone database for scheduling | HIGH |
| flutter_timezone | ^5.0.1 | Get device timezone | HIGH |

**Why:**
- flutter_local_notifications is the de-facto standard for local notifications (1.6M+ pub points, verified publisher)
- Supports iOS 10+ UserNotification APIs with rich content, actions, and attachments
- timezone + flutter_timezone required for reliable time-based notification scheduling
- Enables daily reminder feature without backend dependency

**Installation notes:**
- Requires iOS notification permissions
- Must call `initializeTimeZones()` before scheduling
- Use `zonedSchedule()` for daily notifications (not deprecated `schedule()`)

### Home Screen Widgets
| Library | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| home_widget | ^0.9.0 | WidgetKit integration | MEDIUM |

**Why:**
- Only viable option for Flutter-to-WidgetKit bridge
- Google-official codelab demonstrates its use
- Enables data sharing between Flutter app and iOS WidgetKit extension
- Supports interactive widgets (iOS 17+)

**Critical limitation:**
- Widget UI must be written in SwiftUI (not Flutter)
- Uses App Groups for data sharing via UserDefaults
- Requires Xcode for widget creation
- This is a Flutter ecosystem limitation, not package-specific

**Alternative approach:** Write WidgetKit extension directly in Xcode, skip home_widget if comfortable with native iOS

### Date/Time Utilities
| Library | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| intl | ^0.20.2 | Internationalization & date formatting | HIGH |

**Why:**
- Official Flutter team package
- Standard for date formatting in Flutter
- Locale-aware formatting (future internationalization-ready)
- DateFormat.yMMMd() and similar patterns for streak displays

**Note:** Dart DateTime is adequate for basic date math (30-day tracking). Only add specialized date packages if complex calculations needed.

### Celebratory UI/UX
| Library | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| confetti | ^0.8.0 | Completion celebration animations | HIGH |

**Why:**
- 1.59K likes, 216K+ downloads, MIT license
- Perfect for celebrating streak milestones (7-day, 30-day completion)
- Customizable physics (velocity, gravity, colors)
- Multi-platform support including iOS
- Lightweight (no native dependencies)

**Usage:** Trigger on 30-day completion, weekly milestones

### Haptic Feedback
**Use Flutter's built-in HapticFeedback class** (services library)

**Why NOT use a package:**
- Flutter provides `HapticFeedback.lightImpact()`, `.mediumImpact()`, `.heavyImpact()`, `.selectionClick()` out-of-box
- Native iOS CoreHaptics integration
- No external dependency needed for basic haptics on tap completion

**Only add flutter_vibrate or haptic_feedback if:** You need complex haptic patterns (unlikely for this app)

### UI Components
| Library | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| percent_indicator | ^4.2.5 | Circular progress for 30-day streak | HIGH |

**Why:**
- 565K+ downloads, 2.77K likes
- Clean API for circular progress (perfect for "X/30 days" display)
- Customizable colors, gradients, animations
- Built-in percentage text display
- Lightweight, pure Dart

**Usage:** Show 30-day progress on main screen

### App Metadata & Configuration
| Library | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| flutter_launcher_icons | ^0.14.4 | App icon generation | HIGH |
| shared_preferences | ^2.5.4 | Settings & preferences storage | HIGH |
| uuid | ^4.5.2 | Generate unique IDs for challenges | HIGH |

**Why flutter_launcher_icons:**
- Automates iOS app icon generation (all required sizes)
- iOS 18+ support (dark mode icons, tinted icons)
- Development dependency only (no runtime overhead)
- Verified publisher (fluttercommunity.dev)

**Why shared_preferences:**
- Standard for storing user preferences (notification time, theme, etc.)
- Wraps NSUserDefaults on iOS
- Recent update (2.5.4, 48 days ago) adds SharedPreferencesAsync API
- 10M+ pub points

**Why uuid:**
- Generate unique challenge IDs for Hive storage
- RFC4122 compliant
- Use v4 (random) for 99% of use cases
- Cryptographically secure, no coordination needed

**Note:** For sensitive data (user tokens if added later), use flutter_secure_storage instead

### Social Features
| Library | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| share_plus | ^12.0.1 | Share achievements | MEDIUM |
| in_app_review | ^2.0.11 | Request App Store reviews | HIGH |
| app_badge_plus | ^1.2.6 | App icon badge for streaks | MEDIUM |

**Why share_plus:**
- Wraps iOS UIActivityViewController
- Share streak achievements ("I completed 30 days!")
- iOS 12.0+, verified publisher (fluttercommunity.dev)
- Standard package for social sharing

**Why in_app_review:**
- Uses iOS requestReview() API (native)
- Prompts users at right moment (e.g., after 30-day completion)
- Also provides openStoreListing() for manual review button
- iOS automatically limits to 3 prompts per 365 days

**Why app_badge_plus:**
- Show current streak on app icon badge
- Native iOS badge support
- Requires notification permissions
- Simple API: `AppBadgePlus.updateBadge(streakCount)`

## Development Tools

### Linting & Code Quality
| Tool | Version | Purpose | Confidence |
|------|---------|---------|------------|
| flutter_lints | ^6.0.0 | Official Flutter lint rules | HIGH |

**Why flutter_lints:**
- Official Google/Flutter recommendation
- Included by default in new Flutter projects
- Balances strictness with pragmatism
- Follows Dart Style Guide & Effective Dart

**Alternative: very_good_analysis**
- 188 rules (vs flutter_lints ~80)
- Stricter: strict-inference, strict-raw-types
- Used by Very Good Ventures
- Choose if you want maximum code quality enforcement

**Recommendation:** Start with flutter_lints. It's already in pubspec.yaml for new projects and sufficient for 14-day timeline.

## What NOT to Use

### Firebase
**Why avoid:**
- Local-first architecture (no backend)
- Adds 10MB+ to app size
- Overkill for local-only storage
- RevenueCat handles subscriptions
- No need for remote config, analytics, auth

**When to add:** Only if adding cloud backup feature later

### GetX / Provider
**Why avoid:**
- Riverpod already chosen
- Multiple state management patterns = confusion
- Riverpod superior to Provider in all ways
- GetX brings service locator anti-pattern

### sqflite / drift / isar
**Why avoid:**
- Hive already chosen
- Overkill for simple key-value + object storage
- SQL unnecessary for habit tracking data model
- Hive has lower learning curve for 14-day timeline

### flutter_native_splash
**Why avoid (for now):**
- Nice-to-have, not essential for MVP
- Can add post-launch
- Focus on core features first

### flutter_secure_storage
**Why avoid (for now):**
- No sensitive data stored locally
- RevenueCat handles receipt validation
- Add only if storing auth tokens later

## Installation Commands

```yaml
# pubspec.yaml additions (beyond already-decided stack)

dependencies:
  # Notifications
  flutter_local_notifications: ^20.0.0
  timezone: ^0.11.0
  flutter_timezone: ^5.0.1

  # Date/Time
  intl: ^0.20.2

  # Home Screen Widgets
  home_widget: ^0.9.0

  # UI/UX
  confetti: ^0.8.0
  percent_indicator: ^4.2.5

  # Storage & IDs
  shared_preferences: ^2.5.4
  uuid: ^4.5.2

  # Social Features
  share_plus: ^12.0.1
  in_app_review: ^2.0.11
  app_badge_plus: ^1.2.6

dev_dependencies:
  flutter_lints: ^6.0.0
  flutter_launcher_icons: ^0.14.4
```

**Post-install requirements:**
1. Configure flutter_launcher_icons in pubspec.yaml
2. Initialize timezone data in main.dart before notifications
3. Request iOS notification permissions at app launch
4. Create WidgetKit extension in Xcode for home_widget
5. Configure App Groups for widget data sharing

## Platform-Specific Configuration Needed

### iOS Info.plist
```xml
<!-- Notification descriptions -->
<key>NSUserNotificationsUsageDescription</key>
<string>We'll remind you to complete your daily challenge</string>
```

### iOS Capabilities (Xcode)
- Push Notifications (for local notifications)
- App Groups (for WidgetKit data sharing)

### WidgetKit Extension
- Must be created in Xcode
- Write SwiftUI views for widgets
- Use UserDefaults with App Group for data sync

## Version Strategy

**Minimum iOS Version:** 13.0
- Allows iOS 13.0+ users (95%+ of active iOS devices)
- All packages support iOS 12.0+ except home_widget (requires iOS 14+ for WidgetKit)
- WidgetKit introduced in iOS 14 (2020)

**Flutter SDK:** 3.38.6 stable
- Latest stable as of Jan 2026
- Minimum 3.22 required by flutter_local_notifications
- Dart 3.9+ (null-safe, pattern matching)

## Sources

**High Confidence (Official/Verified):**
- [flutter_local_notifications pub.dev](https://pub.dev/packages/flutter_local_notifications) - v20.0.0, verified publisher
- [home_widget pub.dev](https://pub.dev/packages/home_widget) - v0.9.0
- [intl pub.dev](https://pub.dev/packages/intl) - v0.20.2, Flutter team
- [confetti pub.dev](https://pub.dev/packages/confetti) - v0.8.0, verified publisher
- [flutter_lints pub.dev](https://pub.dev/packages/flutter_lints) - v6.0.0
- [shared_preferences pub.dev](https://pub.dev/packages/shared_preferences) - v2.5.4, verified publisher
- [uuid pub.dev](https://pub.dev/packages/uuid) - v4.5.2
- [percent_indicator pub.dev](https://pub.dev/packages/percent_indicator) - v4.2.5
- [share_plus pub.dev](https://pub.dev/packages/share_plus) - v12.0.1, verified publisher
- [in_app_review pub.dev](https://pub.dev/packages/in_app_review) - v2.0.11, verified publisher
- [app_badge_plus pub.dev](https://pub.dev/packages/app_badge_plus) - v1.2.6
- [timezone pub.dev](https://pub.dev/packages/timezone) - v0.11.0
- [flutter_timezone pub.dev](https://pub.dev/packages/flutter_timezone) - v5.0.1
- [flutter_launcher_icons pub.dev](https://pub.dev/packages/flutter_launcher_icons) - v0.14.4, verified publisher
- [Flutter SDK Release Notes](https://docs.flutter.dev/release/release-notes) - Flutter 3.38.6 stable
- [Google Codelabs: Home Screen Widgets](https://codelabs.developers.google.com/flutter-home-screen-widgets) - Official home_widget guidance
- [Flutter HapticFeedback API](https://api.flutter.dev/flutter/services/HapticFeedback-class.html) - Built-in haptics

**Medium Confidence (Community consensus):**
- [LogRocket: Implementing Local Notifications](https://blog.logrocket.com/implementing-local-notifications-in-flutter/)
- [RydMike: Flutter Linting Comparison](https://rydmike.com/blog_flutter_linting.html)

## Confidence Assessment

| Category | Confidence | Reason |
|----------|------------|--------|
| Notifications | HIGH | flutter_local_notifications is industry standard, verified via pub.dev |
| Widgets | MEDIUM | home_widget is only option, but requires native SwiftUI knowledge |
| Date/Time | HIGH | intl is official Flutter team package |
| UI/UX | HIGH | All packages verified via pub.dev with strong adoption |
| Social Features | HIGH | share_plus and in_app_review are community standards |
| Linting | HIGH | flutter_lints is official Google recommendation |

## Summary

The recommended stack extends the already-decided foundation (Flutter, Riverpod, Hive, RevenueCat) with battle-tested packages for notifications, widgets, and UX polish. All packages are:
1. Actively maintained (updates within last 6 months)
2. iOS-compatible (12.0+ except WidgetKit requires 14.0+)
3. Verified publishers or community standards
4. Lightweight (minimal app size impact)
5. Aligned with 14-day ship timeline (no complex integration)

**Key architectural note:** The home_widget limitation (SwiftUI required) is a Flutter ecosystem constraint, not a package issue. Budget 1-2 days for WidgetKit extension development in Xcode.
