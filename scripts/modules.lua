local UI = require("urhox-libs/UI")
local state = require("state")

local M = {}
local callbacks = {}

function M.configure(nextCallbacks)
    callbacks = nextCallbacks or {}
end

local function player() return state.player_ end
local function active(id) return state.activeModules_[id] == true end
local function position(widget, x, y, size)
    if callbacks.setWidgetPosition then callbacks.setWidgetPosition(widget, x, y, size) end
end
local function damage(enemy, amount)
    if callbacks.damageEnemy then callbacks.damageEnemy(enemy, amount) end
end

function M.fire_trace_beam()
    local target = callbacks.findNearestEnemy and callbacks.findNearestEnemy() or nil
    if not target or not state.gameWorld_ then return end
    local p = player(); local dx, dy = target.x - p.x, target.y - p.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0 then return end
    local widget = UI.Panel { position = "absolute", width = 11, height = 11, backgroundColor = { 255, 224, 99, 255 }, borderRadius = 6, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.projectiles_, { x = p.x, y = p.y, vx = dx / length * (430 + state.moduleLevels_.trace * 35), vy = dy / length * (430 + state.moduleLevels_.trace * 35), radius = 5, damage = p.damage + state.moduleLevels_.trace, life = 1.4, pierce = state.moduleLevels_.trace >= 3 and 2 or 1, widget = widget })
end

function M.pulse_bloom()
    if not active("pulse") then return end
    local p = player(); local radius = 105 + state.moduleLevels_.pulse * 10
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead then
            local dx, dy = enemy.x - p.x, enemy.y - p.y; local distance = math.sqrt(dx * dx + dy * dy)
            if distance < radius then
                damage(enemy, 2 + state.moduleLevels_.pulse)
                if distance > 0 then enemy.x = enemy.x + dx / distance * 30; enemy.y = enemy.y + dy / distance * 30 end
            end
        end
    end
    if state.moduleLevels_.pulse >= 3 then state.surgeFlash_ = 0.25 end
end

function M.update_orbit(timeStep)
    if not active("orbit") or not state.gameWorld_ then return end
    local p = player(); p.orbitAngle = p.orbitAngle + 2.8 * timeStep
    local count = state.moduleLevels_.orbit >= 3 and 2 or 1
    for node = 1, count do
        local angle = p.orbitAngle + (node - 1) * math.pi
        local ox, oy = p.x + math.cos(angle) * 42, p.y + math.sin(angle) * 42
        local widget = node == 1 and state.orbitWidget_ or state.orbitWidget2_
        if not widget then
            widget = UI.Panel { position = "absolute", width = 16, height = 16, backgroundColor = { 190, 139, 255, 255 }, borderRadius = 8, pointerEvents = "none" }
            state.gameWorld_:AddChild(widget)
            if node == 1 then state.orbitWidget_ = widget else state.orbitWidget2_ = widget end
        end
        position(widget, ox, oy, 16)
        for _, enemy in ipairs(state.enemies_) do
            local dx, dy = enemy.x - ox, enemy.y - oy
            if dx * dx + dy * dy < (enemy.radius + 9) ^ 2 then damage(enemy, 0.04 + state.moduleLevels_.orbit * 0.02) end
        end
    end
end

function M.update_shell(timeStep)
    if not active("shell") or not state.gameWorld_ then return end
    local p = player()
    if p.maxShell <= 0 then p.maxShell = 2 + state.moduleLevels_.shell; p.shell = p.maxShell end
    p.shellRechargeTimer = p.shellRechargeTimer + timeStep
    p.shellFlash = math.max(0, p.shellFlash - timeStep * 4)
    if p.shell >= p.maxShell then return end
    local delay = math.max(0.8, 2.6 - state.moduleLevels_.shell * 0.3)
    if p.shellRechargeTimer < delay then return end
    local rate = 0.8 + state.moduleLevels_.shell * 0.2
    if state.moduleLevels_.shell >= 3 then rate = rate + 0.4 end
    p.shell = math.min(p.maxShell, p.shell + rate * timeStep)
end

function M.update_shell_visual()
    local p = player(); local ring = state.shellRing_
    if not ring then return end
    if not active("shell") or p.maxShell <= 0 or p.shell <= 0 then
        if ring:IsVisible() then ring:SetVisible(false) end
        return
    end
    if not ring:IsVisible() then ring:SetVisible(true) end
    position(ring, p.x, p.y, 44)
    local ratio, flash = p.shell / p.maxShell, p.shellFlash
    local alpha = math.floor(50 + ratio * 180); local boost = flash > 0 and math.min(42, math.floor(flash * 200)) or 0
    ring:SetStyle({ borderColor = { 255, math.min(255, 213 + boost), 83, alpha }, opacity = 0.4 + 0.5 * ratio + flash * 0.6 })
end

function M.update_mines(timeStep)
    if not active("mine") or not state.gameWorld_ then return end
    local p, level = player(), state.moduleLevels_.mine
    local maxMines = level >= 5 and 2 or 1
    p.mineCooldown = math.max(0, p.mineCooldown - timeStep)
    if p.mineCooldown <= 0 and #state.mines_ < maxMines then
        local widget = UI.Panel { position = "absolute", width = 12, height = 12, backgroundColor = { 180, 130, 60, 180 }, borderColor = { 255, 200, 100, 220 }, borderWidth = 2, borderRadius = 6, pointerEvents = "none" }
        state.gameWorld_:AddChild(widget)
        table.insert(state.mines_, { x = p.x, y = p.y, age = 0, armed = false, triggerRadius = 35 + level * 3, blastRadius = 50 + level * 6, damage = 2 + level * 0.6, lifetime = 8.0, widget = widget })
        p.mineCooldown = math.max(1.5, 4.0 - level * 0.4)
    end
    local armDelay = level >= 3 and 0.15 or 0.3
    for index = #state.mines_, 1, -1 do
        local mine = state.mines_[index]; mine.age = mine.age + timeStep
        if mine.age >= mine.lifetime then
            if callbacks.destroyWidget then callbacks.destroyWidget(mine.widget) end; table.remove(state.mines_, index)
        elseif mine.age < armDelay then
            mine.widget:SetStyle({ backgroundColor = { 160, 110, 50, 180 }, borderColor = { 200, 160, 80, 200 } })
        else
            mine.armed = true; local pulse = 0.65 + 0.35 * math.sin(mine.age * 7)
            mine.widget:SetStyle({ backgroundColor = { 255, math.floor(140 + 60 * pulse), math.floor(50 + 30 * pulse), math.floor(180 + 60 * pulse) }, borderColor = { 255, 230, 100, math.floor(220 + 35 * pulse) } })
            for _, enemy in ipairs(state.enemies_) do
                local dx, dy = enemy.x - mine.x, enemy.y - mine.y
                if not enemy.dead and dx * dx + dy * dy < mine.triggerRadius * mine.triggerRadius then
                    for _, victim in ipairs(state.enemies_) do
                        local vdx, vdy = victim.x - mine.x, victim.y - mine.y
                        if not victim.dead and vdx * vdx + vdy * vdy < mine.blastRadius * mine.blastRadius then damage(victim, mine.damage) end
                    end
                    if callbacks.destroyWidget then callbacks.destroyWidget(mine.widget) end; table.remove(state.mines_, index); break
                end
            end
        end
        if state.mines_[index] == mine then position(mine.widget, mine.x, mine.y, 12) end
    end
end

function M.update_trail(timeStep)
    if not active("hook") or not state.gameWorld_ then return end
    local p, level = player(), state.moduleLevels_.hook
    local interval = math.max(0.04, 0.10 - level * 0.012); p.trailTimer = p.trailTimer + timeStep
    if p.trailTimer >= interval then
        p.trailTimer = p.trailTimer - interval
        local widget = UI.Panel { position = "absolute", width = 8, height = 8, backgroundColor = { 100, 200, 255, 220 }, borderColor = { 200, 240, 255, 180 }, borderWidth = 1, borderRadius = 4, pointerEvents = "none" }
        state.gameWorld_:AddChild(widget)
        table.insert(state.trail_, { x = p.x, y = p.y, age = 0, lifetime = 0.6 + level * 0.2, radius = 8 + level * 0.5, damagePerSec = 2 + level * 0.8, widget = widget })
    end
    for index = #state.trail_, 1, -1 do
        local point = state.trail_[index]; point.age = point.age + timeStep
        if point.age >= point.lifetime then
            if callbacks.destroyWidget then callbacks.destroyWidget(point.widget) end; table.remove(state.trail_, index)
        else
            local fade = 1.0 - point.age / point.lifetime
            for _, enemy in ipairs(state.enemies_) do
                if not enemy.dead then
                    local dx, dy = enemy.x - point.x, enemy.y - point.y; local combined = point.radius + enemy.radius
                    if dx * dx + dy * dy < combined * combined then damage(enemy, point.damagePerSec * timeStep) end
                end
            end
            point.widget:SetStyle({ opacity = fade * 0.85, backgroundColor = { 100, 200, 255, math.floor(220 * fade) }, borderColor = { 200, 240, 255, math.floor(180 * fade) } })
            position(point.widget, point.x, point.y, 8)
        end
    end
end

return M
