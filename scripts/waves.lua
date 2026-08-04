-- waves.lua
-- Stage -> Level -> Wave hierarchy
-- Manages wave lifecycle, spawn scheduling, and level/stage advancement.

local state  = require("state")
local stages = require("stages")
local shop   = require("shop")   -- P6: shop generation on wave advance
local vfx    = require("vfx")    -- P8: wave banners

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
---Now also handles stage-completion metadata (P6: called from shop.skip after final wave).
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
        -- Stage fully cleared — P6: summary metadata set here (was in EndWave)
        state.defeatReason_ = state.T("game.reason_complete")
        state.isVictory_ = true
        if not state.summaryAwarded_ then
            state.profile_.calibration = state.profile_.calibration + math.max(1, math.floor(state.dataFragments_ / 8))
            state.summaryAwarded_ = true
        end
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

    -- P8: Wave banner
    local bannerText = state.T("game.wave", state.wave_, state.maxWaves_)
    local bannerColor = { 255, 239, 164, 255 }  -- default gold
    if M.is_boss_wave(state.wave_) then
        bannerText = "BOSS  ·  " .. bannerText
        bannerColor = { 255, 120, 60, 255 }
    elseif M.is_midboss_wave(state.wave_) then
        bannerText = "ELITE  ·  " .. bannerText
        bannerColor = { 100, 200, 255, 255 }
    end
    vfx.show_wave_banner(bannerText, bannerColor)

    if M.is_boss_wave(state.wave_) then
        state.waveSpawnTarget_ = 4
    elseif M.is_midboss_wave(state.wave_) then
        state.waveSpawnTarget_ = 6
        state.maxEnemies_ = 20
    else
        -- P9: Increased density — 12 + wave*4 (was 8 + wave*3)
        -- Wave 1: 16 enemies, Wave 6: 36 enemies
        -- More enemies = more gold, balanced by improved weapon DPS
        state.waveSpawnTarget_ = 12 + state.wave_ * 4
    end
end

---Advance to the next wave. Opens the inter-wave shop.
---Caller is responsible for checking level completion and setting
---state.shop_._advanceAfter before calling.
function M.advance()
    local lvl = stages.level(state.stage_, state.stageLevel_)
    local maxW = lvl and lvl.totalWaves or state.maxWaves_

    -- Increment wave (if not the final wave — caller may override)
    if state.wave_ < maxW then
        state.wave_ = state.wave_ + 1
    end

    -- P6: Route to shop instead of wave_pause
    shop.generate_items()
    state.screen_ = state.SCREEN_SHOP
    state.wavePauseTimer_ = 0
    return true
end

return M
