# Geometry Breakout Roadmap

## End goal

Build the best original survivor-style game in its category: stronger build expression and replay depth than Brotato, clearer combat readability and mobile accessibility than Survivor.io, and a distinct geometric identity that is not a clone of either game.

This is an aspiration, not a promise of parity with mature commercial teams. The current priority is to build a complete TapTap demo prototype first. Playtesting is a validation step after the demo is coherent enough to test, not a blocker before core game construction.

## Current state — 2026-08-03

- Demo Build is playable with Neon Vector Geometry visual pass, boss encounter, and monetization placeholder.
- Six modules are implemented: Trace Beam, Orbit Seed, Pulse Bloom, Shell Lantern, Anchor Mine, Vector Hook.
- Chaser, Skimmer, Charger, Splitter, Shooter, elite encounters, enemy projectiles, pickups, level-ups, three-choice upgrades, eight waves, boss fight, run telemetry, victory/defeat distinction, bilingual UI, and touch joystick are implemented.
- `scripts/state.lua`, `scripts/i18n.lua`, `scripts/player.lua`, `scripts/modules.lua`, `scripts/enemies.lua`, and `scripts/waves.lua` now hold the core runtime layers.
- UI builders and HUD updates are extracted into `scripts/ui.lua`; `main.lua` is orchestration-focused.
- Persistence is not verified, device-matrix testing is incomplete, and combat feedback/content depth are below the long-term target.

## Product pillars

1. **Build expression:** every run creates a legible, synergistic build rather than a random pile of upgrades.
2. **Readable intensity:** the player can understand danger, damage, and reward on a small screen.
3. **Fast mastery:** a run teaches one new interaction at a time and restarts quickly.
4. **Original identity:** geometry, topology, resonance, and phase systems create experiences competitors do not own.
5. **TapTap commercial readiness:** the demo must support a real monetizable path on TapTap before it is considered ready for public test launch.
6. **Sustainable scope:** content is data-driven and testable before adding breadth.

## Milestone Ladder

M2 is the active milestone. M3-M10 are locked as direction. For now, build readiness and TapTap commercial readiness are more important than playtest evidence. Playtests begin after the demo has enough content, polish, and monetization structure to represent the intended product.

### M0 — Architecture and truth-source cleanup (complete)

- Finished `ui.lua` extraction and reduced `main.lua` to orchestration.
- Keep behavior identical to Prototype 04.
- Make `project-source/` the only active planning source.
- Gate passed: Maker build passes; six-wave runtime path remains wired; no duplicate roadmap is active.

### M1 — Demo foundation buildout (complete)

- Add damage numbers, hit flashes, screen shake, module evolution bursts, and clearer telegraphs.
- Add a lightweight run telemetry table: wave reached, build, damage taken, deaths, upgrade choices.
- Add first-pass Neon Vector Geometry placeholders only where they improve combat readability.
- Add enough first-pass art, VFX, boss silhouette, arena background, and UI polish that the game looks like a deliberate demo rather than a systems prototype.
- Build a full local demo loop: start, language, run, upgrades, waves, boss/elite, summary, restart, and session rewards.
- Exit criteria: the demo loop is playable end-to-end, visually aligned with Neon Vector Geometry, and ready for internal build verification. No structured playtest evidence is required for M1.

Implementation status: M1 is complete. Feedback instrumentation, Neon Vector Geometry visuals, Core Breaker boss, run telemetry, victory/defeat distinction, and monetization placeholder are all implemented.

### M2 — Content density and first boss (active)

- Add Splitter and Shooter enemies with distinct counter-play.
- Add the Glitch modifier and extend to waves 7–8.
- Add one mid-boss and one final boss prototype.
- Add first arena background pass if it keeps the combat center readable.
- Exit criteria: an eight-wave run exists with regular enemies, at least one boss check, and visible enemy/module variety.

Implementation status: Splitter, Shooter, Glitch modifier, and 8-wave structure are implemented. The Core Breaker serves as the final boss at wave 8. A mid-boss for earlier waves is the next addition.

### M3 — Buildcraft foundation (Brotato advantage)

- Add data-driven chassis definitions, beginning with Vector Triangle plus two contrasting chassis.
- Add eight stat axes and a small item pool; preserve clear module synergies.
- Add shop, reroll, salvage, and lock decisions between waves.
- Exit criteria: three chassis, stat axes, item/shop decisions, reroll/salvage/lock, and at least five obvious build families exist in the demo.

### M4 — Mobile quality and accessibility

- Complete phone/tablet/iPhone/iPad layout matrix and performance pass.
- Add accessibility options: text scale, color-safe telegraphs, reduced shake, left/right touch preference.
- Tune touch joystick, HUD density, pause/restart flow, and upgrade-card readability on small screens.
- Exit criteria: no blocking layout defects on target phone/tablet/browser layouts; touch controls and HUD are usable without explanation.

### M5 — TapTap monetization foundation

- Verify a supported persistence API; then add small permanent unlocks and research data.
- Keep permanent power shallow: unlock options, starter variety, and convenience before raw stat inflation.
- Add run history summary and one non-essential long-term goal.
- Define the commercial model for TapTap: premium unlock, cosmetic purchases, rewarded monetization, or a hybrid. Do not implement platform monetization APIs until the TapTap configuration and policy requirements are verified.
- Add monetization-safe progression surfaces: cosmetic chassis skins, cosmetic trail colors, optional support/upgrade page, and clear separation between paid cosmetics and core power.
- Exit criteria: persistence survives app restart on target devices and the demo has a documented TapTap monetization path without pay-to-win pressure.

### M6 — Visual identity and audio pass

- Apply the Neon Vector Geometry style to player, core enemies, boss placeholders, module icons, VFX bursts, and main arena.
- Add audio only where it improves feedback: hit, pickup, level-up, shell break, boss telegraph, defeat, and upgrade selection.
- Keep generated assets in the Maker asset workflow and record source prompts in `ASSET_BRIEF_M1.md` or a successor asset brief.
- Exit criteria: player, enemy class, pickup, boss telegraph, upgrade rarity, and monetization/cosmetic surfaces are visually distinguishable in screenshots.

### M7 — Boss and chapter structure

- Add a coherent chapter cadence: early pressure, build expansion, mid-boss check, late density, final boss check.
- Add three bosses only after the first boss proves readable and fair.
- Give each boss a geometry theme, a counter-play rule, and at least two telegraphed attacks.
- Exit criteria: one complete chapter has a beginning, middle, final boss, reward flow, and a clear reason to restart.

### M8 — Retention and challenge systems

- Add seeded runs or daily challenge only after balance is stable.
- Add achievement-like Signal Medals and lightweight goals that reward mastery, not grind.
- Add difficulty modifiers or challenge routes that reuse existing systems before adding more content.
- Exit criteria: returning players have daily/weekly reasons to play without needing gacha or a large currency web.

### M9 — Technical readiness and publishing pipeline

- Stabilize Maker build, preview, and submission workflow.
- Add regression checks for localization keys, wave data, upgrade data, and performance-sensitive UI counts.
- Complete repository sync rules and release-note format.
- Verify TapTap commercial configuration, privacy/age-rating needs, store assets, purchase/reward policy, and any required SDK/API setup before code integration.
- Exit criteria: release candidate can be built, previewed, and documented from a clean checkout without undocumented manual steps.

### M10 — Launch candidate and live roadmap

- Reach 12–16 meaningful modules, 6–8 chassis, 15+ enemy behaviors, 3 bosses, and a coherent chapter structure.
- Add daily challenge/seeded runs only after the core run is balanced.
- Add audio and visual identity where they improve feedback, not as decoration.
- Prepare store art, app icon, screenshots, bilingual descriptions, privacy/age-rating notes, and known-issues list.
- Run structured playtests only here, after the demo is representative enough to evaluate.
- Exit criteria: launch build has no known blocking crashes, layout failures, untranslated core UI, or unresolved TapTap commercial-readiness blockers.

## Non-goals until M3

- No gacha economy, aggressive monetization, giant shop, or dozens of shallow currencies.
- No platform monetization API integration until TapTap configuration and policy requirements are verified.
- No structured balance playtest requirement before the demo is complete enough for test launch.
- No large content expansion that does not contribute to the playable demo loop.

## Current M2 Work Queue

1. Add a mid-boss encounter around wave 4 to break up the run pacing.
2. Tune Splitter and Shooter spawn rates and difficulty curve across waves 5–7.
3. Add visual feedback for the Glitch modifier (screen distortion, entity flicker).
4. Verify the HUD remains readable with enemy projectiles, splitter fragments, and glitch effects on screen.
5. Move structured playtesting to the test-launch prototype stage after the demo feels complete enough to judge.

## Weekly operating loop

1. Select the next demo-readiness gap.
2. Make the smallest code/data/art change that moves the game toward a complete TapTap demo.
3. Build or locally verify the changed path when practical.
4. Record durable decisions in `PROJECT_CONTEXT.md`.
5. Save structured playtesting for the test-launch prototype stage, not early construction.
