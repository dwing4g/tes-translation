-- Show Me Everything 2.0 - Actor UI core
-- OpenMW 0.51 / Lua API v129 baseline.
-- Architecture: one target provider, one root UI element, event-driven damage,
-- and polling only for the actor that is actually being displayed.

local async = require('openmw.async')
local camera = require('openmw.camera')
local core = require('openmw.core')
local I = require('openmw.interfaces')
local nearby = require('openmw.nearby')
local self = require('openmw.self')
local storage = require('openmw.storage')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')
local styles = require('scripts.sme_styles')

local behavior = storage.playerSection('SMESettingsBh')
local styleSettings = storage.playerSection('SMESettingsSt')
local hitChanceSettings = storage.playerSection('SMEHitChanceSettings')

local isNPC = types.NPC.objectIsInstance
local isCreature = types.Creature.objectIsInstance
local isActor = function(obj)
    return obj and (isNPC(obj) or isCreature(obj))
end

local FOCUS_SHOW_TIME = 1.0
local COMBAT_SHOW_TIME = 3.0
local FADE_TIME = 1.0
local HEALTH_POLL_INTERVAL = 0.10
local TARGET_INTERVAL = 1 / 60
local STATE_TTL = 60
local CLEANUP_INTERVAL = 5
local HEALTH_ANIM_BASE = 0.8
local MELEE_RANGE = 192
local MARKSMAN_RANGE = 4000

local stylePresets = {
    ['Vanilla'] = {
        rootSize = util.vector2(450, 70), barSize = util.vector2(260, 16), healthBarPos = util.vector2(0, 0.29),
        damagePos = util.vector2(0.735, 0.83), healthPos = util.vector2(0.50, 0.429), nameSize = 17.5, namePos = util.vector2(0.5, 0.047),
    },
    ['Skyrim'] = {
        rootSize = util.vector2(450, 60), barSize = util.vector2(252, 12), healthBarPos = util.vector2(0, 0.29),
        damagePos = util.vector2(0.735, 0.87), healthPos = util.vector2(0.50, 0.432), nameSize = 18, namePos = util.vector2(0.5, 0.03),
    },
    ['Sky Nostalgy'] = {
        rootSize = util.vector2(450, 60), barSize = util.vector2(307, 10), healthBarPos = util.vector2(0, 0.29),
        damagePos = util.vector2(0.76, 0.87), healthPos = util.vector2(0.50, 0.43), nameSize = 17, namePos = util.vector2(0.5, 0.052),
    },
    ['Flat'] = {
        rootSize = util.vector2(450, 65), barSize = util.vector2(300, 16), healthBarPos = util.vector2(0, 0.15),
        damagePos = util.vector2(0.9, 0.548), healthPos = util.vector2(0.50, 0.735), nameSize = 18, namePos = util.vector2(0.5, 0),
    },
    ['Minimal Vanilla'] = {
        rootSize = util.vector2(400, 40), barSize = util.vector2(180, 30), healthBarPos = util.vector2(0, 0.14),
        damagePos = util.vector2(0.94, 0.83), healthPos = util.vector2(0.50, 0.65), nameSize = 16, namePos = util.vector2(0.5, 0.067),
    },
    ['Sixth House'] = {
        rootSize = util.vector2(400, 70), barSize = util.vector2(275, 18), healthBarPos = util.vector2(0, 0),
        damagePos = util.vector2(0.78, 0.85), healthPos = util.vector2(0.50, 0.45), nameSize = 16, namePos = util.vector2(0.5, 0.077),
    },
}

local root = ui.create {
    name = 'TutorialNotifyMenu',
    l10n = 'UITutorial',
    layer = 'HUD',
    type = ui.TYPE.Widget,
    props = {
        anchor = util.vector2(0.5, 0),
        relativePosition = util.vector2(0.5, 0.035),
        visible = false,
        alpha = 1,
        size = util.vector2(450, 70),
    },
    content = ui.content {
        {
            name = 'healthBarContent',
            type = ui.TYPE.Widget,
            props = { relativeSize = util.vector2(1, 1), relativePosition = util.vector2(0, 0.29) },
            content = styles.get('Vanilla'),
        },
        {
            name = 'damageText',
            type = ui.TYPE.Text,
            props = {
                relativePosition = util.vector2(0.735, 0.83), anchor = util.vector2(0.5, 0.5), text = '', textSize = 14,
                textShadow = true, textShadowColor = util.color.rgb(0, 0, 0), textColor = util.color.rgb(200 / 255, 200 / 255, 200 / 255), visible = false,
            },
        },
        {
            name = 'nameText',
            type = ui.TYPE.Text,
            props = {
                relativePosition = util.vector2(0.5, 0.047), anchor = util.vector2(0.5, 0), text = '', textSize = 17.5,
                textShadow = true, textShadowColor = util.color.rgb(0, 0, 0), textColor = util.color.rgb(200 / 255, 200 / 255, 200 / 255), visible = true,
            },
        },
        {
            name = 'healthText',
            type = ui.TYPE.Text,
            props = {
                relativePosition = util.vector2(0.50, 0.429), anchor = util.vector2(0.5, 0), text = '', textSize = 14,
                textShadow = true, textShadowColor = util.color.rgb(0, 0, 0), textColor = util.color.rgb(1, 1, 1, 1), visible = true,
            },
        },
    },
}

local healthBarLayout = root.layout.content['healthBarContent']
local damageLayout = root.layout.content['damageText']
local nameLayout = root.layout.content['nameText']
local healthTextLayout = root.layout.content['healthText']

local barSize = util.vector2(260, 16)
local standardWidgetPos = util.vector2(0.5, 0.035)
local currentStyle = 'Vanilla'
local rootDirty = true
local settingsDirty = true
local metadataGeneration = 0

local states = {}
local currentState = nil
local activeDamageStates = {}
local showTimer = 0
local focusLockTimer = 0
local fading = false
local fadeTimer = 0
local healthPollTimer = 0
local cleanupTimer = 0
local swimming = false
local swimRestoreTimer = 0
local hudSuppressed = false

-- Shared target provider -----------------------------------------------------
local targetSnapshot = { object = nil, distance = nil, hitPos = nil, sequence = 0 }
local targetAccumulator = TARGET_INTERVAL
local targetPending = false
local targetGeneration = 0
local lastDemandRange = 0
local lastProcessedTargetSequence = -1

local weaponSkillMap = {
    [types.Weapon.TYPE.AxeOneHand] = 'axe',
    [types.Weapon.TYPE.AxeTwoHand] = 'axe',
    [types.Weapon.TYPE.BluntOneHand] = 'bluntweapon',
    [types.Weapon.TYPE.BluntTwoClose] = 'bluntweapon',
    [types.Weapon.TYPE.BluntTwoWide] = 'bluntweapon',
    [types.Weapon.TYPE.LongBladeOneHand] = 'longblade',
    [types.Weapon.TYPE.LongBladeTwoHand] = 'longblade',
    [types.Weapon.TYPE.MarksmanBow] = 'marksman',
    [types.Weapon.TYPE.MarksmanCrossbow] = 'marksman',
    [types.Weapon.TYPE.MarksmanThrown] = 'marksman',
    [types.Weapon.TYPE.ShortBladeOneHand] = 'shortblade',
    [types.Weapon.TYPE.SpearTwoWide] = 'spear',
}

local function markDirty()
    rootDirty = true
end

local function commit()
    if rootDirty then
        root:update()
        rootDirty = false
    end
end

local function validObject(obj)
    return obj ~= nil and obj:isValid()
end

local function clearTarget()
    if targetSnapshot.object ~= nil or targetSnapshot.distance ~= nil then
        targetSnapshot = { object = nil, distance = nil, hitPos = nil, sequence = targetSnapshot.sequence + 1 }
    end
end

local function hitChanceDemandRange()
    if not hitChanceSettings:get('hitChanceIsActive') then return 0 end
    if camera.getMode() ~= camera.MODE.FirstPerson then return 0 end
    if types.Actor.getStance(self) ~= types.Actor.STANCE.Weapon then return 0 end

    local carried = types.Actor.getEquipment(self, types.Actor.EQUIPMENT_SLOT.CarriedRight)
    if carried == nil then return MELEE_RANGE end
    if not types.Weapon.objectIsInstance(carried) then return 0 end

    local record = types.Weapon.record(carried)
    return weaponSkillMap[record.type] == 'marksman' and MARKSMAN_RANGE or MELEE_RANGE
end

local function actorUiDemandRange()
    if not behavior:get('SMEisActive') then return 0 end
    if behavior:get('SMEonHit') then return 0 end
    if behavior:get('SMEStance') and types.Actor.getStance(self) == types.Actor.STANCE.Nothing then return 0 end
    return behavior:get('SMEShowDistance') or 500
end

local function targetDemandRange()
    return math.max(actorUiDemandRange(), hitChanceDemandRange())
end

local function applyRayResult(result, from, requestGeneration)
    targetPending = false
    if requestGeneration ~= targetGeneration then return end

    local distance = nil
    if result and result.hitPos then
        distance = (result.hitPos - from):length()
    end
    targetSnapshot = {
        object = result and result.hitObject or nil,
        distance = distance,
        hitPos = result and result.hitPos or nil,
        sequence = targetSnapshot.sequence + 1,
    }
end

local function updateTargetProvider(dt)
    local range = targetDemandRange()
    if range <= 0 or core.isWorldPaused() or not I.UI.isHudVisible() then
        if lastDemandRange > 0 then
            targetGeneration = targetGeneration + 1
            clearTarget()
        end
        lastDemandRange = 0
        return
    end

    if range ~= lastDemandRange then
        targetGeneration = targetGeneration + 1
        lastDemandRange = range
        targetAccumulator = TARGET_INTERVAL
    end

    targetAccumulator = targetAccumulator + dt
    if targetAccumulator < TARGET_INTERVAL then return end
    targetAccumulator = targetAccumulator % TARGET_INTERVAL

    -- OpenMW 0.52+ can reuse the engine's internal focus query for vanilla
    -- reach. 0.51 simply falls through to the async raycast path.
    if camera.getFocusRay and range <= MELEE_RANGE then
        local result = camera.getFocusRay()
        if result then
            local from = camera.getPosition()
            local distance = result.hitPos and (result.hitPos - from):length() or nil
            targetSnapshot = { object = result.hitObject, distance = distance, hitPos = result.hitPos, sequence = targetSnapshot.sequence + 1 }
        else
            clearTarget()
        end
        return
    end

    if targetPending then return end
    targetPending = true
    local from = camera.getPosition()
    local to = from + camera.viewportToWorldVector(util.vector2(0.5, 0.5)) * range
    local requestGeneration = targetGeneration
    nearby.asyncCastRenderingRay(async:callback(function(result)
        applyRayResult(result, from, requestGeneration)
    end), from, to)
end

-- Actor model ---------------------------------------------------------------
local function actorRecord(actor)
    if isNPC(actor) then return types.NPC.record(actor) end
    if isCreature(actor) then return types.Creature.record(actor) end
end

local function titleCaseClass(class)
    if not class or class == '' then return '' end
    if string.match(class, '^t_glb_') then
        class = string.gsub(class, '^t_glb_', '')
    end
    return string.gsub(' ' .. class, '%W%l', string.upper):sub(2)
end

local function buildActorName(actor)
    local record = actorRecord(actor)
    if not record then return '' end

    local name = record.name or ''
    if behavior:get('SMELevel') then
        name = name .. ', Lv. ' .. tostring(types.Actor.stats.level(actor).current)
    end
    if behavior:get('SMEClass') and isNPC(actor) then
        local classRecord = types.NPC.classes.record(record.class)
        if classRecord and classRecord.name and classRecord.name ~= '' then
            name = name .. ' ' .. titleCaseClass(classRecord.name)
        end
    end
    return name
end

local function getHealth(actor)
    local stat = types.Actor.stats.dynamic.health(actor)
    return stat.current, stat.base
end

local function ensureState(actor, initialHealth)
    if not validObject(actor) then return nil end
    local id = actor.id
    local state = states[id]
    if not state then
        local current, base = getHealth(actor)
        state = {
            actor = actor,
            id = id,
            lastHealth = initialHealth or current,
            baseHealth = base,
            name = nil,
            nameGeneration = -1,
            ttl = STATE_TTL,
            damage = 0,
            damageTimer = 0,
            damageStartHealth = nil,
            animating = false,
            animElapsed = 0,
            animDuration = 0,
            animFromWidth = nil,
            animToWidth = nil,
            animWidth = nil,
        }
        states[id] = state
    else
        state.actor = actor
        state.ttl = STATE_TTL
    end
    return state
end

local function healthRatio(current, base)
    if not base or base <= 0 then return 0 end
    return math.max(0, current / base)
end

local function healthWidth(current, base)
    return barSize:emul(util.vector2(healthRatio(current, base), 1))
end

local function healthText(current, base)
    current = math.floor(current or 0)
    base = math.floor(base or 0)
    if current <= 0 then return 'Dead' end
    local a, b = tostring(current), tostring(base)
    if #b > #a then a = string.rep(' ', #b - #a) .. a end
    return a .. ' / ' .. b
end

local function refreshMetadata(state)
    if state.nameGeneration ~= metadataGeneration then
        state.name = buildActorName(state.actor)
        state.nameGeneration = metadataGeneration
    end
end

local function renderCurrentState()
    local state = currentState
    if not state or not validObject(state.actor) then return end
    refreshMetadata(state)

    local current, base = state.lastHealth, state.baseHealth
    nameLayout.props.text = state.name
    healthTextLayout.props.text = behavior:get('SMEHealth') and healthText(current, base) or ''

    local content = healthBarLayout.content
    content['hbBar'].props.size = healthWidth(current, base)
    if state.animating and state.animWidth then
        content['hbBarAnim'].props.size = state.animWidth
    elseif state.damageTimer > 0 and state.animWidth then
        content['hbBarAnim'].props.size = state.animWidth
    else
        content['hbBarAnim'].props.size = healthWidth(current, base)
    end

    if currentStyle == 'Flat' and content['healthBG'] then
        content['healthBG'].props.visible = behavior:get('SMEHealth')
    end

    if behavior:get('SMEDamage') and state.damageTimer > 0 and state.damage > 0 then
        damageLayout.props.text = tostring(util.round(state.damage))
        damageLayout.props.visible = true
    else
        damageLayout.props.text = ''
        damageLayout.props.visible = false
    end
    markDirty()
end

local function selectState(state)
    if currentState ~= state then
        currentState = state
        renderCurrentState()
    end
end

local function renewWidget(seconds)
    showTimer = math.max(showTimer, seconds)
    fading = false
    fadeTimer = 0
    if not root.layout.props.visible then
        root.layout.props.visible = true
        markDirty()
    end
    if root.layout.props.alpha ~= 1 then
        root.layout.props.alpha = 1
        markDirty()
    end
end

local function hideImmediately()
    showTimer = 0
    fading = false
    fadeTimer = 0
    if root.layout.props.visible then
        root.layout.props.visible = false
        root.layout.props.alpha = 1
        markDirty()
    end
end

local function applyStyle()
    currentStyle = styleSettings:get('SMEWidgetStyle') or 'Vanilla'
    local preset = stylePresets[currentStyle] or stylePresets['Vanilla']
    barSize = preset.barSize
    root.layout.props.size = preset.rootSize
    healthBarLayout.props.relativePosition = preset.healthBarPos
    healthBarLayout.content = styles.get(currentStyle)
    damageLayout.props.relativePosition = preset.damagePos
    healthTextLayout.props.relativePosition = preset.healthPos
    nameLayout.props.textSize = preset.nameSize
    nameLayout.props.relativePosition = preset.namePos
    standardWidgetPos = util.vector2(0.5, 0.035)
    root.layout.props.relativePosition = swimming and util.vector2(standardWidgetPos.x, standardWidgetPos.y + 0.07) or standardWidgetPos
    if currentState and validObject(currentState.actor) then renderCurrentState() end
    markDirty()
end

local function onSettingsChanged()
    settingsDirty = true
    metadataGeneration = metadataGeneration + 1
end

behavior:subscribe(async:callback(onSettingsChanged))
styleSettings:subscribe(async:callback(onSettingsChanged))
hitChanceSettings:subscribe(async:callback(function() targetAccumulator = TARGET_INTERVAL end))

local function registerDamage(state, before, after)
    local damage = before - after
    if damage <= 0 then return end

    if state.damageTimer <= 0 then
        state.damage = 0
        state.damageStartHealth = before
        local trailingWidth = state.animating and state.animWidth or healthWidth(before, state.baseHealth)
        state.animating = false
        state.animWidth = trailingWidth
    end
    state.damage = state.damage + damage
    state.damageTimer = 1.0
    state.lastHealth = after
    state.ttl = STATE_TTL
    activeDamageStates[state.id] = state
end

local function onPlayerHitActor(data)
    if not data or not validObject(data.target) or not isActor(data.target) then return end
    local state = ensureState(data.target, data.healthBefore)
    if not state then return end

    local current, base = getHealth(data.target)
    state.baseHealth = base
    local before = data.healthBefore or state.lastHealth or current
    -- Multiple hit events can be delivered together. The first event observes
    -- the complete health delta; later events see the already-synchronised value.
    if state.lastHealth ~= current then
        registerDamage(state, before, current)
    end

    if behavior:get('SMEisActive') then
        if behavior:get('SMEonHit') or not currentState or currentState == state or focusLockTimer <= 0 then
            selectState(state)
        end
        if currentState == state then
            renderCurrentState()
            renewWidget(COMBAT_SHOW_TIME)
        end
    end
end

-- Runtime -------------------------------------------------------------------
local function processFocusedTarget()
    if targetSnapshot.sequence == lastProcessedTargetSequence then return end
    lastProcessedTargetSequence = targetSnapshot.sequence
    if not behavior:get('SMEisActive') or behavior:get('SMEonHit') then return end
    if behavior:get('SMEStance') and types.Actor.getStance(self) == types.Actor.STANCE.Nothing then return end

    local target = targetSnapshot.object
    local distance = targetSnapshot.distance
    if not validObject(target) or not isActor(target) or types.Player.objectIsInstance(target) then return end
    if not distance or distance >= (behavior:get('SMEShowDistance') or 500) then return end
    if not behavior:get('SMEnotForDead') and types.Actor.isDead(target) then return end

    local state = ensureState(target)
    if not state then return end
    if currentState ~= state then
        local current, base = getHealth(target)
        state.lastHealth = current
        state.baseHealth = base
    end
    selectState(state)
    focusLockTimer = FOCUS_SHOW_TIME
    renewWidget(FOCUS_SHOW_TIME)
end

local function pollDisplayedHealth(elapsed)
    local state = currentState
    if not state or not validObject(state.actor) then
        healthPollTimer = 0
        return
    end
    if not root.layout.props.visible and state.damageTimer <= 0 and not state.animating then
        healthPollTimer = 0
        return
    end

    healthPollTimer = healthPollTimer + elapsed
    if healthPollTimer < HEALTH_POLL_INTERVAL then return end
    healthPollTimer = healthPollTimer % HEALTH_POLL_INTERVAL

    local current, base = getHealth(state.actor)
    local changed = current ~= state.lastHealth or base ~= state.baseHealth

    if current < state.lastHealth then
        registerDamage(state, state.lastHealth, current)
        renewWidget(COMBAT_SHOW_TIME)
    else
        state.lastHealth = current
    end
    state.baseHealth = base
    state.ttl = STATE_TTL

    if changed then renderCurrentState() end
end

local function updateDamageTimers(dt)
    for id, state in pairs(activeDamageStates) do
        if not validObject(state.actor) then
            activeDamageStates[id] = nil
        else
            state.damageTimer = state.damageTimer - dt
            if state.damageTimer <= 0 then
                state.damageTimer = 0
                state.damage = 0
                state.animating = true
                state.animElapsed = 0
                local current, base = getHealth(state.actor)
                state.lastHealth = current
                state.baseHealth = base
                state.animFromWidth = state.animWidth or healthWidth(state.damageStartHealth or current, base)
                state.animToWidth = healthWidth(current, base)
                local lost = math.max(0, (state.damageStartHealth or current) - current)
                local lostPercent = base > 0 and lost / base or 0
                state.animDuration = math.max(HEALTH_ANIM_BASE * lostPercent, 0.2)
                activeDamageStates[id] = nil
                if currentState == state then renderCurrentState() end
            end
        end
    end
end

local function updateCurrentAnimation(dt)
    local state = currentState
    if not state or not state.animating then return end
    state.animElapsed = state.animElapsed + dt
    local duration = math.max(state.animDuration, 0.001)
    local t = math.min(1, state.animElapsed / duration)
    local from = state.animFromWidth or healthWidth(state.lastHealth, state.baseHealth)
    local to = state.animToWidth or healthWidth(state.lastHealth, state.baseHealth)
    state.animWidth = util.vector2(from.x + (to.x - from.x) * t, barSize.y)
    renderCurrentState()
    if t >= 1 then
        state.animating = false
        state.animElapsed = 0
        state.damageStartHealth = nil
        state.animFromWidth = nil
        state.animToWidth = nil
        state.animWidth = nil
        renderCurrentState()
    end
end

local function updateVisibility(dt)
    if showTimer > 0 then
        showTimer = math.max(0, showTimer - dt)
    elseif root.layout.props.visible and not fading then
        fading = true
        fadeTimer = 0
    end

    if fading then
        fadeTimer = fadeTimer + dt
        root.layout.props.alpha = math.max(0, 1 - fadeTimer / FADE_TIME)
        markDirty()
        if fadeTimer >= FADE_TIME then
            fading = false
            fadeTimer = 0
            root.layout.props.visible = false
            root.layout.props.alpha = 1
            markDirty()
        end
    end
end

local function updateSwimming(dt)
    if not root.layout.props.visible then return end
    local nowSwimming = types.Actor.isSwimming(self)
    if nowSwimming and not swimming then
        swimming = true
        swimRestoreTimer = 0
        root.layout.props.relativePosition = util.vector2(standardWidgetPos.x, standardWidgetPos.y + 0.07)
        markDirty()
    elseif not nowSwimming and swimming then
        swimRestoreTimer = swimRestoreTimer + dt
        if swimRestoreTimer >= 3 then
            swimming = false
            swimRestoreTimer = 0
            root.layout.props.relativePosition = standardWidgetPos
            markDirty()
        end
    elseif nowSwimming then
        swimRestoreTimer = 0
    end
end

local function cleanupStates(dt)
    cleanupTimer = cleanupTimer + dt
    if cleanupTimer < CLEANUP_INTERVAL then return end
    local elapsed = cleanupTimer
    cleanupTimer = 0
    for id, state in pairs(states) do
        if not validObject(state.actor) then
            states[id] = nil
            activeDamageStates[id] = nil
            if currentState == state then currentState = nil end
        else
            state.ttl = state.ttl - elapsed
            if state.ttl <= 0 and state ~= currentState and state.damageTimer <= 0 then
                states[id] = nil
                activeDamageStates[id] = nil
            end
        end
    end
end

local function syncHudSuppression()
    local suppress = not I.UI.isHudVisible()
    if suppress ~= hudSuppressed then
        hudSuppressed = suppress
        if suppress then
            if root.layout.props.visible then root.layout.props.visible = false; markDirty() end
        elseif showTimer > 0 or fading then
            root.layout.props.visible = true
            markDirty()
        end
    end
end

local function onUpdate(dt)
    syncHudSuppression()

    if settingsDirty then
        settingsDirty = false
        applyStyle()
        if not behavior:get('SMEisActive') then hideImmediately() end
    end

    -- onUpdate is also called while paused in OpenMW 0.51 (dt == 0).
    if dt <= 0 or core.isWorldPaused() then
        commit()
        return
    end

    if hudSuppressed then
        updateTargetProvider(dt) -- clears/invalidates an outstanding demand snapshot
        cleanupStates(dt)
        commit()
        return
    end

    updateTargetProvider(dt)
    processFocusedTarget()

    if focusLockTimer > 0 then focusLockTimer = math.max(0, focusLockTimer - dt) end

    if behavior:get('SMEisActive') then
        pollDisplayedHealth(dt)
        updateDamageTimers(dt)
        updateCurrentAnimation(dt)
        updateVisibility(dt)
        updateSwimming(dt)
    else
        hideImmediately()
    end

    cleanupStates(dt)
    commit()
end

applyStyle()
commit()

return {
    engineHandlers = { onUpdate = onUpdate },
    eventHandlers = { SME_PlayerHitActor = onPlayerHitActor },
    interfaceName = 'SME_CORE',
    interface = {
        version = 2,
        getTargetInfo = function()
            return targetSnapshot
        end,
    },
}
