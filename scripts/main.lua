-- Geometry Breakout / 几何突围
-- Demo Build: Neon Vector Geometry visual pass, boss encounter, monetization placeholder.

local UI = require("urhox-libs/UI")
local state = require("state")
local i18n = require("i18n")
local player = require("player")
local modules = require("modules")
local waves = require("waves")
local enemies = require("enemies")
local ui = require("ui")
local player_ = state.player_

state.T = function(key, ...)
    return i18n.get(state.language_, key, ...)
end


local function IsGameScreen()
    return state.screen_ == "game"
end

local function GetWorldSize()
    local graphics = GetGraphics()
    local dpr = graphics:GetDPR()
    if dpr <= 0 then dpr = 1 end
    return graphics:GetWidth() / dpr, graphics:GetHeight() / dpr
end

local function MakeLabel(text, props)
    props = props or {}; props.text = text; props.fontFamily = "sans"
    return UI.Label(props)
end

local function SetWidgetPosition(widget, x, y, size)
    if widget then widget:SetStyle({ left = x - size * 0.5, top = y - size * 0.5 }) end
end

local function ModuleName(moduleId)
    if moduleId == "trace" then return state.T("module.trace") end
    if moduleId == "orbit" then return state.T("module.orbit") end
    if moduleId == "pulse" then return state.T("module.pulse") end
    if moduleId == "shell" then return state.T("module.shell") end
    if moduleId == "mine" then return state.T("module.mine") end
    if moduleId == "hook" then return state.T("module.hook") end
    return state.T("game.none")
end

local function IsModuleActive(moduleId)
    return state.activeModules_[moduleId] == true
end

local function ActiveModuleText()
    local list = {}
    for _, id in ipairs({ "trace", "orbit", "pulse", "shell", "mine", "hook" }) do
        if IsModuleActive(id) then table.insert(list, ModuleName(id) .. " Lv." .. state.moduleLevels_[id]) end
    end
    return #list > 0 and table.concat(list, " · ") or state.T("game.none")
end

local function SetTouchJoystickVisible(visible)
    if state.joystickBase_ then state.joystickBase_:SetVisible(visible) end
    if state.joystickKnob_ then state.joystickKnob_:SetVisible(visible) end
end

local function ResetTouchControl()
    state.touchPointerId_ = nil
    state.touchActive_ = false
    state.touchStartX_, state.touchStartY_, state.touchX_, state.touchY_ = 0, 0, 0, 0
    SetTouchJoystickVisible(false)
end

local function UpdateTouchJoystickVisual()
    if not state.touchActive_ or not state.joystickBase_ or not state.joystickKnob_ then return end
    local dx, dy = state.touchX_ - state.touchStartX_, state.touchY_ - state.touchStartY_
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance > state.touchRadius_ then
        dx, dy = dx / distance * state.touchRadius_, dy / distance * state.touchRadius_
    end
    state.joystickBase_:SetStyle({ left = state.touchStartX_ - state.touchRadius_, top = state.touchStartY_ - state.touchRadius_ })
    state.joystickKnob_:SetStyle({ left = state.touchStartX_ + dx - 26, top = state.touchStartY_ + dy - 26 })
end

local function HandleTouchDown(event)
    if state.screen_ ~= "game" or event.pointerType ~= "touch" or state.touchActive_ then return end
    if event.x > state.worldWidth_ * 0.58 then return end
    state.touchPointerId_ = event.pointerId
    state.touchActive_ = true
    state.touchStartX_, state.touchStartY_ = event.x, event.y
    state.touchX_, state.touchY_ = event.x, event.y
    SetTouchJoystickVisible(true)
    UpdateTouchJoystickVisual()
    event:PreventDefault()
end

local function HandleTouchMove(event)
    if not state.touchActive_ or event.pointerId ~= state.touchPointerId_ then return end
    state.touchX_, state.touchY_ = event.x, event.y
    UpdateTouchJoystickVisual()
    event:PreventDefault()
end

local function HandleTouchUp(event)
    if not state.touchActive_ or event.pointerId ~= state.touchPointerId_ then return end
    ResetTouchControl()
    event:PreventDefault()
end

local function DestroyEntityWidget(widget)
    if widget then widget:Destroy() end
end

local function ClearEntities()
    for _, e in ipairs(state.enemies_) do DestroyEntityWidget(e.widget) end
    for _, e in ipairs(state.projectiles_) do DestroyEntityWidget(e.widget) end
    for _, e in ipairs(state.enemyProjectiles_) do DestroyEntityWidget(e.widget) end
    for _, e in ipairs(state.pickups_) do DestroyEntityWidget(e.widget) end
    for _, m in ipairs(state.mines_) do DestroyEntityWidget(m.widget) end
    for _, p in ipairs(state.trail_) do DestroyEntityWidget(p.widget) end
    for _, n in ipairs(state.damageNumbers_) do DestroyEntityWidget(n.widget) end
    if state.orbitWidget_ then state.orbitWidget_:Destroy(); state.orbitWidget_ = nil end
    if state.orbitWidget2_ then state.orbitWidget2_:Destroy(); state.orbitWidget2_ = nil end
    if state.shellRing_ then state.shellRing_:Destroy(); state.shellRing_ = nil end
    enemies.clear_boss()
    enemies.clear_enemy_projectiles()
    state.enemies_, state.projectiles_, state.enemyProjectiles_, state.pickups_, state.mines_, state.trail_, state.damageNumbers_ = {}, {}, {}, {}, {}, {}, {}
end

local function ResetRunState()
    ClearEntities(); state.worldWidth_, state.worldHeight_ = GetWorldSize()
    player.reset(state.worldWidth_, state.worldHeight_)
    state.moduleLevels_ = { trace = 1, orbit = 0, pulse = 0, shell = 0, mine = 0, hook = 0 }; state.activeModules_ = { trace = true, orbit = false, pulse = false, shell = false, mine = false, hook = false }
    state.surgeTimer_, state.surgeFlash_ = 2.5, 0
    state.runTime_, state.waveTime_, state.spawnTimer_, state.enemyId_, state.score_ = 0, 0, 0, 0, 0
    state.dataFragments_, state.patternShards_, state.level_, state.levelProgress_ = 0, 0, 1, 0
    state.levelGoal_, state.wave_, state.waveSpawned_, state.eliteCount_ = 5, 1, 0, 0
    waves.reset()
    state.waveSpawnTarget_, state.wavePauseTimer_ = 10, 0
    state.chosenModule_, state.moduleLevel_, state.defeatReason_ = "", 0, ""
    state.summaryAwarded_ = false
    state.isVictory_ = false
    state.damageNumbers_, state.hitFlash_, state.shakeTime_, state.evolutionFlash_ = {}, 0, 0, 0
    state.runStats_ = { damageTaken = 0, deaths = 0, maxWave = 1, upgrades = {} }
    state.boss_ = nil; state.bossFlash_ = 0
    state.glitchWave_ = false; state.corruption_ = 0; state.glitchTickTimer_ = 0
    state.maxEnemies_ = 24
end

function BuildUI()
    local content = ui.build(state.screen_)
    local rootProps = { width = "100%", height = "100%", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 8, 18, 42, 255 }, to = { 35, 20, 68, 255 } }, pointerEvents = "box-none", children = { content } }
    if state.screen_ ~= "game" then
        rootProps.justifyContent = "center"
        rootProps.alignItems = "center"
        rootProps.padding = 16
    end
    state.uiRoot_ = UI.Panel(rootProps)
    UI.SetRoot(state.uiRoot_, true)
    if state.screen_ == "game" then
        SetWidgetPosition(state.playerWidget_, state.player_.x, state.player_.y, 32)
        ui.update_hud()
    end
end

local function SpawnPickup(x, y, kind, amount)
    if not state.gameWorld_ then return end
    if kind == "data" then
        local widget = UI.Panel { position = "absolute", width = 10, height = 10, backgroundGradient = { type = "radial", from = { 255, 214, 92, 255 }, to = { 200, 160, 50, 200 } }, borderColor = { 255, 240, 180, 220 }, borderWidth = 1, borderRadius = 5, pointerEvents = "none" }
        state.gameWorld_:AddChild(widget)
        table.insert(state.pickups_, { x = x, y = y, kind = kind, amount = amount, radius = 5, widget = widget })
    else
        local widget = UI.Panel { position = "absolute", width = 13, height = 13, backgroundGradient = { type = "radial", from = { 175, 128, 255, 255 }, to = { 120, 80, 200, 200 } }, borderColor = { 210, 180, 255, 220 }, borderWidth = 1, borderRadius = 6, pointerEvents = "none" }
        state.gameWorld_:AddChild(widget)
        table.insert(state.pickups_, { x = x, y = y, kind = kind, amount = amount, radius = 7, widget = widget })
    end
end

local function DamagePlayer()
    if player_.invulnerable > 0 or state.screen_ ~= "game" then return end
    if player_.shell >= 1 then
        player_.shell = player_.shell - 1
        if player_.shell < 0 then player_.shell = 0 end
        player_.shellRechargeTimer = 0
        player_.shellFlash = 0.22
        player_.invulnerable = 0.35
        state.runStats_.damageTaken = state.runStats_.damageTaken + 1
        ui.show_damage_number(player_.x, player_.y, 1, { 255, 213, 83, 255 }); ui.trigger_hit_flash({ 255, 213, 83, 255 }, 0.3, 0.16); ui.trigger_shake(0.16, 0.1)
        return
    end
    player_.shellRechargeTimer = 0
    player_.integrity = player_.integrity - 1; player_.invulnerable = 0.65
    state.runStats_.damageTaken = state.runStats_.damageTaken + 1
    ui.show_damage_number(player_.x, player_.y, 1, { 255, 111, 126, 255 }); ui.trigger_hit_flash({ 255, 111, 126, 255 }, 0.42, 0.2); ui.trigger_shake(0.24, 0.14)
    if player_.integrity <= 0 then
        state.runStats_.deaths = state.runStats_.deaths + 1
        if state.boss_ then state.defeatReason_ = state.T("game.reason_boss") else state.defeatReason_ = state.T("game.reason_contact") end
        if not state.summaryAwarded_ then state.profile_.calibration = state.profile_.calibration + math.max(1, math.floor(state.dataFragments_ / 8)); state.summaryAwarded_ = true end
        state.screen_ = "summary"; ClearEntities(); BuildUI()
    end
end

local function UpdatePickups(timeStep)
    for index = #state.pickups_, 1, -1 do
        local pickup = state.pickups_[index]; local dx, dy = player_.x - pickup.x, player_.y - pickup.y; local distance = math.sqrt(dx * dx + dy * dy)
        if distance < player_.magnetRadius and distance > 0 then local speed = distance < 45 and 330 or 180; pickup.x = pickup.x + dx / distance * speed * timeStep; pickup.y = pickup.y + dy / distance * speed * timeStep end
        if distance < player_.radius + pickup.radius then
            if pickup.kind == "data" then state.dataFragments_ = state.dataFragments_ + pickup.amount else state.patternShards_ = state.patternShards_ + pickup.amount; state.levelProgress_ = state.levelProgress_ + pickup.amount end
            DestroyEntityWidget(pickup.widget); table.remove(state.pickups_, index)
            if state.levelProgress_ >= state.levelGoal_ and state.screen_ == "game" then
                state.levelProgress_ = state.levelProgress_ - state.levelGoal_
                state.level_ = state.level_ + 1
                state.levelGoal_ = 5 + state.level_ * 3
                PrepareUpgradeChoices()
                ClearEntities()
                state.screen_ = "upgrade"
                BuildUI()
                return
            end
        else SetWidgetPosition(pickup.widget, pickup.x, pickup.y, pickup.kind == "data" and 10 or 13) end
    end
end

function ApplyUpgrade(id)
    if id == "trace" or id == "orbit" or id == "pulse" or id == "shell" or id == "mine" or id == "hook" then
        state.activeModules_[id] = true; state.moduleLevels_[id] = math.min(5, state.moduleLevels_[id] + 1); state.chosenModule_ = id; state.moduleLevel_ = state.moduleLevels_[id]
        table.insert(state.runStats_.upgrades, id .. "@" .. tostring(state.moduleLevels_[id]))
        if state.moduleLevels_[id] == 3 or state.moduleLevels_[id] == 5 then ui.trigger_evolution(id, state.moduleLevels_[id]) end
        if id == "shell" then
            local newMax = 2 + state.moduleLevels_.shell
            if newMax > player_.maxShell then player_.maxShell = newMax end
            player_.shell = player_.maxShell
        end
    elseif id == "integrity" then player_.maxIntegrity = player_.maxIntegrity + 1; player_.integrity = player_.maxIntegrity
    elseif id == "magnet" then player_.magnetRadius = player_.magnetRadius + 55 end
end

function PrepareUpgradeChoices()
    local options = { "trace", "orbit", "pulse", "shell", "mine", "hook", "integrity", "magnet" }
    for index = #options, 2, -1 do
        local j = math.random(1, index)
        options[index], options[j] = options[j], options[index]
    end
    state.upgradeCards_ = {}
    local pickCount = math.min(3, #options)
    for index = 1, pickCount do
        local id = options[index]
        local title, description = "", ""
        if id == "trace" then title, description = state.T("upgrade.trace"), state.T("module.trace_desc")
        elseif id == "orbit" then title, description = state.T("upgrade.orbit"), state.T("module.orbit_desc")
        elseif id == "pulse" then title, description = state.T("upgrade.pulse"), state.T("module.pulse_desc")
        elseif id == "shell" then title, description = state.T("upgrade.shell"), state.T("module.shell_desc")
        elseif id == "mine" then title, description = state.T("upgrade.mine"), state.T("module.mine_desc")
        elseif id == "hook" then title, description = state.T("upgrade.hook"), state.T("module.hook_desc")
        elseif id == "integrity" then title, description = state.T("upgrade.integrity"), state.T("upgrade.desc")
        else title, description = state.T("upgrade.magnet"), state.T("upgrade.desc") end
        table.insert(state.upgradeCards_, { id = id, title = title, description = description })
    end
end

local function EndWave()
    ClearEntities()
    state.runStats_.maxWave = math.max(state.runStats_.maxWave, state.wave_)
    ui.trigger_shake(0.18, 0.18)

    if state.wave_ >= state.maxWaves_ then
        state.defeatReason_ = state.T("game.reason_complete")
        state.isVictory_ = true
        if not state.summaryAwarded_ then state.profile_.calibration = state.profile_.calibration + math.max(1, math.floor(state.dataFragments_ / 8)); state.summaryAwarded_ = true end
        state.screen_ = "summary"; BuildUI(); return
    end
    waves.advance(); BuildUI()
end

function HandleUpdate(_eventType, eventData)
    if state.screen_ ~= "game" then return end
    local timeStep = math.min(eventData["TimeStep"]:GetFloat(), 0.05); state.runTime_ = state.runTime_ + timeStep; state.waveTime_ = state.waveTime_ + timeStep
    player.update_timers(timeStep); state.spawnTimer_ = state.spawnTimer_ - timeStep; state.surgeFlash_ = math.max(0, state.surgeFlash_ - timeStep)
    if state.modifier_ == "surge" then state.surgeTimer_ = state.surgeTimer_ - timeStep; if state.surgeTimer_ <= 0 then state.surgeTimer_ = 4.0; state.surgeFlash_ = 0.55; for _, enemy in ipairs(state.enemies_) do if not enemy.dead then enemies.damage(enemy, 1); end end end end
    player.update_movement(timeStep)

    if waves.is_boss_wave(state.wave_) then
        if not enemies.boss_exists() and state.waveTime_ > 1.0 and state.waveSpawned_ == 0 then
            enemies.spawn_boss()
            state.waveSpawned_ = 1
        end
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then
            enemies.spawn(false); state.spawnTimer_ = math.max(0.8, 1.5 - state.wave_ * 0.05)
        end
    else
        if state.waveSpawned_ == 0 and state.wave_ % 3 == 0 then enemies.spawn(true) end
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then enemies.spawn(false); state.spawnTimer_ = math.max(0.35, 0.9 - state.wave_ * 0.05) end
    end

    if IsModuleActive("trace") and player_.fireTimer <= 0 then modules.fire_trace_beam(); player_.fireTimer = math.max(0.18, 0.42 - state.moduleLevels_.trace * 0.04) end
    if IsModuleActive("pulse") and player_.pulseTimer <= 0 then modules.pulse_bloom(); player_.pulseTimer = math.max(1.4, 3.0 - state.moduleLevels_.pulse * 0.25) end
    modules.update_shell(timeStep)
    enemies.update(timeStep)
    if not IsGameScreen() then return end
    enemies.update_boss(timeStep)
    if not IsGameScreen() then return end
    enemies.update_projectiles(timeStep); enemies.update_enemy_projectiles(timeStep); UpdatePickups(timeStep)
    if not IsGameScreen() then return end
    modules.update_orbit(timeStep)
    modules.update_shell_visual()
    modules.update_mines(timeStep)
    modules.update_trail(timeStep)

    local waveDone = state.waveTime_ >= state.waveDuration_ and state.waveSpawned_ >= state.waveSpawnTarget_ and #state.enemies_ == 0
    if waves.is_boss_wave(state.wave_) then
        waveDone = state.waveTime_ >= state.waveDuration_ and not enemies.boss_exists() and #state.enemies_ == 0
    end
    if waveDone then EndWave() else ui.update_hud(); ui.update_feedback(timeStep) end
end

function HandleKeyDown(_eventType, eventData)
    local key = eventData["Key"]:GetInt(); state.keys_[key] = true
    if key == KEY_ESCAPE and state.screen_ == "game" then state.screen_ = "language"; ClearEntities(); BuildUI() end
end

function HandleKeyUp(_eventType, eventData)
    local key = eventData["Key"]:GetInt(); state.keys_[key] = false
end

function Start()
    ui.configure({
        makeLabel = MakeLabel,
        resetRunState = ResetRunState,
        applyUpgrade = ApplyUpgrade,
        activeModuleText = ActiveModuleText,
        moduleName = ModuleName,
        resetTouchControl = ResetTouchControl,
        handleTouchDown = HandleTouchDown,
        handleTouchMove = HandleTouchMove,
        handleTouchUp = HandleTouchUp,
        beginWave = waves.begin_wave,
        rebuild = BuildUI,
    })
    modules.configure({
        findNearestEnemy = enemies.find_nearest,
        damageEnemy = enemies.damage,
        damageArea = enemies.damage_area,
        damageBoss = enemies.damage_boss,
        setWidgetPosition = SetWidgetPosition,
        destroyWidget = DestroyEntityWidget,
    })
    enemies.configure({
        spawnPickup = SpawnPickup,
        damagePlayer = DamagePlayer,
        setWidgetPosition = SetWidgetPosition,
        destroyWidget = DestroyEntityWidget,
        onDamage = function(x, y, amount, elite)
            ui.show_damage_number(x, y, amount, elite and { 255, 213, 83, 255 } or { 255, 255, 255, 255 })
            ui.trigger_hit_flash(elite and { 255, 213, 83, 255 } or { 255, 255, 255, 255 }, elite and 0.22 or 0.12, 0.1)
            ui.trigger_shake(elite and 0.12 or 0.05, 0.06)
        end,
    })
    graphics.windowTitle = "Geometry Breakout / 几何突围"
    UI.Init({ theme = "default-dark", fonts = { { family = "sans", weights = { normal = "Fonts/MiSans-Regular.ttf" } } }, scale = UI.Scale.DEFAULT })
    input.mouseMode = MM_ABSOLUTE; input.mouseVisible = true
    SubscribeToEvent("Update", "HandleUpdate"); SubscribeToEvent("KeyDown", "HandleKeyDown"); SubscribeToEvent("KeyUp", "HandleKeyUp"); BuildUI()
    print("=== Geometry Breakout Demo Build started ===")
end

function Stop()
    ClearEntities(); UI.Shutdown()
end
