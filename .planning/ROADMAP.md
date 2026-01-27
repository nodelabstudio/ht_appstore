# Roadmap: 30-Day Challenge Tracker

## Overview

This roadmap delivers a lean iOS habit tracking app in 4 phases across 14 days. Starting with core data models and one-tap completion flow, we build the foundation that everything else depends on. Then we add iOS-specific features (widgets and notifications) that make daily habit tracking frictionless. Monetization and settings provide the business model and compliance requirements. Finally, stats and polish ensure App Store approval on first submission.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3, 4): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation & Core Flow** - Data models, persistence, and one-tap completion
- [ ] **Phase 2: iOS Integration** - Widgets and daily reminder notifications
- [ ] **Phase 3: Monetization & Settings** - RevenueCat paywall and app settings
- [ ] **Phase 4: Stats & Polish** - Progress visualization and App Store compliance

## Phase Details

### Phase 1: Foundation & Core Flow

**Goal**: User can create challenges from preset packs and mark them complete with one tap, seeing their streak grow.

**Depends on**: Nothing (first phase)

**Requirements**: CHAL-01, CHAL-02, CHAL-03, CHAL-04, CHAL-05, COMP-01, COMP-02, COMP-03, COMP-04, COMP-05, COMP-06, DATA-01, DATA-02, DATA-03

**Success Criteria** (what must be TRUE):
1. User can select from 3 challenge packs (No Sugar 30, Daily Walk 30, Read 10 Pages 30)
2. User can create new challenge with start date and optional reminder time
3. User can view grid of active challenges on home screen showing progress
4. User can tap "Done" button to complete today's challenge in under 2 seconds
5. User sees streak count update immediately after completion and progress ring shows Day X/30
6. User can undo completion (same day only)
7. All data persists across app restarts and device reboots
8. Streak logic handles timezone changes correctly (no false streak breaks during travel/DST)

**Plans**: 5 plans

Plans:
- [x] 01-01-PLAN.md — Project setup, models, Hive persistence, streak calculator
- [x] 01-02-PLAN.md — Challenge repository and Riverpod AsyncNotifier
- [x] 01-03-PLAN.md — Home screen grid UI with progress rings
- [x] 01-04-PLAN.md — Pack selection and challenge creation screens
- [x] 01-05-PLAN.md — Challenge detail screen with Done/Undo buttons

---

### Phase 2: iOS Integration

**Goal**: User receives daily reminders and can monitor challenge status via home screen widget without opening the app.

**Depends on**: Phase 1 (needs working completion flow and data layer)

**Requirements**: NOTF-01, NOTF-02, NOTF-03, NOTF-04, WIDG-01, WIDG-02, WIDG-03, WIDG-04

**Success Criteria** (what must be TRUE):
1. User can enable daily reminder notifications with customizable time per challenge
2. Notifications fire at correct time regardless of timezone
3. User can disable notifications per challenge or globally from settings
4. User can add home screen widget showing challenge name, streak count, and completion status
5. Widget updates when user completes challenge in app
6. Tapping widget opens challenge detail screen

**Plans**: TBD

Plans:
- [ ] TBD (to be defined during plan-phase)

---

### Phase 3: Monetization & Settings

**Goal**: User encounters paywall when trying to create second challenge and can purchase Pro subscription to unlock unlimited challenges.

**Depends on**: Phase 2 (needs complete feature set to gate)

**Requirements**: PAID-01, PAID-02, PAID-03, PAID-04, PAID-05, PAID-06, SETT-01, SETT-02, SETT-03, SETT-04, SETT-05, SETT-06

**Success Criteria** (what must be TRUE):
1. Free tier limited to 1 active challenge (attempting to create second shows paywall)
2. Pro tier unlocks unlimited active challenges
3. User can view paywall with monthly and annual subscription options showing duration and renewal price
4. User can restore previous purchases from paywall and settings
5. Paywall displays Terms of Service and Privacy Policy links
6. User can access settings screen with restore purchases, notification toggle, support email link, legal links, and app version

**Plans**: TBD

Plans:
- [ ] TBD (to be defined during plan-phase)

---

### Phase 4: Stats & Polish

**Goal**: App passes App Store review on first submission with complete stats dashboard and compliance requirements met.

**Depends on**: Phase 3 (needs full feature set for audit)

**Requirements**: STAT-01, STAT-02, STAT-03, STAT-04, STAT-05

**Success Criteria** (what must be TRUE):
1. User can view stats screen showing current streak, best streak, total completions, and completion chart
2. Stats update in real-time as user completes challenges
3. App contains no placeholder content (no "TODO", "Lorem Ipsum", test data)
4. Privacy Policy and Terms of Service published and accessible
5. App tested on physical iPhone in Release mode (not just simulator)
6. All App Store compliance requirements met (subscription terms, restore button, legal links, contextual permission requests)

**Plans**: TBD

Plans:
- [ ] TBD (to be defined during plan-phase)

---

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Core Flow | 5/5 | ✓ Complete | 2026-01-27 |
| 2. iOS Integration | 0/TBD | Not started | - |
| 3. Monetization & Settings | 0/TBD | Not started | - |
| 4. Stats & Polish | 0/TBD | Not started | - |

---

*Roadmap created: 2026-01-26*
*Last updated: 2026-01-27*
