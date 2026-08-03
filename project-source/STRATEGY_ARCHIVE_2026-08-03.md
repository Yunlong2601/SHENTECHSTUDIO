# Geometry Breakout — Strategic Plan

**Project:** Geometry Breakout / 几何突围
**Author:** 许清楚 (Xu) — Product Manager, Software Company team (Qi / 齐活林, Delivery Director)
**Date:** 2026-08-03
**Audience:** ShenYunLong (solo dev, decision-maker)
**Status:** Partial workflow — PM stage only. No code, no architecture, no tests in this document.
**Engine reality:** TapTap Maker + Urhox Lua, UI-only (NanoVG + Yoga Flexbox), single-file `scripts/main.lua` (926 lines / 1500-line split threshold = 62%), bilingual en + zh_CN, mobile-first.
**Reading time:** ~35 minutes. This is the reference document for the next ~9 months.

---

## Table of Contents

1. Executive Summary (TL;DR)
2. What You've Achieved (chronological milestones)
3. Current State — Honest Assessment
4. Competitive Analysis — Side-by-Side
5. Strategic Direction — Two Paths, Pick One
6. Roadmap — 4 Phases with Spec Sketches
7. Success Metrics
8. Risks and Open Decisions
9. Recommended Next Step
- Appendix A — File Split Plan (preview)
- Appendix B — Vocabulary reminders
- Appendix C — What NOT to do (recurring traps)
- Appendix D — One-page "What is Geometry Breakout?" recap
- Appendix E — Module Spec Sketches (Phase 2)
- Appendix F — Stat Axes Spec (Phase 2)
- Appendix G — Item Roster Spec (Phase 2)
- Appendix H — Chassis Roster Spec (Phase 2)
- Appendix I — Enemy Roster Spec (Phase 1+2)
- Appendix J — Boss Spec Sketches (Phase 1)
- Appendix K — Difficulty Curve Spec
- Appendix L — Shop UI Mockup (text)
- Appendix M — Audio Asset List (Phase 3)
- Appendix N — Device Matrix Checklist (Phase 3)
- Appendix O — Daily Challenge + Meta Progression Spec (Phase 4)
- Appendix P — Per-Phase Risk + Rollback Plan
- Appendix Q — Balance Tuning Heuristics

---

## 1. Executive Summary (TL;DR)

You have shipped a playable MVP in roughly two weeks of focused dev — Prototype 04 is a complete core loop (move → auto-attack with 6 simultaneous modules → upgrade between waves → die → restart) with deterministic enemy roles, per-wave modifiers, and session-only meta progression. The single biggest strategic decision you must make this week is **Path A (Brotato-style: short premium runs, build variety, shop between waves, paid/IAP-light)** vs. **Path B (Survivor.io-style: short free runs, hyper-casual dopamine, gacha + heavy ads/IAP)**. **My recommendation is Path A**, scoped to what is realistic for a solo dev on TapTap Maker — the engine constraints (UI-only, no verified persistence API, no asset pipeline) and platform reality (TapTap users tolerate premium but punish ad-heavy gacha) both push against Path B. The single biggest gap to close is **build depth**: one chassis, six modules, three enemy types — that produces a fun prototype but not a 10-hour game. Close that gap first; everything else (art, audio, polish, persistence, leaderboards) is Phase 3+ and can be sequenced once the build system is interesting enough to replay.

---

## 2. What You've Achieved

Chronological timeline of shipped work since the project rename on **2026-08-03**. Every entry has a date, a one-line description, and a **size** tag (S/M/L) measuring dev effort relative to your pace.

| Date | Milestone | Size | Notes |
|---|---|---|---|
| 2026-08-03 | Project renamed from Star Quest placeholder → **Geometry Breakout / 几何突围**. Identity and core fantasy frozen in `PROJECT_CONTEXT.md`. | S | One-line commit + doc update; strategically important. |
| 2026-08-03 | `PROJECT_CONTEXT.md` written (~370 lines) as project-level source of truth — identity, MVP, build order, vocabulary, decision log. | M | This document is doing structural work — it prevents agents from reinventing scope. Good. |
| 2026-08-03 | `i18n.json` enabled for `en` + `zh_CN`; inline `TEXT` table mirrored into `i18n/en.json` + `i18n/zh_CN.json`; language-selection screen + runtime language switching. | M | Bilingual from day one is unusual discipline for a solo dev. Pays off later. |
| 2026-08-03 | Initial movement + WASD/arrow keys + virtual touch joystick. | S | Joystick for mobile + keyboard for PC covers both target surfaces. |
| 2026-08-03 | Vector Triangle chassis (only chassis so far). | S | Single chassis MVP, correct scope discipline per `PROJECT_CONTEXT.md` §4. |
| 2026-08-03 | First enemy (Chaser) + auto-attack (Trace Beam) + first module (Trace Beam). | M | This is the **minimum playable seed**. |
| 2026-08-03 | Chaser damage + enemy death + player death + restart loop. | S | The "die → restart" was in early — that's the right instinct. |
| 2026-08-03 | Prototype 02 progression layer: Data Fragment pickups + Pattern Shard XP + level-up + 3-choice upgrade overlay + 3 modules (Trace Beam / Orbit Seed / Pulse Bloom) + timed waves + calibration pause + elite encounter + run summary. | L | A full roguelite loop in one pass. Significant. |
| 2026-08-03 | Prototype 03 systems pass: deterministic enemy roles (Chaser / Skimmer / Charger with telegraph) + per-wave arena modifiers (Compression / Surge / Overclock) + 3-random Fisher-Yates upgrade shuffle + simultaneous modules with Lv3/Lv5 evolution + Calibration Archive (session-only meta). | L | The enemies got readable telegraphs; modifiers add wave-to-wave variety. |
| 2026-08-03 | Shell Lantern (4th module) shipped — rechargeable defense layer above Integrity. Tuning: 2.6s − 0.3·level grace, 0.8 + 0.2·level regen, +0.4/s at Lv3. Gold ring visual + dedicated HUD bar. | M | First defensive module; rebalances what was an all-offense roster. |
| 2026-08-03 | **Prototype 04 — Defense & Counter**: Anchor Mine (proximity mine, arm + detonate, blast) + Vector Hook (damaging movement trail). 6 simultaneous modules complete. | L | Closes the §7 six-module target. Mine + Hook crowd-control combo tested. |
| 2026-08-03 | File growth: 792 → 926 lines. Still well under the 1500-line split threshold (62%). | — | Tech-debt early warning showing in §3.3 below. |

**Pattern (honest read):** small consistent steps, roughly one substantial prototype per day. No heroic leaps. This is the right pace for solo dev on a constrained engine; it's also a **ceiling** — if shipping one large prototype per day continues, a 9-month roadmap (per §6 below) means ~180 prototypes which is too many for what's left to build. Phase 4 will require big content dumps (chassis roster + item roster + daily challenge pool), not more prototypes.

**What's notable about this list:** every date is 2026-08-03. The project moved fast in one burst — that's a feature (you have momentum and a working MVP) and a risk (no breathing room between prototypes has not yet been stress-tested by a real device, real user, or a day without code touching). Phase 1 deliberately slows the cadence to ~3 prototypes/week to leave room for validation (§6 Phase 1 success metric).

---

## 3. Current State — Honest Assessment

### 3.1 What's working well (the core loop is in)

- **The core loop is end-to-end playable.** Move → auto-attack with six simultaneous modules → collect pickups → choose upgrade → die → restart → see summary. That loop closes, and that is rarer than it sounds for a UI-only Lua prototype. Most "dead" TapTap prototypes never reach this stage.
- **Six simultaneous modules with Lv3/Lv5 evolution** is a real mechanic, not a checkbox. The Mine + Hook stacking, the Shell-before-Integrity routing, the TeleBeam tracking — these are tuning handles that produce different run-feels per build. The evolution curve is wired but mechanically under-expressed (see §3.3).
- **Deterministic enemy roles** (Chaser / Skimmer / telegraphed Charger) make combat readable. The telegraphed Charger is especially strong — it teaches the player to dodge by reading. This is the right base for the Splitter and Shooter enemies in Phase 1.
- **Per-wave arena modifiers** (Compression / Surge / Overclock) add wave-to-wave variance without adding enemies. This is a clever way to get variety cheaply. The Glitch modifier (Appendix I) is the natural 4th.
- **3-random Fisher-Yates upgrade overlay** from the eight total upgrade options (six modules + Integrity + Magnet) keeps the choice screen readable as content grows. This decision matters for Phase 2 — it scales to 18 modules + 2 globals + 8 stats cleanly.
- **Bilingual from day one** with a real language-selection screen. Most TapTap indies ship English-first and bolt on Chinese later; you shipped both first-try. This costs you nothing and differentiates the prototype.
- **Touch joystick for mobile + WASD/arrow for PC** in one input layer. Both surfaces covered. The PC keyboard exists for dev velocity; no need to release on PC.
- **Single-file discipline** preserved at 926 lines; below the 1500-line split threshold so refactor cost is still cheap. The planned split (Appendix A) avoids a coerced refactor.
- **Solid project context** in `PROJECT_CONTEXT.md` — vocabulary, MVP scope, decision log. Multiple agents can collaborate against it without re-litigating basics.
- **Calibration Archive as non-essential meta.** Starting Integrity + starting Magnet rewards pattern-shard XP across runs *without* being load-bearing. Correctly architected for future persistence bolt-on.

### 3.2 What's rough (the "this looks prototype-y" list)

- **One chassis (Vector Triangle).** No chassis variety means every run plays the same regardless of which modules you pick, because the chassis doesn't add a multiplicative layer on top of the build. This is the #1 build-depth gap.
- **No persistent storage API verified.** Calibration Archive is a session-only fallback. Players lose meta progress on every app close. Fine for a prototype; disqualifies the game from commercial launch as-is. **Phase 1 spike needed.**
- **UI-only visuals.** All six modules use flat NanoVG shapes with no sprite art, no screen-shake, no damage numbers, no camera punch. The mechanics are good; the feel is functional, not juicy. Phase 1 deliverable partly fixes this.
- **No SFX, no music.** Silent game. Even placeholder geometric beeps would 5x the perceived quality. Phase 3 deliverable; cost is low if you source from a zero-license library.
- **No art direction.** Every visual is geometric abstraction; this is consistent but also anonymous. There's no "this is Geometry Breakout" recognizable silhouette. Decide later (§8.2 decision #4) — staying geometric is *defensible*, not an apology.
- **Three enemy types + one elite.** At wave 6 the player has seen everything the enemy roster offers. Wave 7+ would just be reskinned Chasers. **Phase 1 deliverable.**
- **No multi-stage boss.** Elite = bigger Chaser. There is no encounter in the game that requires the player to think differently; the elite just has more HP and hits harder. **Phase 1 deliverable.**
- **No shop.** Only upgrade overlay. No buy/sell, no reroll, no economy depth. The overlay is the right UI shell but missing the SPEND element. **Phase 2 deliverable.**
- **No items / equipment / pets.** Six modules cover one half of Brotato's build system; the other half (passive stat items) is missing. **Phase 2 deliverable.**
- **No mobile device validation.** The joystick and HUD shell widget have not been physically tested on Android phone / tablet / iPhone / iPad. The second HUD bar added in Prototype 04 may overlap with the joystick on small screens — you won't know until someone runs it on a real device. **Phase 3 deliverable.**
- **No daily / weekly challenges, leaderboard, social, sharing.** No replay hook for those who finish wave 6. **Phase 4 deliverable.**
- **No monetization.** No thought given to how this game pays for the dev time. Path A vs. Path B is partly a monetization decision. **Decision #3.**
- **Six waves, no cadence beyond.** `PROJECT_CONTEXT.md` §14 already flags this — waves 7 / 8 are mentioned as a target but not built. **Phase 1 deliverable.**

### 3.3 Technical debt

- **`scripts/main.lua` at 926 / 1500 lines (62%).** You have ~574 lines of headroom. Any single Phase 2 module that adds 100+ lines will start brushing the threshold. **Rule of thumb:** if Phase 2 adds 6 new modules (Appendix E), that's ~600 more lines → you'd cross 1500 around the 3rd new module and the AGENTS.md rule #13 / §3.3 mandates a split. Plan the split in Phase 2 (Appendix A), not after. Don't split now — splitting too early kills your iteration speed.
- **No test suite.** Zero automated tests; the validation loop is "I ran it in the Maker preview and it looked right." For a game with a 6-wave run + 8 upgrade options + 3 enemy types + 4 modifiers + 6 modules + simultaneous interactions, the state-space you can manually cover is small. Phase 3 needs a small headless smoke-test harness, even if it's 30 lines of Lua that exercises pure functions (damage formulas, evolution curves, spawn timing).
- **No persistence API verified.** The whole Calibration Archive is a session-only in-memory map. If the Maker storage API is never verified, Phase 4 launch is blocked. This is a Phase 0/1 spike.
- **Visual polish debt.** Mine detonation VFX is "basic", hook trail fade is "basic", shell flash is "basic" — your own words from `PROJECT_CONTEXT.md` §3 (current implementation reality). Lv3/Lv5 evolution visuals are mechanical only — no aura, no particle burst, no screen feedback. This compounds: the player can't *see* that their build evolved beyond the HUD bar growing.
- **i18n is inline + JSON-mirrored.** Every new string must be added in two places. This works at 80 keys; it stops working at 300+. Phase 3 should consolidate to JSON as the single source of truth and drop the inline `TEXT` table. Cost: ~2 hours of mechanical work.
- **Unknown performance ceiling on lowest-target phone.** Up to ~40 widgets for shell + trace trail per the `PROJECT_CONTEXT.md` §14 note. Never measured. Phase 3 deliverable: 60fps on a 4-year-old Android phone or explicit acceptance that the game targets newer devices only.
- **No remote synchronization infrastructure.** GitHub target `Yunlong2601/SHENTECHSTUDIO` is "the collaboration repo," but there is no pipeline that proves Maker builds = GitHub pushes. Per the `PROJECT_CONTEXT.md` §9 / `AGENTS.md` rules: do not treat GitHub publication as proof of Maker build success.
- **No design tokens.** Colors (gold, cyan, magenta, purple) are literal hex scattered through the file. If the palette needs to shift in Phase 3, this becomes a find-and-replace nightmare. Cheaper to centralize now (Appendix F-token reference) before further content adds more literal colors.
- **No onboarding tutorial.** First-time players get dropped into wave 1 with no guidance. This costs you D1 retention (see Phase 4 KPI). A 3-screen tutorial adds < 1 prototype's worth of work and pays back across the whole life of the product. **Phase 3 deliverable.**
- **No accessibility consideration beyond bilingual.** Color-only telegraphs (purple = Charger, etc.) exclude colorblind players. Surplus detail for Phase 4+, but note it now so new enemy / module additions don't deepen the gap.

---

## 4. Competitive Analysis — Side-by-Side

| Dimension | Geometry Breakout (current, 2026-08-03) | Brotato (2023, Blobfish, premium $5) | Survivor.io (2022, Habby, free-to-play hyper-casual) | Geometry Breakout target by **end of Phase 4** (≈ month 9) |
|---|---|---|---|---|
| **Combat modules / weapons** | 6 simultaneous, Lv3/Lv5 evolution. One chassis. Player holds all 6 always. | 6 simultaneous slots, auto-fire. 60+ weapons across 5 classes. Stats determine damage, not level-ups. | 100+ weapons, 6 slots, **combine 2 max-level → evolved form** (Lv8 style), pet system on top. | **12–18 modules** with deeper Lv evolution curves. Item system adds ~12 passive stat items. Total ~24 build pieces. |
| **Chassis variety** | 1 (Vector Triangle). | **50+ unlockable characters**, each with a unique passive + stat spread. | 1 body; visual customization via gacha skins. | **6–8 chassis** with distinct stat profiles + 1 passive each. TapTap-friendly scope. |
| **Enemy variety** | 3 (Chaser, Skimmer, Charger) + elite. **No boss.** | 20+ enemy types + boss every 5 waves. | 20+ enemy types + stage boss. | **7–8 enemy archetypes** (incl. ranged, summoner, splitter) + **2 multi-stage bosses** (mid + final). |
| **Boss system** | Elite every 3rd wave = bigger HP/damage. No phases. | Boss at wave 5 / 10 / 15 / 20, each with attack patterns. | Stage boss every ~2 min with screen-clearing telegraph. | **Wave-3 mini-boss + wave-8 multi-phase boss** with telegraphed attack pattern and weak-point brief invulnerability window. |
| **Progression depth** | 6 modules + 2 global upgrades + Integrity / Magnet. Session-only meta. | 10+ stats (MaxHP, HPRegen, Speed, Damage, AttackSpeed, CritChance, Dodge, Armor, Luck, ...). Item system interacts. 20-wave run with shop every wave. | Run-and-pray dopamine. 100+ weapons + evolutions + pets + equipment. Forever-scaling difficulty. | **8 stat axes** (MaxHP, HPRegen, Speed, Damage, AttackSpeed, CritChance, Dodge, Luck). **Item system** replaces or augments module roster. **Persistent meta** with 2–3 currencies. |
| **Visual polish** | Flat NanoVG geometric shapes; no sprite art; no particles; no screen-shake; no damage numbers; no evolution VFX. | Pixel art, readable silhouettes, screen-shake on hit, particle bursts on crit, damage numbers. | VFX-heavy, every hit has a number pop, every kill has a screen-shake, every 30s has a special VFX. | **Damage numbers, screen-shake, particles on crit/evolve, 1 camera punch on boss entry.** Still geometric — *not* pixel art. SFX layer (placeholder beeps OK). |
| **Audio** | None. | Full OST + SFX layer. | Full OST + SFX + dopamine audio stingers. | **Placeholder SFX (zero-licensed or self-made beeps) + 2 looping ambient tracks** (geometric). Not commercial-grade, but not silent. |
| **Monetization** | None. | Premium $5 one-time. No ads. No IAP. | Free, heavy rewarded ads + IAP + gacha. | **Premium unlock $2–$5** (no ads) **OR** freemium with cosmetic-only IAP (no power-for-pay). Pick this in decision #3. |
| **Run length** | ~3–6 min depending on survival. 6 waves. | 20–30 min. 20 waves. | 2–5 min. Runs until death; no between-wave pause. | **8–12 min**. 8 waves. Matches the "session-length KPI" below. |
| **Target platform** | Mobile-first (Android + iPhone/iPad) + PC keyboard for dev. | PC + mobile + console. | Mobile only. | Same as now: **mobile-first**. Do **not** expand to PC release until Phase 4 success metrics are met. |
| **Code footprint** | 926 lines / single file / Lua. No art pipeline. | ~150 KLOC + art pipeline + multiple tools. | ~200 KLOC + massive content data tables + analytics pipeline. | **~2000–2500 lines / 2–3 Lua files** (after the planned split when crossing 1500). **No** art pipeline. **No** backend beyond what TapTap Maker ships. |

### 4.1 One-line "where you stand" notes per row

- **Modules.** You're at the bottom of the depth curve. The mechanic is in; the volume isn't. Six modules × three enemies × one chassis = your replay ceiling today.
- **Chassis.** You ship one. Brotato's magic is the *multiplication* of chassis × module × stat — you don't have it. One chassis means runs vary by build, not by character.
- **Enemies.** Three plus an elite is enough to prove the loop; nowhere near enough to sustain an 8-wave run where each wave adds 2–3 new enemy types.
- **Bosses.** An elite is not a boss. This is your single most-feeling "this game is small" gap. The Resonance Core (Appendix J) is your opening to fix it.
- **Progression.** Eight upgrade options × 6 waves × 6 simultaneous modules × 1 chassis × 1 arena = your replay-space ceiling. Run a few dozen times and you've seen everything.
- **Visual polish.** Functional, not juicy. This is the cheapest QoL improvement you can ship (damage numbers + screen-shake = 1 prototype).
- **Audio.** A silent game is a half-built game. Even three beeps would change perception. Two ambient loops + ten geometric SFX is one prototype in Phase 3.
- **Monetization.** Zero today. Hard to plan around; see decision #3.
- **Run length.** 3–6 min today ≈ Survivor.io cadence. To grow toward 8–12 min ≈ Brotato cadence you need either more waves (cheap) or denser waves (expensive).
- **Platform.** Correctly aimed. Don't widen it.
- **Code footprint.** Your code footprint is your strategic advantage — you can iterate fast. This is the *one* advantage Brotato and Survivor.io don't have. Protect it: don't gold-plate.

### 4.2 Mirror Brotato for [X], learn from Survivor.io for [Y], avoid [Z]

- **Mirror Brotato for** the *stat axis system* (MaxHP / HPRegen / Speed / Damage / AttackSpeed / CritChance / Dodge / Luck) — currently you only have Integrity and Magnet as globals. Adding 6 more passive stats is cheap (Appendix F) and unlocks the item system that makes every run feel different.
- **Mirror Brotato for** the *between-wave shop* — your Calibration overlay is already there; renaming it to Shop (Appendix L) and adding a "spend Data Fragments to reroll choices / buy a guaranteed module" makes the economy feel less passive.
- **Mirror Brotato for** the *short-but-deep run length* (8–12 min) — your current 6-wave run is too short to support the build depth you're about to add.
- **Mirror Brotato for** the *chassis-as-passive-multiplier* pattern. A chassis in Brotato is a stat profile + 1 passive. Don't try to ship 50; ship 6 with one passive each (Appendix H).
- **Learn from Survivor.io for** the *evolution visual punch* — when a weapon hits Lv3 or Lv5, the screen should pulse: glow + size + color shift + a brief 0.2s slowmo on hit. Cheap NanoVG effects; outsized feeling.
- **Learn from Survivor.io for** the *dopamine feedback loop* — damage numbers rising, score popups, an "incoming wave" voice-line substitute (a screen edge flash + bass beep). Every 10s the player should *feel* the build.
- **Learn from Survivor.io for** the *single-screen readable chaos* — your top-down arena framing already supports this.
- **Learn from Survivor.io for** the *frequent small rewards* — Data Fragments and Pattern Shards drop continuously already; the lesson is to give them a visible pickup animation + pickup SFX in Phase 3, not a different drop system.
- **AVOID Brotato's** *50-character unlock treadmill* — TapTap users won't grind for 50 chassis; 6–8 is enough.
- **AVOID Brotato's** *100+ item bloat* — 12–20 items is the solo-dev max.
- **AVOID Brotato's** *multi-stat items without clear identity* — every item in your game should be describable in one sentence ("+CritChance + Shooter module-tag synergy"). If you can't describe it in one sentence, throw it out.
- **AVOID Survivor.io's** *gacha + heavy IAP + ads* — TapTap's audience and your solo bandwidth cannot support this. Plus the engine doesn't ship an ad SDK.
- **AVOID Survivor.io's** *forever-scaling difficulty* — your 8-wave cadence gives players a win condition. Don't remove it for "infinite runs"; that's a different game.
- **AVOID Survivor.io's** *VFX overload* — even with NanoVG particles, matching Survivor.io's pixel-density VFX is impossible. Aim for *clean* and *readable*, not *dense*.
- **AVOID Survivor.io's** *combine-to-evolve mechanic* — the Lv-evolution curve you already have is simpler and works. Don't ship two evolution systems.

---

## 5. Strategic Direction — Two Paths, Pick One

### Path A — Brotato-style (short premium runs, build variety)

- **Run length:** 8–12 min, **8 waves**.
- **Between waves:** Shop (replaces/augments your Calibration overlay).
- **Progression:** 12–18 modules with deeper Lv curves + 12–20 passive stat items + chassis-as-passive-multiplier (6–8 chassis, not 50).
- **Build variety:** stat axes (MaxHP / HPRegen / Speed / Damage / AttackSpeed / CritChance / Dodge / Luck) make item combos multiply.
- **Bosses:** wave-3 mini-boss + wave-8 multi-phase final boss.
- **Monetization:** **Premium unlock $2–$5** OR **freemium cosmetic IAP** (no power-for-pay). No ads.
- **Run outcome:** death ends the run → summary → meta-progression rewards.
- **Visual:** stay geometric (UI-only). Strong NanoVG. Borrow Survivor.io's *evolution punch* (glow / screen-flash / damage numbers), never its *VFX density*.
- **Audio:** placeholder SFX (self-made geometric beeps) + 2 ambient loops.
- **Content depth:** 12–18 modules × 6–8 chassis × 12–20 items × 7–8 enemy types × 2 bosses = meaningfully replayable.
- **Replica of Brotato's magic:** every run feels like a different puzzle because build-stat interactions matter.

### Path B — Survivor.io-style (short free runs, hyper-casual dopamine)

- **Run length:** 2–5 min, **single continuous run until death**.
- **Between waves:** none. Health pickups + level-ups only.
- **Progression:** 30–60 modules with combine-2-max-Lv evolution system (Lv8-style). Fewer stats; more weapons.
- **Build variety:** weapon slots are the only depth axis. Pets & equipment as separate layer.
- **Bosses:** every ~2 min a stage boss. Scaling: enemies scale with time, never stop.
- **Monetization:** **Free + rewarded ads + IAP gacha**. Heavy.
- **Run outcome:** death is the only checkpoint. Runs are infinite.
- **Visual:** VFX-heavy, numbers-popping, screen-shaking, particles-raining.
- **Audio:** punchy stings on every meaningful event.
- **Content depth:** weapon catalog + boss catalog + pet catalog.
- **Replica of Survivor.io's magic:** every 10s feels rewarding; numbers keep going up.

### 5.1 Recommendation

**Path A — Brotato-style, scoped for solo dev on TapTap Maker.**

Five reasons, in priority order:

1. **Engine constraint.** TapTap Maker + Urhox Lua is UI-only with no verified persistence API, no asset pipeline, no analytics, no ad SDK. Path B's monetization (ads, gacha, IAP server) and Path B's asset needs (pixel art, dense VFX, character skins) all require infrastructure you do not have and cannot build in the time available. Path A's monetization (single $2–$5 IAP) is achievable through whatever paid-unlock mechanism TapTap Maker exposes.
2. **Solo-dev ceiling.** At your shipping pace (~1 large prototype per day historically), Path B's 30–60 modules with combine-evolution + 20 enemy types + boss every 2 min + pets + equipment is ~12 months of full-time work just for content, before polish. Path A's 12–18 modules + 12–20 items + 7–8 enemy types + 2 bosses fits in ~4–6 months at your pace.
3. **Platform fit.** TapTap's user base skews toward premium indie (similar to Steam, lite); hyper-casual ads + gacha do worse on TapTap than on global app stores. Path A monetizes via a single IAP, which TapTap supports cleanly.
4. **Existing leverage.** Your current prototype is closer to Path A than Path B. You already have between-wave calibration pauses — those become shop screens with one UI change. You already have 6 simultaneous modules with Lv3/Lv5 evolution — Path A needs more modules, not a different shape.
5. **Run-length KPI compatibility.** A 3–6 min run today ≈ Survivor.io cadence. To make the game feel premium and intentional, you want 8–12 min ≈ Path A's target. Going the other direction (shorter, more screens) is harder than adding waves.

### 5.2 What to borrow from Survivor.io on Path A

- Evolution visual punch at Lv3 and Lv5 (screen flash + size + color shift + slowmo brief).
- Damage numbers (rising floats on every hit).
- "Wave incoming" screen edge flash + bass beep.
- Rapid-fire "things are getting crazy" feedback in late waves.
- Frequent small pickups with visible animation + SFX.

### 5.3 What to AVOID from Path B even on Path A

- **No gacha.** Even cosmetic-only gacha is a different game.
- **No infinite scaling.** 8 waves means a definitive run.
- **No ads.** Even rewarded ads cheapen a $5 product.
- **No pet system.** Tab between pets is a UI surface that costs dev time; skip in v1.
- **No "evolve by combining two max-Lv weapons."** Use the Lv-evolution curve you already have; the Survivor.io combine mechanic is a separate system.

### 5.4 What to AVOID from Path A even though you're going A

- **50 chassis is Brotato's signature but it's wrong for solo dev.** Stop at 6–8 (Appendix H).
- **100 items is also wrong.** Cap at 20 (Appendix G).
- **20 waves is wrong for mobile run length.** Cap at 8.

---

## 6. Roadmap — 4 Phases with Spec Sketches

Each phase has a timeframe, goals, deliverables, success metric, and effort estimate (solo-dev weeks). Spec sketches for the headline deliverables live in Appendices E–J.

### Phase 1 — Content Density (2–3 weeks)

**Timeframe:** 2026-08-04 → ~2026-08-25

**Goals:**

1. Close the *three enemy types* gap that makes wave 7+ feel like reskinned Chasers.
2. Add the *first true boss* so wave 3+ has a distinct encounter.
3. Stretch the run from 6 → 8 waves so build depth has somewhere to land.
4. Add a 4th arena modifier for wave-to-wave variety.
5. Add the cheapest visual-feedback upgrades (damage numbers, screen-shake, evolution glow) so late-evolution hits *feel* late-evolution.
6. Run the **persistence API spike** (Decision #5) to determine whether Phase 4 is feasible.

**Deliverables:**

| # | Deliverable | Size | Notes / spec |
|---|---|---|---|
| 1 | Enemy type 4: **Splitter** — splits into 2 smaller versions on death. | M | Appendix I. First prototype. |
| 2 | Enemy type 5: **Shooter** — stationary, ranged shots on a telegraph. | M | Appendix I. |
| 3 | Mini-boss at wave 3: **Spire** — stationary core with rotating shield segments; exposes a 1.5s weak-point window. | L | Appendix J. |
| 4 | Final boss at wave 8: **Resonance Core** — three phases (chase → summon → beam-sweep), each 15s. | L | Appendix J. |
| 5 | Wave 7 + Wave 8 wired in (existing 1–6 cadence unchanged). | S | Mostly data changes; verify difficulty curve (Appendix K). |
| 6 | 4th modifier: **Glitch** — for 3s every 8s, the player phase-shifts (intangible) and any enemy overlapping takes damage. | M | Appendix I. Cheap mechanic; feels different from Compression / Surge / Overclock. |
| 7 | Damage numbers (rising floats, gold + crit-flash). | S | Borrowed from Survivor.io. Highest ROI visual change for solo dev. |
| 8 | Screen-shake on boss hit / wave-clear / evolution. | S | Cheap to implement; outsized feel. |
| 9 | Lv3 + Lv5 evolution visual glow on each module (size + color shift + brief 0.2s flash). | M | Closes the "evolution is mechanical but invisible" gap from §3.3. |
| 10 | Persistence API spike — discover whether TapTap Maker exposes a stable storage API. Update `PROJECT_CONTEXT.md` §12 with findings. | S | This is **the** Phase 1 blocker for Phase 4. |
| 11 | Onboarding tutorial re-eval — does wave 1 teach *enough* to keep the player alive past wave 2? Note findings; defer the tutorial itself to Phase 3. | S | Research, not delivery. |

**Success metric (KPI to track):** **Average wave reached per run > 5** (today the player usually dies at wave 4–5 because there's nothing past wave 6; wave 7–8 should still be reachable but rare). If Phase 1 ships correctly, this number drops slightly from "everyone dies at 4–5" to "a quarter of players reach the mini-boss, a tenth reach the final boss."

**Effort:** 2–3 solo-dev weeks (~5 prototypes at your current pace). Risks: boss AI is the most expensive item in this list — keep both bosses' phase transitions hard-coded, not data-driven, for Phase 1.

### Phase 2 — Build Depth (4–6 weeks)

**Timeframe:** ~2026-08-25 → ~2026-10-10

**Goals:**

1. Multiply the *build space* from ~6 modules × 2 globals → **18 modules + 8 stat axes + 12 items + 6 chassis**.
2. Add an *item system* that interacts with module behavior, not just stats.
3. Add *chassis variety* so each run has a multiplicative layer (chassis passive × module picks × item picks).
4. Cross the 1500-line single-file threshold deliberately and split the file in a controlled refactor (Appendix A).
5. Ship a *shop system* between waves that turns the Calibration overlay into an economy (Appendix L).
6. Move toward *persistent storage* based on the Phase 1 spike outcome.

**Deliverables:**

| # | Deliverable | Size | Notes / spec |
|---|---|---|---|
| 1 | **6 new modules**: Phase Lance, Drone Squadron, Gravity Well, Mirror Shot, Frost Patch, Arc Node. Each with Lv3/Lv5 evolution. | L (6 × M) | Appendix E. Add in pairs (1 offensive + 1 utility) to keep balance manageable. |
| 2 | **8-stat axis system**: MaxHP / HPRegen / Speed / Damage / AttackSpeed / CritChance / Dodge / Luck. Replaces Integrity + Magnet globals. | L | Appendix F. Inverts existing system; design carefully. Migration path: keep Integrity + Magnet as legacy aliases for one prototype. |
| 3 | **12 passive stat items**: e.g. Capacitor Coil (CritChance), Phase Insulator (Dodge), Recursive Loop (AttackSpeed), etc. Each item has 1–2 stat tags + a niche passive. | L | Appendix G. Half the build diversity comes from here. |
| 4 | **5–6 additional chassis**: Cube, Hex, Ring, Prism, Doublet, Lance. Each with 1 passive. | L | Appendix H. This is where Path A's signature magic lands. |
| 5 | **Shop system** between waves (replaces Calibration overlay; upgrade 3-choice still available inside). Buy: reroll (cost: 5 fragments), single fixed-tier module (cost: 25), heal (cost: 8). | M | Appendix L. Economy levers unlocked here give the player agency inside the upgrade loop. |
| 6 | **File split**: `scripts/main.lua` → `scripts/main.lua` (entry) + `scripts/state.lua` (player/modules) + `scripts/entities.lua` (enemies/bosses) + `scripts/ui.lua` (HUD/overlays/i18n) + `scripts/waves.lua` + `scripts/design.lua`. | M | Appendix A. Planned, not coerced by 1500-line breach. |
| 7 | **Persistence implementation** (if Phase 1 spike found an API): Calibration Archive upgrades persist across sessions; chassis unlocks persist. | M–L | TBD by Phase 1 outcome. If no API, this becomes a known blocker for Phase 4 launch. |
| 8 | **First balance pass**: after 6 new modules + stats + items + chassis, run 50 sim-runs and record average build win-rate. Adjust outliers. | M | Appendix Q. No automated harness yet; manual harness OK. |

**Success metric (KPI to track):** **Build-diversity entropy** (Shannon entropy of module-combo fingerprints across 100 player runs or 100 simulated runs). Target: > 3.0 nats. If entropy stays low, your build space is too narrow — players are converging on 1–2 dominant strategies.

**Effort:** 4–6 solo-dev weeks. The file split, the stat axis, and the new chassis each warrant ~1 prototype. This is the largest phase by line count but mostly mechanical — the design decisions are already made.

### Phase 3 — Polish & Audio (2–3 months)

**Timeframe:** ~2026-10-10 → ~2026-12-31

**Goals:**

1. Make every existing mechanic *feel* like it works. Damage numbers, screen-shake, evolution glows, particle bursts — already started in Phase 1, completed here.
2. Add *audio*: SFX (geometric, self-made beeps if no composer) + 2 ambient loops.
3. Validate on *real mobile devices* — Android phone (low-end), Android tablet, iPhone, iPad. Identify and fix layout overlap bugs (the second HUD bar from Prototype 04 is your suspected offender).
4. Confirm *60fps on the lowest target phone* or accept a smaller device target list.
5. Tighten the *evolution visual* layer: each Lv3 + Lv5 evolution gets a unique VFX (not just glow + size).
6. Add a *headless smoke-test harness* for pure-function modules (damage formulas, evolution curves, spawn timing).
7. Consoli­date *i18n* into JSON as single source of truth, drop the inline `TEXT` table.
8. Centralize *design tokens* (colors / sizes) before further polish pass creates a palette problem.
9. Ship a minimal onboarding tutorial.

**Deliverables:**

| # | Deliverable | Size | Notes / spec |
|---|---|---|---|
| 1 | **SFX pass**: ~12 SFX (hit, crit, level-up, module-evolve, boss-hit, wave-clear, run-end, button-tap, pickup, etc.). Source: self-made geometric beeps or zero-license SFX library. | M | Appendix M. Even ugly beeps beat silence. |
| 2 | **2 ambient loops** (combat calm + combat climax). 30s + 30s, seamless. Source: same as SFX. | M | Appendix M. Geometric pulse / drone, not music. |
| 3 | **Per-module evolution VFX** (Lv3 + Lv5). 6 modules × 2 evo stages × bespoke VFX = 12 hand-tuned effects. | L | Appendix M. Each gets a unique fingerprint. |
| 4 | **Damage numbers + score popups** polish (already added in Phase 1, polished here). | S | Already 80% done. |
| 5 | **Screen-shake library** with intensity tiers (light / medium / heavy). | S | Used by boss hits, wave-clear, evolution. |
| 6 | **Mobile device validation**: 4-device matrix runs with checklist (Appendix N). | M | Block launch until this is green. |
| 7 | **Performance pass**: profile widget count, identify bottlenecks (Shell + trace trail are suspects), reduce if needed. | M | 60fps target on lowest-spec phone. |
| 8 | **Headless smoke-test harness**: Lua script that runs damage formulas, spawn timing, evolution curves outside the engine and reports differences. ~200–400 lines. | M | Long-term debt payback; covers ~20% of state-space. |
| 9 | **i18n consolidation**: every UI string in JSON; inline `TEXT` table removed. | S | Mechanical. |
| 10 | **Design tokens**: `scripts/design.lua` with all colors / sizes / durations centralized. | S | Mechanical. |
| 11 | **Onboarding tutorial** (3 screens, optional, fast). | M | Adds retention. Show only on first launch. |
| 12 | **Color-blind mode** pass — add a non-color telegraph to enemy telegraphs (e.g. shape, motion, position). | M | Frees ~5% of the potential audience. Cheap. |

**Success metric (KPI to track):** **Crash-free session rate > 99%** on the validated device matrix. Also: **TapTap preview build completes** without errors.

**Effort:** 2–3 solo-dev months. Mostly incremental polish across many small files; the boss VFX and audio are the heaviest items.

### Phase 4 — Meta & Launch (3–4 months)

**Timeframe:** ~2027-01-01 → ~2027-04-30

**Goals:**

1. Ship *persistent meta progression* (decision #5 outcome).
2. Ship *daily challenge* + *leaderboard*.
3. Soft-launch on TapTap behind a beta flag.
4. Decide + ship *monetization* (decision #3 outcome).
5. Hit D1 / D7 retention targets (§7).
6. Begin *community iteration loop* — use TapTap comments + in-game feedback to triage Phase 5.
7. TapTap rating ≥ 4.2 by end of Phase 4.

**Deliverables:**

| # | Deliverable | Size | Notes / spec |
|---|---|---|---|
| 1 | **Persistent storage** (if not already in Phase 2). Calibration Archive upgrades persist across sessions; chassis unlocks persist. | L | If no API is verifiable, fall back to local file via Maker's fs (if available) or surface this as a launch blocker. |
| 2 | **2–3 meta currencies**: Calibration Credits (currency), Pattern Memory (chassis unlock), Resonance Tokens (premium / IAP). | M | Solo dev cannot support more than 3 currencies. |
| 3 | **Meta-progression tree**: small unlock tree per chassis (e.g. +1 passive tier at milestones 5/10/25 runs). | M | Appendix O. Gives players a reason to come back without PvP. |
| 4 | **Daily challenge**: fixed seed (deterministic enemy layout + modifier + chassis) with a 24-hour leaderboard. | L | Appendix O. Solo dev daily content is hard; pre-generate a 30-day pool and rotate. |
| 5 | **Leaderboard**: per-chassis + global best wave / score / time. Anti-cheat: server-side only on the runs TapTap validates; client-trusted otherwise. | L | If TapTap Maker supports native leaderboards, prefer that. |
| 6 | **Soft-launch**: 2-week closed beta via TapTap Maker beta-flag; target ≥ 100 sessions. | M | Don't go public before D1 retention data. |
| 7 | **Monetization implementation**: decision #3 outcome. Premium unlock $2–$5 OR cosmetic IAP. | M | Do *not* ship without monetization unless the game is a hobby project. |
| 8 | **Crash analytics + event funnel integration** (whatever TapTap Maker exposes). | M | Required to measure the §7 KPIs. |
| 9 | **TapTap store listing** assets: 5 screenshots, 30-second gameplay video, localization pass on store description (en + zh_CN). | S–M | Block soft-launch until this is done. |

**Success metric (KPI to track):** **D1 retention > 25%, D7 retention > 8%** (hyper-casual benchmarks). Path A targets premium players, so expectations are higher than casual — D1 > 30% / D7 > 12% is realistic if the build depth is right.

**Effort:** 3–4 solo-dev months. Soft-launch + monetization are the longest-lead items.

---

## 7. Success Metrics

Four to six KPIs across the project. Each one is something you can actually measure with what's available; suggestions in parentheses for *how* to measure.

| KPI | Target | When | How to measure |
|---|---|---|---|
| **Session length** (average play session, including restart) | **8–12 min** by end of Phase 1; stabilize at 8–12 min in Phase 2. | Phase 1 onward. | (a) TapTap Maker analytics if exposed. (b) Custom session timer in `scripts/main.lua` writing to log on run-end → read via `adb logcat` scraping. (c) Manual timing during playtest. |
| **Retention D1** | **> 25%** by mid-Phase 4. | Phase 4 onward (needs persistence + day boundaries). | TapTap Maker analytics; for prototype: count unique session IDs per day from the log fallback. |
| **Retention D7** | **> 8%** by end of Phase 4. | Phase 4. | Same as D1; rolling window. |
| **Average wave reached per run** | **> 5 by Phase 1; > 6 by Phase 2.** Should plateau ≈ 6.5 (most players don't beat the boss). | All phases. | Trivially logged at run-end. |
| **Build-diversity entropy** (Shannon entropy of module-combo fingerprints across 100 runs) | **> 3.0 nats** by end of Phase 2; > 3.5 nats by Phase 3. | Phase 2 onward. | Hash (sorted module Lv tuple) per run → count frequencies → Shannon. Most rigorous metric that validates "every run feels different." |
| **Crash-free session rate** | **> 99%** on validated device matrix by end of Phase 3. | Phase 3. | TapTap Maker analytics + manual device matrix runs. |
| **TapTap rating (only meaningful after soft-launch)** | **> 4.2** stars by end of Phase 4. | Phase 4. | Direct from TapTap. |

### 7.1 What this metric stack tells you

- **Session length drifts < 6 min:** your waves are too short or too easy. Add density, not waves.
- **Session length drifts > 15 min:** your build space is too narrow (players can't close a run) — that's a *build depth* failure, not a content failure. Symptom: lots of long runs but lots of "I died on wave 6 because nothing worked."
- **Wave-reached plateaus < 4:** your difficulty curve is wrong. Tune enemy HP and damage (Appendix K).
- **Build-diversity entropy stays < 2.5 nats:** your build space is too small — you have 18 modules but players pick the same 6. Either add more modules or increase the ones players *don't* pick through stat items.
- **D1 retention < 15%:** your onboarding is bad or your game doesn't deliver its fantasy in the first 60 seconds.
- **D7 retention < 5%:** the daily loop isn't pulling players back. Phase 4 daily challenge is the lever.
- **Crash-free < 98%:** don't launch. Fix the crash first.

### 7.2 Don't track (vanity metrics)

- Total downloads (vanity).
- Total play time (vanity).
- Revenue per user (only meaningful in Phase 4+).

---

## 8. Risks and Open Decisions

### 8.1 Top 5 Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| 1 | **Engine ceiling — UI-only Lua can't ship commercial VFX density.** NanoVG particles beyond ~200 widgets-per-frame start to drop frames on low-end Android. Survivor.io-style VFX is unreachable. | **High** | High | Stay geometric; cap concurrent VFX widgets at ~150; trade VFX density for VFX *cleanness*; use screen-shake and color shifts as cheap feel-multipliers. Appendix Q. |
| 2 | **Scope creep — feature list grows past solo bandwidth.** Adding 6 modules + 8 stats + 12 items + 6 chassis in Phase 2 is *already* ambitious for a single dev. | **High** | High | Lock scope at end of Phase 1 design doc. No "while I'm here" additions during Phase 2. Time-box each Phase 2 module to ≤ 1 prototype; if it spills, drop the module from v1. |
| 3 | **No verified persistence API.** Phase 4 needs persistent meta. If Maker doesn't expose a stable API, you can't launch a save-able game. | **Medium** | Critical | Triage this in Phase 1 (decision #5 + persistence spike). If no API by end of Phase 2, fall back to local file (whatever TapTap's `fs` exposes) or treat as launch blocker. |
| 4 | **Art debt — 6 months in, the game still looks like wireframes.** Designers/engineers will tell you "feasible"; players will tell you "ugly" in the rating. | **Medium** | Medium | Centralize design tokens now (Appendix F reference). Define a stricter NanoVG visual language: every enemy has 3 keyframes of "wind-up" motion; every module has 1 signature VFX. Stay geometric but commit to consistency — don't grow visual elements ad-hoc. **Do not** hire an artist on speculation. If the game launches and the rating demands art, fund it from revenue. |
| 5 | **Mobile device fragmentation — iPad layout differs from iPhone, Android tablets differ again.** The second HUD bar from Prototype 04 has not been physically tested. | **High** | Medium | Phase 3 device-matrix validation is non-optional (Appendix N). Test on: 1 low-end Android phone, 1 mid Android, 1 iPhone, 1 iPad minimum. Document layout per device. Block launch on green. |

### 8.1.1 Secondary risks (worth naming, not worth detailing)

- **Burnout.** Two weeks at one-prototype-per-day pace is a sprint, not a marathon. Phase 1 deliberately slows to ~3/week.
- **TapTap Maker platform changes.** The engine is in alpha/beta per `PROJECT_CONTEXT.md` §9. API changes could invalidate Phase 2 work. Mitigation: keep persistence and module code in plain Lua, not custom engine APIs.
- **GitHub repo drift.** `Yunlong2601/SHENTECHSTUDIO` is the collab target but doesn't reflect the live project. Keep `PROJECT_CONTEXT.md` honest about what's actually in the codebase.
- **i18n drift between en/zh_CN.** Add to your vocabulary table on the same day you add the concept.

### 8.2 Top 5 Decisions (must be made by user)

| # | Decision | Options | Default if no choice | When needed |
|---|---|---|---|---|
| 1 | **Which strategic path?** | **A (Brotato-style)** vs. B (Survivor.io-style). | **A** — recommended above, scoped to solo dev. | This week. |
| 2 | **Solo or find collaborators?** | Solo (current pace, ~1 prototype / day). Solo + 1 audio contributor (cheap; high value for Phase 3). Solo + 1 artist (expensive; only if budget allows). Full team (not realistic on TapTap Maker). | **Solo + 1 audio contributor for Phase 3.** | Before Phase 3 starts. |
| 3 | **Monetization model?** | Premium $2–$5 one-time unlock. Freemium cosmetic IAP (no power). Free + ads + IAP (Path B; not recommended). Hobby (no monetization). | **Premium $2–$5 unlock.** | Before Phase 4 launch design. |
| 4 | **Art direction?** | Stay geometric (current). Add pixel-art sprites (requires art pipeline). Hire artist for character art. | **Stay geometric; commit to a stronger NanoVG visual language (damage numbers, evolution glow, screen-shake) before considering sprite work.** | Phase 3. Decision can be deferred to post-launch. |
| 5 | **Persistence approach?** | TapTap Maker cloud (if API exists). Local device storage (via Maker `fs`). Continue session-only (launch blocker for Path A 4-Phase plan). | **TapTap cloud if available; local file as fallback; session-only rejected as Phase 4 launch blocker.** | **Phase 1 week 1 (persistence spike).** This decision gates Phase 4. |

**Decision priority order:** #1 → #5 → #3 → #2 → #4. #1 is this week. #5 is Phase 1. #3 is Phase 4 design. #2 is Phase 3. #4 is optional.

---

## 9. Recommended Next Step

One clear "do this next" with a 1-week deliverable.

> **Implement enemy type 4 — Splitter — by next Friday (2026-08-08).**

**The deliverable in detail:**

- New enemy: Splitter. On death, spawns 2 mini-Splitters (60% HP, 70% damage, smaller collision radius).
- Add to wave 3+ spawn pool; first appear at wave 3 (paired with the existing Charger).
- Add i18n keys `enemy.splitter` + `enemy.splitter_desc` in both `en.json` + `zh_CN.json`.
- Update `scripts/main.lua` if under 1500 lines; otherwise split first (Appendix A).

**Why this first (not boss, not module, not stat axis):**

- It's a self-contained 1-prototype change. No architecture decisions block it.
- It teaches the player that enemies can *create* new enemies — a mechanic pattern you'll reuse at boss scale (the final boss in Phase 1 summons Splitters in its phase 2).
- It diversifies the enemy roster without requiring new tuning, because Splitter is just Chaser with a death-event.
- It's testable in a single Maker preview run. You can prove it works in 30 min of play.
- It pushes `scripts/main.lua` toward 1000 lines, which is your early-warning zone — you'll know whether the planned split becomes necessary in Phase 2.

**Concrete deliverables by Friday 2026-08-08:**

1. Splitter entity in the single-file scope.
2. Death-event spawn of 2 mini-Splitters, not infinite recursion (mini-Splitters do not split).
3. Visual: same as Chaser body with a small notch / split-line that flashes on hit. Reuses existing palette.
4. Logged run-end metric `spawned_splitters` so future balance passes can read it.
5. Updated `PROJECT_CONTEXT.md` §12 with the Splitter decision.

### 9.1 After Splitter ships — the next 5 single-prototype changes (in order)

1. **Enemy type 5 — Shooter** (stationary, ranged telegraph). *Why next:* gives the player a non-melee threat and forces movement, diversifying the wave feel.
2. **Damage numbers + screen-shake** (survivor.io-style feedback). *Why before mini-boss:* makes the boss encounters *feel* like encounters, not just bigger enemies.
3. **Glitch modifier** (4th arena modifier). *Why mid-sequence:* adds wave-to-wave variance cheaply; teaches the player that the arena fights back.
4. **Mini-boss Spire at wave 3.** *Why fourth:* the Splitter + Shooter + Damage numbers combo has reshaped wave 3 into a denser field; the mini-boss lands harder on top of that density.
5. **Lv3 / Lv5 evolution visual glow pass** on the 6 existing modules. *Why fifth:* every other Phase 1 change raises the bar; this raises it visually, capping Phase 1 with a noticeable feel-upgrade.

**Don't do this week:** start chassis variety, start the stat-axis refactor, start the file split, start audio, start art. All are Phase 2+. Phase 1 is density + feel.

---

## Appendix A — File split plan (preview)

When `scripts/main.lua` crosses 1500 lines (likely mid-Phase 2), the planned split per AGENTS.md §3.3 is:

```
scripts/
├── main.lua          — entry, language selection, top-level game loop, run orchestration
├── state.lua         — player state, modules, integrity / shell / level / xp
├── entities.lua      — enemies, spawn logic, projectiles, mines, hooks, boss AI
├── ui.lua            — HUD, overlays (shop, calibration, run-summary), i18n key lookups
├── waves.lua         — wave definitions, modifier logic, spawn tables
├── design.lua        — design tokens (colors, sizes, durations) and stat curves
└── tests/
    └── headless.lua  — pure-function smoke tests (added in Phase 3)
```

`main.lua` should remain the smallest file (entry + glue); `ui.lua` and `state.lua` will be the largest. No file should exceed ~600 lines post-split. Verify the Maker build still works after each file move.

---

## Appendix B — Vocabulary reminders

From `PROJECT_CONTEXT.md` §5. Keep consistent across all new content — en + zh_CN.

| Chinese | English | Use |
|---|---|---|
| 几何突围 | Geometry Breakout | Product title |
| 几何体 | Geometric Form | Playable entity category |
| 底盘 | Chassis | Playable class |
| 模块 | Module | Combat equipment |
| 波次 | Wave | Timed combat phase |
| 完整度 | Integrity | Primary health layer |
| 护壳 | Shell | Rechargeable defense layer |
| 数据碎片 | Data Fragment | Run economy currency |
| 模式碎片 | Pattern Shard | Run experience currency |
| 校准台 | Calibration Deck | Between-wave upgrade/shop interface |
| 突围 | Breakout | Run objective / theme |

When adding new concepts in Phase 2 (stats, items, chassis names, boss names), add to this table on the same day you add the concept.

---

## Appendix C — What NOT to do (recurring traps)

- **Don't add a chassis until you have stat axes.** A chassis with no passive multiplier is a chassis in name only.
- **Don't add an item until you have stats.** Items without stats are just modules with different art.
- **Don't add a boss phase until you have screen-shake + damage numbers.** A boss with no feedback is a bigger enemy, not a boss.
- **Don't ship a shop until you have currency depth.** A shop with one currency and three items is a worse upgrade screen.
- **Don't split `main.lua` until you must.** Splitting early kills the iteration speed that got you here.
- **Don't add pixel art mid-project.** If art direction changes, change it cleanly with a token-system pass; don't straddle both.
- **Don't hire an artist before launch.** Fund art from revenue, not from speculation.
- **Don't accept a "while I'm here" feature request.** Lock Phase 1 and Phase 2 scope before starting; reject all new ideas into a Phase 5 backlog.
- **Don't ship without a Phase 1 device-matrix run.** A UI-only game with a phone-test gap is a launch-time recall waiting to happen.

---

## Appendix D — One-page "What is Geometry Breakout?" recap

> Geometry Breakout / 几何突围 is a top-down arena roguelite built solo on TapTap Maker for mobile (Android + iPhone/iPad) with PC keyboard for development. The player controls a geometric chassis, holds up to ~6 simultaneous combat modules (Trace Beam / Orbit Seed / Pulse Bloom / Shell Lantern / Anchor Mine / Vector Hook and growing), survives timed enemy waves in 8-wave runs of 8–12 minutes, makes build-shaping choices between waves in a Calibration Deck / shop interface, and unlocks persistent meta-progression across runs. The game draws its build-depth inspiration from Brotato and its visual-feedback density from Survivor.io, while staying geometric (UI-only NanoVG) and bilingual (en + zh_CN). Target launch: ~end of Phase 4 (≈ 2027 Q2) on TapTap as a premium $2–$5 unlock with optional cosmetic IAP and no ads.

---

## Appendix E — Module Spec Sketches (Phase 2)

Six new modules to pair with the existing six. Each gives one-sentence identity, a stat block, the Lv3 / Lv5 evolution triggers, and a visual hook. Sizes balance toward "offensive + utility" pairs so you can ship in 2-prototype chunks.

### E.1 Phase Lance

- **Identity:** *Periodic forward thrust beam in the direction of the nearest enemy.*
- **Base stats (Lv1):** Cooldown 3.0s. Length 6 units. Damage 8. Pierces 1 enemy. Knockback 2 units.
- **Lv3 evolution:** Length 12, pierce 3 enemies, knockback 4.
- **Lv5 evolution:** Pierce becomes infinite within length; knockback 6; on hit, slow target by 30% for 1.5s.
- **Visual:** A thin gold line that fires outward from the player triangle's apex; evolves to gold+diamond-bead trail.

### E.2 Drone Squadron

- **Identity:** *Spawns 2 orbiting micro-drones that auto-target nearest enemy and pulse-fire.*
- **Base stats (Lv1):** 2 drones, drone damage 4 / pulse, drone pulse-rate 1.5s, drone lifetime infinite.
- **Lv3 evolution:** 4 drones, damage 6, pulse-rate 1.0s.
- **Lv5 evolution:** 6 drones, damage 8, pulse-rate 0.7s, drones gain 30% dodge.
- **Visual:** Tiny purple diamonds orbiting the player; evolved adds a soft glow.

### E.3 Gravity Well

- **Identity:** *Drops a stationary field that pulls enemies toward its center and damages them slowly.*
- **Base stats (Lv1):** Cooldown 8s. Radius 4 units. Duration 4s. Tick damage 2/0.5s. Pull 1 unit/s.
- **Lv3 evolution:** Radius 7, duration 7s, tick 3, pull 2.
- **Lv5 evolution:** Radius 9, duration 9s, tick 4, pull 3; on field expire, deals 30 burst damage.
- **Visual:** A pulsing blue circle on the floor; evolves to concentric circles + soft cyan fog.

### E.4 Mirror Shot

- **Identity:** *Fires a projectile that, on impact, bounces to a second nearby enemy and deals reduced damage.*
- **Base stats (Lv1):** Cooldown 1.2s. Projectile speed 10. Damage 10. Bounce damage 6, max 1 bounce.
- **Lv3 evolution:** Damage 16, bounce 10, up to 2 bounces.
- **Lv5 evolution:** Damage 22, bounce 14, up to 3 bounces; bounces prefer the farthest un-hit enemy.
- **Visual:** White diamond projectile; evolves to a splitting triplet.

### E.5 Frost Patch

- **Identity:** *A ground patch that slows enemies inside it. Defensive utility, not damage.*
- **Base stats (Lv1):** Cooldown 6s. Radius 5 units. Duration 5s. Slow 25%.
- **Lv3 evolution:** Radius 7, duration 7s, slow 40%.
- **Lv5 evolution:** Radius 9, duration 9s, slow 55%; on enter, enemies take 8 burst.
- **Visual:** Pale-cyan ring on ground; evolves to dashed ring + frost ticks.

### E.6 Arc Node

- **Identity:** *Periodic lightning that chains between the 3 nearest enemies.*
- **Base stats (Lv1):** Cooldown 2.5s. Bolt damage 6 per hop. Max 3 hops. Chain range 6 units.
- **Lv3 evolution:** Damage 10 per hop, 5 hops, range 8.
- **Lv5 evolution:** Damage 14 per hop, 7 hops, range 10; each hop has 20% crit chance.
- **Visual:** White zigzag bolt; evolved arc gets gold edges and a small flash at the impact point.

### E.7 Module-pairing recommendations

- Ship **Phase Lance + Frost Patch** first (offensive + utility).
- Then **Drone Squadron + Gravity Well** (more offensive + space-control).
- Finally **Mirror Shot + Arc Node** (projectile-heavy + chain-lightning, both high damage ceiling).

---

## Appendix F — Stat Axes Spec (Phase 2)

Eight stat axes replace Integrity and Magnet globals. Integrity + Magnet remain as legacy aliases for one prototype only.

### F.1 Stat definitions

| Stat | Default | Effect | Source items |
|---|---|---|---|
| **MaxHP (Integrity max)** | 100 | Hit point cap. | Tonic, Vital Core |
| **HPRegen** | 0/s | Integrity regeneration out of combat. | Vital Core, Sustained Plate |
| **Speed** | 220 | Movement speed in pixels/sec. | Drift Coil, Phase Slip |
| **Damage** | ×1.0 | All module damage multiplier. | Capacitor Coil, Recursive Loop |
| **AttackSpeed** | ×1.0 | All module cooldown multiplier (lower = faster). | Recursive Loop, Haste Cache |
| **CritChance** | 5% | Chance to deal 2× damage on a module hit. | Capacitor Coil, Sharp Lattice |
| **Dodge** | 0% | Chance to ignore a contact-damage hit. | Phase Slip, Echo Shroud |
| **Luck** | 1.0 | Affects drop quality from enemies. | Echo Shroud, Lode Stone |

### F.2 Stat axis design rules

- **No stat exceeds 5× baseline at run-end.** Caps prevent runaway scaling.
- **Every stat must interact with at least 2 modules.** Otherwise it's dead weight.
- **Damage and AttackSpeed are the two scaling stats.** If both spike, runs end in 4 min. Tune so only one spikes per build.

### F.3 Migration path

1. **Prototype A (Phase 2 week 1):** add the 8 stat fields to player state. Legacy Integrity/Magnet upgrades reroute to MaxHP / Magnet.
2. **Prototype B:** add the stat axis as a Calibration overlay choice. Test 100 sim-runs for balance.
3. **Cut over:** remove Integrity/Magnet globals in Prototype C.

---

## Appendix G — Item Roster Spec (Phase 2)

Twelve passive items. Each has a one-sentence identity, the stat tags it boosts, and one niche passive.

### G.1 Offensive items (4)

1. **Capacitor Coil** — *CritChance +6%, +Damage +5%.* Passive: Crit hits grant +5% AttackSpeed for 2s (stacks 3×).
2. **Recursive Loop** — *AttackSpeed +8%, +Damage +3% per stack.* Passive: Every 4th hit fires a free pulse with no cooldown.
3. **Sharp Lattice** — *CritChance +10%, +Dodge +3%.* Passive: Crit hits refund 1s of Module cooldowns.
4. **Haste Cache** — *AttackSpeed +12%, −MaxHP −10%.* Passive: On level-up, +3% AttackSpeed for the run.

### G.2 Defensive items (4)

5. **Vital Core** — *MaxHP +20%, +HPRegen +1/s.* Passive: Below 25% HP, +30% Damage for 5s (one-shot mechanic).
6. **Sustained Plate** — *MaxHP +15%, +HPRegen +2/s.* Passive: Regen continues at 50% inside Shell Lantern.
7. **Phase Slip** — *Speed +10%, +Dodge +5%.* Passive: Successful Dodge grants +20% Speed for 1s.
8. **Echo Shroud** — *Dodge +8%, +Luck +0.3.* Passive: On Dodge, briefly become intangible (1 frame).

### G.3 Utility items (4)

9. **Drift Coil** — *Speed +8%, +Damage +4% while moving.* Passive: Movement accelerates over 2s (max +15% Speed).
10. **Lode Stone** — *Luck +0.6, +Drop magnet radius.* Passive: Every 25th pickup grants a free level-up.
11. **Tonic** — *MaxHP +10%, pickup radius +20%.* Passive: First pickup each wave heals 5 HP.
12. **Beam Splitter** — *Trace Beam damage +25%, Trace Beam pierces +1.* Passive: Single-module item — Trace Beam only.

### G.4 Item design rules

- **Every item must be describable in one sentence.** If not, throw it out.
- **No item gives more than 2 stat boosts.** Multi-stat items dilute builds.
- **No item has a >5% chance of being picked when another item gives more of what the player needs.** Balance pass at end of Phase 2.
- **Items drop between waves from the calibration overlay (chance-based) and from the shop (buy-based).** Shop-reroll cost: 5 Data Fragments.

---

## Appendix H — Chassis Roster Spec (Phase 2)

Six chassis in addition to Vector Triangle. Each has a passive and a stat profile. Total 7 chassis; matches the "6–8 chassis" target.

### H.1 Vector Triangle (existing — keep)

- Passive: none.
- Stat: Balanced.
- Notes: Default chassis. Player's first chassis.

### H.2 Cube

- Passive: **Fortress** — +25% MaxHP, −20% Speed.
- Stat: Tank. Good for survivability-testing builds.
- Visual: Rotating cube silhouette.

### H.3 Hex

- Passive: **Distribute** — Damage taken splits across 6 segments; segments regenerate 1/sec while not hit.
- Stat: Hybrid. Section-based gameplay.
- Visual: Hexagonal ring with internal divisions.

### H.4 Ring

- Passive: **Orbital Echo** — Each equipped Module has its damage also applied on the far side of the ring (×0.3 damage).
- Stat: Module-heavy.
- Visual: Concentric ring.

### H.5 Prism

- Passive: **Refract** — Every 5s, the chassis refracts, gaining +30% CritChance for 2s.
- Stat: Crit-focused.
- Visual: Triangular prism with rainbow gradient.

### H.6 Doublet

- Passive: **Twin Strike** — All damage is doubled on every 4th hit.
- Stat: Burst-damage.
- Visual: Two overlapping diamonds.

### H.7 Lance

- Passive: **Pierce** — Trace Beam + Phase Lance pierce +2; movement speed +15%.
- Stat: Speed + Trace Beam synergy.
- Visual: Long forward-pointed triangle.

### H.8 Chassis design rules

- **Every chassis passive is verifiable in one sentence.**
- **No chassis passive gives a flat >25% stat boost.** Caps prevent best-chassis dominance.
- **No two chassis have identical stat profiles.** Cube ≠ Hex ≠ Ring ≠ ...
- **One chassis is "default-easy" (Vector Triangle).** New players have a forgiving starting point.

---

## Appendix I — Enemy Roster Spec (Phase 1+2)

Three current + two Phase 1 + two Phase 2 = seven archetypes. Phase 1 enemies are Sized M; Phase 2 adds the ranged / summoner / burrower types.

### I.1 Chaser (existing)

- **Behavior:** Moves toward player at 80 speed. Contact damage 8.
- **HP:** 20.
- **Visual:** Red diamond.

### I.2 Skimmer (existing)

- **Behavior:** Orbits the player at radius 150, fires contact damage 6.
- **HP:** 15.
- **Visual:** Yellow diamond.

### I.3 Charger (existing)

- **Behavior:** Telegraphs 1.2s with a purple pulse, then dashes 8 units at 2× speed, dealing 16 contact damage.
- **HP:** 30.
- **Visual:** Purple diamond with telegraph glow.

### I.4 Splitter (Phase 1 — first deliverable)

- **Behavior:** Moves toward player. On death, spawns 2 mini-Splitters (60% HP, 70% damage, smaller collision).
- **HP:** 40. Mini HP: 24.
- **Visual:** Cyan diamond with a vertical split-line that flashes on hit.
- **Tuning intent:** Rewards AOE (Pulse Bloom / Phase Lance) over single-target (Trace Beam).

### I.5 Shooter (Phase 1)

- **Behavior:** Stationary. Telegraphs 1.0s with a red ring, fires a projectile at player speed 5, dealing 6 damage. 2s between shots.
- **HP:** 25.
- **Visual:** Magenta triangle with a glowing red eye.

### I.6 Summoner (Phase 2)

- **Behavior:** Stationary. Every 6s, spawns 2 mini-Chasers (HP 12, damage 6). Dies in 4 player hits.
- **HP:** 50.
- **Visual:** Green hexagon with three orbiting dots.

### I.7 Burrower (Phase 2)

- **Behavior:** Subterranean. Burrows for 3s, then surfaces at the player's location, dealing 12 contact damage. Visible as a moving ground-line while burrowed.
- **HP:** 35.
- **Visual:** Orange line on the floor + brief silhouette on emerge.

### I.8 Splitter-Mini (special, exists only via Splitter)

- **HP:** 24. Damage: 6. Speed: 100. Does not split.

### I.9 Enemy design rules

- **Every enemy has a readable telegraph ≥ 0.6s before its attack.** Honored today; keep.
- **Every enemy drops 1–3 Data Fragments + 1 Pattern Shard on death.**
- **No enemy has > 1.0s of pre-attack invulnerability.** Players should always be able to dodge.
- **Enemy HP scales with wave:** HP *= (1 + 0.15 · waveIndex). Tuned for 8 waves.

---

## Appendix J — Boss Spec Sketches (Phase 1)

### J.1 Mini-boss: Spire (wave 3)

- **Form:** Stationary core in the arena center. Three rotating shield segments around it.
- **HP:** ~600.
- **Phase 1 (0–100% HP):** Shield segments rotate slowly (10s/revolution). Player must find the 90° gap between segments to damage the core.
- **Phase 2 (<50% HP):** Shield speed +50%. Core starts firing short-range arcs every 3s.
- **Reward:** Guaranteed module upgrade (pick from 4), +25% XP pickup, +50 Data Fragments.
- **Visual:** Cyan triangular core with 3 gold shield arcs; arcs visibly accelerate in phase 2.

### J.2 Final boss: Resonance Core (wave 8)

- **Form:** Large movable core that changes phase every 15s (3 phases per attempt).
- **HP:** ~2400 over 3 phases.
- **Phase 1 — Chase:** Moves toward player at speed 60; deals 14 contact damage. Telegraphed dashes every 5s (1.0s wind-up, dashes 12 units, dealing 22).
- **Phase 2 — Summon:** Stops moving. Spawns 3 Splitters and 1 Shooter every 8s for 24s (3 spawn waves).
- **Phase 3 — Beam-Sweep:** Fires a sweeping laser from its position toward the player at the start of the phase; laser sweeps 180° over 8s, dealing 30 contact damage per tick (0.5s tick). Stand at the beam's tail (behind the boss) to avoid.
- **Cycles:** Phases 1 → 2 → 3 → 1 → 2 → 3 until HP depleted (3 cycles).
- **Reward:** Cosmetic banner + Calibration Credits + guaranteed module to Lv5 if the player survives.
- **Visual:** Multi-segment geometric body with phase-specific color shift (gold → magenta → cyan) and a screen-flash on phase transition.

### J.3 Boss design rules

- **Every boss has a "this is the cue" telegraph** before the attack lands.
- **Every boss has at least one safe-zone tactic** the player can learn.
- **Boss HP is tuned so the average player reaches wave 5–6 today, and the boss-resilient player reaches the Spire.**
- **No boss has more than 3 phases.** Adding phases is a 30% complexity cost in testing.

---

## Appendix K — Difficulty Curve Spec

### K.1 Per-wave target (8-wave run)

| Wave | Length (s) | Spawn pattern | Modifiers (one) |
|---|---|---|---|
| 1 | 30 | 3 Chasers | Compression (default) |
| 2 | 35 | 5 Chasers + 2 Skimmers | Surge |
| 3 | 45 | Chaser/Skimmer mix + 1 mini-boss Spire at t=30 | Overclock |
| 4 | 50 | Chasers + Skimmers + first Shooter | Glitch (new) |
| 5 | 55 | + Splitters | Compression |
| 6 | 60 | + Burrowers (Phase 2) | Surge |
| 7 | 65 | Heavy mix | Overclock |
| 8 | 75 | All archetypes + Resonance Core boss at t=60 | Glitch |

### K.2 HP scaling

- Base HP scaling: enemy HP *= (1 + 0.18 · waveIndex).
- Damage scaling: enemy contact damage *= (1 + 0.10 · waveIndex).
- Spawn-rate scaling: spawn interval *= 0.92^(waveIndex).
- Boss HP fixed at design-time (above).

### K.3 Tuning tolerances

- **Player should die at wave 4–5 on a no-upgrade run** (proves the run is hard without upgrades).
- **Player should reach wave 6 on a mid-build run.**
- **Average wave reached across 50 sim-runs should be > 5.**
- **At least 10% of runs should reach the Resonance Core.**

If the simulator disagrees, adjust enemy HP / damage before adding more enemies.

---

## Appendix L — Shop UI Mockup (text)

The Calibration Deck becomes a Shop with three panels. Between-wave UI:

```
┌─────────────────────────────────────────────────────────────┐
│              Wave 1 → 2  ·  Pattern Shards  ·  Data Fragments│
├──────────────────────────┬──────────────────────────────────┤
│  CALIBRATIONS (3 random) │  SHOP                            │
│                          │                                  │
│  [A] Trace Beam  Lv2     │   Reroll calibrations:  5 Frag  │
│  [B] Frost Patch NEW     │   Buy tier-1 module:   25 Frag  │
│  [C] Luck +0.3           │   Heal 30%:            8 Frag   │
│                          │                                  │
│  [reroll]  [confirm]     │   Items (locked until Phase 4)  │
├──────────────────────────┴──────────────────────────────────┤
│  NEXT WAVE:  15s                                            │
│  Glitch Mod in effect                                       │
└─────────────────────────────────────────────────────────────┘
```

Visual layers: NPC overlay panel (existing language-selection screen style) with three Calibration tiles on the left + Shop column on the right + a countdown to next wave at the bottom. Mirrors the existing Calibration overlay; the Shop column is new.

---

## Appendix M — Audio Asset List (Phase 3)

### M.1 SFX (12 total)

| # | Sound | Trigger | Source |
|---|---|---|---|
| 1 | Hit (soft tap) | Module hit on enemy | Self / zero-license |
| 2 | Hit (sharp) | Crit hit | Self / zero-license |
| 3 | Pickup | Data Fragment / Pattern Shard | Self / zero-license |
| 4 | Level up | Player level-up chime | Self / zero-license |
| 5 | Module evolve | Lv3 / Lv5 evolution | Self / zero-license |
| 6 | Boss hit | Module hit on boss | Self / zero-license |
| 7 | Boss phase change | Boss enters new phase | Self / zero-license |
| 8 | Wave start | New wave begins | Self / zero-license |
| 9 | Wave end | Wave clear | Self / zero-license |
| 10 | Run end (won) | Resonance Core defeated | Self / zero-license |
| 11 | Run end (lost) | Player integrity 0 | Self / zero-license |
| 12 | Button tap | UI button press | Self / zero-license |

### M.2 Ambient tracks (2)

- **Combat Calm:** A 30s loop of low-frequency geometric pulses + subtle sine arpeggio. Plays during waves 1–4.
- **Combat Climax:** A 30s loop of higher-frequency pulses + layered bass thumps. Plays during waves 5–8 + boss fights.

### M.3 Implementation notes

- **Source preference:** open-source / zero-license (e.g. freesound.org CC0 filters) → self-made geometric beeps (sine + triangle + noise → short ADSR).
- **Polyphony:** limit to 4 concurrent SFX to avoid engine overload.
- **Volume scaling:** SFX < ambient so ambient forms the floor of the soundscape.
- **Mute toggle:** in pause overlay; persists via Calibration Archive.

---

## Appendix N — Device Matrix Checklist (Phase 3)

A minimum 4-device matrix must pass before launch.

| Device | Resolution | OS | Min check items |
|---|---|---|---|
| Low-end Android phone | 1280×720, 4GB RAM, 60Hz | Android 11 | 60fps, joystick overlap, HUD readability, no overflow. |
| Mid Android phone | 2400×1080, 8GB RAM, 120Hz | Android 13 | 60fps sustained, no VFX widget dropouts. |
| iPhone (recent) | 2532×1170, iOS 17 | iOS | Safe-area layout, no cut-off, 60fps. |
| iPad | 2360×1640, iPadOS 17 | iPadOS | 4:3 layout, joystick placement, HUD scale, 60fps. |

Per device, run a 5-wave playthrough and log:

- **frame rate** (mean, p99)
- **widget count at peak VFX**
- **load time to language screen**
- **joystick + HUD overlap check** (visual screenshot diff vs reference)
- **crash log** (any uncaught error)

Block launch if any device fails 60fps or any layout overlaps the joystick.

---

## Appendix O — Daily Challenge + Meta Progression Spec (Phase 4)

### O.1 Daily Challenge

- **Seed of the day:** A 32-bit integer published via TapTap Maker daily.
- **What it fixes:** chassis, starting modules (Trace Beam + Orbit Seed + Pulse Bloom), starting upgrades (MaxHP +1, Damage +1), modifier set (one fixed modifier per wave), enemy spawn table.
- **Score:** Wave reached + bonus points for fragments collected + boss-kill bonus (Spire = 1000, Resonance Core = 5000).
- **Leaderboard:** per-chassis (only relevant if meta-unlocked) + global. Reset at 00:00 UTC daily.
- **Pool of seeds:** Pre-generate 30 daily seeds; rotate. Cheaper than daily content authoring.

### O.2 Meta Progression Tree

Per chassis (6 chassis * 3 nodes = 18 nodes total), players unlock incremental bonuses across runs.

| Node | Unlocks at | Effect |
|---|---|---|
| **Tier 1** | 5 runs | Starting Integrity +20 |
| **Tier 2** | 10 runs | +1 starting module level |
| **Tier 3** | 25 runs | Chassis passive +50% strength |

Implementation:

```text
runs_completed[chassis_id] -> int (5/10/25 milestones)
unlocked_tiers[chassis_id] -> int (0/1/2/3)
```

Two of these (tier 1 + tier 2) must unlock before a chassis is competitive with Vector Triangle without unlocks. Otherwise players won't pick it.

### O.3 Currency design

- **Calibration Credits:** earned per run. Used to unlock chassis tiers.
- **Pattern Memory:** earned per 5 runs. Used to unlock chassis entirely.
- **Resonance Tokens:** premium currency. Used to skip progression or buy cosmetic IAP.

Don't ship more than 3 currencies; the cognitive load is too high for solo dev.

---

## Appendix P — Per-Phase Risk + Rollback Plan

### P.1 Phase 1 risks

- **Boss AI complexity blows scope.** *Rollback:* simplify both bosses to single-phase with stat-bump if Phase 1 spike shows > 2 prototypes consumed.
- **Damage numbers tank framerate on low-end Android.** *Rollback:* drop floating numbers; keep only crit-flash.

### P.2 Phase 2 risks

- **Stat axis refactor introduces regressions.** *Rollback:* keep Integrity + Magnet as legacy aliases throughout Phase 2; cutover in Phase 3.
- **File split breaks Maker build.** *Rollback:* maintain `main.lua` as a single-file shim that re-exports from the new modules; if even this fails, revert and reset.
- **Build-diversity entropy stays < 2.5.** *Rollback:* add 2 more stat items OR add 2 more modules.

### P.3 Phase 3 risks

- **Device matrix fails on iPad.** *Rollback:* add a tablet-only alternate HUD layout (more compact) — 1 prototype cost.
- **60fps unreachable on low-end Android.** *Rollback:* declare Android tablet/phone minimum spec; relax to 30fps on the lowest tier.
- **Audio asset license issue.** *Rollback:* fall back to self-made geometric beeps (sine + triangle + noise + ADSR — pure Lua, no asset needed).

### P.4 Phase 4 risks

- **Persistence API never materializes.** *Rollback:* local-file persistence via Maker `fs` if available; else ship "session-only" beta with a clear disclaimer and shift launch to post-API.
- **D1 retention < 15% in soft-launch.** *Rollback:* ship the onboarding tutorial as the immediate next fix; reconsider Path A's premium assumption.
- **TapTap review-rating < 4.0 in soft-launch.** *Rollback:* iterate on art direction (still geometric, but with stronger NanoVG); consider pivoting from premium $5 to premium $2.

---

## Appendix Q — Balance Tuning Heuristics

### Q.1 Module balance

- **Target average DPS contribution per module, weighted by pick rate.** If two modules contribute identical DPS, the one with higher pick rate is overperforming.
- **Target pickup rate < 30% per module.** Modules picked > 30% are dominant; buff the alternatives.
- **Aim for:** no single module > 25% pick rate; no module < 5% pick rate across 100 sim-runs.

### Q.2 Stat axis balance

- **Damage and AttackSpeed capped at 5× baseline.** Already noted.
- **Every stat must show measurable lift across 50 sim-runs.** Stats with no measurable lift get removed.

### Q.3 Enemy balance

- **No single enemy type > 40% of spawn pool in any wave.** Otherwise the wave plays like that enemy.
- **Average wave reached < 5?** Buff player base stats.
- **Average wave reached > 6.5?** Buff enemies or reduce module damage.

### Q.4 Run length

- **Target 8–12 min session.** If > 15 min, shorten waves OR cut enemy HP/damage by 15%.
- **If < 6 min, add waves OR increase enemy HP by 15%.**

### Q.5 Build-diversity entropy

- **Target > 3.0 nats.** Below 2.5 nats means low diversity; consider adding / buffing under-picked modules.

### Q.6 Iteration cadence

- **Aim for 1 balance pass per ~5 prototypes.** Don't try to dial in balance before content is done.
- **Always log run-end state in plain text** so you can grep for imbalance from a single 50-run session.

---

*End of strategic plan. Next checkpoint: Friday 2026-08-08, ship Splitter; update PROJECT_CONTEXT.md §12; reconvene on Phase 1 priorities. File path: `C:\Users\ShenYunLong\OneDrive\TAPTAPGAME\deliverables\software-company\geometry-breakout-strategy-2026-08-03.md`*
