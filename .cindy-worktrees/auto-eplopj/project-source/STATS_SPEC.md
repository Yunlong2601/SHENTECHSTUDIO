# STATS_SPEC.md — Stat Axes & Panel

> Defines all 8 stat axes, their effects, display format, and integration points.
>
> Last updated: 2026-08-04

---

## Purpose

Give the player a real-time view of their build's stats. The stats panel is the single source of truth for "how strong am I right now?"

## Player Experience Goal

> "I can glance at the right side of the screen and immediately understand my build: high damage, low speed, decent HP. I know what stat items to hunt for in the next shop."

---

## Stat Axes Definition

### Primary Stats (left column)

| # | Axis | Abbr | Color | Effect Per Point | Base Value | Cap |
|---|------|------|-------|-----------------|------------|-----|
| 1 | Max HP | HP | `#FF5555` | +1 max integrity | 10 | 50 |
| 2 | Damage | DMG | `#FFAA33` | +1 flat damage to all weapons | 0 | 20 |
| 3 | Attack Speed | SPD | `#33FF88` | +8% fire rate multiplier | 0 | 15 |
| 4 | Range | RNG | `#3399FF` | +15% weapon range, +5% projectile speed | 0 | 15 |

### Secondary Stats (right column)

| # | Axis | Abbr | Color | Effect Per Point | Base Value | Cap |
|---|------|------|-------|-----------------|------------|-----|
| 5 | Crit Chance | CRT | `#FFDD44` | +5% critical hit chance | 0% | 60% |
| 6 | Dodge | DDG | `#AA66FF` | +4% chance to negate hit | 0% | 40% |
| 7 | Move Speed | MOV | `#44DDDD` | +6% movement speed | 100% | 200% |
| 8 | Luck | LCK | `#FF88CC` | +3% rare drop chance, +2% reroll discount | 0 | 15 |

---

## Stats Panel Layout

```
┌────────────────┐
│  PRIMARY       │
│                │
│ ❤ HP    12    │  ← Red, large
│ ⚔ DMG    +3   │  ← Orange
│ ⏱ SPD    +24% │  ← Green
│ 🎯 RNG    +15% │  ← Blue
│                │
│  SECONDARY     │
│                │
│ 💥 CRT    15%  │  ← Gold
│ 👟 DDG    8%   │  ← Purple
│ 🏃 MOV   112%  │  ← Teal
│ 🍀 LCK   +2   │  ← Pink
│                │
│  Gold:   35    │  ← Gold counter
│  Wave:   5/20  │  ← Progress
└────────────────┘
```

- Position: right side of screen, 160px wide
- Background: semi-transparent dark panel
- Font size: 14px stat name, 18px value
- Icons: emoji or geometric symbols
- Gold and wave info at bottom

---

## Stat Calculation

Stats apply in this order:
1. Base values set
2. Permanent upgrades (star shop) applied
3. Equipped items applied additively
4. Weapon bonuses applied (per-weapon)
5. Temporary buffs (from items) applied multiplicatively last

### Examples

**Damage calculation:**
```
base_damage = weapon_base + (DMG_stat * 1.0)
crit_multiplier = 2.0  (fixed)
final_damage = base_damage * (crit_roll ? crit_multiplier : 1.0)
```

**Attack speed calculation:**
```
base_fire_rate = weapon_base_fire_rate
speed_multiplier = 1.0 + (SPD_stat * 0.08)
final_fire_rate = base_fire_rate * speed_multiplier
```

**Dodge calculation:**
```
dodge_chance = DDG_stat * 0.04
if random() < dodge_chance: negate damage
```

---

## Integration Points

| File | Change |
|------|--------|
| `scripts/state.lua` | Add `stat_axes_` table with all 8 values |
| `scripts/stats_panel.lua` | NEW — panel renderer |
| `scripts/ui.lua` | Add panel to game screen (right side) |
| `scripts/player.lua` | Apply stats to damage/movement calculations |
| `scripts/weapons.lua` (P4) | Read stats for fire rate/damage |
| `scripts/i18n.lua` | Add stat name abbreviations |

---

## State Structure

```lua
state.statAxes_ = {
    maxHP = 10,     -- +1 per point
    damage = 0,     -- +1 flat per point
    attackSpeed = 0, -- +8% per point
    range = 0,      -- +15% per point
    critChance = 0, -- +5% per point (display as %)
    dodge = 0,      -- +4% per point (display as %)
    moveSpeed = 0,  -- +6% per point (display as % of base)
    luck = 0,       -- +3% rare drop per point
}
```

[PLACEHOLDER] Cap values need playtest validation in P5. Current caps are conservative to prevent broken builds.
