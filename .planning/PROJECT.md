# 30-Day Challenge Tracker

## What This Is

A lean iOS app that helps people complete 30-day challenges with one tap per day. Local-first (no backend), ASO-optimized, and monetized via auto-renewable subscriptions. Ships in 14 days.

## Core Value

One tap completes today's challenge and keeps the streak alive — frictionless daily progress that users actually stick with.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Create/select challenge from preset packs
- [ ] One-tap daily completion with streak logic
- [ ] Local persistence (all data on device)
- [ ] Local notifications for reminders
- [ ] Subscription paywall with entitlements + restore
- [ ] Home screen with challenge grid (Streaks-inspired)
- [ ] Challenge detail with big "Done" button
- [ ] Stats screen (best streak, total completions, simple chart)
- [ ] Add challenge flow (pack selection, start date, reminder time)
- [ ] Settings (restore purchases, notifications, support, legal links)
- [ ] iOS WidgetKit widget (today's status for selected challenge)

### Out of Scope

- Android (V1 is iOS-only, Android deferred)
- Backend/authentication (local-first by design)
- Social features (no sharing, no leaderboards)
- Custom challenge creation (packs only for V1)
- Multiple widget styles (one style for V1)
- Daily notes feature (nice-to-have, only if ahead)
- Share progress card export (nice-to-have, only if ahead)

## Context

**Origin**: Started with Bible sleep/lullaby idea, pivoted after ASO research showed low demand. Validated through Astro keyword research — "habit", "streak", "challenge" clusters show subscription-friendly revenue patterns.

**UI Inspiration**: Streaks app (bold tiles, progress rings, minimal UI). Reference screenshots in `references/streaks/`. Do not copy exact visuals — use as pattern inspiration only.

**V1 Challenge Packs**:
- No Sugar 30
- Daily Walk 30
- Read 10 Pages 30

**Core Loop**: Open → tap Done → today completes → streak continues → close.

**Monetization**:
- Free tier: 1 active challenge + basic streak view + 1 widget style
- Pro tier: unlimited challenges + all packs + widgets + stats/history

**Build-in-public**: Tracking journey in `journey.md` for X posts.

## Constraints

- **Timeline**: 14 days to App Store submission
- **Platform**: iOS only (Flutter, but iOS-first for V1)
- **Tech Stack**: Flutter + Riverpod + Hive + RevenueCat
- **No Backend**: All data local, no authentication required
- **App Store Compliance**: Restore purchases required, paywall must show duration + price, Terms + Privacy links mandatory

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| iOS-only for V1 | Faster ship, simpler widget implementation, App Store focus | — Pending |
| RevenueCat for IAP | Faster paywall wiring, handles receipt validation, analytics included | — Pending |
| Riverpod for state | Modern, compile-safe, good for this app scale | — Pending |
| Hive for storage | Simple, lightweight, widget-compatible via App Groups | — Pending |
| Subscription-only monetization | Higher LTV than ads, aligns with ASO research | — Pending |
| Preset packs only (no custom) | Reduces scope, faster V1, can add custom in V2 | — Pending |

---
*Last updated: 2025-01-25 after initialization*
