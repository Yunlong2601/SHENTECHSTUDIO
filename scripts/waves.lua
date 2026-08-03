-- waves.lua
-- Stage -> Level -> Wave hierarchy
-- Manages wave lifecycle, spawn scheduling, and level/stage advancement.

local state  = require("state")
local stages = require("stages")

local M = {}

-- ── Wave-type helpers (check current level config from stages.lua) ────────

---Is this wave a mid-boss wave? (per-level config)
function M.is_midboss_wave(wave)
    local lvl = stages.level(state.stage_, state.stageLevel_)
    if not lvl then return false end
    return lvl.midBossWave == wave
end

---Is this wave a stage boss? (only the final level's bossWave)
function M.is_boss_wave(wave)
    local lvl = stages.level(state.stage_, state.stageLevel_)
    if not lvl then return false end
    return lvl.bossWave == wave
end

---Get modifier for a given wave index (cyclic: compression/surge/overclock).
---No modifier during mid-boss/boss waves (returns nil).
function M.modifier_for_wave(wave)
    local lvl = stages.level(state.stage_, state.stageLevel_)
    if not lvl then return "compression" end
    if lvl.midBossWave == wave then return nil end
    if lvl.bossWave == wave then return nil end
    -- Cycle through 3 modifiers, 6 waves max
    local cycle = (wave - 1) % 3
    if cycle == 0 then return "compression" end
    if cycle == 1 then return "surge" end
    return "overclock"
end

-- ── Level advancement ─────────────────────────────────────────────────────

---Advance to the next level within the current stage.
function M.advance_level()
    local total = stages.totalLevels(state.stage_)
    if state.stageLevel_ < total then
        state.stageLevel_ = state.stageLevel_ + 1
        state.wave_ = 1
        local lvl = stages.level(state.stage_, state.stageLevel_)
        state.maxWaves_ = lvl and lvl.totalWaves or stages.wavesPerLevel(state.stage_)
        state.wavePauseTimer_ = 2.5
        state.stageIntroTimer_ = 2.0  -- show level name intro
        state.screen_ = state.SCREEN_STAGE_PAUSE
        -- Reset boss/mid-boss for new level
        state.boss_ = nil; state.midBoss_ = nil
    else
        -- Stage fully cleared
        state.isVictory_ = true
        state.screen_ = state.SCREEN_STAGE_SUMMARY
        if state.stage_ < state.totalStages_ and state.stagesUnlocked_ <= state.stage_ then
            state.stagesUnlocked_ = state.stage_ + 1
        end
    end
end

-- ── Wave lifecycle ────────────────────────────────────────────────────────

function M.reset()
    state.wave_ = 1
    state.modifier_ = M.modifier_for_wave(state.wave_) or "none"
    state.waveSpawnTarget_ = 10
    state.wavePauseTimer_ = 0
    state.maxEnemies_ = 30
end

function M.begin_wave()
    -- Update maxWaves_ from current stage/level config
    local lvl = stages.level(state.stage_, state.stageLevel_)
    state.maxWaves_ = lvl and lvl.totalWaves or stages.wavesPerLevel(state.stage_)

    state.screen_ = state.SCREEN_GAME
    state.modifier_ = M.modifier_for_wave(state.wave_) or "none"
    state.maxEnemies_ = 30
    state.surgeTimer_, state.waveTime_, state.waveSpawned_, state.spawnTimer_ = 2.5, 0, 0, 0

    if M.is_boss_wave(state.wave_) then
        state.waveSpawnTarget_ = 4
    elseif M.is_midboss_wave(state.wave_) then
        state.waveSpawnTarget_ = 6
        state.maxEnemies_ = 20
    else
        state.waveSpawnTarget_ = 8 + state.wave_ * 3
    end
end

---Advance to the next wave. Returns false if the level is done
---(caller should check and trigger advance_level).
function M.advance()
    local lvl = stages.level(state.stage_, state.stageLevel_)
    local maxW = lvl and lvl.totalWaves or state.maxWaves_

    if state.wave_ >= maxW then
        return false  -- level complete
    end

    state.wave_ = state.wave_ + 1
    state.screen_ = state.SCREEN_WAVE_PAUSE
    state.wavePauseTimer_ = 0
    return true
end

return M
