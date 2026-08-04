local UI = require("urhox-libs/UI")
local state = require("state")
local stages = require("stages")
local stats_panel = require("stats_panel")  -- P2: right-side stat panel

local M = {}
local callbacks = {}

function M.configure(nextCallbacks) callbacks = nextCallbacks or {} end
local function label(text, props) return callbacks.makeLabel(text, props) end
local function rebuild() if callbacks.rebuild then callbacks.rebuild() end end
local function module_name(id) return callbacks.moduleName(id) end
local function modules_text() return callbacks.activeModuleText() end

-- Get current stage's visual theme
local function arena_theme()
    return stages.theme(state.stage_) or stages.theme(1)
end
local function safe_style(widget, style)
    if not widget then return false end
    local ok = pcall(function() widget:SetStyle(style) end)
    return ok
end

function M.show_damage_number(x, y, value, color)
    if not state.gameWorld_ then return end
    if #state.damageNumbers_ >= 18 then
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
    local card = UI.Panel { width = "90%", maxWidth = 430, padding = 28, gap = 12, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 20, 31, 58, 248 }, to = { 15, 22, 48, 248 } }, borderRadius = 24, borderWidth = 1, borderColor = { 91, 124, 190, 180 }, children = {
        label("◆", { fontSize = 42, fontColor = { 82, 214, 255, 255 } }),
        label(state.T("menu.title"), { fontSize = 30, fontWeight = "bold", fontColor = { 255, 255, 255, 255 }, textAlign = "center" }),
        label(state.T("menu.subtitle"), { fontSize = 15, fontColor = { 177, 196, 231, 255 }, textAlign = "center" }),
        UI.Panel { width = "100%", padding = 14, gap = 4, backgroundColor = { 11, 20, 42, 180 }, borderRadius = 14, children = { language_button("zh_CN", state.T("language.simplified_chinese")), language_button("en", state.T("language.english")) } },
        label(state.T("menu.ready"), { fontSize = 13, fontColor = { 146, 225, 191, 255 }, textAlign = "center", marginTop = 8 }),
        UI.Button { text = state.T("menu.start"), variant = "primary", width = "100%", height = 50, onClick = function() state.screen_ = state.SCREEN_STAGE_SELECT; rebuild() end },
        UI.Panel { width = "100%", flexDirection = "row", gap = 8, children = {
            UI.Button { text = state.T("menu.workshop"), variant = "secondary", flex = 1, height = 44, onClick = function() state.screen_ = "cosmetics"; rebuild() end },
            UI.Button { text = state.T("meta.archive"), variant = "secondary", flex = 1, height = 44, onClick = function() state.metaScreenReturn_ = "language"; state.screen_ = "archive"; rebuild() end },
        } },
    } }
    return UI.Panel { width = "100%", height = "100%", justifyContent = "center", alignItems = "center", padding = 20, children = { card } }
end

local function game_screen()
    callbacks.resetTouchControl()
    local t = arena_theme()
    state.gameWorld_ = UI.Panel { id = "gameWorld", position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "none", backgroundColor = t.bg, overflow = "hidden" }

    local arenaFloor = UI.Panel { position = "absolute", top = 0, left = 0, width = "100%", height = "100%", backgroundColor = t.floorColor, borderColor = t.borderColor, borderWidth = 2, borderRadius = 0, pointerEvents = "none" }
    state.gameWorld_:AddChild(arenaFloor)

    local cx, cy = state.worldWidth_ * 0.5, state.worldHeight_ * 0.5
    local arenaRing1 = UI.Panel { position = "absolute", left = cx - 140, top = cy - 140, width = 280, height = 280, borderColor = t.ring1Color, borderWidth = 1, borderRadius = 140, pointerEvents = "none" }
    state.gameWorld_:AddChild(arenaRing1)
    local arenaRing2 = UI.Panel { position = "absolute", left = cx - 240, top = cy - 240, width = 480, height = 480, borderColor = t.ring2Color, borderWidth = 1, borderRadius = 240, pointerEvents = "none" }
    state.gameWorld_:AddChild(arenaRing2)

    -- Player widget with stage accent color
    state.playerWidget_ = UI.Panel { id = "player", position = "absolute", width = 32, height = 32, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = t.accent, to = { t.accent[1] * 0.65, t.accent[2] * 0.7, t.accent[3] * 0.85, 255 } }, borderColor = { 200, 250, 255, 255 }, borderWidth = 2, borderRadius = 4, rotate = 45, pointerEvents = "none" }
    state.gameWorld_:AddChild(state.playerWidget_)
    state.shellRing_ = UI.Panel { id = "shellRing", position = "absolute", width = 44, height = 44, borderColor = t.bossAccent, borderWidth = 2, borderRadius = 22, pointerEvents = "none", visible = false }
    state.gameWorld_:AddChild(state.shellRing_)
    state.hudLabel_ = label("", { fontSize = 13, fontWeight = "bold", fontColor = { 220, 235, 255, 255 }, lineHeight = 1.35 })
    state.xpLabel_ = label("", { fontSize = 11, fontColor = { 183, 207, 242, 255 }, marginTop = 5 })
    state.xpBarFill_ = UI.Panel { width = "0%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 177, 128, 255, 255 }, to = { 91, 220, 255, 255 } }, borderRadius = 5, pointerEvents = "none" }
    local xpBar = UI.Panel { width = "100%", height = 10, marginTop = 6, backgroundColor = { 25, 40, 76, 220 }, borderRadius = 5, overflow = "hidden", children = { state.xpBarFill_ } }
    state.shellLabel_ = label("", { fontSize = 11, fontColor = t.bossAccent, marginTop = 5, opacity = 0 })
    state.shellBarFill_ = UI.Panel { width = "0%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = t.bossAccent, to = { 255, 165, 80, 255 } }, borderRadius = 5, pointerEvents = "none" }
    local shellBar = UI.Panel { width = "100%", height = 8, marginTop = 4, backgroundColor = { 40, 35, 22, 220 }, borderRadius = 5, overflow = "hidden", opacity = 0, children = { state.shellBarFill_ } }
    state.waveLabel_ = label("", { fontSize = 12, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "left", marginTop = 6 })
    state.moduleLabel_ = label("", { fontSize = 10, fontColor = { 177, 196, 231, 255 }, textAlign = "left", marginTop = 2 })
    local statusCard = UI.Panel { width = "44%", maxWidth = 420, padding = 12, gap = 2, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 8, 20, 45, 220 }, to = { 10, 16, 38, 220 } }, borderColor = t.accentDim, borderWidth = 1, borderRadius = 14, children = { state.hudLabel_, state.xpLabel_, xpBar, state.shellLabel_, shellBar, state.waveLabel_, state.moduleLabel_ } }

    state.bossLabel_ = label("", { fontSize = 13, fontWeight = "bold", fontColor = { 255, 180, 60, 255 }, textAlign = "center", opacity = 0 })
    state.bossBarFill_ = UI.Panel { width = "100%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 255, 100, 60, 255 }, to = { 255, 180, 60, 255 } }, borderRadius = 4, pointerEvents = "none" }
    local bossBar = UI.Panel { width = "100%", height = 10, marginTop = 4, backgroundColor = { 40, 20, 15, 220 }, borderRadius = 5, overflow = "hidden", children = { state.bossBarFill_ } }
    local bossCard = UI.Panel { position = "absolute", top = 72, left = "12%", right = "12%", padding = 8, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 30, 16, 12, 220 }, to = { 20, 12, 10, 220 } }, borderColor = { 200, 100, 40, 180 }, borderWidth = 1, borderRadius = 12, opacity = 0, children = { state.bossLabel_, bossBar } }
    state.bossCard_ = bossCard

    -- R-01: Mid-boss health bar (teal/cyan scheme)
    state.midBossLabel_ = label("", { fontSize = 13, fontWeight = "bold", fontColor = { 140, 255, 255, 255 }, textAlign = "center", opacity = 0 })
    state.midBossBarFill_ = UI.Panel { width = "100%", height = "100%", backgroundGradient = { type = "linear", direction = "to-right", from = { 80, 200, 220, 255 }, to = { 140, 255, 255, 255 } }, borderRadius = 4, pointerEvents = "none" }
    local midBossBar = UI.Panel { width = "100%", height = 10, marginTop = 4, backgroundColor = { 15, 40, 50, 220 }, borderRadius = 5, overflow = "hidden", children = { state.midBossBarFill_ } }
    local midBossCard = UI.Panel { position = "absolute", top = 72, left = "12%", right = "12%", padding = 8, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 12, 30, 36, 220 }, to = { 10, 22, 28, 220 } }, borderColor = { 80, 200, 220, 180 }, borderWidth = 1, borderRadius = 12, opacity = 0, children = { state.midBossLabel_, midBossBar } }
    state.midBossCard_ = midBossCard

    -- R-09: Modifier dock (wave intro hints)
    state.modifierDockLabel_ = label("", { fontSize = 12, fontWeight = "bold", fontColor = { 255, 255, 255, 255 }, textAlign = "center" })
    state.modifierDock_ = UI.Panel { position = "absolute", top = 54, left = "50%", padding = { top = 4, bottom = 4, left = 12, right = 12 }, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 22, 22, 34, 240 }, to = { 14, 14, 22, 240 } }, borderColor = { 255, 200, 60, 200 }, borderWidth = 1, borderRadius = 10, alignItems = "center", opacity = 0, pointerEvents = "none", children = { state.modifierDockLabel_ } }

    -- Stage intro overlay: "Stage X · Level Y"
    state.stageIntroLabel_ = label("", { position = "absolute", top = "40%", left = 0, right = 0, textAlign = "center", fontSize = 28, fontWeight = "bold", fontColor = { 255, 255, 255, 0 }, pointerEvents = "none" })

    state.feedbackLabel_ = label("", { position = "absolute", top = 130, left = 0, right = 0, textAlign = "center", fontSize = 13, fontWeight = "bold", fontColor = { 255, 111, 126, 0 }, pointerEvents = "none" })
    state.hitFlashWidget_ = UI.Panel { position = "absolute", top = 0, left = 0, width = "100%", height = "100%", backgroundColor = { 255, 255, 255, 255 }, opacity = 0, pointerEvents = "none" }
    local hud = UI.Panel { position = "absolute", top = 38, left = 16, right = 16, flexDirection = "row", justifyContent = "flex-start", pointerEvents = "none", children = { statusCard } }
    state.joystickBase_ = UI.Panel { position = "absolute", width = state.touchRadius_ * 2, height = state.touchRadius_ * 2, backgroundColor = { 72, 133, 204, 60 }, borderColor = { 157, 220, 255, 120 }, borderWidth = 2, borderRadius = state.touchRadius_, pointerEvents = "none", visible = false }
    state.joystickKnob_ = UI.Panel { position = "absolute", width = 52, height = 52, backgroundGradient = { type = "radial", from = { 108, 220, 255, 200 }, to = { 60, 160, 220, 160 } }, borderColor = { 230, 252, 255, 200 }, borderWidth = 2, borderRadius = 26, pointerEvents = "none", visible = false }
    state.touchSurface_ = UI.Panel { position = "absolute", top = 0, left = 0, width = "100%", height = "100%", pointerEvents = "auto", onPointerDown = callbacks.handleTouchDown, onPointerMove = callbacks.handleTouchMove, onPointerUp = callbacks.handleTouchUp, onPointerCancel = callbacks.handleTouchUp, children = { state.joystickBase_, state.joystickKnob_ } }
    return UI.Panel { width = "100%", height = "100%", pointerEvents = "box-none", children = { state.gameWorld_, hud, bossCard, state.feedbackLabel_, label(state.T("game.hint"), { position = "absolute", bottom = 44, left = 0, right = 0, textAlign = "center", fontSize = 11, fontColor = { 131, 151, 190, 180 } }), label(state.T("game.mobile_hint"), { position = "absolute", bottom = 24, left = 0, right = 0, textAlign = "center", fontSize = 10, fontColor = { 122, 190, 218, 200 } }), state.touchSurface_, state.hitFlashWidget_, stats_panel.build() } }
end

local function upgrade_screen()
    local cards = {}
    for index, card in ipairs(state.upgradeCards_) do cards[index] = UI.Button { text = card.title .. "\n" .. card.description, variant = index == 1 and "primary" or "secondary", width = "100%", minHeight = 58, marginBottom = 10, fontSize = 12, onClick = function() callbacks.applyUpgrade(card.id); state.screen_ = "game"; rebuild() end } end
    return UI.Panel { width = "90%", maxWidth = 520, maxHeight = "82%", overflow = "scroll", padding = 24, gap = 8, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 19, 30, 58, 250 }, to = { 15, 22, 48, 250 } }, borderRadius = 22, borderWidth = 1, borderColor = { 108, 172, 255, 220 }, children = { label(state.T("game.level_up"), { fontSize = 23, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "center", marginBottom = 4 }), label(state.T("game.level", state.level_), { fontSize = 14, fontColor = { 177, 196, 231, 255 }, textAlign = "center", marginBottom = 12 }), table.unpack(cards) } }
end

local function wave_pause_screen()
    local remaining = math.max(0, state.levelGoal_ - state.levelProgress_)
    local isBoss = state.wave_ >= state.maxWaves_
    local nextLabel = isBoss and state.T("game.boss_wave") or state.T("game.wave_next", state.wave_)
    return UI.Panel { width = "90%", maxWidth = 520, padding = 28, gap = 14, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 20, 39, 63, 250 }, to = { 16, 30, 52, 250 } }, borderRadius = 24, borderWidth = 1, borderColor = isBoss and { 255, 150, 60, 200 } or { 146, 225, 191, 200 }, children = { label(state.T("game.wave_pause"), { fontSize = 25, fontWeight = "bold", fontColor = isBoss and { 255, 180, 60, 255 } or { 146, 225, 191, 255 }, textAlign = "center" }), label(nextLabel, { fontSize = 18, fontWeight = "bold", fontColor = { 255, 230, 137, 255 } }), UI.Panel { width = "100%", padding = 14, gap = 7, backgroundColor = { 9, 20, 43, 180 }, borderRadius = 12, children = { label(state.T("game.stats"), { fontSize = 12, fontWeight = "bold", fontColor = { 146, 225, 191, 255 } }), label(state.T("game.integrity", math.max(0, state.player_.integrity), state.player_.maxIntegrity), { fontSize = 14, fontColor = { 220, 235, 255, 255 } }), label(state.T("game.level", state.level_) .. "  ·  " .. state.T("game.next_upgrade", remaining), { fontSize = 14, fontColor = { 183, 207, 242, 255 } }), label(state.T("game.fragments", state.dataFragments_) .. "  ·  " .. state.T("game.score", state.score_), { fontSize = 14, fontColor = { 255, 230, 137, 255 } }) } }, label(state.T("game.modifier", state.T("modifier." .. state.modifier_)), { fontSize = 14, fontWeight = "bold", fontColor = { 255, 182, 105, 255 }, textAlign = "center" }), label(state.T("game.weapons", modules_text()), { fontSize = 13, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }), UI.Button { text = state.T("game.continue"), variant = "primary", width = "100%", height = 50, onClick = function() callbacks.beginWave(); rebuild() end } } }
end

local function archive_screen()
    local canCalibrate = state.profile_.calibration > 0
    return UI.Panel { width = "90%", maxWidth = 440, maxHeight = "85%", overflow = "scroll", padding = 26, gap = 12, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 20, 31, 58, 250 }, to = { 16, 24, 48, 250 } }, borderRadius = 22, borderWidth = 1, borderColor = { 146, 225, 191, 200 }, children = { label(state.T("meta.title"), { fontSize = 24, fontWeight = "bold", fontColor = { 146, 225, 191, 255 }, textAlign = "center" }), label(state.T("meta.currency", state.profile_.calibration), { fontSize = 15, fontColor = { 255, 230, 137, 255 } }), label(state.T("meta.fallback"), { fontSize = 11, fontColor = { 177, 196, 231, 255 }, textAlign = "center" }), UI.Button { text = state.T("meta.integrity"), variant = state.profile_.startingIntegrity > 0 and "secondary" or "primary", width = "100%", height = 48, onClick = function() if canCalibrate and state.profile_.startingIntegrity == 0 then state.profile_.startingIntegrity = 1; state.profile_.calibration = state.profile_.calibration - 1; rebuild() end end }, UI.Button { text = state.T("meta.magnet"), variant = state.profile_.magnet > 0 and "secondary" or "primary", width = "100%", height = 48, onClick = function() if canCalibrate and state.profile_.magnet == 0 then state.profile_.magnet = 1; state.profile_.calibration = state.profile_.calibration - 1; rebuild() end end }, UI.Button { text = state.T("meta.close"), variant = "secondary", width = "100%", height = 44, onClick = function() state.screen_ = state.metaScreenReturn_; rebuild() end } } }
end

local function cosmetics_screen()
    local skinCard = function(name, color, locked)
        local preview = UI.Panel { width = 36, height = 36, backgroundGradient = { type = "linear", direction = "to-bottom-right", from = color, to = { color[1] * 0.6, color[2] * 0.6, color[3] * 0.6, 255 } }, borderColor = { color[1], math.min(255, color[2] + 40), math.min(255, color[3] + 40), 255 }, borderWidth = 2, borderRadius = 4, rotate = 45 }
        return UI.Panel { width = "100%", padding = 12, flexDirection = "row", alignItems = "center", gap = 12, backgroundColor = { 12, 22, 45, 200 }, borderRadius = 12, borderWidth = 1, borderColor = { 50, 70, 110, 150 }, children = { preview, label(name, { fontSize = 14, fontWeight = "bold", fontColor = { 220, 235, 255, 255 }, flex = 1 }), label(locked and state.T("cosmetics.locked") or "✓", { fontSize = 12, fontColor = locked and { 150, 160, 190, 255 } or { 146, 225, 191, 255 } }) } }
    end
    return UI.Panel { width = "90%", maxWidth = 450, maxHeight = "85%", overflow = "scroll", padding = 26, gap = 12, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 18, 28, 54, 250 }, to = { 14, 20, 44, 250 } }, borderRadius = 24, borderWidth = 1, borderColor = { 108, 172, 255, 180 }, children = {
        label("◈", { fontSize = 36, fontColor = { 177, 128, 255, 255 } }),
        label(state.T("cosmetics.title"), { fontSize = 24, fontWeight = "bold", fontColor = { 220, 235, 255, 255 }, textAlign = "center" }),
        label(state.T("cosmetics.subtitle"), { fontSize = 13, fontColor = { 177, 196, 231, 255 }, textAlign = "center", marginBottom = 6 }),
        skinCard(state.T("cosmetics.skin_default"), { 82, 214, 255, 255 }, false),
        skinCard(state.T("cosmetics.skin_crimson"), { 255, 80, 100, 255 }, true),
        skinCard(state.T("cosmetics.skin_void"), { 150, 100, 220, 255 }, true),
        skinCard(state.T("cosmetics.skin_solar"), { 255, 190, 60, 255 }, true),
        UI.Panel { width = "100%", padding = 14, gap = 6, backgroundColor = { 12, 22, 45, 180 }, borderRadius = 12, borderWidth = 1, borderColor = { 60, 50, 30, 150 }, children = { label(state.T("cosmetics.support"), { fontSize = 14, fontWeight = "bold", fontColor = { 255, 213, 83, 255 } }), label(state.T("cosmetics.support_desc"), { fontSize = 12, fontColor = { 177, 196, 231, 255 } }) } },
        UI.Button { text = state.T("cosmetics.close"), variant = "secondary", width = "100%", height = 44, onClick = function() state.screen_ = "language"; rebuild() end },
    } }
end

local function summary_screen()
    local isVictory = state.isVictory_
    local titleKey = isVictory and "game.victory" or "game.defeated"
    local titleColor = isVictory and { 146, 225, 191, 255 } or { 255, 150, 170, 255 }
    local borderColor = isVictory and { 100, 200, 170, 200 } or { 231, 109, 143, 200 }
    local gradFrom = isVictory and { 18, 42, 38, 250 } or { 30, 24, 54, 250 }
    local gradTo = isVictory and { 14, 32, 30, 250 } or { 22, 18, 42, 250 }

    local upgradeText = state.T("telemetry.no_upgrades")
    if #state.runStats_.upgrades > 0 then
        upgradeText = table.concat(state.runStats_.upgrades, " → ")
    end

    return UI.Panel { width = "90%", maxWidth = 450, padding = 26, gap = 10, alignItems = "center", backgroundGradient = { type = "linear", direction = "to-bottom-right", from = gradFrom, to = gradTo }, borderRadius = 24, borderWidth = 1, borderColor = borderColor, children = {
        label(state.T(titleKey), { fontSize = 28, fontWeight = "bold", fontColor = titleColor, textAlign = "center" }),
        label(state.T("game.summary"), { fontSize = 16, fontColor = { 210, 201, 231, 255 } }),
        label(state.T("game.reason", state.defeatReason_), { fontSize = 13, fontColor = { 210, 201, 231, 255 }, textAlign = "center" }),
        label(state.T("game.final_wave", state.wave_) .. "  ·  " .. state.T("game.final_score", state.score_) .. "  ·  " .. state.T("game.final_level", state.level_), { fontSize = 15, fontColor = { 255, 230, 137, 255 }, textAlign = "center" }),
        label(state.T("game.final_fragments", state.dataFragments_) .. "  ·  " .. state.T("meta.currency", state.profile_.calibration), { fontSize = 13, fontColor = { 207, 220, 244, 255 } }),
        UI.Panel { width = "100%", padding = 12, gap = 5, backgroundColor = { 9, 18, 36, 180 }, borderRadius = 12, children = {
            label(state.T("telemetry.title"), { fontSize = 12, fontWeight = "bold", fontColor = { 146, 225, 191, 255 } }),
            label(state.T("telemetry.damage", state.runStats_.damageTaken) .. "  ·  " .. state.T("telemetry.max_wave", state.runStats_.maxWave) .. "  ·  " .. state.T("telemetry.deaths", state.runStats_.deaths), { fontSize = 12, fontColor = { 183, 207, 242, 255 } }),
            label(state.T("telemetry.build"), { fontSize = 11, fontWeight = "bold", fontColor = { 177, 196, 231, 255 }, marginTop = 4 }),
            label(upgradeText, { fontSize = 11, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }),
        } },
        UI.Button { text = state.T("meta.archive"), variant = "secondary", width = "100%", height = 44, onClick = function() state.metaScreenReturn_ = "summary"; state.screen_ = "archive"; rebuild() end },
        UI.Button { text = state.T("game.restart"), variant = "primary", width = "100%", height = 48, onClick = function()
            state.screen_ = state.SCREEN_STAGE_SELECT; rebuild()
        end },
        UI.Button { text = state.T("game.back"), variant = "secondary", width = "100%", height = 44, onClick = function() state.screen_ = "language"; rebuild() end },
    } }
end

-- ── Stage / Arena Select Screen ─────────────────────────────────────────

local function stage_select_screen()
    local items = {}
    for i = 1, state.totalStages_ do
        local t = stages.theme(i)
        local unlocked = i <= state.stagesUnlocked_
        local bg = unlocked and t.bg or { 30, 30, 40, 220 }
        local border = unlocked and t.accent or { 80, 80, 90, 120 }
        local nameColor = unlocked and { 255, 255, 255, 255 } or { 100, 100, 110, 200 }
        local descColor = unlocked and { 190, 205, 230, 255 } or { 80, 80, 90, 180 }
        local lockIcon = unlocked and "" or " 🔒"

        local totalLv = stages.totalLevels(i)
        local summary = state.T("stage.levels", totalLv)
        local hasBoss = false
        for lv = 1, totalLv do
            local lvl = stages.level(i, lv)
            if lvl and lvl.bossWave then hasBoss = true; break end
        end
        if hasBoss then summary = summary .. " · " .. state.T("stage.boss_tag") end

        local stageIdx = i
        local card = UI.Button {
            text = "",
            width = "100%", minHeight = 72, marginBottom = 10,
            backgroundColor = bg, borderColor = border, borderWidth = 1, borderRadius = 12,
            opacity = unlocked and 1 or 0.55,
            onClick = function()
                if not unlocked then return end
                if callbacks.selectStage then
                    callbacks.selectStage(stageIdx)
                end
            end,
            children = {
                UI.Panel { flexDirection = "row", justifyContent = "space-between", alignItems = "center", padding = 12, children = {
                    UI.Panel { flexDirection = "column", gap = 2, children = {
                        label(stages.name(i, state.language_) .. lockIcon, { fontSize = 17, fontWeight = "bold", fontColor = nameColor }),
                        label(state.T("stage.levels", stages.totalLevels(i)), { fontSize = 11, fontColor = descColor }),
                    } },
                    UI.Panel { flexDirection = "column", alignItems = "flex-end", gap = 2, children = {
                        label(summary, { fontSize = 11, fontColor = descColor, textAlign = "right" }),
                    } },
                } },
            },
        }
        table.insert(items, card)
    end

    return UI.Panel { width = "90%", maxWidth = 560, padding = 20, gap = 4,
        backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 14, 22, 48, 245 }, to = { 22, 18, 38, 245 } },
        borderRadius = 22, borderWidth = 1, borderColor = { 130, 200, 255, 150 },
        children = {
            label(state.T("stage.title"), { fontSize = 24, fontWeight = "bold", fontColor = { 255, 230, 137, 255 }, textAlign = "center", marginBottom = 8 }),
            label(state.T("stage.subtitle"), { fontSize = 12, fontColor = { 150, 180, 220, 255 }, textAlign = "center", marginBottom = 12 }),
            table.unpack(items),
            UI.Button { text = state.T("game.back"), variant = "secondary", width = "100%", height = 44, marginTop = 8,
                onClick = function() state.screen_ = "language"; rebuild() end },
        } }
end

-- ── Stage Pause / Level Transition ──────────────────────────────────────

local function stage_pause_screen()
    local t = arena_theme()
    local nextLv = state.stageLevel_
    local lvl = stages.level(state.stage_, nextLv)
    local totalW = lvl and lvl.totalWaves or 0
    local hasMid = lvl and lvl.midBossWave ~= nil
    local hasBoss = lvl and lvl.bossWave ~= nil
    local tag = hasBoss and state.T("stage.boss_tag") or (hasMid and state.T("stage.midboss_tag") or "")
    local tagColor = hasBoss and t.bossAccent or { 140, 255, 255, 255 }

    return UI.Panel { width = "90%", maxWidth = 460, padding = 24, gap = 6, alignItems = "center",
        backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 18, 25, 50, 245 }, to = { 15, 20, 40, 245 } },
        borderRadius = 22, borderWidth = 1, borderColor = t.accentDim,
        children = {
            label(state.T("stage.name_tag", stages.name(state.stage_, state.language_)), { fontSize = 13, fontColor = t.accentDim }),
            label(state.T("stage.level_tag", nextLv, totalW), { fontSize = 22, fontWeight = "bold", fontColor = { 255, 255, 255, 255 }, textAlign = "center" }),
            tag ~= "" and label(tag, { fontSize = 12, fontColor = tagColor, textAlign = "center" }) or nil,
            label(state.T("stage.get_ready"), { fontSize = 11, fontColor = { 150, 180, 220, 255 }, textAlign = "center", marginTop = 4 }),
        } }
end

-- ── Stage Complete Summary ──────────────────────────────────────────────

local function stage_summary_screen()
    local t = arena_theme()
    local title = state.isVictory_ and state.T("stage.cleared") or state.T("stage.failed")
    local titleColor = state.isVictory_ and { 255, 230, 137, 255 } or { 255, 111, 126, 255 }
    local upgradeText = ""
    local upgrades = state.runStats_.upgrades or {}
    if #upgrades > 0 then
        local names = {}
        for _, id in ipairs(upgrades) do names[#names + 1] = module_name(id) end
        upgradeText = table.concat(names, " > ")
    end
    return UI.Panel { width = "90%", maxWidth = 520, padding = 24, gap = 6, alignItems = "center",
        backgroundGradient = { type = "linear", direction = "to-bottom-right", from = { 18, 25, 50, 245 }, to = { 15, 20, 40, 245 } },
        borderRadius = 22, borderWidth = 1, borderColor = state.isVictory_ and t.accent or { 255, 111, 126, 180 },
        children = {
            label(title, { fontSize = 26, fontWeight = "bold", fontColor = titleColor, textAlign = "center" }),
            label(stages.name(state.stage_, state.language_) .. " · " .. state.T("stage.level_tag", state.stageLevel_, state.wave_), { fontSize = 13, fontColor = t.accentDim }),
            label(state.T("telemetry.damage", state.runStats_.damageTaken) .. "  ·  " .. state.T("telemetry.deaths", state.runStats_.deaths or 0), { fontSize = 12, fontColor = { 183, 207, 242, 255 } }),
            label(state.T("telemetry.build"), { fontSize = 11, fontWeight = "bold", fontColor = { 177, 196, 231, 255 }, marginTop = 4 }),
            label(upgradeText, { fontSize = 11, fontColor = { 207, 220, 244, 255 }, textAlign = "center" }),
            state.isVictory_ and label(state.T("stage.unlocked", stages.name(state.stage_ + 1, state.language_)), { fontSize = 14, fontWeight = "bold", fontColor = { 255, 220, 100, 255 }, textAlign = "center", marginTop = 6, opacity = (state.stage_ < state.totalStages_ and state.stagesUnlocked_ > state.stage_ and 1 or 0) }),
            UI.Button { text = state.T("stage.next_stage"), variant = "primary", width = "100%", height = 48,
                onClick = function()
                    if state.stage_ < state.stagesUnlocked_ then state.stage_ = state.stage_ + 1 end
                    state.screen_ = state.SCREEN_STAGE_SELECT; rebuild()
                end, opacity = state.isVictory_ and state.stage_ < state.stagesUnlocked_ and 1 or 0 },
            UI.Button { text = state.T("game.restart"), variant = "secondary", width = "100%", height = 44,
                onClick = function() state.screen_ = state.SCREEN_STAGE_SELECT; rebuild() end },
            UI.Button { text = state.T("game.back"), variant = "secondary", width = "100%", height = 44,
                onClick = function() state.screen_ = "language"; rebuild() end },
        } }
end

function M.build(screen)
    if screen == "language" then return language_screen() end
    if screen == state.SCREEN_STAGE_SELECT then return stage_select_screen() end
    if screen == "game" then return game_screen() end
    if screen == "upgrade" then return upgrade_screen() end
    if screen == "wave_pause" then return wave_pause_screen() end
    if screen == state.SCREEN_STAGE_PAUSE then return stage_pause_screen() end
    if screen == state.SCREEN_STAGE_SUMMARY then return stage_summary_screen() end
    if screen == "archive" then return archive_screen() end
    if screen == "cosmetics" then return cosmetics_screen() end
    if screen == state.SCREEN_SHOP then return require("shop").build() end
    return summary_screen()
end

function M.update_hud()
    -- P5: Refresh stats panel each frame
    stats_panel.refresh()

    local player = state.player_

    -- HUD top label (integrity / score / fragments) — only update on change
    if state.hudLabel_ then
        local txt = state.T("game.integrity", math.max(0, player.integrity), player.maxIntegrity) .. "  |  " .. state.T("game.score", state.score_) .. "  |  " .. state.T("game.fragments", state.dataFragments_)
        if txt ~= state._hudCache then state.hudLabel_:SetText(txt); state._hudCache = txt end
    end

    -- XP label — only on change
    if state.xpLabel_ then
        local txt = state.T("game.level", state.level_) .. "  ·  " .. state.T("game.next_upgrade", math.max(0, state.levelGoal_ - state.levelProgress_))
        if txt ~= state._xpCache then state.xpLabel_:SetText(txt); state._xpCache = txt end
    end

    -- XP bar — quantized
    if state.xpBarFill_ then
        local ratio = math.floor(math.min(1, state.levelProgress_ / math.max(1, state.levelGoal_)) * 200) / 2
        if ratio ~= state._xpBarCache then
            state.xpBarFill_:SetStyle({ width = tostring(math.floor(ratio * 100)) .. "%" })
            state._xpBarCache = ratio
        end
    end

    -- Wave label — only on change
    if state.waveLabel_ then
        local stageName = stages.name(state.stage_, state.language_)
        local waveInfo = state.T("game.wave_info", stageName, state.stageLevel_, state.wave_, state.maxWaves_)
        local timeInfo = math.floor(state.runTime_)
        local modInfo = state.modifier_
        if waveInfo ~= state._waveTextCache or timeInfo ~= state._waveTimeCache or modInfo ~= state._waveModCache then
            state.waveLabel_:SetText(waveInfo .. "\n" .. state.T("game.time", timeInfo) .. "\n" .. state.T("game.modifier", state.T("modifier." .. modInfo)))
            state._waveTextCache = waveInfo; state._waveTimeCache = timeInfo; state._waveModCache = modInfo
        end
    end

    -- Module/Weapon label — only on change
    if state.moduleLabel_ then
        local txt = state.T("game.weapons", modules_text())
        if txt ~= state._modCache then state.moduleLabel_:SetText(txt); state._modCache = txt end
    end

    -- Gold display is in stats_panel (goldLabel_ removed)

    -- Feedback label — only on change
    if state.feedbackLabel_ then
        local show = state.surgeFlash_ > 0
        if show ~= state._fbCache then
            state.feedbackLabel_:SetStyle({ opacity = show and 1 or 0 })
            state.feedbackLabel_:SetText(show and state.T("game.telegraph") or "")
            state._fbCache = show
        end
    end

    -- Shell label — only on change
    if state.shellLabel_ then
        local shellActive = state.activeModules_.shell and player.maxShell > 0
        local shellKey = shellActive and string.format("%d/%d", math.ceil(player.shell), player.maxShell) or ""
        if shellKey ~= state._shellCache then
            if shellActive then
                state.shellLabel_:SetText(state.T("game.shell", math.ceil(player.shell), player.maxShell))
                state.shellLabel_:SetStyle({ opacity = 1 })
            else
                state.shellLabel_:SetText(""); state.shellLabel_:SetStyle({ opacity = 0 })
            end
            state._shellCache = shellKey
        end
    end

    -- Shell bar — quantized
    if state.shellBarFill_ then
        local ratio = math.floor((player.maxShell > 0 and math.min(1, player.shell / player.maxShell) or 0) * 200) / 2
        if ratio ~= state._shellBarCache then
            state.shellBarFill_:SetStyle({ width = tostring(math.floor(ratio * 100)) .. "%" })
            state._shellBarCache = ratio
        end
    end

    -- Boss bar — only on change
    if state.bossLabel_ and state.bossBarFill_ then
        local bossAlive = state.boss_ and not state.boss_.dead
        if bossAlive ~= state._bossAliveCache then
            if bossAlive then
                state.bossLabel_:SetText(state.T("boss.bar", math.ceil(state.boss_.integrity), state.boss_.maxIntegrity))
                state.bossLabel_:SetStyle({ opacity = 1 })
                local bossRatio = math.max(0, state.boss_.integrity / state.boss_.maxIntegrity)
                state.bossBarFill_:SetStyle({ width = tostring(math.floor(bossRatio * 100)) .. "%" })
                if state.bossCard_ then safe_style(state.bossCard_, { opacity = 1 }) end
            else
                state.bossLabel_:SetStyle({ opacity = 0 })
                if state.bossCard_ then safe_style(state.bossCard_, { opacity = 0 }) end
            end
            state._bossAliveCache = bossAlive
        elseif bossAlive then
            local bossRatio = math.floor(math.max(0, state.boss_.integrity / state.boss_.maxIntegrity) * 200) / 2
            local bossText = string.format("%d/%d", math.ceil(state.boss_.integrity), state.boss_.maxIntegrity)
            if bossRatio ~= state._bossBarCache then
                state.bossBarFill_:SetStyle({ width = tostring(math.floor(bossRatio * 100)) .. "%" })
                state._bossBarCache = bossRatio
            end
            if bossText ~= state._bossTextCache then
                state.bossLabel_:SetText(state.T("boss.bar", math.ceil(state.boss_.integrity), state.boss_.maxIntegrity))
                state._bossTextCache = bossText
            end
        end
    end

    -- Mid-boss bar — only on change
    if state.midBossLabel_ and state.midBossBarFill_ then
        local midAlive = state.midBoss_ and not state.midBoss_.dead
        if midAlive ~= state._midAliveCache then
            if midAlive then
                state.midBossLabel_:SetText(state.T("midboss.bar", math.ceil(state.midBoss_.integrity), state.midBoss_.maxIntegrity))
                state.midBossLabel_:SetStyle({ opacity = 1 })
                local midRatio = math.max(0, state.midBoss_.integrity / state.midBoss_.maxIntegrity)
                state.midBossBarFill_:SetStyle({ width = tostring(math.floor(midRatio * 100)) .. "%" })
                if state.midBossCard_ then safe_style(state.midBossCard_, { opacity = 1 }) end
            else
                state.midBossLabel_:SetStyle({ opacity = 0 })
                if state.midBossCard_ then safe_style(state.midBossCard_, { opacity = 0 }) end
            end
            state._midAliveCache = midAlive
        elseif midAlive then
            local midRatio = math.floor(math.max(0, state.midBoss_.integrity / state.midBoss_.maxIntegrity) * 200) / 2
            local midText = string.format("%d/%d", math.ceil(state.midBoss_.integrity), state.midBoss_.maxIntegrity)
            if midRatio ~= state._midBarCache then
                state.midBossBarFill_:SetStyle({ width = tostring(math.floor(midRatio * 100)) .. "%" })
                state._midBarCache = midRatio
            end
            if midText ~= state._midTextCache then
                state.midBossLabel_:SetText(state.T("midboss.bar", math.ceil(state.midBoss_.integrity), state.midBoss_.maxIntegrity))
                state._midTextCache = midText
            end
        end
    end

    -- Modifier dock — only update opacity/color on quantized change
    if state.modifierDockLabel_ and state.modifierDock_ then
        local dockMod = state.modifier_ or "none"
        local show = state.waveTime_ > 0 and state.waveTime_ < 3.0 and dockMod ~= "none" and state.screen_ == "game"
        local alpha = show and (1 - math.max(0, (state.waveTime_ - 2.0) / 1.0)) or 0
        local qAlpha = math.floor(alpha * 20)
        if qAlpha ~= state._dockAlphaCache or show ~= state._dockShowCache then
            safe_style(state.modifierDock_, { opacity = alpha })
            state._dockAlphaCache = qAlpha; state._dockShowCache = show
        end
        if alpha > 0.01 then
            local modKey = dockMod .. (state.lang_ or "")
            if modKey ~= state._dockModCache then
                local icons = { compression = "⊲", surge = "◇", overclock = "⚡" }
                local labels = { compression = { zh = "压缩", en = "Compress" }, surge = { zh = "波动", en = "Surge" }, overclock = { zh = "加速", en = "Overclock" } }
                local colors = { compression = { 255, 110, 70 }, surge = { 140, 140, 255 }, overclock = { 220, 220, 80 } }
                local name = labels[dockMod] and labels[dockMod][state.lang_ == "en" and "en" or "zh"] or dockMod
                state.modifierDockLabel_:SetText((icons[dockMod] or "") .. " " .. name)
                safe_style(state.modifierDock_, { borderColor = { colors[dockMod][1], colors[dockMod][2], colors[dockMod][3], math.floor(alpha * 200) } })
                state._dockModCache = modKey
            end
        end
    end

    -- Stage intro overlay — only on state change
    if state.stageIntroLabel_ then
        local introAlpha = state.stageIntroTimer_ > 0 and math.min(1, state.stageIntroTimer_ / 1.5) or 0
        local showIntro = introAlpha > 0.01
        if showIntro ~= state._introShowCache then
            state.stageIntroLabel_:SetStyle({ fontColor = { 255, 255, 255, math.floor(introAlpha * 200) } })
            if showIntro then
                local stageName = stages.name(state.stage_, state.language_)
                state.stageIntroLabel_:SetText(stageName .. " · " .. state.T("stage.level_tag", state.stageLevel_, state.maxWaves_))
            end
            state._introShowCache = showIntro
        end
    end
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
    elseif state._shakeWasActive then
        safe_style(state.gameWorld_, { left = 0, top = 0 })
        state.shakeIntensity_ = 0
    end
    state._shakeWasActive = state.shakeTime_ > 0
end

return M
