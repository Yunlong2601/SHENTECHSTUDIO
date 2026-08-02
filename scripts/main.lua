-- Geometry Breakout / 几何突围
-- Chinese-first, bilingual-ready top-down combat prototype.
-- Milestone 1: movement, enemy pursuit, automatic attack, damage, death, restart.

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
local scoreLabel_ = nil
---@type Label|nil
local integrityLabel_ = nil
---@type Label|nil
local timeLabel_ = nil
local keys_ = {}
local enemies_ = {}
local projectiles_ = {}
---@type number
local runTime_ = 0
---@type number
local spawnTimer_ = 0
---@type number
local enemyId_ = 0
---@type number
local score_ = 0
local defeatReason_ = ""
---@type number
local worldWidth_ = 800
---@type number
local worldHeight_ = 600

---@class PlayerState
---@field x number
---@field y number
---@field radius number
---@field speed number
---@field integrity number
---@field maxIntegrity number
---@field invulnerable number
---@field fireTimer number
---@field fireInterval number
---@type PlayerState
local player_ = {
    x = 0,
    y = 0,
    radius = 16,
    speed = 220,
    integrity = 5,
    maxIntegrity = 5,
    invulnerable = 0,
    fireTimer = 0,
    fireInterval = 0.42,
}

local TEXT = {
    zh_CN = {
        ["menu.title"] = "几何突围",
        ["menu.subtitle"] = "选择语言开始游戏",
        ["language.english"] = "English",
        ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "你的突围已经准备好了！",
        ["menu.start"] = "开始突围",
        ["menu.footer"] = "几何突围 · TapTap Maker 原型",
        ["game.integrity"] = "完整度：%d / %d",
        ["game.time"] = "突围时间：%ds",
        ["game.score"] = "击破：%d",
        ["game.enemy"] = "敌对几何体",
        ["game.hint"] = "WASD / 方向键移动 · 自动锁定最近目标",
        ["game.defeated"] = "突围失败",
        ["game.reason"] = "原因：%s",
        ["game.final_score"] = "最终击破：%d",
        ["game.restart"] = "重新开始",
        ["game.back"] = "返回语言选择",
        ["game.reason_contact"] = "与敌对几何体发生碰撞",
    },
    en = {
        ["menu.title"] = "Geometry Breakout",
        ["menu.subtitle"] = "Choose your language to begin",
        ["language.english"] = "English",
        ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "Your breakout is ready!",
        ["menu.start"] = "Start Breakout",
        ["menu.footer"] = "Geometry Breakout · TapTap Maker prototype",
        ["game.integrity"] = "Integrity: %d / %d",
        ["game.time"] = "Breakout time: %ds",
        ["game.score"] = "Defeated: %d",
        ["game.enemy"] = "Hostile Form",
        ["game.hint"] = "WASD / arrow keys to move · nearest target auto-locked",
        ["game.defeated"] = "Breakout Failed",
        ["game.reason"] = "Cause: %s",
        ["game.final_score"] = "Final defeated: %d",
        ["game.restart"] = "Restart",
        ["game.back"] = "Back to language selection",
        ["game.reason_contact"] = "Collision with a hostile form",
    },
}

local function T(key, ...)
    local languageText = TEXT[language_] or TEXT.zh_CN
    local value = languageText[key] or TEXT.zh_CN[key] or key
    if select("#", ...) > 0 then
        return string.format(value, ...)
    end
    return value
end

local function GetWorldSize()
    local graphics = GetGraphics()
    local dpr = graphics:GetDPR()
    if dpr <= 0 then dpr = 1 end
    return graphics:GetWidth() / dpr, graphics:GetHeight() / dpr
end

local function MakeLabel(text, props)
    props = props or {}
    props.text = text
    props.fontFamily = "sans"
    return UI.Label(props)
end

local function SetWidgetPosition(widget, x, y, size)
    if widget then
        widget:SetStyle({ left = x - size * 0.5, top = y - size * 0.5 })
    end
end

local function DestroyEntityWidget(widget)
    if widget then
        widget:Destroy()
    end
end

local function ClearEntities()
    for _, enemy in ipairs(enemies_) do
        DestroyEntityWidget(enemy.widget)
    end
    for _, projectile in ipairs(projectiles_) do
        DestroyEntityWidget(projectile.widget)
    end
    enemies_ = {}
    projectiles_ = {}
end

local function ResetRunState()
    ClearEntities()
    worldWidth_, worldHeight_ = GetWorldSize()
    player_.x = worldWidth_ * 0.5
    player_.y = worldHeight_ * 0.5
    player_.integrity = player_.maxIntegrity
    player_.invulnerable = 0
    player_.fireTimer = 0
    runTime_ = 0
    spawnTimer_ = 0
    enemyId_ = 0
    score_ = 0
    defeatReason_ = ""
end

local function MakeLanguageButton(code, label)
    local isSelected = language_ == code
    return UI.Button {
        text = isSelected and ("✓  " .. label) or label,
        variant = isSelected and "success" or "secondary",
        width = "100%",
        height = 48,
        marginBottom = 10,
        fontSize = 15,
        onClick = function()
            language_ = code
            BuildUI()
        end,
    }
end

local function BuildLanguageScreen()
    local card = UI.Panel {
        width = "90%",
        maxWidth = 430,
        padding = 28,
        gap = 12,
        alignItems = "center",
        backgroundColor = { 20, 31, 58, 245 },
        borderRadius = 24,
        borderWidth = 1,
        borderColor = { 91, 124, 190, 180 },
        children = {
            MakeLabel("◆", { fontSize = 42, fontColor = { 255, 213, 83, 255 } }),
            MakeLabel(T("menu.title"), {
                fontSize = 30,
                fontWeight = "bold",
                fontColor = { 255, 255, 255, 255 },
                textAlign = "center",
            }),
            MakeLabel(T("menu.subtitle"), {
                fontSize = 15,
                fontColor = { 177, 196, 231, 255 },
                textAlign = "center",
                marginBottom = 12,
            }),
            UI.Panel {
                width = "100%",
                padding = 14,
                gap = 4,
                backgroundColor = { 11, 20, 42, 180 },
                borderRadius = 14,
                children = {
                    MakeLanguageButton("zh_CN", T("language.simplified_chinese")),
                    MakeLanguageButton("en", T("language.english")),
                },
            },
            MakeLabel(T("menu.ready"), {
                fontSize = 13,
                fontColor = { 146, 225, 191, 255 },
                textAlign = "center",
                marginTop = 8,
            }),
            UI.Button {
                text = T("menu.start"),
                variant = "primary",
                width = "100%",
                height = 50,
                marginTop = 4,
                fontSize = 16,
                onClick = function()
                    screen_ = "game"
                    ResetRunState()
                    BuildUI()
                end,
            },
        },
    }

    return UI.Panel {
        width = "100%",
        height = "100%",
        justifyContent = "center",
        alignItems = "center",
        padding = 20,
        children = { card },
    }
end

local function BuildGameScreen()
    gameWorld_ = UI.Panel {
        id = "gameWorld",
        position = "absolute",
        top = 0,
        left = 0,
        width = "100%",
        height = "100%",
        pointerEvents = "none",
        backgroundColor = { 9, 17, 37, 255 },
        overflow = "hidden",
    }

    playerWidget_ = UI.Panel {
        id = "player",
        position = "absolute",
        width = 32,
        height = 32,
        backgroundColor = { 82, 214, 255, 255 },
        borderColor = { 225, 250, 255, 255 },
        borderWidth = 2,
        borderRadius = 5,
        rotate = 45,
    }
    gameWorld_:AddChild(playerWidget_)

    scoreLabel_ = MakeLabel(T("game.score", score_), {
        fontSize = 15,
        fontWeight = "bold",
        fontColor = { 255, 230, 137, 255 },
    })
    integrityLabel_ = MakeLabel(T("game.integrity", player_.integrity, player_.maxIntegrity), {
        fontSize = 15,
        fontWeight = "bold",
        fontColor = { 146, 225, 191, 255 },
    })
    timeLabel_ = MakeLabel(T("game.time", 0), {
        fontSize = 15,
        fontWeight = "bold",
        fontColor = { 177, 196, 231, 255 },
    })

    return UI.Panel {
        width = "100%",
        height = "100%",
        pointerEvents = "box-none",
        children = {
            gameWorld_,
            UI.Panel {
                position = "absolute",
                top = 18,
                left = 18,
                right = 18,
                flexDirection = "row",
                justifyContent = "space-between",
                pointerEvents = "none",
                children = { integrityLabel_, scoreLabel_, timeLabel_ },
            },
            MakeLabel(T("game.hint"), {
                position = "absolute",
                bottom = 16,
                left = 0,
                right = 0,
                textAlign = "center",
                fontSize = 11,
                fontColor = { 131, 151, 190, 220 },
            }),
        },
    }
end

local function BuildDefeatScreen()
    return UI.Panel {
        width = "90%",
        maxWidth = 430,
        padding = 28,
        gap = 14,
        alignItems = "center",
        backgroundColor = { 30, 24, 54, 250 },
        borderRadius = 24,
        borderWidth = 1,
        borderColor = { 231, 109, 143, 200 },
        children = {
            MakeLabel(T("game.defeated"), {
                fontSize = 28,
                fontWeight = "bold",
                fontColor = { 255, 150, 170, 255 },
                textAlign = "center",
            }),
            MakeLabel(T("game.reason", T("game.reason_contact")), {
                fontSize = 14,
                fontColor = { 210, 201, 231, 255 },
                textAlign = "center",
                whiteSpace = "normal",
            }),
            MakeLabel(T("game.final_score", score_), {
                fontSize = 18,
                fontColor = { 255, 230, 137, 255 },
            }),
            UI.Button {
                text = T("game.restart"),
                variant = "primary",
                width = "100%",
                height = 48,
                onClick = function()
                    screen_ = "game"
                    ResetRunState()
                    BuildUI()
                end,
            },
            UI.Button {
                text = T("game.back"),
                variant = "secondary",
                width = "100%",
                height = 44,
                onClick = function()
                    screen_ = "language"
                    BuildUI()
                end,
            },
        },
    }
end

function BuildUI()
    local content
    if screen_ == "language" then
        content = BuildLanguageScreen()
    elseif screen_ == "game" then
        content = BuildGameScreen()
    else
        content = BuildDefeatScreen()
    end

    uiRoot_ = UI.Panel {
        width = "100%",
        height = "100%",
        backgroundGradient = {
            type = "linear",
            direction = "to-bottom-right",
            from = { 8, 18, 42, 255 },
            to = { 35, 20, 68, 255 },
        },
        pointerEvents = "box-none",
        children = { content },
    }
    UI.SetRoot(uiRoot_, true)

    if screen_ == "game" then
        SetWidgetPosition(playerWidget_, player_.x, player_.y, 32)
    end
end

local function SpawnEnemy()
    if not gameWorld_ or #enemies_ >= 20 then return end

    enemyId_ = enemyId_ + 1
    local side = (enemyId_ - 1) % 4
    local x, y
    if side == 0 then
        x, y = -30, math.random(30, math.max(31, math.floor(worldHeight_ - 30)))
    elseif side == 1 then
        x, y = worldWidth_ + 30, math.random(30, math.max(31, math.floor(worldHeight_ - 30)))
    elseif side == 2 then
        x, y = math.random(30, math.max(31, math.floor(worldWidth_ - 30))), -30
    else
        x, y = math.random(30, math.max(31, math.floor(worldWidth_ - 30))), worldHeight_ + 30
    end

    local widget = UI.Panel {
        position = "absolute",
        width = 24,
        height = 24,
        backgroundColor = { 244, 93, 133, 255 },
        borderColor = { 255, 190, 210, 255 },
        borderWidth = 2,
        borderRadius = 8,
        pointerEvents = "none",
    }
    gameWorld_:AddChild(widget)
    table.insert(enemies_, {
        x = x,
        y = y,
        radius = 12,
        speed = 52 + math.min(35, runTime_ * 0.8),
        integrity = 2,
        widget = widget,
    })
end

local function FindNearestEnemy()
    local nearest = nil
    local nearestDistance = math.huge
    for _, enemy in ipairs(enemies_) do
        local dx = enemy.x - player_.x
        local dy = enemy.y - player_.y
        local distance = dx * dx + dy * dy
        if distance < nearestDistance then
            nearest = enemy
            nearestDistance = distance
        end
    end
    return nearest
end

local function FireAtNearest()
    local target = FindNearestEnemy()
    if not target or not gameWorld_ then return end

    local dx = target.x - player_.x
    local dy = target.y - player_.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0 then return end

    local speed = 430
    local widget = UI.Panel {
        position = "absolute",
        width = 10,
        height = 10,
        backgroundColor = { 255, 224, 99, 255 },
        borderRadius = 5,
        pointerEvents = "none",
    }
    gameWorld_:AddChild(widget)
    table.insert(projectiles_, {
        x = player_.x,
        y = player_.y,
        vx = dx / length * speed,
        vy = dy / length * speed,
        radius = 5,
        damage = 1,
        life = 1.5,
        widget = widget,
    })
end

local function DamagePlayer()
    if player_.invulnerable > 0 or screen_ ~= "game" then return end
    player_.integrity = player_.integrity - 1
    player_.invulnerable = 0.65
    if integrityLabel_ then
        integrityLabel_:SetText(T("game.integrity", math.max(0, player_.integrity), player_.maxIntegrity))
    end
    if player_.integrity <= 0 then
        defeatReason_ = T("game.reason_contact")
        screen_ = "defeat"
        ClearEntities()
        BuildUI()
    end
end

local function UpdateMovement(timeStep)
    local dx, dy = 0, 0
    if keys_[KEY_A] or keys_[KEY_LEFT] then dx = dx - 1 end
    if keys_[KEY_D] or keys_[KEY_RIGHT] then dx = dx + 1 end
    if keys_[KEY_W] or keys_[KEY_UP] then dy = dy - 1 end
    if keys_[KEY_S] or keys_[KEY_DOWN] then dy = dy + 1 end

    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then
        player_.x = player_.x + dx / length * player_.speed * timeStep
        player_.y = player_.y + dy / length * player_.speed * timeStep
    end

    player_.x = math.max(player_.radius, math.min(worldWidth_ - player_.radius, player_.x))
    player_.y = math.max(player_.radius, math.min(worldHeight_ - player_.radius, player_.y))
    SetWidgetPosition(playerWidget_, player_.x, player_.y, 32)
end

local function UpdateEnemies(timeStep)
    for index = #enemies_, 1, -1 do
        local enemy = enemies_[index]
        local dx = player_.x - enemy.x
        local dy = player_.y - enemy.y
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then
            enemy.x = enemy.x + dx / distance * enemy.speed * timeStep
            enemy.y = enemy.y + dy / distance * enemy.speed * timeStep
        end
        SetWidgetPosition(enemy.widget, enemy.x, enemy.y, 24)

        if distance < player_.radius + enemy.radius then
            DamagePlayer()
            enemy.x = enemy.x - dx / math.max(distance, 1) * 22
            enemy.y = enemy.y - dy / math.max(distance, 1) * 22
        end
    end
end

local function UpdateProjectiles(timeStep)
    for projectileIndex = #projectiles_, 1, -1 do
        local projectile = projectiles_[projectileIndex]
        projectile.x = projectile.x + projectile.vx * timeStep
        projectile.y = projectile.y + projectile.vy * timeStep
        projectile.life = projectile.life - timeStep
        local removeProjectile = projectile.life <= 0

        for enemyIndex = #enemies_, 1, -1 do
            local enemy = enemies_[enemyIndex]
            local dx = enemy.x - projectile.x
            local dy = enemy.y - projectile.y
            if dx * dx + dy * dy < (enemy.radius + projectile.radius) ^ 2 then
                enemy.integrity = enemy.integrity - projectile.damage
                removeProjectile = true
                if enemy.integrity <= 0 then
                    score_ = score_ + 1
                    DestroyEntityWidget(enemy.widget)
                    table.remove(enemies_, enemyIndex)
                    if scoreLabel_ then scoreLabel_:SetText(T("game.score", score_)) end
                end
                break
            end
        end

        if removeProjectile then
            DestroyEntityWidget(projectile.widget)
            table.remove(projectiles_, projectileIndex)
        else
            SetWidgetPosition(projectile.widget, projectile.x, projectile.y, 10)
        end
    end
end

function HandleUpdate(_eventType, eventData)
    if screen_ ~= "game" then return end
    local timeStep = eventData["TimeStep"]:GetFloat()
    timeStep = math.min(timeStep, 0.05)
    runTime_ = runTime_ + timeStep
    player_.invulnerable = math.max(0, player_.invulnerable - timeStep)
    player_.fireTimer = player_.fireTimer - timeStep
    spawnTimer_ = spawnTimer_ - timeStep

    UpdateMovement(timeStep)
    if spawnTimer_ <= 0 then
        SpawnEnemy()
        spawnTimer_ = math.max(0.28, 0.9 - runTime_ * 0.006)
    end
    if player_.fireTimer <= 0 then
        FireAtNearest()
        player_.fireTimer = player_.fireInterval
    end
    UpdateEnemies(timeStep)
    UpdateProjectiles(timeStep)

    if integrityLabel_ then
        integrityLabel_:SetText(T("game.integrity", math.max(0, player_.integrity), player_.maxIntegrity))
    end
    if timeLabel_ then
        timeLabel_:SetText(T("game.time", math.floor(runTime_)))
    end
end

function HandleKeyDown(_eventType, eventData)
    local key = eventData["Key"]:GetInt()
    keys_[key] = true
    if key == KEY_ESCAPE and screen_ == "game" then
        screen_ = "language"
        ClearEntities()
        BuildUI()
    end
end

function HandleKeyUp(_eventType, eventData)
    local key = eventData["Key"]:GetInt()
    keys_[key] = false
end

function Start()
    graphics.windowTitle = "Geometry Breakout / 几何突围"
    UI.Init({
        theme = "default-dark",
        fonts = {
            { family = "sans", weights = { normal = "Fonts/MiSans-Regular.ttf" } },
        },
        scale = UI.Scale.DEFAULT,
    })
    input.mouseMode = MM_ABSOLUTE
    input.mouseVisible = true
    SubscribeToEvent("Update", "HandleUpdate")
    SubscribeToEvent("KeyDown", "HandleKeyDown")
    SubscribeToEvent("KeyUp", "HandleKeyUp")
    BuildUI()
    print("=== Geometry Breakout milestone 1 started ===")
end

function Stop()
    ClearEntities()
    UI.Shutdown()
end
