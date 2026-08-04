-- stages.lua
-- Stage -> Level -> Wave hierarchy
-- 2 stages, each with 10 levels, each level has 6 waves.

local M = {}

-- ── Stage definitions ──────────────────────────────────────────────────────
local STAGES = {
    {
        name        = { zh = "赤红竞技场", en = "Crimson Arena" },
        levels      = 10,                -- 10 levels per stage
        wavesPerLvl = 6,                 -- 6 waves per level
        -- Level → { name, totalWaves, midBossWave?, bossWave? }
        -- Every level has 6 waves. Mid-boss on wave 5, Boss on wave 6 (milestone levels).
        levelMap    = {
            [1]  = { name = { zh = "Lv.1 · 初试锋芒", en = "Lv.1 · Sharp Edge" },    totalWaves = 6 },
            [2]  = { name = { zh = "Lv.2 · 暗流涌动", en = "Lv.2 · Undercurrent" },   totalWaves = 6 },
            [3]  = { name = { zh = "Lv.3 · 血色黄昏", en = "Lv.3 · Blood Dusk" },      totalWaves = 6, midBossWave = 5 },
            [4]  = { name = { zh = "Lv.4 · 烈焰回廊", en = "Lv.4 · Flame Corridor" },   totalWaves = 6 },
            [5]  = { name = { zh = "Lv.5 · 狱火降临", en = "Lv.5 · Inferno Fall" },    totalWaves = 6, bossWave = 6 },
            [6]  = { name = { zh = "Lv.6 · 熔岩之心", en = "Lv.6 · Lava Heart" },      totalWaves = 6, midBossWave = 5 },
            [7]  = { name = { zh = "Lv.7 · 铁与火",   en = "Lv.7 · Iron & Fire" },     totalWaves = 6 },
            [8]  = { name = { zh = "Lv.8 · 燃烬之路", en = "Lv.8 · Burning Road" },    totalWaves = 6 },
            [9]  = { name = { zh = "Lv.9 · 焚天",     en = "Lv.9 · Sky Aflame" },      totalWaves = 6, midBossWave = 5 },
            [10] = { name = { zh = "Lv.10· 终焉红莲", en = "Lv.10· Crimson End" },      totalWaves = 6, bossWave = 6 },
        },
        -- Visual theme (red / orange)
        theme = {
            bgGradient  = { 8, 1, 4 },       -- dark crimson base
            floorColor   = { 60, 8, 6, 80 },
            borderColor  = { 255, 80, 30, 200 },
            ring1Color   = { 255, 100, 40, 80 },
            ring2Color   = { 255, 60, 10, 60 },
            accent       = { 255, 140, 30, 255 },
            accentDim    = { 255, 80, 20, 60 },
            bossAccent   = { 255, 30, 10, 255 },
        },
    },
    {
        name        = { zh = "虚空核心", en = "Void Core" },
        levels      = 10,
        wavesPerLvl = 6,
        levelMap    = {
            [1]  = { name = { zh = "Lv.1 · 虚空之门", en = "Lv.1 · Void Gate" },       totalWaves = 6 },
            [2]  = { name = { zh = "Lv.2 · 暗能涌动", en = "Lv.2 · Dark Surge" },       totalWaves = 6 },
            [3]  = { name = { zh = "Lv.3 · 深渊低语", en = "Lv.3 · Abyss Whisper" },    totalWaves = 6, midBossWave = 5 },
            [4]  = { name = { zh = "Lv.4 · 扭曲之径", en = "Lv.4 · Warped Path" },      totalWaves = 6 },
            [5]  = { name = { zh = "Lv.5 · 虚空领主", en = "Lv.5 · Void Lord" },        totalWaves = 6, bossWave = 6 },
            [6]  = { name = { zh = "Lv.6 · 紫色迷障", en = "Lv.6 · Violet Haze" },      totalWaves = 6, midBossWave = 5 },
            [7]  = { name = { zh = "Lv.7 · 数据洪流", en = "Lv.7 · Data Torrent" },     totalWaves = 6 },
            [8]  = { name = { zh = "Lv.8 · 虚空回声", en = "Lv.8 · Void Echo" },        totalWaves = 6 },
            [9]  = { name = { zh = "Lv.9 · 混沌边缘", en = "Lv.9 · Chaos Brink" },      totalWaves = 6, midBossWave = 5 },
            [10] = { name = { zh = "Lv.10· 绝对虚空", en = "Lv.10· Absolute Void" },     totalWaves = 6, bossWave = 6 },
        },
        -- Visual theme (purple / blue)
        theme = {
            bgGradient  = { 2, 0, 8 },
            floorColor   = { 25, 4, 50, 100 },
            borderColor  = { 160, 60, 255, 200 },
            ring1Color   = { 100, 40, 255, 80 },
            ring2Color   = { 180, 80, 255, 60 },
            accent       = { 180, 60, 255, 255 },
            accentDim    = { 120, 30, 180, 60 },
            bossAccent   = { 220, 60, 255, 255 },
        },
    },
}

-- ── Total stage count ──────────────────────────────────────────────────────

---Total number of stages in the game.
function M.total()
    return #STAGES
end

-- ── Stage-level helpers ────────────────────────────────────────────────────

---Get the stage name for a language.
---@param stageIdx number 1-based stage index
---@param lang string "zh" or "en"
function M.name(stageIdx, lang)
    local s = STAGES[stageIdx] or STAGES[1]
    return s.name[lang] or s.name.en or s.name.zh
end

---Get the number of levels in a stage.
function M.totalLevels(stageIdx)
    local s = STAGES[stageIdx] or STAGES[1]
    return s.levels
end

---Get the number of waves per level in a stage.
function M.wavesPerLevel(stageIdx)
    local s = STAGES[stageIdx] or STAGES[1]
    return s.wavesPerLvl or 6
end

---Get level config for a specific stage + level.
---@param stageIdx number 1-based stage index
---@param level number 1-based level index
---@return table|nil { name, totalWaves, midBossWave?, bossWave? }
function M.level(stageIdx, level)
    local s = STAGES[stageIdx] or STAGES[1]
    return s.levelMap[level] or s.levelMap[1]
end

---Get the level name for a language.
---@param stageIdx number
---@param level number
---@param lang string
function M.levelName(stageIdx, level, lang)
    local lvl = M.level(stageIdx, level)
    if not lvl then return "Level " .. level end
    return lvl.name[lang] or lvl.name.en or lvl.name.zh
end

---Get the stage visual theme.
---@param stageIdx number 1-based stage index
---@return table { bgGradient, floorColor, borderColor, ring1Color, ring2Color, accent, accentDim, bossAccent }
function M.theme(stageIdx)
    local s = STAGES[stageIdx] or STAGES[1]
    return s.theme
end

return M
