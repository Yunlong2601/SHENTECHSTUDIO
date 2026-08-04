# GAME_DESIGN.md — Brotato-Style Survivor

> Full game design document for the Brotato transition.
> This is the canonical design reference. All implementation decisions derive from this document.
>
> Last updated: 2026-08-04

---

## Fun Hypothesis

> This game is fun because the player constructs a unique weapon build each run through shop decisions and 4-card upgrades, and every wave tests that build against escalating enemy density.

## Design Pillars

1. **Build identity** — Each run creates a legible weapon + stat synergy. The player should be able to name their build ("I went all-crit bows").
2. **Decision density** — Every inter-wave moment (shop, upgrade) presents a meaningful choice. No filler.
3. **Readable chaos** — At max density (20+ enemies), the player can still track their character, threats, and damage output.
4. **Short mastery loop** — Runs are ~20 min. Death teaches one clear lesson. Restart is instant.
5. **Neon Vector Geometry** — All visuals speak the established geometric language.

---

## Core Loop

### Moment-to-Moment (0-30s)
```
Move character → Weapons auto-fire at nearest enemy → Enemies chase/die → Collect gold/pickups
```
- Player controls character with virtual joystick / WASD
- 6 weapons auto-fire at nearest target (no manual aiming)
- Enemies spawn from arena edges, pursue player
- Killed enemies drop gold + XP orbs

### Session Loop (5-30min)
```
Wave start → Fight 30s → All enemies dead/time up → Shop (15s) → Choose 1 item/buy → Next wave
```
- 20 waves per run
- Each wave: 30s of combat
- Between every wave: shop screen (buy weapons, stat items, reroll)
- Level-up during combat: 4-card upgrade choice (pauses game)

### Long-Term (hours-weeks)
```
Complete run → Earn star currency → Spend on permanent upgrades → New builds become viable
```
- Stars awarded on run completion (1-3 based on performance)
- Permanent upgrades: starting gold, unlock chassis variants, stat bonuses
- No gacha, no daily energy, no timed gates

---

## Combat System

### Player Character
- Visible geometric chassis on field (32px square, rotatable)
- 6 weapon slots arranged around the character
- Movement speed: base ~200px/s
- Integrity (HP): starts at 10, can grow via items/upgrades
- Shell (shield): optional, from items only

### Weapons (6 Types)
| Weapon | Style | Attack Pattern | Base Damage | Attack Speed |
|--------|-------|---------------|-------------|-------------|
| Blade | Melee | Short-range slash arc | 8 | 1.2/s |
| Bow | Ranged | Single arrow, long range | 6 | 0.9/s |
| Staff | Magic | Seeking projectile | 5 | 0.8/s |
| Mace | Melee AoE | 360° spin | 7 | 0.7/s |
| Crossbow | Ranged Pierce | Piercing bolt | 5 | 0.6/s |
| Throwing | Ranged multi | 3-spread daggers | 4 | 1.0/s |

Weapons scale with stat axes:
- **Damage** — flat +N to all weapon base damage
- **Attack Speed** — % multiplier on fire rate
- **Range** — affects projectile speed/range and melee arc size
- **Crit Chance** — % chance for 2x damage
- **Pierce** — how many enemies a projectile passes through

### Weapon Rarity
| Tier | Color | Spawn Weight | Stat Bonus |
|------|-------|-------------|------------|
| Common | White | 60% | +0-1 stat |
| Uncommon | Blue | 30% | +1-2 stats, +10% damage |
| Legendary | Gold | 10% | +2-3 stats, unique effect |

---

## Stat Axes (8 Total)

| Axis | Abbr | Primary Effect | Secondary Effect |
|------|------|---------------|-----------------|
| Max HP | HP | +1 integrity per point | — |
| Damage | DMG | +1 flat damage per point | — |
| Attack Speed | SPD | +8% fire rate per point | — |
| Range | RNG | +15% weapon range per point | +5% projectile speed |
| Crit Chance | CRT | +5% crit per point | Crits = 2x damage |
| Dodge | DDG | +4% dodge per point | Dodge = negate hit |
| Move Speed | MOV | +6% move speed per point | — |
| Luck | LCK | +3% rare drop chance | +2% shop reroll discount |

All stats displayed in the right-side panel as two columns:
- **Primary** (left column): HP, DMG, SPD, RNG
- **Secondary** (right column): CRT, DDG, MOV, LCK

---

## Upgrade System

### 4-Card Choice
- Level up when XP bar fills (enemy kills drop XP)
- 4 random cards appear, pick 1
- Cards can be: weapon upgrades, stat items, stat boosts, or special effects
- Cards that affect currently-equipped weapons show a glow/highlight

### Card Types
| Type | Example | Weight |
|------|---------|--------|
| Weapon upgrade | "Blade +1 damage, +5% speed" | 35% |
| Stat item | "+2 Max HP" (stacks permanently) | 30% |
| Stat boost | "+1 Damage for this run" | 25% |
| Special | "Gain 5 gold", "Full heal" | 10% |

---

## Shop System

See `SHOP_SPEC.md` for full mechanics.

### Core Rules
- Shop appears between every wave
- 15-second timer (can skip early)
- 4-6 items displayed (mix of weapons + stat items)
- **Reroll**: cost = 1 + (rerolls_this_shop) gold. Refreshes all items.
- **Lock**: free. Marks an item to keep it for next shop.
- **Recycle**: sell an equipped weapon for 30% of its value.
- Gold persists across the entire run.

### Shop Item Pool
| Category | Examples | Price Range |
|----------|---------|-------------|
| Weapons | Blade, Bow, Staff, Mace, Crossbow, Throwing | 15-45 gold |
| Stat Items | +HP, +DMG, +SPD, +RNG, +CRT, +DDG, +MOV, +LCK | 8-25 gold |
| Consumables | Full heal, temporary invuln, gold boost | 5-15 gold |

---

## Enemy Design

### Enemy Types (5, carried forward)
| Type | Behavior | Visual | HP Scale |
|------|----------|--------|----------|
| Chaser | Direct pursuit, no tricks | Red square | 2 + wave |
| Skimmer | Circles player, lateral approach | Teal circle | 2 + wave |
| Charger | Pauses, then fast dash at player | Orange diamond | 3 + wave |
| Splitter | Splits into 2 fragments on death | Green hex | 3 + wave |
| Shooter | Keeps distance, fires projectiles | Purple round rect | 2 + wave |

### Boss (Wave 20)
- Core Breaker — large geometric entity
- 4 attack phases: pulse, charge, spawn, enrage
- HP: 100 + wave × 25 (at wave 20 = ~600)
- Drops: guaranteed legendary weapon + 20 gold

---

## Wave Structure (20 Waves)

| Wave | Enemies | Modifier | Spawn Target |
|------|---------|----------|-------------|
| 1-3 | Chaser + Skimmer | None | 6-10 |
| 4-6 | + Charger | Compression | 10-14 |
| 7-9 | + Splitter | Surge | 14-18 |
| 10-12 | All 5 types | Overclock | 18-22 |
| 13-15 | + Elite spawns | Compression | 22-26 |
| 16-18 | + Elite spawns | Surge | 26-30 |
| 19 | All types, high density | Overclock | 30-35 |
| 20 | Boss (Core Breaker) | None | 4 + boss |

---

## Economy

See `ECONOMY.md` for full sources/sinks model.

| Source | Amount | Frequency |
|--------|--------|-----------|
| Enemy kill | 1-3 gold | Every kill |
| Elite kill | 5-8 gold | ~3 per run |
| Boss kill | 20 gold | Once (wave 20) |
| Wave clear bonus | 5 gold | Every wave |

| Sink | Amount | Frequency |
|------|--------|-----------|
| Shop weapon (common) | 15-25 | 0-6 per shop |
| Shop weapon (legendary) | 35-45 | Rare |
| Shop stat item | 8-25 | 0-3 per shop |
| Reroll | 1 + N | 0-3 per shop |
| Recycle (income) | +30% value | When selling |

---

## Progression

### Per-Run
- Gold → shop purchases → build power
- XP → level-ups → 4-card upgrades
- Wave completion → next wave (escalating difficulty)

### Permanent (Star Shop — M5/P8)
- Earn 1-3 stars per completed run
- Spend on: +1 starting HP, +5 starting gold, unlock chassis variants
- Stars are NOT purchasable (no pay-to-win)

---

## What We're NOT Doing
- No gacha mechanics
- No daily energy / stamina
- No PvP / leaderboards (yet)
- No paid consumables in-run
- No ads during combat
- No 12+ weapon types (6 is enough for build variety)
- No manual aiming (auto-fire is the design)
