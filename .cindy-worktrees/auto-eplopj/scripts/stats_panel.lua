-- stats_panel.lua
-- Right-side stats panel — real-time values (P5).
-- Shows 8 stat axes: Primary (HP/DMG/SPD/RNG) + Secondary (CRT/DDG/MOV/LCK).
-- Updates via refresh() called from ui.update_hud() each frame.

local UI = require("urhox-libs/UI")
local state = require("state")
local stat_items = require("data.stat_items")

local M = {}

local function label(text, props)
    props = props or {}
    props.text = text
    props.fontFamily = "sans"
    props.pointerEvents = "none"
    return UI.Label(props)
end

-- Stored label refs for real-time refresh
M._valueLabels = {}   -- { [statKey] = Label }
M._goldLabel = nil

-- ── Single stat row ──────────────────────────────────────────────────────
local function stat_row(icon, abbr, value, color, statKey)
    local valLabel = label(tostring(value or 0),
        { fontSize = 13, fontWeight = "bold", fontColor = { 255, 255, 255, 255 } })
    if statKey then
        M._valueLabels[statKey] = valLabel
    end
    return UI.Panel {
        width = "100%", flexDirection = "row", justifyContent = "space-between",
        alignItems = "center", padding = { top = 2, bottom = 2 },
        children = {
            UI.Panel {
                flexDirection = "row", alignItems = "center", gap = 4,
                children = {
                    label(icon or "·", { fontSize = 11, fontColor = color or { 200, 200, 200, 200 } }),
                    label(abbr or "---", { fontSize = 11, fontWeight = "bold", fontColor = color or { 180, 190, 210, 255 } }),
                },
            },
            valLabel,
        },
    }
end

-- ── Panel builder — called from ui.lua game_screen() ────────────────────
function M.build()
    -- Clear old refs
    M._valueLabels = {}

    local p = state.player_
    local gold = p and p.gold_ or 0
    M._goldLabel = label("G " .. tostring(gold),
        { fontSize = 13, fontWeight = "bold", fontColor = { 255, 214, 92, 255 } })

    return UI.Panel {
        position = "absolute",
        top = 14, right = 16,
        width = 140, padding = 10, gap = 2,
        backgroundGradient = { type = "linear", direction = "to-bottom-right",
            from = { 8, 20, 45, 200 }, to = { 10, 16, 38, 200 } },
        borderColor = { 60, 90, 140, 120 },
        borderWidth = 1, borderRadius = 12,
        pointerEvents = "none",
        children = {
            -- Primary stats
            label("PRIMARY", { fontSize = 10, fontWeight = "bold",
                fontColor = { 146, 225, 191, 200 }, marginBottom = 2 }),
            stat_row("❤", "HP", 0,  { 255, 85, 85, 255 },   "maxHP"),
            stat_row("⚔", "DMG", 0,  { 255, 170, 51, 255 },  "damage"),
            stat_row("⏱", "SPD", 0,  { 51, 255, 136, 255 },  "attackSpeed"),
            stat_row("🎯", "RNG", 0,  { 51, 153, 255, 255 },  "range"),

            -- Divider
            UI.Panel { width = "100%", height = 1, marginTop = 4, marginBottom = 2,
                backgroundColor = { 60, 90, 140, 80 }, pointerEvents = "none" },

            -- Secondary stats
            label("SECONDARY", { fontSize = 10, fontWeight = "bold",
                fontColor = { 177, 196, 231, 200 }, marginBottom = 2 }),
            stat_row("💥", "CRT", 0,  { 255, 221, 68, 255 },  "critChance"),
            stat_row("👟", "DDG", 0,  { 170, 102, 255, 255 },  "dodge"),
            stat_row("🏃", "MOV", 0,  { 68, 221, 221, 255 },   "moveSpeed"),
            stat_row("🍀", "LCK", 0,  { 255, 136, 204, 255 },  "luck"),

            -- Divider
            UI.Panel { width = "100%", height = 1, marginTop = 4, marginBottom = 2,
                backgroundColor = { 60, 90, 140, 80 }, pointerEvents = "none" },

            -- Gold display
            M._goldLabel,
        },
    }
end

-- ── Refresh: update label texts from state.statAxes_ ────────────────────
function M.refresh()
    local axes = state.statAxes_ or {}
    for key, w in pairs(M._valueLabels) do
        local val = axes[key] or 0
        local sdef = stat_items.DEFS[key]
        if sdef and sdef.displayFn then
            w:SetText(sdef.icon .. " " .. sdef.displayFn(val))
        else
            w:SetText(tostring(val))
        end
    end
    if M._goldLabel then
        local gold = state.player_.gold_ or 0
        M._goldLabel:SetText("G " .. tostring(gold))
    end
end

return M
