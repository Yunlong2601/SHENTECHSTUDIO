-- state.lua
-- Single source of truth for all mutable cross-module state.
-- One instance is required by every module; all reads/writes go through `state.X`.
-- Discipline rule (from plan §5):
--   - Read freely from any module.
--   - Write only inside state.lua (declarations / reset functions) or the owning module
--     (player.lua writes state.player_.*, enemies.lua writes state.enemies_.*, etc.).
--   - Cross-module writes go through a function on the owning module.

local M = {}

-- ─── Screen state machine constants (FSM) ───────────────────────────────
M.SCREEN_LANGUAGE  = "language"
M.SCREEN_GAME      = "game"
M.SCREEN_UPGRADE   = "upgrade"
M.SCREEN_WAVE_PAUSE = "wave_pause"
M.SCREEN_ARCHIVE   = "archive"
M.SCREEN_SUMMARY   = "summary"

-- ─── Language & current screen ───────────────────────────────────────────
---@type string
M.language_ = "zh_CN"
---@type string
M.screen_ = M.SCREEN_LANGUAGE
M.metaScreenReturn_ = M.SCREEN_LANGUAGE

-- ─── UI root + game world widgets ────────────────────────────────────────
---@type Widget|nil
M.uiRoot_ = nil
---@type Widget|nil
M.gameWorld_ = nil

-- ─── Player widgets ─────────────────────────────────────────────────────
---@type Widget|nil
M.playerWidget_ = nil
---@type Widget|nil
M.orbitWidget_ = nil
---@type Widget|nil
M.orbitWidget2_ = nil
---@type Widget|nil
M.shellRing_ = nil

-- ─── HUD widgets ────────────────────────────────────────────────────────
---@type Label|nil
M.hudLabel_ = nil
---@type Label|nil
M.waveLabel_ = nil
---@type Label|nil
M.xpLabel_ = nil
---@type Widget|nil
M.xpBarFill_ = nil
---@type Label|nil
M.shellLabel_ = nil
---@type Widget|nil
M.shellBarFill_ = nil
---@type Label|nil
M.moduleLabel_ = nil
---@type Label|nil
M.feedbackLabel_ = nil

-- ─── Touch / joystick widgets ────────────────────────────────────────────
---@type Widget|nil
M.touchSurface_ = nil
---@type Widget|nil
M.joystickBase_ = nil
---@type Widget|nil
M.joystickKnob_ = nil

-- ─── Keyboard input (key-down table) ────────────────────────────────────
---@type table<number, boolean>
M.keys_ = {}

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
M.player_ = {
    x = 0, y = 0, radius = 16, speed = 220,
    integrity = 5, maxIntegrity = 5, invulnerable = 0,
    fireTimer = 0, pulseTimer = 0, orbitAngle = 0,
    magnetRadius = 110, damage = 1,
    shell = 0, maxShell = 0, shellRechargeTimer = 0, shellFlash = 0,
    mineCooldown = 0, trailTimer = 0,
}

-- ─── Entity lists (flat per plan §4 — Component) ─────────────────────────
---@type table
M.enemies_ = {}
---@type table
M.projectiles_ = {}
---@type table
M.pickups_ = {}
---@type table
M.mines_ = {}
---@type table
M.trail_ = {}

-- ─── Module state ───────────────────────────────────────────────────────
---@type table<string, number>
M.moduleLevels_ = { trace = 1, orbit = 0, pulse = 0, shell = 0, mine = 0, hook = 0 }
---@type table<string, boolean>
M.activeModules_ = { trace = true, orbit = false, pulse = false, shell = false, mine = false, hook = false }

-- ─── Wave / modifier / run scalars ──────────────────────────────────────
M.modifier_ = "compression"
---@type number
M.surgeTimer_ = 0
---@type number
M.surgeFlash_ = 0
---@type number
M.runTime_ = 0
---@type number
M.waveTime_ = 0
---@type number
M.spawnTimer_ = 0
---@type number
M.enemyId_ = 0
---@type number
M.score_ = 0
---@type number
M.dataFragments_ = 0
---@type number
M.patternShards_ = 0
---@type number
M.level_ = 1
---@type number
M.levelProgress_ = 0
---@type number
M.levelGoal_ = 5
---@type number
M.wave_ = 1
---@type number
M.maxWaves_ = 6
---@type number
M.waveDuration_ = 18
---@type number
M.waveSpawned_ = 0
---@type number
M.waveSpawnTarget_ = 10
---@type number
M.wavePauseTimer_ = 0
---@type number
M.eliteCount_ = 0
---@type string
M.defeatReason_ = ""
M.chosenModule_ = ""
---@type number
M.moduleLevel_ = 0
M.upgradeCards_ = {}
M.summaryAwarded_ = false

-- ─── Profile (session-only — no verified storage API) ───────────────────
---@class MetaProfile
---@field calibration number
---@field startingIntegrity number
---@field magnet number
---@type MetaProfile
M.profile_ = { calibration = 0, startingIntegrity = 0, magnet = 0 }

-- ─── Touch state (consumed by player.lua; kept here for now) ────────────
---@type number|nil
M.touchPointerId_ = nil
M.touchActive_ = false
---@type number
M.touchStartX_ = 0
---@type number
M.touchStartY_ = 0
---@type number
M.touchX_ = 0
---@type number
M.touchY_ = 0
---@type number
M.touchRadius_ = 72

-- ─── World dimensions (refreshed on ResetRunState) ───────────────────────
---@type number
M.worldWidth_ = 800
---@type number
M.worldHeight_ = 600

-- ─── MVC observer flag (plan §4 — Observer pattern) ─────────────────────
-- Set to true by any system that mutates HUD-visible state.
-- ui.update_hud() reads this and short-circuits when nothing changed;
-- resets to false at the end of ui.update_hud().
M.dirty_hud = true

return M
