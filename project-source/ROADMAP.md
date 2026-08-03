# Geometry Breakout Roadmap

## End goal

Build the best original survivor-style game in its category: stronger build expression and replay depth than Brotato, clearer combat readability and mobile accessibility than Survivor.io, and a distinct geometric identity that is not a clone of either game.

This is an aspiration, not a promise of parity with mature commercial teams. Every phase must earn the next phase through playtest evidence.

## Current state — 2026-08-03

- Prototype 04, Defense & Counter, is playable and Maker build succeeds.
- Six modules are implemented: Trace Beam, Orbit Seed, Pulse Bloom, Shell Lantern, Anchor Mine, Vector Hook.
- Chaser, Skimmer, Charger, elite encounters, pickups, level-ups, three-choice upgrades, six waves, run summary, bilingual UI, and touch joystick are implemented.
- `scripts/state.lua`, `scripts/i18n.lua`, `scripts/player.lua`, `scripts/modules.lua`, `scripts/enemies.lua`, and `scripts/waves.lua` now hold the core runtime layers.
- UI builders are still partly in `scripts/main.lua`; the UI extraction is the next architecture cleanup.
- Persistence is not verified, device-matrix testing is incomplete, and combat feedback/content depth are below the long-term target.

## Product pillars

1. **Build expression:** every run creates a legible, synergistic build rather than a random pile of upgrades.
2. **Readable intensity:** the player can understand danger, damage, and reward on a small screen.
3. **Fast mastery:** a run teaches one new interaction at a time and restarts quickly.
4. **Original identity:** geometry, topology, resonance, and phase systems create experiences competitors do not own.
5. **Sustainable scope:** content is data-driven and testable before adding breadth.

## Milestones

### M0 — Architecture and truth-source cleanup (complete)

- Finished `ui.lua` extraction and reduced `main.lua` to orchestration.
- Keep behavior identical to Prototype 04.
- Make `project-source/` the only active planning source.
- Gate passed: Maker build passes; six-wave runtime path remains wired; no duplicate roadmap is active.

### M1 — Combat feel and retention proof (next)

- Add damage numbers, hit flashes, screen shake, module evolution bursts, and clearer telegraphs.
- Tune Mine + Hook + Shell combinations using at least 10 structured playtests.
- Add a lightweight run telemetry table: wave reached, build, damage taken, deaths, upgrade choices.
- Gate: testers can explain why they died and name their build; median first-run completion reaches wave 3.

### M2 — Content density prototype

- Add Splitter and Shooter enemies with distinct counter-play.
- Add the Glitch modifier and extend to waves 7–8.
- Add one mid-boss and one final boss only after M1 feedback is positive.
- Gate: eight-wave run has at least three viable builds and no single module dominates win rate.

### M3 — Buildcraft foundation (Brotato advantage)

- Add data-driven chassis definitions, beginning with Vector Triangle plus two contrasting chassis.
- Add eight stat axes and a small item pool; preserve clear module synergies.
- Add shop, reroll, salvage, and lock decisions between waves.
- Gate: 20-run sample shows materially different builds and at least five viable combinations.

### M4 — Meta progression and mobile quality

- Verify a supported persistence API; then add small permanent unlocks and research data.
- Complete phone/tablet/iPhone/iPad layout matrix and performance pass.
- Add accessibility options: text scale, color-safe telegraphs, reduced shake, left/right touch preference.
- Gate: no blocking layout defects on target matrix; repeat players understand the meta loop without documentation.

### M5 — Competitive polish and launch candidate

- Reach 12–16 meaningful modules, 6–8 chassis, 15+ enemy behaviors, 3 bosses, and a coherent chapter structure.
- Add daily challenge/seeded runs only after the core run is balanced.
- Add audio and visual identity where they improve feedback, not as decoration.
- Gate: external playtesters prefer the game’s build decisions and identity over a direct comparison run.

## Non-goals until M3

- No gacha economy, aggressive ads, giant shop, or dozens of shallow currencies.
- No large asset pass before combat readability is proven.
- No feature added without a measurable playtest or balance hypothesis.

## Weekly operating loop

1. Select one roadmap gate.
2. Make the smallest code/data change that tests it.
3. Build and playtest on Maker.
4. Record evidence and update `PROJECT_CONTEXT.md`.
5. Only then pull the next item from this roadmap.
