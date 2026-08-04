# ECONOMY.md — Sources & Sinks Model

> Every gold piece must have a source (where it enters) and a sink (where it exits).
> No source without a sink = inflation. No sink without a source = broken economy.
>
> Last updated: 2026-08-04

---

## Fun Hypothesis for Economy

> Gold creates tension: spend now for immediate power vs. save for a legendary weapon that might appear in the next shop.

---

## Sources (Gold In)

| Source | Amount | Frequency | Per-Run Estimate |
|--------|--------|-----------|-----------------|
| Chaser kill | 1 | Every kill | ~35-50 |
| Skimmer kill | 1 | Every kill | ~25-40 |
| Charger kill | 2 | Every kill | ~15-25 |
| Splitter kill | 2 | Every kill | ~10-18 |
| Shooter kill | 2 | Every kill | ~12-20 |
| Elite kill | 5-8 | ~3 per run | ~18 |
| Boss kill | 20 | 1 per run (wave 20) | 20 |
| Wave clear bonus | 5 | 19 times (not boss wave) | 95 |
| **Total Sources** | | | **~230-270 gold/run** |

### Source Rationale
- Base enemies give 1-2 gold. This is low enough that gold feels scarce early.
- Wave clear bonus (5g) is the primary income — incentivizes completing waves quickly.
- Boss (20g) is a victory lap reward, not the main income engine.
- [PLACEHOLDER] Exact drop rates need tuning after P9 balance pass.

---

## Sinks (Gold Out)

| Sink | Price Range | Frequency | Per-Run Estimate |
|------|------------|-----------|-----------------|
| Common weapon | 15-20 | 0-3 per run | 0-60 |
| Uncommon weapon | 22-30 | 0-2 per run | 0-60 |
| Legendary weapon | 35-45 | 0-1 per run | 0-45 |
| Stat item (+1) | 8-12 | 0-5 per run | 0-60 |
| Stat item (+2) | 14-18 | 0-2 per run | 0-36 |
| Stat item (+3) | 20-25 | 0-1 per run | 0-25 |
| Reroll (1st) | 1 | 0-5 per run | 0-5 |
| Reroll (2nd) | 2 | 0-3 per run | 0-6 |
| Reroll (3rd+) | 3+ | Rare | 0-9 |
| Consumable | 5-15 | 0-2 per run | 0-30 |
| **Total Sinks (max)** | | | **~336** |
| **Total Sinks (typical)** | | | **~150-220** |

### Sink Rationale
- Player earns ~250g per run. A typical player spends ~180g.
- Surplus (50-70g) gives the player agency: save for legendary, reroll aggressively, or buy more items.
- If the player plays perfectly (0 rerolls, efficient purchases), they can afford 1 legendary + 2-3 stat items + 5-6 commons.
- [PLACEHOLDER] Shop prices need live data from P6 playtests.

---

## Sink/Source Balance Check

```
Source max:          ~270g
Sink max:            ~336g (cannot spend all — gold runs out)
Sink typical:        ~180g (player has surplus)
Surplus:             ~90g average (agency buffer)
```

The surplus is intentional. Brotato's economy is tight but not punishing. The player should always have *some* gold but never enough to buy everything.

---

## Price Calculation Formula

### Weapons
```
base_price = 15 + (rarity_tier * 8) + stat_bonus * 3
rarity_tier: Common=0, Uncommon=1, Legendary=2
stat_bonus: sum of all stat increases on the weapon
```

Example: Legendary Bow with +2 DMG, +1 SPD
→ 15 + (2×8) + (3×3) = 15 + 16 + 9 = 40g

### Stat Items
```
base_price = 4 + (magnitude * 4) + random(0, 3)
magnitude: +1=1, +2=2, +3=3
```

Example: +3 Max HP
→ 4 + (3×4) + random(0,3) = 16-19g

---

## Inflation Check

| Risk | Probability | Mitigation |
|------|------------|------------|
| Gold hoarding (player never buys) | Low — power curve forces purchases | Shop timer discourages analysis paralysis |
| Gold drought (too few drops) | Medium — early waves have few enemies | Wave clear bonus provides baseline income |
| Reroll inflation (cost gets ignored) | Low — cost escalates per-shop | Reset per shop; progressive cost within shop |
| Legendary price too low | Medium | Cap legendary at 45g; if players consistently buy 2+, increase |

---

## What This File Does NOT Cover

- Star currency (permanent progression) — that's M5/P8
- XP economy — that's the upgrade system, not gold
- Data fragments — legacy currency, may be deprecated in Brotato transition
- IAP / real-money purchases — out of scope until TapTap monetization review
