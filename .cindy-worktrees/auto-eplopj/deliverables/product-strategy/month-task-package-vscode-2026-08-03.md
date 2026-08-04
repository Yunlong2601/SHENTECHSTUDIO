# CodeBuddy Work Audit & Next Month Task Package for VS Code Copilot

**Date**: 2026-08-03
**Prepared by**: 方向明 (Product Helmsman)
**Target**: VS Code Copilot (replacing CodeBuddy)

---

## Part 1: CodeBuddy Audit — What Was Completed

### Summary Scorecard

| Req | Title | Status | Completion | Key Gap |
|-----|-------|--------|------------|---------|
| R-02 | Weighted Spawn Distribution | ⚠️ Partial | 50% | Wrong wave gating — Splitter at W5 not W3, Shooter from W1 not W5, early waves have Charger+Shooter (should be Chaser+Skimmer only) |
| R-03 | Glitch Modifier Fix | ⚠️ Partial | 40% | Missing: Poisson process, modifier corruption (Compression jitter, Overclock fluctuation), flicker visuals, pulse cycle, correct displacement ±18px |
| R-05 | Fragment Cap | ✅ Complete | 100% | None — working correctly, cap at 10 |
| R-06 | Dynamic Enemy Cap | ❌ Minimal | 30% | `maxEnemies_` never changes from 24; needs dynamic 30 (normal) / 25 (glitch) |

### Detailed Audit

#### R-02: Weighted Spawn Distribution (50% done)

**What CodeBuddy did:**
- Rewrote `kind_for_id()` in `scripts/enemies.lua` (lines 12-41) from equal modulo to weighted random
- Implemented 4 wave-tier blocks with different weight distributions

**What's WRONG (must fix):**

1. **Splitter intro wave**: Code has Splitter starting at Wave 5 (`elseif wave >= 5` block). PRD spec: **Splitter at Wave 3**.

2. **Shooter intro wave**: Code has Shooter available from Wave 1-2 (`else` block, 10% chance). PRD spec: **Shooter at Wave 5**.

3. **Early waves (1-2)**: Code has Chaser 45% + Skimmer 25% + Charger 20% + Shooter 10%. PRD spec: **Chaser + Skimmer only** (no Charger, no Shooter).

4. **Weight distribution doesn't match PRD**: PRD target is Chaser 30% / Skimmer 20-25% / Charger 15% / Splitter 10% / Shooter 20-25%. Code has wildly different per-tier weights.

**Current code** (`enemies.lua` lines 12-41):
```lua
function M.kind_for_id(enemyId, wave)
    local r = math.random()
    if wave >= 7 then
        -- Wave 7-8: chaser 15%, skimmer 10%, charger 10%, shooter 30%, splitter 35%
        ...
    elseif wave >= 5 then
        -- Wave 5-6: chaser 20%, skimmer 15%, charger 15%, shooter 25%, splitter 25%
        ...
    elseif wave >= 3 then
        -- Wave 3-4: chaser 35%, skimmer 25%, charger 20%, shooter 20%
        ...
    else
        -- Wave 1-2: chaser 45%, skimmer 25%, charger 20%, shooter 10%
        ...
    end
end
```

#### R-03: Glitch Modifier Fix (40% done)

**What CodeBuddy did:**
- Removed old `math.random() < 0.02` per-frame check ✅
- Glitch no longer replaces modifier — `waves.lua` `modifier_for_wave()` no longer returns "glitch" ✅
- Added `is_glitch_wave()` returning `wave >= 7` ✅
- `glitchWave_` flag set in `begin_wave()` ✅
- Tick-based displacement system: every 1.5s, enemies get ±12px random displacement targets ✅
- Smooth lerp drift toward displacement targets ✅
- `corruption_` counter increments per tick ✅
- New state fields: `glitchWave_`, `corruption_`, `glitchTickTimer_` ✅

**What's MISSING (must implement):**

1. **Not a Poisson process**: Uses 1.5s fixed tick timer. Spec: delta-time Poisson with λ≈0.18/s (≈0.3% chance per frame at 60fps, frame-rate independent). The tick approach is periodic, not random.

2. **No modifier corruption**: Glitch should CORRUPT the active modifier, not just displace enemies:
   - Glitch + Compression: arena bounds should jitter ±18px (currently `bound` stays static at 70)
   - Glitch + Overclock: spawn rate should fluctuate ±15% (currently no effect on Overclock multiplier)

3. **No pulse cycle**: Spec: 1.5s active glitch → 1.5-2s clear period. CodeBuddy's version is always-on during glitch waves with 1.5s ticks.

4. **No flicker visuals**: Spec: enemy flicker 50ms duration, max 3 concurrent flickers, alpha 60-100%. No visual flicker implemented.

5. **Wrong displacement**: ±12px in code, spec says ±18px.

6. **Missing state fields**: `glitchActive_`, `glitchFlickerCount_`, `glitchPulseTimer_` not in `state.lua`.

#### R-05: Fragment Cap (100% done) ✅

`spawn_fragment()` (lines 90-102) correctly counts fragments and caps at 10. No issues.

#### R-06: Dynamic Enemy Cap (30% done)

**What CodeBuddy did:**
- `state.maxEnemies_` field added (line 206, default 24)
- `spawn()` checks `#state.enemies_ >= state.maxEnemies_` (line 44)
- `spawn_fragment()` also checks it (line 91)

**What's MISSING:**
- `maxEnemies_` is NEVER updated dynamically — stays at 24 forever
- `begin_wave()` in `waves.lua` doesn't set it based on wave type
- `ResetRunState()` in `main.lua` hard-codes it to 24 (line 146)
- Spec: Normal waves = 30, Glitch waves = 25

---

## Part 2: Next Month Task Package for VS Code Copilot

### Overview

This is a 4-week implementation plan. Each week is a self-contained batch of tasks. Paste the instructions into VS Code Copilot chat one task at a time.

**Total scope**: Fix Phase 1 gaps + Complete Phase 2 (boss encounters) + Start Phase 3 (UI feedback)

| Week | Focus | Requirements | Est. Hours |
|------|-------|-------------|------------|
| Week 1 | Fix Phase 1 Gaps | R-02 fix, R-03 completion, R-06 dynamic cap | 16h |
| Week 2 | Mid-Boss Encounter | R-01 (full) | 12h |
| Week 3 | Final Boss Escalation + Wave Tuning | R-04, R-07, R-08 | 21h |
| Week 4 | UI Feedback Layer | R-09, R-10, R-11 | 11h |

---

### WEEK 1: Fix Phase 1 Gaps (R-02, R-03, R-06)

---

#### Task 1.1: Fix R-02 — Weighted Spawn Distribution Wave Gating

**File**: `scripts/enemies.lua`
**Function**: `M.kind_for_id` (lines 12-41)

**Problem**: Wave gating is wrong. Splitter should intro at W3 (not W5), Shooter should intro at W5 (not W1), and Waves 1-2 should only have Chaser + Skimmer.

**Replace the entire `kind_for_id` function with:**

```lua
function M.kind_for_id(enemyId, wave)
    local r = math.random()
    if wave >= 7 then
        -- Wave 7-8: Chaser 30%, Skimmer 20%, Charger 15%, Splitter 10%, Shooter 25%
        if r < 0.30 then return "chaser"
        elseif r < 0.50 then return "skimmer"
        elseif r < 0.65 then return "charger"
        elseif r < 0.75 then return "splitter"
        else return "shooter" end
    elseif wave >= 5 then
        -- Wave 5-6: Chaser 35%, Skimmer 25%, Charger 15%, Splitter 10%, Shooter 15%
        if r < 0.35 then return "chaser"
        elseif r < 0.60 then return "skimmer"
        elseif r < 0.75 then return "charger"
        elseif r < 0.85 then return "splitter"
        else return "shooter" end
    elseif wave >= 3 then
        -- Wave 3-4: Chaser 45%, Skimmer 30%, Charger 15%, Splitter 10%
        if r < 0.45 then return "chaser"
        elseif r < 0.75 then return "skimmer"
        elseif r < 0.90 then return "charger"
        else return "splitter" end
    else
        -- Wave 1-2: Chaser 60%, Skimmer 40% ONLY
        if r < 0.60 then return "chaser"
        else return "skimmer" end
    end
end
```

**Acceptance criteria:**
- [ ] Wave 1-2: only Chaser and Skimmer spawn (no Charger, Shooter, or Splitter)
- [ ] Wave 3-4: Chaser, Skimmer, Charger, Splitter (no Shooter)
- [ ] Wave 5-6: All 5 types including Shooter
- [ ] Wave 7-8: All 5 types with adjusted weights
- [ ] No single type exceeds 45% in any wave tier

---

#### Task 1.2: Fix R-06 — Dynamic Enemy Cap

**File**: `scripts/waves.lua`
**Function**: `M.begin_wave` (lines 29-41)

**Problem**: `state.maxEnemies_` is never updated from its default of 24. It should be 30 for normal waves and 25 for glitch waves.

**In `begin_wave()`, add the dynamic cap setting after line 32 (`state.glitchWave_ = ...`):**

```lua
function M.begin_wave()
    state.screen_ = state.SCREEN_GAME
    state.modifier_ = M.modifier_for_wave(state.wave_)
    state.glitchWave_ = M.is_glitch_wave(state.wave_)
    state.corruption_ = 0
    state.glitchTickTimer_ = 0
    -- R-06: Dynamic enemy cap — 30 normal, 25 glitch
    state.maxEnemies_ = state.glitchWave_ and 25 or 30
    state.surgeTimer_, state.waveTime_, state.waveSpawned_, state.spawnTimer_ = 2.5, 0, 0, 0
    if M.is_boss_wave(state.wave_) then
        state.waveSpawnTarget_ = 4
    else
        state.waveSpawnTarget_ = 8 + state.wave_ * 3
    end
end
```

**Also in `scripts/main.lua` `ResetRunState()` (line 146), change:**
```lua
state.maxEnemies_ = 24
```
**to:**
```lua
state.maxEnemies_ = 30
```

**Acceptance criteria:**
- [ ] Waves 1-6: max 30 enemies on screen simultaneously
- [ ] Waves 7-8 (glitch): max 25 enemies on screen
- [ ] `maxEnemies_` resets to 30 at start of each non-glitch wave
- [ ] Fragment cap (10) still works independently

---

#### Task 1.3: Complete R-03 — Glitch Modifier Full Implementation

This is the most complex task. It has 3 sub-tasks.

##### Task 1.3a: Add missing state fields

**File**: `scripts/state.lua`

**After the existing Glitch fields (around line 202), add:**

```lua
-- ── Glitch corruption overlay (R-03) — extended ─────────────────────────
---@type boolean
M.glitchActive_ = false      -- true during active glitch pulse (1.5s)
---@type number
M.glitchPulseTimer_ = 0      -- countdown: active phase >0, clear phase <0
---@type number
M.glitchFlickerCount_ = 0    -- current concurrent flicker count (max 3)
```

**Also in `scripts/main.lua` `ResetRunState()` (around line 145), add:**
```lua
state.glitchActive_ = false; state.glitchPulseTimer_ = 0; state.glitchFlickerCount_ = 0
```

##### Task 1.3b: Replace tick timer with Poisson + pulse cycle

**File**: `scripts/enemies.lua`
**Function**: `M.update` (lines 162-188)

**Replace the entire glitch block at the top of `M.update` (lines 164-188) with:**

```lua
function M.update(timeStep)
    local player = p()
    -- R-03: Glitch corruption overlay — Poisson trigger + pulse cycle
    local isGlitchWave = state.glitchWave_
    if isGlitchWave then
        -- Poisson process: P(trigger this frame) = 1 - e^(-lambda * dt)
        -- lambda ≈ 0.18/s → ~0.3% per frame at 60fps, frame-rate independent
        local lambda = 0.18
        if not state.glitchActive_ and state.glitchPulseTimer_ <= 0 then
            -- In clear phase — check if Poisson triggers a new glitch pulse
            if 1 - math.exp(-lambda * timeStep) > math.random() then
                state.glitchActive_ = true
                state.glitchPulseTimer_ = 1.5  -- active for 1.5s
            end
        end

        if state.glitchActive_ then
            -- Active glitch phase
            state.glitchPulseTimer_ = state.glitchPulseTimer_ - timeStep
            if state.glitchPulseTimer_ <= 0 then
                -- Transition to clear phase (1.5-2s)
                state.glitchActive_ = false
                state.glitchPulseTimer_ = -(1.5 + math.random() * 0.5)  -- negative = clear countdown
            else
                -- Apply corruption effects during active phase
                -- 1. Enemy displacement ±18px
                for _, e in ipairs(state.enemies_) do
                    if not e.dead then
                        e.glitchTargetX = e.x + math.random(-18, 18)
                        e.glitchTargetY = e.y + math.random(-18, 18)
                    end
                end
                -- 2. Corrupt Compression: jitter bounds ±18px
                -- (applied below where `bound` is calculated)
                -- 3. Corrupt Overclock: fluctuate multiplier ±15%
                -- (applied below where movement multiplier is calculated)
                -- 4. Flicker visuals: alpha 60-100%, 50ms duration
                state.glitchFlickerCount_ = 0
                for _, e in ipairs(state.enemies_) do
                    if not e.dead and state.glitchFlickerCount_ < 3 then
                        if math.random() < 0.15 then
                            state.glitchFlickerCount_ = state.glitchFlickerCount_ + 1
                            e.flickerTimer = 0.05  -- 50ms flicker
                            local alpha = math.random(60, 100)
                            e.widget:SetStyle({ opacity = alpha / 100 })
                        end
                    end
                end
            end
        else
            -- Clear phase — count down the negative timer
            state.glitchPulseTimer_ = state.glitchPulseTimer_ + timeStep
            -- Reset any flicker alpha
            for _, e in ipairs(state.enemies_) do
                if not e.dead and e.flickerTimer and e.flickerTimer > 0 then
                    e.flickerTimer = e.flickerTimer - timeStep
                    if e.flickerTimer <= 0 then
                        e.widget:SetStyle({ opacity = 1 })
                    end
                end
            end
        end

        -- Smooth lerp toward glitch target (during active phase only)
        if state.glitchActive_ then
            local driftSpeed = 80
            for _, e in ipairs(state.enemies_) do
                if not e.dead and e.glitchTargetX then
                    e.x = e.x + (e.glitchTargetX - e.x) * math.min(1, driftSpeed * timeStep)
                    e.y = e.y + (e.glitchTargetY - e.y) * math.min(1, driftSpeed * timeStep)
                end
            end
        end
    end

    -- Calculate bound with Glitch corruption
    local bound = state.modifier_ == "compression" and 70 or 0
    if state.glitchActive_ and state.modifier_ == "compression" then
        bound = bound + math.random(-18, 18)  -- R-03: Corrupt Compression bounds
    end
    bound = math.max(0, bound)  -- never negative

    -- Calculate overclock multiplier with Glitch corruption
    local overclockMult = 1
    if state.modifier_ == "overclock" then
        overclockMult = 1.25
        if state.glitchActive_ then
            overclockMult = overclockMult * (1 + (math.random() - 0.5) * 0.30)  -- ±15% fluctuation
        end
    end
```

**Then in the enemy movement loop (around line 218), change the multiplier line from:**
```lua
if distance > 0 and (enemy.kind ~= "charger" or enemy.telegraph <= 0) then local mult = state.modifier_ == "overclock" and 1.25 or 1; enemy.x = enemy.x + dx / math.max(distance, 1) * enemy.speed * mult * timeStep; enemy.y = enemy.y + dy / math.max(distance, 1) * enemy.speed * mult * timeStep end
```
**to:**
```lua
if distance > 0 and (enemy.kind ~= "charger" or enemy.telegraph <= 0) then enemy.x = enemy.x + dx / math.max(distance, 1) * enemy.speed * overclockMult * timeStep; enemy.y = enemy.y + dy / math.max(distance, 1) * enemy.speed * overclockMult * timeStep end
```

**Acceptance criteria:**
- [ ] Glitch triggers randomly (Poisson λ≈0.18/s), not on a fixed 1.5s timer
- [ ] Active phase lasts 1.5s, clear phase 1.5-2s
- [ ] During Glitch + Compression: arena bounds jitter ±18px (enemies bounce in/out)
- [ ] During Glitch + Overclock: enemy speed fluctuates ±15%
- [ ] During active phase: up to 3 enemies flicker with 60-100% alpha, 50ms duration
- [ ] Enemies smooth-drift ±18px during active phase
- [ ] No flicker during clear phase
- [ ] Frame-rate independent (uses delta-time Poisson, not per-frame random)

---

### WEEK 2: Mid-Boss Encounter (R-01)

---

#### Task 2.1: Add `is_midboss_wave()` to waves.lua

**File**: `scripts/waves.lua`

**After `is_boss_wave()` (line 15), add:**

```lua
function M.is_midboss_wave(wave)
    return wave == 4
end
```

**In `begin_wave()`, add mid-boss wave handling. After the boss wave check (line 36-37), add:**

```lua
    if M.is_boss_wave(state.wave_) then
        state.waveSpawnTarget_ = 4
    elseif M.is_midboss_wave(state.wave_) then
        state.waveSpawnTarget_ = 6  -- fewer trash enemies during mid-boss
        state.maxEnemies_ = 20      -- tighter cap for mid-boss wave
    else
        state.waveSpawnTarget_ = 8 + state.wave_ * 3
    end
```

**Also: Wave 4 should have NO modifier (mid-boss IS the content). In `modifier_for_wave()`, add early return:**

```lua
function M.modifier_for_wave(wave)
    if wave == 4 then return nil end  -- R-01: No modifier during mid-boss wave
    local cycle = (wave - 1) % 3
    if cycle == 0 then return "compression" end
    if cycle == 1 then return "surge" end
    return "overclock"
end
```

**In `begin_wave()`, guard against nil modifier:**
```lua
    state.modifier_ = M.modifier_for_wave(state.wave_) or "none"
```

**Acceptance criteria:**
- [ ] `is_midboss_wave(4)` returns true, all other waves return false
- [ ] Wave 4 has no modifier (compression/surge/overclock all inactive)
- [ ] Wave 4 spawn target is 6 (reduced trash)
- [ ] Wave 4 enemy cap is 20

---

#### Task 2.2: Add mid-boss state fields

**File**: `scripts/state.lua`

**After the Boss state section (around line 194), add:**

```lua
-- ─── Mid-boss state (R-01) ───────────────────────────────────────────────
---@type table|nil
M.midBoss_ = nil
---@type number
M.midBossFlash_ = 0
---@type Widget|nil
M.midBossBarFill_ = nil
---@type Label|nil
M.midBossLabel_ = nil
---@type Widget|nil
M.midBossCard_ = nil
```

**In `scripts/main.lua` `ResetRunState()`, add:**
```lua
state.midBoss_ = nil; state.midBossFlash_ = 0
```

---

#### Task 2.3: Add `spawn_midboss()` to enemies.lua

**File**: `scripts/enemies.lua`

**After `spawn_boss()` (line 88), add a new function:**

```lua
function M.spawn_midboss()
    if not state.gameWorld_ then return end
    local bx, by = state.worldWidth_ * 0.5, -50
    local size = 48
    -- Distinct visual: teal/cyan hexagon (different from final boss's orange/red)
    local widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "radial", from = { 80, 220, 200, 255 }, to = { 30, 120, 110, 255 } }, borderColor = { 120, 255, 230, 255 }, borderWidth = 3, borderRadius = 8, rotate = 30, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    local coreWidget = UI.Panel { position = "absolute", width = 20, height = 20, backgroundColor = { 100, 255, 220, 255 }, borderColor = { 200, 255, 240, 255 }, borderWidth = 2, borderRadius = 10, pointerEvents = "none" }
    state.gameWorld_:AddChild(coreWidget)
    local maxIntegrity = 20 + state.wave_ * 10  -- Wave 4 → HP 60
    state.midBoss_ = { x = bx, y = by, radius = 24, speed = 34, integrity = maxIntegrity, maxIntegrity = maxIntegrity, widget = widget, coreWidget = coreWidget, phase = 0, pulseTimer = 4.0, telegraph = 0, dead = false, entering = true, targetX = state.worldWidth_ * 0.5, targetY = state.worldHeight_ * 0.3 }
    state.midBossFlash_ = 0.5
    if state.feedbackLabel_ then
        state.feedbackLabel_:SetText("◆  " .. state.T("midboss.spawn") .. "  ◆")
        state.feedbackLabel_:SetStyle({ fontColor = { 120, 255, 230, 255 }, opacity = 1 })
    end
end
```

**Also add damage, update, and cleanup functions after the existing boss functions:**

```lua
function M.damage_midboss(amount)
    if not state.midBoss_ or state.midBoss_.dead then return end
    state.midBoss_.integrity = state.midBoss_.integrity - amount
    state.midBossFlash_ = 0.12
    if callbacks.onDamage then callbacks.onDamage(state.midBoss_.x, state.midBoss_.y, amount, true) end
    if state.midBoss_.integrity > 0 then return end
    state.midBoss_.dead = true
    state.score_ = state.score_ + 25
    state.midBossFlash_ = 0.6
    if callbacks.spawnPickup then
        for _ = 1, 4 do callbacks.spawnPickup(state.midBoss_.x + math.random(-25, 25), state.midBoss_.y + math.random(-25, 25), "data", 3) end
        for _ = 1, 3 do callbacks.spawnPickup(state.midBoss_.x + math.random(-15, 15), state.midBoss_.y + math.random(-15, 15), "shard", 2) end
    end
    destroy(state.midBoss_.widget)
    destroy(state.midBoss_.coreWidget)
    state.midBoss_ = nil
    if state.feedbackLabel_ then
        state.feedbackLabel_:SetText("◆  " .. state.T("midboss.defeated") .. "  ◆")
        state.feedbackLabel_:SetStyle({ fontColor = { 146, 225, 191, 255 }, opacity = 1 })
    end
end

function M.update_midboss(timeStep)
    local boss = state.midBoss_
    if not boss or boss.dead then return end
    local player = p()
    boss.phase = boss.phase + timeStep
    state.midBossFlash_ = math.max(0, state.midBossFlash_ - timeStep)
    if boss.entering then
        boss.y = boss.y + 70 * timeStep
        if boss.y >= boss.targetY then boss.y = boss.targetY; boss.entering = false end
    else
        local dx, dy = player.x - boss.x, player.y - boss.y
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 150 then boss.x = boss.x + dx / math.max(distance, 1) * boss.speed * timeStep; boss.y = boss.y + dy / math.max(distance, 1) * boss.speed * timeStep end
        boss.x = boss.x + math.cos(boss.phase * 1.0) * 30 * timeStep
        boss.y = boss.y + math.sin(boss.phase * 0.8) * 20 * timeStep
        boss.x = math.max(50, math.min(state.worldWidth_ - 50, boss.x))
        boss.y = math.max(50, math.min(state.worldHeight_ - 50, boss.y))
        -- Pulse attack (simpler than final boss)
        boss.pulseTimer = boss.pulseTimer - timeStep
        if boss.pulseTimer <= 0 then
            boss.pulseTimer = 4.0
            boss.telegraph = 0.8
        end
        if boss.telegraph > 0 then
            boss.telegraph = boss.telegraph - timeStep
            boss.widget:SetStyle({ borderColor = { 255, 80, 80, 255 }, borderWidth = 4, scale = 1.1 + 0.03 * math.sin(boss.phase * 18) })
            if boss.telegraph <= 0 then
                boss.widget:SetStyle({ borderColor = { 120, 255, 230, 255 }, borderWidth = 3, scale = 1.0 })
                local pulseRadius = 110
                local pdx, pdy = player.x - boss.x, player.y - boss.y
                local pd = math.sqrt(pdx * pdx + pdy * pdy)
                if pd < pulseRadius and pd > 0 and callbacks.damagePlayer then callbacks.damagePlayer() end
                state.surgeFlash_ = 0.3
            end
        end
    end
    pos(boss.widget, boss.x, boss.y, 48)
    pos(boss.coreWidget, boss.x, boss.y, 20)
    local corePulse = 0.7 + 0.3 * math.sin(boss.phase * 3.5)
    local flashBoost = state.midBossFlash_ > 0 and math.min(60, math.floor(state.midBossFlash_ * 200)) or 0
    boss.coreWidget:SetStyle({ backgroundColor = { 100, math.floor(255 - flashBoost * 0.3), math.floor(220 - flashBoost * 0.2), 255 }, scale = corePulse })
end

function M.midboss_exists()
    return state.midBoss_ ~= nil and not state.midBoss_.dead
end

function M.clear_midboss()
    if state.midBoss_ then
        destroy(state.midBoss_.widget)
        destroy(state.midBoss_.coreWidget)
        state.midBoss_ = nil
    end
end
```

**Also update `damage_area()` (around line 354) to also damage mid-boss. Add before the final boss check:**

```lua
    if state.midBoss_ and not state.midBoss_.dead then
        local dx, dy = state.midBoss_.x - x, state.midBoss_.y - y
        if dx * dx + dy * dy < (state.midBoss_.radius + radius) ^ 2 then M.damage_midboss(amount) end
    end
```

**And update `update_projectiles()` (around line 309) to also check mid-boss collision. After the boss collision check, add:**

```lua
        if not remove and state.midBoss_ and not state.midBoss_.dead then
            local dx, dy = state.midBoss_.x - projectile.x, state.midBoss_.y - projectile.y
            if dx * dx + dy * dy < (state.midBoss_.radius + projectile.radius) ^ 2 then M.damage_midboss(projectile.damage); projectile.pierce = projectile.pierce - 1; remove = projectile.pierce <= 0 end
        end
```

---

#### Task 2.4: Wire mid-boss into main.lua game loop

**File**: `scripts/main.lua`

**1. In `ClearEntities()` (around line 124), add mid-boss cleanup:**
```lua
    enemies.clear_midboss()
```
(after `enemies.clear_boss()`)

**2. In `HandleUpdate()` (around line 281), add mid-boss spawn logic. After the boss wave block, add:**

```lua
    if waves.is_boss_wave(state.wave_) then
        if not enemies.boss_exists() and state.waveTime_ > 1.0 and state.waveSpawned_ == 0 then
            enemies.spawn_boss()
            state.waveSpawned_ = 1
        end
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then
            enemies.spawn(false); state.spawnTimer_ = math.max(0.5, 1.2 - state.wave_ * 0.05)
        end
    elseif waves.is_midboss_wave(state.wave_) then
        -- R-01: Mid-boss wave logic
        if not enemies.midboss_exists() and state.waveTime_ > 1.0 and state.waveSpawned_ == 0 then
            enemies.spawn_midboss()
            state.waveSpawned_ = 1
        end
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then
            enemies.spawn(false); state.spawnTimer_ = math.max(0.5, 1.0 - state.wave_ * 0.05)
        end
    else
        ...
    end
```

**3. Add mid-boss update call. After `enemies.update_boss(timeStep)` (line 299), add:**
```lua
    enemies.update_midboss(timeStep)
```

**4. Update wave completion logic (line 308-311). Change to:**

```lua
    local waveDone = state.waveTime_ >= state.waveDuration_ and state.waveSpawned_ >= state.waveSpawnTarget_ and #state.enemies_ == 0
    if waves.is_boss_wave(state.wave_) then
        waveDone = state.waveTime_ >= state.waveDuration_ and not enemies.boss_exists() and #state.enemies_ == 0
    elseif waves.is_midboss_wave(state.wave_) then
        waveDone = not enemies.midboss_exists() and #state.enemies_ == 0
    end
```

Note: Mid-boss wave has NO timer requirement — it ends when mid-boss is dead and enemies are cleared.

**5. Guaranteed module drop on mid-boss defeat. In `damage_midboss()` in enemies.lua, when `state.midBoss_.dead = true` is set, add a flag:**
```lua
    state.midBossDefeated_ = true
```
Add `state.midBossDefeated_ = false` to `ResetRunState()` in main.lua.

**Then in `HandleUpdate()`, after the wave completion check, add:**
```lua
    -- R-01: Guaranteed module drop after mid-boss
    if state.midBossDefeated_ and state.screen_ == "game" then
        state.midBossDefeated_ = false
        PrepareUpgradeChoices()
        ClearEntities()
        state.screen_ = "upgrade"
        BuildUI()
        return
    end
```

---

#### Task 2.5: Add mid-boss HUD (health bar)

**File**: `scripts/ui.lua`

**In `game_screen()`, after the boss card creation (line 103), add mid-boss card:**

```lua
    state.midBossLabel_ = label("", { fontSize = 12, fontWeight = "bold", fontColor = { 120, 255, 230, 255 }, textAlign = "center", opacity = 0 })
    state.midBossBarFill_ = UI.Panel { width = "100%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 80, 220, 200, 255 }, to = { 120, 255, 230, 255 } }, borderRadius = 4, pointerEvents = "none" }
    local midBossBar = UI.Panel { width = "100%", height = 8, marginTop = 4, backgroundColor = { 15, 30, 30, 220 }, borderRadius = 5, overflow = "hidden", children = { state.midBossBarFill_ } }
    local midBossCard = UI.Panel { position = "absolute", top = 120, left = "20%", right = "20%", padding = 6, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 12, 30, 28, 220 }, to = { 8, 22, 20, 220 } }, borderColor = { 80, 200, 180, 180 }, borderWidth = 1, borderRadius = 10, opacity = 0, children = { state.midBossLabel_, midBossBar } }
    state.midBossCard_ = midBossCard
```

**Add `midBossCard` to the return panel's children list** (add it alongside `bossCard`).

**In `update_hud()`, after the boss bar update block (line 216), add:**

```lua
    if state.midBossLabel_ and state.midBossBarFill_ then
        if state.midBoss_ and not state.midBoss_.dead then
            state.midBossLabel_:SetText(state.T("midboss.bar", math.ceil(state.midBoss_.integrity), state.midBoss_.maxIntegrity))
            state.midBossLabel_:SetStyle({ opacity = 1 })
            local ratio = math.max(0, state.midBoss_.integrity / state.midBoss_.maxIntegrity)
            state.midBossBarFill_:SetStyle({ width = tostring(math.floor(ratio * 100)) .. "%" })
            if state.midBossCard_ then safe_style(state.midBossCard_, { opacity = 1 }) end
        else
            state.midBossLabel_:SetStyle({ opacity = 0 })
            if state.midBossCard_ then safe_style(state.midBossCard_, { opacity = 0 }) end
        end
    end
```

---

#### Task 2.6: Add i18n strings for mid-boss

**File**: `scripts/i18n.lua`

**In the `zh_CN` table, after the boss strings (line 44), add:**

```lua
        ["midboss.name"] = "守门者", ["midboss.bar"] = "守门者：%d / %d", ["midboss.spawn"] = "守门者出现", ["midboss.defeated"] = "守门者已被击破",
```

**In the `en` table, after the boss strings (line 81), add:**

```lua
        ["midboss.name"] = "Gatekeeper", ["midboss.bar"] = "Gatekeeper: %d / %d", ["midboss.spawn"] = "Gatekeeper has appeared", ["midboss.defeated"] = "Gatekeeper destroyed",
```

---

### WEEK 3: Final Boss HP Escalation + Wave Tuning (R-04, R-07, R-08)

---

#### Task 3.1: R-04 — Final Boss HP Escalation

**File**: `scripts/enemies.lua`

**1. In `spawn_boss()` (line 81), change HP formula:**
```lua
    local maxIntegrity = 100 + state.wave_ * 25  -- Wave 8 → HP 300
```

**2. Add escalation stage tracking to boss state. In `spawn_boss()` (line 82), add fields:**
```lua
    state.boss_ = { x = bx, y = by, radius = 36, speed = 30, integrity = maxIntegrity, maxIntegrity = maxIntegrity, widget = widget, coreWidget = coreWidget, phase = 0, pulseTimer = 3.5, spawnTimer = 6.0, telegraph = 0, dead = false, entering = true, targetX = state.worldWidth_ * 0.5, targetY = state.worldHeight_ * 0.3, escalationStage = 1, minionTimer = 0, arenaCompression = 0 }
```

**3. In `update_boss()`, replace the combat logic block with 4-stage escalation:**

After `boss.entering = false` (when boss has finished entering), add escalation logic:

```lua
        -- R-04: Escalating DPS check — 4 stages based on elapsed combat time
        local combatTime = boss.phase  -- time since boss spawned
        local newStage = 1
        if combatTime >= 35 then newStage = 4
        elseif combatTime >= 25 then newStage = 3
        elseif combatTime >= 15 then newStage = 2
        end
        if newStage ~= boss.escalationStage then
            boss.escalationStage = newStage
            -- Brief flash on stage transition
            state.bossFlash_ = 0.3
            if state.feedbackLabel_ then
                state.feedbackLabel_:SetText("◆  Phase " .. tostring(newStage) .. "  ◆")
                state.feedbackLabel_:SetStyle({ fontColor = { 255, 80, 80, 255 }, opacity = 1 })
            end
        end

        -- Stage-specific behavior
        local pulseInterval = 3.5
        local spawnInterval = 5.0
        if boss.escalationStage >= 2 then
            pulseInterval = 2.7  -- Stage 2: faster pulses (+30%)
        end
        if boss.escalationStage >= 3 then
            -- Stage 3: minion spawns every 3s
            boss.minionTimer = boss.minionTimer - timeStep
            if boss.minionTimer <= 0 and #state.enemies_ < state.maxEnemies_ then
                boss.minionTimer = 3.0
                for _ = 1, math.random(2, 3) do
                    state.enemyId_ = state.enemyId_ + 1
                    local sx, sy = boss.x + math.random(-40, 40), boss.y + math.random(-40, 40)
                    local mw = UI.Panel { position = "absolute", width = 24, height = 24, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 244, 93, 133, 255 }, to = { 180, 50, 90, 255 } }, borderColor = { 255, 180, 200, 255 }, borderWidth = 2, borderRadius = 2, pointerEvents = "none" }
                    state.gameWorld_:AddChild(mw)
                    table.insert(state.enemies_, { x = sx, y = sy, radius = 12, speed = 52 + state.wave_ * 3, integrity = 2 + state.wave_, widget = mw, elite = false, kind = "chaser", phase = 0, charge = 0, telegraph = 0, fireTimer = 2.0, dead = false, isFragment = false })
                end
            end
        end
        if boss.escalationStage >= 4 then
            -- Stage 4: arena compression (10% shrink) + visual glitch cracking
            boss.arenaCompression = math.min(1, (boss.arenaCompression or 0) + timeStep * 0.5)
            -- Apply screen edge flicker effect
            if math.random() < 0.1 then
                state.surgeFlash_ = math.max(state.surgeFlash_, 0.15)
            end
        end
```

**4. Update pulse timer to use stage-based interval:**
Change `boss.pulseTimer = 3.5` (line 247) to use the variable:
```lua
            boss.pulseTimer = pulseInterval
```

**5. Update spawn timer to use stage-based interval:**
Change `boss.spawnTimer = 5.0` (line 273) to:
```lua
            boss.spawnTimer = spawnInterval
```

**File**: `scripts/main.lua`

**6. Remove timer requirement for boss wave completion (line 310):**
Change:
```lua
        waveDone = state.waveTime_ >= state.waveDuration_ and not enemies.boss_exists() and #state.enemies_ == 0
```
To:
```lua
        waveDone = not enemies.boss_exists() and #state.enemies_ == 0
```

**Acceptance criteria:**
- [ ] Final boss HP at Wave 8 = 300 (100 + 8 × 25)
- [ ] Stage 1 (0-15s): normal pulse speed (3.5s interval)
- [ ] Stage 2 (15-25s): faster pulses (2.7s interval)
- [ ] Stage 3 (25-35s): spawns 2-3 chaser minions every 3s
- [ ] Stage 4 (35s+): arena compression + screen flicker
- [ ] Boss wave ends when boss is dead AND all enemies cleared (no timer)
- [ ] Stage transitions show brief "Phase X" text

---

#### Task 3.2: R-07 — Wave 6 Overclock Tuning

**File**: `scripts/enemies.lua`

**In the enemy movement line (around line 218), change overclock multiplier from 1.25 to 1.15:**

Find:
```lua
local overclockMult = 1
if state.modifier_ == "overclock" then
    overclockMult = 1.25
```

Change to:
```lua
local overclockMult = 1
if state.modifier_ == "overclock" then
    overclockMult = 1.15
```

**Note**: If you already implemented the R-03 corruption version with `overclockMult`, just change the base from 1.25 to 1.15. The Glitch corruption fluctuation (±15%) stays on top of this new base.

**Acceptance criteria:**
- [ ] Wave 6 (Overclock wave): enemies move at 1.15× speed (not 1.25×)
- [ ] Glitch + Overclock on Wave 7: speed fluctuates ±15% around 1.15×

---

#### Task 3.3: R-08 — Wave 7 Glitch Spawn Reduction

**File**: `scripts/waves.lua`

**In `begin_wave()`, add glitch wave spawn reduction. After the `maxEnemies_` line, add:**

```lua
    -- R-08: Reduce spawn density on glitch waves
    if state.glitchWave_ and not M.is_boss_wave(state.wave_) then
        state.waveSpawnTarget_ = math.floor(state.waveSpawnTarget_ * 0.80)  -- 20% reduction
    end
```

**File**: `scripts/main.lua`

**In `HandleUpdate()`, for glitch waves, reduce spawn uptime. Find the non-boss spawn line:**
```lua
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then enemies.spawn(false); state.spawnTimer_ = math.max(0.2, 0.7 - state.wave_ * 0.04) end
```

**Change to add glitch wave slower spawn:**
```lua
        if state.waveSpawned_ == 0 and state.wave_ % 3 == 0 then enemies.spawn(true) end
        local spawnDelay = state.glitchWave_ and math.max(0.3, 0.9 - state.wave_ * 0.04) or math.max(0.2, 0.7 - state.wave_ * 0.04)
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then enemies.spawn(false); state.spawnTimer_ = spawnDelay end
```

**Acceptance criteria:**
- [ ] Wave 7 spawn target reduced by ~20% (from 29 to ~23)
- [ ] Wave 7 spawn interval increased (slower spawns)
- [ ] Combined with R-06: maxEnemies_ = 25 on Wave 7

---

### WEEK 4: UI Feedback Layer (R-09, R-10, R-11)

---

#### Task 4.1: R-09 — Modifier Dock UI

**File**: `scripts/ui.lua`

**In `game_screen()`, after the waveCard creation (line 107), add a modifier dock:**

```lua
    -- R-09: Modifier dock — shows active modifier + glitch badge
    state.modifierDockLabel_ = label("", { fontSize = 11, fontWeight = "bold", fontColor = { 255, 182, 105, 255 }, textAlign = "center" })
    state.glitchBadge_ = label("", { fontSize = 10, fontWeight = "bold", fontColor = { 255, 80, 80, 255 }, textAlign = "center", opacity = 0 })
    local modifierDock = UI.Panel { position = "absolute", top = 14, left = "50%", transform = "translateX(-50%)", padding = 6, flexDirection = "row", gap = 6, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 12, 22, 45, 200 }, to = { 8, 16, 38, 200 } }, borderColor = { 91, 124, 190, 120 }, borderWidth = 1, borderRadius = 8, pointerEvents = "none", children = { state.modifierDockLabel_, state.glitchBadge_ } }
```

**Add `modifierDock` to the game_screen return panel children list.**

**In `update_hud()`, add modifier dock update:**

```lua
    -- R-09/R-10: Modifier dock + glitch badge
    if state.modifierDockLabel_ then
        local modText = state.modifier_ == "none" and state.T("game.none") or state.T("modifier." .. state.modifier_)
        state.modifierDockLabel_:SetText("◆ " .. modText)
    end
    if state.glitchBadge_ then
        if state.glitchActive_ then
            state.glitchBadge_:SetText("⚠ GLITCH")
            -- R-10: Badge pulses with glitch active state
            local pulseAlpha = 0.6 + 0.4 * math.sin(state.runTime_ * 15)
            state.glitchBadge_:SetStyle({ opacity = pulseAlpha })
        else
            state.glitchBadge_:SetStyle({ opacity = 0 })
        end
    end
```

---

#### Task 4.2: R-11 — Mid-Boss Intro Flash

**File**: `scripts/ui.lua`

**In `game_screen()`, add a flash overlay widget (can reuse hitFlashWidget_ or add a new one):**

```lua
    state.introFlashWidget_ = UI.Panel { position = "absolute", top = 0, left = 0, width = "100%", height = "100%", backgroundColor = { 120, 255, 230, 255 }, opacity = 0, pointerEvents = "none" }
```

**Add `state.introFlashWidget_` to the return panel children.**

**In `update_feedback()`, add intro flash decay:**
```lua
    -- R-11: Mid-boss intro flash decay
    if state.midBossFlash_ > 0.3 then
        -- During the initial 0.5s flash, show the intro overlay
        if state.introFlashWidget_ then
            local flashAlpha = math.min(0.4, (state.midBossFlash_ - 0.3) * 2)
            safe_style(state.introFlashWidget_, { opacity = flashAlpha })
        end
    else
        if state.introFlashWidget_ then
            safe_style(state.introFlashWidget_, { opacity = 0 })
        end
    end
```

**Note**: The `midBossFlash_` is set to 0.5 in `spawn_midboss()`. The flash shows when `midBossFlash_ > 0.3` (first 0.2s of the 0.5s flash duration), then fades.

---

## Quick Reference: File Change Map

| File | Week 1 | Week 2 | Week 3 | Week 4 |
|------|--------|--------|--------|--------|
| `scripts/enemies.lua` | R-02 fix, R-03 complete | R-01 spawn/damage/update midboss | R-04 boss HP + escalation, R-07 overclock | — |
| `scripts/waves.lua` | R-06 dynamic cap | R-01 midboss wave, no modifier W4 | R-08 glitch spawn reduction | — |
| `scripts/state.lua` | R-03 new fields | R-01 midboss fields | R-04 escalation fields | — |
| `scripts/main.lua` | R-06 reset fix | R-01 wire midboss into loop, guaranteed drop | R-04 remove boss timer, R-08 spawn delay | — |
| `scripts/ui.lua` | — | R-01 midboss health bar | — | R-09 dock, R-10 badge, R-11 flash |
| `scripts/i18n.lua` | — | R-01 midboss strings | — | — |

---

## How to Use This with VS Code Copilot

1. **Open the target file** in VS Code (e.g., `scripts/enemies.lua`)
2. **Open Copilot Chat** (Ctrl+Shift+I or Cmd+Shift+I)
3. **Paste the task instruction** (one task at a time, e.g., "Task 1.1")
4. **Review the suggested code** — Copilot will generate the edit
5. **Apply and test** — run the game after each task to verify
6. **Move to next task** only after the current one passes acceptance criteria

**Tips for Copilot:**
- Include the file path and function name in your prompt
- Paste the "current code" and "replace with" blocks directly
- After each task, run the game and verify the acceptance criteria checklist
- If Copilot struggles with a large task, break it into smaller pieces

---

## Testing Checklist (After All 4 Weeks)

- [ ] Wave 1-2: Only Chaser + Skimmer spawn
- [ ] Wave 3: Splitter appears for the first time
- [ ] Wave 4: Mid-boss "Gatekeeper" spawns with health bar, no modifier active
- [ ] Wave 4: Mid-boss defeat triggers guaranteed module upgrade
- [ ] Wave 5: Shooter appears for the first time
- [ ] Wave 6: Overclock at 1.15× (not 1.25×)
- [ ] Wave 7: Glitch overlay active — enemies flicker and displace, modifier dock shows "⚠ GLITCH" badge
- [ ] Wave 7: Compression bounds jitter during Glitch active phase
- [ ] Wave 7: Enemy cap is 25 (not 30)
- [ ] Wave 8: Final boss has 300 HP, 4 escalation stages
- [ ] Wave 8: Boss wave ends on boss death + enemies cleared (no timer)
- [ ] Fragment cap: never more than 10 fragments on screen
- [ ] All waves: no single enemy type dominates spawns
