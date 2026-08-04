# Geometry Breakout Art Style

> Canonical visual direction for 几何突围 / Geometry Breakout.
>
> All future asset prompts, UI polish, VFX, enemy silhouettes, store art, and generated placeholder art should follow this baseline unless a later durable decision replaces it.

## Style Name

**Neon Vector Geometry**

Geometry Breakout should look like a premium mobile survivor game built from clean synthetic geometry: triangles, hexagons, rings, shards, orbit lines, radial hazard marks, and angular circuit forms.

The art must make the game feel original. It may learn from the readability and enemy pressure of survivor-like games, but it must not copy their characters, layouts, UI, enemies, colors, or marketing composition.

## Core Visual Promise

> A cyan vector chassis fights through hostile abstract geometry inside a collapsing neon simulation arena.

Every visual should support at least one of these ideas:

1. **Geometry is the world:** shapes are not decoration; they are the characters, enemies, upgrades, arena rules, and combat language.
2. **Readable survivor combat:** the player can identify danger, pickups, modules, and boss states instantly on a phone screen.
3. **Synthetic sci-fi energy:** the world feels digital, engineered, unstable, and precise.
4. **Buildcraft feedback:** upgrades visibly add orbitals, plates, glow layers, rings, shards, and new geometric motion.

## Palette

| Role | Color Direction | Usage |
|---|---|---|
| Background | Deep navy / black-blue | Arena floor, void, panel base |
| Player | Electric cyan | Vector Triangle, player bullets, safe movement cues |
| Player secondary | Violet | Power trails, phase, resonance, advanced VFX |
| Enemy basic | Magenta / red-magenta | Chasers, damage pressure, hostile nodes |
| Enemy special | Teal | Skimmers, strafers, alternate threat class |
| Charger / elite / boss | Orange / orange-gold | Telegraphing threats, elite armor, boss danger |
| Upgrades / rarity | Restrained gold | Module evolution, rewards, rare pickups, highlight accents |
| Neutral UI | Dark slate / blue-gray | Cards, panels, dividers, muted structure |

Rules:

- Keep player cyan distinct from enemy magenta/orange.
- Use gold sparingly so upgrades and evolution moments feel valuable.
- Avoid one-note blue/purple screens; magenta, teal, orange, and gold should create clear role contrast.
- Backgrounds may glow, but gameplay silhouettes must stay readable.

## Shape Language

| Category | Primary Shapes | Notes |
|---|---|---|
| Player: Vector Triangle | Triangle, chevrons, small orbit sockets | Fast, engineered, directional |
| Chaser enemy | Compact red-magenta node, small jagged polygons | Direct pressure, easy to recognize in groups |
| Skimmer enemy | Teal curved wedge / crescent geometry | Strafing, lateral threat |
| Charger enemy | Orange spear, arrowhead, warning line | Telegraph first, impact second |
| Elite / boss | Hex-core, rotating polygon armor, blade arms | Large, radial, phase-readable |
| Modules | Simple iconic geometry | One idea per icon; readable at 32-64 px |
| Arena | Hex grid, radial rings, angular circuits | Structured but quieter in the center |

## Readability Rules

1. Player, enemy, projectile, pickup, and UI highlight colors must be separable at phone size.
2. Combat sprites should remain readable at 32-64 px.
3. Boss sprites should remain readable at 96-160 px.
4. Prefer crisp silhouettes over dense internal detail.
5. Use glow as an edge accent, not as the silhouette itself.
6. Avoid embedded text in images; localization stays in UI.
7. Keep transparent sprite edges clean with no white halo.
8. Keep arena center less busy than arena edges.
9. Make attack telegraphs geometric and obvious: lines, cones, rings, expanding polygons.
10. Do not use photorealism, cute mascot characters, medieval fantasy, military realism, or organic monster anatomy as the base style.

## Asset Direction

### Player

The first chassis, **Vector Triangle**, should be a cyan triangular combat craft/form with a glowing core, angular armor plates, small orbit-module sockets, and subtle violet thrust or phase trails.

Upgrade visuals may add:

- Extra orbit rings
- Cyan/violet reactor lines
- Gold edge plates
- More visible module sockets
- Shield arcs for Shell Lantern
- Trail points for Vector Hook

### Enemies

Enemies should look like hostile geometry, not humanoids or animals.

- **Chaser:** compact magenta node with jagged pursuit energy.
- **Skimmer:** teal curved wedge with side-slip motion.
- **Charger:** orange spear/arrowhead with strong telegraph state.
- **Boss:** orange-gold hex-core with rotating polygon armor, magenta unstable core, red attack emitters, and violet cracks.

### Arena

The arena is a dark synthetic simulation space. It should use a deep navy base, faint hex grids, angular circuit lanes, radial hazard rings, and darker edge pressure. The center must remain readable for dense combat.

Arena backgrounds should not compete with sprites. Put stronger detail at edges and in low-contrast floor patterns.

### UI

UI should feel like a dark synthetic control layer:

- Dark panels
- Cyan current-state highlights
- Gold upgrade/reward accents
- Magenta warning or damage accents
- Compact, readable mobile-first cards
- No decorative clutter that competes with combat

## Prompt Baseline

Use this block as the opening for future asset generation:

```text
Create original game art for 几何突围 / Geometry Breakout, a mobile top-down sci-fi geometric arena survivor roguelite. Use the Neon Vector Geometry style: crisp orthographic shapes, deep navy synthetic arena language, electric cyan player energy, magenta/red enemy pressure, teal alternate threats, orange-gold elite/boss danger, restrained gold upgrades, violet sci-fi energy, clean silhouettes, subtle neon edge glow, readable at phone size, no text, no logos, no copied characters, no photorealism.
```

Add one of these output clauses:

```text
For a sprite: transparent PNG sprite sheet, consistent center alignment, equal frame size, clean transparent edges, no shadows outside the sprite.
```

```text
For an arena: opaque 1920x1080 top-down background, darker edge detail, quieter readable center, no characters, no text.
```

```text
For UI or icons: transparent or dark-panel-ready PNG, one clear geometric idea, readable at 32-128 px, no embedded text.
```

## Negative Prompt

```text
No existing game characters, no Survivor.io clone art, no Brotato clone art, no mascot hero, no humanoid anatomy, no fantasy armor, no military realism, no photorealism, no painterly detail, no text, no logos, no busy background behind small sprites, no soft blobs replacing silhouettes, no white halo on transparent edges.
```

## Acceptance Checklist

- The image clearly belongs to a geometry-first sci-fi survivor game.
- The player reads as cyan and friendly/controllable.
- Enemies read as hostile without needing text.
- Boss attacks have distinct idle, telegraph, impact, damaged, and enraged states where applicable.
- The arena supports gameplay readability instead of showing off background detail.
- The asset can be reused as a style reference for future updates.
