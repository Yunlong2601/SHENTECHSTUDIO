local UI = require("urhox-libs/UI")
local state = require("state")

local M = {}
local callbacks = {}

function M.configure(nextCallbacks) callbacks = nextCallbacks or {} end
local function p() return state.player_ end
local function pos(widget, x, y, size) if callbacks.setWidgetPosition then callbacks.setWidgetPosition(widget, x, y, size) end end
local function destroy(widget) if callbacks.destroyWidget then callbacks.destroyWidget(widget) end end

function M.kind_for_id(enemyId, wave)
    local r = math.random()
    if wave >= 7 then
        -- Wave 7-8: chaser 15%, skimmer 10%, charger 10%, shooter 30%, splitter 35%
        if r < 0.15 then return "chaser"
        elseif r < 0.25 then return "skimmer"
        elseif r < 0.35 then return "charger"
        elseif r < 0.65 then return "shooter"
        else return "splitter" end
    elseif wave >= 5 then
        -- Wave 5-6: chaser 20%, skimmer 15%, charger 15%, shooter 25%, splitter 25%
        if r < 0.20 then return "chaser"
        elseif r < 0.35 then return "skimmer"
        elseif r < 0.50 then return "charger"
        elseif r < 0.75 then return "shooter"
        else return "splitter" end
    elseif wave >= 3 then
        -- Wave 3-4: chaser 35%, skimmer 25%, charger 20%, shooter 20%
        if r < 0.35 then return "chaser"
        elseif r < 0.60 then return "skimmer"
        elseif r < 0.80 then return "charger"
        else return "shooter" end
    else
        -- Wave 1-2: chaser 55%, skimmer 30%, charger 15%
        if r < 0.55 then return "chaser"
        elseif r < 0.85 then return "skimmer"
        else return "charger" end
    end
end

function M.spawn(elite)
    if not state.gameWorld_ or #state.enemies_ >= state.maxEnemies_ or state.waveSpawned_ >= state.waveSpawnTarget_ then return end
    state.enemyId_, state.waveSpawned_ = state.enemyId_ + 1, state.waveSpawned_ + 1
    local side = (state.enemyId_ - 1) % 4; local x, y = 0, 0
    if side == 0 then x, y = -30, math.random(30, math.max(31, math.floor(state.worldHeight_ - 30)))
    elseif side == 1 then x, y = state.worldWidth_ + 30, math.random(30, math.max(31, math.floor(state.worldHeight_ - 30)))
    elseif side == 2 then x, y = math.random(30, math.max(31, math.floor(state.worldWidth_ - 30))), -30
    else x, y = math.random(30, math.max(31, math.floor(state.worldWidth_ - 30))), state.worldHeight_ + 30 end
    local kind = elite and "elite" or M.kind_for_id(state.enemyId_, state.wave_)
    local size = elite and 38 or (kind == "charger" and 28 or kind == "splitter" and 26 or kind == "shooter" and 26 or 24)
    local widget
    if elite then
        widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 255, 126, 63, 255 }, to = { 200, 80, 30, 255 } }, borderColor = { 255, 239, 164, 255 }, borderWidth = 3, borderRadius = 18, rotate = 0, pointerEvents = "none" }
    elseif kind == "skimmer" then
        widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 84, 216, 194, 255 }, to = { 40, 160, 140, 255 } }, borderColor = { 150, 255, 230, 255 }, borderWidth = 2, borderRadius = size * 0.5, pointerEvents = "none" }
    elseif kind == "charger" then
        widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 255, 168, 76, 255 }, to = { 200, 110, 30, 255 } }, borderColor = { 255, 220, 150, 255 }, borderWidth = 2, borderRadius = 3, rotate = 45, pointerEvents = "none" }
    elseif kind == "splitter" then
        widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 100, 220, 100, 255 }, to = { 50, 160, 50, 255 } }, borderColor = { 180, 255, 150, 255 }, borderWidth = 2, borderRadius = 6, rotate = 0, pointerEvents = "none" }
    elseif kind == "shooter" then
        widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 180, 130, 240, 255 }, to = { 120, 80, 200, 255 } }, borderColor = { 210, 170, 255, 255 }, borderWidth = 2, borderRadius = size * 0.4, rotate = 0, pointerEvents = "none" }
    else
        widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 244, 93, 133, 255 }, to = { 180, 50, 90, 255 } }, borderColor = { 255, 180, 200, 255 }, borderWidth = 2, borderRadius = 2, pointerEvents = "none" }
    end
    state.gameWorld_:AddChild(widget)
    local baseSpeed = (elite and 38 or kind == "skimmer" and 46 or kind == "charger" and 40 or kind == "shooter" and 30 or kind == "splitter" and 44 or 52) + state.wave_ * 3
    local baseIntegrity = (elite and 12 or kind == "splitter" and 3 or kind == "shooter" and 2 or 2) + state.wave_
    table.insert(state.enemies_, { x = x, y = y, radius = size * 0.5, speed = baseSpeed, integrity = baseIntegrity, widget = widget, elite = elite, kind = kind, phase = 0, charge = 0, telegraph = 0, fireTimer = 2.0, dead = false, isFragment = false })
end

function M.spawn_boss()
    if not state.gameWorld_ then return end
    local bx, by = state.worldWidth_ * 0.5, -60
    local size = 72
    local widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "radial", from = { 255, 180, 60, 255 }, to = { 180, 60, 20, 255 } }, borderColor = { 255, 239, 100, 255 }, borderWidth = 4, borderRadius = 24, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    local coreWidget = UI.Panel { position = "absolute", width = 28, height = 28, backgroundColor = { 255, 80, 80, 255 }, borderColor = { 255, 200, 100, 255 }, borderWidth = 2, borderRadius = 14, pointerEvents = "none" }
    state.gameWorld_:AddChild(coreWidget)
    local maxIntegrity = 40 + state.wave_ * 3
    state.boss_ = { x = bx, y = by, radius = 36, speed = 30, integrity = maxIntegrity, maxIntegrity = maxIntegrity, widget = widget, coreWidget = coreWidget, phase = 0, pulseTimer = 3.5, spawnTimer = 6.0, telegraph = 0, dead = false, entering = true, targetX = state.worldWidth_ * 0.5, targetY = state.worldHeight_ * 0.3 }
    state.bossFlash_ = 0.6
    if state.feedbackLabel_ then
        state.feedbackLabel_:SetText("◆  " .. state.T("boss.spawn") .. "  ◆")
        state.feedbackLabel_:SetStyle({ fontColor = { 255, 180, 60, 255 }, opacity = 1 })
    end
end

function M.spawn_fragment(x, y)
    if not state.gameWorld_ or #state.enemies_ >= state.maxEnemies_ then return end
    local fragmentCount = 0
    for _, e in ipairs(state.enemies_) do
        if e.isFragment then fragmentCount = fragmentCount + 1 end
    end
    if fragmentCount >= 10 then return end
    local size = 16
    local widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 120, 230, 120, 255 }, to = { 60, 170, 60, 200 } }, borderColor = { 180, 255, 150, 220 }, borderWidth = 1, borderRadius = 4, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    local angle = math.random() * math.pi * 2
    table.insert(state.enemies_, { x = x + math.cos(angle) * 12, y = y + math.sin(angle) * 12, radius = 8, speed = 60 + state.wave_ * 3, integrity = 1, widget = widget, elite = false, kind = "chaser", phase = 0, charge = 0, telegraph = 0, fireTimer = 0, dead = false, isFragment = true })
end

function M.spawn_enemy_projectile(x, y, tx, ty)
    if not state.gameWorld_ then return end
    local dx, dy = tx - x, ty - y
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0 then return end
    local speed = 160 + state.wave_ * 5
    local widget = UI.Panel { position = "absolute", width = 10, height = 10, backgroundGradient = { type = "radial", from = { 200, 130, 255, 255 }, to = { 150, 80, 220, 200 } }, borderColor = { 230, 180, 255, 220 }, borderWidth = 1, borderRadius = 5, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.enemyProjectiles_, { x = x, y = y, vx = dx / length * speed, vy = dy / length * speed, radius = 5, damage = 1, life = 3.0, widget = widget })
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
    state.score_ = state.score_ + (enemy.elite and 8 or enemy.isFragment and 0 or 1)
    if enemy.kind == "splitter" and not enemy.isFragment then
        M.spawn_fragment(enemy.x, enemy.y)
        M.spawn_fragment(enemy.x, enemy.y)
    end
    if callbacks.spawnPickup then callbacks.spawnPickup(enemy.x, enemy.y, "data", (enemy.elite and 3 or 1) * reward); callbacks.spawnPickup(enemy.x + 8, enemy.y, "shard", enemy.elite and 3 or 1) end
    destroy(enemy.widget)
end

function M.damage_boss(amount)
    if not state.boss_ or state.boss_.dead then return end
    state.boss_.integrity = state.boss_.integrity - amount
    state.bossFlash_ = 0.15
    if callbacks.onDamage then callbacks.onDamage(state.boss_.x, state.boss_.y, amount, true) end
    if state.boss_.integrity > 0 then return end
    state.boss_.dead = true
    state.score_ = state.score_ + 50
    state.bossFlash_ = 0.8
    if callbacks.spawnPickup then
        for _ = 1, 6 do callbacks.spawnPickup(state.boss_.x + math.random(-30, 30), state.boss_.y + math.random(-30, 30), "data", 3) end
        for _ = 1, 4 do callbacks.spawnPickup(state.boss_.x + math.random(-20, 20), state.boss_.y + math.random(-20, 20), "shard", 2) end
    end
    destroy(state.boss_.widget)
    destroy(state.boss_.coreWidget)
    state.boss_ = nil
    if state.feedbackLabel_ then
        state.feedbackLabel_:SetText("◆  " .. state.T("boss.defeated") .. "  ◆")
        state.feedbackLabel_:SetStyle({ fontColor = { 146, 225, 191, 255 }, opacity = 1 })
    end
end

function M.update(timeStep)
    local bound = state.modifier_ == "compression" and 70 or 0; local player = p()
    -- R-03: Corruption overlay — frame-rate-independent Poisson tick (~1.5s mean)
    local isGlitchWave = state.glitchWave_
    if isGlitchWave then
        state.glitchTickTimer_ = state.glitchTickTimer_ + timeStep
        if state.glitchTickTimer_ >= 1.5 then
            state.glitchTickTimer_ = state.glitchTickTimer_ - 1.5
            state.corruption_ = math.min(100, state.corruption_ + 1)
            for _, e in ipairs(state.enemies_) do
                if not e.dead then
                    e.x = e.x + math.random(-12, 12)
                    e.y = e.y + math.random(-12, 12)
                end
            end
        end
    end
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead then
            local dx, dy = player.x - enemy.x, player.y - enemy.y; local distance = math.sqrt(dx * dx + dy * dy)
            enemy.phase = enemy.phase + timeStep
            if enemy.kind == "skimmer" then local tx, ty = -dy / math.max(distance, 1), dx / math.max(distance, 1); dx, dy = dx + tx * 90, dy + ty * 90
            elseif enemy.kind == "charger" then if enemy.charge <= 0 then enemy.charge, enemy.telegraph = 2.1, 0.45 end; if enemy.telegraph > 0 then enemy.telegraph = enemy.telegraph - timeStep else enemy.charge = enemy.charge - timeStep; enemy.speed = 165 + state.wave_ * 5 end end
            elseif enemy.kind == "shooter" then
                enemy.fireTimer = enemy.fireTimer - timeStep
                local idealRange = 200
                if distance > idealRange + 30 then
                    -- move closer
                elseif distance < idealRange - 30 then
                    dx, dy = -dx, -dy -- back away
                else
                    -- strafe
                    local tx, ty = -dy / math.max(distance, 1), dx / math.max(distance, 1)
                    dx, dy = tx * 60, ty * 60
                end
                if enemy.fireTimer <= 0 and distance < 350 then
                    enemy.fireTimer = 2.5
                    enemy.telegraph = 0.4
                end
                if enemy.telegraph > 0 then
                    enemy.telegraph = enemy.telegraph - timeStep
                    if enemy.telegraph <= 0 then
                        M.spawn_enemy_projectile(enemy.x, enemy.y, player.x, player.y)
                    end
                end
            end
            if distance > 0 and (enemy.kind ~= "charger" or enemy.telegraph <= 0) then local mult = state.modifier_ == "overclock" and 1.25 or 1; enemy.x = enemy.x + dx / math.max(distance, 1) * enemy.speed * mult * timeStep; enemy.y = enemy.y + dy / math.max(distance, 1) * enemy.speed * mult * timeStep end
            if bound > 0 then enemy.x = math.max(bound, math.min(state.worldWidth_ - bound, enemy.x)); enemy.y = math.max(bound, math.min(state.worldHeight_ - bound, enemy.y)) end
            if enemy.telegraph > 0 and enemy.kind ~= "shooter" then enemy.widget:SetStyle({ backgroundColor = { 255, 245, 110, 255 }, borderColor = { 255, 70, 80, 255 }, scale = 1.2 }) elseif enemy.telegraph > 0 and enemy.kind == "shooter" then enemy.widget:SetStyle({ borderColor = { 255, 80, 255, 255 }, borderWidth = 3, scale = 1.15 }) else enemy.widget:SetStyle({ scale = 1.0 }) end
            pos(enemy.widget, enemy.x, enemy.y, enemy.elite and 38 or (enemy.kind == "charger" and 28 or enemy.kind == "splitter" and 26 or enemy.kind == "shooter" and 26 or enemy.isFragment and 16 or 24))
            if distance < player.radius + enemy.radius and callbacks.damagePlayer then callbacks.damagePlayer(); if state.screen_ ~= "game" then return end; enemy.x = enemy.x - dx / math.max(distance, 1) * 22; enemy.y = enemy.y - dy / math.max(distance, 1) * 22 end
        end
    end
    for index = #state.enemies_, 1, -1 do if state.enemies_[index].dead then table.remove(state.enemies_, index) end end
end

function M.update_boss(timeStep)
    local boss = state.boss_
    if not boss or boss.dead then return end
    local player = p()
    boss.phase = boss.phase + timeStep
    state.bossFlash_ = math.max(0, state.bossFlash_ - timeStep)
    if boss.entering then
        boss.y = boss.y + 80 * timeStep
        if boss.y >= boss.targetY then boss.y = boss.targetY; boss.entering = false end
    else
        local dx, dy = player.x - boss.x, player.y - boss.y; local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 180 then boss.x = boss.x + dx / math.max(distance, 1) * boss.speed * timeStep; boss.y = boss.y + dy / math.max(distance, 1) * boss.speed * timeStep end
        boss.x = boss.x + math.cos(boss.phase * 0.8) * 40 * timeStep
        boss.y = boss.y + math.sin(boss.phase * 0.6) * 25 * timeStep
        boss.x = math.max(60, math.min(state.worldWidth_ - 60, boss.x))
        boss.y = math.max(60, math.min(state.worldHeight_ - 60, boss.y))

        boss.pulseTimer = boss.pulseTimer - timeStep
        if boss.pulseTimer <= 0 then
            boss.pulseTimer = 3.5
            boss.telegraph = 1.0
        end
        if boss.telegraph > 0 then
            boss.telegraph = boss.telegraph - timeStep
            boss.widget:SetStyle({ borderColor = { 255, 80, 80, 255 }, borderWidth = 5, scale = 1.08 + 0.04 * math.sin(boss.phase * 20) })
            if boss.telegraph <= 0 then
                boss.widget:SetStyle({ borderColor = { 255, 239, 100, 255 }, borderWidth = 4, scale = 1.0 })
                local pulseRadius = 140
                for _, enemy in ipairs(state.enemies_) do
                    if not enemy.dead then
                        local ex, ey = enemy.x - boss.x, enemy.y - boss.y
                        local ed = math.sqrt(ex * ex + ey * ey)
                        if ed < pulseRadius and ed > 0 then
                            enemy.x = enemy.x + ex / ed * 60; enemy.y = enemy.y + ey / ed * 60
                        end
                    end
                end
                local pdx, pdy = player.x - boss.x, player.y - boss.y; local pd = math.sqrt(pdx * pdx + pdy * pdy)
                if pd < pulseRadius and pd > 0 and callbacks.damagePlayer then callbacks.damagePlayer() end
                state.surgeFlash_ = 0.4
            end
        end

        boss.spawnTimer = boss.spawnTimer - timeStep
        if boss.spawnTimer <= 0 and #state.enemies_ < 12 then
            boss.spawnTimer = 5.0
            state.enemyId_ = state.enemyId_ + 1
            local kind = M.kind_for_id(state.enemyId_, state.wave_)
            local size = 24; local sx, sy = boss.x + math.random(-30, 30), boss.y + math.random(-30, 30)
            local widget
            if kind == "skimmer" then
                widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 84, 216, 194, 255 }, to = { 40, 160, 140, 255 } }, borderColor = { 150, 255, 230, 255 }, borderWidth = 2, borderRadius = size * 0.5, pointerEvents = "none" }
            elseif kind == "charger" then
                widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 255, 168, 76, 255 }, to = { 200, 110, 30, 255 } }, borderColor = { 255, 220, 150, 255 }, borderWidth = 2, borderRadius = 3, rotate = 45, pointerEvents = "none" }
            elseif kind == "splitter" then
                widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 100, 220, 100, 255 }, to = { 50, 160, 50, 255 } }, borderColor = { 180, 255, 150, 255 }, borderWidth = 2, borderRadius = 6, pointerEvents = "none" }
            elseif kind == "shooter" then
                widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 180, 130, 240, 255 }, to = { 120, 80, 200, 255 } }, borderColor = { 210, 170, 255, 255 }, borderWidth = 2, borderRadius = size * 0.4, pointerEvents = "none" }
            else
                widget = UI.Panel { position = "absolute", width = size, height = size, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 244, 93, 133, 255 }, to = { 180, 50, 90, 255 } }, borderColor = { 255, 180, 200, 255 }, borderWidth = 2, borderRadius = 2, pointerEvents = "none" }
            end
            state.gameWorld_:AddChild(widget)
            table.insert(state.enemies_, { x = sx, y = sy, radius = 12, speed = 52 + state.wave_ * 3, integrity = 2 + state.wave_, widget = widget, elite = false, kind = kind, phase = 0, charge = 0, telegraph = 0, fireTimer = 2.0, dead = false, isFragment = false })
        end
    end

    pos(boss.widget, boss.x, boss.y, 72)
    pos(boss.coreWidget, boss.x, boss.y, 28)
    local corePulse = 0.7 + 0.3 * math.sin(boss.phase * 3)
    local flashBoost = state.bossFlash_ > 0 and math.min(60, math.floor(state.bossFlash_ * 200)) or 0
    boss.coreWidget:SetStyle({ backgroundColor = { 255, math.floor(80 + flashBoost * 0.5), math.floor(80 + flashBoost * 0.3), 255 }, scale = corePulse })
end

function M.update_projectiles(timeStep)
    for projectileIndex = #state.projectiles_, 1, -1 do
        local projectile = state.projectiles_[projectileIndex]; projectile.x = projectile.x + projectile.vx * timeStep; projectile.y = projectile.y + projectile.vy * timeStep; projectile.life = projectile.life - timeStep; local remove = projectile.life <= 0
        for enemyIndex = #state.enemies_, 1, -1 do
            local enemy = state.enemies_[enemyIndex]; if not enemy then break end
            local dx, dy = enemy.x - projectile.x, enemy.y - projectile.y
            if dx * dx + dy * dy < (enemy.radius + projectile.radius) ^ 2 then M.damage(enemy, projectile.damage); projectile.pierce = projectile.pierce - 1; remove = projectile.pierce <= 0; if remove then break end end
        end
        if not remove and state.boss_ and not state.boss_.dead then
            local dx, dy = state.boss_.x - projectile.x, state.boss_.y - projectile.y
            if dx * dx + dy * dy < (state.boss_.radius + projectile.radius) ^ 2 then M.damage_boss(projectile.damage); projectile.pierce = projectile.pierce - 1; remove = projectile.pierce <= 0 end
        end
        if remove then destroy(projectile.widget); table.remove(state.projectiles_, projectileIndex) else pos(projectile.widget, projectile.x, projectile.y, 10) end
    end
end

function M.update_enemy_projectiles(timeStep)
    local player = p()
    for index = #state.enemyProjectiles_, 1, -1 do
        local proj = state.enemyProjectiles_[index]
        proj.x = proj.x + proj.vx * timeStep
        proj.y = proj.y + proj.vy * timeStep
        proj.life = proj.life - timeStep
        local remove = proj.life <= 0 or proj.x < -20 or proj.x > state.worldWidth_ + 20 or proj.y < -20 or proj.y > state.worldHeight_ + 20
        if not remove then
            local dx, dy = player.x - proj.x, player.y - proj.y
            if dx * dx + dy * dy < (player.radius + proj.radius) ^ 2 then
                if callbacks.damagePlayer then callbacks.damagePlayer() end
                remove = true
            end
        end
        if remove then destroy(proj.widget); table.remove(state.enemyProjectiles_, index) else pos(proj.widget, proj.x, proj.y, 10) end
    end
end

function M.boss_exists()
    return state.boss_ ~= nil and not state.boss_.dead
end

function M.clear_boss()
    if state.boss_ then
        destroy(state.boss_.widget)
        destroy(state.boss_.coreWidget)
        state.boss_ = nil
    end
end

function M.clear_enemy_projectiles()
    for _, proj in ipairs(state.enemyProjectiles_) do destroy(proj.widget) end
    state.enemyProjectiles_ = {}
end

-- Called by pulse/mine/hook modules to also damage the boss
function M.damage_area(x, y, radius, amount)
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead then
            local dx, dy = enemy.x - x, enemy.y - y
            if dx * dx + dy * dy < (enemy.radius + radius) ^ 2 then M.damage(enemy, amount) end
        end
    end
    if state.boss_ and not state.boss_.dead then
        local dx, dy = state.boss_.x - x, state.boss_.y - y
        if dx * dx + dy * dy < (state.boss_.radius + radius) ^ 2 then M.damage_boss(amount) end
    end
end

return M
