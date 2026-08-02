-- Geometry Breakout / 几何突围
-- Prototype 03: pickups, progression, wave pacing, modules, elite, and run summary.

local UI = require("urhox-libs/UI")

---@type string
local language_ = "zh_CN"
---@type string
local screen_ = "language"
---@type Widget|nil
local uiRoot_ = nil
---@type Widget|nil
local gameWorld_ = nil
---@type Widget|nil
local playerWidget_ = nil
---@type Label|nil
local hudLabel_ = nil
---@type Label|nil
local waveLabel_ = nil
---@type Label|nil
local xpLabel_ = nil
---@type Widget|nil
local xpBarFill_ = nil
---@type Label|nil
local moduleLabel_ = nil
---@type Label|nil
local feedbackLabel_ = nil
---@type table<number, boolean>
local keys_ = {}
---@type table
local enemies_ = {}
---@type table
local projectiles_ = {}
---@type table
local pickups_ = {}
---@type table<string, number>
local moduleLevels_ = { trace = 1, orbit = 0, pulse = 0 }
---@type table<string, boolean>
local activeModules_ = { trace = true, orbit = false, pulse = false }
local modifier_ = "compression"
---@type number
local surgeTimer_ = 0
---@type number
local surgeFlash_ = 0
local metaScreenReturn_ = "language"
---@class MetaProfile
---@field calibration number
---@field startingIntegrity number
---@field magnet number
---@type MetaProfile
local profile_ = { calibration = 0, startingIntegrity = 0, magnet = 0 } -- session fallback: no verified storage API
local summaryAwarded_ = false
---@type Widget|nil
local orbitWidget_ = nil
---@type Widget|nil
local orbitWidget2_ = nil
---@type Widget|nil
local touchSurface_ = nil
---@type Widget|nil
local joystickBase_ = nil
---@type Widget|nil
local joystickKnob_ = nil
---@type number|nil
local touchPointerId_ = nil
local touchActive_ = false
---@type number
local touchStartX_ = 0
---@type number
local touchStartY_ = 0
---@type number
local touchX_ = 0
---@type number
local touchY_ = 0
---@type number
local touchRadius_ = 72
---@type number
local worldWidth_ = 800
---@type number
local worldHeight_ = 600
---@type number
local runTime_ = 0
---@type number
local waveTime_ = 0
---@type number
local spawnTimer_ = 0
---@type number
local enemyId_ = 0
---@type number
local score_ = 0
---@type number
local dataFragments_ = 0
---@type number
local patternShards_ = 0
---@type number
local level_ = 1
---@type number
local levelProgress_ = 0
---@type number
local levelGoal_ = 5
---@type number
local wave_ = 1
---@type number
local maxWaves_ = 6
---@type number
local waveDuration_ = 18
---@type number
local waveSpawned_ = 0
---@type number
local waveSpawnTarget_ = 10
---@type number
local wavePauseTimer_ = 0
---@type number
local eliteCount_ = 0
---@type string
local defeatReason_ = ""
local chosenModule_ = ""
---@type number
local moduleLevel_ = 0
local upgradeCards_ = {}

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
---@type PlayerState
local player_ = {
    x = 0, y = 0, radius = 16, speed = 220,
    integrity = 5, maxIntegrity = 5, invulnerable = 0,
    fireTimer = 0, pulseTimer = 0, orbitAngle = 0,
    magnetRadius = 110, damage = 1,
}

---@type table<string, table<string, string>>
local TEXT = {
    zh_CN = {
        ["menu.title"] = "几何突围", ["menu.subtitle"] = "选择语言开始游戏",
        ["language.english"] = "English", ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "校准台已上线，准备开始突围。", ["menu.start"] = "开始突围",
        ["menu.footer"] = "几何突围 · Prototype 03", ["game.integrity"] = "完整度：%d / %d",
        ["game.time"] = "突围时间：%ds", ["game.score"] = "击破：%d", ["game.wave"] = "波次：%d / %d",
        ["game.progress"] = "模式碎片：%d / %d", ["game.fragments"] = "数据碎片：%d", ["game.next_upgrade"] = "距离下一次升级：%d 个模式碎片", ["game.stats"] = "当前状态",
        ["game.module"] = "模块：%s Lv.%d", ["game.none"] = "未装配", ["game.enemy"] = "敌对几何体",
        ["game.elite"] = "精英核心", ["game.hint"] = "WASD / 方向键移动 · 自动模块锁定目标", ["game.mobile_hint"] = "触摸左侧并拖动移动 · 自动攻击",

        ["game.wave_pause"] = "波次校准完成", ["game.wave_next"] = "下一波：%d", ["game.continue"] = "继续突围",
        ["game.level_up"] = "升级：选择一项校准", ["game.level"] = "等级 %d",
        ["module.trace"] = "Trace Beam · 轨迹光束", ["module.trace_desc"] = "更快、更强的窄束自动追踪光束",
        ["module.orbit"] = "Orbit Seed · 环轨种子", ["module.orbit_desc"] = "旋转种子持续撞击附近敌人",
        ["module.pulse"] = "Pulse Bloom · 脉冲绽放", ["module.pulse_desc"] = "周期性释放圆形脉冲，击退并伤害敌人",
        ["upgrade.trace"] = "强化轨迹光束", ["upgrade.orbit"] = "强化环轨种子", ["upgrade.pulse"] = "强化脉冲绽放",
        ["upgrade.integrity"] = "加固完整度", ["upgrade.magnet"] = "扩大磁吸范围", ["upgrade.desc"] = "获得一项永久运行强化",
        ["game.defeated"] = "突围失败", ["game.summary"] = "运行总结", ["game.reason"] = "原因：%s",
        ["game.final_score"] = "最终击破：%d", ["game.final_wave"] = "抵达波次：%d", ["game.final_level"] = "最终等级：%d",
        ["game.final_module"] = "装配模块：%s Lv.%d", ["game.final_fragments"] = "数据碎片：%d",
        ["game.restart"] = "重新开始", ["game.back"] = "返回语言选择", ["game.reason_contact"] = "与敌对几何体发生碰撞", ["game.reason_complete"] = "完成全部波次",
        ["game.modifier"] = "场域：%s", ["modifier.compression"] = "压缩：内圈移动边界", ["modifier.surge"] = "涌潮：周期性场域脉冲", ["modifier.overclock"] = "超频：敌人更快，奖励更高",
        ["enemy.chaser"] = "追猎体", ["enemy.skimmer"] = "掠行体", ["enemy.charger"] = "蓄能体", ["game.modules"] = "活动模块：%s", ["game.telegraph"] = "警告：场域脉冲",
        ["meta.archive"] = "校准档案", ["meta.title"] = "校准档案（本次会话）", ["meta.currency"] = "校准片：%d", ["meta.integrity"] = "起始完整度 +1", ["meta.magnet"] = "磁吸范围 +35", ["meta.upgrade"] = "校准", ["meta.fallback"] = "未验证持久化：仅在本次会话有效", ["meta.close"] = "返回",
    },
    en = {
        ["menu.title"] = "Geometry Breakout", ["menu.subtitle"] = "Choose your language to begin",
        ["language.english"] = "English", ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "Calibration deck online. Ready to break out.", ["menu.start"] = "Start Breakout",
        ["menu.footer"] = "Geometry Breakout · Prototype 03", ["game.integrity"] = "Integrity: %d / %d",
        ["game.time"] = "Breakout time: %ds", ["game.score"] = "Defeated: %d", ["game.wave"] = "Wave: %d / %d",
        ["game.progress"] = "Pattern Shards: %d / %d", ["game.fragments"] = "Data Fragments: %d", ["game.next_upgrade"] = "%d Pattern Shards to next upgrade", ["game.stats"] = "Current status",
        ["game.module"] = "Module: %s Lv.%d", ["game.none"] = "Unassigned", ["game.enemy"] = "Hostile Form",
        ["game.elite"] = "Elite Core", ["game.hint"] = "WASD / arrows to move · module auto-locks targets", ["game.mobile_hint"] = "Touch and drag on the left side to move · auto-attacks",

        ["game.wave_pause"] = "Wave calibrated", ["game.wave_next"] = "Next wave: %d", ["game.continue"] = "Continue Breakout",
        ["game.level_up"] = "Level up: choose a calibration", ["game.level"] = "Level %d",
        ["module.trace"] = "Trace Beam", ["module.trace_desc"] = "A faster, stronger narrow auto-tracking beam",
        ["module.orbit"] = "Orbit Seed", ["module.orbit_desc"] = "A rotating seed that strikes nearby enemies",
        ["module.pulse"] = "Pulse Bloom", ["module.pulse_desc"] = "A periodic circular pulse that damages and pushes enemies",
        ["upgrade.trace"] = "Tune Trace Beam", ["upgrade.orbit"] = "Tune Orbit Seed", ["upgrade.pulse"] = "Tune Pulse Bloom",
        ["upgrade.integrity"] = "Reinforce Integrity", ["upgrade.magnet"] = "Expand Magnet", ["upgrade.desc"] = "Gain one permanent run upgrade",
        ["game.defeated"] = "Breakout Failed", ["game.summary"] = "Run Summary", ["game.reason"] = "Cause: %s",
        ["game.final_score"] = "Final defeated: %d", ["game.final_wave"] = "Wave reached: %d", ["game.final_level"] = "Final level: %d",
        ["game.final_module"] = "Equipped module: %s Lv.%d", ["game.final_fragments"] = "Data Fragments: %d",
        ["game.restart"] = "Restart", ["game.back"] = "Back to language selection", ["game.reason_contact"] = "Collision with a hostile form", ["game.reason_complete"] = "All waves completed",
        ["game.modifier"] = "Field: %s", ["modifier.compression"] = "Compression: inner movement bounds", ["modifier.surge"] = "Surge: periodic arena pulse", ["modifier.overclock"] = "Overclock: faster enemies, richer drops",
        ["enemy.chaser"] = "Chaser", ["enemy.skimmer"] = "Skimmer", ["enemy.charger"] = "Charger", ["game.modules"] = "Active modules: %s", ["game.telegraph"] = "WARNING: arena surge",
        ["meta.archive"] = "Calibration Archive", ["meta.title"] = "Calibration Archive (session)", ["meta.currency"] = "Calibration: %d", ["meta.integrity"] = "+1 starting Integrity", ["meta.magnet"] = "+35 magnet range", ["meta.upgrade"] = "Calibrate", ["meta.fallback"] = "Persistence unverified: session fallback only", ["meta.close"] = "Back",
    },
}

local function T(key, ...)
    local languageText = TEXT[language_] or TEXT.zh_CN
    local value = languageText[key] or TEXT.zh_CN[key] or key
    if select("#", ...) > 0 then return string.format(value, ...) end
    return value
end

local function IsGameScreen()
    return screen_ == "game"
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
    if joystickBase_ then joystickBase_:SetVisible(visible) end
    if joystickKnob_ then joystickKnob_:SetVisible(visible) end
end

local function ResetTouchControl()
    touchPointerId_ = nil
    touchActive_ = false
    touchStartX_, touchStartY_, touchX_, touchY_ = 0, 0, 0, 0
    SetTouchJoystickVisible(false)
end

local function UpdateTouchJoystickVisual()
    if not touchActive_ or not joystickBase_ or not joystickKnob_ then return end
    local dx, dy = touchX_ - touchStartX_, touchY_ - touchStartY_
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance > touchRadius_ then
        dx, dy = dx / distance * touchRadius_, dy / distance * touchRadius_
    end
    joystickBase_:SetStyle({ left = touchStartX_ - touchRadius_, top = touchStartY_ - touchRadius_ })
    joystickKnob_:SetStyle({ left = touchStartX_ + dx - 26, top = touchStartY_ + dy - 26 })
end

local function HandleTouchDown(event)
    if screen_ ~= "game" or event.pointerType ~= "touch" or touchActive_ then return end
    -- Reserve the right side for future touch abilities; movement starts on the left.
    if event.x > worldWidth_ * 0.58 then return end
    touchPointerId_ = event.pointerId
    touchActive_ = true
    touchStartX_, touchStartY_ = event.x, event.y
    touchX_, touchY_ = event.x, event.y
    SetTouchJoystickVisible(true)
    UpdateTouchJoystickVisual()
    event:PreventDefault()
end

local function HandleTouchMove(event)
    if not touchActive_ or event.pointerId ~= touchPointerId_ then return end
    touchX_, touchY_ = event.x, event.y
    UpdateTouchJoystickVisual()
    event:PreventDefault()
end

local function HandleTouchUp(event)
    if not touchActive_ or event.pointerId ~= touchPointerId_ then return end
    ResetTouchControl()
    event:PreventDefault()
end

local function DestroyEntityWidget(widget)
    if widget then widget:Destroy() end
end

local function ClearEntities()
    for _, e in ipairs(enemies_) do DestroyEntityWidget(e.widget) end
    for _, e in ipairs(projectiles_) do DestroyEntityWidget(e.widget) end
    for _, e in ipairs(pickups_) do DestroyEntityWidget(e.widget) end
    if orbitWidget_ then orbitWidget_:Destroy(); orbitWidget_ = nil end
    if orbitWidget2_ then orbitWidget2_:Destroy(); orbitWidget2_ = nil end
    enemies_, projectiles_, pickups_ = {}, {}, {}
end

local function ResetRunState()
    ClearEntities(); worldWidth_, worldHeight_ = GetWorldSize()
    player_.x, player_.y = worldWidth_ * 0.5, worldHeight_ * 0.5
    player_.integrity, player_.maxIntegrity = 5 + profile_.startingIntegrity, 5 + profile_.startingIntegrity
    player_.invulnerable, player_.fireTimer, player_.pulseTimer = 0, 0, 0
    player_.orbitAngle, player_.magnetRadius, player_.damage = 0, 110 + profile_.magnet * 35, 1
    moduleLevels_ = { trace = 1, orbit = 0, pulse = 0 }; activeModules_ = { trace = true, orbit = false, pulse = false }
    surgeTimer_, surgeFlash_ = 2.5, 0
    runTime_, waveTime_, spawnTimer_, enemyId_, score_ = 0, 0, 0, 0, 0
    dataFragments_, patternShards_, level_, levelProgress_ = 0, 0, 1, 0
    levelGoal_, wave_, waveSpawned_, eliteCount_ = 5, 1, 0, 0
    modifier_ = ModifierForWave(wave_)
    waveSpawnTarget_, wavePauseTimer_ = 10, 0
    chosenModule_, moduleLevel_, defeatReason_ = "", 0, ""
    summaryAwarded_ = false
end

local function MakeLanguageButton(code, label)
    return UI.Button { text = language_ == code and ("✓  " .. label) or label, variant = language_ == code and "success" or "secondary", width = "100%", height = 48, marginBottom = 10, onClick = function() language_ = code; BuildUI() end }
end

local function BuildLanguageScreen()
    local card = UI.Panel { width = "90%", maxWidth = 430, padding = 28, gap = 12, alignItems = "center", backgroundColor = { 20, 31, 58, 245 }, borderRadius = 24, borderWidth = 1, borderColor = { 91, 124, 190, 180 }, children = {
        MakeLabel("◆", { fontSize = 42, fontColor = { 255, 213, 83, 255 } }),
        MakeLabel(T("menu.title"), { fontSize = 30, fontWeight = "bold", fontColor = { 255, 255, 255, 255 }, textAlign = "center" }),
        MakeLabel(T("menu.subtitle"), { fontSize = 15, fontColor = { 177, 196, 231, 255 }, textAlign = "center" }),
        UI.Panel { width = "100%", padding = 14, gap = 4, backgroundColor = { 11, 20, 42, 180 }, borderRadius = 14, children = { MakeLanguageButton("zh_CN", T("language.simplified_chinese")), MakeLanguageButton("en", T("language.english")) } },
        MakeLabel(T("menu.ready"), { fontSize = 13, fontColor = { 146, 225, 191, 255 }, textAlign = "center", marginTop = 8 }),
        UI.Button { text = T("menu.start"), variant = "primary", width = "100%", height = 50, onClick = function() screen_ = "game"; ResetRunState(); BuildUI() end },
        UI.Button { text = T("meta.archive"), variant = "secondary", width = "100%", height = 44, onClick = function() metaScreenReturn_ = "language"; screen_ = "archive"; BuildUI() end },
    } }
    return UI.Panel { width = "100%", height = "100%", justifyContent = "center", alignItems = "center", padding = 20, children = { card } }
end

local function ModuleName(moduleId)
    if moduleId == "trace" then return T("module.trace") end
    if moduleId == "orbit" then return T("module.orbit") end
    if moduleId == "pulse" then return T("module.pulse") end
    return T("game.none")
end

local function IsModuleActive(moduleId)
    return activeModules_[moduleId] == true
end

local function ActiveModuleText()
    local list = {}
    for _, id in ipairs({ "trace", "orbit", "pulse" }) do if activeModules_[id] then table.insert(list, ModuleName(id) .. " Lv." .. moduleLevels_[id]) end end
    return #list > 0 and table.concat(list, " · ") or T("game.none")
end

local function BuildGameScreen()
    ResetTouchControl()
    gameWorld_ = UI.Panel { id = "gameWorld", position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "none", backgroundColor = { 9, 17, 37, 255 }, overflow = "hidden" }
    playerWidget_ = UI.Panel { id = "player", position = "absolute", width = 32, height = 32, backgroundColor = { 82, 214, 255, 255 }, borderColor = { 225, 250, 255, 255 }, borderWidth = 2, borderRadius = 5, rotate = 45 }
    gameWorld_:AddChild(playerWidget_)

    hudLabel_ = MakeLabel("", { fontSize = 13, fontWeight = "bold", fontColor = { 220, 235, 255, 255 }, lineHeight = 1.35 })
    xpLabel_ = MakeLabel("", { fontSize = 11, fontColor = { 183, 207, 242, 255 }, marginTop = 5 })
    xpBarFill_ = UI.Panel { width = "0%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 177, 128, 255, 255 }, to = { 91, 220, 255, 255 } }, borderRadius = 5, pointerEvents = "none" }
    local xpBar = UI.Panel { width = "100%", height = 10, marginTop = 6, backgroundColor = { 25, 40, 76, 220 }, borderRadius = 5, overflow = "hidden", children = { xpBarFill_ } }
    local statusCard = UI.Panel { width = "44%", maxWidth = 420, padding = 12, backgroundColor = { 8, 20, 45, 215 }, borderColor = { 91, 153, 220, 150 }, borderWidth = 1, borderRadius = 14, children = { hudLabel_, xpLabel_, xpBar } }

    waveLabel_ = MakeLabel("", { fontSize = 14, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "right" })
    moduleLabel_ = MakeLabel("", { fontSize = 11, fontColor = { 207, 220, 244, 255 }, textAlign = "right", marginTop = 5 })
    feedbackLabel_ = MakeLabel("", { position = "absolute", top = 112, left = 0, right = 0, textAlign = "center", fontSize = 13, fontWeight = "bold", fontColor = { 255, 111, 126, 0 }, pointerEvents = "none" })
    local waveCard = UI.Panel { width = "38%", maxWidth = 360, padding = 12, alignItems = "flex-end", backgroundColor = { 8, 20, 45, 215 }, borderColor = { 146, 225, 191, 150 }, borderWidth = 1, borderRadius = 14, children = { waveLabel_, moduleLabel_ } }
    local hud = UI.Panel { position = "absolute", top = 14, left = 16, right = 16, flexDirection = "row", justifyContent = "space-between", pointerEvents = "none", children = { statusCard, waveCard } }

    joystickBase_ = UI.Panel { position = "absolute", width = touchRadius_ * 2, height = touchRadius_ * 2, backgroundColor = { 72, 133, 204, 90 }, borderColor = { 157, 220, 255, 170 }, borderWidth = 2, borderRadius = touchRadius_, pointerEvents = "none", visible = false }
    joystickKnob_ = UI.Panel { position = "absolute", width = 52, height = 52, backgroundColor = { 108, 220, 255, 210 }, borderColor = { 230, 252, 255, 230 }, borderWidth = 2, borderRadius = 26, pointerEvents = "none", visible = false }
    touchSurface_ = UI.Panel { position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "auto", onPointerDown = HandleTouchDown, onPointerMove = HandleTouchMove, onPointerUp = HandleTouchUp, onPointerCancel = HandleTouchUp, children = { joystickBase_, joystickKnob_ } }

    return UI.Panel { width = "100%", height = "100%", pointerEvents = "box-none", children = {
        gameWorld_, hud, feedbackLabel_,
        MakeLabel(T("game.hint"), { position = "absolute", bottom = 28, left = 0, right = 0, textAlign = "center", fontSize = 11, fontColor = { 131, 151, 190, 220 } }),
        MakeLabel(T("game.mobile_hint"), { position = "absolute", bottom = 10, left = 0, right = 0, textAlign = "center", fontSize = 10, fontColor = { 122, 190, 218, 230 } }),
        touchSurface_,
    } }
end

local function BuildUpgradeScreen()
    local cards = {}
    for index, card in ipairs(upgradeCards_) do
        cards[index] = UI.Button { text = card.title .. "\n" .. card.description, variant = index == 1 and "primary" or "secondary", width = "100%", minHeight = 72, marginBottom = 10, fontSize = 13, onClick = function() ApplyUpgrade(card.id); screen_ = "game"; BuildUI() end }
    end
    return UI.Panel { width = "90%", maxWidth = 520, padding = 24, gap = 8, backgroundColor = { 19, 30, 58, 250 }, borderRadius = 22, borderWidth = 1, borderColor = { 108, 172, 255, 220 }, children = {
        MakeLabel(T("game.level_up"), { fontSize = 23, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "center", marginBottom = 4 }),
        MakeLabel(T("game.level", level_), { fontSize = 14, fontColor = { 177, 196, 231, 255 }, textAlign = "center", marginBottom = 12 }),
        table.unpack(cards),
    } }
end

local function BuildWavePauseScreen()
    local remaining = math.max(0, levelGoal_ - levelProgress_)
    return UI.Panel { width = "90%", maxWidth = 520, padding = 28, gap = 14, alignItems = "center", backgroundColor = { 20, 39, 63, 250 }, borderRadius = 24, borderWidth = 1, borderColor = { 146, 225, 191, 200 }, children = {
        MakeLabel(T("game.wave_pause"), { fontSize = 25, fontWeight = "bold", fontColor = { 146, 225, 191, 255 }, textAlign = "center" }),
        MakeLabel(T("game.wave_next", wave_), { fontSize = 18, fontWeight = "bold", fontColor = { 255, 230, 137, 255 } }),
        UI.Panel { width = "100%", padding = 14, gap = 7, backgroundColor = { 9, 20, 43, 180 }, borderRadius = 12, children = {
            MakeLabel(T("game.stats"), { fontSize = 12, fontWeight = "bold", fontColor = { 146, 225, 191, 255 } }),
            MakeLabel(T("game.integrity", math.max(0, player_.integrity), player_.maxIntegrity), { fontSize = 14, fontColor = { 220, 235, 255, 255 } }),
            MakeLabel(T("game.level", level_) .. "  ·  " .. T("game.next_upgrade", remaining), { fontSize = 14, fontColor = { 183, 207, 242, 255 } }),
            MakeLabel(T("game.fragments", dataFragments_) .. "  ·  " .. T("game.score", score_), { fontSize = 14, fontColor = { 255, 230, 137, 255 } }),
        } },
        MakeLabel(T("game.modifier", T("modifier." .. modifier_)), { fontSize = 14, fontWeight = "bold", fontColor = { 255, 182, 105, 255 }, textAlign = "center" }),
        MakeLabel(T("game.modules", ActiveModuleText()), { fontSize = 13, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }),
        UI.Button { text = T("game.continue"), variant = "primary", width = "100%", height = 50, onClick = function() screen_ = "game"; modifier_ = ModifierForWave(wave_); surgeTimer_, waveTime_, waveSpawned_, spawnTimer_ = 2.5, 0, 0, 0; waveSpawnTarget_ = 8 + wave_ * 3; BuildUI() end },
    } }
end

local function BuildArchiveScreen()
    local canCalibrate = profile_.calibration > 0
    return UI.Panel { width = "90%", maxWidth = 440, padding = 26, gap = 12, alignItems = "center", backgroundColor = { 20, 31, 58, 250 }, borderRadius = 22, borderWidth = 1, borderColor = { 146, 225, 191, 200 }, children = {
        MakeLabel(T("meta.title"), { fontSize = 24, fontWeight = "bold", fontColor = { 146, 225, 191, 255 }, textAlign = "center" }),
        MakeLabel(T("meta.currency", profile_.calibration), { fontSize = 15, fontColor = { 255, 230, 137, 255 } }),
        MakeLabel(T("meta.fallback"), { fontSize = 11, fontColor = { 177, 196, 231, 255 }, textAlign = "center" }),
        UI.Button { text = T("meta.integrity"), variant = profile_.startingIntegrity > 0 and "secondary" or "primary", width = "100%", height = 48, onClick = function() if canCalibrate and profile_.startingIntegrity == 0 then profile_.startingIntegrity = 1; profile_.calibration = profile_.calibration - 1; BuildUI() end end },
        UI.Button { text = T("meta.magnet"), variant = profile_.magnet > 0 and "secondary" or "primary", width = "100%", height = 48, onClick = function() if canCalibrate and profile_.magnet == 0 then profile_.magnet = 1; profile_.calibration = profile_.calibration - 1; BuildUI() end end },
        UI.Button { text = T("meta.close"), variant = "secondary", width = "100%", height = 44, onClick = function() screen_ = metaScreenReturn_; BuildUI() end },
    } }
end

local function BuildSummaryScreen()
    return UI.Panel { width = "90%", maxWidth = 450, padding = 28, gap = 12, alignItems = "center", backgroundColor = { 30, 24, 54, 250 }, borderRadius = 24, borderWidth = 1, borderColor = { 231, 109, 143, 200 }, children = {
        MakeLabel(T("game.defeated"), { fontSize = 28, fontWeight = "bold", fontColor = { 255, 150, 170, 255 }, textAlign = "center" }),
        MakeLabel(T("game.summary"), { fontSize = 16, fontColor = { 210, 201, 231, 255 } }),
        MakeLabel(T("game.reason", defeatReason_), { fontSize = 13, fontColor = { 210, 201, 231, 255 }, textAlign = "center" }),
        MakeLabel(T("game.final_wave", wave_), { fontSize = 16, fontColor = { 177, 196, 231, 255 } }),
        MakeLabel(T("game.final_score", score_), { fontSize = 16, fontColor = { 255, 230, 137, 255 } }),
        MakeLabel(T("game.final_level", level_), { fontSize = 16, fontColor = { 146, 225, 191, 255 } }),
        MakeLabel(T("game.modules", ActiveModuleText()), { fontSize = 14, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }),
        MakeLabel(T("game.final_fragments", dataFragments_), { fontSize = 14, fontColor = { 207, 220, 244, 255 } }),
        MakeLabel(T("meta.currency", profile_.calibration), { fontSize = 13, fontColor = { 255, 230, 137, 255 } }),
        UI.Button { text = T("meta.archive"), variant = "secondary", width = "100%", height = 44, onClick = function() metaScreenReturn_ = "summary"; screen_ = "archive"; BuildUI() end },
        UI.Button { text = T("game.restart"), variant = "primary", width = "100%", height = 48, onClick = function() screen_ = "game"; ResetRunState(); BuildUI() end },
        UI.Button { text = T("game.back"), variant = "secondary", width = "100%", height = 44, onClick = function() screen_ = "language"; BuildUI() end },
    } }
end

function BuildUI()
    ---@type Widget|nil
    local content = nil
    if screen_ == "language" then content = BuildLanguageScreen()
    elseif screen_ == "game" then content = BuildGameScreen()
    elseif screen_ == "upgrade" then content = BuildUpgradeScreen()
    elseif screen_ == "wave_pause" then content = BuildWavePauseScreen()
    elseif screen_ == "archive" then content = BuildArchiveScreen()
    else content = BuildSummaryScreen() end
    local rootProps = { width = "100%", height = "100%", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 8, 18, 42, 255 }, to = { 35, 20, 68, 255 } }, pointerEvents = "box-none", children = { content } }
    if screen_ ~= "game" then
        rootProps.justifyContent = "center"
        rootProps.alignItems = "center"
        rootProps.padding = 16
    end
    uiRoot_ = UI.Panel(rootProps)
    UI.SetRoot(uiRoot_, true)
    if screen_ == "game" then SetWidgetPosition(playerWidget_, player_.x, player_.y, 32) end
end

local function SpawnPickup(x, y, kind, amount)
    if not gameWorld_ then return end
    local color = kind == "data" and { 255, 214, 92, 255 } or { 175, 128, 255, 255 }
    local widget = UI.Panel { position = "absolute", width = kind == "data" and 10 or 13, height = kind == "data" and 10 or 13, backgroundColor = color, borderColor = { 255, 255, 255, 220 }, borderWidth = 1, borderRadius = 6, pointerEvents = "none" }
    gameWorld_:AddChild(widget)
    table.insert(pickups_, { x = x, y = y, kind = kind, amount = amount, radius = kind == "data" and 5 or 7, widget = widget })
end

local function EnemyKindForId(enemyId, wave)
    local cycle = (enemyId + wave) % 3
    if cycle == 0 then return "chaser" end
    if cycle == 1 then return "skimmer" end
    return "charger"
end

local function SpawnEnemy(elite)
    if not gameWorld_ or #enemies_ >= 24 or waveSpawned_ >= waveSpawnTarget_ then return end
    enemyId_ = enemyId_ + 1; waveSpawned_ = waveSpawned_ + 1
    local side = (enemyId_ - 1) % 4
    ---@type number
    local x = 0
    ---@type number
    local y = 0
    if side == 0 then x, y = -30, math.random(30, math.max(31, math.floor(worldHeight_ - 30)))
    elseif side == 1 then x, y = worldWidth_ + 30, math.random(30, math.max(31, math.floor(worldHeight_ - 30)))
    elseif side == 2 then x, y = math.random(30, math.max(31, math.floor(worldWidth_ - 30))), -30
    else x, y = math.random(30, math.max(31, math.floor(worldWidth_ - 30))), worldHeight_ + 30 end
    local kind = elite and "elite" or EnemyKindForId(enemyId_, wave_)
    local size = elite and 38 or (kind == "charger" and 28 or 24)
    local color = elite and { 255, 126, 63, 255 } or (kind == "skimmer" and { 84, 216, 194, 255 } or kind == "charger" and { 255, 168, 76, 255 } or { 244, 93, 133, 255 })
    local widget = UI.Panel { position = "absolute", width = size, height = size, backgroundColor = color, borderColor = elite and { 255, 239, 164, 255 } or { 255, 220, 150, 255 }, borderWidth = elite and 3 or 2, borderRadius = kind == "skimmer" and size * 0.5 or (elite and 18 or 8), pointerEvents = "none" }
    gameWorld_:AddChild(widget)
    table.insert(enemies_, { x = x, y = y, radius = size * 0.5, speed = (elite and 38 or kind == "skimmer" and 46 or kind == "charger" and 40 or 52) + wave_ * 3, integrity = (elite and 12 or 2) + wave_, widget = widget, elite = elite, kind = kind, phase = 0, charge = 0, telegraph = 0, dead = false })
end

local function FindNearestEnemy()
    local nearest, distanceBest = nil, math.huge
    for _, enemy in ipairs(enemies_) do
        local dx, dy = enemy.x - player_.x, enemy.y - player_.y; local distance = dx * dx + dy * dy
        if distance < distanceBest then nearest, distanceBest = enemy, distance end
    end
    return nearest
end

local function FireTraceBeam()
    local target = FindNearestEnemy(); if not target or not gameWorld_ then return end
    local dx, dy = target.x - player_.x, target.y - player_.y; local length = math.sqrt(dx * dx + dy * dy); if length <= 0 then return end
    local widget = UI.Panel { position = "absolute", width = 11, height = 11, backgroundColor = { 255, 224, 99, 255 }, borderRadius = 6, pointerEvents = "none" }; gameWorld_:AddChild(widget)
    table.insert(projectiles_, { x = player_.x, y = player_.y, vx = dx / length * (430 + moduleLevels_.trace * 35), vy = dy / length * (430 + moduleLevels_.trace * 35), radius = 5, damage = player_.damage + moduleLevels_.trace, life = 1.4, pierce = moduleLevels_.trace >= 3 and 2 or 1, widget = widget })
end

local function DamageEnemy(enemy, amount)
    if not enemy or enemy.dead then return end
    enemy.integrity = enemy.integrity - amount
    if enemy.integrity > 0 then return end
    enemy.dead = true
    local reward = modifier_ == "overclock" and 2 or 1
    score_ = score_ + (enemy.elite and 8 or 1); SpawnPickup(enemy.x, enemy.y, "data", (enemy.elite and 3 or 1) * reward); SpawnPickup(enemy.x + 8, enemy.y, "shard", enemy.elite and 3 or 1)
    DestroyEntityWidget(enemy.widget)
end

local function CleanupDeadEnemies()
    for index = #enemies_, 1, -1 do
        if enemies_[index].dead then table.remove(enemies_, index) end
    end
end

local function DamagePlayer()
    if player_.invulnerable > 0 or screen_ ~= "game" then return end
    player_.integrity = player_.integrity - 1; player_.invulnerable = 0.65
    if player_.integrity <= 0 then defeatReason_ = T("game.reason_contact"); if not summaryAwarded_ then profile_.calibration = profile_.calibration + math.max(1, math.floor(dataFragments_ / 8)); summaryAwarded_ = true end; screen_ = "summary"; ClearEntities(); BuildUI() end
end

local function UpdateMovement(timeStep)
    ---@type number
    local dx = 0
    ---@type number
    local dy = 0
    if touchActive_ then
        dx, dy = touchX_ - touchStartX_, touchY_ - touchStartY_
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then
            dx, dy = dx / math.max(distance, touchRadius_), dy / math.max(distance, touchRadius_)
        end
    else
        if keys_[KEY_A] or keys_[KEY_LEFT] then dx = dx - 1 end; if keys_[KEY_D] or keys_[KEY_RIGHT] then dx = dx + 1 end
        if keys_[KEY_W] or keys_[KEY_UP] then dy = dy - 1 end; if keys_[KEY_S] or keys_[KEY_DOWN] then dy = dy + 1 end
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then dx, dy = dx / length, dy / length end
    end
    if dx ~= 0 or dy ~= 0 then player_.x = player_.x + dx * player_.speed * timeStep; player_.y = player_.y + dy * player_.speed * timeStep end
    local bound = modifier_ == "compression" and 70 or player_.radius
    player_.x = math.max(bound, math.min(worldWidth_ - bound, player_.x)); player_.y = math.max(bound, math.min(worldHeight_ - bound, player_.y)); SetWidgetPosition(playerWidget_, player_.x, player_.y, 32)
end

local function UpdateEnemies(timeStep)
    local bound = modifier_ == "compression" and 70 or 0
    for _, enemy in ipairs(enemies_) do
        if not enemy.dead then
            local dx, dy = player_.x - enemy.x, player_.y - enemy.y; local distance = math.sqrt(dx * dx + dy * dy)
            enemy.phase = enemy.phase + timeStep
            if enemy.kind == "skimmer" then
                local tangentX, tangentY = -dy / math.max(distance, 1), dx / math.max(distance, 1)
                dx, dy = dx + tangentX * 90, dy + tangentY * 90
            elseif enemy.kind == "charger" then
                if enemy.charge <= 0 then enemy.charge = 2.1; enemy.telegraph = 0.45 end
                if enemy.telegraph > 0 then enemy.telegraph = enemy.telegraph - timeStep
                else enemy.charge = enemy.charge - timeStep; enemy.speed = 165 + wave_ * 5 end
            end
            if distance > 0 and (enemy.kind ~= "charger" or enemy.telegraph <= 0) then enemy.x = enemy.x + dx / math.max(distance, 1) * enemy.speed * (modifier_ == "overclock" and 1.25 or 1) * timeStep; enemy.y = enemy.y + dy / math.max(distance, 1) * enemy.speed * (modifier_ == "overclock" and 1.25 or 1) * timeStep end
            if bound > 0 then enemy.x = math.max(bound, math.min(worldWidth_ - bound, enemy.x)); enemy.y = math.max(bound, math.min(worldHeight_ - bound, enemy.y)) end
            if enemy.telegraph > 0 then enemy.widget:SetStyle({ backgroundColor = { 255, 245, 110, 255 }, borderColor = { 255, 70, 80, 255 }, scale = 1.2 }) else enemy.widget:SetStyle({ scale = 1.0 }) end
            SetWidgetPosition(enemy.widget, enemy.x, enemy.y, enemy.elite and 38 or (enemy.kind == "charger" and 28 or 24))
            if distance < player_.radius + enemy.radius then
                DamagePlayer()
                if screen_ ~= "game" then return end
                enemy.x = enemy.x - dx / math.max(distance, 1) * 22; enemy.y = enemy.y - dy / math.max(distance, 1) * 22
            end
        end
    end
    CleanupDeadEnemies()
end

local function UpdateProjectiles(timeStep)
    for projectileIndex = #projectiles_, 1, -1 do
        local projectile = projectiles_[projectileIndex]; projectile.x = projectile.x + projectile.vx * timeStep; projectile.y = projectile.y + projectile.vy * timeStep; projectile.life = projectile.life - timeStep; local remove = projectile.life <= 0
        for enemyIndex = #enemies_, 1, -1 do
            local enemy = enemies_[enemyIndex]
            if not enemy then break end
            local dx, dy = enemy.x - projectile.x, enemy.y - projectile.y
            if dx * dx + dy * dy < (enemy.radius + projectile.radius) ^ 2 then DamageEnemy(enemy, projectile.damage); projectile.pierce = projectile.pierce - 1; remove = projectile.pierce <= 0; if remove then break end end
        end
        if remove then DestroyEntityWidget(projectile.widget); table.remove(projectiles_, projectileIndex) else SetWidgetPosition(projectile.widget, projectile.x, projectile.y, 10) end
    end
end

local function UpdatePickups(timeStep)
    for index = #pickups_, 1, -1 do
        local pickup = pickups_[index]; local dx, dy = player_.x - pickup.x, player_.y - pickup.y; local distance = math.sqrt(dx * dx + dy * dy)
        if distance < player_.magnetRadius and distance > 0 then local speed = distance < 45 and 330 or 180; pickup.x = pickup.x + dx / distance * speed * timeStep; pickup.y = pickup.y + dy / distance * speed * timeStep end
        if distance < player_.radius + pickup.radius then
            if pickup.kind == "data" then dataFragments_ = dataFragments_ + pickup.amount else patternShards_ = patternShards_ + pickup.amount; levelProgress_ = levelProgress_ + pickup.amount end
            DestroyEntityWidget(pickup.widget); table.remove(pickups_, index)
            if levelProgress_ >= levelGoal_ and screen_ == "game" then
                levelProgress_ = levelProgress_ - levelGoal_
                level_ = level_ + 1
                levelGoal_ = 5 + level_ * 3
                PrepareUpgradeChoices()
                ClearEntities()
                screen_ = "upgrade"
                BuildUI()
                return
            end
        else SetWidgetPosition(pickup.widget, pickup.x, pickup.y, pickup.kind == "data" and 10 or 13) end
    end
end

local function UpdateOrbit(timeStep)
    if not IsModuleActive("orbit") or not gameWorld_ then return end
    player_.orbitAngle = player_.orbitAngle + 2.8 * timeStep
    local count = moduleLevels_.orbit >= 3 and 2 or 1
    for node = 1, count do
        local angle = player_.orbitAngle + (node - 1) * math.pi
        local ox, oy = player_.x + math.cos(angle) * 42, player_.y + math.sin(angle) * 42
        ---@type Widget|nil
        local widget = node == 1 and orbitWidget_ or orbitWidget2_
        if not widget then widget = UI.Panel { position = "absolute", width = 16, height = 16, backgroundColor = { 190, 139, 255, 255 }, borderRadius = 8, pointerEvents = "none" }; gameWorld_:AddChild(widget); if node == 1 then orbitWidget_ = widget else orbitWidget2_ = widget end end
        SetWidgetPosition(widget, ox, oy, 16)
        for _, enemy in ipairs(enemies_) do local dx, dy = enemy.x - ox, enemy.y - oy; if dx * dx + dy * dy < (enemy.radius + 9) ^ 2 then DamageEnemy(enemy, 0.04 + moduleLevels_.orbit * 0.02) end end
    end
end

local function PulseBloom()
    if not IsModuleActive("pulse") then return end
    local radius = 105 + moduleLevels_.pulse * 10
    for _, enemy in ipairs(enemies_) do
        if not enemy.dead then local dx, dy = enemy.x - player_.x, enemy.y - player_.y; local distance = math.sqrt(dx * dx + dy * dy); if distance < radius then DamageEnemy(enemy, 2 + moduleLevels_.pulse); if distance > 0 then enemy.x = enemy.x + dx / distance * 30; enemy.y = enemy.y + dy / distance * 30 end end end
    end
    if moduleLevels_.pulse >= 3 then surgeFlash_ = 0.25 end
end

function ApplyUpgrade(id)
    if id == "trace" or id == "orbit" or id == "pulse" then
        activeModules_[id] = true; moduleLevels_[id] = math.min(5, moduleLevels_[id] + 1); chosenModule_ = id; moduleLevel_ = moduleLevels_[id]
    elseif id == "integrity" then player_.maxIntegrity = player_.maxIntegrity + 1; player_.integrity = player_.maxIntegrity
    elseif id == "magnet" then player_.magnetRadius = player_.magnetRadius + 55 end
end

function PrepareUpgradeChoices()
    local options = { "trace", "orbit", "pulse", "integrity", "magnet" }
    upgradeCards_ = {}
    for _, id in ipairs(options) do
        local title = ""
        local description = ""
        if id == "trace" then title, description = T("upgrade.trace"), T("module.trace_desc")
        elseif id == "orbit" then title, description = T("upgrade.orbit"), T("module.orbit_desc")
        elseif id == "pulse" then title, description = T("upgrade.pulse"), T("module.pulse_desc")
        elseif id == "integrity" then title, description = T("upgrade.integrity"), T("upgrade.desc")
        else title, description = T("upgrade.magnet"), T("upgrade.desc") end
        table.insert(upgradeCards_, { id = id, title = title, description = description })
    end
end

local function UpdateHUD()
    if hudLabel_ then hudLabel_:SetText(T("game.integrity", math.max(0, player_.integrity), player_.maxIntegrity) .. "  |  " .. T("game.score", score_) .. "  |  " .. T("game.fragments", dataFragments_)) end
    if xpLabel_ then xpLabel_:SetText(T("game.level", level_) .. "  ·  " .. T("game.next_upgrade", math.max(0, levelGoal_ - levelProgress_))) end
    if xpBarFill_ then xpBarFill_:SetStyle({ width = tostring(math.floor(math.min(1, levelProgress_ / math.max(1, levelGoal_)) * 100)) .. "%" }) end
    if waveLabel_ then waveLabel_:SetText(T("game.wave", wave_, maxWaves_) .. "\n" .. T("game.time", math.floor(runTime_)) .. "\n" .. T("game.modifier", T("modifier." .. modifier_))) end
    if moduleLabel_ then moduleLabel_:SetText(T("game.modules", ActiveModuleText())) end
    if feedbackLabel_ then feedbackLabel_:SetStyle({ opacity = surgeFlash_ > 0 and 1 or 0 }); feedbackLabel_:SetText(surgeFlash_ > 0 and T("game.telegraph") or "") end
end

local function EndWave()
    ClearEntities()
    if wave_ >= maxWaves_ then defeatReason_ = T("game.reason_complete"); if not summaryAwarded_ then profile_.calibration = profile_.calibration + math.max(1, math.floor(dataFragments_ / 8)); summaryAwarded_ = true end; screen_ = "summary"; BuildUI(); return end
    wave_ = wave_ + 1; screen_ = "wave_pause"; wavePauseTimer_ = 0; BuildUI()
end

function HandleUpdate(_eventType, eventData)
    if screen_ ~= "game" then return end
    local timeStep = math.min(eventData["TimeStep"]:GetFloat(), 0.05); runTime_ = runTime_ + timeStep; waveTime_ = waveTime_ + timeStep
    player_.invulnerable = math.max(0, player_.invulnerable - timeStep); player_.fireTimer = player_.fireTimer - timeStep; player_.pulseTimer = player_.pulseTimer - timeStep; spawnTimer_ = spawnTimer_ - timeStep; surgeFlash_ = math.max(0, surgeFlash_ - timeStep)
    if modifier_ == "surge" then surgeTimer_ = surgeTimer_ - timeStep; if surgeTimer_ <= 0 then surgeTimer_ = 4.0; surgeFlash_ = 0.55; for _, enemy in ipairs(enemies_) do if not enemy.dead then DamageEnemy(enemy, 1); end end end end
    UpdateMovement(timeStep)
    if waveSpawned_ == 0 and wave_ % 3 == 0 then SpawnEnemy(true) end
    if spawnTimer_ <= 0 and waveSpawned_ < waveSpawnTarget_ and waveTime_ < waveDuration_ then SpawnEnemy(false); spawnTimer_ = math.max(0.35, 0.9 - wave_ * 0.05) end
    if IsModuleActive("trace") and player_.fireTimer <= 0 then FireTraceBeam(); player_.fireTimer = math.max(0.18, 0.42 - moduleLevels_.trace * 0.04) end
    if IsModuleActive("pulse") and player_.pulseTimer <= 0 then PulseBloom(); player_.pulseTimer = math.max(1.4, 3.0 - moduleLevels_.pulse * 0.25) end
    UpdateEnemies(timeStep)
    if not IsGameScreen() then return end
    UpdateProjectiles(timeStep); UpdatePickups(timeStep)
    if not IsGameScreen() then return end
    UpdateOrbit(timeStep)
    if waveTime_ >= waveDuration_ and waveSpawned_ >= waveSpawnTarget_ and #enemies_ == 0 then EndWave() else UpdateHUD() end
end

function HandleKeyDown(_eventType, eventData)
    local key = eventData["Key"]:GetInt(); keys_[key] = true
    if key == KEY_ESCAPE and screen_ == "game" then screen_ = "language"; ClearEntities(); BuildUI() end
end

function HandleKeyUp(_eventType, eventData)
    local key = eventData["Key"]:GetInt(); keys_[key] = false
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
