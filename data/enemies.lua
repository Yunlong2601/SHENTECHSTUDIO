-- data/enemies.lua
-- Enemy type definitions — canonical data source.
-- Migrated from scripts/enemies.lua hardcoded values.
-- Loaded by: scripts/enemies.lua (optional, for data-driven spawning)
--
-- Last updated: 2026-08-04 (P1 — Brotato Transition)

local M = {}

M.TYPES = {
    chaser = {
        name        = { zh = "追猎体", en = "Chaser" },
        color       = { 244, 93, 133, 255 },     -- red-pink
        borderColor = { 255, 180, 200, 255 },
        size        = 24,
        borderRadius = 2,
        rotate      = 0,
        baseSpeed   = 52,
        baseHP      = 2,
        behavior    = "pursuit",                  -- direct chase
        spawnWeight = {  -- wave → weight
            [1] = 0.55, [3] = 0.45, [5] = 0.30,
        },
    },
    skimmer = {
        name        = { zh = "掠行体", en = "Skimmer" },
        color       = { 84, 216, 194, 255 },     -- teal
        borderColor = { 150, 255, 230, 255 },
        size        = 24,
        borderRadius = 12,                         -- circle
        rotate      = 0,
        baseSpeed   = 46,
        baseHP      = 2,
        behavior    = "flank",                     -- lateral approach
        spawnWeight = {
            [1] = 0.45, [3] = 0.25, [5] = 0.22,
        },
    },
    charger = {
        name        = { zh = "蓄能体", en = "Charger" },
        color       = { 255, 168, 76, 255 },     -- orange
        borderColor = { 255, 220, 150, 255 },
        size        = 28,
        borderRadius = 3,
        rotate      = 45,                          -- diamond
        baseSpeed   = 40,
        baseHP      = 2,
        behavior    = "charge",                    -- pause then dash
        spawnWeight = {
            [3] = 0.20, [5] = 0.15,
        },
    },
    splitter = {
        name        = { zh = "分裂体", en = "Splitter" },
        color       = { 100, 220, 100, 255 },    -- green
        borderColor = { 180, 255, 150, 255 },
        size        = 26,
        borderRadius = 6,
        rotate      = 0,
        baseSpeed   = 44,
        baseHP      = 3,
        behavior    = "split",                     -- splits into fragments on death
        spawnWeight = {
            [3] = 0.10, [5] = 0.10,
        },
    },
    shooter = {
        name        = { zh = "射击体", en = "Shooter" },
        color       = { 180, 130, 240, 255 },    -- purple
        borderColor = { 210, 170, 255, 255 },
        size        = 26,
        borderRadius = 10,                         -- round rect
        rotate      = 0,
        baseSpeed   = 30,
        baseHP      = 2,
        behavior    = "shoot",                     -- keeps distance, fires projectiles
        spawnWeight = {
            [5] = 0.23,
        },
    },
}

-- Stage scale multipliers per stage (index 1 = stage 1)
-- speed_mult: enemy speed multiplier
-- hp_mult: enemy HP multiplier
M.STAGE_SCALE = {
    { speed = 1.00, hp = 1.00 },  -- Stage 1
    { speed = 1.05, hp = 1.15 },  -- Stage 2
}

return M
