-- Geometry Breakout / 几何突围
-- Prototype 02: pickups, progression, wave pacing, modules, elite, and run summary.

local UI = require("urhox-libs/UI")

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
local keys_ = {}
local enemies_ = {}
local projectiles_ = {}
local pickups_ = {}
---@type Widget|nil
local orbitWidget_ = nil
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

local TEXT = {
    zh_CN = {
        ["menu.title"] = "几何突围", ["menu.subtitle"] = "选择语言开始游戏",
        ["language.english"] = "English", ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "校准台已上线，准备开始突围。", ["menu.start"] = "开始突围",
        ["menu.footer"] = "几何突围 · Prototype 02", ["game.integrity"] = "完整度：%d / %d",
        ["game.time"] = "突围时间：%ds", ["game.score"] = "击破：%d", ["game.wave"] = "波次：%d / %d",
        ["game.progress"] = "模式碎片：%d / %d", ["game.fragments"] = "数据碎片：%d",
        ["game.module"] = "模块：%s Lv.%d", ["game.none"] = "未装配", ["game.enemy"] = "敌对几何体",
        ["game.elite"] = "精英核心", ["game.hint"] = "WASD / 方向键移动 · 自动模块锁定目标",
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
    },
    en = {
        ["menu.title"] = "Geometry Breakout", ["menu.subtitle"] = "Choose your language to begin",
        ["language.english"] = "English", ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "Calibration deck online. Ready to break out.", ["menu.start"] = "Start Breakout",
        ["menu.footer"] = "Geometry Breakout · Prototype 02", ["game.integrity"] = "Integrity: %d / %d",
        ["game.time"] = "Breakout time: %ds", ["game.score"] = "Defeated: %d", ["game.wave"] = "Wave: %d / %d",
        ["game.progress"] = "Pattern Shards: %d / %d", ["game.fragments"] = "Data Fragments: %d",
        ["game.module"] = "Module: %s Lv.%d", ["game.none"] = "Unassigned", ["game.enemy"] = "Hostile Form",
        ["game.elite"] = "Elite Core", ["game.hint"] = "WASD / arrows to move · module auto-locks targets",
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

local function DestroyEntityWidget(widget)
    if widget then widget:Destroy() end
end

local function ClearEntities()
    for _, e in ipairs(enemies_) do DestroyEntityWidget(e.widget) end
    for _, e in ipairs(projectiles_) do DestroyEntityWidget(e.widget) end
    for _, e in ipairs(pickups_) do DestroyEntityWidget(e.widget) end
    if orbitWidget_ then orbitWidget_:Destroy(); orbitWidget_ = nil end
    enemies_, projectiles_, pickups_ = {}, {}, {}
end

local function ResetRunState()
    ClearEntities(); worldWidth_, worldHeight_ = GetWorldSize()
    player_.x, player_.y = worldWidth_ * 0.5, worldHeight_ * 0.5
    player_.integrity, player_.maxIntegrity = 5, 5
    player_.invulnerable, player_.fireTimer, player_.pulseTimer = 0, 0, 0
    player_.orbitAngle, player_.magnetRadius, player_.damage = 0, 110, 1
    runTime_, waveTime_, spawnTimer_, enemyId_, score_ = 0, 0, 0, 0, 0
    dataFragments_, patternShards_, level_, levelProgress_ = 0, 0, 1, 0
    levelGoal_, wave_, waveSpawned_, eliteCount_ = 5, 1, 0, 0
    waveSpawnTarget_, wavePauseTimer_ = 10, 0
    chosenModule_, moduleLevel_, defeatReason_ = "", 0, ""
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
    } }
    return UI.Panel { width = "100%", height = "100%", justifyContent = "center", alignItems = "center", padding = 20, children = { card } }
end

local function ModuleName(moduleId)
    if moduleId == "trace" then return T("module.trace") end
    if moduleId == "orbit" then return T("module.orbit") end
    if moduleId == "pulse" then return T("module.pulse") end
    return T("game.none")
end

local function BuildGameScreen()
    gameWorld_ = UI.Panel { id = "gameWorld", position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "none", backgroundColor = { 9, 17, 37, 255 }, overflow = "hidden" }
    playerWidget_ = UI.Panel { id = "player", position = "absolute", width = 32, height = 32, backgroundColor = { 82, 214, 255, 255 }, borderColor = { 225, 250, 255, 255 }, borderWidth = 2, borderRadius = 5, rotate = 45 }
    gameWorld_:AddChild(playerWidget_)
    hudLabel_ = MakeLabel("", { fontSize = 13, fontWeight = "bold", fontColor = { 220, 235, 255, 255 }, lineHeight = 1.35 })
    waveLabel_ = MakeLabel("", { fontSize = 14, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "right" })
    local hud = UI.Panel { position = "absolute", top = 14, left = 16, right = 16, flexDirection = "row", justifyContent = "space-between", pointerEvents = "none", children = { hudLabel_, waveLabel_ } }
    return UI.Panel { width = "100%", height = "100%", pointerEvents = "box-none", children = { gameWorld_, hud, MakeLabel(T("game.hint"), { position = "absolute", bottom = 12, left = 0, right = 0, textAlign = "center", fontSize = 11, fontColor = { 131, 151, 190, 220 } }) } }
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
    return UI.Panel { width = "90%", maxWidth = 430, padding = 28, gap = 14, alignItems = "center", backgroundColor = { 20, 39, 63, 250 }, borderRadius = 24, borderWidth = 1, borderColor = { 146, 225, 191, 200 }, children = {
        MakeLabel(T("game.wave_pause"), { fontSize = 25, fontWeight = "bold", fontColor = { 146, 225, 191, 255 }, textAlign = "center" }),
        MakeLabel(T("game.wave_next", wave_), { fontSize = 16, fontColor = { 255, 230, 137, 255 } }),
        MakeLabel(T("game.module", ModuleName(chosenModule_), moduleLevel_), { fontSize = 14, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }),
        UI.Button { text = T("game.continue"), variant = "primary", width = "100%", height = 50, onClick = function() screen_ = "game"; waveTime_, waveSpawned_, spawnTimer_ = 0, 0, 0; waveSpawnTarget_ = 8 + wave_ * 3; BuildUI() end },
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
        MakeLabel(T("game.final_module", ModuleName(chosenModule_), moduleLevel_), { fontSize = 14, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }),
        MakeLabel(T("game.final_fragments", dataFragments_), { fontSize = 14, fontColor = { 207, 220, 244, 255 } }),
        UI.Button { text = T("game.restart"), variant = "primary", width = "100%", height = 48, onClick = function() screen_ = "game"; ResetRunState(); BuildUI() end },
        UI.Button { text = T("game.back"), variant = "secondary", width = "100%", height = 44, onClick = function() screen_ = "language"; BuildUI() end },
    } }
end

function BuildUI()
    local content
    if screen_ == "language" then content = BuildLanguageScreen()
    elseif screen_ == "game" then content = BuildGameScreen()
    elseif screen_ == "upgrade" then content = BuildUpgradeScreen()
    elseif screen_ == "wave_pause" then content = BuildWavePauseScreen()
    else content = BuildSummaryScreen() end
    uiRoot_ = UI.Panel { width = "100%", height = "100%", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 8, 18, 42, 255 }, to = { 35, 20, 68, 255 } }, pointerEvents = "box-none", children = { content } }
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

local function SpawnEnemy(elite)
    if not gameWorld_ or #enemies_ >= 24 or waveSpawned_ >= waveSpawnTarget_ then return end
    enemyId_ = enemyId_ + 1; waveSpawned_ = waveSpawned_ + 1
    local side = (enemyId_ - 1) % 4; local x, y
    if side == 0 then x, y = -30, math.random(30, math.max(31, math.floor(worldHeight_ - 30)))
    elseif side == 1 then x, y = worldWidth_ + 30, math.random(30, math.max(31, math.floor(worldHeight_ - 30)))
    elseif side == 2 then x, y = math.random(30, math.max(31, math.floor(worldWidth_ - 30))), -30
    else x, y = math.random(30, math.max(31, math.floor(worldWidth_ - 30))), worldHeight_ + 30 end
    local size = elite and 38 or 24
    local widget = UI.Panel { position = "absolute", width = size, height = size, backgroundColor = elite and { 255, 126, 63, 255 } or { 244, 93, 133, 255 }, borderColor = elite and { 255, 239, 164, 255 } or { 255, 190, 210, 255 }, borderWidth = elite and 3 or 2, borderRadius = elite and 18 or 8, pointerEvents = "none" }
    gameWorld_:AddChild(widget)
    table.insert(enemies_, { x = x, y = y, radius = size * 0.5, speed = (elite and 38 or 52) + wave_ * 3, integrity = (elite and 12 or 2) + wave_, widget = widget, elite = elite })
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
    table.insert(projectiles_, { x = player_.x, y = player_.y, vx = dx / length * (430 + moduleLevel_ * 35), vy = dy / length * (430 + moduleLevel_ * 35), radius = 5, damage = player_.damage + moduleLevel_, life = 1.4, widget = widget })
end

local function DamageEnemy(enemy, amount)
    enemy.integrity = enemy.integrity - amount
    if enemy.integrity > 0 then return end
    score_ = score_ + (enemy.elite and 8 or 1); SpawnPickup(enemy.x, enemy.y, "data", enemy.elite and 3 or 1); SpawnPickup(enemy.x + 8, enemy.y, "shard", enemy.elite and 3 or 1)
    DestroyEntityWidget(enemy.widget)
    for index, candidate in ipairs(enemies_) do if candidate == enemy then table.remove(enemies_, index); break end end
end

local function DamagePlayer()
    if player_.invulnerable > 0 or screen_ ~= "game" then return end
    player_.integrity = player_.integrity - 1; player_.invulnerable = 0.65
    if player_.integrity <= 0 then defeatReason_ = T("game.reason_contact"); screen_ = "summary"; ClearEntities(); BuildUI() end
end

local function UpdateMovement(timeStep)
    local dx, dy = 0, 0
    if keys_[KEY_A] or keys_[KEY_LEFT] then dx = dx - 1 end; if keys_[KEY_D] or keys_[KEY_RIGHT] then dx = dx + 1 end
    if keys_[KEY_W] or keys_[KEY_UP] then dy = dy - 1 end; if keys_[KEY_S] or keys_[KEY_DOWN] then dy = dy + 1 end
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then player_.x = player_.x + dx / length * player_.speed * timeStep; player_.y = player_.y + dy / length * player_.speed * timeStep end
    player_.x = math.max(player_.radius, math.min(worldWidth_ - player_.radius, player_.x)); player_.y = math.max(player_.radius, math.min(worldHeight_ - player_.radius, player_.y)); SetWidgetPosition(playerWidget_, player_.x, player_.y, 32)
end

local function UpdateEnemies(timeStep)
    for _, enemy in ipairs(enemies_) do
        local dx, dy = player_.x - enemy.x, player_.y - enemy.y; local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then enemy.x = enemy.x + dx / distance * enemy.speed * timeStep; enemy.y = enemy.y + dy / distance * enemy.speed * timeStep end
        SetWidgetPosition(enemy.widget, enemy.x, enemy.y, enemy.elite and 38 or 24)
        if distance < player_.radius + enemy.radius then
            DamagePlayer()
            if screen_ ~= "game" then return end
            enemy.x = enemy.x - dx / math.max(distance, 1) * 22; enemy.y = enemy.y - dy / math.max(distance, 1) * 22
        end
    end
end

local function UpdateProjectiles(timeStep)
    for projectileIndex = #projectiles_, 1, -1 do
        local projectile = projectiles_[projectileIndex]; projectile.x = projectile.x + projectile.vx * timeStep; projectile.y = projectile.y + projectile.vy * timeStep; projectile.life = projectile.life - timeStep; local remove = projectile.life <= 0
        for enemyIndex = #enemies_, 1, -1 do
            local enemy = enemies_[enemyIndex]
            if not enemy then break end
            local dx, dy = enemy.x - projectile.x, enemy.y - projectile.y
            if dx * dx + dy * dy < (enemy.radius + projectile.radius) ^ 2 then DamageEnemy(enemy, projectile.damage); remove = true; break end
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

local function UpdateOrbit()
    if chosenModule_ ~= "orbit" or not gameWorld_ then return end
    player_.orbitAngle = player_.orbitAngle + 2.8 * 0.016; local ox = player_.x + math.cos(player_.orbitAngle) * 42; local oy = player_.y + math.sin(player_.orbitAngle) * 42
    if not orbitWidget_ then orbitWidget_ = UI.Panel { position = "absolute", width = 16, height = 16, backgroundColor = { 190, 139, 255, 255 }, borderRadius = 8, pointerEvents = "none" }; gameWorld_:AddChild(orbitWidget_) end
    SetWidgetPosition(orbitWidget_, ox, oy, 16)
    for _, enemy in ipairs(enemies_) do local dx, dy = enemy.x - ox, enemy.y - oy; if dx * dx + dy * dy < (enemy.radius + 9) ^ 2 then DamageEnemy(enemy, 0.04 + moduleLevel_ * 0.02) end end
end

local function PulseBloom()
    if chosenModule_ ~= "pulse" then return end
    for _, enemy in ipairs(enemies_) do local dx, dy = enemy.x - player_.x, enemy.y - player_.y; local distance = math.sqrt(dx * dx + dy * dy); if distance < 105 + moduleLevel_ * 10 then DamageEnemy(enemy, 2 + moduleLevel_); if distance > 0 then enemy.x = enemy.x + dx / distance * 30; enemy.y = enemy.y + dy / distance * 30 end end end
end

function ApplyUpgrade(id)
    if id == "trace" or id == "orbit" or id == "pulse" then if chosenModule_ == id then moduleLevel_ = moduleLevel_ + 1 else chosenModule_, moduleLevel_ = id, 1 end
    elseif id == "integrity" then player_.maxIntegrity = player_.maxIntegrity + 1; player_.integrity = player_.maxIntegrity
    elseif id == "magnet" then player_.magnetRadius = player_.magnetRadius + 55 end
end

function PrepareUpgradeChoices()
    local options = {}
    if chosenModule_ == "" then options = { "trace", "orbit", "pulse" } else options = { chosenModule_, "integrity", "magnet" } end
    upgradeCards_ = {}
    for _, id in ipairs(options) do local title, description
        if id == "trace" then title, description = T("upgrade.trace"), T("module.trace_desc")
        elseif id == "orbit" then title, description = T("upgrade.orbit"), T("module.orbit_desc")
        elseif id == "pulse" then title, description = T("upgrade.pulse"), T("module.pulse_desc")
        elseif id == "integrity" then title, description = T("upgrade.integrity"), T("upgrade.desc")
        else title, description = T("upgrade.magnet"), T("upgrade.desc") end
        table.insert(upgradeCards_, { id = id, title = title, description = description })
    end
end

local function UpdateHUD()
    if hudLabel_ then hudLabel_:SetText(T("game.integrity", math.max(0, player_.integrity), player_.maxIntegrity) .. "  |  " .. T("game.score", score_) .. "  |  " .. T("game.fragments", dataFragments_) .. "\n" .. T("game.progress", patternShards_, levelGoal_) .. "  |  " .. T("game.module", ModuleName(chosenModule_), moduleLevel_)) end
    if waveLabel_ then waveLabel_:SetText(T("game.wave", wave_, maxWaves_) .. "\n" .. T("game.time", math.floor(runTime_))) end
end

local function EndWave()
    ClearEntities()
    if wave_ >= maxWaves_ then defeatReason_ = T("game.reason_complete"); screen_ = "summary"; BuildUI(); return end
    wave_ = wave_ + 1; screen_ = "wave_pause"; wavePauseTimer_ = 0; BuildUI()
end

function HandleUpdate(_eventType, eventData)
    if screen_ ~= "game" then return end
    local timeStep = math.min(eventData["TimeStep"]:GetFloat(), 0.05); runTime_ = runTime_ + timeStep; waveTime_ = waveTime_ + timeStep
    player_.invulnerable = math.max(0, player_.invulnerable - timeStep); player_.fireTimer = player_.fireTimer - timeStep; player_.pulseTimer = player_.pulseTimer - timeStep; spawnTimer_ = spawnTimer_ - timeStep
    UpdateMovement(timeStep)
    if waveSpawned_ == 0 and wave_ % 3 == 0 then SpawnEnemy(true) end
    if spawnTimer_ <= 0 and waveSpawned_ < waveSpawnTarget_ and waveTime_ < waveDuration_ then SpawnEnemy(false); spawnTimer_ = math.max(0.35, 0.9 - wave_ * 0.05) end
    if (chosenModule_ == "trace" or chosenModule_ == "") and player_.fireTimer <= 0 then FireTraceBeam(); player_.fireTimer = math.max(0.18, 0.42 - moduleLevel_ * 0.04) end
    if chosenModule_ == "pulse" and player_.pulseTimer <= 0 then PulseBloom(); player_.pulseTimer = math.max(1.4, 3.0 - moduleLevel_ * 0.25) end
    UpdateEnemies(timeStep)
    if not IsGameScreen() then return end
    UpdateProjectiles(timeStep); UpdatePickups(timeStep)
    if not IsGameScreen() then return end
    UpdateOrbit()
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
    print("=== Geometry Breakout Prototype 02 started ===")
end

function Stop()
    ClearEntities(); UI.Shutdown()
end
