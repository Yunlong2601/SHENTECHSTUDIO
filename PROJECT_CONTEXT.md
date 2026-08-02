# Geometry Breakout / 几何突围

> Shared project context for TapTap Maker development and collaboration across AI agent platforms.
>
> Last updated: 2026-08-03
>
> This file is the project-level source of truth for product direction, current status, workflow boundaries, and collaboration rules. Update it when a durable project decision changes.

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

The project now contains **Geometry Breakout Prototype 02**, a UI-driven playable progression loop built in the single-file local entry script.

Current prototype behavior:

- Choose English or 简体中文
- Move the geometric player with WASD/arrow keys on PC or a virtual touch joystick on phones and tablets
- Timed waves with between-wave calibration pauses
- Deterministic Chaser, Skimmer, and telegraphed Charger behaviors plus preserved elite core on every third wave
- Deterministic Compression, Surge, and Overclock arena modifiers per wave
- Automatic Trace Beam baseline attack with simultaneous Orbit Seed and Pulse Bloom combinations
- Data Fragment pickups with magnet attraction and collection
- Pattern Shard experience, level-up thresholds, and a three-choice calibration overlay
- Three simultaneous modules: Trace Beam, Orbit Seed, and Pulse Bloom, with level-3/5 evolution effects
- Track Integrity, time, score, wave, modifier, data fragments, pattern shards, level, and all active module levels
- Session-safe Calibration Archive with starting Integrity and magnet upgrades; summary awards calibration currency once
- Contact damage, defeat state, restart, and run summary showing wave/score/level/module

### Not implemented yet

- Persistent storage-backed meta progression (storage API remains unverified; Prototype 03 uses a session fallback)
- Mobile phone/tablet/iPhone/iPad device pass beyond the current touch prototype

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

1. **Trace Beam** — narrow auto-tracking beam
2. **Orbit Seed** — one rotating attack node
3. **Pulse Bloom** — periodic circular burst
4. **Anchor Mine** — proximity mine
5. **Vector Hook** — damaging movement trail
6. **Shell Lantern** — rechargeable defensive shell

The first three are required for the initial build. The others can be added after the core loop works.

## 8. Collaboration Rules

### Source of truth

- Product direction and durable decisions: this file
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
- [x] Three upgrade choices
- [x] Three modules
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

### 2026-08-03 — Scope decision

The project will prioritize a small playable MVP before large content expansion. One chassis, one arena, three modules, a few waves, and one elite/boss are sufficient for the first proof of fun.

### 2026-08-03 — Collaboration decision

This local directory is the active TapTap Maker project. The project will also be shared through `Yunlong2601/SHENTECHSTUDIO` for collaboration across multiple agent platforms. Local Maker readiness and GitHub publication are separate checks.

### 2026-08-03 — Prototype 03 systems pass

Prototype 03 keeps the single-file UI architecture and mobile touch controls while adding deterministic enemy roles, per-wave arena modifiers, simultaneous modules with level-3/5 evolution, readable telegraphs, and a small non-essential Calibration Archive. The profile is intentionally an in-memory session fallback because no supported persistence API was verified.

### 2026-08-03 — Prototype 02 progression loop

Prototype 02 keeps the UI-only, single-file scope while adding the first roguelite loop: collectible Data Fragments and Pattern Shards, level-up choices, three module behaviors, timed waves with calibration pauses, elite encounters, and a bilingual run summary. The local entry remains `scripts/main.lua`; no build or remote synchronization is implied by this milestone.

## 13. Definition of “Ready for First Playtest”

The first playtest is ready when:

- The title says Geometry Breakout / 几何突围.
- The player can select English or Simplified Chinese.
- The player controls a geometric chassis.
- At least one enemy can damage the player.
- At least one module can defeat enemies.
- The player can collect a resource.
- The player can make one upgrade choice.
- The player can die and restart.
- No known blocking Lua errors remain.
- The build or preview has been tested in the intended Maker runtime.

## 14. Immediate Next Action

Prototype 02 has been built successfully in Maker and now includes a mobile virtual joystick. The next development focus is a mobile-first Prototype 03 systems pass:

1. Add readable skimmer and charger enemy behaviors.
2. Add deterministic arena modifiers per wave.
3. Replace the single selected module with true simultaneous module combinations.
4. Add level-based module evolution.
5. Add a small permanent Calibration Archive for meta progression.
6. Re-run Maker preview validation on Android phone/tablet and iPhone/iPad-sized layouts.

Keep the first meta progression deliberately small and non-essential to winning a run. Do not begin with twelve chassis, a full shop, or a large asset pass.
