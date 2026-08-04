# Production Plan: Mid Phase to Monetization-Ready

**Date**: 2026-08-04
**Author**: Game Design / Production Planning
**Project**: Geometry Breakout / 几何突围
**Audience**: Solo developer, AI-assisted workflow, TapTap Maker ecosystem

---

## A. Diagnosis — Where the Project Is Now

Geometry Breakout has a working core loop — 6 modules, 5 enemy types, 8 waves, a boss, upgrade choices, bilingual UI, touch controls, run telemetry — sitting across ~2,500 lines of Lua in 9 files. M1 (demo foundation) is complete. M2 (content density) is approximately 30% done: R-05 (fragment cap) is done, but R-02 (weighted spawn) has wrong wave gating, R-03 (Glitch) is missing its core Poisson/corruption/flicker implementation, R-06 (dynamic enemy cap) has the field but never updates it from 24, and R-01/R-04 (both boss encounters) haven't been started. The M1 playtest sheet has **zero runs recorded** — you have systems, not evidence. The single biggest risk right now is not missing features; it's building more systems on top of a core loop that hasn't been proven fun through real playtests on a real device. The game is playable. It is not yet proven fun. That gap is the entire job.

---

## B. Do Now / Do Next / Do Later

### Do Now — This Week (Blocker: spawn system must be correct before anything else)

| # | Task | Requirement | Why It Blocks |
|---|------|-------------|---------------|
| 1 | Fix R-02 wave gating | Splitter at W3, Shooter at W5, Waves 1-2 Chaser+Skimmer only | Wrong spawn distribution invalidates all balance testing |
| 2 | Complete R-03 Glitch | Poisson λ≈0.18/s, corruption overlay on Compression/Overclock, flicker visuals, pulse cycle | Glitch is the W7 identity; without it, W7 is just "more enemies" |
| 3 | Fix R-06 dynamic enemy cap | 30 normal / 25 glitch, actually update `maxEnemies_` in `begin_wave()` | Hardcoded 24 means density tuning is impossible |
| 4 | Build and run on Maker preview after each fix | Verify no Lua errors, wave transitions work | You can't tune what doesn't run |

**Estimated effort**: ~16h (per the existing task package)

### Do Next — Weeks 2-4 (Boss encounters, wave tuning, UI feedback)

| # | Task | Requirement | Why It Matters |
|---|------|-------------|----------------|
| 5 | R-01 Mid-boss (W4 Gatekeeper) | HP=60, health bar, no modifier, guaranteed module drop | Gives the run a pacing break; W1-3 is too long without a checkpoint |
| 6 | R-04 Final boss 4-stage escalation | HP=300, 4 stages by time, arena compression at Stage 4 | The climax of the run; without it, W8 is just "harder W7" |
| 7 | R-07/R-08 Wave tuning | Overclock 1.25→1.15, W7 spawn reduction ~20% | Prevents W6-W7 back-to-back difficulty wall |
| 8 | R-09 Modifier Dock UI | Show active modifier + glitch badge on HUD | Players can't react to what they can't see |
| 9 | R-10 Glitch Badge animation | Pulse/blink synced to glitch active state | Reinforces the corruption feedback loop |
| 10 | R-11 Mid-boss intro flash | 500ms screen flash + warning text | Signals "this is different from a normal wave" |
| 11 | Real mobile device test | Run on actual phone, not just Maker preview | Touch joystick, HUD density, performance — all unknown until tested |

**Estimated effort**: ~44h (per existing task package Weeks 2-4)

### Do Later — Post-M2, Pre-Monetization (Prove the fun, then polish)

| # | Task | Why It Matters | When |
|---|------|----------------|------|
| 12 | Fill 10-run playtest sheet with REAL data | You have zero playtest evidence. This is the single most important deliverable before monetization. | Immediately after M2 content is stable |
| 13 | Balance pass: are all 6 modules useful? | If 2 modules are always-pick and 2 are never-pick, the upgrade system is broken | After 5+ playtest runs |
| 14 | Build variety audit: 3+ distinct build paths? | If every run feels the same, replayability is zero | After 10 playtest runs |
| 15 | Persistence verification | Storage API is unverified; using session fallback. Can't monetize meta progression without persistence | Before monetization planning |
| 16 | Performance check on target phone | 30+ fps with 30 enemies + glitch effects + flicker | Before closed test |
| 17 | Mobile layout polish | HUD readability on small screens, upgrade card sizes, touch zones | Before closed test |
| 18 | Restart motivation check | After death/defeat, does the player want to restart? Why? | During playtests |
| 19 | Minimal audio: hit, pickup, level-up, boss telegraph, defeat | Audio is a feedback channel, not decoration. Silence kills "game feel" | Before closed test |
| 20 | Data-driven content refactor (enemies, waves, modules → JSON) | Hardcoded Lua tables will bottleneck content iteration. But only after current content is proven | After playtests prove the content is right |

---

## C. Milestone Roadmap: Mid Phase to Monetization-Ready

### MS-1: M2 Content Density Finish (~3.5 weeks from now)

**Scope**: Complete all P0+P1 requirements (R-01 through R-11, fixing R-02/R-03/R-06 gaps)

**Gate criteria**:
- [ ] 8-wave run exists with: Chaser/Skimmer/Charger/Splitter/Shooter across correct wave tiers
- [ ] Mid-boss Gatekeeper spawns at W4 with health bar, no modifier, guaranteed drop
- [ ] Final boss has 300 HP, 4 escalation stages, no timer
- [ ] Glitch modifier uses Poisson, corrupts active modifier, shows flicker visuals
- [ ] Modifier Dock + Glitch Badge visible on HUD
- [ ] Dynamic enemy cap works (30 normal / 25 glitch)
- [ ] No blocking Lua errors in Maker preview

**Exit signal**: The 8-wave run is playable end-to-end with all content variety visible.

### MS-2: Polished MVP (~2 weeks after MS-1)

**Scope**: Mobile polish, balance first pass, minimal audio, performance check

**Gate criteria**:
- [ ] Tested on at least one real Android phone and one iPhone/iPad
- [ ] HUD readable on small screen (all elements visible, no overlap)
- [ ] Touch joystick responsive and doesn't fight the player
- [ ] 30+ fps with 30 enemies + glitch effects on target phone
- [ ] Minimal audio: hit, pickup, level-up, boss telegraph, defeat, upgrade select
- [ ] First balance pass: no module is obviously useless, no module is obviously dominant
- [ ] Restart flow is fast (<2s from death to new run)

**Exit signal**: The game feels like a deliberate mobile product, not a systems prototype.

### MS-3: Closed Test / Soft Test (~1.5 weeks after MS-2)

**Scope**: 10+ real playtest runs, record data, iterate on findings

**Gate criteria**:
- [ ] 10-run playtest sheet filled with real Maker preview data on mobile device
- [ ] Each run records: wave reached, death reason, damage taken, module levels, readability 1-5, build satisfaction 1-5
- [ ] Median wave reached is 5-6 (not too easy, not too hard)
- [ ] At least 3 distinct build paths observed across 10 runs
- [ ] Player can explain "what killed me" in ≥80% of deaths (readability proven)
- [ ] Restart rate after death: ≥60% of sessions restart immediately
- [ ] No blocking crashes
- [ ] At least 2-3 external testers (not just the developer) have played

**Exit signal**: You have evidence that the core loop is fun — or you have evidence of what's broken and needs fixing.

### MS-4: Retention Tuning (~2 weeks after MS-3)

**Scope**: Iterate on playtest findings, tune for replayability, verify persistence

**Gate criteria**:
- [ ] Playtest findings addressed (specific tuning changes based on data)
- [ ] Build variety confirmed: 3+ viable build families feel different to play
- [ ] Restart motivation is clear (player knows what they want to try differently)
- [ ] Persistence API verified — session state survives app restart on target device
- [ ] Session rewards feel meaningful (even if meta progression is shallow)
- [ ] Second round of playtests shows improvement on key metrics

**Exit signal**: The game is genuinely replayable — players want to restart, not just "finish once and delete."

### MS-5: Monetization Planning (~1 week after MS-4)

**Scope**: Define the commercial model, design monetization-safe surfaces, verify TapTap requirements

**Gate criteria**:
- [ ] Core loop is proven fun (MS-3 evidence)
- [ ] Game is replayable (MS-4 evidence)
- [ ] Persistence works on target devices
- [ ] Commercial model defined: premium unlock, cosmetic purchases, rewarded monetization, or hybrid
- [ ] Monetization surfaces designed: cosmetic chassis skins, cosmetic trail colors, optional support panel
- [ ] Clear separation between paid cosmetics and core power (no pay-to-win)
- [ ] TapTap commercial configuration requirements verified

**Exit signal**: You have a documented monetization plan that doesn't break the core loop. Only THEN do you implement platform payment/reward APIs.

---

## D. Top 10 Priorities (In Order)

| # | Priority | Rationale |
|---|----------|-----------|
| 1 | **Fix R-02/R-03/R-06 spawn system** | Everything downstream depends on correct spawn distribution. You can't balance a game with broken spawns. |
| 2 | **R-01 Mid-boss at W4** | An 8-wave run without a mid-point break is a flat difficulty curve. The Gatekeeper gives players a "checkpoint" feeling. |
| 3 | **R-04 Final boss 4-stage escalation** | The run needs a climax. A boss you kill in 9 seconds is not a climax. |
| 4 | **R-09/R-10/R-11 UI feedback (Modifier Dock, Glitch Badge, intro flash)** | Readability is a product pillar. If players can't see what's happening, they can't enjoy it. |
| 5 | **Real mobile device test** | You have touch controls but no evidence they work on a phone. This is the highest-risk unknown. |
| 6 | **Fill 10-run playtest sheet with real data** | Zero playtests = zero evidence. This is the single most important deliverable in the entire plan. |
| 7 | **Balance pass: module usefulness audit** | If 2 of 6 modules are dead picks, the upgrade system is broken and every run feels worse. |
| 8 | **Persistence verification** | You can't design meta progression or monetization without knowing storage works. |
| 9 | **Performance check on target phone** | 30 enemies + glitch flicker + corruption effects on a Lua/UI-driven engine. If it drops below 30fps, the game is unplayable. |
| 10 | **Build variety audit** | If every run produces the same build, replayability is zero and retention is zero. |

---

## E. Top 10 Things to Delay or Cut

| # | Feature | Verdict | Why |
|---|---------|---------|-----|
| 1 | Second arena / chapter | **Cut until first arena is proven fun** | One arena with 8 waves is enough to prove the fun hypothesis. A second arena doubles content production cost for zero validated return. |
| 2 | Chassis variety (M3: 3+ chassis) | **Cut until Vector Triangle is proven fun** | If one chassis isn't fun, three won't be either. Chassis variety is a retention feature, not a fun feature. |
| 3 | Shop / reroll / salvage economy (M3) | **Cut until upgrade choices are proven interesting** | You have a 3-choice upgrade screen. If that's not generating interesting decisions, adding shop/reroll is putting a band-aid on a broken bone. |
| 4 | Daily challenges / seeded runs (M8) | **Too early** | These are retention features for a game that has already proven it retains players. You haven't proven that yet. |
| 5 | Achievement / Signal Medals system (M8) | **Too early** | Same logic. Achievements reward mastery; you haven't proven the game supports mastery yet. |
| 6 | Full audio pass (M6) | **Delay — do minimal only** | Full audio is polish. Do 5-6 essential SFX (hit, pickup, level-up, boss telegraph, defeat, upgrade select) and nothing else until the game is proven fun. |
| 7 | Gacha / multi-currency economy | **Cut** | This is a solo dev game on TapTap. A gacha economy is a live-ops commitment you cannot sustain. |
| 8 | Platform monetization API integration | **Delay until model is defined** | Don't wire payment APIs until you know what you're selling and why. |
| 9 | More modules (beyond 6) | **Cut until 6 are proven to create build variety** | 6 modules with 8 upgrade options is plenty for a proof-of-fun demo. More modules = more balance surface = more things that can be broken. |
| 10 | Social features / leaderboards | **Cut** | Multiplayer/social is a different game. This is a single-player roguelite. Social features are scope creep of the worst kind. |

---

## F. Recommended Playtest Checklist

### Before You Start
- [ ] Build is stable in Maker preview (no blocking Lua errors)
- [ ] Test on a real mobile device, not just PC browser
- [ ] Use the existing 10-run sheet in `project-source/PLAYTEST_M1.md`
- [ ] Start with baseline: Vector Triangle, no archive upgrades

### Per Run (10 runs minimum)
- [ ] Record: device form factor
- [ ] Record: wave reached
- [ ] Record: death reason (be specific — "swarmed by Splitters" not "died")
- [ ] Record: damage taken
- [ ] Record: Mine Lv, Hook Lv, Shell Lv, and all other upgrade choices
- [ ] Rate readability 1-5
- [ ] Rate build satisfaction 1-5
- [ ] Note: first wave where danger became unclear
- [ ] Note: any moment you didn't understand what happened

### After 3 Runs — Early Signal Check
- [ ] Is median wave reached 5-6? (If <3, too hard. If every run reaches W8, too easy.)
- [ ] Did all 6 modules appear in upgrade choices? (If not, the shuffle is broken.)
- [ ] Was there any moment you felt "I don't know what killed me"? (Readability red flag.)

### After 5 Runs — Module Audit
- [ ] Were all 6 modules chosen at least once across 5 runs?
- [ ] Is there a module you NEVER pick? (If yes, it's a dead upgrade — needs redesign or tuning.)
- [ ] Is there a module you ALWAYS pick? (If yes, it's too dominant — needs nerf or competition.)

### After 10 Runs — Variety & Retention Check
- [ ] Did 3+ distinct build paths emerge? (e.g., "mine+shell tank", "hook+kite speed", "orbit+pulse AoE")
- [ ] Did you want to restart immediately after death in ≥6 of 10 runs?
- [ ] Could you explain what you'd do differently in the next run?
- [ ] Was there a moment that felt genuinely exciting or satisfying? (Write it down — that's your fun hypothesis validated.)

### Failure Signals (Stop and Fix If...)
- [ ] Median wave < 3 → difficulty is too high; reduce early enemy density
- [ ] Every run reaches W8 → difficulty is too low; increase W4+ density
- [ ] Player can't explain death → readability is broken; check feedback channels first
- [ ] Same 2-3 modules picked every run → upgrade system lacks meaningful choice
- [ ] Player doesn't want to restart → core loop lacks replay motivation; this is the worst signal

### Tuning Rules (from existing PLAYTEST_M1.md)
- If Mine contributes <15% of kills in 3 runs → reduce cooldown 0.3s or increase blast radius 8%
- If Hook causes >45% of kills or makes movement mandatory → increase trail spacing 0.02s
- If Shell absorbs <2 meaningful hits before W3 → reduce recharge delay 0.3s
- If Shell prevents all contact risk → increase delay 0.4s
- If median wave < 3 → reduce early enemy density 10%
- If every run reaches W6 → increase W4+ density 10%

---

## G. What Makes the Game Truly Ready to Start Monetization Planning

The game is ready to start monetization planning when **all** of the following are true:

### Fun Is Proven
1. **10+ real playtest runs** completed on a mobile device, recorded in the playtest sheet
2. **Median readability score ≥ 4/5** across playtest runs
3. **Median build satisfaction score ≥ 4/5** across playtest runs
4. **Player can explain "what killed me"** in ≥80% of deaths (readability is proven, not assumed)

### The Loop Is Complete
5. **Full run path works**: start → language → run → waves 1-8 → mid-boss → final boss → summary → restart, with no crashes
6. **Restart rate ≥ 60%**: players want to restart after death, not close the app
7. **3+ distinct viable build paths** observed in playtests (different upgrade choices lead to different play experiences)

### Technical Foundation Is Solid
8. **Persistence verified**: session/meta state survives app restart on target device
9. **Performance stable**: 30+ fps on target phone with 30 enemies + glitch effects
10. **No blocking Lua errors** in Maker preview build
11. **Mobile layout has no blocking defects**: HUD readable, touch responsive, upgrade cards visible on small screens

### The Product Feels Deliberate
12. **One complete arena/chapter** feels good start to finish — not just "systems working" but "a real game experience"
13. **Minimal audio feedback** is present (hit, pickup, level-up, boss telegraph, defeat)
14. **Neon Vector Geometry art style** is consistent across player, enemies, boss, arena, UI

### What You Do NOT Need Before Monetization Planning
- ❌ You do NOT need a second arena
- ❌ You do NOT need multiple chassis
- ❌ You do NOT need a shop/gacha system
- ❌ You do NOT need daily challenges or achievements
- ❌ You do NOT need platform payment APIs wired
- ❌ You do NOT need social features

You need proof that one arena, one chassis, six modules, and eight waves create a fun, replayable experience. If that's not true, monetization is premature. If it IS true, monetization should be lightweight: cosmetic skins, cosmetic trail colors, and an optional support panel — nothing that touches core power.

---

## Summary: The One Sentence That Matters

**Before you monetize, you need to prove that a player who dies on wave 6 wants to immediately restart and try a different build — not because the game told them to, but because they're genuinely curious what would happen if they picked Mine first instead of Shell.**

If that sentence is true, you have a game worth monetizing. If it's not, no amount of monetization design will fix it.

---

## Appendix: Assumptions & Risks

### Assumptions
- TapTap Maker engine supports dynamic arena boundary adjustment (R-04 Stage 4 compression) — **unverified**
- `UI.Panel` system supports alpha animation and timer callbacks (R-10/R-11 flicker effects) — **assumed from existing hit flash implementation**
- Current Lua runtime handles 30 enemies + 3 concurrent flickers + Glitch corruption overlay — **untested on mobile**
- Solo developer can commit ~20h/week to implementation — **assumed from workflow pattern**

### Key Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Glitch corruption is architecturally new (R-03) | High — could break modifier system | Start with conservative λ=0.15/s; test modifier interaction matrix before full implementation |
| Final boss 4-stage balance (R-04) | High — could make W8 too hard or too easy | Implement Stage 1+2 first, playtest, then add 3+4; 3-stage fallback if 4 doesn't work |
| Mobile performance with 30 enemies + effects | Medium — could make game unplayable on low-end phones | Test on real device ASAP; reduce particle count if needed |
| Persistence API unverified | Medium — blocks meta progression and monetization | Verify before MS-4; session fallback is acceptable for playtests but not for launch |
| Zero playtest data | Critical — all balance assumptions are unvalidated | Fill the 10-run sheet as the #1 priority after M2 content is stable |
