# Quest 30

A lean iOS app that helps people complete 30-day challenges with one tap per day. Local-first, no backend, subscription monetization.

## One-Sentence Promise

Finish any 30-day challenge with one tap a day — streaks, reminders, and widgets that keep you on track.

## Current Status

**Phase 1: Foundation & Core Flow** — Complete (5/5 plans)

The app now has:

- Challenge creation from 3 preset packs (No Sugar 30, Daily Walk 30, Read 10 Pages 30)
- Home screen with challenge grid showing progress rings
- One-tap "Done" completion flow
- Streak tracking with timezone-safe logic
- Undo same-day completion
- Local persistence with Hive

**Next:** Phase 2 (iOS Integration) — Widgets and notifications

## V1 Challenge Packs

- **No Sugar 30** — 30 days without added sugar
- **Daily Walk 30** — 30 days of daily walks
- **Read 10 Pages 30** — 30 days of reading 10 pages

## Core Loop

```
Open → tap Done → day completes → streak continues → close
```

## Tech Stack

- **Framework:** Flutter (iOS-only for V1)
- **State:** Riverpod with AsyncNotifier pattern
- **Storage:** Hive (local-first, widget-compatible via App Groups)
- **IAP:** RevenueCat (planned for Phase 3)
- **Architecture:** Feature-first with clean separation

## Project Structure

```
ht_appstore/
├── lib/
│   ├── main.dart                 # App entry, Hive/timezone init
│   ├── core/
│   │   └── utils/                # StreakCalculator, DateUtils
│   └── features/
│       └── challenges/
│           ├── data/
│           │   ├── models/       # Challenge, ChallengePack
│           │   ├── services/     # HiveService
│           │   └── repositories/ # ChallengeRepository
│           └── presentation/
│               ├── screens/      # Home, Detail, PackSelection, Creation
│               ├── widgets/      # ProgressRing, GridItem, EmptyState
│               └── notifiers/    # ChallengeListNotifier
└── .planning/                    # GSD workflow docs (roadmap, state, plans)
```

## Running the App

```bash
cd ht_appstore
flutter pub get
flutter run
```

## Roadmap

| Phase | Description                              | Status   |
| ----- | ---------------------------------------- | -------- |
| 1     | Foundation & Core Flow                   | Complete |
| 2     | iOS Integration (Widgets, Notifications) | Up Next  |
| 3     | Monetization & Settings                  | Planned  |
| 4     | Stats & Polish                           | Planned  |

## Documentation

- `plan.md` — Full V1 product spec and build order
- `journey.md` — Build log for X/Twitter posts
- `.planning/` — Detailed phase plans, requirements, and state
