-- stat_items.lua — Brotato-style stat axis definitions (P5)
-- Each stat axis: key, icon, name_i18n, per-point effect, color, max cap

local M = {}

-- Ordered list of all 8 axes (display order: Primary then Secondary)
M.ORDER = {
  "maxHP", "damage", "attackSpeed", "range",       -- Primary
  "critChance", "dodge", "moveSpeed", "luck",       -- Secondary
}

-- Full definitions
M.DEFS = {
  maxHP = {
    key = "maxHP", icon = "❤", nameKey = "stat.hp_name",
    descKey = "stat.hp_desc", valuePerPoint = 2,
    color = { 255, 85, 85, 255 }, displayUnit = "",
    displayFn = function(v) return "+" .. (v * 2) end,
  },
  damage = {
    key = "damage", icon = "⚔", nameKey = "stat.dmg_name",
    descKey = "stat.dmg_desc", valuePerPoint = 1,
    color = { 255, 170, 51, 255 }, displayUnit = "",
    displayFn = function(v) return "+" .. v end,
  },
  attackSpeed = {
    key = "attackSpeed", icon = "⏱", nameKey = "stat.spd_name",
    descKey = "stat.spd_desc", valuePerPoint = 1,   -- ~4% per point via formula
    color = { 51, 255, 136, 255 }, displayUnit = "%",
    displayFn = function(v) return "+" .. (v * 4) .. "%" end,
  },
  range = {
    key = "range", icon = "🎯", nameKey = "stat.rng_name",
    descKey = "stat.rng_desc", valuePerPoint = 1,   -- ~5% per point
    color = { 51, 153, 255, 255 }, displayUnit = "%",
    displayFn = function(v) return "+" .. (v * 5) .. "%" end,
  },
  critChance = {
    key = "critChance", icon = "💥", nameKey = "stat.crt_name",
    descKey = "stat.crt_desc", valuePerPoint = 1,   -- +4% per point (capped to 95%)
    color = { 255, 221, 68, 255 }, displayUnit = "%",
    displayFn = function(v) return math.min(v * 4, 95) .. "%" end,
  },
  dodge = {
    key = "dodge", icon = "👟", nameKey = "stat.ddg_name",
    descKey = "stat.ddg_desc", valuePerPoint = 1,   -- +4% per point (capped to 60%)
    color = { 170, 102, 255, 255 }, displayUnit = "%",
    displayFn = function(v) return math.min(v * 4, 60) .. "%" end,
  },
  moveSpeed = {
    key = "moveSpeed", icon = "🏃", nameKey = "stat.mov_name",
    descKey = "stat.mov_desc", valuePerPoint = 1,   -- +5% per point
    color = { 68, 221, 221, 255 }, displayUnit = "%",
    displayFn = function(v) return "+" .. (v * 5) .. "%" end,
  },
  luck = {
    key = "luck", icon = "🍀", nameKey = "stat.lck_name",
    descKey = "stat.lck_desc", valuePerPoint = 1,   -- +1 luck, affects drops
    color = { 255, 136, 204, 255 }, displayUnit = "",
    displayFn = function(v) return tostring(v) end,
  },
}

-- Effective combat formulas (P5.2)
-- damage multiplier:      1 + statAxes_.damage * 0.08     (8% per point)
-- attackSpeed multiplier: 1 / (1 + statAxes_.attackSpeed * 0.04)
-- range multiplier:       1 + statAxes_.range * 0.05      (5% per point)
-- crit chance:            statAxes_.critChance * 0.04      (4% per point, cap 0.95)
-- crit damage mult:       1.5
-- dodge chance:           statAxes_.dodge * 0.04          (4% per point, cap 0.60)
-- moveSpeed multiplier:   1 + statAxes_.moveSpeed * 0.05   (5% per point)
-- maxHP bonus:            statAxes_.maxHP * 2             (+2 HP per point)
-- luck gold mult:         1 + statAxes_.luck * 0.15        (+15% gold per point)

return M
