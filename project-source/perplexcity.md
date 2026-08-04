# PerplexCity — 几何突围 Mobile Test Log

> 移动端测试记录中心：截图、Bug、性能、体验反馈
> Game: Geometry Breakout / 几何突围 (Brotato-style survivor)
> Build: `f2539b6` | P0–P9 Complete | 2026-08-04

---

## Quick Reference

| Item | Detail |
|------|--------|
| Genre | Brotato-style auto-fire survivor |
| Run length | 20 waves × ~30s ≈ 10–12 min |
| Controls | Virtual joystick (touch) / WASD (keyboard) |
| Core loop | Fight → Shop → Fight → … → Boss → Stage Clear |
| Weapons | 6 slots, auto-fire at nearest enemy |
| Stats | 8 axes: HP / DMG / SPD / RNG / CRT / DDG / MOV / LCK |
| Art style | Neon Vector Geometry (cyan/white player, warm-color monsters) |
| Current SHA | `f2539b6` — TapTap Maker & GitHub synced |

### Weapon Quick Card

| Weapon | Type | DPS | Range | Pierce | Price | Role |
|--------|------|-----|-------|--------|-------|------|
| Blade 🔷 | Melee | 8.33 | 55px | 4 | 15g | Fast crowd sweep |
| Bow 🏹 | Ranged | 9.38 | 380px | 1 | 15g | Highest single-target DPS |
| Thrown 🔪 | Ranged | 8.33 | 260px | 4 | 25g | Mid-range pierce spam |
| Crossbow 🎯 | Ranged | 7.76 | 420px | 3 | 30g | Longest range piercer |
| Blunt 🔨 | Melee | 7.39 | 65px | 6 | 35g | Heavy wide CC |
| Staff ✨ | Magic | 7.08 | 300px | 1+AoE | 35g | Magic splash |

### Stat Scaling (per point)

| Stat | Effect | Cap |
|------|--------|-----|
| maxHP | +2 HP | — |
| damage | +8% DMG | — |
| attackSpeed | -4% cooldown | — |
| range | +5% range | — |
| critChance | +4% crit | 95% |
| dodge | +4% dodge | 60% |
| moveSpeed | +5% speed | — |
| luck | +15% gold | — |

---

## Test Checklist — By System

### 1. Combat ⚔️

- [ ] **Weapon auto-fire** — all 6 slots fire at nearest enemy without input
- [ ] **Blade** — 120° arc sweep, cyan, melee range ~55px
- [ ] **Bow** — green fast arrow, long range ~380px
- [ ] **Staff** — purple slow bolt, 50px AoE on hit
- [ ] **Blunt** — orange wide heavy swing, 6 pierce
- [ ] **Crossbow** — red-orange piercing bolt, 420px range
- [ ] **Thrown** — gold fast multi-pierce
- [ ] **Crit hits** — gold-colored projectiles, 1.5x damage
- [ ] **Dodge** — purple flash + brief invuln (0.15s) on successful dodge
- [ ] **Damage numbers** — visible, correct color per weapon
- [ ] **Hit flash** — enemy flash on hit, character flash on damage/dodge
- [ ] **Enemy types** — Chaser / Skimmer / Charger / Splitter / Shooter all appear
- [ ] **Boss (Core Breaker)** — spawns at final wave, distinct behavior
- [ ] **Mid-boss (Gatekeeper)** — spawns mid-level

### 2. Character 👤

- [ ] **Diamond body** — 36px, dark blue fill, cyan border (3px)
- [ ] **Eyes** — two white dots (5px), shift toward movement direction
- [ ] **Face bar** — bright cyan, faces movement direction, fades when still
- [ ] **Smooth turn** — character rotates toward movement (not snap)
- [ ] **Idle bob** — gentle vertical bounce when stationary
- [ ] **Hit flash** — red flash on damage, purple flash on dodge
- [ ] **Movement trail** — geometric square dots (not circles), max 8, fade
- [ ] **Weapon orbits** — 6 colored diamonds circling character
- [ ] **Monster distinction** — player clearly different from enemies

### 3. Shop 🛒

- [ ] **Shop appears between waves** — after wave clear, before next wave
- [ ] **3 weapon slots** — random weapons, no duplicates in same shop
- [ ] **3 stat item slots** — random stat items, no duplicates
- [ ] **Prices correct** — weapons: 15/25/30/35g; stats: 10 + level×5
- [ ] **Buy weapon** — deducts gold, equips to empty slot
- [ ] **Buy stat item** — deducts gold, increments stat
- [ ] **"FULL" guard** — shows "FULL" when all 6 weapon slots occupied
- [ ] **Can't afford** — button dimmed, no purchase
- [ ] **Reroll** — costs 1g + rerollCount, refreshes non-locked items
- [ ] **Lock** — 🔒 items survive reroll, orange border
- [ ] **Skip** — advances to next wave/level
- [ ] **Gold display** — correct balance throughout shop session
- [ ] **Shop after every wave** — no skipped shop screens

### 4. Stats Panel 📊

- [ ] **Real-time update** — values change as stats change
- [ ] **HP display** — current/max, updates on damage/heal
- [ ] **DMG display** — % bonus from damage stat
- [ ] **SPD display** — attack speed % bonus
- [ ] **RNG display** — range % bonus
- [ ] **CRT display** — crit chance %
- [ ] **DDG display** — dodge chance %
- [ ] **MOV display** — move speed % bonus
- [ ] **LCK display** — luck bonus
- [ ] **Gold counter** — real-time gold in stats panel

### 5. Economy 💰

- [ ] **Gold drops from kills** — Chaser/Skimmer: 1g, Charger/Splitter/Shooter: 2g, Elite: 5g
- [ ] **Boss gold** — 8 × 5g = 40g total on kill
- [ ] **Mid-boss gold** — 5 × 4g = 20g total on kill
- [ ] **Luck multiplier** — luck stat increases gold drops (×1.15 per point)
- [ ] **Gold pickup** — yellow coin-shaped circle (12×12), collected on touch
- [ ] **Gold reset** — gold resets to 0 on new run
- [ ] **Shopping possible** — can afford early items, scaling costs feel fair

### 6. Wave Progression 🌊

- [ ] **20 waves total** — 2 stages × 10 levels × 6 waves (per legacy config, verify actual)
- [ ] **Wave banner** — "Wave X/Y" gold text at wave start
- [ ] **Boss banner** — orange "BOSS · Wave X/Y" at boss wave
- [ ] **Elite banner** — "ELITE · Wave X/Y" at mid-boss wave
- [ ] **Enemy density** — 12 + wave×4 enemies per wave (~45% more than original)
- [ ] **Difficulty curve** — later waves noticeably harder
- [ ] **Wave timer** — 30s per wave (verify)
- [ ] **Game over screen** — on death, shows stats
- [ ] **Victory screen** — on stage clear, shows summary

### 7. VFX ✨

- [ ] **Death particles** — colored diamond bursts on enemy death
- [ ] **Projectile trails** — weapon-colored diamond dots behind projectiles
- [ ] **Wave banners** — fade-in → hold → fade-out (2.2s total)
- [ ] **Boss spawn flash** — screen flash + shake on boss entrance
- [ ] **Boss death flash** — big shake + flash + many particles on boss kill
- [ ] **Screen shake** — on boss/mid-boss events
- [ ] **Performance** — no frame drops with many particles active

### 8. UI / HUD 🖥️

- [ ] **Gold counter (HUD)** — visible during gameplay
- [ ] **Weapon display** — shows equipped weapons on HUD
- [ ] **Wave info** — current wave / total visible
- [ ] **Stats panel** — right-side panel visible
- [ ] **Upgrade cards** — 4-card choice on level-up
- [ ] **Pause screen** — shows weapons, not old modules
- [ ] **Language switch** — zh_CN ↔ en works

### 9. Mobile-Specific 📱

- [ ] **Touch joystick** — responsive, no dead zones
- [ ] **Screen layout** — no elements overlapping or cut off
- [ ] **Small screen readability** — text/numbers legible on phone
- [ ] **Shop buttons** — touchable, no mis-taps
- [ ] **Performance** — 30+ FPS on mid-range device
- [ ] **Battery/heat** — no excessive drain
- [ ] **Notifications/calls** — game pauses correctly
- [ ] **Orientation** — portrait/landscape behavior correct

### 10. Edge Cases 🔍

- [ ] **Rapid shop buy** — spamming buy doesn't crash
- [ ] **Full inventory** — all 6 weapon slots filled, shop shows FULL
- [ ] **Zero gold** — shop items all dimmed
- [ ] **Max stats** — stat at cap, no further increase
- [ ] **Fast enemy spawn** — no spawn overlap or clipping
- [ ] **Death while shopping** — impossible (in combat only)
- [ ] **Run restart** — new run resets all state (gold, stats, weapons, waves)
- [ ] **Multiple runs** — no memory leak across runs

---

## Bug Severity Guide

| Level | Icon | Definition |
|-------|------|------------|
| **P0** | 🔴 | Crash / softlock / can't play |
| **P1** | 🟠 | Major feature broken (e.g. can't buy items) |
| **P2** | 🟡 | Visual glitch / wrong number / cosmetic |
| **P3** | 🟢 | Minor polish / suggestion |

---

## Test Session Template

```markdown
### [YYYY-MM-DD] Test #N — [Feature / Wave Range]

**Device:** [model, OS, screen size]
**Build SHA:** [commit]
**Test Duration:** [minutes]

#### Pre-Test
- [ ] Game loads without error
- [ ] HUD / stats panel visible
- [ ] Character renders correctly

#### Screenshots / Video
<!-- embed here -->

#### Test Flow
1. [Wave 1–3]  → [observation]
2. [Shop 1]     → [items seen, bought, gold spent]
3. [Wave 4–6]   → [observation]
4. ...

#### Observations
| # | Severity | System | Description |
|---|----------|--------|-------------|
| 1 | P1 🟠 | Shop | Buy button unresponsive on first tap |
| 2 | P2 🟡 | VFX | Death particles wrong color for Charger |

#### Combat Feel
- Weapon balance: [too strong / too weak / just right — per weapon]
- Enemy difficulty: [too easy / fair / frustrating]
- Gold economy: [too little / enough / abundant]
- Shop decisions: [meaningful / trivial / confusing]

#### Performance
- FPS: [smooth / occasional drops / consistently low]
- When drops occur: [wave __, __ enemies on screen]
- Battery: [normal / warm / hot]

#### Summary
<!-- One paragraph verdict on this build -->
```

---

## Performance Benchmarks

Record FPS / frame time at key moments:

| Scenario | Target FPS | Actual FPS | Notes |
|----------|-----------|------------|-------|
| Wave 1 (16 enemies) | 30+ | — | |
| Wave 6 (36 enemies) | 30+ | — | |
| Boss fight (enemies + VFX) | 25+ | — | |
| Shop screen (idle) | 30+ | — | |
| Many projectiles (6 weapons firing) | 25+ | — | |
| Death particles (20+ burst) | 25+ | — | |

---

## Known Issues

| # | Severity | Description | Status |
|---|----------|-------------|--------|
| 1 | P2 🟡 | ROADMAP.md & MEMORY.md still show stale phase status (P0–P3 "in progress", P6 "next") — docs only | Pending |
| 2 | P2 🟡 | `.tmp/mcp-log*.txt` (gitignored) has stale OneDrive paths — harmless | Ignore |
| 3 | — | No sound/music wired yet | Future |
| 4 | — | No save/persistence system | Future |
| 5 | — | Trail dots capped at 120; death particles unbounded — potential perf issue | Monitor |

---

## Test History

<!-- ═══════════════════════════════════════════════ -->
<!-- ADD NEW TEST SESSIONS BELOW THIS LINE         -->
<!-- Use the Test Session Template above           -->
<!-- ═══════════════════════════════════════════════ -->

_No tests recorded yet. Run a test and paste results here._
