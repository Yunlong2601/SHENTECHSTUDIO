-- Geometry Breakout / 几何突围
-- Prototype 03: pickups, progression, wave pacing, modules, elite, and run summary.

local UI = require("urhox-libs/UI")
local state = require("state")
local i18n = require("i18n")

state.T = function(key, ...)
    return i18n.get(state.language_, key, ...)
end


---@class PlayerState
---@field x number
---@field y number
---@field radius number
---@field speed number
---@field integrity number
---@field maxIntegrity number
---@field invulnerable number
---@field fireTimer number
---@field pulseTimer number
---@field orbitAngle number
---@field magnetRadius number
---@field damage number
---@field shell number
---@field maxShell number
---@field shellRechargeTimer number
---@field shellFlash number
---@field mineCooldown number
---@field trailTimer number
---@type PlayerState
local player_ = {
    x = 0, y = 0, radius = 16, speed = 220,
    integrity = 5, maxIntegrity = 5, invulnerable = 0,
    fireTimer = 0, pulseTimer = 0, orbitAngle = 0,
    magnetRadius = 110, damage = 1,
    shell = 0, maxShell = 0, shellRechargeTimer = 0, shellFlash = 0,
    mineCooldown = 0, trailTimer = 0,
}

local function IsGameScreen()
    return state.screen_ == "game"
end

local function ModifierForWave(wave)
    local cycle = (wave - 1) % 3
    if cycle == 0 then return "compression" end
    if cycle == 1 then return "surge" end
    return "overclock"
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
    -- Reserve the right side for future touch abilities; movement starts on the left.
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
    for _, e in ipairs(state.pickups_) do DestroyEntityWidget(e.widget) end
    for _, m in ipairs(state.mines_) do DestroyEntityWidget(m.widget) end
    for _, p in ipairs(state.trail_) do DestroyEntityWidget(p.widget) end
    if state.orbitWidget_ then state.orbitWidget_:Destroy(); state.orbitWidget_ = nil end
    if state.orbitWidget2_ then state.orbitWidget2_:Destroy(); state.orbitWidget2_ = nil end
    if state.shellRing_ then state.shellRing_:Destroy(); state.shellRing_ = nil end
    state.enemies_, state.projectiles_, state.pickups_, state.mines_, state.trail_ = {}, {}, {}, {}, {}
end

local function ResetRunState()
    ClearEntities(); state.worldWidth_, state.worldHeight_ = GetWorldSize()
    player_.x, player_.y = state.worldWidth_ * 0.5, state.worldHeight_ * 0.5
    player_.integrity, player_.maxIntegrity = 5 + state.profile_.startingIntegrity, 5 + state.profile_.startingIntegrity
    player_.invulnerable, player_.fireTimer, player_.pulseTimer = 0, 0, 0
    player_.orbitAngle, player_.magnetRadius, player_.damage = 0, 110 + state.profile_.magnet * 35, 1
    player_.shell, player_.maxShell, player_.shellRechargeTimer, player_.shellFlash = 0, 0, 0, 0
    player_.mineCooldown, player_.trailTimer = 0, 0
    state.moduleLevels_ = { trace = 1, orbit = 0, pulse = 0, shell = 0, mine = 0, hook = 0 }; state.activeModules_ = { trace = true, orbit = false, pulse = false, shell = false, mine = false, hook = false }
    state.surgeTimer_, state.surgeFlash_ = 2.5, 0
    state.runTime_, state.waveTime_, state.spawnTimer_, state.enemyId_, state.score_ = 0, 0, 0, 0, 0
    state.dataFragments_, state.patternShards_, state.level_, state.levelProgress_ = 0, 0, 1, 0
    state.levelGoal_, state.wave_, state.waveSpawned_, state.eliteCount_ = 5, 1, 0, 0
    state.modifier_ = ModifierForWave(state.wave_)
    state.waveSpawnTarget_, state.wavePauseTimer_ = 10, 0
    state.chosenModule_, state.moduleLevel_, state.defeatReason_ = "", 0, ""
    state.summaryAwarded_ = false
end

local function MakeLanguageButton(code, label)
    return UI.Button { text = state.language_ == code and ("✓  " .. label) or label, variant = state.language_ == code and "success" or "secondary", width = "100%", height = 48, marginBottom = 10, onClick = function() state.language_ = code; BuildUI() end }
end

local function BuildLanguageScreen()
    local card = UI.Panel { width = "90%", maxWidth = 430, padding = 28, gap = 12, alignItems = "center", backgroundColor = { 20, 31, 58, 245 }, borderRadius = 24, borderWidth = 1, borderColor = { 91, 124, 190, 180 }, children = {
        MakeLabel("◆", { fontSize = 42, fontColor = { 255, 213, 83, 255 } }),
        MakeLabel(state.T("menu.title"), { fontSize = 30, fontWeight = "bold", fontColor = { 255, 255, 255, 255 }, textAlign = "center" }),
        MakeLabel(state.T("menu.subtitle"), { fontSize = 15, fontColor = { 177, 196, 231, 255 }, textAlign = "center" }),
        UI.Panel { width = "100%", padding = 14, gap = 4, backgroundColor = { 11, 20, 42, 180 }, borderRadius = 14, children = { MakeLanguageButton("zh_CN", state.T("language.simplified_chinese")), MakeLanguageButton("en", state.T("language.english")) } },
        MakeLabel(state.T("menu.ready"), { fontSize = 13, fontColor = { 146, 225, 191, 255 }, textAlign = "center", marginTop = 8 }),
        UI.Button { text = state.T("menu.start"), variant = "primary", width = "100%", height = 50, onClick = function() state.screen_ = "game"; ResetRunState(); BuildUI() end },
        UI.Button { text = state.T("meta.archive"), variant = "secondary", width = "100%", height = 44, onClick = function() state.metaScreenReturn_ = "language"; state.screen_ = "archive"; BuildUI() end },
    } }
    return UI.Panel { width = "100%", height = "100%", justifyContent = "center", alignItems = "center", padding = 20, children = { card } }
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
    for _, id in ipairs({ "trace", "orbit", "pulse", "shell", "mine", "hook" }) do if state.activeModules_[id] then table.insert(list, ModuleName(id) .. " Lv." .. state.moduleLevels_[id]) end end
    return #list > 0 and table.concat(list, " · ") or state.T("game.none")
end

local function BuildGameScreen()
    ResetTouchControl()
    state.gameWorld_ = UI.Panel { id = "gameWorld", position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "none", backgroundColor = { 9, 17, 37, 255 }, overflow = "hidden" }
    state.playerWidget_ = UI.Panel { id = "player", position = "absolute", width = 32, height = 32, backgroundColor = { 82, 214, 255, 255 }, borderColor = { 225, 250, 255, 255 }, borderWidth = 2, borderRadius = 5, rotate = 45 }
    state.gameWorld_:AddChild(state.playerWidget_)
    state.shellRing_ = UI.Panel { id = "shellRing", position = "absolute", width = 44, height = 44, borderColor = { 255, 213, 83, 200 }, borderWidth = 2, borderRadius = 22, pointerEvents = "none", visible = false }
    state.gameWorld_:AddChild(state.shellRing_)

    state.hudLabel_ = MakeLabel("", { fontSize = 13, fontWeight = "bold", fontColor = { 220, 235, 255, 255 }, lineHeight = 1.35 })
    state.xpLabel_ = MakeLabel("", { fontSize = 11, fontColor = { 183, 207, 242, 255 }, marginTop = 5 })
    state.xpBarFill_ = UI.Panel { width = "0%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 177, 128, 255, 255 }, to = { 91, 220, 255, 255 } }, borderRadius = 5, pointerEvents = "none" }
    local xpBar = UI.Panel { width = "100%", height = 10, marginTop = 6, backgroundColor = { 25, 40, 76, 220 }, borderRadius = 5, overflow = "hidden", children = { state.xpBarFill_ } }
    state.shellLabel_ = MakeLabel("", { fontSize = 11, fontColor = { 255, 213, 140, 255 }, marginTop = 5, opacity = 0 })
    state.shellBarFill_ = UI.Panel { width = "0%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 255, 213, 83, 255 }, to = { 255, 165, 80, 255 } }, borderRadius = 5, pointerEvents = "none" }
    local shellBar = UI.Panel { width = "100%", height = 8, marginTop = 4, backgroundColor = { 40, 35, 22, 220 }, borderRadius = 5, overflow = "hidden", opacity = 0, children = { state.shellBarFill_ } }
    local statusCard = UI.Panel { width = "44%", maxWidth = 420, padding = 12, backgroundColor = { 8, 20, 45, 215 }, borderColor = { 91, 153, 220, 150 }, borderWidth = 1, borderRadius = 14, children = { state.hudLabel_, state.xpLabel_, xpBar, state.shellLabel_, shellBar } }

    state.waveLabel_ = MakeLabel("", { fontSize = 14, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "right" })
    state.moduleLabel_ = MakeLabel("", { fontSize = 11, fontColor = { 207, 220, 244, 255 }, textAlign = "right", marginTop = 5 })
    state.feedbackLabel_ = MakeLabel("", { position = "absolute", top = 112, left = 0, right = 0, textAlign = "center", fontSize = 13, fontWeight = "bold", fontColor = { 255, 111, 126, 0 }, pointerEvents = "none" })
    local waveCard = UI.Panel { width = "38%", maxWidth = 360, padding = 12, alignItems = "flex-end", backgroundColor = { 8, 20, 45, 215 }, borderColor = { 146, 225, 191, 150 }, borderWidth = 1, borderRadius = 14, children = { state.waveLabel_, state.moduleLabel_ } }
    local hud = UI.Panel { position = "absolute", top = 14, left = 16, right = 16, flexDirection = "row", justifyContent = "space-between", pointerEvents = "none", children = { statusCard, waveCard } }

    state.joystickBase_ = UI.Panel { position = "absolute", width = state.touchRadius_ * 2, height = state.touchRadius_ * 2, backgroundColor = { 72, 133, 204, 90 }, borderColor = { 157, 220, 255, 170 }, borderWidth = 2, borderRadius = state.touchRadius_, pointerEvents = "none", visible = false }
    state.joystickKnob_ = UI.Panel { position = "absolute", width = 52, height = 52, backgroundColor = { 108, 220, 255, 210 }, borderColor = { 230, 252, 255, 230 }, borderWidth = 2, borderRadius = 26, pointerEvents = "none", visible = false }
    state.touchSurface_ = UI.Panel { position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "auto", onPointerDown = HandleTouchDown, onPointerMove = HandleTouchMove, onPointerUp = HandleTouchUp, onPointerCancel = HandleTouchUp, children = { state.joystickBase_, state.joystickKnob_ } }

    return UI.Panel { width = "100%", height = "100%", pointerEvents = "box-none", children = {
        state.gameWorld_, hud, state.feedbackLabel_,
        MakeLabel(state.T("game.hint"), { position = "absolute", bottom = 28, left = 0, right = 0, textAlign = "center", fontSize = 11, fontColor = { 131, 151, 190, 220 } }),
        MakeLabel(state.T("game.mobile_hint"), { position = "absolute", bottom = 10, left = 0, right = 0, textAlign = "center", fontSize = 10, fontColor = { 122, 190, 218, 230 } }),
        state.touchSurface_,
    } }
end

local function BuildUpgradeScreen()
    local cards = {}
    for index, card in ipairs(state.upgradeCards_) do
        cards[index] = UI.Button { text = card.title .. "\n" .. card.description, variant = index == 1 and "primary" or "secondary", width = "100%", minHeight = 72, marginBottom = 10, fontSize = 13, onClick = function() ApplyUpgrade(card.id); state.screen_ = "game"; BuildUI() end }
    end
    return UI.Panel { width = "90%", maxWidth = 520, padding = 24, gap = 8, backgroundColor = { 19, 30, 58, 250 }, borderRadius = 22, borderWidth = 1, borderColor = { 108, 172, 255, 220 }, children = {
        MakeLabel(state.T("game.level_up"), { fontSize = 23, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "center", marginBottom = 4 }),
        MakeLabel(state.T("game.level", state.level_), { fontSize = 14, fontColor = { 177, 196, 231, 255 }, textAlign = "center", marginBottom = 12 }),
        table.unpack(cards),
    } }
end

local function BuildWavePauseScreen()
    local remaining = math.max(0, state.levelGoal_ - state.levelProgress_)
    return UI.Panel { width = "90%", maxWidth = 520, padding = 28, gap = 14, alignItems = "center", backgroundColor = { 20, 39, 63, 250 }, borderRadius = 24, borderWidth = 1, borderColor = { 146, 225, 191, 200 }, children = {
        MakeLabel(state.T("game.wave_pause"), { fontSize = 25, fontWeight = "bold", fontColor = { 146, 225, 191, 255 }, textAlign = "center" }),
        MakeLabel(state.T("game.wave_next", state.wave_), { fontSize = 18, fontWeight = "bold", fontColor = { 255, 230, 137, 255 } }),
        UI.Panel { width = "100%", padding = 14, gap = 7, backgroundColor = { 9, 20, 43, 180 }, borderRadius = 12, children = {
            MakeLabel(state.T("game.stats"), { fontSize = 12, fontWeight = "bold", fontColor = { 146, 225, 191, 255 } }),
            MakeLabel(state.T("game.integrity", math.max(0, player_.integrity), player_.maxIntegrity), { fontSize = 14, fontColor = { 220, 235, 255, 255 } }),
            MakeLabel(state.T("game.level", state.level_) .. "  ·  " .. state.T("game.next_upgrade", remaining), { fontSize = 14, fontColor = { 183, 207, 242, 255 } }),
            MakeLabel(state.T("game.fragments", state.dataFragments_) .. "  ·  " .. state.T("game.score", state.score_), { fontSize = 14, fontColor = { 255, 230, 137, 255 } }),
        } },
        MakeLabel(state.T("game.modifier", state.T("modifier." .. state.modifier_)), { fontSize = 14, fontWeight = "bold", fontColor = { 255, 182, 105, 255 }, textAlign = "center" }),
        MakeLabel(state.T("game.modules", ActiveModuleText()), { fontSize = 13, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }),
        UI.Button { text = state.T("game.continue"), variant = "primary", width = "100%", height = 50, onClick = function() state.screen_ = "game"; state.modifier_ = ModifierForWave(state.wave_); state.surgeTimer_, state.waveTime_, state.waveSpawned_, state.spawnTimer_ = 2.5, 0, 0, 0; state.waveSpawnTarget_ = 8 + state.wave_ * 3; BuildUI() end },
    } }
end

local function BuildArchiveScreen()
    local canCalibrate = state.profile_.calibration > 0
    return UI.Panel { width = "90%", maxWidth = 440, padding = 26, gap = 12, alignItems = "center", backgroundColor = { 20, 31, 58, 250 }, borderRadius = 22, borderWidth = 1, borderColor = { 146, 225, 191, 200 }, children = {
        MakeLabel(state.T("meta.title"), { fontSize = 24, fontWeight = "bold", fontColor = { 146, 225, 191, 255 }, textAlign = "center" }),
        MakeLabel(state.T("meta.currency", state.profile_.calibration), { fontSize = 15, fontColor = { 255, 230, 137, 255 } }),
        MakeLabel(state.T("meta.fallback"), { fontSize = 11, fontColor = { 177, 196, 231, 255 }, textAlign = "center" }),
        UI.Button { text = state.T("meta.integrity"), variant = state.profile_.startingIntegrity > 0 and "secondary" or "primary", width = "100%", height = 48, onClick = function() if canCalibrate and state.profile_.startingIntegrity == 0 then state.profile_.startingIntegrity = 1; state.profile_.calibration = state.profile_.calibration - 1; BuildUI() end end },
        UI.Button { text = state.T("meta.magnet"), variant = state.profile_.magnet > 0 and "secondary" or "primary", width = "100%", height = 48, onClick = function() if canCalibrate and state.profile_.magnet == 0 then state.profile_.magnet = 1; state.profile_.calibration = state.profile_.calibration - 1; BuildUI() end end },
        UI.Button { text = state.T("meta.close"), variant = "secondary", width = "100%", height = 44, onClick = function() state.screen_ = state.metaScreenReturn_; BuildUI() end },
    } }
end

local function BuildSummaryScreen()
    return UI.Panel { width = "90%", maxWidth = 450, padding = 28, gap = 12, alignItems = "center", backgroundColor = { 30, 24, 54, 250 }, borderRadius = 24, borderWidth = 1, borderColor = { 231, 109, 143, 200 }, children = {
        MakeLabel(state.T("game.defeated"), { fontSize = 28, fontWeight = "bold", fontColor = { 255, 150, 170, 255 }, textAlign = "center" }),
        MakeLabel(state.T("game.summary"), { fontSize = 16, fontColor = { 210, 201, 231, 255 } }),
        MakeLabel(state.T("game.reason", state.defeatReason_), { fontSize = 13, fontColor = { 210, 201, 231, 255 }, textAlign = "center" }),
        MakeLabel(state.T("game.final_wave", state.wave_), { fontSize = 16, fontColor = { 177, 196, 231, 255 } }),
        MakeLabel(state.T("game.final_score", state.score_), { fontSize = 16, fontColor = { 255, 230, 137, 255 } }),
        MakeLabel(state.T("game.final_level", state.level_), { fontSize = 16, fontColor = { 146, 225, 191, 255 } }),
        MakeLabel(state.T("game.modules", ActiveModuleText()), { fontSize = 14, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }),
        MakeLabel(state.T("game.final_fragments", state.dataFragments_), { fontSize = 14, fontColor = { 207, 220, 244, 255 } }),
        MakeLabel(state.T("meta.currency", state.profile_.calibration), { fontSize = 13, fontColor = { 255, 230, 137, 255 } }),
        UI.Button { text = state.T("meta.archive"), variant = "secondary", width = "100%", height = 44, onClick = function() state.metaScreenReturn_ = "summary"; state.screen_ = "archive"; BuildUI() end },
        UI.Button { text = state.T("game.restart"), variant = "primary", width = "100%", height = 48, onClick = function() state.screen_ = "game"; ResetRunState(); BuildUI() end },
        UI.Button { text = state.T("game.back"), variant = "secondary", width = "100%", height = 44, onClick = function() state.screen_ = "language"; BuildUI() end },
    } }
end

function BuildUI()
    ---@type Widget|nil
    local content = nil
    if state.screen_ == "language" then content = BuildLanguageScreen()
    elseif state.screen_ == "game" then content = BuildGameScreen()
    elseif state.screen_ == "upgrade" then content = BuildUpgradeScreen()
    elseif state.screen_ == "wave_pause" then content = BuildWavePauseScreen()
    elseif state.screen_ == "archive" then content = BuildArchiveScreen()
    else content = BuildSummaryScreen() end
    local rootProps = { width = "100%", height = "100%", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 8, 18, 42, 255 }, to = { 35, 20, 68, 255 } }, pointerEvents = "box-none", children = { content } }
    if state.screen_ ~= "game" then
        rootProps.justifyContent = "center"
        rootProps.alignItems = "center"
        rootProps.padding = 16
    end
    state.uiRoot_ = UI.Panel(rootProps)
    UI.SetRoot(state.uiRoot_, true)
    if state.screen_ == "game" then SetWidgetPosition(state.playerWidget_, player_.x, player_.y, 32) end
end

local function SpawnPickup(x, y, kind, amount)
    if not state.gameWorld_ then return end
    local color = kind == "data" and { 255, 214, 92, 255 } or { 175, 128, 255, 255 }
    local widget = UI.Panel { position = "absolute", width = kind == "data" and 10 or 13, height = kind == "data" and 10 or 13, backgroundColor = color, borderColor = { 255, 255, 255, 220 }, borderWidth = 1, borderRadius = 6, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.pickups_, { x = x, y = y, kind = kind, amount = amount, radius = kind == "data" and 5 or 7, widget = widget })
end

local function EnemyKindForId(enemyId, wave)
    local cycle = (enemyId + wave) % 3
    if cycle == 0 then return "chaser" end
    if cycle == 1 then return "skimmer" end
    return "charger"
end

local function SpawnEnemy(elite)
    if not state.gameWorld_ or #state.enemies_ >= 24 or state.waveSpawned_ >= state.waveSpawnTarget_ then return end
    state.enemyId_ = state.enemyId_ + 1; state.waveSpawned_ = state.waveSpawned_ + 1
    local side = (state.enemyId_ - 1) % 4
    ---@type number
    local x = 0
    ---@type number
    local y = 0
    if side == 0 then x, y = -30, math.random(30, math.max(31, math.floor(state.worldHeight_ - 30)))
    elseif side == 1 then x, y = state.worldWidth_ + 30, math.random(30, math.max(31, math.floor(state.worldHeight_ - 30)))
    elseif side == 2 then x, y = math.random(30, math.max(31, math.floor(state.worldWidth_ - 30))), -30
    else x, y = math.random(30, math.max(31, math.floor(state.worldWidth_ - 30))), state.worldHeight_ + 30 end
    local kind = elite and "elite" or EnemyKindForId(state.enemyId_, state.wave_)
    local size = elite and 38 or (kind == "charger" and 28 or 24)
    local color = elite and { 255, 126, 63, 255 } or (kind == "skimmer" and { 84, 216, 194, 255 } or kind == "charger" and { 255, 168, 76, 255 } or { 244, 93, 133, 255 })
    local widget = UI.Panel { position = "absolute", width = size, height = size, backgroundColor = color, borderColor = elite and { 255, 239, 164, 255 } or { 255, 220, 150, 255 }, borderWidth = elite and 3 or 2, borderRadius = kind == "skimmer" and size * 0.5 or (elite and 18 or 8), pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.enemies_, { x = x, y = y, radius = size * 0.5, speed = (elite and 38 or kind == "skimmer" and 46 or kind == "charger" and 40 or 52) + state.wave_ * 3, integrity = (elite and 12 or 2) + state.wave_, widget = widget, elite = elite, kind = kind, phase = 0, charge = 0, telegraph = 0, dead = false })
end

local function FindNearestEnemy()
    local nearest, distanceBest = nil, math.huge
    for _, enemy in ipairs(state.enemies_) do
        local dx, dy = enemy.x - player_.x, enemy.y - player_.y; local distance = dx * dx + dy * dy
        if distance < distanceBest then nearest, distanceBest = enemy, distance end
    end
    return nearest
end

local function FireTraceBeam()
    local target = FindNearestEnemy(); if not target or not state.gameWorld_ then return end
    local dx, dy = target.x - player_.x, target.y - player_.y; local length = math.sqrt(dx * dx + dy * dy); if length <= 0 then return end
    local widget = UI.Panel { position = "absolute", width = 11, height = 11, backgroundColor = { 255, 224, 99, 255 }, borderRadius = 6, pointerEvents = "none" }; state.gameWorld_:AddChild(widget)
    table.insert(state.projectiles_, { x = player_.x, y = player_.y, vx = dx / length * (430 + state.moduleLevels_.trace * 35), vy = dy / length * (430 + state.moduleLevels_.trace * 35), radius = 5, damage = player_.damage + state.moduleLevels_.trace, life = 1.4, pierce = state.moduleLevels_.trace >= 3 and 2 or 1, widget = widget })
end

local function DamageEnemy(enemy, amount)
    if not enemy or enemy.dead then return end
    enemy.integrity = enemy.integrity - amount
    if enemy.integrity > 0 then return end
    enemy.dead = true
    local reward = state.modifier_ == "overclock" and 2 or 1
    state.score_ = state.score_ + (enemy.elite and 8 or 1); SpawnPickup(enemy.x, enemy.y, "data", (enemy.elite and 3 or 1) * reward); SpawnPickup(enemy.x + 8, enemy.y, "shard", enemy.elite and 3 or 1)
    DestroyEntityWidget(enemy.widget)
end

local function CleanupDeadEnemies()
    for index = #state.enemies_, 1, -1 do
        if state.enemies_[index].dead then table.remove(state.enemies_, index) end
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
        return
    end
    player_.shellRechargeTimer = 0
    player_.integrity = player_.integrity - 1; player_.invulnerable = 0.65
    if player_.integrity <= 0 then state.defeatReason_ = state.T("game.reason_contact"); if not state.summaryAwarded_ then state.profile_.calibration = state.profile_.calibration + math.max(1, math.floor(state.dataFragments_ / 8)); state.summaryAwarded_ = true end; state.screen_ = "summary"; ClearEntities(); BuildUI() end
end

local function UpdateMovement(timeStep)
    ---@type number
    local dx = 0
    ---@type number
    local dy = 0
    if state.touchActive_ then
        dx, dy = state.touchX_ - state.touchStartX_, state.touchY_ - state.touchStartY_
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then
            dx, dy = dx / math.max(distance, state.touchRadius_), dy / math.max(distance, state.touchRadius_)
        end
    else
        if state.keys_[KEY_A] or state.keys_[KEY_LEFT] then dx = dx - 1 end; if state.keys_[KEY_D] or state.keys_[KEY_RIGHT] then dx = dx + 1 end
        if state.keys_[KEY_W] or state.keys_[KEY_UP] then dy = dy - 1 end; if state.keys_[KEY_S] or state.keys_[KEY_DOWN] then dy = dy + 1 end
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then dx, dy = dx / length, dy / length end
    end
    if dx ~= 0 or dy ~= 0 then player_.x = player_.x + dx * player_.speed * timeStep; player_.y = player_.y + dy * player_.speed * timeStep end
    local bound = state.modifier_ == "compression" and 70 or player_.radius
    player_.x = math.max(bound, math.min(state.worldWidth_ - bound, player_.x)); player_.y = math.max(bound, math.min(state.worldHeight_ - bound, player_.y)); SetWidgetPosition(state.playerWidget_, player_.x, player_.y, 32)
end

local function UpdateEnemies(timeStep)
    local bound = state.modifier_ == "compression" and 70 or 0
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead then
            local dx, dy = player_.x - enemy.x, player_.y - enemy.y; local distance = math.sqrt(dx * dx + dy * dy)
            enemy.phase = enemy.phase + timeStep
            if enemy.kind == "skimmer" then
                local tangentX, tangentY = -dy / math.max(distance, 1), dx / math.max(distance, 1)
                dx, dy = dx + tangentX * 90, dy + tangentY * 90
            elseif enemy.kind == "charger" then
                if enemy.charge <= 0 then enemy.charge = 2.1; enemy.telegraph = 0.45 end
                if enemy.telegraph > 0 then enemy.telegraph = enemy.telegraph - timeStep
                else enemy.charge = enemy.charge - timeStep; enemy.speed = 165 + state.wave_ * 5 end
            end
            if distance > 0 and (enemy.kind ~= "charger" or enemy.telegraph <= 0) then enemy.x = enemy.x + dx / math.max(distance, 1) * enemy.speed * (state.modifier_ == "overclock" and 1.25 or 1) * timeStep; enemy.y = enemy.y + dy / math.max(distance, 1) * enemy.speed * (state.modifier_ == "overclock" and 1.25 or 1) * timeStep end
            if bound > 0 then enemy.x = math.max(bound, math.min(state.worldWidth_ - bound, enemy.x)); enemy.y = math.max(bound, math.min(state.worldHeight_ - bound, enemy.y)) end
            if enemy.telegraph > 0 then enemy.widget:SetStyle({ backgroundColor = { 255, 245, 110, 255 }, borderColor = { 255, 70, 80, 255 }, scale = 1.2 }) else enemy.widget:SetStyle({ scale = 1.0 }) end
            SetWidgetPosition(enemy.widget, enemy.x, enemy.y, enemy.elite and 38 or (enemy.kind == "charger" and 28 or 24))
            if distance < player_.radius + enemy.radius then
                DamagePlayer()
                if state.screen_ ~= "game" then return end
                enemy.x = enemy.x - dx / math.max(distance, 1) * 22; enemy.y = enemy.y - dy / math.max(distance, 1) * 22
            end
        end
    end
    CleanupDeadEnemies()
end

local function UpdateProjectiles(timeStep)
    for projectileIndex = #state.projectiles_, 1, -1 do
        local projectile = state.projectiles_[projectileIndex]; projectile.x = projectile.x + projectile.vx * timeStep; projectile.y = projectile.y + projectile.vy * timeStep; projectile.life = projectile.life - timeStep; local remove = projectile.life <= 0
        for enemyIndex = #state.enemies_, 1, -1 do
            local enemy = state.enemies_[enemyIndex]
            if not enemy then break end
            local dx, dy = enemy.x - projectile.x, enemy.y - projectile.y
            if dx * dx + dy * dy < (enemy.radius + projectile.radius) ^ 2 then DamageEnemy(enemy, projectile.damage); projectile.pierce = projectile.pierce - 1; remove = projectile.pierce <= 0; if remove then break end end
        end
        if remove then DestroyEntityWidget(projectile.widget); table.remove(state.projectiles_, projectileIndex) else SetWidgetPosition(projectile.widget, projectile.x, projectile.y, 10) end
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

local function UpdateOrbit(timeStep)
    if not IsModuleActive("orbit") or not state.gameWorld_ then return end
    player_.orbitAngle = player_.orbitAngle + 2.8 * timeStep
    local count = state.moduleLevels_.orbit >= 3 and 2 or 1
    for node = 1, count do
        local angle = player_.orbitAngle + (node - 1) * math.pi
        local ox, oy = player_.x + math.cos(angle) * 42, player_.y + math.sin(angle) * 42
        ---@type Widget|nil
        local widget = node == 1 and state.orbitWidget_ or state.orbitWidget2_
        if not widget then widget = UI.Panel { position = "absolute", width = 16, height = 16, backgroundColor = { 190, 139, 255, 255 }, borderRadius = 8, pointerEvents = "none" }; state.gameWorld_:AddChild(widget); if node == 1 then state.orbitWidget_ = widget else state.orbitWidget2_ = widget end end
        SetWidgetPosition(widget, ox, oy, 16)
        for _, enemy in ipairs(state.enemies_) do local dx, dy = enemy.x - ox, enemy.y - oy; if dx * dx + dy * dy < (enemy.radius + 9) ^ 2 then DamageEnemy(enemy, 0.04 + state.moduleLevels_.orbit * 0.02) end end
    end
end

local function PulseBloom()
    if not IsModuleActive("pulse") then return end
    local radius = 105 + state.moduleLevels_.pulse * 10
    for _, enemy in ipairs(state.enemies_) do
        if not enemy.dead then local dx, dy = enemy.x - player_.x, enemy.y - player_.y; local distance = math.sqrt(dx * dx + dy * dy); if distance < radius then DamageEnemy(enemy, 2 + state.moduleLevels_.pulse); if distance > 0 then enemy.x = enemy.x + dx / distance * 30; enemy.y = enemy.y + dy / distance * 30 end end end
    end
    if state.moduleLevels_.pulse >= 3 then state.surgeFlash_ = 0.25 end
end

local function UpdateShell(timeStep)
    if not IsModuleActive("shell") or not state.gameWorld_ then return end
    if player_.maxShell <= 0 then
        player_.maxShell = 2 + state.moduleLevels_.shell
        player_.shell = player_.maxShell
    end
    player_.shellRechargeTimer = player_.shellRechargeTimer + timeStep
    player_.shellFlash = math.max(0, player_.shellFlash - timeStep * 4)
    if player_.shell >= player_.maxShell then return end
    local rechargeDelay = math.max(0.8, 2.6 - state.moduleLevels_.shell * 0.3)
    if player_.shellRechargeTimer < rechargeDelay then return end
    local rechargeRate = 0.8 + state.moduleLevels_.shell * 0.2
    if state.moduleLevels_.shell >= 3 then rechargeRate = rechargeRate + 0.4 end
    player_.shell = math.min(player_.maxShell, player_.shell + rechargeRate * timeStep)
end

local function UpdateShellVisual()
    if not state.shellRing_ then return end
    if not IsModuleActive("shell") or player_.maxShell <= 0 or player_.shell <= 0 then
        if state.shellRing_:IsVisible() then state.shellRing_:SetVisible(false) end
        return
    end
    if not state.shellRing_:IsVisible() then state.shellRing_:SetVisible(true) end
    SetWidgetPosition(state.shellRing_, player_.x, player_.y, 44)
    local ratio = player_.shell / player_.maxShell
    local flash = player_.shellFlash
    local alpha = math.floor(50 + ratio * 180)
    local flashBoost = flash > 0 and math.min(42, math.floor(flash * 200)) or 0
    state.shellRing_:SetStyle({
        borderColor = { 255, math.min(255, 213 + flashBoost), 83, alpha },
        opacity = 0.4 + 0.5 * ratio + flash * 0.6,
    })
end

local function PlaceMine()
    local level = state.moduleLevels_.mine
    local widget = UI.Panel { position = "absolute", width = 12, height = 12, backgroundColor = { 180, 130, 60, 180 }, borderColor = { 255, 200, 100, 220 }, borderWidth = 2, borderRadius = 6, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.mines_, {
        x = player_.x, y = player_.y, age = 0, armed = false,
        triggerRadius = 35 + level * 3, blastRadius = 50 + level * 6,
        damage = 2 + level * 0.6, lifetime = 8.0, widget = widget,
    })
end

local function UpdateMines(timeStep)
    if not IsModuleActive("mine") or not state.gameWorld_ then return end
    local level = state.moduleLevels_.mine
    local maxMines = level >= 5 and 2 or 1
    player_.mineCooldown = math.max(0, player_.mineCooldown - timeStep)
    if player_.mineCooldown <= 0 and #state.mines_ < maxMines then
        PlaceMine()
        player_.mineCooldown = math.max(1.5, 4.0 - level * 0.4)
    end
    local armDelay = level >= 3 and 0.15 or 0.3
    for index = #state.mines_, 1, -1 do
        local mine = state.mines_[index]
        mine.age = mine.age + timeStep
        if mine.age >= mine.lifetime then
            DestroyEntityWidget(mine.widget)
            table.remove(state.mines_, index)
        else
            if mine.age < armDelay then
                mine.widget:SetStyle({ backgroundColor = { 160, 110, 50, 180 }, borderColor = { 200, 160, 80, 200 } })
            else
                if not mine.armed then mine.armed = true end
                local pulse = 0.65 + 0.35 * math.sin(mine.age * 7)
                mine.widget:SetStyle({
                    backgroundColor = { 255, math.floor(140 + 60 * pulse), math.floor(50 + 30 * pulse), math.floor(180 + 60 * pulse) },
                    borderColor = { 255, 230, 100, math.floor(220 + 35 * pulse) },
                })
                for _, enemy in ipairs(state.enemies_) do
                    if not enemy.dead then
                        local dx, dy = enemy.x - mine.x, enemy.y - mine.y
                        if dx * dx + dy * dy < mine.triggerRadius * mine.triggerRadius then
                            for _, victim in ipairs(state.enemies_) do
                                if not victim.dead then
                                    local vdx, vdy = victim.x - mine.x, victim.y - mine.y
                                    if vdx * vdx + vdy * vdy < mine.blastRadius * mine.blastRadius then
                                        DamageEnemy(victim, mine.damage)
                                    end
                                end
                            end
                            DestroyEntityWidget(mine.widget)
                            table.remove(state.mines_, index)
                            break
                        end
                    end
                end
            end
            SetWidgetPosition(mine.widget, mine.x, mine.y, 12)
        end
    end
end

local function AddTrailPoint()
    local level = state.moduleLevels_.hook
    local widget = UI.Panel { position = "absolute", width = 8, height = 8, backgroundColor = { 100, 200, 255, 220 }, borderColor = { 200, 240, 255, 180 }, borderWidth = 1, borderRadius = 4, pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.trail_, {
        x = player_.x, y = player_.y, age = 0,
        lifetime = 0.6 + level * 0.2, radius = 8 + level * 0.5,
        damagePerSec = 2 + level * 0.8, widget = widget,
    })
end

local function UpdateTrail(timeStep)
    if not IsModuleActive("hook") or not state.gameWorld_ then return end
    local interval = math.max(0.04, 0.10 - state.moduleLevels_.hook * 0.012)
    player_.trailTimer = player_.trailTimer + timeStep
    if player_.trailTimer >= interval then
        player_.trailTimer = player_.trailTimer - interval
        AddTrailPoint()
    end
    for index = #state.trail_, 1, -1 do
        local point = state.trail_[index]
        point.age = point.age + timeStep
        if point.age >= point.lifetime then
            DestroyEntityWidget(point.widget)
            table.remove(state.trail_, index)
        else
            local fade = 1.0 - point.age / point.lifetime
            local dmg = point.damagePerSec * timeStep
            for _, enemy in ipairs(state.enemies_) do
                if not enemy.dead then
                    local dx, dy = enemy.x - point.x, enemy.y - point.y
                    local combined = point.radius + enemy.radius
                    if dx * dx + dy * dy < combined * combined then
                        DamageEnemy(enemy, dmg)
                    end
                end
            end
            point.widget:SetStyle({
                opacity = fade * 0.85,
                backgroundColor = { 100, 200, 255, math.floor(220 * fade) },
                borderColor = { 200, 240, 255, math.floor(180 * fade) },
            })
            SetWidgetPosition(point.widget, point.x, point.y, 8)
        end
    end
end

function ApplyUpgrade(id)
    if id == "trace" or id == "orbit" or id == "pulse" or id == "shell" or id == "mine" or id == "hook" then
        state.activeModules_[id] = true; state.moduleLevels_[id] = math.min(5, state.moduleLevels_[id] + 1); state.chosenModule_ = id; state.moduleLevel_ = state.moduleLevels_[id]
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

local function UpdateHUD()
    if state.hudLabel_ then state.hudLabel_:SetText(state.T("game.integrity", math.max(0, player_.integrity), player_.maxIntegrity) .. "  |  " .. state.T("game.score", state.score_) .. "  |  " .. state.T("game.fragments", state.dataFragments_)) end
    if state.xpLabel_ then state.xpLabel_:SetText(state.T("game.level", state.level_) .. "  ·  " .. state.T("game.next_upgrade", math.max(0, state.levelGoal_ - state.levelProgress_))) end
    if state.xpBarFill_ then state.xpBarFill_:SetStyle({ width = tostring(math.floor(math.min(1, state.levelProgress_ / math.max(1, state.levelGoal_)) * 100)) .. "%" }) end
    if state.waveLabel_ then state.waveLabel_:SetText(state.T("game.wave", state.wave_, state.maxWaves_) .. "\n" .. state.T("game.time", math.floor(state.runTime_)) .. "\n" .. state.T("game.modifier", state.T("modifier." .. state.modifier_))) end
    if state.moduleLabel_ then state.moduleLabel_:SetText(state.T("game.modules", ActiveModuleText())) end
    if state.feedbackLabel_ then state.feedbackLabel_:SetStyle({ opacity = state.surgeFlash_ > 0 and 1 or 0 }); state.feedbackLabel_:SetText(state.surgeFlash_ > 0 and state.T("game.telegraph") or "") end
    if state.shellLabel_ then
        local shellActive = IsModuleActive("shell") and player_.maxShell > 0
        if shellActive then
            state.shellLabel_:SetText(state.T("game.shell", math.ceil(player_.shell), player_.maxShell))
            state.shellLabel_:SetStyle({ opacity = 1 })
        else
            state.shellLabel_:SetText("")
            state.shellLabel_:SetStyle({ opacity = 0 })
        end
    end
    if state.shellBarFill_ then
        local ratio = player_.maxShell > 0 and math.min(1, player_.shell / player_.maxShell) or 0
        state.shellBarFill_:SetStyle({ width = tostring(math.floor(ratio * 100)) .. "%" })
    end
end

local function EndWave()
    ClearEntities()
    if state.wave_ >= state.maxWaves_ then state.defeatReason_ = state.T("game.reason_complete"); if not state.summaryAwarded_ then state.profile_.calibration = state.profile_.calibration + math.max(1, math.floor(state.dataFragments_ / 8)); state.summaryAwarded_ = true end; state.screen_ = "summary"; BuildUI(); return end
    state.wave_ = state.wave_ + 1; state.screen_ = "wave_pause"; state.wavePauseTimer_ = 0; BuildUI()
end

function HandleUpdate(_eventType, eventData)
    if state.screen_ ~= "game" then return end
    local timeStep = math.min(eventData["TimeStep"]:GetFloat(), 0.05); state.runTime_ = state.runTime_ + timeStep; state.waveTime_ = state.waveTime_ + timeStep
    player_.invulnerable = math.max(0, player_.invulnerable - timeStep); player_.fireTimer = player_.fireTimer - timeStep; player_.pulseTimer = player_.pulseTimer - timeStep; state.spawnTimer_ = state.spawnTimer_ - timeStep; state.surgeFlash_ = math.max(0, state.surgeFlash_ - timeStep)
    if state.modifier_ == "surge" then state.surgeTimer_ = state.surgeTimer_ - timeStep; if state.surgeTimer_ <= 0 then state.surgeTimer_ = 4.0; state.surgeFlash_ = 0.55; for _, enemy in ipairs(state.enemies_) do if not enemy.dead then DamageEnemy(enemy, 1); end end end end
    UpdateMovement(timeStep)
    if state.waveSpawned_ == 0 and state.wave_ % 3 == 0 then SpawnEnemy(true) end
    if state.spawnTimer_ <= 0 and state.waveSpawned_ < state.waveSpawnTarget_ and state.waveTime_ < state.waveDuration_ then SpawnEnemy(false); state.spawnTimer_ = math.max(0.35, 0.9 - state.wave_ * 0.05) end
    if IsModuleActive("trace") and player_.fireTimer <= 0 then FireTraceBeam(); player_.fireTimer = math.max(0.18, 0.42 - state.moduleLevels_.trace * 0.04) end
    if IsModuleActive("pulse") and player_.pulseTimer <= 0 then PulseBloom(); player_.pulseTimer = math.max(1.4, 3.0 - state.moduleLevels_.pulse * 0.25) end
    UpdateShell(timeStep)
    UpdateEnemies(timeStep)
    if not IsGameScreen() then return end
    UpdateProjectiles(timeStep); UpdatePickups(timeStep)
    if not IsGameScreen() then return end
    UpdateOrbit(timeStep)
    UpdateShellVisual()
    UpdateMines(timeStep)
    UpdateTrail(timeStep)
    if state.waveTime_ >= state.waveDuration_ and state.waveSpawned_ >= state.waveSpawnTarget_ and #state.enemies_ == 0 then EndWave() else UpdateHUD() end
end

function HandleKeyDown(_eventType, eventData)
    local key = eventData["Key"]:GetInt(); state.keys_[key] = true
    if key == KEY_ESCAPE and state.screen_ == "game" then state.screen_ = "language"; ClearEntities(); BuildUI() end
end

function HandleKeyUp(_eventType, eventData)
    local key = eventData["Key"]:GetInt(); state.keys_[key] = false
end

function Start()
    graphics.windowTitle = "Geometry Breakout / 几何突围"; UI.Init({ theme = "default-dark", fonts = { { family = "sans", weights = { normal = "Fonts/MiSans-Regular.ttf" } } }, scale = UI.Scale.DEFAULT })
    input.mouseMode = MM_ABSOLUTE; input.mouseVisible = true
    SubscribeToEvent("Update", "HandleUpdate"); SubscribeToEvent("KeyDown", "HandleKeyDown"); SubscribeToEvent("KeyUp", "HandleKeyUp"); BuildUI()
    print("=== Geometry Breakout Prototype 03 started ===")
end

function Stop()
    ClearEntities(); UI.Shutdown()
end
