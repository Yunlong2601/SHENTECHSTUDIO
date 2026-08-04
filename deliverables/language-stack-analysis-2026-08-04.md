# Language & Stack Analysis — Geometry Breakout on TapTap Maker

> Date: 2026-08-04
> Verdict: **Lua 5.4 on UrhoX engine, distributed through TapTap Maker.** This is not a choice — it's already your stack, and it's the correct one.

---

## A. One-paragraph diagnosis

Your game is already built in **Lua 5.4** on the **UrhoX engine** (a Urho3D 1.8 fork), distributed through the **TapTap Maker** ecosystem. You have 9 Lua modules totaling ~2,500 lines, a working core loop, NanoVG vector rendering, Yoga flexbox UI, and a full MCP toolchain for AI-assisted development. The question isn't "what language should I use" — it's "do I understand what I already have, and am I using it correctly?" The answer to the second question is: mostly yes, but there are capabilities in the engine docs and TapTap Maker skills you're not leveraging yet.

---

## B. The Stack — What You're Actually Using

### Language: Lua 5.4

| Aspect | Detail |
|--------|--------|
| **Version** | Lua 5.4 (supports bitwise ops `&`, `|`, `~`, `<<`, `>>`) |
| **Binding** | tolua++ (C++ engine → Lua bridge) |
| **Indexing** | 1-based arrays (not 0) |
| **Unicode** | `\u{XXXX}` syntax (NOT `\uXXXX` — common AI mistake) |
| **OOP pattern** | `local M = {}; M.__index = M; function M:method() end; return M` |
| **Event data** | `eventData["FieldName"]:GetType()` or `eventData:GetType("FieldName")` |
| **No `io` library** | Sandbox removes `io`; use `File` class for storage |

**Why Lua is correct for this project:**

1. **TapTap Maker only runs Lua.** The entire build pipeline, MCP toolchain, preview system, and deployment path are Lua-only. Switching languages means leaving the ecosystem.
2. **Lightweight enough for mobile.** Lua's runtime footprint is tiny. Your game runs on Android phones/tablets and iPhone/iPad without a heavy VM.
3. **Hot-reload friendly.** TapTap Maker's preview loop is designed for Lua's interpreted nature — change a file, rebuild, test in seconds.
4. **AI-assisted workflow matches.** LLMs write Lua well when given proper context (which your `.emmylua/` type definitions and `AGENTS.md` rules provide).

### Engine: UrhoX (Urho3D 1.8 fork)

| Layer | Technology | What It Does |
|-------|-----------|--------------|
| **Scene graph** | Urho3D core (`Scene`, `Node`, `Component`) | Entity hierarchy, lifecycle, serialization |
| **2D physics** | Box2D (`RigidBody2D`, `CollisionShape2D`) | Collision detection, sensors, triggers |
| **3D physics** | Bullet (`RigidBody`, `CollisionShape`) | 3D collision (not used in your game) |
| **Vector rendering** | NanoVG (C API, 1:1 Lua mapping) | All your neon geometry, shapes, glow effects |
| **UI system** | urhox-libs/UI (Yoga Flexbox + NanoVG, 40+ widgets) | HUD, menus, upgrade overlay, touch joystick |
| **Audio** | Urho3D Audio (`Sound`, `SoundSource`) | SFX and music (not yet implemented) |
| **Input** | Urho3D Input (`Keyboard`, `Mouse`, `Touch`) | WASD + touch joystick |
| **Math** | `Vector2`, `Vector3`, `Color`, `Quaternion` | All positional and color math |
| **Storage** | `File`, `FileSystem` (sandboxed) | Save data (persistence API still unverified) |
| **Network** | `HttpClient`, `Network`, `ClientCloud`, `ServerCloud` | Cloud scores, leaderboards (future) |
| **Animation** | `AnimationStateMachine`, `BlendSpace` | FSM-driven animation (not used yet) |

### Platform: TapTap Maker

TapTap Maker is not just a "platform" — it's the entire production pipeline:

| Capability | Tool/Resource | Status |
|-----------|--------------|--------|
| **Build & preview** | `maker_build_current_directory` MCP tool | Active |
| **Test QR codes** | `generate_test_qrcode` | Available |
| **Player feedback** | `get_debug_feedbacks` (bug reports, logs, screenshots) | Available when exposed |
| **Image generation** | `generate_image`, `batch_generate_images`, `edit_image` | Available when exposed |
| **Video generation** | `create_video_task`, `query_video_task` | Available when exposed |
| **Music** | `text_to_music` | Available when exposed |
| **Sound effects** | `text_to_sound_effect`, `batch_sound_effects` | Available when exposed |
| **Voice dialogue** | `text_to_dialogue` | Available when exposed |
| **3D models** | `create_3d_asset` | Available when exposed |
| **Ads** | `get_ad_config`, `ShowRewardVideoAd` | Future (monetization phase) |
| **Cloud scores** | `ClientCloud`, `ServerCloud`, `Score` | Future (retention phase) |

---

## C. MD File Analysis — What the Docs Tell You

### `AGENTS.md` — The Master Policy File

This is the single most important file in your project. It's a TapTap Maker managed policy (version 3, hash-verified) that defines:

1. **Build workflow**: Never use generic Git for Maker builds. Always use `maker_build_current_directory`.
2. **Ad workflow**: Must read `maker://ads-integration-guide` before any ad work. `get_ad_config` is source of truth.
3. **Feedback workflow**: `get_debug_feedbacks` for player-submitted bugs, logs, screenshots.
4. **Asset generation**: Full MCP toolchain for images, video, music, SFX, dialogue, 3D.
5. **MCP recovery**: Diagnostic flow for when Maker tools disconnect (`-32000`, `Connection closed`).
6. **Engine knowledge**: 17 rules covering coordinates, resolution, NanoVG, UI, physics, input, enums, modularity, networking.

**Key insight**: AGENTS.md is not documentation — it's a **policy contract** between you, the AI assistant, and the TapTap Maker build system. Violating it causes build failures, silent bugs, and wasted time.

### `engine-docs/` — Engine Reference (42 files)

| Directory | Files | Purpose |
|-----------|-------|---------|
| `api/` | 10 files | Class-level API reference (Core, Graphics, Physics, Audio, Input, Math, Enums, Globals, Network) |
| `recipes/` | 22 files | Solution-oriented guides (UI, materials, rendering, file storage, cloud scores, networking, state machines, NanoVG, procedural geometry, i18n, video, HTTP, JSON, SDK, download-while-playing) |
| `gotchas/` | 3 files | Verified pitfalls (physics friction, camera orthoSize 0.5 factor) |
| `lua-scripting-guide.md` | 1 file | The master guide: eventData access, NanoVG API mapping, Box2D sensors, OOP patterns, Unicode, object lifecycle, error reference |

**What you're already using well**: Core scene graph, NanoVG rendering, UI components, input handling, wave/enemy/module systems.

**What you're NOT using yet but should**: `recipes/file-storage.md` (persistence), `recipes/client-cloud-score.md` (leaderboards), `recipes/state-machine.md` (boss FSM), `api/audio.md` (SFX/music), `recipes/rendering.md` (bloom/glow for Neon Vector Geometry).

### `project-source/` — Your Design Documents (12 files)

These are YOUR documents, not engine docs:

| File | Purpose |
|------|---------|
| `PROJECT_CONTEXT.md` | Source of truth for project identity, status, vocabulary, milestones |
| `ARCHITECTURE.md` | Module boundaries, update pipeline, dependency rules |
| `ROADMAP.md` | M1-M10 milestone ladder |
| `ART_STYLE.md` | Neon Vector Geometry canonical style guide |
| `UI_LAYOUT.md` | HUD layout, screen flow, touch surface design |
| `PLAYTEST_M1.md` | M1 playtest checklist (10 runs, pending) |

### `templates/` — Scaffolds (4 files)

| Scaffold | When to Use |
|----------|-------------|
| `scaffold-2d.lua` | Pure 2D games (your game is closest to this) |
| `scaffold-2d-physics.lua` | 2D physics platformers (Box2D) |
| `scaffold-3d-scene.lua` | 3D scene visualization |
| `scaffold-3d-character.lua` | 3D character games (ThirdPersonCamera) |

Your game evolved beyond the scaffold — you have a custom modular architecture. Don't go back to scaffolds.

### `examples/` — 22 Reference Games

| Most relevant to you | Why |
|---------------------|-----|
| `03-flappy-bird-game.lua` | NanoVG-based complete game loop |
| `10-nanovg-bloom.lua` | Bloom/glow effects (directly relevant to Neon Vector Geometry) |
| `14-ui-widgets-gallery.lua` | All 41 UI components |
| `13-yoga-layout-nanovg-render.lua` | Yoga + NanoVG integration |
| `11-client-cloud-score-leaderboard-api.lua` | Cloud scores (future retention) |

---

## D. Skills Analysis — What TapTap Maker Provides

The AGENTS.md references several skill systems embedded in the engine:

### Engine Skills (from `skills/` directory, auto-discovered)

| Skill | Trigger | Relevance |
|-------|---------|-----------|
| `materials` | Material technique questions | Medium — your game uses procedural NanoVG, not PBR materials |
| `nvg-resolution-mode` | Raw NanoVG calls | **High** — your game uses NanoVG for all rendering |
| `setup-fsm` | Animation state machine setup | Medium — boss phases could use FSM |
| `run-lua-headless` | Procedural generation / offline baking | Low — not needed yet |
| UI style skills (`ui-astroon`, `ui-brawlforge`, `ui-pixelforge`) | UI theme selection | Medium — could speed up UI polish |

### TapTap Maker MCP Skills (from AGENTS.md)

| Skill Category | Tools | When to Use |
|---------------|-------|-------------|
| **Asset generation** | `generate_image`, `batch_generate_images`, `edit_image` | Creating enemy silhouettes, boss designs, module VFX sprites |
| **Audio generation** | `text_to_music`, `text_to_sound_effect`, `batch_sound_effects` | SFX for hits, explosions, level-up; background music |
| **Video generation** | `create_video_task`, `query_video_task` | Trailer/preview videos for TapTap store page |
| **3D models** | `create_3d_asset` | Not needed (your game is 2D NanoVG) |
| **Voice** | `text_to_dialogue`, `audition_voices_for_character` | Not needed (no characters with voice) |
| **Build/submit** | `maker_build_current_directory` | Every time you want to preview or publish |
| **Test** | `generate_test_qrcode` | QR code for device testing |
| **Feedback** | `get_debug_feedbacks` | Player bug reports, logs, screenshots |
| **Ads** | `get_ad_config`, `ShowRewardVideoAd` | Future — monetization phase only |

---

## E. Why NOT Other Languages

| Alternative | Why It's Wrong |
|-------------|---------------|
| **JavaScript/TypeScript (Cocos/PixiJS)** | Wrong ecosystem. TapTap Maker doesn't support it. You'd lose the entire MCP toolchain, build pipeline, and preview system. |
| **C# (Unity)** | Heavyweight for a 2D arena survival game. No TapTap Maker integration. Overkill. |
| **GDScript (Godot)** | Godot is great, but TapTap Maker doesn't run Godot projects. You'd lose the platform. |
| **Python** | Not a game runtime. Fine for tooling (which you already use for diagnostics), not for the game itself. |
| **C++ (native Urho3D)** | UrhoX exposes everything via Lua. Writing C++ would mean fighting the engine's design. |
| **Rust/Go** | No game engine ecosystem match. No TapTap Maker support. |

---

## F. What This Means for Your Production Plan

### You should NOT change languages. You should:

1. **Deepen Lua mastery** — Learn the UrhoX-specific patterns (event data access, OOP with `:init`, object lifecycle management, NanoVG render events).
2. **Use the MCP asset tools** — You haven't generated any SFX, music, or polished visual assets yet. The tools are sitting there unused.
3. **Read the recipes you haven't read** — `file-storage.md` for persistence, `client-cloud-score.md` for leaderboards, `rendering.md` for bloom/glow on your neon visuals.
4. **Leverage the LSP** — `.emmylua/` type definitions + `maker-lua-lsp` give you IDE-grade autocomplete and error checking. Use it before every build.
5. **Follow AGENTS.md rules religiously** — Every rule exists because someone hit that bug. Rule #6 (NanoVGRender event), Rule #10 (UI system choice), Rule #4 (1-based arrays) are the top three that bite AI-generated code.

### What you should explicitly NOT do:

- Don't add a second language for tooling (Python scripts for data processing are fine, but don't introduce a JS build step).
- Don't try to write C++ engine extensions — UrhoX is designed to be driven from Lua.
- Don't switch engines to "future-proof" — TapTap Maker is your distribution channel; leaving it means losing your audience path.

---

## G. The One-Sentence Summary

**Your language is Lua 5.4, your engine is UrhoX, your platform is TapTap Maker, and your biggest opportunity isn't switching stacks — it's using the 60% of engine capabilities and MCP tools you haven't touched yet.**
