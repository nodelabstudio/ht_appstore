# plan.md — 30‑Day Challenge Tracker (V1)

## Current Status

**Phase 1: Foundation & Core Flow** — COMPLETE (2026-01-27)

| Step | Description | Status |
|------|-------------|--------|
| 1 | Project setup, theme, routing | Done |
| 2 | Local data model + storage | Done |
| 3 | Home → Detail → Add screens | Done |
| 4 | Streak logic + date handling | Done |
| 5 | Local notifications | **Next** (Phase 2) |
| 6 | Paywall + subscriptions | Phase 3 |
| 7 | Stats screen | Phase 4 |
| 8 | Widgets | **Next** (Phase 2) |
| 9 | Polish + TestFlight | Phase 4 |

**What's built:**
- 1,786 lines of Dart across 17 files
- Challenge/ChallengePack models with Hive persistence
- ChallengeRepository with CRUD + completion logic
- Riverpod AsyncNotifier for reactive state
- HomeScreen, PackSelectionScreen, ChallengeCreationScreen, ChallengeDetailScreen
- ProgressRing widget, timezone-safe StreakCalculator
- Material 3 theming with light/dark support

**Next up:** Phase 2 — iOS Integration (widgets + notifications)

---

## Goal

Ship a lean iOS app in **14 days** that helps people complete **30‑day challenges** with one tap per day. The app is **local‑first** (no backend), **ASO-first**, and monetizes via **auto‑renewable subscriptions**.

## One‑sentence promise

Finish any 30‑day challenge with one tap a day — streaks, reminders, and widgets that keep you on track.

## V1 Challenge Packs (included at launch)

- **No Sugar 30**
- **Daily Walk 30**
- **Read 10 Pages 30**

## Core loop (the whole app)

Open → tap **Done** → today completes → streak continues → close.

## Monetization (subscription-only)

We’ll use **auto‑renewable subscriptions** (monthly + annual).

- Free tier: 1 active challenge + basic streak view + 1 widget style
- Pro tier: unlimited challenges + all packs + widgets + stats/history

Implementation notes:

- Include a **Restore Purchases** action (required for subscriptions). (Apple StoreKit guidance)
- Paywall must clearly show subscription name/duration and renewal price; App Store metadata must link Terms + Privacy Policy. (Apple subscriptions guidance)

## V1 Screens (max 6) Inside references/streaks there is a README.md that has some instructions and screenshots of some apps that I like for inspiration.

### 1) Home (grid of challenges)

Purpose: Choose a challenge fast.

- Grid of “challenge cards” (inspired by Streaks’ bold tiles)
- Each card shows: icon, title, progress ring (Day X/30), current streak
- Primary CTA: tap a challenge to open detail
- Secondary CTA: “+ Add” card

### 2) Challenge Detail

Purpose: Do today’s action.

- Big **Done** button
- Shows: Day X of 30, streak count, last completed date
- Optional: tiny “Note” field for today (kept local)
- Undo last completion (same day only)

### 3) Stats (simple, optional but recommended)

Purpose: Make progress feel real.

- Best streak, total completions
- Simple chart: completions by day (sparkline) OR calendar dots
- Keep it lightweight; no heavy analytics SDK needed for V1

### 4) Add Challenge

Purpose: Start quickly.

- Choose pack: No Sugar 30 / Daily Walk 30 / Read 10 Pages 30
- Start date (default today)
- Reminder time (optional)
- “Create” button

### 5) Paywall

Purpose: Convert.

- Headline: “Go Pro: Unlimited Challenges + Widgets + Stats”
- Bullets: unlimited, widgets, history/stats, all packs
- Monthly + Annual options
- Restore purchases
- Links: Terms, Privacy

### 6) Settings

Purpose: the boring required stuff.

- Restore purchases
- Notifications toggle + reminder time shortcut
- Support (email)
- Privacy policy + Terms links
- App version

## V1 Features (keep it tight)

### Must-have

- Create/select challenge from pack
- One-tap daily completion + streak logic
- Local persistence (all data on device)
- Local notifications (optional reminders)
- Subscription paywall + entitlements + restore

### Nice-to-have (only if ahead of schedule)

- Notes per day (short text)
- Multiple widget styles
- Simple “share progress” card (image export)

## Data model (local)

ChallengePack

- id, name, icon, defaultGoalText (optional)

Challenge

- id
- packId
- title (editable)
- startDate
- reminderTime (nullable)
- completions: Set<Date> (store as yyyy-mm-dd strings)
- currentStreak
- bestStreak
- lastCompletedDate
- status: active | completed | abandoned

Entitlement

- isPro (bool)
- purchaseInfo (receipt-derived via StoreKit)

## Widgets (Pro)

- iOS WidgetKit widget(s): show today’s status for selected challenge(s)
- Tap opens Challenge Detail (widgets can’t directly mutate state; they deep-link into the app)

## Notifications (optional)

Local notifications:

- Schedule daily reminder for active challenge(s) at user-selected time.
- Keep it simple: one reminder per day per active challenge (or just one “Today’s challenge” reminder).

## Tech stack (Flutter-first)

- UI: Flutter (Material 3 or custom theme)
- State mgmt: simple (Riverpod / Provider / Bloc — choose what your starter kit supports cleanly)
- Local storage: Hive/Isar/shared_preferences (pick one; prefer whichever your kit already has)
- IAP: StoreKit 2 via Flutter plugin (or RevenueCat if you prefer faster paywall wiring)
- Deep links: for widget tap → open challenge detail

## App Store / Review readiness checklist

- No forced sign-in
- Restore purchases present
- Paywall disclosure: duration + renewal price + what’s included
- Privacy policy + Terms links in-app + in App Store metadata
- No “must rate to use app” mechanics (App Review Guidelines)

## Build order (what Claude should do in sequence)

1. Project setup, theme, routing
2. Implement local data model + storage
3. Build screens: Home → Detail → Add
4. Implement streak logic + date handling
5. Add local notifications (time picker + scheduling)
6. Add paywall + subscription entitlements + restore
7. Add Stats screen (simple)
8. Add widgets (at least 1 style)
9. Polish pass (empty states, loading, haptics), then TestFlight

## ASO starter pack (placeholder; refine later)

Primary: “streak tracker”, “challenge tracker”, “habit challenge”
Secondary: “daily challenge”, “30 day challenge”, “routine tracker”
Subtitle idea: “One tap a day.”
