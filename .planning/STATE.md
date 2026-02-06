# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2025-01-25)

**Core value:** One tap completes today's challenge and keeps the streak alive
**Current focus:** Phase 04.1 - Fix Streak and Day Tracking (URGENT BUG FIX)

## Current Position

Phase: 04.1 (Fix Streak and Day Tracking) - INSERTED
Plan: 1 of 1
Status: Phase complete
Last activity: 2026-02-06 - Completed 04.1-01-PLAN.md

Progress: [██████████] Phase 1 complete | [██████████] Phase 2 complete | [██████████] Phase 3 complete | [████░░░░░░] Phase 4 2/3

## Performance Metrics

**Velocity:**
- Total plans completed: 18
- Total execution time: ~4.5 hours

**By Phase:**

| Phase | Plans | Status |
|-------|-------|--------|
| 01-foundation-core-flow | 5/5 | Complete |
| 02-ios-integration | 7/7 | Complete |
| 03-monetization-settings | 4/4 | Complete |
| 04.1-fix-streak-and-day-tracking | 1/1 | Complete |
| 04-stats-and-polish | 1/3 | In progress |

**Recent Completions:**
- 03-03: Settings Screen Expansion
- 03-04: Phase 3 Verification
- 04-01: Completion Chart
- 04.1-01: Fix Streak and Day Tracking (Bug fix)

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- iOS-only for V1: Faster ship, simpler widget implementation
- RevenueCat for IAP: Faster paywall wiring, handles receipt validation
- Riverpod for state: Modern, compile-safe, good for this app scale
- Hive for storage: Simple, lightweight, widget-compatible via App Groups
- Subscription-only monetization: Higher LTV than ads, aligns with ASO research
- Preset packs only (no custom): Reduces scope, faster V1

**Plan 01-01 Decisions:**
- Used List<int> instead of Set<int> for completionDatesUtc (Hive limitation)
- Removed riverpod_generator due to analyzer version conflict
- Downgraded build_runner to 2.4.13 for hive_generator compatibility
- Renamed DateUtils to AppDateUtils to avoid Flutter conflict

**Plan 01-02 Decisions:**
- Standard Riverpod providers instead of @riverpod code generation (carried forward from 01-01)
- AsyncValue.guard pattern for all notifier mutations
- Full list reload after mutations (simplicity over optimistic updates for V1)
- Provider.family for single challenge access from list

**Plan 01-04 Decisions:**
- Navigator.popUntil for multi-screen return after challenge creation
- Used withValues(alpha:) instead of deprecated withOpacity() for Flutter compatibility

**Plan 01-05 Decisions:**
- Large 200px progress ring with X/30 center text for visual prominence
- Pack emoji as large visual identifier at top of screen
- Undo button only appears after completion (secondary styling)

**Plan 02-02 Decisions:**
- Downgraded timezone to ^0.10.1 for flutter_local_notifications v20 compatibility
- flutter_local_notifications v20 uses named parameters (settings:, id:, scheduledDate:, etc.)
- Fixed Xcode build phases: Embed Foundation Extensions BEFORE Pods/Thin Binary
- Added iOS 17 availability checks for widget preview macros

**Plan 02-03 Decisions:**
- iOS 14.0 minimum deployment target (required by home_widget package)
- Removed ChallengeWidgetControl (Control Center widget) - not needed for V1
- Widget data keys: challenge_name, streak_count, is_completed_today, progress_percent, challenge_id, pack_emoji
- Deep link format: challengetracker://challenge/{id}
- Midnight refresh policy for widget timeline

**Plan 02-04 Decisions:**
- Converted ChallengeTrackerApp to StatefulWidget for widget click lifecycle handling
- GlobalKey<NavigatorState> for programmatic deep link navigation
- URI parsing: challengetracker://challenge/{id} with scheme/host/pathSegments

**Plan 02-06 Decisions:**
- Permission flow wired into _createChallenge() (not _selectTime())
- Pre-permission dialog shown before iOS system dialog
- Denial clears reminderTimeMinutes to null with SnackBar feedback

**Plan 02-07 Decisions:**
- Challenge.copyWith sentinel pattern (_unset = -1) to support clearing nullable reminderTimeMinutes
- Global notification toggle is "mute all" — preserves per-challenge reminder settings
- NotificationService singleton tracks globalEnabled state for settings screen
- Settings screen is minimal for Phase 2; Phase 3 expands with full SETT requirements

**Plan 03-01 Decisions:**
- iOS deployment target bumped from 14.0 to 15.0 for purchases_ui_flutter native paywalls (iOS 14 has <1% market share)
- subscriptionProvider uses polling pattern (30s interval) instead of customerInfoStream for purchases_flutter 9.x compatibility
- RevenueCatService follows NotificationService singleton pattern for consistency
- MonetizationConstants uses placeholder values (API key, URLs) for user replacement

**Day 8 Device Testing Decisions (2026-02-03):**
- LayoutBuilder for responsive progress ring sizing (40-60px) to prevent overflow on different devices
- Widget deep link URL requires `?homeWidget` query parameter for home_widget package to receive click events
- App display name set to "Quest 30" in Info.plist (CFBundleDisplayName, CFBundleName)

**Plan 04.1-01 Decisions:**
- DateTime.utc(year, month, day) for all date storage (not DateTime.now().toUtc() which shifts time)
- Start date validation in toggleCompletion() prevents pre-challenge completions
- Comprehensive doc comments added to Challenge model computed properties for date logic clarity

### Pending Todos

**Remaining for App Store submission:**
- [ ] Configure RevenueCat with real API key
- [ ] Create custom paywall design in RevenueCat Dashboard
- [ ] Add confetti animation for 30/30 challenge completion
- [ ] Audit codebase for placeholder content (TODO, Lorem ipsum, etc.)
- [ ] Complete offline testing
- [ ] Final compliance checklist

**V2 Features (documented in PROJECT.md):**
- [ ] CONT-02: Custom challenge creation (user-defined challenges)

### Roadmap Evolution

- Phase 04.1 inserted after Phase 4: Fix Streak and Day Tracking Calculations (URGENT) - COMPLETED
  - Bug introduced during Phase 4 polish work
  - Progress ring count correct, but Day Counter off by 1, Streak not counting until 10+ days
  - Duplicate entries possible when using calendar + Done button
  - Root cause: Inconsistent date storage/comparison formats across codebase
  - FIXED: Established DateTime.utc(year, month, day) normalization pattern, added start date validation

### Blockers/Concerns

**Phase 1 Critical Risks:**
- Timezone-naive streak logic: [ADDRESSED] StreakCalculator uses TZDateTime for timezone-safe calculations
- Hive database corruption: [ADDRESSED] HiveService uses explicit box management with _openBox() pattern

**Phase 2 Risks:**
- WidgetKit data sharing misconfiguration: [ADDRESSED] App Groups configured in 02-01, widget reading from UserDefaults in 02-03
- Notification permission rejection: [ADDRESSED] Pre-permission education dialog created in 02-02
- Xcode build phase cycles with Widget Extension: [ADDRESSED] Correct order documented in 02-02, applied in 02-03

**Phase 3 Risks:**
- RevenueCat Product ID mismatches: Verify exact match across App Store Connect, RevenueCat dashboard, and code
- Timeline underestimation: Allocate 2-3 hours for RevenueCat dashboard setup (App Store Connect + RevenueCat configuration)
- RevenueCat API key must be replaced in MonetizationConstants before purchase operations work
- TestFlight testing required to verify purchase flow (Sandbox environment) before production

## Session Continuity

Last session: 2026-02-06
Stopped at: Completed Phase 04.1 bug fix (streak and day tracking)
Resume file: None - ready for 04-02 (Pre-launch Polish & Compliance Audit)

**Bugs fixed in Phase 04.1:**
1. StreakCalculator.getCurrentUtcTimestamp() using incorrect DateTime.now().toUtc() pattern
2. Missing start date validation in toggleCompletion() allowing pre-challenge completions
3. Challenge model computed properties lacked documentation for complex date logic

**Tasks completed:**
- Fixed UTC normalization in StreakCalculator (renamed method to getTodayUtcTimestamp)
- Added start date validation to ChallengeRepository.toggleCompletion()
- Documented Challenge model date logic (Set deduplication, inclusive counting)

**Commits:**
- 56af68d: fix(04.1-01): fix StreakCalculator UTC normalization
- 9071d3f: fix(04.1-01): add start date validation to toggleCompletion
- 53c5823: docs(04.1-01): document Challenge model date logic

---

*State initialized: 2026-01-26*
*Last updated: 2026-02-06*
