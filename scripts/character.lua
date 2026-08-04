-- character.lua — Visible player character: geometric core + humanoid hints (P4.3)
-- P7: smooth turning, hit flash, idle bob, weapon orbit VFX.
-- Design: diamond body (distinct from enemy circles), bright cyan,
-- two white "eye" dots, directional face highlight, movement trail.
-- Monsters = pure geometry. Player = geometry + humanity. Split by shape + color.

local UI   = require("urhox-libs/UI")
local state = require("state")
local weapons = require("weapons")

local M = {}

local BODY_SIZE   = 36
local EYE_SIZE    = 5
local TRAIL_LIFE  = 0.35
local TURN_LERP   = 6.5    -- degrees/sec → radians/frame smoothness factor
local IDLE_BOB_AMP = 2.5   -- px, vertical idle oscillation
local IDLE_BOB_SPD = 2.2   -- rad/s, idle bob frequency

-- Default colors (restored after flash)
local DEFAULT_BORDER  = { 82, 214, 255, 240 }
local DEFAULT_FILL_F  = { 8, 30, 56, 240 }
local DEFAULT_FILL_T  = { 4, 18, 38, 240 }

-- ── Orbit VFX ────────────────────────────────────────────────────────────

local ORBIT_RADII = { 44, 52, 44, 56, 52, 48 }   -- per slot: odds ↔ evens alternate
local ORBIT_SIZE  = 7   -- small diamond

local function orbit_color(wid)
  local def = weapons.get_def(wid)
  return def and def.color or { 82, 214, 255, 200 }
end

local function create_orbit_widget(color)
  local c = color or { 82, 214, 255, 200 }
  local w = UI.Panel {
    position = "absolute", width = ORBIT_SIZE, height = ORBIT_SIZE,
    backgroundColor = { c[1], c[2], c[3], math.floor(c[4] * 0.5) },
    borderColor = c, borderWidth = 1, borderRadius = 1,
    pointerEvents = "none",
  }
  return w
end

local function destroy_orbit_widget(w)
  if w then w:Destroy() end
end

-- ── Create ────────────────────────────────────────────────────────────────

function M.create()
  if not state.gameWorld_ then return end

  local body = UI.Panel {
    id = "charBody", position = "absolute",
    width = BODY_SIZE, height = BODY_SIZE,
    backgroundGradient = { type = "linear", direction = "to-bottom-right",
      from = DEFAULT_FILL_F, to = DEFAULT_FILL_T },
    borderColor = DEFAULT_BORDER, borderWidth = 3,
    borderRadius = 3,
    pointerEvents = "none",
  }

  local innerGlow = UI.Panel {
    id = "charGlow", position = "absolute",
    width = BODY_SIZE - 10, height = BODY_SIZE - 10,
    backgroundGradient = { type = "linear", direction = "to-bottom-right",
      from = { 20, 100, 180, 120 }, to = { 10, 60, 120, 80 } },
    borderColor = { 110, 230, 255, 140 }, borderWidth = 1,
    borderRadius = 2,
    pointerEvents = "none",
  }

  local eyeL = UI.Panel {
    id = "charEyeL", position = "absolute",
    width = EYE_SIZE, height = EYE_SIZE,
    backgroundColor = { 240, 250, 255, 255 },
    borderRadius = EYE_SIZE * 0.5,
    pointerEvents = "none",
  }

  local eyeR = UI.Panel {
    id = "charEyeR", position = "absolute",
    width = EYE_SIZE, height = EYE_SIZE,
    backgroundColor = { 240, 250, 255, 255 },
    borderRadius = EYE_SIZE * 0.5,
    pointerEvents = "none",
  }

  local face = UI.Panel {
    id = "charFace", position = "absolute",
    width = 14, height = 4,
    backgroundColor = { 140, 240, 255, 220 },
    borderRadius = 2,
    pointerEvents = "none",
  }

  state.gameWorld_:AddChild(body)
  state.gameWorld_:AddChild(innerGlow)
  state.gameWorld_:AddChild(eyeL)
  state.gameWorld_:AddChild(eyeR)
  state.gameWorld_:AddChild(face)

  state.charWidgets_ = {
    body = body, glow = innerGlow,
    eyeL = eyeL, eyeR = eyeR, face = face,
  }

  -- Orbit VFX pool: 6 slots, widgets created lazily
  state.charOrbit_ = {}
  for i = 1, 6 do
    state.charOrbit_[i] = { widget = nil, slotId = nil }
  end

  state._facingAngle = 0  -- P7: lerped facing direction (radians)
  state._bobPhase    = 0  -- P7: idle bob phase accumulator

  state.charTrail_ = {}
end

-- ── Update ────────────────────────────────────────────────────────────────

function M.update(timeStep)
  local cw = state.charWidgets_
  if not cw then return end
  local p = state.player_
  local cx, cy = p.x, p.y

  -- ── Movement direction (smoothed) ──────────────────────────────────────
  local dx = (p._vx or 0) * 0.6 + (state._lastMoveDx or 0) * 0.4
  local dy = (p._vy or 0) * 0.6 + (state._lastMoveDy or 0) * 0.4
  local speed = math.sqrt(dx * dx + dy * dy)
  state._lastMoveDx, state._lastMoveDy = dx, dy

  -- P7: Lerp facing angle toward movement direction
  if speed > 8 then
    local targetAngle = math.atan2(dy, dx)
    local fa = state._facingAngle or 0
    -- shortest-rotation lerp
    local diff = targetAngle - fa
    while diff > math.pi  do diff = diff - 2 * math.pi end
    while diff < -math.pi do diff = diff + 2 * math.pi end
    fa = fa + diff * math.min(1, TURN_LERP * timeStep)
    state._facingAngle = fa
  end

  -- P7: Idle bob
  local bobY = 0
  if speed < 15 then
    state._bobPhase = (state._bobPhase or 0) + IDLE_BOB_SPD * timeStep
    bobY = math.sin(state._bobPhase) * IDLE_BOB_AMP
  else
    state._bobPhase = 0
  end

  -- ── Position body & glow ───────────────────────────────────────────────
  local half = BODY_SIZE * 0.5
  local setPos = function(w, x, y, s)
    if w then w:SetStyle({ left = x - s * 0.5, top = y - s * 0.5 }) end
  end
  setPos(cw.body, cx, cy + bobY, BODY_SIZE)
  setPos(cw.glow, cx, cy + bobY, BODY_SIZE - 10)

  -- P7: Hit flash — body reacts to state.hitFlash_
  local flash = state.hitFlash_ or 0
  if flash > 0.03 then
    local fcol = state.hitFlashColor_ or { 255, 111, 126, 255 }
    local fAlpha = math.floor(160 + flash * 300)
    -- Flash border to hit color, brighten fill
    cw.body:SetStyle({
      borderColor = { fcol[1], fcol[2], fcol[3], math.min(255, fAlpha) },
      borderWidth = 3 + flash * 5,  -- border thickens on hit
      backgroundGradient = {
        type = "linear", direction = "to-bottom-right",
        from = { fcol[1], fcol[2], fcol[3], math.floor(60 + flash * 200) },
        to   = { math.floor(fcol[1] * 0.5), math.floor(fcol[2] * 0.5), math.floor(fcol[3] * 0.5), math.floor(40 + flash * 160) },
      },
    })
    cw.glow:SetStyle({ opacity = math.min(1, flash * 2) })
  else
    -- Restore default
    cw.body:SetStyle({
      borderColor = DEFAULT_BORDER, borderWidth = 3,
      backgroundGradient = { type = "linear", direction = "to-bottom-right",
        from = DEFAULT_FILL_F, to = DEFAULT_FILL_T },
    })
    cw.glow:SetStyle({ opacity = 0.4 })
  end

  -- ── Eyes & face (use lerped facing angle) ──────────────────────────────
  local fa = state._facingAngle or 0
  local eyeLookX, eyeLookY = 0, 0
  if speed > 5 then
    eyeLookX = math.cos(fa) * 3
    eyeLookY = math.sin(fa) * 3
  end
  local eyeOffY = -7 + bobY
  setPos(cw.eyeL, cx - 6 + eyeLookX, cy + eyeOffY, EYE_SIZE)
  setPos(cw.eyeR, cx + 6 + eyeLookX, cy + eyeOffY, EYE_SIZE)

  -- Face indicator on perimeter in facing direction
  local faceDist = 18
  if speed > 8 then
    local fx = cx + math.cos(fa) * faceDist
    local fy = cy + math.sin(fa) * faceDist + bobY
    cw.face:SetStyle({
      left = fx - 7, top = fy - 2,
      opacity = math.min(1, speed / 80),
      backgroundColor = { 140, 240, 255, math.floor(180 + speed * 0.5) },
    })
  else
    cw.face:SetStyle({ opacity = 0.3 })
  end

  -- ── Weapon orbit VFX (P7) ──────────────────────────────────────────────
  M.update_orbits(timeStep, cx, cy + bobY)

  -- ── Movement trail ─────────────────────────────────────────────────────
  if speed > 30 then
    M.spawn_trail(cx, cy, speed)
  end
  M.update_trail(timeStep)

  -- Player widget (backward compat)
  if state.playerWidget_ then
    state.playerWidget_:SetStyle({ left = cx - 16, top = cy - 16 })
  end
end

-- ── Weapon orbit VFX ─────────────────────────────────────────────────────

function M.update_orbits(timeStep, cx, cy)
  if not state.charOrbit_ or not state.gameWorld_ then return end
  local orbits = state.charOrbit_

  for slot = 1, 6 do
    local entry = orbits[slot] or { widget = nil, slotId = nil }
    local wdata = state.weapons_ and state.weapons_[slot]

    -- Destroy if no weapon in this slot
    if not wdata then
      if entry.widget then
        destroy_orbit_widget(entry.widget)
        orbits[slot] = { widget = nil, slotId = nil }
      end
      goto continue_slot
    end

    -- Create or recreate if weapon changed
    if not entry.widget or entry.slotId ~= wdata.id then
      if entry.widget then destroy_orbit_widget(entry.widget) end
      local col = orbit_color(wdata.id)
      local w = create_orbit_widget(col)
      state.gameWorld_:AddChild(w)
      orbits[slot] = { widget = w, slotId = wdata.id, angle = orbits[slot] and orbits[slot].angle or (math.pi * 2 * slot / 6) }
    end

    -- Rotate
    local ent = orbits[slot]
    local orbSpeed = 2.4 * (1 + (state.statAxes_.attackSpeed or 0) * 0.02)
    ent.angle = (ent.angle or 0) + orbSpeed * timeStep
    local r = ORBIT_RADII[slot] or 48
    local ox = cx + math.cos(ent.angle) * r
    local oy = cy + math.sin(ent.angle) * r
    ent.widget:SetStyle({
      left = ox - ORBIT_SIZE * 0.5,
      top  = oy - ORBIT_SIZE * 0.5,
      opacity = 0.7 + math.sin(ent.angle * 1.7) * 0.2,
    })

    ::continue_slot::
  end
end

-- ── Trail system ──────────────────────────────────────────────────────────

function M.spawn_trail(x, y, _speed)
  if not state.gameWorld_ then return end
  if #state.charTrail_ > 8 then
    local old = table.remove(state.charTrail_, 1)
    if old.widget then old.widget:Destroy() end
  end

  local dot = UI.Panel {
    position = "absolute", width = 8, height = 8,
    backgroundColor = { 60, 180, 220, 160 },
    borderColor = { 100, 210, 240, 100 }, borderWidth = 1,
    borderRadius = 2,
    pointerEvents = "none",
  }
  state.gameWorld_:AddChild(dot)

  table.insert(state.charTrail_, {
    x = x, y = y, age = 0, lifetime = TRAIL_LIFE, widget = dot,
  })
end

function M.update_trail(timeStep)
  for i = #state.charTrail_, 1, -1 do
    local t = state.charTrail_[i]
    t.age = t.age + timeStep
    if t.age >= t.lifetime then
      t.widget:Destroy()
      table.remove(state.charTrail_, i)
    else
      local fade = 1 - t.age / t.lifetime
      t.widget:SetStyle({
        left = t.x - 4, top = t.y - 4,
        opacity = fade * 0.6,
        backgroundColor = { 60, 180, 220, math.floor(160 * fade) },
      })
    end
  end
end

-- ── Cleanup ───────────────────────────────────────────────────────────────

function M.destroy()
  if state.charWidgets_ then
    for _, w in pairs(state.charWidgets_) do
      if w then w:Destroy() end
    end
    state.charWidgets_ = nil
  end
  -- Destroy orbit widgets
  if state.charOrbit_ then
    for _, entry in ipairs(state.charOrbit_) do
      if entry.widget then entry.widget:Destroy() end
    end
    state.charOrbit_ = {}
  end
  for _, t in ipairs(state.charTrail_ or {}) do
    if t.widget then t.widget:Destroy() end
  end
  state.charTrail_ = {}
  state._facingAngle = 0
  state._bobPhase = 0
end

return M
