# M1 Visual Asset Brief — 几何突围

This brief is the canonical handoff for Perplexity Canvas or another image tool. Generate assets as original geometric game art, not references or copies of existing games.

## Art direction

- Dark synthetic arena: deep navy, electric cyan, violet, magenta, and restrained gold.
- Clean geometric silhouettes with high contrast and readable shapes at phone size.
- Slight neon edge glow, limited bloom, no photorealism, no text embedded in sprites.
- Transparent backgrounds for icons and sprites; banners may use a full-bleed arena background.
- Keep visual language consistent with the existing UI: dark panels, cyan player, gold upgrades, magenta offensive effects.

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
| icon-modules | Six separate module icons: beam, orbit seed, pulse bloom, shell lantern, anchor mine, vector hook | 128×128 each | PNG, transparent | Upgrade cards and HUD |
| vfx-evolution | Gold Lv3 burst and violet Lv5 burst, separate transparent layers | 256×256 | PNG, transparent | Evolution feedback |

## Canvas prompt template

```text
Create an original game asset for 几何突围 (Geometry Breakout), a mobile-first top-down geometric arena survival roguelite. Use dark synthetic sci-fi geometry, deep navy background where applicable, electric cyan/violet/magenta accents, restrained gold for upgrades, crisp silhouette, readable at small phone-screen scale, subtle neon edge glow, no words, no logos, no gradients that destroy silhouette, no characters from existing games.

Asset: [DESCRIBE ONE ASSET]
Composition: [CENTERED / FULL BLEED / SPRITE SHEET]
Output: [DIMENSION], [PNG], [TRANSPARENT OR OPAQUE]
Keep all important geometry inside a 10% safe margin.
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
- No embedded text; localization stays in the game UI.
- Asset names follow `category_subject_variant_v001.png`.
- Store banner leaves title-safe space for localized Chinese and English text.
