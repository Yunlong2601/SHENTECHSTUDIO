local state = require("state")

local M = {}

function M.modifier_for_wave(wave)
    local cycle = (wave - 1) % 3
    if cycle == 0 then return "compression" end
    if cycle == 1 then return "surge" end
    return "overclock"
end

function M.is_boss_wave(wave)
    return wave >= state.maxWaves_
end

function M.reset()
    state.modifier_ = M.modifier_for_wave(state.wave_)
    state.waveSpawnTarget_ = 10
    state.wavePauseTimer_ = 0
end

function M.begin_wave()
    state.screen_ = state.SCREEN_GAME
    state.modifier_ = M.modifier_for_wave(state.wave_)
    state.surgeTimer_, state.waveTime_, state.waveSpawned_, state.spawnTimer_ = 2.5, 0, 0, 0
    if M.is_boss_wave(state.wave_) then
        state.waveSpawnTarget_ = 4
    else
        state.waveSpawnTarget_ = 8 + state.wave_ * 3
    end
end

function M.advance()
    if state.wave_ >= state.maxWaves_ then return false end
    state.wave_ = state.wave_ + 1
    state.screen_ = state.SCREEN_WAVE_PAUSE
    state.wavePauseTimer_ = 0
    return true
end

return M
