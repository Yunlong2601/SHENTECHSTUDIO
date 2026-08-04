# Geometry Breakout / 几何突围 Terminology

> Chinese-first terminology source. Add every new player-facing term here before using it in UI, design docs, or data files.
>
> Translation policy: preserve the gameplay meaning and use the same English term everywhere.
>
> Last updated: 2026-08-04 (Brotato terms added)

## Product Identity

| Chinese | English | Usage |
|---|---|---|
| 几何突围 | Geometry Breakout | Official game title |
| 几何体 | Geometric Form | General playable/entity category |
| 突围 | Breakout | Central run objective |

## Core Gameplay (Brotato Transition)

| Chinese | English | Usage |
|---|---|---|
| 武器 | Weapon | Equippable auto-fire item (replaces "模块/Module") |
| 道具 | Item | Equippable stat-boosting item |
| 商店 | Shop | Inter-wave purchase screen |
| 金币 | Gold | In-run currency for shop purchases |
| 重摇 | Reroll | Refresh shop items (costs gold) |
| 锁定 | Lock | Preserve a shop item for next wave (free) |
| 回收 | Recycle | Sell an equipped weapon for gold |
| 属性 | Stat | Character attribute (HP, DMG, SPD, etc.) |
| 稀有度 | Rarity | Item quality tier (Common/Uncommon/Legendary) |
| 波次 | Wave | Timed combat phase |
| 升级 | Upgrade | Level-up card choice |
| 四选一 | Four-choice selection | Upgrade format (upgraded from 3) |

## Stat Axes (8 Total)

| Chinese | English | Abbr |
|---|---|---|
| 生命值 | Max HP | HP |
| 伤害 | Damage | DMG |
| 攻击速度 | Attack Speed | SPD |
| 范围 | Range | RNG |
| 暴击率 | Crit Chance | CRT |
| 闪避 | Dodge | DDG |
| 移动速度 | Move Speed | MOV |
| 幸运 | Luck | LCK |

## Resources & Progression

| Chinese | English | Usage |
|---|---|---|
| 金币 | Gold | In-run shop currency (source: enemy kills, wave clears) |
| 经验 | XP / Experience | In-run level-up resource |
| 星星 | Star | Permanent progression currency (earned on run completion) |
| 星币商店 | Star Shop | Permanent upgrade shop |

## Legacy Terms (Still Active Until P4)

| Chinese | English | Note |
|---|---|---|
| 模块 | Module | Being replaced by "武器/Weapon" in P4 |
| 模式碎片 | Pattern Shard | Being replaced by "XP" in P3 |
| 数据碎片 | Data Fragment | Legacy run currency; may be deprecated |
| 完整度 | Integrity | May be renamed to "HP" or "生命值" |

## UI & Localization Rules (unchanged)

1. All player-facing strings use stable keys in `scripts/i18n.lua`.
2. Chinese (zh_CN) is the design language; English (en) is the first target.
3. Translate each feature when added; don't postpone.
4. English text may be longer — buttons/cards must be flexible.
5. No player-facing text in images.
6. Preserve placeholders exactly: `%d`, `%s`.
7. New ambiguous terms → add here before implementing.
