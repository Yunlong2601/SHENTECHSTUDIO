# Project Long-Term Memory — Geometry Breakout / 几何突围

## Current Phase: Brotato Transition (P0-P5 complete, P6 next)

### Design Locked
- Brotato-style: 6 weapon slots, auto-fire, 4-card upgrades, 20 waves × ~30s (~20 min runs)
- Shop between every wave: weapons + stat items + reroll/lock/recycle
- Gold economy: enemies drop gold → spend in shop
- 8 stat axes: HP/DMG/SPD/RNG/CRT/DDG/MOV/LCK
- 3 weapon rarity tiers: Common/Uncommon/Legendary
- Neon Vector Geometry visual style preserved
- Player character: geometric body (diamond) + humanoid features (eyes, face bar, trail) — distinct from monsters
- Full design: `project-source/GAME_DESIGN.md`

### Phase Status
| Phase | Status |
|-------|--------|
| P0 (cleanup + docs) | ✅ Complete |
| P1 (data externalization) | ✅ Complete |
| P2 (shop + stats scaffolding) | ✅ Complete |
| P3 (gold economy) | ✅ Complete |
| P4 (weapons + character) | ✅ Complete |
| P5 (stat items + 4-card) | ✅ Complete |
| P6 (shop purchasing) | ⏳ Next |

### Project Facts (unchanged)
- TapTap Maker project UUID: `5e6c0799-195d-48e4-8bcb-0445b036dcf3`
- GitHub repo: `https://github.com/Yunlong2601/SHENTECHSTUDIO`
- Entry point: `scripts/main.lua`
- Art style: Neon Vector Geometry (`project-source/ART_STYLE.md`)
- i18n config: `.project/i18n.json`, translations in `i18n/`
- **TapTap Maker `main` is source of truth.** GitHub `main` is a mirror. Always push to both.

### Key Files for Agents
- **Quick-start:** `project-source/CONTEXT.md`
- **Full design:** `project-source/GAME_DESIGN.md`
- **Mechanics:** `project-source/SHOP_SPEC.md`, `STATS_SPEC.md`, `ECONOMY.md`
- **Roadmap:** `project-source/ROADMAP.md`
- **Architecture:** `project-source/ARCHITECTURE.md`

### Active Scripts
- `main.lua` — scheduler: weapons.update + character.update + shell + enemies
- `weapons.lua` — 6 weapon types (blade/bow/staff/blunt/crossbow/thrown), 6 slots, auto-fire
- `character.lua` — visible player: diamond body + eyes + trail
- `player.lua` — movement + collision + velocity tracking
- `enemies.lua` — spawn/damage/projectile system (now with onHitAoE support)
- `waves.lua` / `stages.lua` — wave progression
- `ui.lua` / `shop.lua` / `stats_panel.lua` — UI layer
- `state.lua` — shared state (includes weapons_, charWidgets_, gold_)

### Archive
- Legacy reference project moved to `archive/base-references/`
- `modules.lua` deleted in P4 — weapons.lua is the replacement

### What NOT to touch
- `urhox-libs/`, `engine-docs/`, `examples/`, `templates/` — engine files
- Don't change art style away from Neon Vector Geometry
