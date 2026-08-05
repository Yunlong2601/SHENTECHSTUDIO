-- audio.lua -- AudioManager for Geometry Breakout
-- Creates a minimal Scene to host SoundListener + SoundSource components,
-- enabling audio in a UI-widget-only game that has no Scene/Node hierarchy.
--
-- Based on AUDIO_DIRECTION.md S6.2 (AudioManager Module Design).
-- See docs/ADR/ADR-007-audio-system-architecture.md for architecture decision.
--
-- Usage:
--   local audio_mgr = require("audio")
--   audio_mgr.Init()                -- call once in main.lua Start()
--   audio_mgr.Update(dt)            -- call every frame in HandleUpdate()
--   audio_mgr.PlaySFX("sfx_weapon_blade_fire")
--   audio_mgr.PlayMusic("music_combat_low")
--   audio_mgr.Shutdown()            -- call in main.lua Stop()

local M = {}

-- ===========================================================================
-- Constants
-- ===========================================================================

local SFX_POOL_SIZE      = 16     -- max concurrent SFX voices (S5.4)
local MUSIC_SOURCE_COUNT = 2      -- A/B sources for crossfading
local DEFAULT_CROSSFADE  = 1.5    -- seconds (S3.2)
local AMBIENT_FADE       = 0.8    -- seconds

-- Default per-type gains (S5.2)
local DEFAULT_GAINS = {
    [SOUND_MASTER]  = 1.0,
    [SOUND_EFFECT]  = 0.8,
    [SOUND_MUSIC]   = 0.6,
    [SOUND_AMBIENT] = 0.3,
    [SOUND_VOICE]   = 0.0,
}

-- Priority ranking for preemption (higher number = higher priority)
local PRIORITY_RANK = {
    critical = 4,
    high     = 3,
    medium   = 2,
    low      = 1,
}

-- ===========================================================================
-- Event Registry
-- Maps event IDs to resource metadata. Extensions add entries here.
-- Resource paths are relative to the assets/ directory.
-- ===========================================================================

-- Helper: build a weapon event definition
local function weaponEvent(weaponId, action, variations, throttle)
    return {
        dir         = "Sounds/sfx/weapons/",
        prefix      = "sfx_weapon_" .. weaponId .. "_" .. action,
        variations  = variations,
        throttle    = throttle or 0.020,
        priority    = action == "fire" and "high" or "medium",
        soundType   = SOUND_EFFECT,
        looped      = false,
        pitchRange  = 0.03,  -- +/-3%
    }
end

local SFX_EVENTS = {
    -- Weapon fire (6 weapons) -- P0, first integration point
    ["sfx_weapon_blade_fire"]     = weaponEvent("blade",     "fire", 2, 0.020),
    ["sfx_weapon_bow_fire"]       = weaponEvent("bow",       "fire", 2, 0.020),
    ["sfx_weapon_staff_fire"]     = weaponEvent("staff",     "fire", 2, 0.020),
    ["sfx_weapon_mace_fire"]      = weaponEvent("mace",      "fire", 1, 0.020),
    ["sfx_weapon_crossbow_fire"]  = weaponEvent("crossbow",  "fire", 2, 0.020),
    ["sfx_weapon_throwing_fire"]  = weaponEvent("throwing",  "fire", 2, 0.020),

    -- Weapon hit (6 weapons)
    ["sfx_weapon_blade_hit"]     = weaponEvent("blade",     "hit", 3, 0.015),
    ["sfx_weapon_bow_hit"]       = weaponEvent("bow",       "hit", 3, 0.015),
    ["sfx_weapon_staff_hit"]     = weaponEvent("staff",     "hit", 3, 0.015),
    ["sfx_weapon_mace_hit"]      = weaponEvent("mace",      "hit", 3, 0.015),
    ["sfx_weapon_crossbow_hit"]  = weaponEvent("crossbow",  "hit", 3, 0.015),
    ["sfx_weapon_throwing_hit"]  = weaponEvent("throwing",  "hit", 3, 0.015),

    -- Weapon crit
    ["sfx_weapon_crit"] = {
        dir = "Sounds/sfx/weapons/", prefix = "sfx_weapon_crit",
        variations = 1, throttle = 0.030, priority = "high",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },

    -- Player events (S4.2.3)
    ["sfx_player_damage"] = {
        dir = "Sounds/sfx/player/", prefix = "sfx_player_damage",
        variations = 2, throttle = 0.100, priority = "critical",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.02,
    },
    ["sfx_player_heal"] = {
        dir = "Sounds/sfx/player/", prefix = "sfx_player_heal",
        variations = 1, throttle = 0.100, priority = "medium",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },
    ["sfx_player_dodge"] = {
        dir = "Sounds/sfx/player/", prefix = "sfx_player_dodge",
        variations = 1, throttle = 0.050, priority = "medium",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },
    ["sfx_player_pickup_gold"] = {
        dir = "Sounds/sfx/player/", prefix = "sfx_player_pickup_gold",
        variations = 2, throttle = 0.050, priority = "low",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.03,
    },
    ["sfx_player_pickup_xp"] = {
        dir = "Sounds/sfx/player/", prefix = "sfx_player_pickup_xp",
        variations = 1, throttle = 0.050, priority = "low",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },
    ["sfx_player_levelup"] = {
        dir = "Sounds/sfx/player/", prefix = "sfx_player_levelup",
        variations = 1, throttle = 0.500, priority = "critical",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },
    ["sfx_player_death"] = {
        dir = "Sounds/sfx/player/", prefix = "sfx_player_death",
        variations = 1, throttle = 1.000, priority = "critical",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },

    -- Wave events (S4.2.4)
    ["sfx_wave_start"] = {
        dir = "Sounds/sfx/wave/", prefix = "sfx_wave_start",
        variations = 1, throttle = 0.500, priority = "high",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },
    ["sfx_wave_clear"] = {
        dir = "Sounds/sfx/wave/", prefix = "sfx_wave_clear",
        variations = 1, throttle = 0.500, priority = "high",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },

    -- UI navigation (S4.2.8) -- P0 subset
    ["ui_nav_button"] = {
        dir = "Sounds/ui/nav/", prefix = "ui_nav_button",
        variations = 2, throttle = 0.030, priority = "low",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.02,
    },
    ["ui_nav_back"] = {
        dir = "Sounds/ui/nav/", prefix = "ui_nav_back",
        variations = 1, throttle = 0.030, priority = "low",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },
    ["ui_nav_start_run"] = {
        dir = "Sounds/ui/nav/", prefix = "ui_nav_start_run",
        variations = 1, throttle = 0.200, priority = "medium",
        soundType = SOUND_EFFECT, looped = false, pitchRange = 0.0,
    },
}

-- Music tracks (S3.1) -- key = track name, value = resource path
local MUSIC_TRACKS = {
    ["music_menu"]        = "Sounds/music/music_menu.ogg",
    ["music_combat_low"]  = "Sounds/music/music_combat_low.ogg",
    ["music_combat_mid"]  = "Sounds/music/music_combat_mid.ogg",
    ["music_combat_high"] = "Sounds/music/music_combat_high.ogg",
    ["music_boss"]        = "Sounds/music/music_boss.ogg",
    ["music_shop"]        = "Sounds/music/music_shop.ogg",
    ["stinger_victory"]   = "Sounds/music/stinger_victory.ogg",
    ["stinger_defeat"]    = "Sounds/music/stinger_defeat.ogg",
}

-- Ambient tracks (S4.2.9)
local AMBIENT_TRACKS = {
    ["amb_arena_hum_low"]  = "Sounds/ambient/amb_arena_hum_low.ogg",
    ["amb_arena_hum_mid"]  = "Sounds/ambient/amb_arena_hum_mid.ogg",
    ["amb_arena_hum_high"] = "Sounds/ambient/amb_arena_hum_high.ogg",
    ["amb_arena_boss"]     = "Sounds/ambient/amb_arena_boss.ogg",
    ["amb_menu"]           = "Sounds/ambient/amb_menu.ogg",
}

-- ===========================================================================
-- Internal State
-- ===========================================================================

local audioScene_     = nil   -- Scene: minimal audio-only scene
local audioNode_      = nil   -- Node: root node in audio scene (position 0,0,0)
local listener_       = nil   -- SoundListener: the "ears"

-- SFX pool: array of 16 slots, each { source = SoundSource|nil, playOrder = number }
local sfxPool_        = {}
local sfxRoundRobin_  = 1     -- next slot to check for availability
local sfxPlayOrder_   = 0     -- incrementing counter for LRU preemption

-- Music: two persistent SoundSources for A/B crossfading
local musicSources_   = {}    -- { [1] = SoundSource, [2] = SoundSource }
local activeMusicIdx_ = 1     -- which source is currently active (1 or 2)
local currentTrack_   = nil   -- name of currently playing track

-- Ambient: single persistent SoundSource
local ambientSource_  = nil
local currentAmbient_ = nil   -- name of currently playing ambient

-- Resource cache: maps resource path -> Sound resource (or false if failed)
local soundCache_     = {}

-- Throttle: maps event ID -> last play time (in seconds)
local lastPlayTime_   = {}

-- Crossfade state: { fromIdx, toIdx, timer, duration, fromGain, toGain } or nil
local crossfade_      = nil

-- Ambient fade state: { fading = "out"|"in", timer, duration, targetGain } or nil
local ambientFade_    = nil

local isInitialized_  = false
local elapsedTime_    = 0     -- running time for throttle calculations

-- ===========================================================================
-- Helper Functions
-- ===========================================================================

--- Resolve the full resource path for an SFX event with a random variation.
--- @param eventId string  The event ID (e.g. "sfx_weapon_blade_fire")
--- @return string|nil  Full resource path, or nil if event not registered
local function resolveSfxPath(eventId)
    local def = SFX_EVENTS[eventId]
    if not def then return nil end
    local varIdx = def.variations > 1 and math.random(1, def.variations) or 1
    return def.dir .. def.prefix .. "_v" .. varIdx .. ".wav"
end

--- Get a Sound resource from cache, or load it on demand.
--- @param path string  Resource path (e.g. "Sounds/sfx/weapons/sfx_weapon_blade_fire_v1.wav")
--- @return Sound|nil  The Sound resource, or nil if load failed
local function getSound(path)
    if soundCache_[path] ~= nil then
        -- false means we already tried and failed
        return soundCache_[path] or nil
    end
    local sound = cache:GetResource("Sound", path)
    if not sound then
        -- Resource not available yet (assets may not exist in prototype phase)
        soundCache_[path] = false
        return nil
    end
    soundCache_[path] = sound
    return sound
end

--- Calculate stereo panning from optional world coordinates.
--- Player is assumed to be at screen center. Pan is clamped to +/-0.7 (S5.5).
--- @param optWorldX number|nil  Entity X position (screen coords)
--- @param optWorldY number|nil  Entity Y position (unused for 2D panning)
--- @return number  Panning value in [-0.7, 0.7]
local function calculatePan(optWorldX, optWorldY)
    if not optWorldX then return 0.0 end
    -- We need the player's X position. Since the AudioManager doesn't have
    -- direct access to game state, we require the caller to pass relative
    -- coordinates. For now, if optWorldX is provided, we treat it as an
    -- absolute screen X and pan relative to screen center.
    local screenWidth = graphics:GetWidth()
    local centerX = screenWidth * 0.5
    local dx = optWorldX - centerX
    local halfScreen = screenWidth * 0.5
    if halfScreen <= 0 then return 0.0 end
    local pan = dx / halfScreen * 0.7
    return math.max(-0.7, math.min(0.7, pan))
end

--- Find an available SFX pool slot (source not playing and not fading).
--- @return number|nil  Slot index, or nil if all slots are busy
local function findAvailableSlot()
    for i = 1, SFX_POOL_SIZE do
        local idx = ((sfxRoundRobin_ - 1 + i) % SFX_POOL_SIZE) + 1
        local slot = sfxPool_[idx]
        if slot and slot.source then
            if not slot.source:IsPlaying() and not slot.source:IsFadingOut() then
                sfxRoundRobin_ = idx + 1
                return idx
            end
        else
            -- Slot has no source (was never created or was cleaned up) — available
            sfxRoundRobin_ = idx + 1
            return idx
        end
    end
    return nil
end

--- Preempt the oldest lowest-priority SFX slot to make room for a higher-priority sound.
--- @param newPriority string  Priority of the new sound ("critical"/"high"/"medium"/"low")
--- @return number|nil  Slot index of the preempted slot, or nil if none can be preempted
local function preemptSlot(newPriority)
    local newRank = PRIORITY_RANK[newPriority] or 2
    local oldestIdx = nil
    local oldestOrder = math.huge
    local oldestRank = math.huge

    for i = 1, SFX_POOL_SIZE do
        local slot = sfxPool_[i]
        if slot and slot.source and slot.source:IsPlaying() then
            local slotRank = PRIORITY_RANK[slot.priority or "low"] or 1
            -- Only preempt lower or equal priority (never higher)
            if slotRank <= newRank then
                if slotRank < oldestRank or (slotRank == oldestRank and slot.playOrder < oldestOrder) then
                    oldestRank = slotRank
                    oldestOrder = slot.playOrder
                    oldestIdx = i
                end
            end
        end
    end

    if oldestIdx then
        local slot = sfxPool_[oldestIdx]
        slot.source:Stop()
        return oldestIdx
    end
    return nil
end

--- Create or recreate a SoundSource component on the audio node for a pool slot.
--- @param idx number  Slot index
--- @return SoundSource  The new or existing SoundSource
local function ensureSfxSource(idx)
    local slot = sfxPool_[idx]
    if slot and slot.source and not slot.source:IsPlaying() then
        return slot.source
    end
    -- Create a new SoundSource component on the audio node
    local source = audioNode_:CreateComponent("SoundSource")
    source:SetSoundType(SOUND_EFFECT)
    source:SetAutoRemoveMode(REMOVE_DISABLED)  -- See ADR-007: pool uses REMOVE_DISABLED
    source:SetDeclickEnabled(true)
    sfxPool_[idx] = { source = source, playOrder = 0, priority = "low" }
    return source
end

--- Apply per-type gain scaling for an event's priority (S5.1 volume hierarchy).
--- @param priority string  "critical"/"high"/"medium"/"low"
--- @return number  Gain multiplier (1.0, 0.97, 0.94, 0.88 for -0/-3/-6/-12 dB approx)
local function priorityGain(priority)
    if priority == "critical" then return 1.0
    elseif priority == "high"   then return 0.97
    elseif priority == "medium" then return 0.94
    else return 0.88  -- low
    end
end

-- ===========================================================================
-- Public API
-- ===========================================================================

--- Initialize the AudioManager: create Scene, Node, SoundListener, SFX pool, music sources.
--- Sets default per-type gains. Call once in main.lua Start().
--- @return boolean  true if initialization succeeded
function M.Init()
    if isInitialized_ then return true end

    -- 1. Create minimal audio Scene (no Octree, no Camera — audio only)
    audioScene_ = Scene.new()

    -- 2. Create root audio Node at world origin (0,0,0)
    audioNode_ = audioScene_:CreateChild("AudioNode")

    -- 3. Create SoundListener and register it with the Audio subsystem
    listener_ = audioNode_:CreateComponent("SoundListener")
    audio:SetListener(listener_)

    -- 4. Create SFX pool: 16 SoundSource components on the audio node
    for i = 1, SFX_POOL_SIZE do
        local source = audioNode_:CreateComponent("SoundSource")
        source:SetSoundType(SOUND_EFFECT)
        source:SetAutoRemoveMode(REMOVE_DISABLED)
        source:SetDeclickEnabled(true)
        sfxPool_[i] = { source = source, playOrder = 0, priority = "low" }
    end

    -- 5. Create music sources: 2 persistent SoundSources for A/B crossfading
    for i = 1, MUSIC_SOURCE_COUNT do
        local source = audioNode_:CreateComponent("SoundSource")
        source:SetSoundType(SOUND_MUSIC)
        source:SetAutoRemoveMode(REMOVE_DISABLED)
        source:SetDeclickEnabled(true)
        source:SetGain(0.0)  -- start silent; gain set on play
        musicSources_[i] = source
    end

    -- 6. Create ambient source: 1 persistent SoundSource
    ambientSource_ = audioNode_:CreateComponent("SoundSource")
    ambientSource_:SetSoundType(SOUND_AMBIENT)
    ambientSource_:SetAutoRemoveMode(REMOVE_DISABLED)
    ambientSource_:SetDeclickEnabled(true)
    ambientSource_:SetGain(0.0)

    -- 7. Set default per-type gains (S5.2)
    for soundType, gain in pairs(DEFAULT_GAINS) do
        audio:SetMasterGain(soundType, gain)
    end

    isInitialized_ = true
    return true
end

--- Play a one-shot sound effect by event ID.
--- Applies throttle, voice limit, priority preemption, pitch randomization, panning.
--- @param eventId string   Event ID (e.g. "sfx_weapon_blade_fire")
--- @param optWorldX number|nil  Optional world X for panning (screen coords)
--- @param optWorldY number|nil  Optional world Y (reserved, unused for 2D panning)
function M.PlaySFX(eventId, optWorldX, optWorldY)
    if not isInitialized_ then return end

    local def = SFX_EVENTS[eventId]
    if not def then return end  -- unregistered event, silently ignore

    -- Throttle check: skip if same event fired too recently (S5.4)
    local lastTime = lastPlayTime_[eventId] or 0
    if elapsedTime_ - lastTime < def.throttle then return end

    -- Resolve resource path with variation selection
    local path = resolveSfxPath(eventId)
    if not path then return end

    local sound = getSound(path)
    if not sound then return end  -- resource not available, silently skip

    -- Find an available pool slot
    local slotIdx = findAvailableSlot()

    if not slotIdx then
        -- All slots busy — try to preempt (S5.4 priority-based preemption)
        slotIdx = preemptSlot(def.priority)
        if not slotIdx then return end  -- cannot preempt, drop the sound
    end

    -- Ensure the slot has a valid SoundSource
    local source = ensureSfxSource(slotIdx)

    -- Calculate playback parameters
    local baseFreq = sound:GetFrequency()
    if baseFreq <= 0 then baseFreq = 22050 end  -- fallback for safety
    local pitchMult = 1.0 + (math.random() - 0.5) * 2 * (def.pitchRange or 0.0)
    local freq = baseFreq * pitchMult

    local gain = priorityGain(def.priority)

    local pan = calculatePan(optWorldX, optWorldY)

    -- Set sound type (in case the source was reused from a different type)
    source:SetSoundType(def.soundType)

    -- Play with all parameters
    source:Play(sound, freq, gain, pan)

    -- Update slot tracking
    sfxPlayOrder_ = sfxPlayOrder_ + 1
    sfxPool_[slotIdx].playOrder = sfxPlayOrder_
    sfxPool_[slotIdx].priority = def.priority

    -- Update throttle timestamp
    lastPlayTime_[eventId] = elapsedTime_
end

--- Play a music track with optional crossfade.
--- @param trackName string    Track name (e.g. "music_combat_low")
--- @param optFadeTime number|nil  Crossfade duration in seconds (default 1.5)
function M.PlayMusic(trackName, optFadeTime)
    if not isInitialized_ then return end

    local path = MUSIC_TRACKS[trackName]
    if not path then return end  -- unregistered track

    -- If same track is already playing, do nothing
    if currentTrack_ == trackName and not crossfade_ then return end

    local sound = getSound(path)
    if not sound then return end  -- resource not available

    sound:SetLooped(true)

    local fadeTime = optFadeTime or DEFAULT_CROSSFADE

    -- If no music is currently playing, just start the new track
    local activeSource = musicSources_[activeMusicIdx_]
    if not activeSource:IsPlaying() and not crossfade_ then
        activeSource:SetSoundType(SOUND_MUSIC)
        activeSource:SetGain(0.0)
        activeSource:Play(sound)
        -- Fade in
        activeSource:SetGain(DEFAULT_GAINS[SOUND_MUSIC] or 0.6)
        currentTrack_ = trackName
        return
    end

    -- Crossfade: fade out current, fade in new on the other source
    local fromIdx = activeMusicIdx_
    local toIdx = (fromIdx == 1) and 2 or 1
    local fromSource = musicSources_[fromIdx]
    local toSource = musicSources_[toIdx]

    -- Start new track on the other source
    toSource:SetSoundType(SOUND_MUSIC)
    toSource:SetGain(0.0)
    toSource:Play(sound)

    -- Set up crossfade state
    local fromGain = fromSource:GetGain()
    local toGain = DEFAULT_GAINS[SOUND_MUSIC] or 0.6
    crossfade_ = {
        fromIdx = fromIdx,
        toIdx = toIdx,
        timer = 0,
        duration = fadeTime,
        fromGainStart = fromGain,
        toGainTarget = toGain,
    }

    activeMusicIdx_ = toIdx
    currentTrack_ = trackName
end

--- Stop current music with optional fade out.
--- @param optFadeTime number|nil  Fade duration in seconds (default 1.0)
function M.StopMusic(optFadeTime)
    if not isInitialized_ then return end

    local fadeTime = optFadeTime or 1.0
    local activeSource = musicSources_[activeMusicIdx_]

    if not activeSource:IsPlaying() and not crossfade_ then
        currentTrack_ = nil
        return
    end

    -- If a crossfade is in progress, stop the target source too
    if crossfade_ then
        musicSources_[crossfade_.toIdx]:Stop()
        crossfade_ = nil
    end

    -- Fade out the active source
    -- SoundSource:Stop() already applies a fade-out, but we want a specific duration.
    -- We'll handle this in Update() by lerping gain, then calling Stop().
    crossfade_ = {
        fromIdx = activeMusicIdx_,
        toIdx = nil,  -- nil means fade-out only (no new track)
        timer = 0,
        duration = fadeTime,
        fromGainStart = activeSource:GetGain(),
        toGainTarget = 0.0,
    }
    currentTrack_ = nil
end

--- Play an ambient bed track (looped, low gain).
--- @param trackName string  Ambient track name (e.g. "amb_arena_hum_low")
function M.PlayAmbient(trackName)
    if not isInitialized_ then return end

    local path = AMBIENT_TRACKS[trackName]
    if not path then return end

    if currentAmbient_ == trackName and ambientSource_:IsPlaying() then return end

    local sound = getSound(path)
    if not sound then return end

    sound:SetLooped(true)
    ambientSource_:SetSoundType(SOUND_AMBIENT)
    ambientSource_:SetGain(0.0)
    ambientSource_:Play(sound)

    -- Fade in
    ambientFade_ = {
        mode = "in",
        timer = 0,
        duration = AMBIENT_FADE,
        targetGain = DEFAULT_GAINS[SOUND_AMBIENT] or 0.3,
    }
    currentAmbient_ = trackName
end

--- Stop ambient with optional fade out.
--- @param optFadeTime number|nil  Fade duration in seconds (default 0.8)
function M.StopAmbient(optFadeTime)
    if not isInitialized_ then return end
    if not ambientSource_:IsPlaying() then
        currentAmbient_ = nil
        return
    end

    ambientFade_ = {
        mode = "out",
        timer = 0,
        duration = optFadeTime or AMBIENT_FADE,
        targetGain = 0.0,
    }
end

--- Set volume for a sound type (for settings screen).
--- @param soundType string  Sound type constant (SOUND_EFFECT, SOUND_MUSIC, etc.)
--- @param gain number       Volume 0.0 to 1.0
function M.SetVolume(soundType, gain)
    if not isInitialized_ then return end
    audio:SetMasterGain(soundType, gain)
    -- Update our DEFAULT_GAINS so future crossfades use the new value
    DEFAULT_GAINS[soundType] = gain
end

--- Pause all sounds of a specific type.
--- @param soundType string  Sound type constant
function M.PauseType(soundType)
    if not isInitialized_ then return end
    audio:PauseSoundType(soundType)
end

--- Resume all paused sounds.
function M.ResumeAll()
    if not isInitialized_ then return end
    audio:ResumeAll()
end

--- Stop all audio immediately (cleanup).
function M.StopAll()
    if not isInitialized_ then return end

    -- Stop all SFX
    for i = 1, SFX_POOL_SIZE do
        local slot = sfxPool_[i]
        if slot and slot.source then
            slot.source:Stop()
        end
    end

    -- Stop music
    for i = 1, MUSIC_SOURCE_COUNT do
        if musicSources_[i] then
            musicSources_[i]:Stop()
        end
    end

    -- Stop ambient
    if ambientSource_ then
        ambientSource_:Stop()
    end

    crossfade_ = nil
    ambientFade_ = nil
    currentTrack_ = nil
    currentAmbient_ = nil
end

--- Per-frame update. Handles crossfade progress, ambient fade, voice counting.
--- @param dt number  Delta time in seconds
function M.Update(dt)
    if not isInitialized_ then return end

    elapsedTime_ = elapsedTime_ + dt

    -- Handle music crossfade
    if crossfade_ then
        crossfade_.timer = crossfade_.timer + dt
        local t = math.min(1.0, crossfade_.timer / crossfade_.duration)
        local easedT = t * t * (3 - 2 * t)  -- smoothstep

        -- Fade out the "from" source
        local fromSource = musicSources_[crossfade_.fromIdx]
        if fromSource then
            local gain = crossfade_.fromGainStart * (1.0 - easedT)
            fromSource:SetGain(gain)
        end

        -- Fade in the "to" source (if any)
        if crossfade_.toIdx then
            local toSource = musicSources_[crossfade_.toIdx]
            if toSource then
                local gain = crossfade_.toGainTarget * easedT
                toSource:SetGain(gain)
            end
        end

        -- Crossfade complete
        if t >= 1.0 then
            if fromSource then
                fromSource:Stop()
                fromSource:SetGain(0.0)
            end
            crossfade_ = nil
        end
    end

    -- Handle ambient fade
    if ambientFade_ then
        ambientFade_.timer = ambientFade_.timer + dt
        local t = math.min(1.0, ambientFade_.timer / ambientFade_.duration)
        local easedT = t * t * (3 - 2 * t)  -- smoothstep

        if ambientFade_.mode == "in" then
            ambientSource_:SetGain(ambientFade_.targetGain * easedT)
        else  -- "out"
            local currentGain = DEFAULT_GAINS[SOUND_AMBIENT] or 0.3
            ambientSource_:SetGain(currentGain * (1.0 - easedT))
        end

        if t >= 1.0 then
            if ambientFade_.mode == "out" then
                ambientSource_:Stop()
                ambientSource_:SetGain(0.0)
                currentAmbient_ = nil
            end
            ambientFade_ = nil
        end
    end
end

--- Shut down the AudioManager: stop all audio, destroy the Scene.
function M.Shutdown()
    if not isInitialized_ then return end

    M.StopAll()

    -- Clear references
    sfxPool_ = {}
    musicSources_ = {}
    ambientSource_ = nil
    listener_ = nil
    audioNode_ = nil

    -- Destroy the audio Scene
    if audioScene_ then
        audioScene_:Clear()
        audioScene_ = nil
    end

    soundCache_ = {}
    lastPlayTime_ = {}
    crossfade_ = nil
    ambientFade_ = nil
    currentTrack_ = nil
    currentAmbient_ = nil
    isInitialized_ = false
end

--- Check if AudioManager is initialized.
--- @return boolean
function M.IsInitialized()
    return isInitialized_
end

--- Get the name of the currently playing music track.
--- @return string|nil
function M.GetCurrentTrack()
    return currentTrack_
end

return M
