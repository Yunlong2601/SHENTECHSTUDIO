-- Geometry Breakout / 几何突围
-- Chinese-first, bilingual-ready prototype.

local UI = require("urhox-libs/UI")

local language_ = "zh_CN"
local screen_ = "language"
local score_ = 0
local uiRoot_ = nil

local TEXT = {
    zh_CN = {
        ["menu.title"] = "几何突围",
        ["menu.subtitle"] = "选择语言开始游戏",
        ["language.english"] = "English",
        ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "你的突围已经准备好了！",
        ["menu.start"] = "开始突围",
        ["prototype.objective"] = "收集几何能量",
        ["prototype.hint"] = "点击核心，测试双语游戏流程。",
        ["prototype.core"] = "◆",
        ["prototype.score"] = "能量：%d",
        ["menu.change_language"] = "更换语言",
        ["menu.reset"] = "重新开始",
        ["menu.footer"] = "几何突围 · TapTap Maker 原型",
    },
    en = {
        ["menu.title"] = "Geometry Breakout",
        ["menu.subtitle"] = "Choose your language to begin",
        ["language.english"] = "English",
        ["language.simplified_chinese"] = "简体中文",
        ["menu.ready"] = "Your breakout is ready!",
        ["menu.start"] = "Start Breakout",
        ["prototype.objective"] = "Collect geometric energy",
        ["prototype.hint"] = "Tap the core to test the bilingual game flow.",
        ["prototype.core"] = "◆",
        ["prototype.score"] = "Energy: %d",
        ["menu.change_language"] = "Change language",
        ["menu.reset"] = "Reset",
        ["menu.footer"] = "Geometry Breakout · TapTap Maker prototype",
    },
}

local function T(key, ...)
    local languageText = TEXT[language_] or TEXT.en
    local value = languageText[key] or TEXT.en[key] or key
    if select("#", ...) > 0 then
        return string.format(value, ...)
    end
    return value
end

local function MakeLabel(text, props)
    props = props or {}
    props.text = text
    props.fontFamily = "sans"
    return UI.Label(props)
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
            print("Language changed to " .. code)
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
        boxShadow = { { x = 0, y = 12, blur = 30, spread = 0, color = { 0, 0, 0, 90 } } },
        children = {
            MakeLabel("✦", { fontSize = 42, fontColor = { 255, 213, 83, 255 }, marginBottom = 2 }),
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
                    MakeLanguageButton("en", T("language.english")),
                    MakeLanguageButton("zh_CN", T("language.simplified_chinese")),
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
                    score_ = 0
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
    local scoreLabel = MakeLabel(T("prototype.score", score_), {
        id = "scoreLabel",
        fontSize = 18,
        fontWeight = "bold",
        fontColor = { 255, 230, 137, 255 },
    })

    local gameCard = UI.Panel {
        width = "90%",
        maxWidth = 520,
        padding = 26,
        gap = 14,
        alignItems = "center",
        backgroundColor = { 20, 31, 58, 245 },
        borderRadius = 24,
        borderWidth = 1,
        borderColor = { 91, 124, 190, 180 },
        children = {
            MakeLabel(T("prototype.objective"), {
                fontSize = 26,
                fontWeight = "bold",
                fontColor = { 255, 255, 255, 255 },
                textAlign = "center",
            }),
            MakeLabel(T("prototype.hint"), {
                fontSize = 14,
                fontColor = { 177, 196, 231, 255 },
                textAlign = "center",
                whiteSpace = "normal",
            }),
            UI.Panel {
                width = 190,
                height = 190,
                marginVertical = 14,
                justifyContent = "center",
                alignItems = "center",
                backgroundGradient = {
                    type = "radial",
                    innerRadius = 8,
                    outerRadius = 120,
                    from = { 255, 218, 102, 80 },
                    to = { 255, 218, 102, 0 },
                },
                children = {
                    UI.Button {
                        text = T("prototype.core"),
                        variant = "primary",
                        width = 120,
                        height = 120,
                        fontSize = 62,
                        textColor = { 255, 248, 214, 255 },
                        backgroundColor = { 244, 175, 52, 255 },
                        borderRadius = 60,
                        onClick = function()
                            score_ = score_ + 1
                            scoreLabel:SetText(T("prototype.score", score_))
                        end,
                    },
                },
            },
            scoreLabel,
            UI.Panel {
                width = "100%",
                flexDirection = "row",
                gap = 10,
                marginTop = 6,
                children = {
                    UI.Button {
                        text = T("menu.reset"),
                        variant = "secondary",
                        flexGrow = 1,
                        onClick = function()
                            score_ = 0
                            scoreLabel:SetText(T("prototype.score", score_))
                        end,
                    },
                    UI.Button {
                        text = T("menu.change_language"),
                        variant = "secondary",
                        flexGrow = 1,
                        onClick = function()
                            screen_ = "language"
                            BuildUI()
                        end,
                    },
                },
            },
        },
    }

    return UI.Panel {
        width = "100%",
        height = "100%",
        justifyContent = "center",
        alignItems = "center",
        padding = 20,
        children = { gameCard },
    }
end

function BuildUI()
    local content = screen_ == "language" and BuildLanguageScreen() or BuildGameScreen()
    local footer = MakeLabel(T("menu.footer"), {
        position = "absolute",
        bottom = 16,
        left = 0,
        right = 0,
        textAlign = "center",
        fontSize = 11,
        fontColor = { 131, 151, 190, 220 },
    })

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
        children = { content, footer },
    }
    UI.SetRoot(uiRoot_, true)
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
    BuildUI()
    print("=== Geometry Breakout started: 简体中文 + English ===")
end

function Stop()
    UI.Shutdown()
end
