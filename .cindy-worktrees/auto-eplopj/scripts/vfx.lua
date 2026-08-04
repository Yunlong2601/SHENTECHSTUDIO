-- vfx.lua — Global visual feedback: death particles, projectile trails, wave banners (P8)
-- Owns all VFX arrays internally; exports destroy_all() for ClearEntities.

local UI    = require("urhox-libs/UI")
local state = require("state")

local M = {}
local callbacks = {}

-- Internal arrays for long-lived particles
local deathParticles = {}   -- { x, y, vx, vy, life, maxLife, color, widget, size }
local trailDots = {}        -- { x, y, life, maxLife, color, widget, size }
local waveBanner = nil      -- { widget, timer }

-- ── Callbacks (set by main.lua) ──────────────────────────────────────────

function M.configure(cb) callbacks = cb or {} end

local function gameWorld() return state.gameWorld_ end
local function pos(w, x, y, sz)
    if callbacks.setWidgetPosition then callbacks.setWidgetPosition(w, x, y, sz) end
end
local function destroy(w)
    if w and callbacks.destroyWidget then callbacks.destroyWidget(w) end
end

-- ── Helper: create a small diamond/particle widget ───────────────────────

local function make_dot(color, size)
    return UI.Panel {
        position = "absolute", width = size, height = size,
        backgroundGradient = { type = "radial",
            from = color,
            to   = { color[1], color[2], color[3], 0 } },
        borderColor = color, borderWidth = 1, borderRadius = size * 0.5,
        pointerEvents = "none", opacity = 1,
    }
end

-- ── Death particle burst (enemy killed) ──────────────────────────────────

function M.spawn_death_burst(x, y, color, count)
    local gw = gameWorld()
    if not gw then return end
    count = count or 5
    for _ = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = 70 + math.random() * 140
        local life = 0.30 + math.random() * 0.35
        local sz = 3 + math.random() * 5
        local w = make_dot(color, sz)
        gw:AddChild(w)
        table.insert(deathParticles, {
            x = x, y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = life, maxLife = life,
            color = color, widget = w, size = sz,
        })
    end
end

-- ── Projectile trail dots ────────────────────────────────────────────────

function M.spawn_trail_dot(x, y, color, size)
    local gw = gameWorld()
    if not gw then return end
    local w = make_dot(color, size or 4)
    w:SetStyle({ opacity = 0.55 })  -- trails are semi-transparent
    gw:AddChild(w)
    table.insert(trailDots, {
        x = x, y = y, vx = 0, vy = 0,
        life = 0.18 + math.random() * 0.12,
        maxLife = 0.28,
        color = color, widget = w, size = size or 4,
    })
    -- Cap trail dots to prevent runaway widget count
    if #trailDots > 120 then
        local old = table.remove(trailDots, 1)
        destroy(old.widget)
    end
end

-- ── Wave/level banner ────────────────────────────────────────────────────

function M.show_wave_banner(text, color)
    local gw = gameWorld()
    if not gw then return end
    -- Destroy previous banner if still alive
    if waveBanner then
        destroy(waveBanner.widget)
    end
    local w = UI.Label {
        position = "absolute",
        text = text or "---",
        fontSize = 32, fontWeight = "bold",
        fontColor = color or { 255, 239, 164, 255 },
        textAlign = "center",
        pointerEvents = "none",
        opacity = 0,
    }
    gw:AddChild(w)
    waveBanner = { widget = w, timer = 2.2, phase = 0 }
end

-- ── Screen flash (used for boss spawn/death impacts) ────────────────────

function M.screen_flash(color, intensity)
    -- piggyback on ui's existing hit flash system
    state.hitFlashColor_ = color or { 255, 239, 164, 255 }
    state.hitFlash_ = math.max(state.hitFlash_, intensity or 0.5)
    state.hitFlashDuration_ = math.max(state.hitFlashDuration_, 0.35)
end

-- ── Big screen shake (boss events) ───────────────────────────────────────

function M.big_shake(intensity, duration)
    state.shakeIntensity_ = math.max(state.shakeIntensity_, intensity or 0.4)
    state.shakeDuration_ = math.max(state.shakeDuration_, duration or 0.3)
    state.shakeTime_ = state.shakeDuration_
end

-- ── Update (called every frame from main.lua) ────────────────────────────

-- Per-projectile trail accumulator (indexed by projectile's own table ref)
-- We can't key by table in Lua easily, so we use a parallel approach:
-- each projectile in state.projectiles_ now carries _trailAccum

local function spawn_projectile_trails(timeStep)
    for _, proj in ipairs(state.projectiles_) do
        -- Each projectile accumulates trail timer
        proj._trailAccum = (proj._trailAccum or 0) + timeStep
        local interval = proj._trailInterval or 0.04  -- default 0.04s between dots
        while proj._trailAccum >= interval do
            proj._trailAccum = proj._trailAccum - interval
            local dotColor = proj._color or { 200, 200, 220, 200 }
            M.spawn_trail_dot(proj.x, proj.y, dotColor, 4)
        end
    end
end

local function update_particles(list, timeStep)
    for i = #list, 1, -1 do
        local p = list[i]
        p.x = p.x + (p.vx or 0) * timeStep
        p.y = p.y + (p.vy or 0) * timeStep
        p.life = p.life - timeStep
        if p.life <= 0 then
            destroy(p.widget)
            table.remove(list, i)
        else
            local fade = p.life / p.maxLife
            pos(p.widget, p.x, p.y, p.size * (0.3 + fade * 0.7))
            p.widget:SetStyle({ opacity = fade })
        end
    end
end

local function update_banner(timeStep)
    if not waveBanner then return end
    waveBanner.timer = waveBanner.timer - timeStep
    local t = waveBanner.timer
    local w = waveBanner.widget
    local screenW = state.worldWidth_ or 800
    if t > 1.5 then
        -- Fade in phase
        local fadeIn = math.min(1, (2.2 - t) / 0.7)
        w:SetStyle({ opacity = fadeIn, left = screenW * 0.5 - 120, top = (state.worldHeight_ or 600) * 0.35 })
    elseif t > 0.5 then
        -- Hold phase
        w:SetStyle({ opacity = 1 })
    elseif t > 0 then
        -- Fade out
        w:SetStyle({ opacity = t / 0.5 })
    else
        destroy(w)
        waveBanner = nil
    end
end

function M.update(timeStep)
    spawn_projectile_trails(timeStep)
    update_particles(deathParticles, timeStep)
    update_particles(trailDots, timeStep)
    update_banner(timeStep)
end

-- ── Cleanup ───────────────────────────────────────────────────────────────

function M.destroy_all()
    for _, p in ipairs(deathParticles) do destroy(p.widget) end
    for _, t in ipairs(trailDots) do destroy(t.widget) end
    if waveBanner then destroy(waveBanner.widget); waveBanner = nil end
    deathParticles = {}
    trailDots = {}
end

return M
