# Geometry Breakout — Audio Direction Document

> Canonical audio direction for 几何突围 / Geometry Breakout.
>
> This document defines the complete sonic identity, sound effect event list, mixing strategy, implementation plan, and asset manifest for a game that currently ships with **zero audio**.
>
> All audio decisions align with the **Neon Vector Geometry** visual identity (see `ART_STYLE.md`) and the Brotato-style survivor design (see `GAME_DESIGN.md`).
>
> Last updated: 2026-08-05

---

## Table of Contents

1. [Audio Pillars](#1-audio-pillars)
2. [Sound Palette & Direction](#2-sound-palette--direction)
3. [Music Direction](#3-music-direction)
4. [SFX Event List](#4-sfx-event-list)
5. [Mixing Notes](#5-mixing-notes)
6. [Implementation Strategy](#6-implementation-strategy)
7. [Asset Manifest](#7-asset-manifest)

---

## 1. Audio Pillars

The game's design pillars (build identity, decision density, readable chaos, short mastery loop, neon vector geometry) translate into five audio principles:

### P1 — Audio Serves Readable Chaos, Not Adds to It

When 20+ enemies are on screen, the audio must help the player parse threats, not bury them in noise. This means:

- **Enemy death sounds are short (40-80ms) and decay instantly** — no lingering tails that stack into mud.
- **Weapon fire sounds are prioritized by proximity to the player** — the Blade slashing an adjacent Chaser is louder than a Bow hitting a distant Skimmer.
- **Simultaneous identical sounds are capped** — if 5 Chasers die in the same frame, play 1 death sound at normal gain, not 5 overlapping copies. Use a voice-limit gate (see Mixing Notes §5.4).
- **Critical gameplay events cut through the mix** — player damage, level-up, wave clear, and boss phase changes always have the highest priority and are never drowned out.

### P2 — Synthesis Is the Sonic Language of Geometry

The visuals are pure geometric shapes with glowing edges on dark backgrounds. The audio must feel equally **synthetic, precise, and digital**. No acoustic instruments, no orchestral textures, no Foley recordings of real-world objects. Every sound is **generated, sculpted, or synthesized** — waveforms, filters, noise bursts, FM tones — matching the engineered quality of vector geometry.

This means:
- Weapons sound like energy discharges, not arrows or steel.
- Enemies sound like digital corruption, not organic creatures.
- UI sounds like a control interface, not button clicks.
- The world hums with synthetic ambience, not wind or nature.

### P3 — Color Has a Sound

The art bible defines a precise color palette with clear semantic roles. Audio maps to these colors:

| Visual Color | Role | Sonic Character |
|---|---|---|
| Electric Cyan (Player) | Player, safe energy | Bright sine/triangle tones, clean high frequencies (2-6 kHz), crisp transients |
| Magenta/Red (Enemies) | Hostile pressure | Sawtooth/grit textures, mid-low frequencies (200-800 Hz), harsh noise bursts |
| Teal (Skimmer) | Alternate threat | Ring-modulated tones, metallic resonances (1-3 kHz) |
| Orange/Gold (Charger/Boss) | Telegraphing danger | Low sub-bass pulses (40-120 Hz) + bright alarm overtones (4-8 kHz) |
| Gold (Upgrades/Rewards) | Valuable, rare | Pure bell/mallet synthesis, harmonic overtones, warm shimmer (2-5 kHz) |
| Violet (Advanced VFX) | Power, resonance | Detuned saw pads, stereo widening, modulation |

This color-sound mapping ensures that a player can identify what is happening **by ear alone** — a skill that reinforces the "readable chaos" pillar at high enemy density.

### P4 — Dynamic Intensity Tracks the Wave Curve

Audio intensity scales with the 20-wave progression. The game starts calm and builds to a crescendo at Wave 20 (boss). This is achieved through:

- **Music layer additive** — more musical layers activate as wave numbers increase (see §3).
- **Ambient bed density** — the background hum intensifies (filter opens, layer count rises) in later waves.
- **Enemy spawn audio** — spawn cues become more aggressive in later waves (higher pitch, more grit).
- **Boss music override** — Wave 20 replaces combat music entirely with a distinct boss track.

The player should **feel** the difficulty curve rising through audio, not just through enemy count.

### P5 — Silence Is a Tool

A game with constant firing, enemy deaths, and music can become fatiguing on mobile (especially with phone speakers). Intentional silences and dynamic ducking create contrast:

- **Shop phase** — combat music stops, ambient bed drops to minimal, UI sounds take center stage. This 15-second breather is a deliberate decompression.
- **Level-up freeze** — all combat SFX duck -6dB, the upgrade fanfare plays, then combat resumes. This creates a micro-moment of focus.
- **Player death** — everything cuts to silence for 500ms, then the defeat stinger plays. The silence is the impact.

---

## 2. Sound Palette & Direction

### 2.1 Overall Sonic Identity

**Geometry Breakout sounds like a premium synthwave/cyberpunk arena — crisp digital transients, sub-bass pressure, and melodic synth arpeggios — stripped to its essential elements for mobile clarity.**

The sonic direction is **modern electronic / synthwave-adjacent**, not chiptune (too retro/nostalgic), not ambient (too passive for combat), and not EDM (too busy). It sits in the space between:

- **Geometric Dash / Geometry Dash** (for the synth energy and rhythmic precision)
- **Hyper Light Drifter** (for the atmospheric restraint and color-coded sound design)
- **Risk of Rain 2** (for the intensity layering and boss music distinction)
- **Nier: Automata** (for the emotional synth-orchestral blend in menu/victory moments)

### 2.2 Synthesis Approach

All SFX are **procedurally synthesized or designed from synthesized source material**. No field recordings, no acoustic samples. The toolchain:

- **SFX generation**: SFXR / jsfxr / Bfxr (classic game sound synthesis) or modern equivalents (LabChirp, SonantPIXEL, Blender audio synthesis). These produce short, clean, synthesized WAV files ideal for game SFX.
- **Music composition**: DAW-produced (FL Studio, Ableton, Reaper, or LMMS) using software synthesizers (Serum, Vital, Helm — all free options exist). Tracks rendered to Ogg Vorbis loops.
- **Processing**: Light reverb (short, synthetic room IR), bitcrusher (for retro grit on enemy sounds), stereo widening (for music only, not SFX — mobile mono compatibility).

### 2.3 Frequency Characteristics

| Frequency Range | Role | Usage |
|---|---|---|
| 20-80 Hz (Sub) | Boss impact, charger dash, player damage thud | Sparingly — phone speakers cannot reproduce this, but headphones/subs add physical impact |
| 80-200 Hz (Low) | Enemy death body, weapon fire weight | Moderate — provides "punch" on capable speakers |
| 200-800 Hz (Low-Mid) | Enemy presence, hostile grit | Moderate — this is where "threat" lives tonally |
| 800 Hz-3 kHz (Mid) | UI, shop interactions, ambient layers | Moderate — primary information band |
| 3-6 kHz (High-Mid) | Weapon transients, player energy, pickup clarity | High — this is where "readable chaos" cut-through happens |
| 6-12 kHz (High) | Sparkle, shimmer, gold/upgrade reward | Moderate — adds premium quality, fatiguing if overused |
| 12-20 kHz (Air) | Cymbal-like synth shimmer, ambient hiss | Low — mostly in music, minimal in SFX |

### 2.4 Mono Compatibility

Mobile phones frequently play audio in mono (single speaker, or when the phone is held in a way that blocks one speaker). Therefore:

- **All SFX are authored in mono.** Panning is applied at runtime via `SoundSource:SetPanning()` for positional cues, but the source asset is mono.
- **Music is authored in stereo** but must pass a mono fold-down test — no phase cancellation issues, no critical information lost in mono.
- **No stereo-dependent effects** (no HAAS, no mid-side-only content) in any gameplay-critical audio.

### 2.5 Reference Touchstones

| Reference | What We Take | What We Avoid |
|---|---|---|
| Geometry Dash (soundtrack) | Driving synth arpeggios, rhythmic precision, energy | Full EDM drops, vocal samples, high BPM busyness |
| Hyper Light Drifter | Color-coded sound design, atmospheric restraint, synth pads | Orchestral elements, organic textures |
| Risk of Rain 2 | Intensity layering, boss music distinction, combat readability | Heavy guitars, rock instrumentation |
| Brotato (direct competitor) | Satisfying shop sounds, clear feedback audio, minimalist SFX | Generic/stock sound effects, acoustic weapon sounds |
| Rez / Thumper | Synesthetic audio-visual sync, pulsing rhythm | Rhythm-game strict timing constraints (we are not a rhythm game) |

---

## 3. Music Direction

### 3.1 Track Inventory

The game needs **5 distinct musical pieces** plus 2 short stingers:

| # | Track Name | Game Phase | Duration (loop) | Format |
|---|---|---|---|---|
| 1 | `music_menu` | Main menu, language select, stage select | 60s loop | Ogg Vorbis |
| 2 | `music_combat_low` | Waves 1-6 (early game, calm) | 90s loop | Ogg Vorbis |
| 3 | `music_combat_mid` | Waves 7-14 (mid game, intensity rising) | 90s loop | Ogg Vorbis |
| 4 | `music_combat_high` | Waves 15-19 (late game, max intensity) | 90s loop | Ogg Vorbis |
| 5 | `music_boss` | Wave 20 (Core Breaker fight) | 120s loop | Ogg Vorbis |
| 6 | `music_shop` | Inter-wave shop (15s window, but loops for browsing) | 30s loop | Ogg Vorbis |
| 7 | `stinger_victory` | Run complete (Wave 20 boss defeated) | 8s one-shot | Ogg Vorbis |
| 8 | `stinger_defeat` | Player death | 6s one-shot | Ogg Vorbis |

**Total music duration**: ~7 minutes of looping content + 14s of stingers.

### 3.2 Music Intensity Curve

Music changes with wave intensity through **track switching**, not real-time layering (the engine does not support real-time stem mixing). The switch happens at the shop transition between waves, so there is no abrupt mid-combat music change.

```
Wave 1-6:   music_combat_low  (110 BPM, sparse arp, ambient pad, light percussion)
Wave 7-14:  music_combat_mid  (120 BPM, fuller arp, driving bass, steady percussion)
Wave 15-19: music_combat_high (130 BPM, aggressive arp, sub bass, intense percussion, lead melody)
Wave 20:    music_boss        (140 BPM, dark synth, alarm motifs, relentless rhythm)
Shop:       music_shop        (90 BPM, ambient, minimal, melodic, decompression)
```

**Crossfade**: When switching tracks, apply a 1.5s crossfade (fade out current, fade in new). The engine supports fade in/out on SoundSource. Implementation: start fade-out on current music source, at 50% point start fade-in on new source, at completion stop old source.

### 3.3 Musical Character Per Phase

#### `music_menu` — "System Boot"
- **Mood**: Calm, inviting, mysterious — a dark digital space awakening.
- **Tempo**: 100-110 BPM
- **Elements**: Slow arpeggio (triangle wave, cyan-feeling), ambient pad (detuned saw, violet-feeling), soft sub pulse, occasional bell accents (gold-feeling).
- **Reference**: Hyper Light Drifter menu theme — sparse, atmospheric, inviting.

#### `music_combat_low` — "First Contact"
- **Mood**: Focused, methodical — the player is learning, enemies are manageable.
- **Tempo**: 110 BPM
- **Elements**: Pulsing arp (saw wave), steady kick (every quarter note), light hat pattern, no lead melody. The energy is forward-moving but not urgent.
- **Reference**: Risk of Rain 2 early-stage music — driving but not overwhelming.

#### `music_combat_mid` — "Escalation"
- **Mood**: Urgent, determined — the build is coming online, threats are diversifying.
- **Tempo**: 120 BPM
- **Elements**: Fuller arp (dual oscillators), driving bass line, snare on 2 and 4, open hat on offbeats. A simple lead motif enters (3-note repeating phrase).
- **Reference**: Geometry Dash easier levels — energy without chaos.

#### `music_combat_high` — "Overclock"
- **Mood**: Intense, focused adrenaline — survival mode, the build must carry.
- **Tempo**: 130 BPM
- **Elements**: Aggressive arp, sub bass drive, full percussion (kick, snare, hats, clap), lead melody (saw, detuned). Filter sweep builds tension every 16 bars.
- **Reference**: Nier: Automata combat themes — intensity with melodic identity.

#### `music_boss` — "Core Breaker"
- **Mood**: Dark, relentless, mechanical — the arena is collapsing, the boss is alive.
- **Tempo**: 140 BPM
- **Elements**: Dark synth bass (sub + saw), alarm-like motif (alternating minor 2nd, orange-feeling), relentless percussion (four-on-the-floor + double-time hats), no traditional melody — pure texture and rhythm. A melodic counter-theme enters at 50% boss HP to signal the enrage phase.
- **Reference**: Thumper boss themes — dark, rhythmic, oppressive.

#### `music_shop` — "Recalibrate"
- **Mood**: Breathing room, curiosity, decision-making — a calm space between storms.
- **Tempo**: 90 BPM
- **Elements**: Ambient pad (warm), gentle arpeggio (triangle, cyan-feeling), soft sub pulse, no percussion. Melodic, contemplative. The player should feel safe and thoughtful.
- **Reference**: Brotato shop music — minimal, non-intrusive, slightly curious.

#### `stinger_victory` — "Breakthrough"
- **Mood**: Triumph, relief, earned victory.
- **Elements**: Rising arpeggio → resolved major chord (synth pad) → bell shimmer (gold-feeling) → fade. 8 seconds total.
- **Reference**: Classic victory fanfares, but synthesized, not orchestral.

#### `stinger_defeat` — "System Failure"
- **Mood**: Sudden, cold, final — the simulation has collapsed.
- **Elements**: 500ms silence → low sub drop → descending minor arp → digital glitch noise → cutoff. 6 seconds total.
- **Reference**: Nier: Automata game-over stinger — cold, synthetic, final.

### 3.4 Loop Structure

All looping tracks follow this structure for seamless looping:

- **Loop point**: The track is composed so that the final bar resolves cleanly into the first bar. The audio file's end-to-start transition must be sample-accurate.
- **No fade in/out on the file itself** — the loop is hard-edged. Runtime fade is handled by the engine's SoundSource fade.
- **Loop length**: 90s for combat tracks is intentional — long enough that the player doesn't notice repetition during a 30s wave, short enough to keep file size reasonable.
- **Ogg Vorbis loop**: When loading as Ogg Vorbis, ensure the encoder does not add padding samples at the loop boundary. Test with `Sound:SetLooped(true)`.

### 3.5 File Size Budget

| Track | Format | Est. Bitrate | Est. Size |
|---|---|---|---|
| `music_menu` (60s) | Ogg Vorbis, 128kbps | 128 kbps | ~960 KB |
| `music_combat_low` (90s) | Ogg Vorbis, 128kbps | 128 kbps | ~1.4 MB |
| `music_combat_mid` (90s) | Ogg Vorbis, 128kbps | 128 kbps | ~1.4 MB |
| `music_combat_high` (90s) | Ogg Vorbis, 128kbps | 128 kbps | ~1.4 MB |
| `music_boss` (120s) | Ogg Vorbis, 128kbps | 128 kbps | ~1.9 MB |
| `music_shop` (30s) | Ogg Vorbis, 128kbps | 128 kbps | ~480 KB |
| `stinger_victory` (8s) | Ogg Vorbis, 128kbps | 128 kbps | ~128 KB |
| `stinger_defeat` (6s) | Ogg Vorbis, 128kbps | 128 kbps | ~96 KB |
| **Total Music** | | | **~8.2 MB** |

If file size is a concern, music bitrate can be reduced to 96kbps with minimal perceptible quality loss on mobile speakers (~6.1 MB total).

---

## 4. SFX Event List

### 4.1 Event Naming Convention

All audio events follow this naming convention:

```
[category]_[source]_[action]_[variant]
```

- **category**: `sfx` (sound effect), `ui` (interface), `mus` (music cue), `amb` (ambient)
- **source**: the entity or system producing the sound (`weapon_blade`, `enemy_chaser`, `player`, `shop`, `wave`, `boss`)
- **action**: what happened (`fire`, `hit`, `death`, `spawn`, `damage`, `levelup`, `open`, `close`, `buy`, `reroll`, etc.)
- **variant**: optional variation index (`v1`, `v2`, `v3`) — implemented as separate Sound resources, randomly selected at play time

Examples: `sfx_weapon_blade_fire_v1`, `ui_shop_buy`, `amb_arena_hum_low`

### 4.2 Complete SFX Event Table

#### 4.2.1 Weapon Events (6 weapons × fire + hit)

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `sfx_weapon_blade_fire` | Blade weapon auto-fires (slash arc) | EFFECT | High | Metallic swoosh, 80-120ms. Pitch randomization ±3%. 2 variations (v1: brighter, v2: darker). High-pass at 1kHz to avoid mud with bass-heavy enemies. | WAV, mono, 22050 Hz |
| `sfx_weapon_bow_fire` | Bow weapon fires (single arrow) | EFFECT | High | Short energy draw + release, 100-150ms. Ascending pitch sweep. 2 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_staff_fire` | Staff weapon fires (seeking projectile) | EFFECT | High | Resonant ping + trailing tone, 120-180ms. Bell-like FM synthesis. 2 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_mace_fire` | Mace weapon fires (360° spin) | EFFECT | High | Low-frequency whoosh sweep, 150-200ms. Sub-bass emphasis (60-120 Hz). 1 variation (the spin is continuous, pitch tracks rotation speed). | WAV, mono, 22050 Hz |
| `sfx_weapon_crossbow_fire` | Crossbow fires (piercing bolt) | EFFECT | High | Sharp energy crack + tail, 80-100ms. Bright transient, quick decay. 2 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_throwing_fire` | Throwing weapon fires (3-spread daggers) | EFFECT | High | Triple-burst energy release, 100-140ms. Three distinct clicks within the sound. 2 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_blade_hit` | Blade hits enemy | EFFECT | Medium | Sharp metallic impact, 40-60ms. High-frequency crack. 3 variations (pitch randomization ±5%). | WAV, mono, 22050 Hz |
| `sfx_weapon_bow_hit` | Bow arrow hits enemy | EFFECT | Medium | Energy impact puncture, 40-60ms. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_staff_hit` | Staff projectile hits enemy | EFFECT | Medium | Resonant burst, 50-70ms. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_mace_hit` | Mace hits enemy | EFFECT | Medium | Heavy impact thud + crunch, 60-80ms. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_crossbow_hit` | Crossbow bolt pierces enemy | EFFECT | Medium | Piercing zing + impact, 50-70ms. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_throwing_hit` | Throwing dagger hits enemy | EFFECT | Medium | Quick energy puncture, 30-50ms. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_weapon_crit` | Any weapon crits (2x damage) | EFFECT | High | Bright energy burst + harmonic shimmer, 80-100ms. Plays IN ADDITION to the weapon hit sound. 1 variation. Distinguishable from normal hits by pitch (1 octave up) + added gold-frequency content (4-5 kHz). | WAV, mono, 22050 Hz |

**Weapon SFX count**: 14 events, ~38 WAV files (including variations)

#### 4.2.2 Enemy Events (5 types × spawn + death + special)

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `sfx_enemy_chaser_spawn` | Chaser spawns at arena edge | EFFECT | Low | Short digital corruption blip, 40-60ms. Magenta grit (sawtooth, 300-500 Hz). 2 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_chaser_death` | Chaser killed | EFFECT | Medium | Quick digital shatter, 50-80ms. Descending pitch sweep + noise burst. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_skimmer_spawn` | Skimmer spawns | EFFECT | Low | Ring-modulated blip, 50-70ms. Teal metallic resonance (1-3 kHz). 2 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_skimmer_death` | Skimmer killed | EFFECT | Medium | Metallic break + resonance decay, 60-90ms. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_charger_spawn` | Charger spawns | EFFECT | Low | Low alarm pulse, 80-100ms. Orange sub-bass + high overtone. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_enemy_charger_telegraph` | Charger pauses before dash | EFFECT | High | Tension riser, 200-300ms. Rising pitch + filtering sweep. Signals imminent dash — player must hear this clearly. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_enemy_charger_dash` | Charger executes dash | EFFECT | High | Fast whoosh + impact-ready bass, 100-150ms. 2 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_charger_death` | Charger killed | EFFECT | Medium | Heavy digital collapse, 80-120ms. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_splitter_spawn` | Splitter spawns | EFFECT | Low | Layered blip (two tones), 50-70ms. Green frequency character (500-800 Hz). 2 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_splitter_death` | Splitter killed (splits into 2) | EFFECT | Medium | Split sound: one burst + two smaller bursts, 100-150ms total. 2 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_splitter_fragment_death` | Splitter fragment killed | EFFECT | Low | Quick shatter, 30-50ms. 2 variations. Lower gain than full splitter death. | WAV, mono, 22050 Hz |
| `sfx_enemy_shooter_spawn` | Shooter spawns | EFFECT | Low | Dark electronic pulse, 60-80ms. Purple frequency (200-400 Hz + 3-4 kHz). 2 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_shooter_fire` | Shooter fires projectile at player | EFFECT | Medium | Enemy projectile launch, 50-70ms. Descending pitch. 2 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_shooter_death` | Shooter killed | EFFECT | Medium | Digital implosion, 60-90ms. 3 variations. | WAV, mono, 22050 Hz |
| `sfx_enemy_projectile_hit` | Enemy projectile hits player | EFFECT | High | Impact + digital corruption, 60-80ms. 2 variations. (Also triggers player damage sound.) | WAV, mono, 22050 Hz |
| `sfx_enemy_elite_spawn` | Elite enemy spawns (Waves 13+) | EFFECT | Medium | Empowered spawn — layered version of base enemy spawn + gold overtone, 80-120ms. 1 variation. | WAV, mono, 22050 Hz |

**Enemy SFX count**: 16 events, ~40 WAV files

#### 4.2.3 Player Events

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `sfx_player_damage` | Player loses integrity (HP) | EFFECT | Critical | Impact thud + digital distortion, 80-120ms. Sub-bass (60 Hz) + harsh mid (1-2 kHz). 2 variations. Always audible — never ducked. | WAV, mono, 22050 Hz |
| `sfx_player_damage_low_hp` | Player takes damage at ≤2 HP | EFFECT | Critical | Alarming version of damage sound — adds alarm overtone (4-8 kHz pulsing). 1 variation. Triggers alongside normal damage sound. | WAV, mono, 22050 Hz |
| `sfx_player_heal` | Player heals (shop item, upgrade card) | EFFECT | Medium | Warm rising tone + bell, 100-150ms. Gold-frequency emphasis (3-5 kHz). 1 variation. | WAV, mono, 22050 Hz |
| `sfx_player_dodge` | Player dodges an attack (DDG stat) | EFFECT | Medium | Quick energy shimmer, 30-50ms. Cyan high-frequency sweep. 1 variation. Subtle — not intrusive. | WAV, mono, 22050 Hz |
| `sfx_player_pickup_gold` | Player collects gold | EFFECT | Low | Tiny coin-like energy blip, 20-40ms. Gold frequency (4-5 kHz). 2 variations. Very short — designed to stack without mud when collecting multiple. | WAV, mono, 22050 Hz |
| `sfx_player_pickup_xp` | Player collects XP orb | EFFECT | Low | Soft energy absorption, 30-50ms. Cyan frequency (2-4 kHz). 1 variation. Quieter than gold pickup. | WAV, mono, 22050 Hz |
| `sfx_player_levelup` | Player XP bar fills, 4-card screen appears | EFFECT | Critical | Rising energy sweep → harmonic bloom, 300-500ms. Distinctive, celebratory but synthetic. 1 variation. Ducks all other SFX. | WAV, mono, 22050 Hz |
| `sfx_player_death` | Player integrity reaches 0 | EFFECT | Critical | Digital collapse: glitch noise → sub drop → silence, 500-800ms. 1 variation. Stops all other audio. | WAV, mono, 22050 Hz |

**Player SFX count**: 8 events, ~11 WAV files

#### 4.2.4 Wave & Game Flow Events

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `sfx_wave_start` | New wave begins (after shop) | EFFECT | High | Arena activation pulse, 200-300ms. Rising energy + rhythm kick. Intensity scales with wave number (see Implementation §6.6). 1 variation. | WAV, mono, 22050 Hz |
| `sfx_wave_clear` | All enemies dead / wave timer expires | EFFECT | High | Resolution chord + energy release, 200-300ms. Descending arp to signal decompression. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_wave_countdown` | Shop timer hits 3 seconds remaining | EFFECT | Medium | Tick-tock energy pulse, 50ms each, 3 pulses. Rising pitch per tick. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_run_victory` | Boss defeated, run complete | MUSIC | Critical | Victory stinger trigger (plays `stinger_victory` music file). 1 variation. | Ogg Vorbis, stereo |
| `sfx_run_defeat` | Player death confirmed | MUSIC | Critical | Defeat stinger trigger (plays `stinger_defeat` music file). 1 variation. | Ogg Vorbis, stereo |

**Wave SFX count**: 5 events, ~5 WAV + 2 Ogg files

#### 4.2.5 Shop Events

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `ui_shop_open` | Shop screen appears (between waves) | EFFECT | Medium | Panel slide-in energy, 100-150ms. Clean UI tone. 1 variation. | WAV, mono, 22050 Hz |
| `ui_shop_close` | Shop screen closes (skip or timer) | EFFECT | Medium | Panel slide-out energy, 80-120ms. Descending tone. 1 variation. | WAV, mono, 22050 Hz |
| `ui_shop_buy_weapon` | Player buys a weapon | EFFECT | High | Purchase confirmation: bright energy chime + gold accent, 100-150ms. 2 variations (common vs legendary — legendary has extended tail + harmonic shimmer). | WAV, mono, 22050 Hz |
| `ui_shop_buy_item` | Player buys a stat item | EFFECT | High | Purchase confirmation: clean energy blip, 80-100ms. 1 variation. | WAV, mono, 22050 Hz |
| `ui_shop_reroll` | Player rerolls shop items | EFFECT | Medium | Refresh sweep: filtering noise sweep + item pop sounds, 200-300ms. 1 variation. | WAV, mono, 22050 Hz |
| `ui_shop_lock` | Player locks an item | EFFECT | Low | Padlock click: short metallic snap, 40-60ms. 1 variation. | WAV, mono, 22050 Hz |
| `ui_shop_unlock_reroll` | Player unlocks reroll capability (2g) | EFFECT | Medium | Capability unlock: rising energy + confirmation chime, 150-200ms. Distinct from reroll itself. 1 variation. | WAV, mono, 22050 Hz |
| `ui_shop_unlock_lock` | Player unlocks lock capability (3g) | EFFECT | Medium | Capability unlock: similar to reroll unlock but different pitch, 150-200ms. 1 variation. | WAV, mono, 22050 Hz |
| `ui_shop_recycle` | Player recycles (sells) a weapon | EFFECT | Medium | Deconstruct sound: reverse energy + coin return, 150-200ms. 1 variation. | WAV, mono, 22050 Hz |
| `ui_shop_error` | Player tries to buy without enough gold | EFFECT | Medium | Error buzz: short low-frequency rejection tone, 60-80ms. 1 variation. | WAV, mono, 22050 Hz |

**Shop SFX count**: 10 events, ~11 WAV files

#### 4.2.6 Upgrade Events

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `ui_upgrade_appear` | 4-card upgrade screen appears | EFFECT | High | Card materialization: 4 distinct energy blips (staggered 50ms apart), 250ms total. 1 variation. | WAV, mono, 22050 Hz |
| `ui_upgrade_hover` | Player hovers/focuses a card | EFFECT | Low | Soft focus tone, 30-50ms. 1 variation. Subtle — only plays on focus change. | WAV, mono, 22050 Hz |
| `ui_upgrade_select` | Player selects a card | EFFECT | High | Card selection: confirmation chime + energy burst, 100-150ms. Pitch varies by card type (weapon upgrade = higher, stat item = mid, special = lower). 3 variations by type. | WAV, mono, 22050 Hz |

**Upgrade SFX count**: 3 events, ~5 WAV files

#### 4.2.7 Boss Events (Wave 20: Core Breaker)

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `sfx_boss_appear` | Core Breaker spawns (Wave 20 start) | EFFECT | Critical | Massive sub-bass drop + alarm motif, 500-800ms. Stops combat music, starts boss music. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_boss_phase_pulse` | Boss Phase 1: Pulse attack | EFFECT | High | Expanding ring sound: low-frequency sweep outward, 200-300ms. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_boss_phase_charge` | Boss Phase 2: Charge attack | EFFECT | High | Charge windup + dash impact, 300-400ms. Similar to Charger telegraph but louder and longer. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_boss_phase_spawn` | Boss Phase 3: Spawn minions | EFFECT | High | Summoning pulse + enemy spawn blips, 300-400ms. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_boss_phase_enrage` | Boss Phase 4: Enrage (below 50% HP) | EFFECT | Critical | Enrage transition: alarm escalation + music intensification, 500-700ms. Triggers boss music melodic counter-theme. 1 variation. | WAV, mono, 22050 Hz |
| `sfx_boss_hit` | Player weapon hits boss | EFFECT | Medium | Heavy impact + metallic ring, 60-100ms. More resonant than normal enemy hit. 2 variations. | WAV, mono, 22050 Hz |
| `sfx_boss_death` | Boss defeated | EFFECT | Critical | Extended digital collapse: multi-stage destruction, 800-1200ms. Layers of shatter + sub drops + final cutoff. 1 variation. Triggers victory stinger. | WAV, mono, 22050 Hz |

**Boss SFX count**: 7 events, ~9 WAV files

#### 4.2.8 UI Navigation Events

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `ui_nav_button` | Any generic button press | EFFECT | Low | Soft energy tap, 20-40ms. 2 variations. Very short, non-intrusive. | WAV, mono, 22050 Hz |
| `ui_nav_back` | Back button / return to previous screen | EFFECT | Low | Descending energy blip, 40-60ms. 1 variation. | WAV, mono, 22050 Hz |
| `ui_nav_select_language` | Language selection (en/zh_CN) | EFFECT | Low | Confirmation tone, 50-70ms. 1 variation. | WAV, mono, 22050 Hz |
| `ui_nav_select_stage` | Stage selection | EFFECT | Low | Stage activation tone, 60-80ms. 1 variation. | WAV, mono, 22050 Hz |
| `ui_nav_select_weapon` | Weapon selection (loadout) | EFFECT | Low | Weapon-type-specific short tone (6 variations, one per weapon type). 40-60ms each. | WAV, mono, 22050 Hz |
| `ui_nav_start_run` | "Start" button on stage select | EFFECT | Medium | Run initiation: energy charge + release, 150-200ms. 1 variation. | WAV, mono, 22050 Hz |

**UI SFX count**: 6 events, ~11 WAV files

#### 4.2.9 Ambient Events

| Event ID | Trigger | Sound Type | Priority | Notes | Format |
|---|---|---|---|---|---|
| `amb_arena_hum_low` | Waves 1-6 background ambience | AMBIENT | Low | Continuous low synthetic hum with occasional digital artifact blips. 30s loop. Plays under combat music at low gain. | Ogg Vorbis, mono, 30s loop |
| `amb_arena_hum_mid` | Waves 7-14 background ambience | AMBIENT | Low | Denser version: hum + filter modulation + more frequent artifacts. 30s loop. | Ogg Vorbis, mono, 30s loop |
| `amb_arena_hum_high` | Waves 15-19 background ambience | AMBIENT | Low | Most intense: hum + sub pulse + aggressive artifacts. 30s loop. | Ogg Vorbis, mono, 30s loop |
| `amb_arena_boss` | Wave 20 boss arena ambience | AMBIENT | Low | Dark, oppressive hum with alarm undertones. 30s loop. Plays under boss music. | Ogg Vorbis, mono, 30s loop |
| `amb_menu` | Main menu background | AMBIENT | Low | Calm synthetic atmosphere: soft pad + occasional energy pulse. 60s loop. | Ogg Vorbis, mono, 60s loop |

**Ambient count**: 5 events, 5 Ogg files

### 4.3 SFX Event Summary

| Category | Events | WAV Files | Ogg Files |
|---|---|---|---|
| Weapons | 14 | ~38 | 0 |
| Enemies | 16 | ~40 | 0 |
| Player | 8 | ~11 | 0 |
| Wave/Game Flow | 5 | ~5 | 2 |
| Shop | 10 | ~11 | 0 |
| Upgrade | 3 | ~5 | 0 |
| Boss | 7 | ~9 | 0 |
| UI Navigation | 6 | ~11 | 0 |
| Ambient | 5 | 0 | 5 |
| **Total** | **74** | **~130** | **7** |

---

## 5. Mixing Notes

### 5.1 Volume Hierarchy

Sounds are ranked by perceptual priority. When multiple sounds compete, higher-priority sounds dominate through gain staging, not muting:

| Priority Level | Events | Relative Gain | Rationale |
|---|---|---|---|
| **Critical** | Player damage, player death, level-up, boss appear, boss enrage, boss death, wave start/clear, run victory/defeat | 0 dB (reference) | These must ALWAYS be heard — they are the most important feedback the player receives |
| **High** | Weapon fire, weapon crit, charger telegraph, charger dash, shop buy, upgrade select, boss phase attacks | -3 dB | Core gameplay feedback — player needs to hear their weapons and key enemy behaviors |
| **Medium** | Enemy death, weapon hit, enemy shooter fire, shop interactions, wave countdown, upgrade appear | -6 dB | Important but not urgent — if missed, the player can still play effectively |
| **Low** | Enemy spawn, gold/XP pickup, UI nav, ambient, dodge, upgrade hover | -12 dB | Atmospheric and confirmatory — enhances the experience but is not gameplay-critical |

### 5.2 Per-Type Gain Recommendations

The engine supports 5 independent sound type channels with separate volume controls (`audio:SetMasterGain(type, gain)`). Recommended default gains:

| Sound Type | Default Gain | Contains | Rationale |
|---|---|---|---|
| `SOUND_MASTER` | 1.0 (0 dB) | — | Master bus — all other types are scaled relative to this |
| `SOUND_EFFECT` | 0.8 (-2 dB) | All SFX (weapons, enemies, player, UI, shop, boss) | Slightly below master to leave headroom for music presence |
| `SOUND_MUSIC` | 0.6 (-4 dB) | Music tracks, stingers | Music is background energy, not foreground — SFX must cut through |
| `SOUND_AMBIENT` | 0.3 (-10 dB) | Arena hum, menu ambience | Ambient is textural — barely perceptible under music and SFX |
| `SOUND_VOICE` | 0.0 (muted) | Reserved for future VO | No VO in v1 — keep at 0 to avoid accidental playback |

**Player-facing volume controls** (in a future settings screen):
- Master Volume (controls `SOUND_MASTER`)
- SFX Volume (controls `SOUND_EFFECT`)
- Music Volume (controls `SOUND_MUSIC`)
- Ambient Volume (controls `SOUND_AMBIENT`)

### 5.3 Ducking Rules

The engine does not have built-in sidechain ducking. Ducking must be implemented manually in the audio manager's update loop. Recommended ducking behaviors:

| Trigger | What Ducks | Duck Amount | Duration | Recovery |
|---|---|---|---|---|
| Player takes damage | MUSIC → -6 dB, AMBIENT → -6 dB | -6 dB from current | 200ms ramp down | 800ms ramp back up |
| Player level-up | ALL SFX (except level-up sound) → -6 dB, MUSIC → -3 dB | -6 dB / -3 dB | 100ms ramp down | 500ms ramp back up (after card selection) |
| Boss appears | MUSIC → fade out (1s), AMBIENT → switch to boss ambience | Full fade | 1s crossfade | N/A (boss music takes over) |
| Shop opens | MUSIC → fade out (0.5s), switch to shop music | Full switch | 0.5s crossfade | N/A |
| Player death | ALL audio → immediate stop, 500ms silence, then defeat stinger | Full stop | Instant | N/A |

**Implementation approach**: The audio manager tracks a `duckAmount` float per sound type. Each frame, if a duck trigger is active, it lerps the effective gain toward `baseGain * (1.0 - duckAmount)`. When the duck trigger expires, it lerps back. The final gain is applied via `audio:SetMasterGain()` — but since this affects ALL sounds of a type globally, a more granular approach is needed:

**Granular ducking**: Instead of global type gain, ducking is applied per-SoundSource. When a duck trigger fires, the audio manager iterates active SFX sources and reduces their individual `SetGain()`. This is more CPU-intensive but provides the control needed. For music, the single music SoundSource's gain is adjusted directly.

### 5.4 Voice Limit & Congestion Management

At max density (Wave 19, 30+ enemies), the following simultaneous sounds are possible:

- 6 weapons firing (each 0.6-1.2/s) = ~6 fire sounds/sec
- 6 weapons hitting = ~6 hit sounds/sec
- 5-10 enemy deaths/sec (during burst clears)
- 5-10 gold/XP pickups/sec
- Enemy spawn sounds
- Ambient bed
- Music

**Worst case**: ~30+ SFX triggers per second. The engine will attempt to play all of them, creating audio mud and potential performance issues.

**Voice limit strategy** (implemented in the audio manager):

1. **Hard voice cap**: Maximum 16 concurrent SFX voices. When the cap is reached, new sounds are either dropped (if Low priority) or replace the oldest Low-priority sound (if Medium+ priority).

2. **Per-event-type throttle**: Each event type has a minimum retrigger interval:
   - `sfx_player_pickup_gold`: 50ms minimum between plays (if multiple gold collected in 50ms, play once)
   - `sfx_player_pickup_xp`: 50ms minimum
   - `sfx_enemy_chaser_death`: 30ms minimum (allows some stacking but prevents 10-at-once)
   - All enemy death sounds: 30ms minimum per type
   - `sfx_weapon_*_fire`: 20ms minimum per weapon type (prevents machine-gun stacking at high attack speed)

3. **Priority-based preemption**: When voice cap is reached and a Critical/High sound needs to play:
   - First, stop the oldest Low-priority sound
   - If still at cap, stop the oldest Medium-priority sound
   - Critical sounds always play (preempt High if needed)

4. **Gain stacking reduction**: When the same event type fires N times within 100ms:
   - 1st play: normal gain
   - 2nd play (within 100ms): -3 dB
   - 3rd+ play (within 100ms): -6 dB
   - This simulates the perceptual effect of stacked sounds without actually stacking full-volume copies

5. **Pitch randomization**: All repeating SFX use ±3-5% pitch randomization (`SoundSource:SetFrequency()` with `baseFreq * (1 + random(-0.05, 0.05))`) to prevent the "machine gun" effect of identical sounds firing in rapid succession.

### 5.5 Panning Strategy

The game is 2D top-down. Positional audio is achieved through simple stereo panning (not 3D attenuation):

- **Player-originated sounds** (weapon fire, player damage, level-up): Center pan (0.0). The player is the camera focus.
- **Enemy sounds** (spawn, death, special): Pan based on enemy X-position relative to player:
  - Enemy at player X: pan 0.0 (center)
  - Enemy far left of player: pan -0.7 (left)
  - Enemy far right of player: pan +0.7 (right)
  - Pan is clamped to ±0.7 (not full ±1.0) to avoid extreme channel isolation on mobile mono speakers.
- **UI sounds**: Center pan (0.0). UI is screen-space, not world-space.
- **Pickup sounds**: Pan toward pickup position (same formula as enemies, but ±0.5 range — pickups are less important for spatial awareness).
- **Boss sounds**: Boss is large and centered — pan 0.0 for most events. Phase attacks pan slightly based on attack direction.

**Implementation note**: Panning requires knowing the enemy's screen position relative to the player. Since the game is UI-widget-based (no Scene/Node), the audio manager will need to receive position data from the gameplay modules when triggering sounds. The proposed `AudioManager:PlaySFX(eventId, worldX, worldY)` API handles this — it calculates pan from the position before calling `SoundSource:Play()`.

---

## 6. Implementation Strategy

### 6.1 The "No Scene/Node" Constraint

**Current state**: The game is entirely UI-widget-based. `scripts/main.lua` manages the engine lifecycle, and all gameplay is rendered through Urho3D's UI system. There is no Scene, no Node hierarchy, and therefore no natural place to attach SoundSource components (which are Components that attach to Nodes).

**Problem**: `SoundSource` is a `Component`, which must be attached to a `Node` within a `Scene`. The global `audio` object can add/remove SoundSources directly (`Audio:AddSoundSource()` / `Audio:RemoveSoundSource()`), but SoundSource still needs a Node to exist as a component.

**Proposed solution — Minimal Audio Scene**:

The audio manager creates a minimal Scene with a single Node at world origin (0,0,0). This Node holds:
- A `SoundListener` component (required for audio to function — the listener defines the "ears" position)
- One or more `SoundSource` components for SFX playback
- One `SoundSource` for music (always present, for crossfading)

```
Scene (audioScene)
  └── Node (audioNode, position: 0,0,0)
       ├── SoundListener (the "ears")
       ├── SoundSource [sfx_pool_1] (type: SOUND_EFFECT, autoRemove: REMOVE_COMPONENT)
       ├── SoundSource [sfx_pool_2] (type: SOUND_EFFECT, autoRemove: REMOVE_COMPONENT)
       ├── ... (up to 16 SFX pool sources)
       ├── SoundSource [music_a] (type: SOUND_MUSIC, looped)
       └── SoundSource [music_b] (type: SOUND_MUSIC, looped)
```

This scene is created once at game initialization and never rendered (no camera, no viewport). It exists solely to host audio components. The SoundListener at origin means all panning is relative to center — which is correct for our 2D top-down game where the player is always centered.

**Alternative (simpler) approach**: If creating a full Scene is too invasive, the audio manager can use `Audio:AddSoundSource()` to register "bare" SoundSources. However, SoundSource as a Component still technically needs a Node. The minimal Scene approach is cleaner and more maintainable.

### 6.2 AudioManager Module Design

A new `scripts/audio.lua` module should be created (by the programming team — this document specifies the design, not the code). The module's responsibilities:

**State**:
- `audioScene_` — minimal Scene for audio components
- `audioNode_` — root Node in the audio scene
- `listener_` — SoundListener component
- `sfxPool_` — array of 16 SoundSource components for SFX
- `sfxPoolIndex_` — round-robin index for SFX pool allocation
- `musicSourceA_`, `musicSourceB_` — two SoundSources for music crossfading
- `activeMusic_` — which music source is currently active (A or B)
- `soundCache_` — table mapping event IDs to pre-loaded Sound resources
- `duckState_` — table tracking active duck triggers and amounts per sound type
- `voiceCount_` — count of currently active SFX voices
- `lastPlayTime_` — table mapping event IDs to timestamps for throttle checks

**Public API** (to be called by other modules):
- `AudioManager:Init()` — create scene, node, listener, SFX pool, music sources. Preload all P0 sounds. Set default type gains.
- `AudioManager:PlaySFX(eventId, optWorldX, optWorldY)` — play a sound effect by event ID. If worldX/Y provided, calculate pan. Applies throttle, voice limit, priority preemption, pitch randomization.
- `AudioManager:PlayMusic(trackName, optFadeTime)` — play a music track with optional crossfade. Stops the previous track.
- `AudioManager:StopMusic(optFadeTime)` — fade out and stop current music.
- `AudioManager:PlayAmbient(trackName)` — play an ambient bed track (looped, low gain).
- `AudioManager:StopAmbient(optFadeTime)` — fade out and stop ambient.
- `AudioManager:SetVolume(soundType, gain)` — set volume for a sound type (for settings).
- `AudioManager:PauseAll()` — pause all audio (for app backgrounding).
- `AudioManager:ResumeAll()` — resume all audio (for app foregrounding).
- `AudioManager:Update(dt)` — called every frame. Handles duck lerp, voice count cleanup, throttle timer cleanup.
- `AudioManager:Shutdown()` — stop all sounds, remove sources, destroy scene.

**Integration points** (which modules call which audio events):
- `main.lua` → `AudioManager:Init()` in `Start()`, `AudioManager:Update(dt)` in `HandleUpdate`, `AudioManager:PauseAll()`/`ResumeAll()` on app pause/resume
- `weapons.lua` → `AudioManager:PlaySFX("sfx_weapon_*_fire")` on weapon fire, `AudioManager:PlaySFX("sfx_weapon_*_hit")` on hit, `AudioManager:PlaySFX("sfx_weapon_crit")` on crit
- `enemies.lua` → `AudioManager:PlaySFX("sfx_enemy_*_spawn/death/...")` on spawn/death/special, with worldX/Y for panning
- `player.lua` → `AudioManager:PlaySFX("sfx_player_damage/...")` on damage/heal/dodge/levelup/death
- `waves.lua` → `AudioManager:PlaySFX("sfx_wave_start/clear")`, `AudioManager:PlayMusic(...)` for intensity switching
- `shop.lua` → `AudioManager:PlaySFX("ui_shop_*")` on shop interactions
- `ui.lua` → `AudioManager:PlaySFX("ui_nav_*")` on navigation, `AudioManager:PlaySFX("ui_upgrade_*")` on upgrade interactions
- `main.lua` (pickups) → `AudioManager:PlaySFX("sfx_player_pickup_gold/xp")` on gold/XP collection

### 6.3 File Organization

```
assets/
  Sounds/
    sfx/
      weapons/
        sfx_weapon_blade_fire_v1.wav
        sfx_weapon_blade_fire_v2.wav
        sfx_weapon_blade_hit_v1.wav
        sfx_weapon_blade_hit_v2.wav
        sfx_weapon_blade_hit_v3.wav
        sfx_weapon_bow_fire_v1.wav
        sfx_weapon_bow_fire_v2.wav
        sfx_weapon_bow_hit_v1.wav
        sfx_weapon_bow_hit_v2.wav
        sfx_weapon_bow_hit_v3.wav
        sfx_weapon_staff_fire_v1.wav
        sfx_weapon_staff_fire_v2.wav
        sfx_weapon_staff_hit_v1.wav
        sfx_weapon_staff_hit_v2.wav
        sfx_weapon_staff_hit_v3.wav
        sfx_weapon_mace_fire_v1.wav
        sfx_weapon_mace_hit_v1.wav
        sfx_weapon_mace_hit_v2.wav
        sfx_weapon_mace_hit_v3.wav
        sfx_weapon_crossbow_fire_v1.wav
        sfx_weapon_crossbow_fire_v2.wav
        sfx_weapon_crossbow_hit_v1.wav
        sfx_weapon_crossbow_hit_v2.wav
        sfx_weapon_crossbow_hit_v3.wav
        sfx_weapon_throwing_fire_v1.wav
        sfx_weapon_throwing_fire_v2.wav
        sfx_weapon_throwing_hit_v1.wav
        sfx_weapon_throwing_hit_v2.wav
        sfx_weapon_throwing_hit_v3.wav
        sfx_weapon_crit_v1.wav
      enemies/
        sfx_enemy_chaser_spawn_v1.wav
        sfx_enemy_chaser_spawn_v2.wav
        sfx_enemy_chaser_death_v1.wav
        sfx_enemy_chaser_death_v2.wav
        sfx_enemy_chaser_death_v3.wav
        sfx_enemy_skimmer_spawn_v1.wav
        sfx_enemy_skimmer_spawn_v2.wav
        sfx_enemy_skimmer_death_v1.wav
        sfx_enemy_skimmer_death_v2.wav
        sfx_enemy_skimmer_death_v3.wav
        sfx_enemy_charger_spawn_v1.wav
        sfx_enemy_charger_telegraph_v1.wav
        sfx_enemy_charger_dash_v1.wav
        sfx_enemy_charger_dash_v2.wav
        sfx_enemy_charger_death_v1.wav
        sfx_enemy_charger_death_v2.wav
        sfx_enemy_charger_death_v3.wav
        sfx_enemy_splitter_spawn_v1.wav
        sfx_enemy_splitter_spawn_v2.wav
        sfx_enemy_splitter_death_v1.wav
        sfx_enemy_splitter_death_v2.wav
        sfx_enemy_splitter_fragment_death_v1.wav
        sfx_enemy_splitter_fragment_death_v2.wav
        sfx_enemy_shooter_spawn_v1.wav
        sfx_enemy_shooter_spawn_v2.wav
        sfx_enemy_shooter_fire_v1.wav
        sfx_enemy_shooter_fire_v2.wav
        sfx_enemy_shooter_death_v1.wav
        sfx_enemy_shooter_death_v2.wav
        sfx_enemy_shooter_death_v3.wav
        sfx_enemy_projectile_hit_v1.wav
        sfx_enemy_projectile_hit_v2.wav
        sfx_enemy_elite_spawn_v1.wav
      player/
        sfx_player_damage_v1.wav
        sfx_player_damage_v2.wav
        sfx_player_damage_low_hp_v1.wav
        sfx_player_heal_v1.wav
        sfx_player_dodge_v1.wav
        sfx_player_pickup_gold_v1.wav
        sfx_player_pickup_gold_v2.wav
        sfx_player_pickup_xp_v1.wav
        sfx_player_levelup_v1.wav
        sfx_player_death_v1.wav
      boss/
        sfx_boss_appear_v1.wav
        sfx_boss_phase_pulse_v1.wav
        sfx_boss_phase_charge_v1.wav
        sfx_boss_phase_spawn_v1.wav
        sfx_boss_phase_enrage_v1.wav
        sfx_boss_hit_v1.wav
        sfx_boss_hit_v2.wav
        sfx_boss_death_v1.wav
      wave/
        sfx_wave_start_v1.wav
        sfx_wave_clear_v1.wav
        sfx_wave_countdown_v1.wav
    ui/
      shop/
        ui_shop_open_v1.wav
        ui_shop_close_v1.wav
        ui_shop_buy_weapon_v1.wav
        ui_shop_buy_weapon_legendary_v1.wav
        ui_shop_buy_item_v1.wav
        ui_shop_reroll_v1.wav
        ui_shop_lock_v1.wav
        ui_shop_unlock_reroll_v1.wav
        ui_shop_unlock_lock_v1.wav
        ui_shop_recycle_v1.wav
        ui_shop_error_v1.wav
      upgrade/
        ui_upgrade_appear_v1.wav
        ui_upgrade_hover_v1.wav
        ui_upgrade_select_weapon_v1.wav
        ui_upgrade_select_stat_v1.wav
        ui_upgrade_select_special_v1.wav
      nav/
        ui_nav_button_v1.wav
        ui_nav_button_v2.wav
        ui_nav_back_v1.wav
        ui_nav_select_language_v1.wav
        ui_nav_select_stage_v1.wav
        ui_nav_select_weapon_blade.wav
        ui_nav_select_weapon_bow.wav
        ui_nav_select_weapon_staff.wav
        ui_nav_select_weapon_mace.wav
        ui_nav_select_weapon_crossbow.wav
        ui_nav_select_weapon_throwing.wav
        ui_nav_start_run_v1.wav
    music/
      music_menu.ogg
      music_combat_low.ogg
      music_combat_mid.ogg
      music_combat_high.ogg
      music_boss.ogg
      music_shop.ogg
      stinger_victory.ogg
      stinger_defeat.ogg
    ambient/
      amb_arena_hum_low.ogg
      amb_arena_hum_mid.ogg
      amb_arena_hum_high.ogg
      amb_arena_boss.ogg
      amb_menu.ogg
```

### 6.4 File Format Strategy

| Category | Format | Sample Rate | Channels | Rationale |
|---|---|---|---|---|
| SFX (short, <200ms) | WAV (uncompressed PCM) | 22050 Hz | Mono | Fast load, no decode overhead, small file size at 22050 Hz mono. WAV avoids Ogg decode latency for rapid-fire SFX. |
| Music (looped, long) | Ogg Vorbis | 44100 Hz | Stereo | Compressed (10x smaller than WAV), good quality at 128kbps, engine supports Ogg looped playback. Decode overhead is acceptable for music (single stream). |
| Ambient (looped, long) | Ogg Vorbis | 22050 Hz | Mono | Compressed, mono (ambient is positional but low priority — mono saves space). 22050 Hz is sufficient for low-frequency ambient content. |
| Stingers (one-shot, short) | Ogg Vorbis | 44100 Hz | Stereo | Compressed, stereo for emotional impact (victory/defeat). Short duration means small file even at 44100 Hz stereo. |

**Why 22050 Hz for SFX?** Mobile phone speakers rarely reproduce frequencies above 11 kHz cleanly. 22050 Hz sample rate captures up to 11 kHz (Nyquist), which covers the useful band for gameplay SFX. This halves the file size vs 44100 Hz with no perceptible quality loss on mobile. If the game also targets PC with good speakers, 44100 Hz can be used — but the file size cost is 2x.

**WAV vs Ogg for SFX**: WAV is chosen for SFX because:
1. No decode latency — critical for rapid-fire weapons (6 weapons × 1+ shots/sec)
2. WAV files at 22050 Hz mono are small (a 100ms SFX = ~4.4 KB)
3. The engine loads WAV as raw PCM — no CPU overhead during playback
4. Ogg Vorbis decode for many simultaneous short sounds could cause CPU spikes on low-end mobile

### 6.5 Memory Budget

| Category | File Count | Est. Total Size (uncompressed in memory) | Notes |
|---|---|---|---|
| SFX (WAV, 22050 Hz mono) | ~130 files | ~1.5 MB | Average 11 KB per file. All P0 SFX preloaded at init. P1/P2 loaded on demand or at init if memory allows. |
| Music (Ogg Vorbis, 128kbps stereo) | 8 files | ~8.2 MB (on disk) | Only 1-2 tracks decompressed in memory at a time (~2-4 MB RAM). Ogg streams from disk. |
| Ambient (Ogg Vorbis, 96kbps mono) | 5 files | ~1.8 MB (on disk) | Only 1 ambient track active at a time (~400 KB RAM). Ogg streams from disk. |
| **Total disk** | ~143 files | **~11.5 MB** | Acceptable for a mobile game. TapTap APK size impact is minimal. |
| **Total RAM (peak)** | — | **~6-8 MB** | SFX preloaded + 1 music stream + 1 ambient stream. Well within mobile budget. |

### 6.6 Dynamic Intensity Implementation

Wave-based intensity is implemented through track switching, not real-time DSP. The mapping:

| Wave Range | Music Track | Ambient Track | SFX Pitch Shift |
|---|---|---|---|
| 1-6 | `music_combat_low` | `amb_arena_hum_low` | None (base pitch) |
| 7-14 | `music_combat_mid` | `amb_arena_hum_mid` | None |
| 15-19 | `music_combat_high` | `amb_arena_hum_high` | None |
| 20 (Boss) | `music_boss` | `amb_arena_boss` | None |
| Shop | `music_shop` | None (ambient paused) | None |
| Menu | `music_menu` | `amb_menu` | None |

**Wave start sound variation**: `sfx_wave_start` pitch-shifts upward by ~5% per wave tier (waves 1-6 = base, 7-14 = +5%, 15-19 = +10%). This is achieved by calling `SoundSource:Play(sound, baseFreq * pitchMultiplier, gain, panning)`.

### 6.7 App Lifecycle Handling

Mobile apps can be backgrounded at any time. The audio manager must:

1. **On app pause** (background/lock screen): Call `audio:PauseSoundType(SOUND_MASTER)` or `audio:Stop()` to pause all audio. This prevents audio from continuing to play when the player is not in the game.
2. **On app resume** (foreground): Call `audio:ResumeAll()` to resume all paused audio. If the player was in combat, music and SFX resume from where they paused.
3. **On run end** (victory/defeat): Stop combat music, play stinger, then transition to menu music after a 3-second delay.

**Engine API**: The engine provides `audio:PauseSoundType(type)` and `audio:ResumeAll()`. The app lifecycle events should be wired in `main.lua` to call these through the AudioManager.

### 6.8 Asset Sourcing Strategy

**SFX — Procedural Generation (Primary)**:
- Use **sfxr / jsfxr** (free, open-source) to generate all short SFX. These tools are designed for exactly this use case: retro/synthetic game sound effects with parameter randomization.
- Workflow: Design each sound in sfxr → export as WAV (22050 Hz, mono) → batch-process if needed (normalize to -3 dB peak, trim silence, fade in/out 2ms).
- Advantage: Every sound is unique, original, and matches the synthesized aesthetic. No licensing concerns. Zero cost.
- For more complex SFX (boss sounds, level-up, death), use a DAW with free synth plugins (Vital, Helm) to layer and process multiple synthesized elements.

**Music — Custom Composition (Primary)**:
- Commission or create custom synthwave/electronic tracks using a DAW with free software synthesizers.
- Recommended free tools: **LMMS** (free DAW), **Vital** (free wavetable synth), **Helm** (free synth), **Surge XT** (free synth).
- Each track should be composed specifically for the game's mood and tempo requirements (see §3.3).
- Render to Ogg Vorbis at 128kbps stereo, 44100 Hz, with seamless loop points.

**Ambient — Procedural + DAW**:
- Generate base hum tones procedurally (sine wave + filtered noise).
- Layer with occasional artifact blips (short FM tones at random intervals).
- Process in DAW for spatial depth (light reverb, stereo widening for mono-fold-down-safe stereo).
- Render to Ogg Vorbis at 96kbps mono, 22050 Hz, 30s loop.

**Alternative — Royalty-Free Libraries (Fallback)**:
- If custom composition is not feasible, use royalty-free libraries: **freesound.org** (CC0 sounds), **OpenGameArt.org** (CC0/CC-BY game audio), **Kenney.nl** (CC0 game audio packs).
- Filter strictly for synthetic/electronic sounds that match the Neon Vector Geometry aesthetic.
- All sourced assets must be verified for license compatibility with commercial TapTap release.

### 6.9 Prioritized Implementation Phases

Audio implementation should follow a phased approach aligned with the project's roadmap. The ROADMAP currently lists "No audio pass" as a non-goal until the Brotato transition is complete. Audio should be integrated after the core gameplay loop (P4-P9) is functional.

#### Phase A — Foundation (after P4 weapon system is playable)
**Goal**: Prove the audio pipeline works end-to-end.
- Create `scripts/audio.lua` module (AudioManager)
- Implement minimal Scene + Node + SoundListener + SFX pool
- Implement `PlaySFX()` with basic voice limiting
- Create 6 weapon fire sounds (1 variation each) using sfxr
- Wire weapon fire events from `weapons.lua`
- Set default type gains
- **Deliverable**: Weapons make sounds when they fire. No music, no other SFX yet.

#### Phase B — Core Combat SFX (after P5 enemy system is stable)
**Goal**: Full combat audio feedback loop.
- Create all enemy spawn/death/special SFX
- Create player damage, dodge, pickup, level-up, death SFX
- Create weapon hit SFX (all 6 weapons + crit)
- Wire all combat events from `enemies.lua`, `player.lua`
- Implement panning (pass worldX/Y to PlaySFX)
- Implement throttle and gain stacking reduction
- **Deliverable**: Full combat audio — firing, hitting, enemies dying, player taking damage, pickups.

#### Phase C — Music & Ambient (after P9 wave tuning)
**Goal**: The game has a soundtrack.
- Compose and render all 8 music tracks
- Generate all 5 ambient tracks
- Implement `PlayMusic()` with crossfade
- Implement `PlayAmbient()`
- Wire music intensity switching from `waves.lua`
- Wire shop music from `shop.lua`
- Wire boss music from `enemies.lua` (boss spawn)
- **Deliverable**: Music plays through the full run, switches intensity at wave boundaries, boss music for Wave 20.

#### Phase D — UI & Shop SFX (after P6 shop is functional)
**Goal**: All interface interactions have audio feedback.
- Create all UI navigation, shop, and upgrade SFX
- Wire UI events from `ui.lua`, `shop.lua`
- Implement ducking rules (level-up duck, shop music transition, death silence)
- **Deliverable**: Every button press, shop action, and upgrade selection has audio feedback.

#### Phase E — Polish & Boss Audio (after P9, pre-release)
**Goal**: Audio is release-ready.
- Create all boss SFX (7 events)
- Create victory/defeat stingers
- Add SFX variations (v2, v3 for all events)
- Tune mix gains based on playtesting
- Implement app lifecycle handling (pause/resume)
- Add volume settings UI (if settings screen exists)
- Final mix pass: adjust per-type gains, duck amounts, voice limits based on real gameplay
- **Deliverable**: Complete audio experience, release-ready.

#### Phase F — Post-Launch (P2 / future)
- Additional music tracks for new stages/arenas
- Voice-over (VO) for boss intro/narrative (if story is added)
- Adaptive music system (real-time stem layering, if engine allows)
- Haptic feedback sync (mobile vibration on critical events)

### 6.10 Performance Considerations

| Concern | Mitigation |
|---|---|
| CPU: Ogg decode for music + ambient | Only 2 Ogg streams active at once (1 music + 1 ambient). Engine handles this efficiently. SFX are WAV (no decode). |
| CPU: 16 concurrent SFX voices | 16 is conservative for modern mobile. If profiling shows issues, reduce to 12. Voice limit + throttle prevents exceeding this. |
| Memory: 130 WAV files preloaded | At 22050 Hz mono, 130 files × ~11 KB average = ~1.5 MB. Negligible. If memory is tight, load P1/P2 SFX on demand. |
| Memory: Music Ogg streaming | Ogg Vorbis streams from disk — only a small buffer is in RAM (~200 KB per stream). No full-track decompression in memory. |
| Frame time: AudioManager:Update() | Duck lerp + voice cleanup is O(active_voices) ≈ O(16) per frame. Negligible. Throttle check is O(1) per PlaySFX call (hash lookup). |
| Audio glitching: SoundSource pool exhaustion | 16-source pool with round-robin allocation. If all 16 are busy, lowest-priority is preempted. AutoRemoveMode = REMOVE_COMPONENT ensures sources are recycled after playback. |

---

## 7. Asset Manifest

### 7.1 Complete Asset Checklist

All assets are listed with priority:
- **P0** = Must-have for v1 audio release (Phase A-C)
- **P1** = Important for full experience (Phase D-E)
- **P2** = Nice-to-have / future enhancement (Phase F)

#### 7.1.1 Weapon SFX

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 1 | `sfx_weapon_blade_fire_v1` | SFX | 100ms | WAV 22050 mono | P0 |
| 2 | `sfx_weapon_blade_fire_v2` | SFX | 100ms | WAV 22050 mono | P1 |
| 3 | `sfx_weapon_blade_hit_v1` | SFX | 50ms | WAV 22050 mono | P0 |
| 4 | `sfx_weapon_blade_hit_v2` | SFX | 50ms | WAV 22050 mono | P1 |
| 5 | `sfx_weapon_blade_hit_v3` | SFX | 50ms | WAV 22050 mono | P1 |
| 6 | `sfx_weapon_bow_fire_v1` | SFX | 120ms | WAV 22050 mono | P0 |
| 7 | `sfx_weapon_bow_fire_v2` | SFX | 120ms | WAV 22050 mono | P1 |
| 8 | `sfx_weapon_bow_hit_v1` | SFX | 50ms | WAV 22050 mono | P0 |
| 9 | `sfx_weapon_bow_hit_v2` | SFX | 50ms | WAV 22050 mono | P1 |
| 10 | `sfx_weapon_bow_hit_v3` | SFX | 50ms | WAV 22050 mono | P1 |
| 11 | `sfx_weapon_staff_fire_v1` | SFX | 150ms | WAV 22050 mono | P0 |
| 12 | `sfx_weapon_staff_fire_v2` | SFX | 150ms | WAV 22050 mono | P1 |
| 13 | `sfx_weapon_staff_hit_v1` | SFX | 60ms | WAV 22050 mono | P0 |
| 14 | `sfx_weapon_staff_hit_v2` | SFX | 60ms | WAV 22050 mono | P1 |
| 15 | `sfx_weapon_staff_hit_v3` | SFX | 60ms | WAV 22050 mono | P1 |
| 16 | `sfx_weapon_mace_fire_v1` | SFX | 180ms | WAV 22050 mono | P0 |
| 17 | `sfx_weapon_mace_hit_v1` | SFX | 70ms | WAV 22050 mono | P0 |
| 18 | `sfx_weapon_mace_hit_v2` | SFX | 70ms | WAV 22050 mono | P1 |
| 19 | `sfx_weapon_mace_hit_v3` | SFX | 70ms | WAV 22050 mono | P1 |
| 20 | `sfx_weapon_crossbow_fire_v1` | SFX | 90ms | WAV 22050 mono | P0 |
| 21 | `sfx_weapon_crossbow_fire_v2` | SFX | 90ms | WAV 22050 mono | P1 |
| 22 | `sfx_weapon_crossbow_hit_v1` | SFX | 60ms | WAV 22050 mono | P0 |
| 23 | `sfx_weapon_crossbow_hit_v2` | SFX | 60ms | WAV 22050 mono | P1 |
| 24 | `sfx_weapon_crossbow_hit_v3` | SFX | 60ms | WAV 22050 mono | P1 |
| 25 | `sfx_weapon_throwing_fire_v1` | SFX | 120ms | WAV 22050 mono | P0 |
| 26 | `sfx_weapon_throwing_fire_v2` | SFX | 120ms | WAV 22050 mono | P1 |
| 27 | `sfx_weapon_throwing_hit_v1` | SFX | 40ms | WAV 22050 mono | P0 |
| 28 | `sfx_weapon_throwing_hit_v2` | SFX | 40ms | WAV 22050 mono | P1 |
| 29 | `sfx_weapon_throwing_hit_v3` | SFX | 40ms | WAV 22050 mono | P1 |
| 30 | `sfx_weapon_crit_v1` | SFX | 90ms | WAV 22050 mono | P0 |

#### 7.1.2 Enemy SFX

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 31 | `sfx_enemy_chaser_spawn_v1` | SFX | 50ms | WAV 22050 mono | P0 |
| 32 | `sfx_enemy_chaser_spawn_v2` | SFX | 50ms | WAV 22050 mono | P1 |
| 33 | `sfx_enemy_chaser_death_v1` | SFX | 60ms | WAV 22050 mono | P0 |
| 34 | `sfx_enemy_chaser_death_v2` | SFX | 60ms | WAV 22050 mono | P1 |
| 35 | `sfx_enemy_chaser_death_v3` | SFX | 60ms | WAV 22050 mono | P1 |
| 36 | `sfx_enemy_skimmer_spawn_v1` | SFX | 60ms | WAV 22050 mono | P0 |
| 37 | `sfx_enemy_skimmer_spawn_v2` | SFX | 60ms | WAV 22050 mono | P1 |
| 38 | `sfx_enemy_skimmer_death_v1` | SFX | 70ms | WAV 22050 mono | P0 |
| 39 | `sfx_enemy_skimmer_death_v2` | SFX | 70ms | WAV 22050 mono | P1 |
| 40 | `sfx_enemy_skimmer_death_v3` | SFX | 70ms | WAV 22050 mono | P1 |
| 41 | `sfx_enemy_charger_spawn_v1` | SFX | 90ms | WAV 22050 mono | P0 |
| 42 | `sfx_enemy_charger_telegraph_v1` | SFX | 250ms | WAV 22050 mono | P0 |
| 43 | `sfx_enemy_charger_dash_v1` | SFX | 120ms | WAV 22050 mono | P0 |
| 44 | `sfx_enemy_charger_dash_v2` | SFX | 120ms | WAV 22050 mono | P1 |
| 45 | `sfx_enemy_charger_death_v1` | SFX | 100ms | WAV 22050 mono | P0 |
| 46 | `sfx_enemy_charger_death_v2` | SFX | 100ms | WAV 22050 mono | P1 |
| 47 | `sfx_enemy_charger_death_v3` | SFX | 100ms | WAV 22050 mono | P1 |
| 48 | `sfx_enemy_splitter_spawn_v1` | SFX | 60ms | WAV 22050 mono | P0 |
| 49 | `sfx_enemy_splitter_spawn_v2` | SFX | 60ms | WAV 22050 mono | P1 |
| 50 | `sfx_enemy_splitter_death_v1` | SFX | 120ms | WAV 22050 mono | P0 |
| 51 | `sfx_enemy_splitter_death_v2` | SFX | 120ms | WAV 22050 mono | P1 |
| 52 | `sfx_enemy_splitter_fragment_death_v1` | SFX | 40ms | WAV 22050 mono | P1 |
| 53 | `sfx_enemy_splitter_fragment_death_v2` | SFX | 40ms | WAV 22050 mono | P1 |
| 54 | `sfx_enemy_shooter_spawn_v1` | SFX | 70ms | WAV 22050 mono | P0 |
| 55 | `sfx_enemy_shooter_spawn_v2` | SFX | 70ms | WAV 22050 mono | P1 |
| 56 | `sfx_enemy_shooter_fire_v1` | SFX | 60ms | WAV 22050 mono | P0 |
| 57 | `sfx_enemy_shooter_fire_v2` | SFX | 60ms | WAV 22050 mono | P1 |
| 58 | `sfx_enemy_shooter_death_v1` | SFX | 70ms | WAV 22050 mono | P0 |
| 59 | `sfx_enemy_shooter_death_v2` | SFX | 70ms | WAV 22050 mono | P1 |
| 60 | `sfx_enemy_shooter_death_v3` | SFX | 70ms | WAV 22050 mono | P1 |
| 61 | `sfx_enemy_projectile_hit_v1` | SFX | 70ms | WAV 22050 mono | P0 |
| 62 | `sfx_enemy_projectile_hit_v2` | SFX | 70ms | WAV 22050 mono | P1 |
| 63 | `sfx_enemy_elite_spawn_v1` | SFX | 100ms | WAV 22050 mono | P1 |

#### 7.1.3 Player SFX

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 64 | `sfx_player_damage_v1` | SFX | 100ms | WAV 22050 mono | P0 |
| 65 | `sfx_player_damage_v2` | SFX | 100ms | WAV 22050 mono | P0 |
| 66 | `sfx_player_damage_low_hp_v1` | SFX | 100ms | WAV 22050 mono | P1 |
| 67 | `sfx_player_heal_v1` | SFX | 120ms | WAV 22050 mono | P1 |
| 68 | `sfx_player_dodge_v1` | SFX | 40ms | WAV 22050 mono | P1 |
| 69 | `sfx_player_pickup_gold_v1` | SFX | 30ms | WAV 22050 mono | P0 |
| 70 | `sfx_player_pickup_gold_v2` | SFX | 30ms | WAV 22050 mono | P0 |
| 71 | `sfx_player_pickup_xp_v1` | SFX | 40ms | WAV 22050 mono | P0 |
| 72 | `sfx_player_levelup_v1` | SFX | 400ms | WAV 22050 mono | P0 |
| 73 | `sfx_player_death_v1` | SFX | 600ms | WAV 22050 mono | P0 |

#### 7.1.4 Wave & Game Flow SFX

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 74 | `sfx_wave_start_v1` | SFX | 250ms | WAV 22050 mono | P0 |
| 75 | `sfx_wave_clear_v1` | SFX | 250ms | WAV 22050 mono | P0 |
| 76 | `sfx_wave_countdown_v1` | SFX | 50ms | WAV 22050 mono | P1 |

#### 7.1.5 Shop SFX

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 77 | `ui_shop_open_v1` | SFX | 120ms | WAV 22050 mono | P1 |
| 78 | `ui_shop_close_v1` | SFX | 100ms | WAV 22050 mono | P1 |
| 79 | `ui_shop_buy_weapon_v1` | SFX | 120ms | WAV 22050 mono | P1 |
| 80 | `ui_shop_buy_weapon_legendary_v1` | SFX | 200ms | WAV 22050 mono | P1 |
| 81 | `ui_shop_buy_item_v1` | SFX | 90ms | WAV 22050 mono | P1 |
| 82 | `ui_shop_reroll_v1` | SFX | 250ms | WAV 22050 mono | P1 |
| 83 | `ui_shop_lock_v1` | SFX | 50ms | WAV 22050 mono | P1 |
| 84 | `ui_shop_unlock_reroll_v1` | SFX | 180ms | WAV 22050 mono | P1 |
| 85 | `ui_shop_unlock_lock_v1` | SFX | 180ms | WAV 22050 mono | P1 |
| 86 | `ui_shop_recycle_v1` | SFX | 180ms | WAV 22050 mono | P1 |
| 87 | `ui_shop_error_v1` | SFX | 70ms | WAV 22050 mono | P1 |

#### 7.1.6 Upgrade SFX

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 88 | `ui_upgrade_appear_v1` | SFX | 250ms | WAV 22050 mono | P0 |
| 89 | `ui_upgrade_hover_v1` | SFX | 40ms | WAV 22050 mono | P1 |
| 90 | `ui_upgrade_select_weapon_v1` | SFX | 120ms | WAV 22050 mono | P0 |
| 91 | `ui_upgrade_select_stat_v1` | SFX | 120ms | WAV 22050 mono | P0 |
| 92 | `ui_upgrade_select_special_v1` | SFX | 120ms | WAV 22050 mono | P0 |

#### 7.1.7 Boss SFX

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 93 | `sfx_boss_appear_v1` | SFX | 600ms | WAV 22050 mono | P1 |
| 94 | `sfx_boss_phase_pulse_v1` | SFX | 250ms | WAV 22050 mono | P1 |
| 95 | `sfx_boss_phase_charge_v1` | SFX | 350ms | WAV 22050 mono | P1 |
| 96 | `sfx_boss_phase_spawn_v1` | SFX | 350ms | WAV 22050 mono | P1 |
| 97 | `sfx_boss_phase_enrage_v1` | SFX | 600ms | WAV 22050 mono | P1 |
| 98 | `sfx_boss_hit_v1` | SFX | 80ms | WAV 22050 mono | P1 |
| 99 | `sfx_boss_hit_v2` | SFX | 80ms | WAV 22050 mono | P1 |
| 100 | `sfx_boss_death_v1` | SFX | 1000ms | WAV 22050 mono | P1 |

#### 7.1.8 UI Navigation SFX

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 101 | `ui_nav_button_v1` | SFX | 30ms | WAV 22050 mono | P0 |
| 102 | `ui_nav_button_v2` | SFX | 30ms | WAV 22050 mono | P1 |
| 103 | `ui_nav_back_v1` | SFX | 50ms | WAV 22050 mono | P0 |
| 104 | `ui_nav_select_language_v1` | SFX | 60ms | WAV 22050 mono | P0 |
| 105 | `ui_nav_select_stage_v1` | SFX | 70ms | WAV 22050 mono | P0 |
| 106 | `ui_nav_select_weapon_blade` | SFX | 50ms | WAV 22050 mono | P1 |
| 107 | `ui_nav_select_weapon_bow` | SFX | 50ms | WAV 22050 mono | P1 |
| 108 | `ui_nav_select_weapon_staff` | SFX | 50ms | WAV 22050 mono | P1 |
| 109 | `ui_nav_select_weapon_mace` | SFX | 50ms | WAV 22050 mono | P1 |
| 110 | `ui_nav_select_weapon_crossbow` | SFX | 50ms | WAV 22050 mono | P1 |
| 111 | `ui_nav_select_weapon_throwing` | SFX | 50ms | WAV 22050 mono | P1 |
| 112 | `ui_nav_start_run_v1` | SFX | 180ms | WAV 22050 mono | P0 |

#### 7.1.9 Music

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 113 | `music_menu` | Music | 60s loop | Ogg Vorbis 128k stereo | P0 |
| 114 | `music_combat_low` | Music | 90s loop | Ogg Vorbis 128k stereo | P0 |
| 115 | `music_combat_mid` | Music | 90s loop | Ogg Vorbis 128k stereo | P0 |
| 116 | `music_combat_high` | Music | 90s loop | Ogg Vorbis 128k stereo | P0 |
| 117 | `music_boss` | Music | 120s loop | Ogg Vorbis 128k stereo | P1 |
| 118 | `music_shop` | Music | 30s loop | Ogg Vorbis 128k stereo | P1 |
| 119 | `stinger_victory` | Music | 8s one-shot | Ogg Vorbis 128k stereo | P1 |
| 120 | `stinger_defeat` | Music | 6s one-shot | Ogg Vorbis 128k stereo | P0 |

#### 7.1.10 Ambient

| # | Asset Name | Category | Duration | Format | Priority |
|---|---|---|---|---|---|
| 121 | `amb_arena_hum_low` | Ambient | 30s loop | Ogg Vorbis 96k mono | P1 |
| 122 | `amb_arena_hum_mid` | Ambient | 30s loop | Ogg Vorbis 96k mono | P1 |
| 123 | `amb_arena_hum_high` | Ambient | 30s loop | Ogg Vorbis 96k mono | P2 |
| 124 | `amb_arena_boss` | Ambient | 30s loop | Ogg Vorbis 96k mono | P2 |
| 125 | `amb_menu` | Ambient | 60s loop | Ogg Vorbis 96k mono | P1 |

### 7.2 Asset Count Summary

| Category | P0 (Must-Have) | P1 (Important) | P2 (Future) | Total |
|---|---|---|---|---|
| Weapon SFX | 12 | 18 | 0 | 30 |
| Enemy SFX | 14 | 17 | 0 | 31 (note: 2 fragment deaths are P1) |
| Player SFX | 7 | 3 | 0 | 10 |
| Wave/Game SFX | 2 | 1 | 0 | 3 |
| Shop SFX | 0 | 11 | 0 | 11 |
| Upgrade SFX | 4 | 1 | 0 | 5 |
| Boss SFX | 0 | 8 | 0 | 8 |
| UI Nav SFX | 5 | 7 | 0 | 12 |
| Music | 5 | 3 | 0 | 8 |
| Ambient | 0 | 3 | 2 | 5 |
| **Total** | **49** | **72** | **2** | **123** |

**P0 alone** (49 assets) provides a functional, satisfying audio experience: weapons fire and hit, enemies spawn and die, player takes damage and levels up, waves start and clear, UI buttons respond, menu/combat music plays, and defeat stinger plays on death.

**P0 + P1** (121 assets) provides the complete v1 audio experience as described in this document.

**P2** (2 assets) adds high-wave ambient variations for future polish.

### 7.3 Estimated Total File Size

| Category | Format | P0 Size | P1 Size | P2 Size | Total |
|---|---|---|---|---|---|
| SFX (WAV) | 22050 Hz mono PCM | ~0.5 MB | ~0.8 MB | 0 | ~1.3 MB |
| Music (Ogg) | 128kbps stereo | ~5.2 MB | ~3.0 MB | 0 | ~8.2 MB |
| Ambient (Ogg) | 96kbps mono | 0 | ~1.1 MB | ~0.7 MB | ~1.8 MB |
| **Total** | | **~5.7 MB** | **~4.9 MB** | **~0.7 MB** | **~11.3 MB** |

---

## Appendix A: Engine Audio API Reference

The following UrhoX Lua API is available for audio implementation. This is provided as reference for the programming team.

### Global Objects
```lua
audio          -- Audio subsystem (global)
cache          -- ResourceCache (global, for loading Sound resources)
```

### Sound Type Constants
```lua
SOUND_MASTER   -- Master bus (all other types scaled relative to this)
SOUND_EFFECT   -- Sound effects (weapons, enemies, player, UI)
SOUND_AMBIENT  -- Ambient beds (arena hum, menu ambience)
SOUND_VOICE    -- Voice-over (reserved, unused in v1)
SOUND_MUSIC    -- Music tracks and stingers
```

### Audio Subsystem Methods
```lua
audio:SetMasterGain(type, gain)      -- Set volume for a sound type (0.0 - 1.0)
audio:GetMasterGain(type)            -- Get volume for a sound type
audio:PauseSoundType(type)           -- Pause all sounds of a type
audio:ResumeSoundType(type)          -- Resume all sounds of a type
audio:ResumeAll()                    -- Resume all paused sounds
audio:StopSound(sound)               -- Stop a specific sound
audio:AddSoundSource(source)         -- Register a SoundSource with the audio system
audio:RemoveSoundSource(source)      -- Unregister a SoundSource
audio:GetSoundSources()              -- Get all registered SoundSources
audio:SetListener(listener)          -- Set the active SoundListener
```

### Sound Resource Loading
```lua
local sound = cache:GetResource("Sound", "Sounds/sfx/weapons/sfx_weapon_blade_fire_v1.wav")
sound:SetLooped(false)  -- SFX: not looped; Music/Ambient: looped = true
```

### SoundSource Component
```lua
-- SoundSource is a Component — must be attached to a Node
source:SetSoundType(SOUND_EFFECT)
source:SetGain(0.8)
source:SetPanning(0.0)  -- -1.0 (left) to 1.0 (right)
source:SetAutoRemoveMode(REMOVE_COMPONENT)  -- Auto-cleanup after playback
source:SetDeclickEnabled(true)  -- Prevents click artifacts on start/stop

-- Play with optional parameters
source:Play(sound)                              -- Basic play
source:Play(sound, frequency)                   -- With pitch (frequency in Hz)
source:Play(sound, frequency, gain)             -- With gain
source:Play(sound, frequency, gain, panning)    -- With panning

source:Stop()              -- Fade out and stop
source:StopImmediate()     -- Stop instantly (may cause click — use declick)
source:IsPlaying()         -- Check if still playing
source:IsFadingIn()        -- Check if fading in
source:IsFadingOut()       -- Check if fading out
```

### AutoRemoveMode Constants
```lua
REMOVE_DISABLED    -- Source persists after playback (use for music/ambient)
REMOVE_COMPONENT   -- Source removes itself after playback (use for SFX pool)
REMOVE_NODE        -- Source + its Node are removed (not recommended for pooled sources)
```

---

## Appendix B: Color-Frequency Mapping Quick Reference

For sound designers creating assets, this table maps each visual color to recommended frequency characteristics:

| Color | Role | Synth Type | Frequency Focus | Envelope |
|---|---|---|---|---|
| Cyan | Player, safe | Sine / Triangle | 2-6 kHz (bright, clean) | Fast attack, medium decay |
| Magenta/Red | Enemy, hostile | Sawtooth + Noise | 200-800 Hz (gritty, mid-low) | Medium attack, fast decay |
| Teal | Skimmer, alternate | Ring Mod / FM | 1-3 kHz (metallic) | Medium attack, medium decay |
| Orange | Charger/Boss, danger | Sub + Alarm overtones | 40-120 Hz + 4-8 kHz | Slow build, sharp release |
| Gold | Upgrade, reward | Bell / Mallet synth | 2-5 kHz (harmonic, warm) | Medium attack, long decay |
| Violet | Advanced VFX | Detuned Saw pad | 200-400 Hz + 4-6 kHz | Slow attack, long sustain |
| Dark Navy | Background, ambience | Filtered Noise + Sine | 40-200 Hz (sub rumble) | Very slow, continuous |

---

*End of Audio Direction Document.*
