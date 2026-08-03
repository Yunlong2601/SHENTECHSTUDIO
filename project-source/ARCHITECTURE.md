# Geometry Breakout Architecture

## Runtime shape

The game is a UI-driven UrhoX Lua game. `scripts/main.lua` owns engine lifecycle and frame orchestration. Shared mutable runtime state lives in `scripts/state.lua`; feature modules receive state and callbacks rather than importing each other in a cycle.

## Current modules

- `state.lua` — screen constants, shared state, entity lists, HUD references, profile state, and player state.
- `i18n.lua` — bilingual runtime text source.
- `player.lua` — player reset, movement, touch/keyboard movement interpretation, and timers.
- `modules.lua` — six combat modules and their widget/effect updates.
- `enemies.lua` — enemy spawn, movement, collision, damage, and projectiles.
- `waves.lua` — wave modifier selection, wave start, and wave advancement.
- `ui.lua` — all screen builders, HUD construction, touch surface, and HUD refresh.
- `main.lua` — UI lifecycle, input event binding, pickups, summary flow, and frame orchestration.

## Approved next refactor

The UI extraction is complete. `main.lua` now coordinates lifecycle, callbacks, pickups, and the ordered update pipeline. Do not introduce a framework rewrite or ECS abstraction until the content prototype proves that the current module boundaries are insufficient.

## Update pipeline

`HandleUpdate` should remain ordered:

1. Read timestep and update run timers.
2. Update player movement.
3. Spawn enemies and automatic attacks.
4. Update defensive modules and enemy movement/collision.
5. Update projectiles and pickups.
6. Update orbit, mines, trail, and visual feedback.
7. End the wave or refresh HUD.

## Dependency rule

Feature modules communicate through explicit callbacks configured at startup. Avoid circular `require()` dependencies and avoid writing another module’s private tables directly. Any new system must state its owner, state fields, update order, and reset behavior before implementation.
