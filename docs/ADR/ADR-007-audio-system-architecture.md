# ADR-007: Audio System Architecture

| Field | Value |
|-------|-------|
| **Status** | Proposed (pending implementation) |
| **Date** | 2026-08-05 |
| **Author** | Engineering Lead (Cheng Jiyan) |
| **Supersedes** | — |
| **Related** | `project-source/AUDIO_DIRECTION.md` S6, `scripts/audio.lua` |

---

## Context

Geometry Breakout is a Brotato-style top-down survivor roguelite built entirely on UrhoX's UI-widget system. The entire game — player character, enemies, weapons, projectiles, pickups — is rendered via `UI.Panel` widgets positioned absolutely on screen. The entry point `scripts/main.lua` sets up UI panels and subscribes to `Update`/`KeyDown`/`KeyUp` events. **There is no Scene, no Node hierarchy, and no Component system anywhere in the codebase.**

UrhoX's `SoundSource` is a `Component` that must be attached to a `Node` within a `Scene`. The `SoundListener` (the "ears" of the audio system) is also a `Component`. The global `audio` subsystem can register/unregister SoundSources manually via `Audio:AddSoundSource()` / `Audio:RemoveSoundSource()`, but SoundSources still need a Node to exist as a component.

The audio direction document (`AUDIO_DIRECTION.md` S6.1) proposes creating a minimal "audio Scene" — one Scene with one Node containing a `SoundListener` + a pool of 16 `SoundSource` components for SFX + 2 `SoundSource` components for music crossfading. **This approach had not been validated.**

## Investigation

### API Surface Verified

The following UrhoX Lua API was confirmed from `.emmylua/` type definitions and engine examples:

| Capability | API | Source |
|---|---|---|
| Create Scene programmatically | `Scene.new()` or `Scene()` | `Scene.d.lua` line 34; examples use `scene_ = Scene()` |
| Create child Node on Scene | `scene:CreateChild(name)` | `Node.d.lua` line 347; confirmed in 6+ examples |
| Create SoundListener component | `node:CreateComponent("SoundListener")` | `SoundListener.d.lua` — class extends Component; `Node.d.lua` CreateComponent union func |
| Create SoundSource component | `node:CreateComponent("SoundSource")` | `SoundSource.d.lua` — class extends Component; confirmed in `urhox-libs/Effects/Effects.lua` line 138 |
| Set active listener | `audio:SetListener(listener)` | `Audio.d.lua` line 46 |
| Load Sound resource | `cache:GetResource("Sound", path)` | `Sound.d.lua`; confirmed in Effects.lua line 141 |
| Play sound with parameters | `source:Play(sound, freq, gain, panning)` | `SoundSource.d.lua` line 45 |
| Set sound type | `source:SetSoundType(SOUND_EFFECT)` | `SoundSource.d.lua` line 62 |
| Set auto-remove mode | `source:SetAutoRemoveMode(mode)` | `SoundSource.d.lua` line 82 |
| Set master gain per type | `audio:SetMasterGain(type, gain)` | `Audio.d.lua` line 31 |
| Pause/resume by type | `audio:PauseSoundType(type)` / `audio:ResumeAll()` | `Audio.d.lua` lines 35, 42 |

### Scene Creation Patterns in Codebase

Six example projects in `examples/` create Scenes programmatically using `scene_ = Scene()` or `scene_ = Scene:new()`. All follow the pattern:

```lua
scene_ = Scene()
scene_:CreateComponent("Octree")        -- for 3D rendering
scene_:CreateComponent("DebugRenderer") -- for debug visuals
local node = scene_:CreateChild("NodeName")
local component = node:CreateComponent("ComponentType")
```

The `urhox-libs/Effects/Effects.lua` library (lines 121-189) already implements `Effects.PlaySound(scene, soundPath, options)` which creates a child node + SoundSource component on a given Scene. This confirms the pattern works.

### Coexistence with UI-Only Game

**Verified**: A Scene can coexist with a UI-only game without conflict:

1. **No Viewport required**: Audio components (SoundSource, SoundListener) do not require a Viewport or Camera. The Audio subsystem iterates registered SoundSources independently of the rendering pipeline.
2. **No Octree required**: Octree is needed for spatial culling of Drawable components (StaticModel, Light, etc.). SoundSource is not a Drawable — it does not need an Octree.
3. **No Scene::Update() required**: The Audio subsystem updates SoundSources in its own internal `Update()` call, driven by the engine's main loop, not by `Scene:Update()`. The Scene does not need to be registered with a Viewport for audio to work.
4. **Audio global is independent**: The `audio` global is an engine subsystem available from engine startup, not dependent on any Scene. It tracks SoundSources via `AddSoundSource()` / `RemoveSoundSource()`, which are called automatically when SoundSource components are created on Nodes within a Scene.
5. **No conflict with UI system**: The UI system (`UI.SetRoot()`, `UI.Panel()`, etc.) operates on a completely separate rendering path (Yoga + NanoVG) that does not interact with the Scene/Node/Component hierarchy.

### `scripts/` Has Zero Scene References

A grep of `scripts/` for `Scene`, `scene_`, `CreateChild`, `CreateComponent` returned **zero matches**. The game truly has no Scene anywhere in its codebase. The AudioManager will be the first and only module to create one.

## Decision

**Adopt the Minimal Audio Scene approach** as proposed in `AUDIO_DIRECTION.md` S6.1.

The AudioManager (`scripts/audio.lua`) creates a single Scene with a single root Node at world origin (0,0,0). This Node hosts:
- 1 `SoundListener` component (the "ears")
- 16 `SoundSource` components for SFX (pool)
- 2 `SoundSource` components for music (A/B crossfading)
- 1 `SoundSource` component for ambient

```
Scene (audioScene)
  +-- Node "AudioNode" (position: 0,0,0)
       +-- SoundListener (active listener)
       +-- SoundSource [sfx_01..sfx_16] (type: SOUND_EFFECT)
       +-- SoundSource [music_a] (type: SOUND_MUSIC)
       +-- SoundSource [music_b] (type: SOUND_MUSIC)
       +-- SoundSource [ambient] (type: SOUND_AMBIENT)
```

The Scene is created once at game initialization (`AudioManager:Init()` called from `main.lua Start()`) and destroyed on shutdown (`AudioManager:Shutdown()` called from `main.lua Stop()`). The Scene is never rendered (no Camera, no Viewport). It exists solely to host audio components.

### Deviation from Spec: REMOVE_DISABLED for SFX Pool

The `AUDIO_DIRECTION.md` S6.2 specifies `REMOVE_COMPONENT` auto-remove mode for SFX pool sources. **This ADR overrides that specification: SFX pool sources use `REMOVE_DISABLED` instead.**

**Rationale**: `REMOVE_COMPONENT` removes the SoundSource component from the Node after playback finishes. For a pooled source design (16 persistent sources reused across many plays), this is counterproductive — it would require recreating components after each play, introducing GC pressure and allocation overhead on the hot path. `REMOVE_DISABLED` keeps the component alive after playback, allowing it to be reused by checking `IsPlaying() == false`. The pool's voice limit (16 concurrent voices) is enforced by the AudioManager's preemption logic, not by auto-remove.

`REMOVE_COMPONENT` would be appropriate for a "fire-and-forget" design (like `urhox-libs/Effects/Effects.lua` which creates a new node+source per play and auto-removes the node). For a pool, `REMOVE_DISABLED` is correct.

### Panning Calculation

The AudioManager calculates stereo panning from optional world X/Y coordinates passed to `PlaySFX()`. Since the game is UI-widget-based and the AudioManager doesn't have direct access to game state (player position), the panning is calculated relative to screen center. Callers pass the entity's screen X position; the AudioManager maps it to a pan value in [-0.7, +0.7] (clamped per S5.5).

This is a pragmatic solution. A future improvement could have the AudioManager receive the player's position via a `SetListenerPosition(x, y)` call each frame, enabling true relative panning.

## Consequences

### Positive

1. **Audio works in a UI-only game**: The minimal Scene approach unblocks the entire audio implementation without requiring a fundamental architecture change (converting gameplay from UI widgets to Scene/Node).
2. **Low memory overhead**: One Scene + one Node + 20 components ≈ negligible memory. No Octree, no physics world, no rendering pipeline.
3. **No rendering interference**: The audio Scene has no Camera/Viewport, so it does not affect the UI rendering pipeline at all.
4. **Clean API**: Other modules call `AudioManager:PlaySFX(eventId)` without knowing or caring about the Scene/Node/Component details.
5. **Extensible**: New SFX events can be added to the `SFX_EVENTS` table without code changes. Music and ambient tracks are similarly data-driven.

### Negative

1. **Architecture inconsistency**: The game now has a Scene for audio but not for gameplay. This is a deliberate trade-off — future migration to Scene-based gameplay would need to reconcile the audio Scene.
2. **Panning is screen-relative, not world-relative**: Since the AudioManager doesn't have access to game state, panning is calculated from screen coordinates, not relative to the player's actual position. This is acceptable for a 2D top-down game where the player is always near screen center, but is less precise than a world-space listener.
3. **No Scene::Update() called**: The audio Scene's `Update()` is never called. This is intentional (audio doesn't need it), but means any future components added to the audio Scene that require Scene updates would not function. This is an acceptable constraint — the audio Scene is for audio only.
4. **SoundSource pool is fixed at 16**: The pool size is hardcoded. If profiling shows 16 is insufficient (unlikely based on S5.4 analysis), the pool size would need to be increased and the module reloaded.

### Risks

1. **SoundSource auto-registration**: SoundSources are expected to auto-register with the Audio subsystem when created as components on a Node within a Scene. If auto-registration fails (e.g., because the Scene has no Octree), the AudioManager would need to manually call `audio:AddSoundSource(source)` for each source. **Mitigation**: The `urhox-libs/Effects/Effects.lua` library already uses this pattern successfully, providing confidence that auto-registration works. If it doesn't, the fix is trivial (add `audio:AddSoundSource(source)` calls in `Init()`).

2. **Sound resource availability**: The prototype is being written before audio assets exist. All `PlaySFX` / `PlayMusic` calls will silently no-op when resources are not found. This is intentional — the AudioManager degrades gracefully. **Mitigation**: The `soundCache_` table caches failed loads as `false` to avoid repeated `cache:GetResource()` calls for missing files.

## Implementation

- **File**: `scripts/audio.lua` — AudioManager module (prototype complete)
- **Integration points**: See "Integration Points" section below
- **Testing**: Manual testing required once audio assets are available. Unit testing is not feasible in the UrhoX Lua environment without a test harness.

## Integration Points

### main.lua

| Location | Line | Call | Purpose |
|---|---|---|---|
| `Start()` — after `UI.Init()` (line 566), before `SubscribeToEvent` (line 568) | ~567 | `require("audio").Init()` | Initialize audio system at game startup |
| `HandleUpdate()` — after `local timeStep = ...` (line 395), before any game logic | ~396 | `require("audio").Update(timeStep)` | Per-frame audio updates (crossfade, ambient fade) |
| `Stop()` — after `ClearEntities()` (line 573), before `UI.Shutdown()` | ~573 | `require("audio").Shutdown()` | Clean up audio on engine shutdown |

### weapons.lua

| Location | Line | Call | Purpose |
|---|---|---|---|
| `M.update()` — after the fire dispatch block (lines 217-219) | ~220 | `require("audio").PlaySFX("sfx_weapon_" .. w.id .. "_fire")` | Play weapon fire SFX for all 6 weapon types |

The fire dispatch at lines 217-219 is:
```lua
if     def.tag == "melee"  then M.fire_melee(def)
elseif def.tag == "magic"  then M.fire_magic(def)
else                            M.fire_ranged(def)
end
```

The SFX call would go immediately after this `if/elseif/else` block, using `w.id` (the weapon slot's ID: "blade", "bow", "staff", "mace", "crossbow", "thrown"). This maps directly to the event IDs: `sfx_weapon_blade_fire`, `sfx_weapon_bow_fire`, etc.

### Future Integration Points (not in this task)

| Module | Events | Phase |
|---|---|---|
| `enemies.lua` | `sfx_enemy_*_spawn`, `sfx_enemy_*_death`, `sfx_enemy_*_telegraph`, `sfx_enemy_*_dash` | Phase B |
| `player.lua` | `sfx_player_damage`, `sfx_player_heal`, `sfx_player_dodge`, `sfx_player_levelup`, `sfx_player_death` | Phase B |
| `main.lua` (pickups) | `sfx_player_pickup_gold`, `sfx_player_pickup_xp` | Phase B |
| `waves.lua` | `sfx_wave_start`, `sfx_wave_clear`, `AudioManager:PlayMusic(...)` | Phase C |
| `shop.lua` | `ui_shop_*`, `AudioManager:PlayMusic("music_shop")` | Phase D |
| `ui.lua` | `ui_nav_*`, `ui_upgrade_*` | Phase D |

## Alternatives Considered

### Alternative A: Bare SoundSources via Audio:AddSoundSource()

Instead of creating a Scene, manually create SoundSource objects and register them with `audio:AddSoundSource()`.

**Rejected because**: SoundSource is a Component — it requires a Node to exist as a component. Creating a "bare" SoundSource without a Node is not supported by the engine API. The `Audio:AddSoundSource()` method registers an already-created SoundSource (which must be attached to a Node) with the Audio subsystem — it does not create one.

### Alternative B: Use urhox-libs/Effects/Effects.lua

The Effects library already has `PlaySound()` and `PlaySoundLooped()` functions. However, these require a `scene` parameter — they create a new child Node + SoundSource per call and auto-remove after playback.

**Rejected because**: This is a "fire-and-forget" pattern, not a pool. It would create and destroy Nodes/Components on every SFX play (potentially 30+ per second during combat), causing GC pressure. It also doesn't provide voice limiting, throttling, priority preemption, or crossfading. The AudioManager needs these features (S5.4).

The Effects library could be used as a fallback or for one-off sounds, but the AudioManager's pool-based approach is better for the high-density combat audio described in the audio direction document.

### Alternative C: No Scene — use Audio subsystem directly

Some engines allow playing sounds without any Scene/Node hierarchy. UrhoX does not — SoundSource is fundamentally a Component.

**Rejected because**: Not possible with the UrhoX API.

## References

- `project-source/AUDIO_DIRECTION.md` S6.1 — The "No Scene/Node" Constraint (proposes this approach)
- `project-source/AUDIO_DIRECTION.md` S6.2 — AudioManager Module Design (API specification)
- `.emmylua/Scene.d.lua` — Scene API (confirms `Scene.new()`, `CreateChild`)
- `.emmylua/Node.d.lua` — Node API (confirms `CreateChild`, `CreateComponent`)
- `.emmylua/SoundSource.d.lua` — SoundSource API (confirms Play, Stop, IsPlaying, etc.)
- `.emmylua/SoundListener.d.lua` — SoundListener API (Component subclass)
- `.emmylua/Audio.d.lua` — Audio subsystem API (confirms SetListener, SetMasterGain, etc.)
- `.emmylua/Component.d.lua` — Component base class (confirms REMOVE_DISABLED/COMPONENT/NODE constants)
- `urhox-libs/Effects/Effects.lua` lines 121-189 — Existing PlaySound implementation (confirms pattern)
- `engine-docs/recipes/network-game-guide.md` lines 1927-1931 — Sound playing pattern with Scene:CreateChild
- `examples/18-physics-collision-3d.lua` line 164 — Scene creation pattern (`Scene()`)
- `examples/21-video-screen-3d.lua` line 67 — Scene creation pattern (`Scene:new()`)
