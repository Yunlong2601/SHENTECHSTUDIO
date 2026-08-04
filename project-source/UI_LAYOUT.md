# Geometry Breakout UI Layout

> Last updated: 2026-08-04 (UI Bug Fix — HUD rearrangement, popup overflow, safe areas)

## UX goal

At any moment, the player should answer three questions without pausing:

1. How much Integrity do I have?
2. How close am I to the next upgrade?
3. What is happening in this wave, and what weapons are active?

The HUD is mobile-first, but remains readable on PC and large tablets.

## Safe area constants

- **Top safe area**: 38px — reserved for TapTap Maker dev banner on non-game screens; all HUD/popups start below this.
- **Bottom safe area**: 24px (mobile) / 44px (PC hints) — ensures controls are not cut off by device bezels/home indicators.
- **Side padding**: 16px — all HUD elements stay within left/right bounds.

## In-run layout (Brotato transition — current)

```text
┌──────────────────────────────────────────────────────────────┐
│ [Integrity | Score | Fragments]            [████ stats_panel ████]
│ [Level · shards to next upgrade]           [HP / DMG / SPD / RNG ]
│ [══════ XP bar ═══════════]                [CRT / DDG / MOV / LCK ]
│ [Shell: 0/0]                               [───────────────────]
│ [Crimson Arena · Lv.1 · 1/6 波]            [G 0                ]
│ [武器：Blade]                                                │
│                                                              │
│                    GAMEPLAY ARENA                            │
│                                                              │
│  virtual joystick                                            │
│  appears where touched                                       │
│                                                              │
│         WASD / 方向键移动 (PC)                                  │
│         触摸左侧拖动移动 (Mobile)                                │
└──────────────────────────────────────────────────────────────┘
```

- **Left statusCard** (44% width, max 420px): Integrity/score/fragments → Level/XP bar → Shell → Wave name/level/time/field → Weapons list.
- **Right stats_panel** (absolute, 140px wide, right=16, top=38): PRIMARY (HP/DMG/SPD/RNG) + SECONDARY (CRT/DDG/MOV/LCK) + Gold.
- Gold is displayed **only in stats_panel** — no duplicate gold counter.
- Wave/map info is integrated into statusCard (no separate waveCard).

## Popup overflow rules

All modal screens (upgrade, shop, cosmetics, archive) MUST include:

- `maxHeight = "82%"` or `"85%"` to prevent overflow on narrow/portrait screens.
- `overflow = "scroll"` to allow access to all content when it exceeds viewport height.
- Cards/buttons inside popups must stay within the visible panel.

## Stage select layout

Arena cards show a **summary** of total levels + boss indicator, not a horizontal row of per-level tags:

```text
┌──────────────────────────────────────────────┐
│ 🟦 Crimson Arena                      10 关卡│
│    10 关卡 · 含 Boss                       │
└──────────────────────────────────────────────┘
```

10 individual "关卡 N · 6 波" tags were removed (horizontal overflow risk).

## Responsive rules

- Use percentage widths with maximum widths for HUD cards.
- Keep controls and buttons at least 48 base pixels where possible.
- Center modal screens instead of relying on their natural top-left position.
- Keep the gameplay arena full-screen and use `UI.Scale.DEFAULT`.
- Test portrait and landscape phone layouts, tablet layouts, iPhone, and iPad.
- Keep text concise on narrow screens; move detailed information to pause and summary screens.
- Long weapon stat text is split into multiple lines (DMG / CD on separate lines) to prevent card overflow.

## Implementation status

- [x] Centered non-game screens
- [x] Persistent in-run Integrity/status card
- [x] Explicit XP progress bar
- [x] Explicit remaining-fragments-to-upgrade text
- [x] Right stats panel (8 axes + gold)
- [x] Wave/field/weapon info merged into statusCard
- [x] Wave pause statistics panel
- [x] Mobile virtual joystick
- [x] Multi-weapon summary layout
- [x] Arena modifier badge and wave-pause disclosure
- [x] Session-safe Calibration Archive screen
- [x] Popup overflow protection (maxHeight + scroll)
- [x] Safe area top/bottom margins
- [x] Stage select summary (no horizontal level overflow)
