# Project Long-Term Memory — Geometry Breakout / 几何突围

## Current Phase: All Core Systems Complete (P0-P9 + UI Fixes + Published + Phase A)

### Design Locked
- Brotato-style: 6 weapon slots, auto-fire, 4-card upgrades, 20 waves × ~30s (~20 min runs)
- Shop between every wave: weapons + stat items + reroll/lock/recycle
- Gold economy: enemies drop gold → spend in shop
- 8 stat axes: HP/DMG/SPD/RNG/CRT/DDG/MOV/LCK
- Neon Vector Geometry visual style preserved
- Player character: geometric body (diamond) + humanoid features (eyes, face bar, trail) — distinct from monsters
- Full design: `project-source/GAME_DESIGN.md`
- Pre-run weapon select: player picks from Bow/Crossbow/Thrown (blade is fallback default)
- Shop unlock system: 2g reroll unlock + 3g lock unlock (per-run, [PLACEHOLDER pending playtest])
- Lock max 1 card per shop visit

### Phase Status
| Phase | Status |
|-------|--------|
| P0 (cleanup + docs) | ✅ Complete |
| P1 (data externalization) | ✅ Complete |
| P2 (shop + stats scaffolding) | ✅ Complete |
| P3 (gold economy) | ✅ Complete |
| P4 (weapons + character) | ✅ Complete |
| P5 (stat items + 4-card) | ✅ Complete |
| P6 (shop purchasing) | ✅ Complete |
| P7 (character polish) | ✅ Complete |
| P8 (VFX) | ✅ Complete |
| P9 (playtest tuning) | ✅ Complete |
| UI Fixes (9 bugs) | ✅ Complete |
| TapTap Publish | ✅ Published (2026-08-04)
| Phase A (weapon select + shop unlock + i18n) | ✅ Complete (2026-08-04)

### Project Facts (unchanged)
- TapTap Maker project UUID: `5e6c0799-195d-48e4-8bcb-0445b036dcf3`
- GitHub repo: `https://github.com/Yunlong2601/SHENTECHSTUDIO`
- Entry point: `scripts/main.lua`
- Art style: Neon Vector Geometry (`project-source/ART_STYLE.md`)
- i18n config: `.project/i18n.json`, translations in `i18n/`
- **TapTap Maker `main` is source of truth.** GitHub `main` is a mirror. Always push to both.

### TapTap Maker Build Config (gotcha — learned 2026-08-04)
- `.project/settings.json` `build.asset_dirs` lists dirs the engine scans at build + loads at runtime.
- **CRITICAL: Maker validates asset_dirs MUST contain only `"../assets"` and `"../scripts"`.** Adding any other dir (e.g. `"../data"`) causes build rejection.
- `require("foo")` → bare name, searched across all asset_dirs. `require("data.foo")` → `data.` prefix maps → engine searches `../scripts/data/foo.lua` (since `scripts` is an asset_dir). Put data files under `scripts/data/` to namespace without adding to asset_dirs.
- `.lua.meta` files (UUID refs) are NOT required for `require()` resolution — 5 active scripts have none and load fine (TapTap Maker auto-generates .meta server-side on git sync). Only needed for UUID-based asset refs in scenes/prefabs.
- `resources.json` uses `"default": ["**"]` (全量引用) → all files under asset_dirs are included; no per-file registration needed.

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

### TapTap Publish Checklist (post-mortem — 2026-08-04)

Before calling `maker_build_current_directory`, ALWAYS:

1. **Run `maker_status_lite` first** — catches asset_dirs violations and branch mismatches without burning a build.
2. **Verify `asset_dirs` exactly `["../assets", "../scripts"]`** — any other entry gets rejected at build time. All Lua modules must live under `scripts/`.
3. **Verify branch is `main`** (not `master`). After any `git init`, use `git init -b main` or `git branch -m main`.
4. **Never use `git stash` for cross-operation state saving** — it can corrupt refs on Windows when refs are packed. Instead:
   - `git diff > /tmp/changes.patch` for working tree
   - `cp -r <files> /tmp/` for untracked files
   - Then `git pull`, reapply patch + copy files back
5. **Recovery plan if git is broken:**
   - Back up changed files to `/tmp/` (not stash)
   - `rm -rf .git && git init -b main`
   - Set remotes, fetch, reset --hard
   - Copy files back, commit, push
   - Run `maker_status_lite` → `maker_build_current_directory`

### What NOT to touch
- `urhox-libs/`, `engine-docs/`, `examples/`, `templates/` — engine files
- Don't change art style away from Neon Vector Geometry
- **Never `git stash` in this project** — use explicit file backup instead
