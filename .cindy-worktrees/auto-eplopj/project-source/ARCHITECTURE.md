# Geometry Breakout Architecture

> Last updated: 2026-08-04 (Brotato Transition — new modules added)

## Runtime shape

UI-driven UrhoX Lua game. `scripts/main.lua` owns engine lifecycle and frame orchestration. Shared mutable runtime state lives in `scripts/state.lua`; feature modules receive state and callbacks rather than importing each other in a cycle.

## Current modules (post-transition target)

| File | Status | Purpose |
|------|--------|---------|
| `state.lua` | Active | Screen constants, shared state, entity lists, HUD refs, profile, shop state, gold, stats |
| `i18n.lua` | Active | Bilingual runtime text source (en + zh_CN) |
| `player.lua` | Active | Player reset, movement, touch/keyboard input, timers, stat application |
| `modules.lua` | **Deprecated** (P4) | 8 auto-attack modules. Will be replaced by `weapons.lua` |
| `enemies.lua` | Active | Enemy spawn, AI, damage, gold drops (P3), boss/mid-boss |
| `waves.lua` | Active | Wave lifecycle, modifier selection, shop routing (P2) |
| `stages.lua` | Active | Stage/level definitions, visual themes |
| `ui.lua` | Active | All screen builders, HUD, damage numbers, hit flash, shop screen (P2) |
| `shop.lua` | **NEW** (P2) | Shop screen builder, item generation, buy/reroll/lock/recycle logic |
| `stats_panel.lua` | **NEW** (P2) | Right-side stat display panel |
| `weapons.lua` | **NEW** (P4) | 6 weapon types, slot system, auto-fire logic |
| `items.lua` | **NEW** (P5) | Stat item definitions, effect application |
| `star_shop.lua` | **NEW** (P8) | Permanent progression shop |
| `main.lua` | Active | UI lifecycle, input events, pickups, frame orchestration |

## Externalized data (`data/`)

| File | Status | Content |
|------|--------|---------|
| `data/enemies.lua` | NEW (P1) | Enemy type definitions (name, stats, colors, behavior flags) |
| `data/upgrades.lua` | NEW (P1) | Upgrade card definitions |
| `data/stages.lua` | NEW (P1) | Stage/level/wave definitions (migrated from `stages.lua`) |

## Update pipeline

`HandleUpdate` maintains this order:

1. Read timestep + update run timers
2. Update player movement + stat calculations
3. Spawn enemies + weapon auto-fire (P4+)
4. Update defensive systems + enemy movement/collision
5. Update projectiles + pickups (gold P3+, XP)
6. Update visual modules (orbit, mines, trail) / weapon effects
7. End wave → route to shop (P2+) or wave_pause
8. Refresh HUD + stats panel + feedback

## Dependency rule

Feature modules communicate through explicit callbacks configured in `main.lua` → `Start()`. Avoid circular `require()` dependencies. Any new system must state: owner, state fields, update order, reset behavior before implementation.

## Screen flow (Brotato transition target)

```
language → stage_select → game (combat) → shop (between waves) → game → ...
                                                                    ↓
   summary ← (death or wave 20 complete)
```

Current flow still routes to `wave_pause`; shop routing comes in P2.
