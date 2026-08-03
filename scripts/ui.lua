local UI = require("urhox-libs/UI")
local state = require("state")

local M = {}
local callbacks = {}

function M.configure(nextCallbacks) callbacks = nextCallbacks or {} end
local function label(text, props) return callbacks.makeLabel(text, props) end
local function rebuild() if callbacks.rebuild then callbacks.rebuild() end end
local function module_name(id) return callbacks.moduleName(id) end
local function modules_text() return callbacks.activeModuleText() end
local function safe_style(widget, style)
    if not widget then return false end
    local ok = pcall(function() widget:SetStyle(style) end)
    return ok
end

function M.show_damage_number(x, y, value, color)
    if not state.gameWorld_ then return end
    if #state.damageNumbers_ >= 28 then
        local oldest = table.remove(state.damageNumbers_, 1)
        if oldest.widget then oldest.widget:Destroy() end
    end
    local widget = UI.Label { position = "absolute", fontSize = 14, fontWeight = "bold", fontColor = color or { 255, 239, 164, 255 }, text = tostring(math.floor(value)), pointerEvents = "none" }
    state.gameWorld_:AddChild(widget)
    table.insert(state.damageNumbers_, { widget = widget, x = x, y = y, age = 0, lifetime = 0.72 })
end

function M.trigger_hit_flash(color, intensity, duration)
    state.hitFlashColor_ = color or { 255, 255, 255, 255 }
    state.hitFlash_ = math.max(state.hitFlash_, (intensity or 0.35))
    state.hitFlashDuration_ = math.max(state.hitFlashDuration_, (duration or 0.18))
end

function M.trigger_shake(intensity, duration)
    state.shakeIntensity_ = math.max(state.shakeIntensity_, intensity or 0.18)
    state.shakeDuration_ = math.max(state.shakeDuration_, duration or 0.12)
    state.shakeTime_ = state.shakeDuration_
end

function M.trigger_evolution(moduleId, level)
    state.evolutionFlash_ = 0.5
    state.evolutionColor_ = level >= 5 and { 255, 117, 218, 255 } or { 255, 213, 83, 255 }
    M.trigger_shake(level >= 5 and 0.28 or 0.2, 0.22)
    if state.feedbackLabel_ then
        state.feedbackLabel_:SetText("◆  " .. module_name(moduleId) .. "  Lv" .. tostring(level) .. "  ◆")
        state.feedbackLabel_:SetStyle({ fontColor = state.evolutionColor_, opacity = 1 })
    end
end

local function language_button(code, text)
    return UI.Button { text = state.language_ == code and ("✓  " .. text) or text, variant = state.language_ == code and "success" or "secondary", width = "100%", height = 48, marginBottom = 10, onClick = function() state.language_ = code; rebuild() end }
end

local function language_screen()
    local card = UI.Panel { width = "90%", maxWidth = 430, padding = 28, gap = 12, alignItems = "center", backgroundColor = { 20, 31, 58, 245 }, borderRadius = 24, borderWidth = 1, borderColor = { 91, 124, 190, 180 }, children = {
        label("◆", { fontSize = 42, fontColor = { 255, 213, 83, 255 } }),
        label(state.T("menu.title"), { fontSize = 30, fontWeight = "bold", fontColor = { 255, 255, 255, 255 }, textAlign = "center" }),
        label(state.T("menu.subtitle"), { fontSize = 15, fontColor = { 177, 196, 231, 255 }, textAlign = "center" }),
        UI.Panel { width = "100%", padding = 14, gap = 4, backgroundColor = { 11, 20, 42, 180 }, borderRadius = 14, children = { language_button("zh_CN", state.T("language.simplified_chinese")), language_button("en", state.T("language.english")) } },
        label(state.T("menu.ready"), { fontSize = 13, fontColor = { 146, 225, 191, 255 }, textAlign = "center", marginTop = 8 }),
        UI.Button { text = state.T("menu.start"), variant = "primary", width = "100%", height = 50, onClick = function() state.screen_ = "game"; callbacks.resetRunState(); rebuild() end },
        UI.Button { text = state.T("meta.archive"), variant = "secondary", width = "100%", height = 44, onClick = function() state.metaScreenReturn_ = "language"; state.screen_ = "archive"; rebuild() end },
    } }
    return UI.Panel { width = "100%", height = "100%", justifyContent = "center", alignItems = "center", padding = 20, children = { card } }
end

local function game_screen()
    callbacks.resetTouchControl()
    state.gameWorld_ = UI.Panel { id = "gameWorld", position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "none", backgroundColor = { 9, 17, 37, 255 }, overflow = "hidden" }
    state.playerWidget_ = UI.Panel { id = "player", position = "absolute", width = 32, height = 32, backgroundColor = { 82, 214, 255, 255 }, borderColor = { 225, 250, 255, 255 }, borderWidth = 2, borderRadius = 5, rotate = 45 }
    state.gameWorld_:AddChild(state.playerWidget_)
    state.shellRing_ = UI.Panel { id = "shellRing", position = "absolute", width = 44, height = 44, borderColor = { 255, 213, 83, 200 }, borderWidth = 2, borderRadius = 22, pointerEvents = "none", visible = false }
    state.gameWorld_:AddChild(state.shellRing_)
    state.hudLabel_ = label("", { fontSize = 13, fontWeight = "bold", fontColor = { 220, 235, 255, 255 }, lineHeight = 1.35 })
    state.xpLabel_ = label("", { fontSize = 11, fontColor = { 183, 207, 242, 255 }, marginTop = 5 })
    state.xpBarFill_ = UI.Panel { width = "0%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 177, 128, 255, 255 }, to = { 91, 220, 255, 255 } }, borderRadius = 5, pointerEvents = "none" }
    local xpBar = UI.Panel { width = "100%", height = 10, marginTop = 6, backgroundColor = { 25, 40, 76, 220 }, borderRadius = 5, overflow = "hidden", children = { state.xpBarFill_ } }
    state.shellLabel_ = label("", { fontSize = 11, fontColor = { 255, 213, 140, 255 }, marginTop = 5, opacity = 0 })
    state.shellBarFill_ = UI.Panel { width = "0%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 255, 213, 83, 255 }, to = { 255, 165, 80, 255 } }, borderRadius = 5, pointerEvents = "none" }
    local shellBar = UI.Panel { width = "100%", height = 8, marginTop = 4, backgroundColor = { 40, 35, 22, 220 }, borderRadius = 5, overflow = "hidden", opacity = 0, children = { state.shellBarFill_ } }
    local statusCard = UI.Panel { width = "44%", maxWidth = 420, padding = 12, backgroundColor = { 8, 20, 45, 215 }, borderColor = { 91, 153, 220, 150 }, borderWidth = 1, borderRadius = 14, children = { state.hudLabel_, state.xpLabel_, xpBar, state.shellLabel_, shellBar } }
    state.waveLabel_ = label("", { fontSize = 14, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "right" })
    state.moduleLabel_ = label("", { fontSize = 11, fontColor = { 207, 220, 244, 255 }, textAlign = "right", marginTop = 5 })
    state.feedbackLabel_ = label("", { position = "absolute", top = 112, left = 0, right = 0, textAlign = "center", fontSize = 13, fontWeight = "bold", fontColor = { 255, 111, 126, 0 }, pointerEvents = "none" })
    state.hitFlashWidget_ = UI.Panel { position = "absolute", top = 0, left = 0, width = "100%", height = "100%", backgroundColor = { 255, 255, 255, 255 }, opacity = 0, pointerEvents = "none" }
    local waveCard = UI.Panel { width = "38%", maxWidth = 360, padding = 12, alignItems = "flex-end", backgroundColor = { 8, 20, 45, 215 }, borderColor = { 146, 225, 191, 150 }, borderWidth = 1, borderRadius = 14, children = { state.waveLabel_, state.moduleLabel_ } }
    local hud = UI.Panel { position = "absolute", top = 14, left = 16, right = 16, flexDirection = "row", justifyContent = "space-between", pointerEvents = "none", children = { statusCard, waveCard } }
    state.joystickBase_ = UI.Panel { position = "absolute", width = state.touchRadius_ * 2, height = state.touchRadius_ * 2, backgroundColor = { 72, 133, 204, 90 }, borderColor = { 157, 220, 255, 170 }, borderWidth = 2, borderRadius = state.touchRadius_, pointerEvents = "none", visible = false }
    state.joystickKnob_ = UI.Panel { position = "absolute", width = 52, height = 52, backgroundColor = { 108, 220, 255, 210 }, borderColor = { 230, 252, 255, 230 }, borderWidth = 2, borderRadius = 26, pointerEvents = "none", visible = false }
    state.touchSurface_ = UI.Panel { position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "auto", onPointerDown = callbacks.handleTouchDown, onPointerMove = callbacks.handleTouchMove, onPointerUp = callbacks.handleTouchUp, onPointerCancel = callbacks.handleTouchUp, children = { state.joystickBase_, state.joystickKnob_ } }
    return UI.Panel { width = "100%", height = "100%", pointerEvents = "box-none", children = { state.gameWorld_, hud, state.feedbackLabel_, label(state.T("game.hint"), { position = "absolute", bottom = 28, left = 0, right = 0, textAlign = "center", fontSize = 11, fontColor = { 131, 151, 190, 220 } }), label(state.T("game.mobile_hint"), { position = "absolute", bottom = 10, left = 0, right = 0, textAlign = "center", fontSize = 10, fontColor = { 122, 190, 218, 230 } }), state.touchSurface_, state.hitFlashWidget_ } }
end

local function upgrade_screen()
    local cards = {}
    for index, card in ipairs(state.upgradeCards_) do cards[index] = UI.Button { text = card.title .. "\n" .. card.description, variant = index == 1 and "primary" or "secondary", width = "100%", minHeight = 72, marginBottom = 10, fontSize = 13, onClick = function() callbacks.applyUpgrade(card.id); state.screen_ = "game"; rebuild() end } end
    return UI.Panel { width = "90%", maxWidth = 520, padding = 24, gap = 8, backgroundColor = { 19, 30, 58, 250 }, borderRadius = 22, borderWidth = 1, borderColor = { 108, 172, 255, 220 }, children = { label(state.T("game.level_up"), { fontSize = 23, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "center", marginBottom = 4 }), label(state.T("game.level", state.level_), { fontSize = 14, fontColor = { 177, 196, 231, 255 }, textAlign = "center", marginBottom = 12 }), table.unpack(cards) } }
end

local function wave_pause_screen()
    local remaining = math.max(0, state.levelGoal_ - state.levelProgress_)
    return UI.Panel { width = "90%", maxWidth = 520, padding = 28, gap = 14, alignItems = "center", backgroundColor = { 20, 39, 63, 250 }, borderRadius = 24, borderWidth = 1, borderColor = { 146, 225, 191, 200 }, children = { label(state.T("game.wave_pause"), { fontSize = 25, fontWeight = "bold", fontColor = { 146, 225, 191, 255 }, textAlign = "center" }), label(state.T("game.wave_next", state.wave_), { fontSize = 18, fontWeight = "bold", fontColor = { 255, 230, 137, 255 } }), UI.Panel { width = "100%", padding = 14, gap = 7, backgroundColor = { 9, 20, 43, 180 }, borderRadius = 12, children = { label(state.T("game.stats"), { fontSize = 12, fontWeight = "bold", fontColor = { 146, 225, 191, 255 } }), label(state.T("game.integrity", math.max(0, state.player_.integrity), state.player_.maxIntegrity), { fontSize = 14, fontColor = { 220, 235, 255, 255 } }), label(state.T("game.level", state.level_) .. "  ·  " .. state.T("game.next_upgrade", remaining), { fontSize = 14, fontColor = { 183, 207, 242, 255 } }), label(state.T("game.fragments", state.dataFragments_) .. "  ·  " .. state.T("game.score", state.score_), { fontSize = 14, fontColor = { 255, 230, 137, 255 } }) } }, label(state.T("game.modifier", state.T("modifier." .. state.modifier_)), { fontSize = 14, fontWeight = "bold", fontColor = { 255, 182, 105, 255 }, textAlign = "center" }), label(state.T("game.modules", modules_text()), { fontSize = 13, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }), UI.Button { text = state.T("game.continue"), variant = "primary", width = "100%", height = 50, onClick = function() callbacks.beginWave(); rebuild() end } } }
end

local function archive_screen()
    local canCalibrate = state.profile_.calibration > 0
    return UI.Panel { width = "90%", maxWidth = 440, padding = 26, gap = 12, alignItems = "center", backgroundColor = { 20, 31, 58, 250 }, borderRadius = 22, borderWidth = 1, borderColor = { 146, 225, 191, 200 }, children = { label(state.T("meta.title"), { fontSize = 24, fontWeight = "bold", fontColor = { 146, 225, 191, 255 }, textAlign = "center" }), label(state.T("meta.currency", state.profile_.calibration), { fontSize = 15, fontColor = { 255, 230, 137, 255 } }), label(state.T("meta.fallback"), { fontSize = 11, fontColor = { 177, 196, 231, 255 }, textAlign = "center" }), UI.Button { text = state.T("meta.integrity"), variant = state.profile_.startingIntegrity > 0 and "secondary" or "primary", width = "100%", height = 48, onClick = function() if canCalibrate and state.profile_.startingIntegrity == 0 then state.profile_.startingIntegrity = 1; state.profile_.calibration = state.profile_.calibration - 1; rebuild() end end }, UI.Button { text = state.T("meta.magnet"), variant = state.profile_.magnet > 0 and "secondary" or "primary", width = "100%", height = 48, onClick = function() if canCalibrate and state.profile_.magnet == 0 then state.profile_.magnet = 1; state.profile_.calibration = state.profile_.calibration - 1; rebuild() end end }, UI.Button { text = state.T("meta.close"), variant = "secondary", width = "100%", height = 44, onClick = function() state.screen_ = state.metaScreenReturn_; rebuild() end } } }
end

local function summary_screen()
    return UI.Panel { width = "90%", maxWidth = 450, padding = 28, gap = 12, alignItems = "center", backgroundColor = { 30, 24, 54, 250 }, borderRadius = 24, borderWidth = 1, borderColor = { 231, 109, 143, 200 }, children = { label(state.T("game.defeated"), { fontSize = 28, fontWeight = "bold", fontColor = { 255, 150, 170, 255 }, textAlign = "center" }), label(state.T("game.summary"), { fontSize = 16, fontColor = { 210, 201, 231, 255 } }), label(state.T("game.reason", state.defeatReason_), { fontSize = 13, fontColor = { 210, 201, 231, 255 }, textAlign = "center" }), label(state.T("game.final_wave", state.wave_), { fontSize = 16, fontColor = { 177, 196, 231, 255 } }), label(state.T("game.final_score", state.score_), { fontSize = 16, fontColor = { 255, 230, 137, 255 } }), label(state.T("game.final_level", state.level_), { fontSize = 16, fontColor = { 146, 225, 191, 255 } }), label(state.T("game.modules", modules_text()), { fontSize = 14, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }), label(state.T("game.final_fragments", state.dataFragments_), { fontSize = 14, fontColor = { 207, 220, 244, 255 } }), label(state.T("meta.currency", state.profile_.calibration), { fontSize = 13, fontColor = { 255, 230, 137, 255 } }), UI.Button { text = state.T("meta.archive"), variant = "secondary", width = "100%", height = 44, onClick = function() state.metaScreenReturn_ = "summary"; state.screen_ = "archive"; rebuild() end }, UI.Button { text = state.T("game.restart"), variant = "primary", width = "100%", height = 48, onClick = function() state.screen_ = "game"; callbacks.resetRunState(); rebuild() end }, UI.Button { text = state.T("game.back"), variant = "secondary", width = "100%", height = 44, onClick = function() state.screen_ = "language"; rebuild() end } } }
end

function M.build(screen)
    if screen == "language" then return language_screen() end
    if screen == "game" then return game_screen() end
    if screen == "upgrade" then return upgrade_screen() end
    if screen == "wave_pause" then return wave_pause_screen() end
    if screen == "archive" then return archive_screen() end
    return summary_screen()
end

function M.update_hud()
    local player = state.player_
    if state.hudLabel_ then state.hudLabel_:SetText(state.T("game.integrity", math.max(0, player.integrity), player.maxIntegrity) .. "  |  " .. state.T("game.score", state.score_) .. "  |  " .. state.T("game.fragments", state.dataFragments_)) end
    if state.xpLabel_ then state.xpLabel_:SetText(state.T("game.level", state.level_) .. "  ·  " .. state.T("game.next_upgrade", math.max(0, state.levelGoal_ - state.levelProgress_))) end
    if state.xpBarFill_ then state.xpBarFill_:SetStyle({ width = tostring(math.floor(math.min(1, state.levelProgress_ / math.max(1, state.levelGoal_)) * 100)) .. "%" }) end
    if state.waveLabel_ then state.waveLabel_:SetText(state.T("game.wave", state.wave_, state.maxWaves_) .. "\n" .. state.T("game.time", math.floor(state.runTime_)) .. "\n" .. state.T("game.modifier", state.T("modifier." .. state.modifier_))) end
    if state.moduleLabel_ then state.moduleLabel_:SetText(state.T("game.modules", modules_text())) end
    if state.feedbackLabel_ then state.feedbackLabel_:SetStyle({ opacity = state.surgeFlash_ > 0 and 1 or 0 }); state.feedbackLabel_:SetText(state.surgeFlash_ > 0 and state.T("game.telegraph") or "") end
    if state.shellLabel_ then
        local shellActive = state.activeModules_.shell and player.maxShell > 0
        if shellActive then state.shellLabel_:SetText(state.T("game.shell", math.ceil(player.shell), player.maxShell)); state.shellLabel_:SetStyle({ opacity = 1 }) else state.shellLabel_:SetText(""); state.shellLabel_:SetStyle({ opacity = 0 }) end
    end
    if state.shellBarFill_ then local ratio = player.maxShell > 0 and math.min(1, player.shell / player.maxShell) or 0; state.shellBarFill_:SetStyle({ width = tostring(math.floor(ratio * 100)) .. "%" }) end
end

function M.update_feedback(timeStep)
    if not state.gameWorld_ then return end
    for index = #state.damageNumbers_, 1, -1 do
        local item = state.damageNumbers_[index]
        item.age = item.age + timeStep
        if item.age >= item.lifetime then item.widget:Destroy(); table.remove(state.damageNumbers_, index)
        else
            local progress = item.age / item.lifetime
            safe_style(item.widget, { left = item.x - 12, top = item.y - 18 - progress * 30, opacity = 1 - progress })
        end
    end
    state.hitFlashDuration_ = math.max(0, state.hitFlashDuration_ - timeStep)
    state.hitFlash_ = math.max(0, state.hitFlash_ - timeStep * 2.8)
    state.evolutionFlash_ = math.max(0, state.evolutionFlash_ - timeStep)
    if state.hitFlashWidget_ then
        local alpha = math.max(state.hitFlash_, state.evolutionFlash_ * 0.7)
        local color = state.evolutionFlash_ > state.hitFlash_ and state.evolutionColor_ or state.hitFlashColor_
        safe_style(state.hitFlashWidget_, { backgroundColor = color, opacity = alpha })
    end
    if state.shakeTime_ > 0 then
        state.shakeTime_ = math.max(0, state.shakeTime_ - timeStep)
        local fade = state.shakeDuration_ > 0 and state.shakeTime_ / state.shakeDuration_ or 0
        local phase = state.runTime_ * 70
        safe_style(state.gameWorld_, { left = math.sin(phase) * state.shakeIntensity_ * 12 * fade, top = math.cos(phase * 1.3) * state.shakeIntensity_ * 12 * fade })
    else
        safe_style(state.gameWorld_, { left = 0, top = 0 })
        state.shakeIntensity_ = 0
    end
end

return M
