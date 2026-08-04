# SHOP_SPEC.md — Wave Shop Mechanics

> Canonical spec for the inter-wave shop.
>
> Last updated: 2026-08-04

---

## Purpose

Give the player a spending decision between every wave. The shop is the primary gold sink and the main vector for build expression. Without a functioning shop, the Brotato transition is incomplete.

## Player Experience Goal

> "I have X gold. Do I buy this weapon that upgrades my build, save for a legendary, or reroll to hunt for a specific stat item?"

The shop should create tension between short-term power (buy now) and long-term optimization (save/reroll).

---

## Trigger

Shop appears after every wave ends (all enemies dead or wave timer expires).

Current flow (to modify):
```
Wave ends → EndWave() → advance wave → wave_pause screen → next wave
```

Target flow:
```
Wave ends → EndWave() → shop screen (15s or manual skip) → next wave
```

---

## Shop Screen Layout

```
┌─────────────────────────────────┐
│  SHOP · Wave 5/20               │ ← header
│                                 │
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │Blade │ │ Bow  │ │Staff │   │ ← 3 weapon slots (top row)
│  │ 18g  │ │ 22g  │ │ 30g  │   │
│  └──────┘ └──────┘ └──────┘   │
│                                 │
│  ┌──────┐ ┌──────┐ ┌──────┐   │
│  │+2 HP │ │+1DMG │ │+3SPD │   │ ← 3 stat item slots (bottom row)
│  │ 12g  │ │ 10g  │ │ 14g  │   │
│  └──────┘ └──────┘ └──────┘   │
│                                 │
│  Gold: 35   [REROLL 2g] [SKIP] │ ← action bar
│  Timer: 12s                     │
└─────────────────────────────────┘
```

- 6 item slots: 3 weapons + 3 stat items
- Each slot shows: icon, name, stat effects, price
- Equipped weapons show at bottom with sell/recycle option

---

## Shop Actions

### Buy Item
- Click/tap an item → deduct gold → equip or add to inventory
- Weapons: go to first empty slot (or prompt to replace)
- Stat items: apply immediately, stack permanently
- Price: calculated from rarity + stat bonus (see ECONOMY.md)

### Reroll
- Cost = 1 + reroll_count_this_shop
- Refreshes ALL 6 items with new random draws
- Can reroll multiple times (cost increases)
- Locked items are preserved through reroll

### Lock
- Free action
- Marks 1 item to stay in the shop for the next wave
- Locked items persist through rerolls
- Visual: padlock icon on locked item

### Recycle (Sell)
- Sell an equipped weapon
- Returns 30% of purchase price as gold
- Frees a weapon slot
- Cannot recycle starter weapon (the free weapon from wave 1)

### Skip / Continue
- Manual skip: button to end shop early
- Auto-continue: when 15s timer expires
- Proceeds to next wave

---

## Shop State (in state.lua)

```lua
state.shop_ = {
    weapons = {},      -- { id, name, rarity, price, stats, locked }
    items = {},        -- { id, name, price, effect, locked }
    rerollCount = 0,   -- increments each reroll this shop
    timer = 15.0,      -- countdown in seconds
    isOpen = false,
}
```

---

## Item Generation Algorithm

### Weapons (3 slots)
1. Roll rarity: 60% common / 30% uncommon / 10% legendary
2. Select weapon type from pool (all 6 possible)
3. Roll stat bonuses based on rarity tier
4. Calculate price: base_price + stat_bonus * 5
5. If identical to an already-equipped weapon, re-roll rarity (not type)

### Stat Items (3 slots)
1. Select stat axis randomly from 8 axes
2. Roll magnitude: 80% +1 / 15% +2 / 5% +3
3. Calculate price: magnitude * 4 + random(0, 3)
4. No duplicates in same shop

---

## Integration Points

| File | Change Needed |
|------|--------------|
| `scripts/shop.lua` | NEW — shop screen builder + logic |
| `scripts/state.lua` | Add `shop_` sub-table and `gold_` |
| `scripts/ui.lua` | Add `"shop"` screen to `M.build()` |
| `scripts/waves.lua` | Route to shop instead of wave_pause after wave clear |
| `scripts/i18n.lua` | Add shop UI strings |
| `scripts/main.lua` | Wire shop into `HandleUpdate` |

---

## Edge Cases
- Player has 0 gold: reroll/lock buttons disabled (skip only option)
- All weapon slots full: buying a weapon shows "replace?" confirm
- Shop timer hits 0 during purchase animation: complete the purchase, then advance
- Player dies during shop: not possible (shop is between waves, no enemies)
