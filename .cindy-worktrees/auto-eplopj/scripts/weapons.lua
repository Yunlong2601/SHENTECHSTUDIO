-- weapons.lua — Brotato-style 6-slot auto-fire weapon system (P4)
-- Replaces modules.lua. Each weapon fires independently at nearest enemy.

local UI   = require("urhox-libs/UI")
local state = require("state")
local stat_items = require("data.stat_items")

local M = {}
local callbacks = {}

-- ── Stat-aware damage calc (P5) ─────────────────────────────────────────
local function effective_damage(baseDmg)
    local mult = 1 + (state.statAxes_.damage or 0) * 0.08
    return baseDmg * mult
end

local function roll_crit(dmg)
    local chance = math.min(0.95, (state.statAxes_.critChance or 0) * 0.04)
    if math.random() < chance then
        return dmg * 1.5, true
    end
    return dmg, false
end

local function effective_range(baseRange)
    local mult = 1 + (state.statAxes_.range or 0) * 0.05
    return baseRange * mult
end

-- ── Weapon definitions ──────────────────────────────────────────────────
-- P9 tuning: Rationale per weapon —
--   Bow: highest raw DPS (9.38) but pierce=1 → single-target specialist, safe range.
--   Blade: 8.33 DPS, 4 pierce in arc → melee crowd clear, entry-level.
--   Thrown: 8.33 DPS, 4 pierce → fast mid-range multi-hit, competes with Bow on density.
--   Crossbow: 7.76 DPS, 3 pierce → longest range, positional advantage.
--   Blunt: 7.39 DPS, 6 pierce → heavy melee CC, clears everything in arc.
--   Staff: 7.08 DPS, AoE 50 @ half-dmg → splash specialist, scales with enemy density.
-- Prices updated in shop.lua to match combat value.
local DEFS = {
  blade = {
    name = "Blade", tag = "melee", damage = 5, cooldown = 0.60,
    range = 55, pierce = 4, -- fast melee, hits arc
    color = { 82, 214, 255, 255 },   -- cyan, matches player
  },
  bow = {
    name = "Bow", tag = "ranged", damage = 3, cooldown = 0.32,
    range = 380, pierce = 1,         -- fastest fire rate, single-target
    color = { 120, 255, 180, 255 },  -- green
  },
  staff = {
    name = "Staff", tag = "magic", damage = 8.5, cooldown = 1.20,
    range = 300, pierce = 1,
    color = { 180, 120, 255, 255 },  -- purple
  },
  blunt = {
    name = "Blunt", tag = "melee", damage = 6.5, cooldown = 0.88,
    range = 65, pierce = 6,          -- wide arc, heavy knock feel
    color = { 255, 170, 80, 255 },   -- orange
  },
  crossbow = {
    name = "Crossbow", tag = "ranged", damage = 4.5, cooldown = 0.58,
    range = 420, pierce = 3,         -- long-range piercing bolt
    color = { 255, 130, 70, 255 },   -- red-orange
  },
  thrown = {
    name = "Thrown", tag = "ranged", damage = 3.5, cooldown = 0.42,
    range = 260, pierce = 4,         -- fast multi-pierce, mid-range
    color = { 255, 215, 50, 255 },   -- gold
  },
}

-- ── Config / callbacks ──────────────────────────────────────────────────

function M.configure(cb) callbacks = cb or {} end

local function ppos() return state.player_.x, state.player_.y end
local function nearest() return callbacks.findNearestEnemy and callbacks.findNearestEnemy() end

-- ── Melee: swing arc ────────────────────────────────────────────────────

function M.fire_melee(wep)
  local px, py = ppos()
  local tgt = nearest()
  local angle = tgt and math.atan2(tgt.y - py, tgt.x - px) or 0

  local erange = effective_range(wep.range)

  -- Arc visual
  local arc
  if state.gameWorld_ then
    arc = UI.Panel {
      position = "absolute", width = erange * 2, height = erange * 2,
      backgroundGradient = { type = "radial",
        from = { wep.color[1], wep.color[2], wep.color[3], 100 },
        to   = { wep.color[1], wep.color[2], wep.color[3], 0 } },
      borderColor = wep.color, borderWidth = 2, borderRadius = erange,
      pointerEvents = "none", opacity = 0.35,
    }
    state.gameWorld_:AddChild(arc)
    callbacks.setWidgetPosition(arc, px, py, erange * 2)
  end

  -- Damage enemies within forward 120° arc
  local hit = 0
  for _, e in ipairs(state.enemies_) do
    if not e.dead and hit < wep.pierce then
      local dx, dy = e.x - px, e.y - py
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist < erange + e.radius then
        local eA = math.atan2(dy, dx)
        local diff = math.abs(eA - angle)
        if diff > math.pi then diff = 2 * math.pi - diff end
        if diff < math.pi * 0.65 then
          local dmg, isCrit = roll_crit(effective_damage(wep.damage))
          callbacks.damageEnemy(e, dmg)
          hit = hit + 1
        end
      end
    end
  end

  -- Arc cleanup
  if arc then
    table.insert(state.projectiles_, {
      widget = arc, life = 0.14, x = px, y = py,
      radius = 0, damage = 0, vx = 0, vy = 0, pierce = 0,
    })
  end
end

-- ── Ranged: projectile at nearest enemy ─────────────────────────────────

function M.fire_ranged(wep)
  local px, py = ppos()
  local tgt = nearest()
  if not tgt or not state.gameWorld_ then return end

  local dx, dy = tgt.x - px, tgt.y - py
  local len = math.sqrt(dx * dx + dy * dy)
  if len <= 0 then return end
  local speed = 420 * (1 + (state.statAxes_.range or 0) * 0.03)
  local vx, vy = dx / len * speed, dy / len * speed

  local dmg, isCrit = roll_crit(effective_damage(wep.damage))

  local colorToUse = isCrit and { 255, 221, 68, 255 } or wep.color  -- gold on crit
  local w = UI.Panel {
    position = "absolute", width = 8, height = 8,
    backgroundGradient = { type = "radial",
      from = colorToUse,
      to   = { colorToUse[1], colorToUse[2], colorToUse[3], 80 } },
    borderColor = colorToUse, borderWidth = isCrit and 2 or 1, borderRadius = 4,
    pointerEvents = "none",
  }
  state.gameWorld_:AddChild(w)

  table.insert(state.projectiles_, {
    x = px, y = py, vx = vx, vy = vy, radius = 4,
    damage = dmg, life = 1.4, pierce = wep.pierce, widget = w,
    isCrit = isCrit, _trailAccum = 0, _trailInterval = 0.05,
    _color = colorToUse,
  })
end

-- ── Magic: slow bolt + small AoE on-hit ─────────────────────────────────

function M.fire_magic(wep)
  local px, py = ppos()
  local tgt = nearest()
  if not tgt or not state.gameWorld_ then return end

  local dx, dy = tgt.x - px, tgt.y - py
  local len = math.sqrt(dx * dx + dy * dy)
  if len <= 0 then return end
  local speed = 260 * (1 + (state.statAxes_.range or 0) * 0.03)
  local vx, vy = dx / len * speed, dy / len * speed

  local dmg, isCrit = roll_crit(effective_damage(wep.damage))

  local colorToUse = isCrit and { 255, 221, 68, 255 } or wep.color
  local w = UI.Panel {
    position = "absolute", width = 13, height = 13,
    backgroundGradient = { type = "radial",
      from = colorToUse,
      to   = { colorToUse[1], colorToUse[2], colorToUse[3], 40 } },
    borderColor = colorToUse, borderWidth = isCrit and 3 or 2, borderRadius = 7,
    pointerEvents = "none",
  }
  state.gameWorld_:AddChild(w)

  table.insert(state.projectiles_, {
    x = px, y = py, vx = vx, vy = vy, radius = 7,
    damage = dmg, life = 1.8, pierce = wep.pierce, widget = w,
    onHitAoE = 50, isCrit = isCrit, _trailAccum = 0, _trailInterval = 0.04,
    _color = colorToUse,
  })
end

-- ── Update: tick cooldowns, fire each weapon ────────────────────────────

function M.update(timeStep)
  if not state.weapons_ then return end

  for slot = 1, 6 do
    local w = state.weapons_[slot]
    if w then
      w.fireTimer = (w.fireTimer or 0) - timeStep

      if w.fireTimer <= 0 then
        local def = DEFS[w.id]
        if not def then goto continue end

        -- Cooldown modified by attackSpeed stat
        local cd = def.cooldown / (1 + state.statAxes_.attackSpeed * 0.04)
        w.fireTimer = math.max(0.12, cd)

        if     def.tag == "melee"  then M.fire_melee(def)
        elseif def.tag == "magic"  then M.fire_magic(def)
        else                            M.fire_ranged(def)
        end
        ::continue::
      end
    end
  end
end

-- ── Slot management ─────────────────────────────────────────────────────

function M.equip(weaponId, slot)
  slot = slot or M.find_empty()
  if not slot then return false end
  if not DEFS[weaponId] then return false end
  state.weapons_[slot] = {
    id = weaponId,
    fireTimer = DEFS[weaponId].cooldown * 0.35,  -- first shot faster
  }
  return true
end

function M.find_empty()
  for i = 1, 6 do
    if not state.weapons_[i] then return i end
  end
  return nil
end

function M.weapon_count()
  local n = 0
  for i = 1, 6 do if state.weapons_[i] then n = n + 1 end end
  return n
end

function M.get_def(id) return DEFS[id] end
function M.all_defs() return DEFS end

return M
