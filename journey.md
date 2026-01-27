# journey.md — Build Log for X (Daily Posts)

## Why this file exists
This is the running log of how the app idea evolved and what we built each day, written in a way that can be adapted into daily X posts.

## Origin story (short)
We started with a “Bible Sleep / lullaby verses” idea, discovered via Astro that search demand was low for those terms, then pivoted to ASO-driven idea selection. We tested “tap counter” and found high downloads but low revenue, indicating a mostly free/ad market. We then validated higher-revenue categories and chose a subscription-friendly direction: a **30‑Day Challenge Tracker**, using the **Streaks-style UI** as inspiration.

## Research timeline (what happened)
### 1) Initial idea + constraint setting
- Goal: ship one app in 2 weeks, ASO-first, no heavy APIs/backends, subscription-only.

### 2) Astro exploration
- “Bible sleep” keywords showed low popularity → pivoted to broader utility seeds.
- Explored seed keywords: counter, timer, fasting, habit, tracker, streak.

### 3) Validation loop
- Found “tap counter” opportunity (winnable difficulty) but Sensor Tower showed low revenue vs downloads.
- Interpreted as a “free market” keyword cluster (hard to justify subscription).

### 4) Pivot to subscription-friendly markets
- Validated “fasting” and “habit/streak” as higher revenue clusters.
- Chose a direction that supports subscription **without requiring a backend**:
  **30-Day Challenge Tracker** (program packs + widgets + stats).

### 5) Locked V1
Challenge packs:
- No Sugar 30
- Daily Walk 30
- Read 10 Pages 30

Core loop:
Open → tap Done → day completes → streak continues

Screens (V1):
Home, Challenge Detail, Stats, Add Challenge, Paywall, Settings

---

## Daily Build Log

### Day 1 — 2026-01-26

**What we shipped today**
- Set up GSD workflow with PROJECT.md, REQUIREMENTS.md, ROADMAP.md
- Defined 4 phases with clear success criteria
- Created 34 requirements mapped to phases
- Researched Flutter stack: Riverpod, Hive, timezone handling

**What we decided**
- iOS-only for V1 (faster ship, simpler widget implementation)
- RevenueCat for IAP (faster paywall wiring)
- Riverpod for state management (compile-safe, modern)
- Hive for storage (simple, widget-compatible via App Groups)
- Preset packs only, no custom challenges (reduces scope)

**What broke / what we learned**
- ASO research showed "tap counter" has high downloads but low revenue — free market
- Pivoted to subscription-friendly "habit/streak" cluster instead

**Tomorrow's target**
- Execute Phase 1: Foundation & Core Flow

**X post draft (short)**
Day 1: Planned the entire 30-day challenge tracker app.
34 requirements across 4 phases. Local-first, no backend.
Biggest lesson: ASO research before coding saves you from building the wrong thing.
Tomorrow: Building the core flow.

---

### Day 2 — 2026-01-27

**What we shipped today**
- Phase 1 complete: 5 plans, 1,786 lines of Dart code, 17 files
- Flutter project with Hive persistence and timezone-safe streak calculator
- Challenge and ChallengePack domain models
- ChallengeRepository with full CRUD operations
- Riverpod AsyncNotifier for reactive state management
- Home screen with GridView and progress rings
- Pack selection and challenge creation screens
- Challenge detail screen with Done/Undo buttons
- Light/dark theme support with Material 3

**What we decided**
- Used List<int> instead of Set<int> for completions (Hive limitation)
- Standard Riverpod providers instead of @riverpod codegen (analyzer conflict)
- Full list reload after mutations (simplicity over optimistic updates for V1)
- Large 200px progress ring on detail screen for visual prominence

**What broke / what we learned**
- riverpod_generator conflicted with hive_generator's analyzer version
- Flutter's DateUtils class conflicts with custom DateUtils — renamed to AppDateUtils
- Wave-based parallel execution worked well: 3 plans in parallel for Wave 3

**Tomorrow's target**
- Phase 2: iOS Integration (widgets and notifications)

**X post draft (short)**
Day 2: Phase 1 done. The app works.
Create a challenge, tap Done, streak grows, data persists.
1,786 lines of Dart, 17 files, timezone-safe streak logic.
Tomorrow: Widgets and notifications.

---

## Daily log template (copy/paste each day)
### Day X — (date)
**What we shipped today**
- …

**What we decided**
- …

**What broke / what we learned**
- …

**Tomorrow's target**
- …

**X post draft (short)**
Today I shipped ____ for my 30‑day challenge tracker.
Biggest lesson: ____.
Tomorrow: ____.

## Suggested “building in public” angles
- “ASO > vibes” lessons (how keywords forced the pivot)
- “Subscriptions need ongoing value” (packs + widgets + stats)
- “2-week constraint is a feature” (scope discipline)
- “Local-first is underrated” (no auth, no backend, faster ship)

## Proof-of-work artifacts to share on X
- Astro screenshots (keyword tables + ranking lists)
- Sensor Tower snapshots (download vs revenue reality check)
- Figma/WIP screenshots (Home grid, Done button, Paywall)
- Short screen recordings (tap Done → streak updates)
