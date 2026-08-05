-- Geometry Breakout / 几何突围
-- Demo Build: Neon Vector Geometry visual pass, boss encounter, monetization placeholder.

local UI = require("urhox-libs/UI")
local state = require("state")
local i18n = require("i18n")
local player = require("player")
local weapons = require("weapons")        -- P4: 6-slot weapon system (replaces modules)
local character = require("character")    -- P4.3: visible player character
local vfx = require("vfx")                -- P8: death particles, trails, banners
local waves = require("waves")
local enemies = require("enemies")
local stages = require("stages")
local ui = require("ui")
local shop = require("shop")
local stats_panel = require("stats_panel")
local stat_items = require("data.stat_items")  -- P5: 8 stat axes
local AudioManager = require("audio")          -- Audio system (ADR-007)
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

-- Get the current stage's theme for arena visuals
local function ArenaTheme()
    return stages.theme(state.stage_) or stages.theme(1)
end

local function MakeLabel(text, props)
    props = props or {}; props.text = text; props.fontFamily = "sans"
    return UI.Label(props)
end

local function SetWidgetPosition(widget, x, y, size)
    if widget then widget:SetStyle({ left = x - size * 0.5, top = y - size * 0.5 }) end
end

local function WeaponName(id)
    local def = weapons.get_def(id)
    return def and def.name or state.T("game.none")
end

local function EquippedWeaponsText()
    local list = {}
    for i = 1, 6 do
        local w = state.weapons_[i]
        if w then table.insert(list, WeaponName(w.id)) end
    end
    return #list > 0 and table.concat(list, " + ") or state.T("game.none")
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
    for _, c in ipairs(state.poisonClouds_ or {}) do DestroyEntityWidget(c.widget) end
    for _, b in ipairs(state.laserBeams_ or {}) do DestroyEntityWidget(b.widget) end
    if state.orbitWidget_ then state.orbitWidget_:Destroy(); state.orbitWidget_ = nil end
    if state.orbitWidget2_ then state.orbitWidget2_:Destroy(); state.orbitWidget2_ = nil end
    if state.shellRing_ then state.shellRing_:Destroy(); state.shellRing_ = nil end
    character.destroy()   -- P4.3: cleanup character visuals
    vfx.destroy_all()     -- P8: cleanup death particles, trails, banners
    enemies.clear_boss()
    enemies.clear_midboss()
    enemies.clear_enemy_projectiles()
    state.enemies_, state.projectiles_, state.enemyProjectiles_, state.pickups_, state.mines_, state.trail_, state.damageNumbers_ = {}, {}, {}, {}, {}, {}, {}
end

local function ResetRunState()
    ClearEntities(); state.worldWidth_, state.worldHeight_ = GetWorldSize()
    player.reset(state.worldWidth_, state.worldHeight_)
    state.moduleLevels_ = { trace = 0, orbit = 0, pulse = 0, shell = 0, mine = 0, hook = 0, laser = 0, poison = 0 }; state.activeModules_ = { trace = false, orbit = false, pulse = false, shell = false, mine = false, hook = false, laser = false, poison = false }
    -- P4: Equip starting weapon (chosen on weapon select screen; blade fallback)
    state.weapons_ = {}; weapons.equip(state.chosenStartWeapon_ or "blade", 1)
    state.surgeTimer_, state.surgeFlash_ = 2.5, 0
    state.runTime_, state.waveTime_, state.spawnTimer_, state.enemyId_, state.score_ = 0, 0, 0, 0, 0
    state.dataFragments_, state.patternShards_, state.level_, state.levelProgress_ = 0, 0, 1, 0
    state.levelGoal_, state.wave_, state.waveSpawned_, state.eliteCount_ = 5, 1, 0, 0
    -- stage_ is preserved (set by stage select); reset level to 1
    state.stageLevel_ = 1
    state.stageIntroTimer_ = 2.0  -- show level intro on first level
    waves.reset()
    state.waveSpawnTarget_, state.wavePauseTimer_ = 10, 0
    state.chosenModule_, state.moduleLevel_, state.defeatReason_ = "", 0, ""
    state.summaryAwarded_ = false
    state.isVictory_ = false
    state.poisonClouds_, state.laserBeams_, state.damageNumbers_, state.hitFlash_, state.shakeTime_, state.evolutionFlash_ = {}, {}, {}, 0, 0, 0
    state.runStats_ = { damageTaken = 0, deaths = 0, maxWave = 1, maxStageLevel = 1, upgrades = {} }
    state.boss_ = nil; state.bossFlash_ = 0
    state.midBoss_ = nil; state.midBossFlash_ = 0
    state.maxEnemies_ = 30
    player_.gold_ = 0  -- P3: reset gold on new run
    state.shop_ = { isOpen = false, rerollCount = 0, timer = 15.0, weapons = {}, items = {}, rerollUnlocked = false, lockUnlocked = false }  -- P2
    state.statAxes_ = { maxHP = 0, damage = 0, attackSpeed = 0, range = 0, critChance = 0, dodge = 0, moveSpeed = 0, luck = 0 }  -- P5
end

function BuildUI()
    local t = ArenaTheme()
    local content
    if state.screen_ == state.SCREEN_SHOP then
        content = shop.build()
    else
        content = ui.build(state.screen_)
    end
    local rootProps = {
        width = "100%", height = "100%",
        backgroundGradient = { type = "linear", direction = "to-bottom-right",
            from = t.bgGradient, to = { t.bgGradient[1] * 1.4, t.bgGradient[2] * 0.8, t.bgGradient[3] * 1.6, 255 } },
        pointerEvents = "box-none", children = { content }
    }
    local nonGame = state.screen_ ~= "game"
    if nonGame then
        rootProps.justifyContent = "center"
        rootProps.alignItems = "center"
        rootProps.padding = { top = 44, bottom = 16, left = 16, right = 16 }
    end
    state.uiRoot_ = UI.Panel(rootProps)
    UI.SetRoot(state.uiRoot_, true)
    -- Reset HUD change-detection caches so new screen's first frame updates correctly
    state._hudCache, state._xpCache, state._xpBarCache = nil, nil, nil
    state._waveTextCache, state._waveTimeCache, state._waveModCache = nil, nil, nil
    state._modCache, state._fbCache, state._shellCache, state._shellBarCache = nil, nil, nil, nil
    state._bossAliveCache, state._bossBarCache, state._bossTextCache = nil, nil, nil
    state._midAliveCache, state._midBarCache, state._midTextCache = nil, nil, nil
    state._dockAlphaCache, state._dockShowCache, state._dockModCache = nil, nil, nil
    state._gTick, state._gShowCache, state._introShowCache = nil, nil, nil
    if state.screen_ == "game" then
        SetWidgetPosition(state.playerWidget_, state.player_.x, state.player_.y, 32)
        character.create()   -- P4.3: create visible player character
        ui.update_hud()
    end
end

local function SpawnPickup(x, y, kind, amount)
    if not state.gameWorld_ then return end
    if kind == "data" then
        local widget = UI.Panel { position = "absolute", width = 10, height = 10, backgroundGradient = { type = "radial", from = { 255, 214, 92, 255 }, to = { 200, 160, 50, 200 } }, borderColor = { 255, 240, 180, 220 }, borderWidth = 1, borderRadius = 5, pointerEvents = "none" }
        state.gameWorld_:AddChild(widget)
        table.insert(state.pickups_, { x = x, y = y, kind = kind, amount = amount, radius = 5, widget = widget })
    elseif kind == "gold" then
        -- P3: Gold pickup (coin-shaped, yellow)
        local widget = UI.Panel { position = "absolute", width = 12, height = 12, backgroundGradient = { type = "radial", from = { 255, 214, 50, 255 }, to = { 200, 160, 20, 200 } }, borderColor = { 255, 240, 100, 255 }, borderWidth = 2, borderRadius = 6, pointerEvents = "none" }
        state.gameWorld_:AddChild(widget)
        table.insert(state.pickups_, { x = x, y = y, kind = kind, amount = amount, radius = 6, widget = widget })
    else
        local widget = UI.Panel { position = "absolute", width = 13, height = 13, backgroundGradient = { type = "radial", from = { 175, 128, 255, 255 }, to = { 120, 80, 200, 200 } }, borderColor = { 210, 180, 255, 220 }, borderWidth = 1, borderRadius = 6, pointerEvents = "none" }
        state.gameWorld_:AddChild(widget)
        table.insert(state.pickups_, { x = x, y = y, kind = kind, amount = amount, radius = 7, widget = widget })
    end
end

local function DamagePlayer()
    if player_.invulnerable > 0 or state.screen_ ~= "game" then return end
    -- P5: Dodge check (before shell / integrity)
    local dodgeChance = math.min(0.60, (state.statAxes_.dodge or 0) * 0.04)
    if math.random() < dodgeChance then
        ui.show_damage_number(player_.x, player_.y - 10, 0, { 170, 102, 255, 255 })  -- purple "dodged"
        ui.trigger_hit_flash({ 170, 102, 255, 255 }, 0.15, 0.08)
        player_.invulnerable = 0.15  -- brief invuln on dodge
        return
    end
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
            if pickup.kind == "data" then state.dataFragments_ = state.dataFragments_ + pickup.amount
            elseif pickup.kind == "gold" then player_.gold_ = (player_.gold_ or 0) + pickup.amount  -- P3
            else state.patternShards_ = state.patternShards_ + pickup.amount; state.levelProgress_ = state.levelProgress_ + pickup.amount end
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
    -- P5: Stat axis upgrades (from data/stat_items.lua)
    if stat_items.DEFS[id] then
        state.statAxes_[id] = (state.statAxes_[id] or 0) + 1
        table.insert(state.runStats_.upgrades, "stat:" .. id)
        -- Apply immediate effects for HP and speed
        if id == "maxHP" then
            player_.maxIntegrity = player_.maxIntegrity + 2
            player_.integrity = player_.maxIntegrity
        end
        ui.trigger_evolution(id, state.statAxes_[id])
        return
    end
    -- P4: Weapon upgrades
    local def = weapons.get_def(id)
    if def then
        local slot = weapons.find_empty()
        if slot then
            weapons.equip(id, slot)
        else
            -- All slots full: refresh weapon (instant next shot)
            for i = 1, 6 do
                if state.weapons_[i] and state.weapons_[i].id == id then
                    state.weapons_[i].fireTimer = 0
                    break
                end
            end
        end
        table.insert(state.runStats_.upgrades, "weapon:" .. id)
        ui.trigger_evolution(id, weapons.weapon_count())
        return
    end
    -- Legacy: integrity / magnet
    if id == "integrity" then player_.maxIntegrity = player_.maxIntegrity + 1; player_.integrity = player_.maxIntegrity
    elseif id == "magnet" then player_.magnetRadius = player_.magnetRadius + 55 end
end

function PrepareUpgradeChoices()
    -- P5: Weapon pool + stat item pool + utility (integrity/magnet)
    local weaponIds = {}
    for id, _ in pairs(weapons.all_defs()) do table.insert(weaponIds, id) end
    local statIds = {}
    for _, key in ipairs(stat_items.ORDER) do table.insert(statIds, key) end

    -- Build pool: pick 2 weapons, 2 stat items, 2 utility → shuffle
    local pool = {}
    -- 2 weapons (unique)
    for _ = 1, 2 do
        local idx = math.random(1, #weaponIds)
        table.insert(pool, { type = "weapon", id = weaponIds[idx] })
    end
    -- 2 stat items (unique per screen)
    local pickedStats = {}
    for _ = 1, 2 do
        local idx, sid
        repeat
            idx = math.random(1, #statIds)
            sid = statIds[idx]
        until not pickedStats[sid]
        pickedStats[sid] = true
        table.insert(pool, { type = "stat", id = sid })
    end
    -- 1 utility
    table.insert(pool, { type = "utility", id = math.random() < 0.5 and "integrity" or "magnet" })

    -- Shuffle pool
    for i = #pool, 2, -1 do
        local j = math.random(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    state.upgradeCards_ = {}
    local pickCount = math.min(4, #pool)  -- P4: 4-card upgrade
    for i = 1, pickCount do
        local item = pool[i]
        local title, desc = "", ""
        if item.type == "weapon" then
            local def = weapons.get_def(item.id)
            if def then
                title = def.name
                desc = string.format("DMG %.1f | CD %.2fs | %s",
                    def.damage, def.cooldown,
                    def.tag == "melee" and state.T("weapon.melee") or state.T("weapon.ranged"))
            end
        elseif item.type == "stat" then
            local sdef = stat_items.DEFS[item.id]
            if sdef then
                local cur = state.statAxes_[item.id] or 0
                title = state.T(sdef.nameKey)
                desc = state.T(sdef.descKey) .. " | " .. sdef.icon .. " x" .. (cur + 1)
            end
        else
            if item.id == "integrity" then
                title, desc = state.T("upgrade.integrity"), state.T("upgrade.desc")
            else
                title, desc = state.T("upgrade.magnet"), state.T("upgrade.desc")
            end
        end
        table.insert(state.upgradeCards_,
            { id = item.id, type = item.type, title = title, description = desc })
    end
end

local function EndWave()
    ClearEntities()
    state.runStats_.maxWave = math.max(state.runStats_.maxWave, state.wave_)
    state.runStats_.maxStageLevel = math.max(state.runStats_.maxStageLevel or 1, state.stageLevel_)
    ui.trigger_shake(0.18, 0.18)

    -- P6: Was this the final wave? Shop will advance level after skip.
    local lvl = stages.level(state.stage_, state.stageLevel_)
    local maxW = lvl and lvl.totalWaves or state.maxWaves_
    state.shop_._advanceAfter = (state.wave_ >= maxW)

    -- Always route through the inter-wave shop
    waves.advance()
    state._needsRebuild = true
end

function HandleUpdate(_eventType, eventData)
    local timeStep = math.min(eventData["TimeStep"]:GetFloat(), 0.05)

    AudioManager.Update(timeStep)

    -- ── Deferred UI rebuild (from EndWave / screen changes) ────────────
    if state._needsRebuild then
        state._needsRebuild = false
        BuildUI()
        return
    end

    -- ── Timer-based screen transitions ────────────────────────────────
    if state.screen_ == state.SCREEN_WAVE_PAUSE then
        state.wavePauseTimer_ = state.wavePauseTimer_ + timeStep
        if state.wavePauseTimer_ >= 1.2 then
            waves.begin_wave()
            BuildUI()
        end
        return
    end

    if state.screen_ == state.SCREEN_STAGE_PAUSE then
        state.wavePauseTimer_ = state.wavePauseTimer_ + timeStep
        state.stageIntroTimer_ = math.max(0, state.stageIntroTimer_ - timeStep)
        if state.wavePauseTimer_ >= 2.5 then
            waves.begin_wave()
            BuildUI()
        end
        return
    end

    if state.screen_ ~= "game" then return end
    state.runTime_ = state.runTime_ + timeStep; state.waveTime_ = state.waveTime_ + timeStep
    state.stageIntroTimer_ = math.max(0, (state.stageIntroTimer_ or 0) - timeStep)
    player.update_timers(timeStep); state.spawnTimer_ = state.spawnTimer_ - timeStep; state.surgeFlash_ = math.max(0, state.surgeFlash_ - timeStep)
    if state.modifier_ == "surge" then state.surgeTimer_ = state.surgeTimer_ - timeStep; if state.surgeTimer_ <= 0 then state.surgeTimer_ = 4.0; state.surgeFlash_ = 0.55; for _, enemy in ipairs(state.enemies_) do if not enemy.dead then enemies.damage(enemy, 1); end end end end
    player.update_movement(timeStep)

    -- P4: Weapon auto-fire (replaces all module fire calls)
    weapons.update(timeStep)

    if waves.is_midboss_wave(state.wave_) then
        if not enemies.midboss_exists() and state.waveTime_ > 0.8 and state.waveSpawned_ == 0 then
            enemies.spawn_midboss()
            state.waveSpawned_ = 1
        end
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then
            enemies.spawn(false); state.spawnTimer_ = math.max(0.8, 1.4 - state.wave_ * 0.03)
        end
    elseif waves.is_boss_wave(state.wave_) then
        if not enemies.boss_exists() and state.waveTime_ > 1.0 and state.waveSpawned_ == 0 then
            enemies.spawn_boss()
            state.waveSpawned_ = 1
        end
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then
            enemies.spawn(false); state.spawnTimer_ = math.max(0.5, 1.2 - state.wave_ * 0.05)
        end
    else
        if state.waveSpawned_ == 0 and state.wave_ % 3 == 0 then enemies.spawn(true) end
        local interval = math.max(0.2, 0.7 - state.wave_ * 0.04)
        if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then enemies.spawn(false); state.spawnTimer_ = interval end
    end

    -- P4: Shell management (moved from modules.update_shell)
    if player_.maxShell > 0 then
        player_.shellRechargeTimer = player_.shellRechargeTimer + timeStep
        player_.shellFlash = math.max(0, player_.shellFlash - timeStep * 4)
        if player_.shell < player_.maxShell and player_.shellRechargeTimer >= 2.0 then
            player_.shell = math.min(player_.maxShell, player_.shell + 0.5 * timeStep)
        end
    end

    enemies.update(timeStep)
    if not IsGameScreen() then return end
    enemies.update_boss(timeStep)
    if not IsGameScreen() then return end
    enemies.update_midboss(timeStep)
    if not IsGameScreen() then return end
    enemies.update_projectiles(timeStep); enemies.update_enemy_projectiles(timeStep); UpdatePickups(timeStep)
    if not IsGameScreen() then return end

    -- P4.3: Character visuals (replaces all module visual updates)
    character.update(timeStep)
    -- P8: VFX update (death particles, projectile trails, wave banners)
    vfx.update(timeStep)

    local waveDone = state.waveTime_ >= state.waveDuration_ and state.waveSpawned_ >= state.waveSpawnTarget_ and #state.enemies_ == 0
    if waves.is_midboss_wave(state.wave_) then
        waveDone = state.waveTime_ >= state.waveDuration_ and not enemies.midboss_exists() and #state.enemies_ == 0
    elseif waves.is_boss_wave(state.wave_) then
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
        activeModuleText = EquippedWeaponsText,   -- P4: show weapons instead of modules
        moduleName = WeaponName,
        resetTouchControl = ResetTouchControl,
        handleTouchDown = HandleTouchDown,
        handleTouchMove = HandleTouchMove,
        handleTouchUp = HandleTouchUp,
        beginWave = waves.begin_wave,
        rebuild = BuildUI,
        selectStage = function(stageIdx)
            state.stage_ = stageIdx
            state.stageLevel_ = 1
            state.screen_ = state.SCREEN_WEAPON_SELECT
            BuildUI()
        end,
        confirmStartWeapon = function(weaponId)
            state.chosenStartWeapon_ = weaponId
            ResetRunState()
            waves.begin_wave()
            BuildUI()
        end,
        goStageSelect = function()
            state.screen_ = state.SCREEN_STAGE_SELECT
            BuildUI()
        end,
    })
    weapons.configure({
        findNearestEnemy = enemies.find_nearest,
        damageEnemy = enemies.damage,
        damageArea = enemies.damage_area,
        damageBoss = enemies.damage_boss,
        damageMidboss = enemies.damage_midboss,
        setWidgetPosition = SetWidgetPosition,
        destroyWidget = DestroyEntityWidget,
        spawnPickup = SpawnPickup,
    })
    shop.configure({
        rebuild = BuildUI,
        beginWave = waves.begin_wave,
        advanceLevel = waves.advance_level,
        T = state.T,
    })
    vfx.configure({
        setWidgetPosition = SetWidgetPosition,
        destroyWidget = DestroyEntityWidget,
    })
    enemies.configure({
        spawnPickup = SpawnPickup,
        damagePlayer = DamagePlayer,
        setWidgetPosition = SetWidgetPosition,
        destroyWidget = DestroyEntityWidget,
        spawnMidBossDrop = function()
            -- P4: Give a random new weapon on mid-boss defeat
            local all = {}
            for id, _ in pairs(weapons.all_defs()) do table.insert(all, id) end
            local pick = all[math.random(1, #all)]
            weapons.equip(pick)
        end,
        onDamage = function(x, y, amount, elite)
            ui.show_damage_number(x, y, amount, elite and { 255, 213, 83, 255 } or { 255, 255, 255, 255 })
            ui.trigger_hit_flash(elite and { 255, 213, 83, 255 } or { 255, 255, 255, 255 }, elite and 0.22 or 0.12, 0.1)
            ui.trigger_shake(elite and 0.12 or 0.05, 0.06)
        end,
    })
    graphics.windowTitle = "Geometry Breakout / 几何突围"
    UI.Init({ theme = "default-dark", fonts = { { family = "sans", weights = { normal = "Fonts/MiSans-Regular.ttf" } } }, scale = UI.Scale.DEFAULT })
    input.mouseMode = MM_ABSOLUTE; input.mouseVisible = true
    AudioManager.Init()
    SubscribeToEvent("Update", "HandleUpdate"); SubscribeToEvent("KeyDown", "HandleKeyDown"); SubscribeToEvent("KeyUp", "HandleKeyUp"); BuildUI()
    print("=== Geometry Breakout Demo Build started ===")
end

function Stop()
    ClearEntities(); UI.Shutdown()
    AudioManager.Shutdown()
end
