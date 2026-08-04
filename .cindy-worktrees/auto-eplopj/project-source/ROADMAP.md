# Geometry Breakout Roadmap

## End goal

Build the best Brotato-style survivor on mobile: stronger build expression than Brotato, clearer combat readability than Survivor.io, distinct Neon Vector Geometry identity.

## Current state — 2026-08-04

**Brotato Transition active.** The module-based game is being restructured into a weapon-slot + shop system.

**What works now:**
- Full playable loop (language → stage → combat → upgrades → boss → summary)
- 8 modules, 5 enemies, 2 stages, boss/mid-boss, touch + keyboard controls
- HUD, damage numbers, hit flash, screen shake, run telemetry
- Bilingual UI (zh_CN + en)

**What's being built (P0-P9):**
The Brotato transition — see `project-source/GAME_DESIGN.md` for full design.

## Transition Phase Plan

| Phase | What | Status |
|-------|------|--------|
| P0 | Cleanup + docs + directory structure | ✅ DONE |
| P1 | Externalize data to Lua modules | 🔄 IN PROGRESS |
| P2 | Shop + stats panel UI scaffolding | 🔄 IN PROGRESS |
| P3 | Gold economy (state, drops, HUD) | 🔄 IN PROGRESS |
| P4 | Replace modules with 6-slot weapon system | ⏳ |
| P5 | Stat items + 4-card upgrade | ⏳ |
| P6 | Full shop (weapons/items/reroll/lock/recycle) | ⏳ |
| P7 | Visible character on field | ⏳ |
| P8 | Star shop for permanent upgrades | ⏳ |
| P9 | 20-wave tuning + full balance pass | ⏳ |

## Product pillars (unchanged)

1. **Build expression:** every run creates a legible, synergistic build.
2. **Readable intensity:** the player can understand danger, damage, and reward on a small screen.
3. **Fast mastery:** a run teaches one new interaction at a time and restarts quickly.
4. **Original identity:** Neon Vector Geometry creates experiences competitors do not own.
5. **TapTap commercial readiness:** the demo must support a real monetizable path.
6. **Sustainable scope:** content is data-driven and testable before adding breadth.

## Completed Milestones

### M0 — Architecture cleanup ✅
- Extracted `ui.lua`, reduced `main.lua` to orchestration.
- Made `project-source/` the only active planning source.

### M1 — Demo foundation ✅
- Damage numbers, hit flashes, screen shake, module evolution bursts.
- Run telemetry, Neon Vector Geometry visuals, Core Breaker boss.
- Victory/defeat distinction, monetization placeholder.

### M2 — Content density ✅
- 5 enemy types, 8 modules, 2 stages × 10 levels × 6 waves.
- Mid-boss (Gatekeeper) + Final boss (Core Breaker).
- Laser Gun + Poison Bomb modules.
- HUD caching, frame-boundary UI rebuilds.

## Next Milestone — Brotato Transition

This replaces the old M3 milestone. The goal is a complete Brotato-style gameplay loop before any more content.

**Exit criteria for the transition:**
- [ ] 6 weapon types auto-fire at nearest enemy
- [ ] 4-card upgrade system with 8 stat axes
- [ ] Shop between every wave (weapons + stat items + reroll/lock/recycle)
- [ ] Gold economy fully functional (sources + sinks balance)
- [ ] Right-side stats panel shows all 8 axes in real-time
- [ ] Visible geometric character on field
- [ ] 20-wave run completable with distinct builds
- [ ] Star currency earned on completion (placeholder if persistence unavailable)

## Non-goals until transition complete
- No more stages or levels beyond the base 20-wave format
- No new enemy types beyond the 5 existing
- No monetization API integration
- No audio pass
- No daily challenges or leaderboards
- No more than 6 weapon types

## Weekly operating loop
1. Select the next phase (P0→P9 in order).
2. Make the smallest change that moves the game toward Brotato transition.
3. Document design decisions in the relevant spec file.
4. Push to TapTap Maker `main` → then GitHub `main`.
