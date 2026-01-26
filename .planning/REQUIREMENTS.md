# Requirements: 30-Day Challenge Tracker

**Defined:** 2026-01-26
**Core Value:** One tap completes today's challenge and keeps the streak alive

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Challenge Management

- [ ] **CHAL-01**: User can view grid of active challenges on home screen
- [ ] **CHAL-02**: User can select from 3 pre-built challenge packs (No Sugar 30, Daily Walk 30, Read 10 Pages 30)
- [ ] **CHAL-03**: User can create new challenge from selected pack with start date
- [ ] **CHAL-04**: User can set optional reminder time when creating challenge
- [ ] **CHAL-05**: User can view challenge detail showing progress (Day X of 30)

### Completion & Streaks

- [ ] **COMP-01**: User can tap "Done" to mark today's challenge complete (one-tap flow)
- [ ] **COMP-02**: User sees streak count update immediately after completion
- [ ] **COMP-03**: User can undo completion (same day only)
- [ ] **COMP-04**: User sees progress ring showing Day X/30 completion percentage
- [ ] **COMP-05**: Streak logic handles timezone changes correctly (no false streak breaks)
- [ ] **COMP-06**: User can freeze streak for a day (forgiveness feature)

### Persistence

- [ ] **DATA-01**: All challenge data persists locally on device (Hive)
- [ ] **DATA-02**: Data survives app restart and device reboot
- [ ] **DATA-03**: Completion timestamps stored in UTC, displayed in local timezone

### Notifications

- [ ] **NOTF-01**: User can enable daily reminder notifications
- [ ] **NOTF-02**: User can set reminder time for each challenge
- [ ] **NOTF-03**: Notifications fire at correct time regardless of timezone
- [ ] **NOTF-04**: User can disable notifications per challenge or globally

### Widgets

- [ ] **WIDG-01**: User can add home screen widget showing today's challenge status
- [ ] **WIDG-02**: Widget displays challenge name, streak count, and completion status
- [ ] **WIDG-03**: Widget updates when user completes challenge in app
- [ ] **WIDG-04**: Tapping widget opens challenge detail in app

### Stats

- [ ] **STAT-01**: User can view stats screen with progress metrics
- [ ] **STAT-02**: User sees current streak count
- [ ] **STAT-03**: User sees best streak (all-time record)
- [ ] **STAT-04**: User sees total completions count
- [ ] **STAT-05**: User sees simple completion chart or calendar dots

### Monetization

- [ ] **PAID-01**: Free tier limited to 1 active challenge
- [ ] **PAID-02**: Pro tier unlocks unlimited active challenges
- [ ] **PAID-03**: User can view paywall with monthly and annual subscription options
- [ ] **PAID-04**: Paywall displays subscription duration and renewal price clearly
- [ ] **PAID-05**: User can restore previous purchases
- [ ] **PAID-06**: User sees Terms of Service and Privacy Policy links in paywall

### Settings

- [ ] **SETT-01**: User can access settings screen
- [ ] **SETT-02**: User can restore purchases from settings
- [ ] **SETT-03**: User can toggle notifications globally
- [ ] **SETT-04**: User can access support (email link)
- [ ] **SETT-05**: User can view Privacy Policy and Terms of Service
- [ ] **SETT-06**: User can see app version

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Enhanced Widgets

- **WIDG-05**: Interactive widget completion (mark done without opening app)
- **WIDG-06**: Lock screen widget (iOS 16+)
- **WIDG-07**: Multiple widget styles/sizes

### Data Sync

- **SYNC-01**: iCloud sync for data across devices
- **SYNC-02**: Data migration on reinstall

### History

- **HIST-01**: User can edit completion history (backfill missed days)
- **HIST-02**: User can view detailed completion calendar

### Content

- **CONT-01**: Additional challenge packs beyond initial 3
- **CONT-02**: Custom challenge creation (user-defined challenges)

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Android version | iOS-only for V1, ship fast |
| Backend/authentication | Local-first by design, no complexity |
| Social features | Not core to 30-day challenge value |
| Apple Health integration | High complexity, subset of users |
| Apple Watch app | Requires iOS excellence first |
| Complex gamification (XP, levels) | Research shows novelty fades, adds friction |
| Mood ratings per habit | Adds friction to core one-tap loop |
| Photo progress tracking | Feature creep for V1 |
| Multiple themes | Defer until core is solid |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| CHAL-01 | Phase 1 | Pending |
| CHAL-02 | Phase 1 | Pending |
| CHAL-03 | Phase 1 | Pending |
| CHAL-04 | Phase 1 | Pending |
| CHAL-05 | Phase 1 | Pending |
| COMP-01 | Phase 1 | Pending |
| COMP-02 | Phase 1 | Pending |
| COMP-03 | Phase 1 | Pending |
| COMP-04 | Phase 1 | Pending |
| COMP-05 | Phase 1 | Pending |
| COMP-06 | Phase 1 | Pending |
| DATA-01 | Phase 1 | Pending |
| DATA-02 | Phase 1 | Pending |
| DATA-03 | Phase 1 | Pending |
| NOTF-01 | Phase 2 | Pending |
| NOTF-02 | Phase 2 | Pending |
| NOTF-03 | Phase 2 | Pending |
| NOTF-04 | Phase 2 | Pending |
| WIDG-01 | Phase 2 | Pending |
| WIDG-02 | Phase 2 | Pending |
| WIDG-03 | Phase 2 | Pending |
| WIDG-04 | Phase 2 | Pending |
| STAT-01 | Phase 4 | Pending |
| STAT-02 | Phase 4 | Pending |
| STAT-03 | Phase 4 | Pending |
| STAT-04 | Phase 4 | Pending |
| STAT-05 | Phase 4 | Pending |
| PAID-01 | Phase 3 | Pending |
| PAID-02 | Phase 3 | Pending |
| PAID-03 | Phase 3 | Pending |
| PAID-04 | Phase 3 | Pending |
| PAID-05 | Phase 3 | Pending |
| PAID-06 | Phase 3 | Pending |
| SETT-01 | Phase 3 | Pending |
| SETT-02 | Phase 3 | Pending |
| SETT-03 | Phase 3 | Pending |
| SETT-04 | Phase 3 | Pending |
| SETT-05 | Phase 3 | Pending |
| SETT-06 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 34 total
- Mapped to phases: 34
- Unmapped: 0

**Phase Distribution:**
- Phase 1 (Foundation & Core Flow): 14 requirements
- Phase 2 (iOS Integration): 8 requirements
- Phase 3 (Monetization & Settings): 12 requirements
- Phase 4 (Stats & Polish): 5 requirements

---
*Requirements defined: 2026-01-26*
*Last updated: 2026-01-26 after roadmap creation*
