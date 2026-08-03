# Geometry Breakout / 几何突围

> Shared project context for TapTap Maker development and collaboration across AI agent platforms.
>
> Last updated: 2026-08-03 (Prototype 04 — Defense & Counter)
>
> This file is the current-state source of truth. The complete planning source is `project-source/`; read `ROADMAP.md` for future milestones and `ARCHITECTURE.md` for code structure.

## 1. Project Identity

- **Chinese title:** 几何突围
- **English title:** Geometry Breakout
- **Genre:** Top-down arena roguelite / short-run survival action game
- **Platform priority:** Mobile-first TapTap Maker prototype for Android phones/tablets and iPhone/iPad, with browser/PC keyboard support for development; GitHub is the collaboration and publishing repository
- **Current local project:** This directory (`TAPTAPGAME`)
- **GitHub target repository:** `Yunlong2601/SHENTECHSTUDIO`
- **Primary code location:** `scripts/`
- **Localization configuration:** `.project/i18n.json`
- **Translation files:** `i18n/`

## 2. Product Vision

Geometry Breakout is an original geometric survival game. The player controls a sentient geometric form inside an abstract digital arena, survives timed enemy waves, collects resources, chooses upgrades, and creates temporary combat builds from spatial modules.

The game must feel like an original geometric/synthetic IP, not a clone or reskin of any existing survivor-like game.

### Art style baseline

The canonical art style is **Neon Vector Geometry**. Future assets, prompts, UI polish, enemy silhouettes, boss designs, VFX, and placeholder art should follow `project-source/ART_STYLE.md`.

The style is geometry-first: triangles, hexagons, rings, shards, orbit lines, angular circuits, radial hazard marks, and polygon armor form the player, enemies, arena, and combat effects. The target is premium mobile survivor readability with a distinct sci-fi geometric identity.

### Core fantasy

> Engineer a powerful geometric combat build while the arena collapses around you.

### Product priorities

1. Readable combat
2. Fast restart and short runs
3. Meaningful build choices
4. Strong synergy between shape classes and modules
5. Clear English and Simplified Chinese support
6. Scope control and reliable iteration

## 3. Current Status

### Completed

- Bilingual language-selection UI prototype
- English and Simplified Chinese text tables
- Runtime language switching
- Simple interactive score prototype
- `.project/i18n.json` enabled for `en` and `zh_CN`
- Initial Lua LSP check performed on `scripts/main.lua`
- Initial UI style: dark synthetic interface with blue/purple background and gold accent

### Current implementation reality

The project now contains **Geometry Breakout Prototype 04 — Defense & Counter**, a UI-driven playable progression loop with state, player, module, enemy, and wave modules under `scripts/`.

Current prototype behavior:

- Choose English or 简体中文
- Move the geometric player with WASD/arrow keys on PC or a virtual touch joystick on phones and tablets
- Timed waves with between-wave calibration pauses
- Deterministic Chaser, Skimmer, and telegraphed Charger behaviors plus preserved elite core on every third wave
- Deterministic Compression, Surge, and Overclock arena modifiers per wave
- Automatic Trace Beam baseline attack with simultaneous Orbit Seed, Pulse Bloom, Shell Lantern, Anchor Mine, and Vector Hook combinations
- Data Fragment pickups with magnet attraction and collection
- Pattern Shard experience, level-up thresholds, and a three-choice calibration overlay (randomly shuffled from the eight available upgrade options per §11)
- **Six simultaneous modules** with level-3/5 evolution effects:
  - Trace Beam — narrow auto-tracking beam
  - Orbit Seed — rotating attack node
  - Pulse Bloom — periodic circular burst
  - Shell Lantern — rechargeable defensive shell that absorbs hits before Integrity
  - Anchor Mine — proximity mine that arms and detonates near enemies, blasting all in radius
  - Vector Hook — damaging movement trail that drops fading damage points behind the player
- Track Integrity, Shell, time, score, wave, modifier, data fragments, pattern shards, level, and all active module levels
- Session-safe Calibration Archive with starting Integrity and magnet upgrades; summary awards calibration currency once
- Contact damage routed Shell-first then Integrity; defeat state, restart, and run summary showing wave/score/level/module

### Not implemented yet

- Persistent storage-backed meta progression (storage API remains unverified; Prototype 03 uses a session fallback)
- Mobile phone/tablet/iPhone/iPad device pass beyond the current touch prototype
- Visual polish pass for the new modules (mine detonation vfx, hook trail fade curves)
- UI builders and HUD updates are extracted into `scripts/ui.lua`; `main.lua` is now orchestration-focused
- M1 combat feedback is implemented: damage numbers, hit flash, screen shake, Lv3/Lv5 evolution flash, and lightweight run telemetry (`state.runStats_`). Ten Mine + Hook + Shell playtests are recorded in `project-source/PLAYTEST_M1.md` and remain pending.

## 4. MVP Target

The first real playable milestone is **Geometry Breakout Prototype 01**.

### MVP acceptance criteria

```text
Launch game
→ Show Geometry Breakout / 几何突围
→ Choose English or 简体中文
→ Control one geometric chassis
→ Survive a combat wave
→ Automatically attack enemies
→ Enemies pursue and can be defeated
→ Enemies drop resources
→ Player collects resources
→ Player can die
→ Player can restart
```

### MVP content limits

- 1 playable chassis: **Vector Triangle**
- 1 arena
- 3 regular enemies
- 3 combat modules
- 3-choice upgrade screen
- 3 to 6 waves
- 1 elite enemy or simple boss
- 1 run summary screen
- English and Simplified Chinese UI

Do not expand to 12 chassis, dozens of modules, multiple bosses, or full meta progression until this loop is fun and stable.

## 5. Initial Game Vocabulary

| Chinese | English | Notes |
|---|---|---|
| 几何突围 | Geometry Breakout | Product title |
| 几何体 | Geometric Form | Playable entity category |
| 形态 / 底盘 | Chassis | Playable class; choose one term and keep it consistent in UI |
| 模块 | Module | Combat equipment |
| 波次 | Wave | Timed combat phase |
| 共振 | Resonance | Repeated-hit buildup and break effect |
| 结构 | Topology | Arena and structure interaction |
| 相位 | Phase | Intangibility/alternate-state system |
| 核心 | Core | Central player identity or boss element |
| 完整度 | Integrity | Primary health layer |
| 护壳 | Shell | Rechargeable defense layer |
| 不稳定度 | Instability | Risk/power pressure system |
| 数据碎片 | Data Fragment | Run economy currency |
| 模式碎片 | Pattern Shard | Run experience currency |
| 共振核心 | Resonance Core | Rare run resource |
| 校准台 | Calibration Deck | Between-wave upgrade interface |
| 突围 | Breakout | Run objective/theme; do not use generic “survive” as the only identity |

Avoid changing a term between English and Chinese translations unless the meaning genuinely changes.

## 6. MVP Build Order

### Phase 1: Rename and clean the prototype

- Replace Star Quest / 星星探险 with Geometry Breakout / 几何突围
- Remove obsolete star-click gameplay from the main flow
- Keep the bilingual language-selection architecture
- Consolidate all player-facing text into a clear localization source
- Keep old prototype code only if it is useful for reference

### Phase 2: Combat foundation

1. Create player geometric chassis
2. Implement top-down movement
3. Create one pursuing enemy
4. Implement player Integrity and damage
5. Implement one automatic attack
6. Implement enemy death
7. Implement player death and restart

### Phase 3: Wave and progression loop

1. Add timed waves
2. Add enemy spawn gates
3. Add Data Fragment and Pattern Shard pickups
4. Add level-up trigger
5. Add three-choice upgrade screen
6. Add three modules
7. Add wave-end transition

### Phase 4: Prototype finish

1. Add second and third enemy types
2. Add one elite
3. Add six-wave run structure
4. Add run summary
5. Add bilingual polish
6. Add debug controls
7. Verify on Maker preview and target devices

## 7. Suggested MVP Modules

1. **Trace Beam** — narrow auto-tracking beam — **implemented**
2. **Orbit Seed** — one rotating attack node — **implemented**
3. **Pulse Bloom** — periodic circular burst — **implemented**
4. **Shell Lantern** — rechargeable defensive shell — **implemented (2026-08-03)**
5. **Anchor Mine** — proximity mine that arms and detonates near enemies, blasting all in radius — **implemented (2026-08-03)**
6. **Vector Hook** — damaging movement trail that drops fading damage points behind the player — **implemented (2026-08-03)**

The first three were required for the initial build. Shell Lantern was added on 2026-08-03 as the first defensive module, balancing the all-offense lineup. Anchor Mine and Vector Hook were added the same day as Prototype 04 (Defense & Counter) to fill the §11 six-module target and round out the build with crowd control and passive offense. All six are now implemented across the modular runtime layer.

## 8. Collaboration Rules

### Source of truth

- Product direction and durable decisions: `project-source/PROJECT_CONTEXT.md`
- Active roadmap and milestone gates: `project-source/ROADMAP.md`
- Current architecture: `project-source/ARCHITECTURE.md`
- Canonical planning folder: `project-source/` (do not create parallel roadmaps)
- User gameplay code: `scripts/`
- Localization configuration: `.project/i18n.json`
- Translation tables: `i18n/`
- Engine documentation: `engine-docs/` (reference only)
- Examples/templates/libraries: reference only; do not modify unless explicitly required
- Generated/temporary files: keep out of user code and do not treat as design decisions

### Agent responsibilities

Before editing:

1. Read this file.
2. Check the current working tree.
3. Read the relevant engine documentation before using an unfamiliar API.
4. Check whether another agent has already changed the target file.
5. Keep changes focused and explain the files changed.

After editing:

1. Run local Lua LSP diagnostics when available.
2. Test the smallest relevant behavior.
3. Update this file only for durable decisions, not transient progress.
4. Report failures honestly.

### Do not do

- Do not silently rename the project again.
- Do not reintroduce Star Quest as the product identity.
- Do not expand scope before the MVP combat loop is playable.
- Do not edit `engine-docs/`, `examples/`, `templates/`, `urhox-libs/`, or `.emmylua/` as a substitute for changing user code.
- Do not use guessed UrhoX API names when documentation is available.
- Do not use generic Git commit/push/branch workflows for TapTap Maker build/submit requests. Follow the Maker workflow instructions.
- Do not treat GitHub publication as proof that the TapTap project built successfully.

## 9. TapTap Maker Workflow

For TapTap Maker work:

1. Check Maker project status first.
2. Keep code under the current Maker project directory.
3. Use `scripts/main.lua` as the current single-player entry unless the project configuration changes.
4. For build, preview, run, submit, or push requests, use the official Maker build workflow rather than generic Git commands.
5. Before building after Lua changes, run local Lua LSP diagnostics if available.
6. Do not change service environments for preview/build/test requests.

The current project previously reported a Maker project configuration gap and remote/local synchronization issues. Re-check live status before attempting a new build; do not infer readiness from this document alone.

## 10. GitHub Collaboration

Target repository:

```text
https://github.com/Yunlong2601/SHENTECHSTUDIO
```

GitHub is intended to hold shared project documentation and future source/data files for collaboration across agent platforms.

Recommended repository layout when the repository is initialized:

```text
Geometry-Breakout/
├── PROJECT_CONTEXT.md
├── README.md
├── docs/
│   ├── GAME_DESIGN.md
│   ├── ROADMAP.md
│   └── TERMINOLOGY.md
├── data/
│   ├── chassis.json
│   ├── modules.json
│   ├── enemies.json
│   ├── upgrades.json
│   └── waves.json
├── scripts/
├── localization/
│   ├── en.json
│   └── zh_CN.json
└── tests/
```

Do not assume GitHub has the newest local files. Confirm repository contents and permissions before syncing. If GitHub write access fails, continue local development and report the exact failure instead of claiming publication succeeded.

## 11. Near-Term Goals

### Goal A — Product identity

- [ ] Rename prototype UI to Geometry Breakout / 几何突围
- [ ] Freeze terminology
- [ ] Write a concise README and MVP design document

### Goal B — Playable combat

- [ ] Player movement
- [ ] One enemy
- [ ] One automatic attack
- [ ] Damage/death/restart
- [ ] First playable combat loop

### Goal C — Roguelite loop

- [x] Pickups
- [x] XP/level-up
- [x] Three upgrade choices (random three of eight per level-up, since Prototype 04)
- [x] Six modules: Trace Beam, Orbit Seed, Pulse Bloom, Shell Lantern, Anchor Mine, Vector Hook (extended from three → four with Shell Lantern, then to six with Anchor Mine + Vector Hook on 2026-08-03)
- [x] Timed waves
- [x] Elite encounter and run summary

### Goal D — Release readiness

- [ ] Bilingual UI complete
- [ ] Maker build verified
- [ ] Preview tested
- [ ] Mobile/browser layout checked
- [ ] Shared GitHub repository updated

## 12. Decision Log

### 2026-08-03 — Project renamed

The formal product name changed from the placeholder Star Quest concept to:

- **Geometry Breakout**
- **几何突围**

The game should focus on geometric survival, combat construction, and breakout from hostile arena conditions.

### 2026-08-03 — Art style baseline selected

The project selected **Neon Vector Geometry** as the canonical art direction. The style uses deep navy synthetic arenas, electric cyan player energy, magenta/red enemy pressure, teal alternate threats, orange-gold elites and bosses, restrained gold upgrades, violet sci-fi VFX, and crisp geometric silhouettes. `project-source/ART_STYLE.md` is now the durable source for future visual decisions and asset prompts.

### 2026-08-03 — M1-M10 milestone ladder established

The roadmap was expanded from a broad M1-M5 outline into a gated M1-M10 ladder: M1 combat feel, M2 content density, M3 buildcraft, M4 mobile/accessibility, M5 small meta progression, M6 visual/audio identity, M7 bosses/chapter structure, M8 retention/challenges, M9 technical publishing readiness, and M10 launch candidate. M1 remains active; later milestones are direction, not permission to skip playtest gates.

### 2026-08-03 — Demo-first milestone policy

Structured playtesting is no longer an early M1 blocker. The project will build a complete, monetizable TapTap demo prototype first, then use playtesting after the demo is ready for test launch. M1 is now demo foundation buildout, and TapTap commercial readiness is a required pillar before public test launch.

### 2026-08-03 — Scope decision

The project will prioritize a small playable MVP before large content expansion. One chassis, one arena, three modules, a few waves, and one elite/boss are sufficient for the first proof of fun.

### 2026-08-03 — Collaboration decision

This local directory is the active TapTap Maker project. The project will also be shared through `Yunlong2601/SHENTECHSTUDIO` for collaboration across multiple agent platforms. Local Maker readiness and GitHub publication are separate checks.

### 2026-08-03 — Prototype 03 systems pass

Prototype 03 established the mobile touch controls, deterministic enemy roles, per-wave arena modifiers, simultaneous modules with level-3/5 evolution, readable telegraphs, and a small non-essential Calibration Archive. The profile is intentionally an in-memory session fallback because no supported persistence API was verified.

### 2026-08-03 — Shell Lantern module added

The fourth module from the §7 roster, Shell Lantern, was added as the first defensive module. It absorbs hits before Integrity, recharges after a 2.6s − 0.3·level grace period at 0.8 + 0.2·level per second (plus +0.4/s at Lv3 evolution). Visuals: a gold ring around the player plus a dedicated HUD bar. i18n keys `module.shell`, `module.shell_desc`, `upgrade.shell`, `game.shell` added in both `zh_CN` and `en`.

### 2026-08-03 — Prototype 04 Defense & Counter

The fifth and sixth modules, Anchor Mine and Vector Hook, were added to close out the §7 six-module roster. Prototype 04 (Defense & Counter) pairs passive offense with crowd control:

- **Anchor Mine** — auto-places a mine at the player's current position on a 4.0 − 0.6·level second cooldown (faster at higher level). Each mine arms after 0.3s (0.15s at Lv3) and detonates when an enemy enters its proximity, damaging all enemies in the blast radius. Visuals: cyan diamond with a soft glow that brightens at detonation.
- **Vector Hook** — drops a damage point at the player's position every 0.10 − 0.02·level seconds (0.04s at Lv3) while the player is moving. Each point lives for 0.6 + 0.2·level seconds and fades with age. Visuals: small magenta dots that scale and dim over their lifetime.

In the same pass, the upgrade overlay switched from "show all available modules" to a 3-random Fisher-Yates shuffle of all eight upgrade options (the six modules plus Integrity and Magnet), matching the spec in §11 and keeping the screen readable as the module roster grew. `ApplyUpgrade` now accepts `trace | orbit | pulse | shell | mine | hook` as module-level triggers and falls through to the global-stat upgrades for `integrity | magnet`. New i18n keys: `module.mine`, `module.mine_desc`, `module.hook`, `module.hook_desc`, `upgrade.mine`, `upgrade.hook` in both `zh_CN` and `en`.

### 2026-08-03 — Prototype 02 progression loop

Prototype 02 keeps the UI-only, single-file scope while adding the first roguelite loop: collectible Data Fragments and Pattern Shards, level-up choices, three module behaviors, timed waves with calibration pauses, elite encounters, and a bilingual run summary. The local entry remains `scripts/main.lua`; no build or remote synchronization is implied by this milestone.

## 13. Definition of “Ready for Test-Launch Prototype”

The project is not ready for structured playtesting or public test launch until the demo feels like a real TapTap product, not only a systems prototype. Test-launch readiness requires:

- The title says Geometry Breakout / 几何突围.
- The player can select English or Simplified Chinese.
- The player controls a polished geometric chassis using the Neon Vector Geometry art baseline.
- At least three enemy roles, one elite, and one boss/proto-boss exist.
- The player can complete a full run path: start, fight, collect, upgrade, face an elite/boss, die or finish, see summary, restart.
- The demo includes readable VFX, damage feedback, module evolution feedback, and a coherent arena background.
- The demo includes session rewards and a clear progression surface.
- The demo has a documented TapTap monetization path, even if payment or reward APIs are not wired yet.
- Paid/cosmetic surfaces must not break core progression or create pay-to-win pressure.
- The player can die and restart.
- No known blocking Lua errors remain.
- The build or preview has been tested in the intended Maker runtime.

## 14. Immediate Next Action

The active milestone is **M1 — Demo foundation buildout** in `project-source/ROADMAP.md`. Prototype 03 (systems pass) and Prototype 04 (Defense & Counter) are both complete, and feedback instrumentation is already implemented. The remaining M1 work is now demo construction, not structured playtesting:

1. Build the complete demo loop: start, language, run, upgrades, waves, elite/boss, summary, restart, and session rewards.
2. Add or refine Neon Vector Geometry placeholders for Vector Triangle, core enemy roles, boss silhouette, module effects, and arena floor.
3. Add a first monetization-design placeholder surface, such as locked cosmetics/chassis skins or a support panel, without wiring payment APIs yet.
4. Verify damage numbers, hit flash, screen shake, shell bar, module effects, touch joystick, and upgrade overlay do not crowd small phone layouts.
5. Keep structured playtesting for the later test-launch prototype stage after the demo is complete enough to judge.

The project now has a demo-first M1-M10 milestone ladder. Keep the first meta progression and monetization surfaces deliberately small. Do not begin with twelve chassis, a giant shop, or platform payment/reward API work before the demo loop and TapTap requirements are clear.
