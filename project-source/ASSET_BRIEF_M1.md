# M1 Visual Asset Brief — 几何突围

This brief is the M1 asset handoff for Perplexity Canvas, Canva, or another image tool. Generate assets as original geometric game art, not references or copies of existing games.

Read `ART_STYLE.md` first. All M1 assets must follow the **Neon Vector Geometry** baseline there.

## Art direction

- Geometry-first sci-fi survivor style: triangles, hexagons, orbit rings, shards, angular circuits, radial hazard marks, and polygon armor.
- Dark synthetic arena: deep navy base, electric cyan player, violet energy, magenta/red enemies, teal alternate threats, orange-gold elites/bosses, and restrained gold upgrades.
- Clean geometric silhouettes with high contrast and readable shapes at phone size.
- Slight neon edge glow, limited bloom, no photorealism, no text embedded in sprites.
- Transparent backgrounds for icons and sprites; banners may use a full-bleed arena background.
- Keep visual language consistent with the existing UI: dark panels, cyan player, gold upgrades, magenta offensive effects.
- Treat survivor-game intensity as a readability target: many enemies can be on screen, but every role must remain visually separable.

## Asset set

| ID | Asset | Size | Format | Purpose |
|---|---|---:|---|---|
| icon-app | App icon: glowing geometric triangle breaking through a hexagonal frame | 1024×1024 | PNG, opaque | TapTap/app identity |
| banner-main | Horizontal arena banner with Vector Triangle centered, enemy silhouettes at the edges, empty space for UI title | 1920×1080 | PNG, opaque | Store page and title screen |
| sprite-player | Vector Triangle chassis, four directions plus idle | 64×64 each frame | PNG, transparent | Player visual replacement |
| sprite-chaser | Compact red-magenta pursuing node, idle and hit frame | 48×48 each frame | PNG, transparent | Basic enemy |
| sprite-skimmer | Teal curved skimmer node, idle and hit frame | 48×48 each frame | PNG, transparent | Strafing enemy |
| sprite-charger | Orange pointed charger, idle, telegraph, and impact frame | 64×64 each frame | PNG, transparent | Telegraphing enemy |
| sprite-elite | Larger orange-gold elite core, idle and hit frame | 80×80 each frame | PNG, transparent | Elite enemy |
| sprite-boss | Hex-core boss with idle, telegraph, impact, damaged, and enraged states | 160×160 each frame | PNG, transparent | First boss visual direction |
| icon-modules | Six separate module icons: beam, orbit seed, pulse bloom, shell lantern, anchor mine, vector hook | 128×128 each | PNG, transparent | Upgrade cards and HUD |
| vfx-evolution | Gold Lv3 burst and violet Lv5 burst, separate transparent layers | 256×256 | PNG, transparent | Evolution feedback |
| arena-main | Top-down dark synthetic arena with quiet center and geometric edge pressure | 1920×1080 | PNG, opaque | Main combat background |

## Canvas prompt template

```text
Create an original game asset for 几何突围 (Geometry Breakout), a mobile-first top-down sci-fi geometric arena survivor roguelite. Use Neon Vector Geometry: crisp orthographic geometric shapes, deep navy synthetic arena language, electric cyan player energy, magenta/red enemy pressure, teal alternate threats, orange-gold elite/boss danger, restrained gold upgrades, violet sci-fi energy, clean silhouettes, subtle neon edge glow, readable at phone size, no text, no logos, no copied characters, no photorealism.

Asset: [DESCRIBE ONE ASSET]
Composition: [CENTERED / FULL BLEED / SPRITE SHEET]
Output: [DIMENSION], [PNG], [TRANSPARENT OR OPAQUE]
Keep all important geometry inside a 10% safe margin.
```

## Recommended prompts

### Player sprite sheet

```text
Create original top-down character sprites for 几何突围 / Geometry Breakout using the Neon Vector Geometry style. Subject: playable Vector Triangle chassis with a glowing cyan core, angular armor plates, orbit-module sockets, violet thrust/phase trails, and restrained gold upgrade details. Output: transparent PNG sprite sheet, 64x64 per frame, equal spacing, consistent center alignment, clean transparent edges. Frames: idle, move up, move right, move down, move left, hit/damaged, upgraded/powered. Keep each frame inside a 10% safe margin.
```

### Boss sprite sheet

```text
Create original top-down boss enemy sprites for 几何突围 / Geometry Breakout using the Neon Vector Geometry style. Subject: large orange-gold hex-core boss with rotating polygon armor, blade-like geometric arms, magenta unstable core, red attack emitters, violet cracks, and fractured shield rings. Output: transparent PNG sprite sheet, 160x160 per frame, equal spacing, consistent center alignment, clean transparent edges. Frames: idle, attack telegraph, attack impact, damaged/cracked, enraged. Keep each frame inside a 10% safe margin.
```

### Arena background

```text
Create an original top-down arena background for 几何突围 / Geometry Breakout using the Neon Vector Geometry style. Deep navy synthetic floor, faint hex grid, angular circuit lanes, radial hazard rings, darker edge pressure, violet/magenta danger zones near the perimeter, cyan energy lanes, restrained gold upgrade glow points. Keep the center quieter and readable for dense survivor combat. Output: opaque 1920x1080 PNG, no text, no logo, no characters, important details inside a 10% safe margin.
```

## Sprite constraints

- Use a consistent orthographic top-down view.
- Keep the visual center aligned across every frame.
- Do not add shadows outside the transparent canvas.
- Use identical canvas dimensions for all frames in one animation.
- Export individual PNGs or a clearly labelled sprite sheet; do not rely on CSS cropping until the asset format is verified in Maker.

## Acceptance checklist

- Recognizable at 32–64 px.
- Transparent edges are clean with no white halo.
- Player, enemy, module, and rarity colors remain distinct for color-safe play.
- Arena center remains quiet enough for dense combat readability.
- Boss and charger attack telegraphs are recognizable before impact.
- No embedded text; localization stays in the game UI.
- Asset names follow `category_subject_variant_v001.png`.
- Store banner leaves title-safe space for localized Chinese and English text.
