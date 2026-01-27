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

## Daily log template (copy/paste each day)
### Day X — (date)
**What we shipped today**
- …

**What we decided**
- …

**What broke / what we learned**
- …

**Tomorrow’s target**
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
