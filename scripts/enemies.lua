local UI = require("urhox-libs/UI")
local state = require("state")

local M = {}
local callbacks = {}

function M.configure(nextCallbacks) callbacks = nextCallbacks or {} end
local function p() return state.player_ end
local function pos(widget, x, y, size) if callbacks.setWidgetPosition then callbacks.setWidgetPosition(widget, x, y, size) end end
local function destroy(widget) if callbacks.destroyWidget then callbacks.destroyWidget(widget) end end

function M.kind_for_id(enemyId, wave)
    local cycle = (enemyId + wave) % 3
    if cycle == 0 then return "chaser" end
    if cycle == 1 then return "skimmer" end
    return "charger"
end

function M.spawn(elite)
    if not state.gameWorld_ or #state.enemies_ >= 24 or state.waveSpawned_ >= state.waveSpawnTarget_ then return end
    state.enemyId_, state.waveSpawned_ = state.enemyId_ + 1, state.waveSpawned_ + 1
    local side = (state.enemyId_ - 1) % 4; local x, y = 0, 0
    if side == 0 then x, y = -30, math.random(30, math.max(31, math.floor(state.worldHeight_ - 30)))
    elseif side == 1 then x, y = state.worldWidth_ + 30, math.random(30, math.max(31, math.floor(state.worldHeight_ - 30)))
    elseif side == 2 then x, y = math.random(30, math.max(31, math.floor(state.worldWidth_ - 30))), -30
    else x, y = math.random(30, math.max(31, math.floor(state.worldWidth_ - 30))), state.worldHeight_ + 30 end
    local kind = elite and "elite" or M.kind_for_id(state.enemyId_, state.wave_)
    local size = elite and 38 or (kind == "charger" and 28 or 24)
    local color = elite and { 255, 126, 63, 255 } or (kind == "skimmer" and { 84, 216, 194, 255 } or kind == "charger" and { 255, 168, 76, 255 } or { 244, 93, 133, 255 })
    local widget = UI.Panel { position = "absolute", width = size, height = size, backgroundColor = color, borderColor = elite and { 255, 239, 164, 255 } or { 255, 220, 150, 255 }, borderWidth = elite and 3 or 2, borderRadius = kind == "skimmer" and size * 0.5 or (elite and 18 or 8), pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.enemies_, { x = x, y = y, radius = size * 0.5, speed = (elite and 38 or kind == "skimmer" and 46 or kind == "charger" and 40 or 52) + state.wave_ * 3, integrity = (elite and 12 or 2) + state.wave_, widget = widget, elite = elite, kind = kind, phase = 0, charge = 0, telegraph = 0, dead = false })
end

function M.find_nearest()
    local nearest, best = nil, math.huge; local player = p()
    for _, enemy in ipairs(state.enemies_) do
        local dx, dy = enemy.x - player.x, enemy.y - player.y; local distance = dx * dx + dy * dy
        if distance < best then nearest, best = enemy, distance end
    end
    return nearest
end

function M.damage(enemy, amount)
    if not enemy or enemy.dead then return end
    if callbacks.onDamage then callbacks.onDamage(enemy.x, enemy.y, amount, enemy.elite) end
    enemy.integrity = enemy.integrity - amount
    if enemy.integrity > 0 then return end
    enemy.dead = true
    local reward = state.modifier_ == "overclock" and 2 or 1
    state.score_ = state.score_ + (enemy.elite and 8 or 1)
    if callbacks.spawnPickup then callbacks.spawnPickup(enemy.x, enemy.y, "data", (enemy.elite and 3 or 1) * reward); callbacks.spawnPickup(enemy.x + 8, enemy.y, "shard", enemy.elite and 3 or 1) end
    destroy(enemy.widget)
end

function M.update(timeStep)
    local bound = state.modifier_ == "compression" and 70 or 0; local player = p()
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead then
            local dx, dy = player.x - enemy.x, player.y - enemy.y; local distance = math.sqrt(dx * dx + dy * dy)
            enemy.phase = enemy.phase + timeStep
            if enemy.kind == "skimmer" then local tx, ty = -dy / math.max(distance, 1), dx / math.max(distance, 1); dx, dy = dx + tx * 90, dy + ty * 90
            elseif enemy.kind == "charger" then if enemy.charge <= 0 then enemy.charge, enemy.telegraph = 2.1, 0.45 end; if enemy.telegraph > 0 then enemy.telegraph = enemy.telegraph - timeStep else enemy.charge = enemy.charge - timeStep; enemy.speed = 165 + state.wave_ * 5 end end
            if distance > 0 and (enemy.kind ~= "charger" or enemy.telegraph <= 0) then local mult = state.modifier_ == "overclock" and 1.25 or 1; enemy.x = enemy.x + dx / math.max(distance, 1) * enemy.speed * mult * timeStep; enemy.y = enemy.y + dy / math.max(distance, 1) * enemy.speed * mult * timeStep end
            if bound > 0 then enemy.x = math.max(bound, math.min(state.worldWidth_ - bound, enemy.x)); enemy.y = math.max(bound, math.min(state.worldHeight_ - bound, enemy.y)) end
            if enemy.telegraph > 0 then enemy.widget:SetStyle({ backgroundColor = { 255, 245, 110, 255 }, borderColor = { 255, 70, 80, 255 }, scale = 1.2 }) else enemy.widget:SetStyle({ scale = 1.0 }) end
            pos(enemy.widget, enemy.x, enemy.y, enemy.elite and 38 or (enemy.kind == "charger" and 28 or 24))
            if distance < player.radius + enemy.radius and callbacks.damagePlayer then callbacks.damagePlayer(); if state.screen_ ~= "game" then return end; enemy.x = enemy.x - dx / math.max(distance, 1) * 22; enemy.y = enemy.y - dy / math.max(distance, 1) * 22 end
        end
    end
    for index = #state.enemies_, 1, -1 do if state.enemies_[index].dead then table.remove(state.enemies_, index) end end
end

function M.update_projectiles(timeStep)
    for projectileIndex = #state.projectiles_, 1, -1 do
        local projectile = state.projectiles_[projectileIndex]; projectile.x = projectile.x + projectile.vx * timeStep; projectile.y = projectile.y + projectile.vy * timeStep; projectile.life = projectile.life - timeStep; local remove = projectile.life <= 0
        for enemyIndex = #state.enemies_, 1, -1 do
            local enemy = state.enemies_[enemyIndex]; if not enemy then break end
            local dx, dy = enemy.x - projectile.x, enemy.y - projectile.y
            if dx * dx + dy * dy < (enemy.radius + projectile.radius) ^ 2 then M.damage(enemy, projectile.damage); projectile.pierce = projectile.pierce - 1; remove = projectile.pierce <= 0; if remove then break end end
        end
        if remove then destroy(projectile.widget); table.remove(state.projectiles_, projectileIndex) else pos(projectile.widget, projectile.x, projectile.y, 10) end
    end
end

return M
