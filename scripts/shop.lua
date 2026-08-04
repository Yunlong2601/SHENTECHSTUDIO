-- shop.lua — Inter-wave shop (P6: fully functional buy/reroll/lock/skip)
-- Brotato-style: 3 weapons + 3 stat items per screen.
-- Appears after every wave. No timer — player skips when ready.
--
-- Architecture:
--   state.shop_ holds runtime shop inventory.
--   shop.build() renders from state.shop_ (called by BuildUI when screen == "shop").
--   On buy/reroll/lock: mutate state, call _rebuild() to refresh UI.
--   On skip: call _begin_wave() or _advance_level() then _rebuild().
--
-- Last updated: 2026-08-04 (P6)

local UI = require("urhox-libs/UI")
local state = require("state")
local weapons = require("weapons")
local stat_items = require("data.stat_items")

local M = {}

-- ── Callbacks wired from main.lua ────────────────────────────────────────
local _rebuild, _begin_wave, _advance_level, _T

function M.configure(cfg)
    _rebuild = cfg.rebuild
    _begin_wave = cfg.beginWave
    _advance_level = cfg.advanceLevel
    _T = cfg.T
end

-- ── Helpers ──────────────────────────────────────────────────────────────

local function T(key, ...)
    if _T then return _T(key, ...) end
    return key
end

local function label(text, props)
    props = props or {}
    props.text = text
    props.fontFamily = "sans"
    return UI.Label(props)
end

-- ── Pricing ──────────────────────────────────────────────────────────────

---Weapon base prices by type. P9: aligned with combat value —
---  Bow (highest DPS, single-target) = 15g entry ranged.
---  Blade (fast melee crowd) = 15g entry melee.
---  Thrown (mid-range multi-pierce) = 25g.
---  Crossbow (long-range pierce) = 30g.
---  Blunt (heavy melee CC) = 35g.
---  Staff (AoE splash) = 35g.
local WEAPON_PRICES = {
    blade = 15, bow = 15,
    thrown = 25, crossbow = 30,
    blunt = 35, staff = 35,
}

---One-time unlock costs. [PLACEHOLDER · pending economy playtest]
---Rationale: 2g reroll = ~1 wave's gold; 3g lock = ~1.5 waves' gold.
---These are early-game gold sinks that create a real decision:
---"unlock shop tools now vs. buy items now."
local UNLOCK_REROLL_COST = 2
local UNLOCK_LOCK_COST   = 3
local MAX_LOCKS          = 1  -- max locked cards per shop visit

---Stat item price: 10 + (current stat level × 5).
local function stat_price(statKey)
    local cur = state.statAxes_[statKey] or 0
    return 10 + cur * 5
end

-- ── Shop inventory generation ────────────────────────────────────────────

---Populate state.shop_ with 3 weapons + 3 stat items.
function M.generate_items()
    if not state.shop_ then state.shop_ = {} end
    state.shop_.rerollCount = 0
    state.shop_.isOpen = true

    -- 3 random weapons (no duplicates within same shop)
    local weaponIds = {}
    for id, _ in pairs(weapons.all_defs()) do table.insert(weaponIds, id) end
    state.shop_.weapons = {}
    local usedW = {}
    for i = 1, 3 do
        local wid
        repeat
            wid = weaponIds[math.random(1, #weaponIds)]
        until not usedW[wid]
        usedW[wid] = true
        table.insert(state.shop_.weapons, {
            id = wid,
            price = WEAPON_PRICES[wid] or 20,
            locked = false,
        })
    end

    -- 3 random stat items (no duplicates within same shop)
    local allStats = {}
    for _, key in ipairs(stat_items.ORDER) do table.insert(allStats, key) end
    state.shop_.items = {}
    local usedS = {}
    for i = 1, 3 do
        local skey
        repeat
            skey = allStats[math.random(1, #allStats)]
        until not usedS[skey]
        usedS[skey] = true
        table.insert(state.shop_.items, {
            statKey = skey,
            price = stat_price(skey),
            locked = false,
        })
    end
end

-- ── Shop actions ─────────────────────────────────────────────────────────

---Unlock reroll capability (one-time cost per run).
function M.unlock_reroll()
    if state.shop_.rerollUnlocked then return end
    local gold = state.player_.gold_ or 0
    if gold < UNLOCK_REROLL_COST then return end
    state.player_.gold_ = gold - UNLOCK_REROLL_COST
    state.shop_.rerollUnlocked = true
    if _rebuild then _rebuild() end
end

---Unlock lock capability (one-time cost per run).
function M.unlock_lock()
    if state.shop_.lockUnlocked then return end
    local gold = state.player_.gold_ or 0
    if gold < UNLOCK_LOCK_COST then return end
    state.player_.gold_ = gold - UNLOCK_LOCK_COST
    state.shop_.lockUnlocked = true
    if _rebuild then _rebuild() end
end

---Buy a weapon or stat item by index.
---@param index number  1-based index into weapons[] or items[]
---@param category string  "weapon" | "item"
function M.buy(index, category)
    local list = category == "weapon" and state.shop_.weapons or state.shop_.items
    if not list or not list[index] then return end

    local entry = list[index]
    local gold = state.player_.gold_ or 0
    if gold < entry.price then return end  -- can't afford

    state.player_.gold_ = gold - entry.price

    if category == "weapon" then
        if weapons.find_empty() == nil then return end  -- all 6 slots full
        weapons.equip(entry.id)
    elseif category == "item" then
        state.statAxes_[entry.statKey] = (state.statAxes_[entry.statKey] or 0) + 1
        -- Immediate HP application
        if entry.statKey == "maxHP" then
            state.player_.maxIntegrity = state.player_.maxIntegrity + 2
            state.player_.integrity = state.player_.maxIntegrity
        end
    end

    -- Remove purchased item from shop; refresh remaining stat item prices
    table.remove(list, index)
    if category == "item" then
        for _, it in ipairs(state.shop_.items) do
            it.price = stat_price(it.statKey)
        end
    end

    if _rebuild then _rebuild() end
end

---Reroll all non-locked items. Cost = 1 + rerollCount. Requires unlock.
function M.reroll()
    if not state.shop_.rerollUnlocked then return end
    local cost = 1 + state.shop_.rerollCount
    local gold = state.player_.gold_ or 0
    if gold < cost then return end

    state.player_.gold_ = gold - cost
    state.shop_.rerollCount = state.shop_.rerollCount + 1

    -- Preserve locked items
    local lockedW, lockedS = {}, {}
    for _, w in ipairs(state.shop_.weapons) do
        if w.locked then table.insert(lockedW, w) end
    end
    for _, it in ipairs(state.shop_.items) do
        if it.locked then table.insert(lockedS, it) end
    end

    -- Regenerate weapons (fill up to 3, avoid duplicating locked ones)
    local weaponIds = {}
    for id, _ in pairs(weapons.all_defs()) do table.insert(weaponIds, id) end
    state.shop_.weapons = {}
    local usedW = {}
    for _, lw in ipairs(lockedW) do
        table.insert(state.shop_.weapons, lw)
        usedW[lw.id] = true
    end
    while #state.shop_.weapons < 3 do
        local wid
        repeat
            wid = weaponIds[math.random(1, #weaponIds)]
        until not usedW[wid]
        usedW[wid] = true
        table.insert(state.shop_.weapons, {
            id = wid,
            price = WEAPON_PRICES[wid] or 20,
            locked = false,
        })
    end

    -- Regenerate stat items (fill up to 3)
    local allStats = {}
    for _, key in ipairs(stat_items.ORDER) do table.insert(allStats, key) end
    state.shop_.items = {}
    local usedS = {}
    for _, li in ipairs(lockedS) do
        table.insert(state.shop_.items, li)
        usedS[li.statKey] = true
    end
    while #state.shop_.items < 3 do
        local skey
        repeat
            skey = allStats[math.random(1, #allStats)]
        until not usedS[skey]
        usedS[skey] = true
        table.insert(state.shop_.items, {
            statKey = skey,
            price = stat_price(skey),
            locked = false,
        })
    end

    if _rebuild then _rebuild() end
end

---Toggle lock on a weapon or stat item. Requires unlock; max 1 locked card.
function M.toggle_lock(index, category)
    if not state.shop_.lockUnlocked then return end
    local list = category == "weapon" and state.shop_.weapons or state.shop_.items
    if not list or not list[index] then return end
    -- Enforce max locks when locking a new card
    if not list[index].locked then
        local lockedCount = 0
        for _, w in ipairs(state.shop_.weapons) do if w.locked then lockedCount = lockedCount + 1 end end
        for _, it in ipairs(state.shop_.items) do if it.locked then lockedCount = lockedCount + 1 end end
        if lockedCount >= MAX_LOCKS then return end
    end
    list[index].locked = not list[index].locked
    if _rebuild then _rebuild() end
end

---Skip shop — advance to next wave (or next level if this was the final wave).
function M.skip()
    if state.shop_._advanceAfter then
        state.shop_._advanceAfter = false
        if _advance_level then
            _advance_level()
        end
    else
        if _begin_wave then
            _begin_wave()
        end
    end
    state.shop_.isOpen = false
    if _rebuild then _rebuild() end
end

-- ── UI Builders ──────────────────────────────────────────────────────────

local COLOR_AFFORD = { 146, 225, 191, 255 }   -- green highlight when affordable
local COLOR_EXPENSIVE = { 180, 180, 190, 180 }  -- greyed out when can't afford
local COLOR_GOLD = { 255, 215, 50, 255 }
local COLOR_LOCKED = { 255, 180, 60, 255 }     -- orange lock indicator
local COLOR_BG = { 12, 22, 45, 220 }

---Render a weapon card with buy + lock buttons.
local function weapon_card(index, w)
    local def = weapons.get_def(w.id)
    if not def then return UI.Panel {} end

    local gold = state.player_.gold_ or 0
    local canAfford = gold >= w.price
    local slotsFull = weapons.find_empty() == nil

    -- Tag label color by weapon type
    local tagColor = { 180, 190, 210, 255 }
    if def.tag == "melee" then tagColor = { 255, 170, 80, 255 }
    elseif def.tag == "magic" then tagColor = { 180, 120, 255, 255 }
    end

    return UI.Panel {
        width = "31%", minHeight = 130, padding = 8, gap = 4,
        alignItems = "center", justifyContent = "space-between",
        backgroundColor = COLOR_BG,
        borderColor = w.locked and { 255, 180, 60, 200 } or { 80, 120, 180, 150 },
        borderWidth = w.locked and 2 or 1,
        borderRadius = 10,
        children = {
            -- Weapon name
            label(def.name or w.id,
                { fontSize = 13, fontWeight = "bold",
                  fontColor = { 220, 235, 255, 255 }, textAlign = "center" }),
            -- Tag
            label(def.tag:upper() or "",
                { fontSize = 9, fontColor = tagColor, textAlign = "center" }),
            -- Stats: DMG on one line, CD on another
            label(string.format("DMG %.1f", def.damage),
                { fontSize = 10, fontColor = { 200, 210, 230, 255 }, textAlign = "center" }),
            label(string.format("CD %.2fs", def.cooldown),
                { fontSize = 10, fontColor = { 150, 170, 200, 255 }, textAlign = "center" }),
            -- Lock indicator
            w.locked and label("🔒",
                { fontSize = 10, fontColor = COLOR_LOCKED, textAlign = "center" }) or nil,
            -- Buy button
            UI.Button {
                text = slotsFull and "FULL" or string.format("BUY  %dg", w.price),
                variant = (canAfford and not slotsFull) and "primary" or "secondary",
                height = 32, minWidth = 70, fontSize = 11,
                opacity = (canAfford and not slotsFull) and 1 or 0.5,
                onClick = function() M.buy(index, "weapon") end,
            },
            -- Lock toggle (only when lock is unlocked)
            state.shop_.lockUnlocked and UI.Button {
                text = w.locked and "🔒" or "🔓",
                variant = "secondary",
                height = 24, minWidth = 40, fontSize = 10,
                onClick = function() M.toggle_lock(index, "weapon") end,
            } or nil,
        },
    }
end

---Render a stat item card with buy + lock buttons.
local function stat_card(index, item)
    local sdef = stat_items.DEFS[item.statKey]
    if not sdef then return UI.Panel {} end

    local gold = state.player_.gold_ or 0
    local canAfford = gold >= item.price
    local cur = state.statAxes_[item.statKey] or 0
    local nextVal = cur + 1

    return UI.Panel {
        width = "31%", minHeight = 130, padding = 8, gap = 4,
        alignItems = "center", justifyContent = "space-between",
        backgroundColor = COLOR_BG,
        borderColor = item.locked and { 255, 180, 60, 200 } or { sdef.color[1] * 0.5, sdef.color[2] * 0.5, sdef.color[3] * 0.5, 150 },
        borderWidth = item.locked and 2 or 1,
        borderRadius = 10,
        children = {
            -- Stat icon + name
            label(sdef.icon .. " " .. (T(sdef.nameKey) or item.statKey),
                { fontSize = 12, fontWeight = "bold",
                  fontColor = sdef.color, textAlign = "center" }),
            -- Current → Next value
            label(sdef.displayFn(cur) .. " → " .. sdef.displayFn(nextVal),
                { fontSize = 11, fontColor = { 220, 235, 255, 255 }, textAlign = "center" }),
            -- Descriptor
            label(T(sdef.descKey) or "",
                { fontSize = 9, fontColor = { 150, 170, 200, 255 }, textAlign = "center" }),
            -- Lock indicator
            item.locked and label("🔒",
                { fontSize = 10, fontColor = COLOR_LOCKED, textAlign = "center" }) or nil,
            -- Buy button
            UI.Button {
                text = string.format("BUY  %dg", item.price),
                variant = canAfford and "primary" or "secondary",
                height = 32, minWidth = 70, fontSize = 11,
                opacity = canAfford and 1 or 0.5,
                onClick = function() M.buy(index, "item") end,
            },
            -- Lock toggle (only when lock is unlocked)
            state.shop_.lockUnlocked and UI.Button {
                text = item.locked and "🔒" or "🔓",
                variant = "secondary",
                height = 24, minWidth = 40, fontSize = 10,
                onClick = function() M.toggle_lock(index, "item") end,
            } or nil,
        },
    }
end

-- ── Main shop screen builder ─────────────────────────────────────────────

function M.build()
    local gold = state.player_.gold_ or 0
    local rerollCost = 1 + (state.shop_.rerollCount or 0)

    -- Header
    local lvl = require("stages").level(state.stage_, state.stageLevel_)
    local maxW = lvl and lvl.totalWaves or state.maxWaves_
    local header = label(
        T("shop.title") .. " · " .. T("game.wave", state.wave_, maxW),
        { fontSize = 20, fontWeight = "bold",
          fontColor = { 255, 230, 137, 255 }, textAlign = "center" }
    )

    -- Weapon row (3 cards)
    local weaponCards = {}
    for i = 1, 3 do
        local w = state.shop_.weapons[i]
        table.insert(weaponCards,
            w and weapon_card(i, w)
              or UI.Panel { width = "31%", minHeight = 130, padding = 8,
                  backgroundColor = { 8, 15, 32, 120 },
                  borderColor = { 40, 60, 90, 80 }, borderWidth = 1, borderRadius = 10,
                  alignItems = "center", justifyContent = "center",
                  children = { label("—", { fontSize = 16, fontColor = { 100, 120, 150, 150 }, textAlign = "center" }) }
                })
    end

    local weaponRow = UI.Panel {
        width = "100%", flexDirection = "row", justifyContent = "space-around", gap = 6,
        children = weaponCards,
    }

    -- Stat item row (3 cards)
    local itemCards = {}
    for i = 1, 3 do
        local it = state.shop_.items[i]
        table.insert(itemCards,
            it and stat_card(i, it)
               or UI.Panel { width = "31%", minHeight = 130, padding = 8,
                   backgroundColor = { 8, 15, 32, 120 },
                   borderColor = { 40, 60, 90, 80 }, borderWidth = 1, borderRadius = 10,
                   alignItems = "center", justifyContent = "center",
                   children = { label("—", { fontSize = 16, fontColor = { 100, 120, 150, 150 }, textAlign = "center" }) }
                 })
    end

    local itemRow = UI.Panel {
        width = "100%", flexDirection = "row", justifyContent = "space-around", gap = 6, marginTop = 8,
        children = itemCards,
    }

    -- Gold display
    local goldDisplay = label(
        T("shop.gold", gold),
        { fontSize = 16, fontWeight = "bold", fontColor = COLOR_GOLD,
          textAlign = "center", marginTop = 8 }
    )

    -- Action buttons row (conditional on unlock state)
    local actionChildren = {}

    -- REROLL or UNLOCK-REROLL button
    if state.shop_.rerollUnlocked then
        local canReroll = gold >= rerollCost
        table.insert(actionChildren, UI.Button {
            text = T("shop.reroll", rerollCost),
            variant = "secondary", height = 40, minWidth = 100, fontSize = 12,
            opacity = canReroll and 1 or 0.4,
            onClick = function() if canReroll then M.reroll() end end,
        })
    else
        local canUnlockR = gold >= UNLOCK_REROLL_COST
        table.insert(actionChildren, UI.Button {
            text = T("shop.unlock_reroll", UNLOCK_REROLL_COST),
            variant = "secondary", height = 40, minWidth = 120, fontSize = 12,
            opacity = canUnlockR and 1 or 0.4,
            onClick = function() if canUnlockR then M.unlock_reroll() end end,
        })
    end

    -- UNLOCK-LOCK button (only when not yet unlocked)
    if not state.shop_.lockUnlocked then
        local canUnlockL = gold >= UNLOCK_LOCK_COST
        table.insert(actionChildren, UI.Button {
            text = T("shop.unlock_lock", UNLOCK_LOCK_COST),
            variant = "secondary", height = 40, minWidth = 120, fontSize = 12,
            opacity = canUnlockL and 1 or 0.4,
            onClick = function() if canUnlockL then M.unlock_lock() end end,
        })
    end

    -- SKIP button (always available)
    table.insert(actionChildren, UI.Button {
        text = T("shop.skip"),
        variant = "primary", height = 40, minWidth = 90, fontSize = 12,
        onClick = function() M.skip() end,
    })

    local actionRow = UI.Panel {
        width = "100%", flexDirection = "row", justifyContent = "center", gap = 10, marginTop = 10,
        children = actionChildren,
    }

    -- Assemble shop card
    local card = UI.Panel {
        width = "92%", maxWidth = 520, padding = 16, gap = 6,
        backgroundGradient = { type = "linear", direction = "to-bottom-right",
            from = { 16, 28, 54, 250 }, to = { 12, 20, 44, 250 } },
        borderRadius = 22, borderWidth = 1,
        borderColor = { 146, 225, 191, 180 },
        children = {
            header,
            label(T("shop.weapons"),
                { fontSize = 11, fontColor = { 150, 180, 220, 255 }, textAlign = "center" }),
            weaponRow,
            label(T("shop.items"),
                { fontSize = 11, fontColor = { 150, 180, 220, 255 }, textAlign = "center", marginTop = 4 }),
            itemRow,
            goldDisplay,
            actionRow,
            -- Lock hint
            label(T("shop.lock_hint"),
                { fontSize = 9, fontColor = { 100, 130, 170, 200 },
                  textAlign = "center", marginTop = 6 }),
        },
    }

    return UI.Panel {
        width = "100%", height = "100%",
        justifyContent = "center", alignItems = "center",
        padding = 12,
        children = { card },
    }
end

return M
