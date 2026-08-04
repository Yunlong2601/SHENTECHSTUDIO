# Geometry Breakout UI Layout

## UX goal

At any moment, the player should answer three questions without pausing:

1. How much Integrity do I have?
2. How close am I to the next upgrade?
3. What is happening in this wave, and what module is active?

The HUD is mobile-first, but remains readable on PC and large tablets.

## In-run layout

```text
┌──────────────────────────────────────────────────────────────┐
│ [Integrity | Defeated | Data Fragments]   [Wave | Time]       │
│ [Level · shards to next upgrade]           [Module + level]   │
│ [================ XP progress ============]                  │
│                                                              │
│                    GAMEPLAY ARENA                            │
│                                                              │
│  virtual joystick                         reserved ability    │
│  appears where touched                   space                │
│                                                              │
│             PC hint / touch hint                             │
└──────────────────────────────────────────────────────────────┘
```

- The upper-left status card contains Integrity, defeated count, Data Fragments, level, and the XP bar.
- The upper-right card contains wave, elapsed time, and the equipped module.
- The arena remains unobstructed in the center.
- The left touch area is reserved for movement.
- The right side remains available for future active abilities.
- The bottom hints are secondary and should never compete with the XP bar.

## Wave pause layout

The wave pause card is centered on every viewport. It shows:

- Wave completion state
- Next wave number
- Current Integrity
- Current level and fragments needed for the next upgrade
- Data Fragments and defeated count
- Current module and level
- Continue button

This prevents the pause screen from becoming an information dead end.

## Responsive rules

- Use percentage widths with maximum widths for HUD cards.
- Keep controls and buttons at least 48 base pixels where possible.
- Center modal screens instead of relying on their natural top-left position.
- Keep the gameplay arena full-screen and use `UI.Scale.DEFAULT`.
- Test portrait and landscape phone layouts, tablet layouts, iPhone, and iPad.
- Keep text concise on narrow screens; move detailed information to pause and summary screens.

## Prototype 03 systems

- The upper-right card now includes the deterministic wave modifier: Compression, Surge, or Overclock.
- Wave pause repeats the modifier and lists every active module, not only the most recently upgraded one.
- Summary lists simultaneous Trace Beam, Orbit Seed, and Pulse Bloom levels and exposes the Calibration Archive.
- Calibration Archive is centered and safe on narrow screens; it is explicitly session-only until a supported persistence API is verified.
- Combat telegraphs use high-contrast charger state and surge feedback text without adding generated assets.

## Implementation status

- [x] Centered non-game screens
- [x] Persistent in-run Integrity/status card
- [x] Explicit XP progress bar
- [x] Explicit remaining-fragments-to-upgrade text
- [x] Wave/time card
- [x] Module card
- [x] Wave pause statistics panel
- [x] Mobile virtual joystick
- [x] Multi-module summary layout
- [x] Arena modifier badge and wave-pause disclosure
- [x] Session-safe Calibration Archive screen (explicitly labeled fallback)
