# CONTEXT.md — Quick-Start for AI Agents

> **Read this first.** 5 minutes = you know what this project is, what state it's in, and what to do next.
>
> Last updated: 2026-08-04 (Brotato Transition · P0-P3 in progress)

---

## What Is This?

**Geometry Breakout (几何突围)** — a Brotato-style top-down survivor roguelite built on TapTap Maker / UrhoX Lua.

It was a module-based auto-attack game (8 "modules" firing automatically). We're mid-transition to a Brotato-style weapon-slot + shop system.

**Platform:** TapTap Maker (mobile-first, Android/iOS)  
**Engine:** UrhoX Lua (no Unity, no Godot — Lua scripts only)  
**Art style:** Neon Vector Geometry → `project-source/ART_STYLE.md`  
**Entry point:** `scripts/main.lua`  
**i18n:** `i18n/` + `scripts/i18n.lua` (en + zh_CN)

## Current State (2026-08-04)

**The game RUNS** — full gameplay loop works:
- Language select → Stage select → Arena combat → 8 modules auto-attack → XP/level-up → 3-card upgrades → Waves → Bosses → Summary → Restart
- 2 stages × 10 levels × 6 waves each = 120 waves possible
- 5 enemy types: Chaser, Skimmer, Charger, Splitter, Shooter
- Boss & mid-boss encounters
- Touch joystick + keyboard controls
- HUD with integrity/XP/wave/timer/module display

**The transition has STARTED but is NOT complete:**
- P0 (cleanup + docs) ✅ DONE
- P1-P3 (data externalization, shop shell, gold) — IN PROGRESS
- P4-P9 (weapons, items, full shop, character, star shop, tuning) — NOT STARTED

## Where Does Everything Live?

```
TAPTAPGAME/
├── scripts/                    ← ALL runtime code
│   ├── main.lua               ← orchestrator (HandleUpdate, event wiring)
│   ├── state.lua              ← shared game state (player_, enemies_, screen_, etc.)
│   ├── i18n.lua               ← bilingual text lookup (M.TEXT table)
│   ├── player.lua             ← player movement + timers
│   ├── modules.lua            ← 8 auto-attack modules (WILL BE REPLACED by weapons.lua)
│   ├── enemies.lua            ← enemy spawning, AI, damage, boss logic
│   ├── waves.lua              ← wave lifecycle, level/stage advancement
│   ├── stages.lua             ← stage + level definitions (visual themes too)
│   ├── ui.lua                 ← ALL screen builders (language, game, upgrade, shop, etc.)
│   ├── shop.lua               ← shop screen between waves (NEW, scaffolding)
│   └── stats_panel.lua        ← right-side stats panel (NEW, scaffolding)
│
├── data/                       ← Externalized game data (NEW)
│   ├── enemies.lua            ← enemy definitions
│   ├── upgrades.lua           ← upgrade definitions
│   └── stages.lua             ← stage definitions
│
├── project-source/             ← ALL planning & design docs
│   ├── CONTEXT.md             ← YOU ARE HERE — start here
│   ├── PROJECT_CONTEXT.md     ← project identity, status, decisions
│   ├── ROADMAP.md             ← milestone ladder (M1-M10)
│   ├── GAME_DESIGN.md         ← full Brotato-style design (NEW)
│   ├── SHOP_SPEC.md           ← shop mechanics spec (NEW)
│   ├── ECONOMY.md             ← sources/sinks model (NEW)
│   ├── STATS_SPEC.md          ← stat axes spec (NEW)
│   ├── ARCHITECTURE.md        ← code architecture
│   ├── UI_LAYOUT.md           ← screen layout specs
│   ├── ART_STYLE.md           ← Neon Vector Geometry reference
│   └── TERMINOLOGY.md         ← bilingual term glossary
│
├── i18n/                       ← TapTap Maker i18n JSON files (mirror of i18n.lua)
├── archive/base-references/    ← Old reference projects (Brotato PDF, Windowkill clone)
├── urhox-libs/                 ← Engine UI library (DO NOT MODIFY)
├── engine-docs/                ← Engine reference (DO NOT MODIFY)
├── examples/                   ← Engine examples (DO NOT MODIFY)
├── templates/                  ← Engine templates (DO NOT MODIFY)
├── tools/                      ← Dev tools (SQLite DBs, scripts)
├── deliverables/               ← Past deliverables (month task packages, etc.)
└── schemas/                    ← Data schemas (empty, for future JSON validation)
```

## The Brotato Transition Plan

The game is becoming a Brotato-style survivor. Here's the locked-in design:

| Dimension | Decision |
|-----------|----------|
| Combat model | 6 weapon slots, auto-fire at nearest enemy |
| Upgrades | 4-card choice (was 3) |
| Run length | ~20 min, ~20 waves × 30s + 15s shop |
| Shop | Weapons + stat items + reroll/lock/recycle |
| Character | Geometric chassis + humanoid accents, visible on field |
| Meta progression | Star currency shop (after persistence verified) |
| Economy | Gold from enemies → spend in shop. No gold = no purchases. |
| Visual | Neon Vector Geometry (preserved) |

**Phase plan:**

| Phase | What | Status |
|-------|------|--------|
| P0 | Cleanup + docs + directory structure | ✅ DONE |
| P1 | Externalize data to Lua modules | IN PROGRESS |
| P2 | Shop + stats panel UI scaffolding | IN PROGRESS |
| P3 | Gold economy (state, drops, HUD, i18n) | IN PROGRESS |
| P4 | Replace modules with 6 weapon system | NOT STARTED |
| P5 | Stat items + 4-card upgrade | NOT STARTED |
| P6 | Full shop (weapons/items/reroll/lock/recycle) | NOT STARTED |
| P7 | Visible character on field | NOT STARTED |
| P8 | Star shop for permanent upgrades | NOT STARTED |
| P9 | 20-wave tuning + balance pass | NOT STARTED |

## Key Design Decisions (Locked)

- **6 weapon slots**: 6 distinct weapon types, auto-fire at nearest enemy. Replaces 8 modules entirely.
- **4-card upgrades**: not 3. Brotato-standard 4 random choices per level-up.
- **20 waves × ~30s**: ~20 min total run time. Shop between every wave.
- **Gold economy**: enemies drop gold on death. Gold used ONLY in shop. No gold = no purchases.
- **Shop sells**: weapons (primary), stat items (secondary). Reroll costs +1 gold per use.
- **Stat axes**: HP, Damage, Attack Speed, Range, Crit, Dodge, Speed, Luck. 8 total.
- **Weapon rarity**: 3 tiers (Common/Uncommon/Legendary) — not 4, to keep mobile readable.
- **Item stacking**: 1 per item type (no stacking same item).
- **Star currency**: Awarded on run completion (1-3 stars), spent in permanent shop.

## What NOT To Do

- Don't modify `urhox-libs/`, `engine-docs/`, `examples/`, `templates/`
- Don't introduce new engines or frameworks (Lua only)
- Don't change the art style away from Neon Vector Geometry
- Don't skip documenting design decisions — every stat, every mechanic needs a rationale
- Don't push to GitHub without also pushing to TapTap Maker `main` (Maker is source of truth)
- Don't delete `modules.lua` until weapons.lua is fully functional (P4)
- Don't add content before the core Brotato loop works

## TapTap Maker vs GitHub

- **TapTap Maker `main` is the source of truth.** All code flows from it.
- **GitHub `main` (Yunlong2601/SHENTECHSTUDIO) is a mirror.** Always push to both.
- Maker project UUID: `5e6c0799-195d-48e4-8bcb-0445b036dcf3`
- GitHub: `https://github.com/Yunlong2601/SHENTECHSTUDIO`

## Quick Debugging
- Entry: `scripts/main.lua` → `Start()` → `BuildUI()` → `HandleUpdate()`
- Screen state: `state.screen_` — values: `"language"`, `"game"`, `"upgrade"`, `"shop"`, `"wave_pause"`, `"summary"`, `"archive"`, `"cosmetics"`
- Game state: `state.player_` has `x, y, integrity, maxIntegrity, shell, invulnerable, gold_`
- Wave state: `state.wave_`, `state.waveTime_`, `state.modifier_`, `state.waveSpawnTarget_`
- Key bindings: WASD/arrows for movement, ESC to return to menu
