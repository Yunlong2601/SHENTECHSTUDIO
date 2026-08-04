# Geometry Breakout / 几何突围

> Shared project context for TapTap Maker development and collaboration across AI agent platforms.
>
> **NEW: Read `project-source/CONTEXT.md` first** — it's the quick-start for AI agents.
> This file remains the durable source of truth for identity, status, decisions, and rules.
>
> Last updated: 2026-08-04 (Brotato Transition · P0-P3)

## 1. Project Identity

- **Chinese title:** 几何突围
- **English title:** Geometry Breakout
- **Genre:** Brotato-style top-down survivor roguelite
- **Platform:** TapTap Maker (UrhoX Lua), mobile-first Android/iOS
- **GitHub:** `Yunlong2601/SHENTECHSTUDIO` (mirror — Maker is source of truth)
- **Maker UUID:** `5e6c0799-195d-48e4-8bcb-0445b036dcf3`
- **Entry point:** `scripts/main.lua`
- **Art style:** Neon Vector Geometry → `project-source/ART_STYLE.md`
- **i18n:** `i18n/` (en + zh_CN)

## 2. Product Vision

Geometry Breakout is a Brotato-style survivor: construct a unique weapon build each run through shop decisions and 4-card upgrades. Every 30-second wave tests that build against escalating enemy density.

The game retains its Neon Vector Geometry identity — geometric forms, not character sprites. The Brotato transition is about *systems* (weapons, shop, stats), not about abandoning the visual language.

### Core fantasy

> Engineer a powerful geometric combat build while the arena collapses around you.

### Design pillars

1. **Build identity** — Each run creates a legible weapon + stat synergy.
2. **Decision density** — Every shop and upgrade is a meaningful choice.
3. **Readable chaos** — At max density (20+ enemies), the player can track everything.
4. **Short mastery loop** — ~20 min runs. Death teaches one lesson. Restart is instant.

## 3. Current Status — Brotato Transition

### Completed
- M1: Demo foundation (combat loop, upgrades, boss, telemetry, monetization placeholder)
- M2: Content density (2 stages, 10 levels, 5 enemies, mid-boss, boss, 8 modules)

### Active — Brotato Transition
The game is being restructured from a module-based auto-attack system to a Brotato-style weapon-slot + shop system.

**Transition phases (locked design — see GAME_DESIGN.md):**

| Phase | Scope | Status |
|-------|-------|--------|
| P0 | Cleanup + docs + directory structure | ✅ DONE |
| P1 | Externalize data to Lua modules | IN PROGRESS |
| P2 | Shop + stats panel UI scaffolding | IN PROGRESS |
| P3 | Gold economy (state, drops, HUD) | IN PROGRESS |
| P4 | Replace modules with 6-slot weapon system | NOT STARTED |
| P5 | Stat items + 4-card upgrade | NOT STARTED |
| P6 | Full shop (weapons/items/reroll/lock/recycle) | NOT STARTED |
| P7 | Visible character on field | NOT STARTED |
| P8 | Star shop for permanent upgrades | NOT STARTED |
| P9 | 20-wave tuning + full balance pass | NOT STARTED |

### Current code (still runs the old module-based game)
- 8 modules: Trace Beam, Orbit Seed, Pulse Bloom, Shell Lantern, Anchor Mine, Vector Hook, Laser Gun, Poison Bomb
- 3-card upgrades (will become 4)
- No shop, no gold, no weapons
- `scripts/modules.lua` is active but will be replaced by `scripts/weapons.lua` in P4

## 4. Key Design Decisions (Locked)

| Decision | Value | Rationale |
|----------|-------|-----------|
| Weapon slots | 6 | Enough for build variety, not overwhelming on mobile |
| Upgrade cards | 4 | Brotato standard, more decisions per level-up |
| Run length | ~20 min (20 waves × 30s) | Short enough for mobile sessions |
| Shop timing | Between every wave | Maximizes decision frequency |
| Weapon rarity | 3 tiers (Common/Uncommon/Legendary) | Mobile readability; 4 tiers is clutter |
| Stat axes | 8 (HP/DMG/SPD/RNG/CRT/DDG/MOV/LCK) | Brotato's proven set |
| Item stacking | 1 per type | Prevents degenerate stacking builds |
| Star currency | Awarded on run completion | Prevents grinding; rewards skill |
| Visual style | Neon Vector Geometry (preserved) | Distinct identity, Brotato is systems-only reference |

## 5. Collaboration Rules

### Source of truth
- **Quick-start:** `project-source/CONTEXT.md`
- **Product direction:** `project-source/PROJECT_CONTEXT.md` (this file)
- **Full design:** `project-source/GAME_DESIGN.md`
- **Mechanics specs:** `project-source/SHOP_SPEC.md`, `STATS_SPEC.md`, `ECONOMY.md`
- **Roadmap:** `project-source/ROADMAP.md`
- **Architecture:** `project-source/ARCHITECTURE.md`
- **Terminology:** `project-source/TERMINOLOGY.md`
- **Code:** `scripts/`
- **Data:** `data/`

### Before editing
1. Read `CONTEXT.md` (5 min overview)
2. Read `GAME_DESIGN.md` (design intent)
3. Read the relevant spec file (SHOP_SPEC, STATS_SPEC, ECONOMY)
4. Check what phase we're in (P0-P9 above)

### After editing
1. Run local Lua LSP if available
2. Update relevant spec files if design changes
3. **Push to TapTap Maker `main` first, then GitHub `main`**
4. Verify both remotes independently

### Do not do
- Don't modify `urhox-libs/`, `engine-docs/`, `examples/`, `templates/`
- Don't change engine or platform
- Don't change art style away from Neon Vector Geometry
- Don't skip phases — each unlocks prerequisites for the next
- Don't delete `modules.lua` until `weapons.lua` is functional
- Don't skip documenting design decisions in spec files

## 6. Archive

Old reference projects and design documents live in `archive/base-references/`:
- `Brotato Clone Documentation.pdf` — UX/design reference
- `Windowkill Clone` — Unity build (UX reference only, cannot merge — different engine)
