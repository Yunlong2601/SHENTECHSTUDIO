-- data/upgrades.lua
-- Upgrade card definitions — canonical upgrade data.
-- Migrated from scripts/main.lua PrepareUpgradeChoices().
--
-- Last updated: 2026-08-04 (P1 — Brotato Transition)

local M = {}

-- Legacy module upgrades (3 cards, will become 4-card stat/weapon in P5)
M.MODULES = {
    trace = {
        id          = "trace",
        titleKey    = "upgrade.trace",
        descKey     = "module.trace_desc",
        category    = "module",
        maxLevel    = 5,
    },
    orbit = {
        id          = "orbit",
        titleKey    = "upgrade.orbit",
        descKey     = "module.orbit_desc",
        category    = "module",
        maxLevel    = 5,
    },
    pulse = {
        id          = "pulse",
        titleKey    = "upgrade.pulse",
        descKey     = "module.pulse_desc",
        category    = "module",
        maxLevel    = 5,
    },
    shell = {
        id          = "shell",
        titleKey    = "upgrade.shell",
        descKey     = "module.shell_desc",
        category    = "module",
        maxLevel    = 5,
    },
    mine = {
        id          = "mine",
        titleKey    = "upgrade.mine",
        descKey     = "module.mine_desc",
        category    = "module",
        maxLevel    = 5,
    },
    hook = {
        id          = "hook",
        titleKey    = "upgrade.hook",
        descKey     = "module.hook_desc",
        category    = "module",
        maxLevel    = 5,
    },
    laser = {
        id          = "laser",
        titleKey    = "upgrade.laser",
        descKey     = "module.laser_desc",
        category    = "module",
        maxLevel    = 5,
    },
    poison = {
        id          = "poison",
        titleKey    = "upgrade.poison",
        descKey     = "module.poison_desc",
        category    = "module",
        maxLevel    = 5,
    },
}

-- Global stat upgrades (always available)
M.GLOBAL = {
    integrity = {
        id          = "integrity",
        titleKey    = "upgrade.integrity",
        descKey     = "upgrade.desc",
        category    = "global",
        effect      = { maxIntegrity = 1 },   -- +1 max HP
    },
    magnet = {
        id          = "magnet",
        titleKey    = "upgrade.magnet",
        descKey     = "upgrade.desc",
        category    = "global",
        effect      = { magnetRadius = 55 },   -- +55 pickup range
    },
}

-- All upgrade IDs (for Fisher-Yates shuffle)
M.ALL_IDS = { "trace", "orbit", "pulse", "shell", "mine", "hook", "laser", "poison", "integrity", "magnet" }

-- XP thresholds per level
-- levelGoal = 5 + level * 3
M.xpForLevel = function(level)
    return 5 + level * 3
end

-- Number of cards to show (3 → will become 4 in P5)
M.CARD_COUNT = 3

return M
