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
local function damage_area(x, y, radius, amount)
    if callbacks.damageArea then callbacks.damageArea(x, y, radius, amount) end
end

function M.fire_trace_beam()
    local target = callbacks.findNearestEnemy and callbacks.findNearestEnemy() or nil
    if not target or not state.gameWorld_ then return end
    local p = player(); local dx, dy = target.x - p.x, target.y - p.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0 then return end
    local widget = UI.Panel { position = "absolute", width = 11, height = 11, backgroundGradient = { type = "radial", from = { 255, 240, 120, 255 }, to = { 255, 200, 60, 200 } }, borderColor = { 255, 255, 200, 220 }, borderWidth = 1, borderRadius = 6, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.projectiles_, { x = p.x, y = p.y, vx = dx / length * (430 + state.moduleLevels_.trace * 35), vy = dy / length * (430 + state.moduleLevels_.trace * 35), radius = 5, damage = p.damage + state.moduleLevels_.trace, life = 1.4, pierce = state.moduleLevels_.trace >= 3 and 2 or 1, widget = widget })
end

function M.pulse_bloom()
    if not active("pulse") then return end
    local p = player(); local radius = 105 + state.moduleLevels_.pulse * 10
    damage_area(p.x, p.y, radius, 2 + state.moduleLevels_.pulse)
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead then
            local dx, dy = enemy.x - p.x, enemy.y - p.y; local distance = math.sqrt(dx * dx + dy * dy)
            if distance < radius and distance > 0 then enemy.x = enemy.x + dx / distance * 30; enemy.y = enemy.y + dy / distance * 30 end
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
            widget = UI.Panel { position = "absolute", width = 16, height = 16, backgroundGradient = { type = "radial", from = { 200, 150, 255, 255 }, to = { 150, 100, 220, 200 } }, borderColor = { 220, 180, 255, 255 }, borderWidth = 1, borderRadius = 8, pointerEvents = "none" }
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
        local widget = UI.Panel { position = "absolute", width = 14, height = 14, backgroundGradient = { type = "radial", from = { 120, 200, 255, 220 }, to = { 60, 140, 200, 180 } }, borderColor = { 180, 230, 255, 220 }, borderWidth = 2, borderRadius = 7, pointerEvents = "none" }
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
            mine.widget:SetStyle({ opacity = 0.5 })
        else
            mine.armed = true; local pulse = 0.65 + 0.35 * math.sin(mine.age * 7)
            mine.widget:SetStyle({ opacity = 1, backgroundColor = { 100, math.floor(180 + 60 * pulse), 255, math.floor(200 + 55 * pulse) }, borderColor = { 180, 230, 255, math.floor(220 + 35 * pulse) } })
            for _, enemy in ipairs(state.enemies_) do
                local dx, dy = enemy.x - mine.x, enemy.y - mine.y
                if not enemy.dead and dx * dx + dy * dy < mine.triggerRadius * mine.triggerRadius then
                    damage_area(mine.x, mine.y, mine.blastRadius, mine.damage)
                    if callbacks.destroyWidget then callbacks.destroyWidget(mine.widget) end; table.remove(state.mines_, index); break
                end
            end
        end
        if state.mines_[index] == mine then position(mine.widget, mine.x, mine.y, 14) end
    end
end

function M.update_trail(timeStep)
    if not active("hook") or not state.gameWorld_ then return end
    local p, level = player(), state.moduleLevels_.hook
    local interval = math.max(0.04, 0.10 - level * 0.012); p.trailTimer = p.trailTimer + timeStep
    if p.trailTimer >= interval then
        p.trailTimer = p.trailTimer - interval
        local widget = UI.Panel { position = "absolute", width = 10, height = 10, backgroundGradient = { type = "radial", from = { 120, 220, 255, 230 }, to = { 80, 180, 240, 180 } }, borderColor = { 200, 240, 255, 200 }, borderWidth = 1, borderRadius = 5, pointerEvents = "none" }
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
            if state.boss_ and not state.boss_.dead then
                local dx, dy = state.boss_.x - point.x, state.boss_.y - point.y; local combined = point.radius + state.boss_.radius
                if dx * dx + dy * dy < combined * combined then
                    if callbacks.damageBoss then callbacks.damageBoss(point.damagePerSec * timeStep) end
                end
            end
            point.widget:SetStyle({ opacity = fade * 0.85, backgroundColor = { 120, 220, 255, math.floor(230 * fade) }, borderColor = { 200, 240, 255, math.floor(180 * fade) } })
            position(point.widget, point.x, point.y, 10)
        end
    end
end

-- ── Laser Gun ─────────────────────────────────────────────────────────────
-- Fires a high-damage targeted beam at the nearest enemy.
-- Higher levels: faster fire rate, more damage, beam pierces.

function M.fire_laser_gun()
    if not state.gameWorld_ then return end
    local p = player()
    local target = callbacks.findNearestEnemy and callbacks.findNearestEnemy()
    if not target then return end
    local level = state.moduleLevels_.laser
    local dx, dy = target.x - p.x, target.y - p.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0 then return end
    local dirX, dirY = dx / length, dy / length

    -- Beam visual (thin rectangle from player to target area)
    local beamLen = length + 80  -- overshoot slightly
    local beam = UI.Panel {
        position = "absolute",
        width = beamLen,
        height = 4 + level,
        backgroundGradient = { type = "linear", direction = "to-right",
            from = { 255, 40, 30, 200 }, to = { 255, 120, 20, 100 } },
        borderColor = { 255, 220, 100, 200 },
        borderWidth = 1,
        pointerEvents = "none",
    }
    state.gameWorld_:AddChild(beam)
    position(beam, p.x + dirX * beamLen * 0.5, p.y + dirY * beamLen * 0.5, beamLen)

    -- Damage to target and enemies near the beam path
    local damageAmount = 3 + level * 1.5
    local pierce = level >= 3 and 3 or 1
    local hitCount = 0
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead and hitCount < pierce then
            -- Check if enemy is near the beam line segment
            local ex, ey = enemy.x - p.x, enemy.y - p.y
            local dot = ex * dirX + ey * dirY
            if dot > 0 and dot < length + enemy.radius then
                local projX, projY = p.x + dirX * dot, p.y + dirY * dot
                local distX, distY = enemy.x - projX, enemy.y - projY
                if distX * distX + distY * distY < (enemy.radius + 18) ^ 2 then
                    damage(enemy, damageAmount)
                    hitCount = hitCount + 1
                end
            end
        end
    end
    -- Also hit boss/mid-boss along beam
    if state.boss_ and not state.boss_.dead then
        local bx, by = state.boss_.x - p.x, state.boss_.y - p.y
        local bdot = bx * dirX + by * dirY
        if bdot > 0 and bdot < length + state.boss_.radius then
            local projX, projY = p.x + dirX * bdot, p.y + dirY * bdot
            local bdx, bdy = state.boss_.x - projX, state.boss_.y - projY
            if bdx * bdx + bdy * bdy < (state.boss_.radius + 18) ^ 2 then
                if callbacks.damageBoss then callbacks.damageBoss(damageAmount) end
            end
        end
    end
    if state.midBoss_ and not state.midBoss_.dead then
        local mx, my = state.midBoss_.x - p.x, state.midBoss_.y - p.y
        local mdot = mx * dirX + my * dirY
        if mdot > 0 and mdot < length + state.midBoss_.radius then
            local projX, projY = p.x + dirX * mdot, p.y + dirY * mdot
            local mdx, mdy = state.midBoss_.x - projX, state.midBoss_.y - projY
            if mdx * mdx + mdy * mdy < (state.midBoss_.radius + 18) ^ 2 then
                if callbacks.damageMidBoss then callbacks.damageMidBoss(damageAmount) end
            end
        end
    end

    table.insert(state.laserBeams_, { widget = beam, life = 0.25 })
    p.laserTimer = math.max(1.0, 2.4 - level * 0.22)
end

function M.update_laser(timeStep)
    for index = #(state.laserBeams_ or {}), 1, -1 do
        local beam = state.laserBeams_[index]
        beam.life = beam.life - timeStep
        if beam.life <= 0 then
            if callbacks.destroyWidget then callbacks.destroyWidget(beam.widget) end
            table.remove(state.laserBeams_, index)
        else
            local fade = beam.life / 0.25
            beam.widget:SetStyle({ opacity = fade })
        end
    end
end

-- ── Poison Bomb ────────────────────────────────────────────────────────────
-- Deploys a poison cloud that deals damage-over-time in an area.
-- Higher levels: larger radius, more damage, longer duration.

function M.deploy_poison_bomb(x, y)
    if not state.gameWorld_ then return end
    local level = state.moduleLevels_.poison
    local radius = 40 + level * 8
    local size = radius * 2

    -- Cloud visual
    local cloud = UI.Panel {
        position = "absolute",
        width = size,
        height = size,
        backgroundGradient = { type = "radial",
            from = { 80, 200, 40, 90 }, to = { 20, 80, 10, 0 } },
        borderColor = { 100, 230, 50, 80 },
        borderWidth = 2,
        borderRadius = size * 0.5,
        pointerEvents = "none",
    }
    state.gameWorld_:AddChild(cloud)

    local cloudData = {
        x = x, y = y, radius = radius, size = size,
        widget = cloud,
        life = 3.0 + level * 0.6,
        damagePerSec = 1.5 + level * 0.8,
        tickTimer = 0,
    }
    if not state.poisonClouds_ then state.poisonClouds_ = {} end
    table.insert(state.poisonClouds_, cloudData)
    position(cloud, x, y, size)
    local pl = player()
    pl.poisonTimer = math.max(1.6, 3.5 - level * 0.3)
end

function M.update_poison(timeStep)
    for index = #(state.poisonClouds_ or {}), 1, -1 do
        local cloud = state.poisonClouds_[index]
        cloud.life = cloud.life - timeStep
        if cloud.life <= 0 then
            if callbacks.destroyWidget then callbacks.destroyWidget(cloud.widget) end
            table.remove(state.poisonClouds_, index)
        else
            -- Fade over time
            local fade = math.min(1, cloud.life / 1.5)
            local pulse = 0.7 + 0.3 * math.sin(cloud.life * 5)
            cloud.widget:SetStyle({ opacity = fade * pulse })

            -- Damage tick
            cloud.tickTimer = cloud.tickTimer + timeStep
            if cloud.tickTimer >= 0.25 then
                cloud.tickTimer = 0
                damage_area(cloud.x, cloud.y, cloud.radius, cloud.damagePerSec * 0.25)
                -- Also damage boss/midboss in radius
                if state.boss_ and not state.boss_.dead then
                    local dx, dy = state.boss_.x - cloud.x, state.boss_.y - cloud.y
                    if dx * dx + dy * dy < (cloud.radius + state.boss_.radius) ^ 2 then
                        if callbacks.damageBoss then callbacks.damageBoss(cloud.damagePerSec * 0.25) end
                    end
                end
                if state.midBoss_ and not state.midBoss_.dead then
                    local dx, dy = state.midBoss_.x - cloud.x, state.midBoss_.y - cloud.y
                    if dx * dx + dy * dy < (cloud.radius + state.midBoss_.radius) ^ 2 then
                        if callbacks.damageMidBoss then callbacks.damageMidBoss(cloud.damagePerSec * 0.25) end
                    end
                end
            end
            position(cloud.widget, cloud.x, cloud.y, cloud.size)
        end
    end
end

return M
