local state = require("state")

local M = {}

local function SetWidgetPosition(widget, x, y, size)
    if widget then widget:SetStyle({ left = x - size * 0.5, top = y - size * 0.5 }) end
end

function M.reset(worldWidth, worldHeight)
    local player = state.player_
    player.x, player.y = worldWidth * 0.5, worldHeight * 0.5
    player.integrity, player.maxIntegrity = 5 + state.profile_.startingIntegrity, 5 + state.profile_.startingIntegrity
    player.invulnerable, player.fireTimer, player.pulseTimer = 0, 0, 0
    player.orbitAngle, player.magnetRadius, player.damage = 0, 110 + state.profile_.magnet * 35, 1
    player.shell, player.maxShell, player.shellRechargeTimer, player.shellFlash = 0, 0, 0, 0
    player.mineCooldown, player.trailTimer = 0, 0
end

function M.update_movement(timeStep)
    local player = state.player_
    local dx, dy = 0, 0
    if state.touchActive_ then
        dx, dy = state.touchX_ - state.touchStartX_, state.touchY_ - state.touchStartY_
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then dx, dy = dx / math.max(distance, state.touchRadius_), dy / math.max(distance, state.touchRadius_) end
    else
        if state.keys_[KEY_A] or state.keys_[KEY_LEFT] then dx = dx - 1 end
        if state.keys_[KEY_D] or state.keys_[KEY_RIGHT] then dx = dx + 1 end
        if state.keys_[KEY_W] or state.keys_[KEY_UP] then dy = dy - 1 end
        if state.keys_[KEY_S] or state.keys_[KEY_DOWN] then dy = dy + 1 end
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then dx, dy = dx / length, dy / length end
    end
    if dx ~= 0 or dy ~= 0 then
        player.x = player.x + dx * player.speed * timeStep
        player.y = player.y + dy * player.speed * timeStep
    end
    local bound = state.modifier_ == "compression" and 70 or player.radius
    player.x = math.max(bound, math.min(state.worldWidth_ - bound, player.x))
    player.y = math.max(bound, math.min(state.worldHeight_ - bound, player.y))
    SetWidgetPosition(state.playerWidget_, player.x, player.y, 32)
end

function M.update_timers(timeStep)
    local player = state.player_
    player.invulnerable = math.max(0, player.invulnerable - timeStep)
    player.fireTimer = player.fireTimer - timeStep
    player.pulseTimer = player.pulseTimer - timeStep
end

return M
