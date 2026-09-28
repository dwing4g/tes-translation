-- Show Me Everything 2.0 - Hit Chance
-- Uses the shared SME target snapshot; this script performs no raycasts.

local async = require('openmw.async')
local camera = require('openmw.camera')
local core = require('openmw.core')
local I = require('openmw.interfaces')
local self = require('openmw.self')
local storage = require('openmw.storage')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')

local settings = storage.playerSection('SMEHitChanceSettings')

local LOGIC_INTERVAL = 0.10
local FOCUS_TIME = 0.30
local FADE_TIME = 1.0
local MELEE_RANGE = 192
local SCALE_SIZE = util.vector2(6, 40)

local fFatigueBase = core.getGMST('fFatigueBase')
local fFatigueMult = core.getGMST('fFatigueMult')
local fCombatInvisoMult = core.getGMST('fCombatInvisoMult')

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

local function percentContent()
    return ui.content {
        {
            name = 'hitChanceContainer',
            type = ui.TYPE.Widget,
            props = { relativePosition = util.vector2(0.8, 0.63), anchor = util.vector2(0.5, 0.5), size = util.vector2(50, 20) },
            content = ui.content {
                {
                    name = 'hitChanceBG', type = ui.TYPE.Image,
                    props = { alpha = 0.8, resource = ui.texture({ path = 'White' }), color = util.color.rgb(1 / 255, 1 / 255, 1 / 255), relativeSize = util.vector2(1, 1) },
                },
                {
                    name = 'hitChanceText', type = ui.TYPE.Text,
                    props = { text = '%', textColor = util.color.rgba(1, 1, 1, 1), textSize = 14, relativePosition = util.vector2(0.5, 0.5), anchor = util.vector2(0.5, 0.5) },
                },
            },
        },
    }
end

local function circleContent()
    return ui.content {
        {
            name = 'hitChanceWidget', type = ui.TYPE.Image,
            props = { resource = ui.texture({ path = 'Textures/hitIndicator.png' }), size = util.vector2(8, 8), relativePosition = util.vector2(0.6, 0.6), anchor = util.vector2(0.5, 0.5) },
        },
    }
end

local function scaleContent()
    return ui.content {
        {
            name = 'hitChanceWidgetBG', type = ui.TYPE.Image,
            props = { alpha = 0.8, resource = ui.texture({ path = 'White' }), color = util.color.rgb(1 / 255, 1 / 255, 1 / 255), size = util.vector2(10, 45), relativePosition = util.vector2(0.65, 0.5), anchor = util.vector2(0.5, 0.5) },
        },
        {
            name = 'hitChanceWidgetScale', type = ui.TYPE.Image,
            props = { alpha = 0.8, resource = ui.texture({ path = 'White' }), color = util.color.rgb(244 / 255, 198 / 255, 0), size = SCALE_SIZE, relativePosition = util.vector2(0.65, 0.5), anchor = util.vector2(0.5, 0.5) },
        },
    }
end

local root = ui.create {
    name = 'TutorialNotifyMenu',
    l10n = 'UITutorial',
    layer = 'HUD',
    type = ui.TYPE.Widget,
    props = {
        anchor = util.vector2(0.5, 0.5), relativePosition = util.vector2(0.5, 0.5),
        visible = false, alpha = 1, size = util.vector2(150, 150),
    },
    content = ui.content {
        {
            name = 'reticle', type = ui.TYPE.Image,
            props = {
                resource = ui.texture({ path = 'Textures/targetHitChance.png' }), size = util.vector2(26, 26),
                relativePosition = util.vector2(0.5, 0.5), anchor = util.vector2(0.5, 0.5), visible = false,
            },
        },
        {
            name = 'indicator', type = ui.TYPE.Widget,
            props = { relativeSize = util.vector2(1, 1) },
            content = percentContent(),
        },
    },
}

local reticle = root.layout.content['reticle']
local indicator = root.layout.content['indicator']
local currentStyle = 'Percent'
local dirty = true
local settingsDirty = true
local logicTimer = LOGIC_INTERVAL
local focusTimer = 0
local fadeTimer = 0
local fading = false
local lastChance = nil
local lastColourKey = nil

local function markDirty() dirty = true end
local function commit()
    if dirty then root:update(); dirty = false end
end

local function applyStyle()
    currentStyle = settings:get('SMEhitChanceWidget') or 'Percent'
    if currentStyle == 'Circle' then
        indicator.content = circleContent()
    elseif currentStyle == 'Scale' then
        indicator.content = scaleContent()
    else
        currentStyle = 'Percent'
        indicator.content = percentContent()
    end
    lastChance = nil
    lastColourKey = nil
    markDirty()
end

local function hideImmediately()
    focusTimer = 0
    fadeTimer = 0
    fading = false
    if root.layout.props.visible then
        root.layout.props.visible = false
        root.layout.props.alpha = 1
        markDirty()
    end
end

settings:subscribe(async:callback(function()
    settingsDirty = true
end))

local function effectMagnitude(actor, effect)
    return types.Actor.activeEffects(actor):getEffect(effect).magnitude
end

local function fatigueTerm(actor)
    local fatigue = types.Actor.stats.dynamic.fatigue(actor)
    local maximum = fatigue.base + fatigue.modifier
    local normalized
    if maximum <= 0 then
        normalized = 1
    else
        normalized = math.max(0, fatigue.current / maximum)
    end
    return fFatigueBase - fFatigueMult * (1 - normalized)
end

local function playerAttackTerm(weapon)
    local skillName = 'handtohand'
    if weapon then
        local record = types.Weapon.record(weapon)
        skillName = weaponSkillMap[record.type]
        if not skillName then return nil end
    end

    local skill = types.NPC.stats.skills[skillName](self).modified
    local agility = types.Actor.stats.attributes.agility(self).modified
    local luck = types.Actor.stats.attributes.luck(self).modified
    local attack = (skill + agility / 5 + luck / 10) * fatigueTerm(self)
    attack = attack + effectMagnitude(self, core.magic.EFFECT_TYPE.FortifyAttack)
    attack = attack - effectMagnitude(self, core.magic.EFFECT_TYPE.Blind)
    return attack
end

local function targetDefenseTerm(target)
    local fatigue = types.Actor.stats.dynamic.fatigue(target)
    if fatigue.current < 0 then return 0 end

    local defense = 0
    -- OpenMW also suppresses evasion for an unaware target. Awareness is not
    -- exposed by API v129, but canMove exactly covers dead/paralyzed/knocked-down.
    if types.Actor.canMove(target) then
        local agility = types.Actor.stats.attributes.agility(target).modified
        local luck = types.Actor.stats.attributes.luck(target).modified
        defense = (agility / 5 + luck / 10) * fatigueTerm(target)
        defense = defense + math.min(100, effectMagnitude(target, core.magic.EFFECT_TYPE.Sanctuary))
    end

    defense = defense + math.min(100, fCombatInvisoMult * effectMagnitude(target, core.magic.EFFECT_TYPE.Chameleon))
    defense = defense + math.min(100, fCombatInvisoMult * effectMagnitude(target, core.magic.EFFECT_TYPE.Invisibility))
    return defense
end

local function calculateHitChance(target, weapon)
    local attack = playerAttackTerm(weapon)
    if not attack then return nil end
    return math.max(0, util.round(attack - targetDefenseTerm(target)))
end

local colours = {
    red = { 193 / 255, 63 / 255, 55 / 255, 1 },
    yellow = { 1, 220 / 255, 95 / 255, 1 },
    white = { 1, 1, 1, 1 },
    green = { 180 / 255, 1, 158 / 255, 1 },
    purple = { 184 / 255, 102 / 255, 211 / 255, 1 },
}

local function colourFor(chance)
    if chance <= 25 then return 'red', colours.red end
    if chance <= 50 then return 'yellow', colours.yellow end
    if chance <= 75 then return 'white', colours.white end
    if chance <= 100 then return 'green', colours.green end
    return 'purple', colours.purple
end

local function display(chance)
    local colourKey, colour = colourFor(chance)
    local changed = lastChance ~= chance or lastColourKey ~= colourKey

    if changed then
        if currentStyle == 'Percent' then
            local text = indicator.content['hitChanceContainer'].content['hitChanceText']
            text.props.text = string.format('%d%%', chance)
            text.props.textColor = util.color.rgba(table.unpack(colour))
        elseif currentStyle == 'Circle' then
            indicator.content['hitChanceWidget'].props.color = util.color.rgba(table.unpack(colour))
        else
            local scale = indicator.content['hitChanceWidgetScale']
            scale.props.color = util.color.rgba(table.unpack(colour))
            scale.props.size = SCALE_SIZE:emul(util.vector2(1, math.min(chance, 100) / 100))
        end
        lastChance = chance
        lastColourKey = colourKey
        markDirty()
    end

    local wantsReticle = settings:get('SMEhitChanceReticle')
    if reticle.props.visible ~= wantsReticle then reticle.props.visible = wantsReticle; markDirty() end
    if wantsReticle and (changed or not root.layout.props.visible) then
        reticle.props.color = util.color.rgba(table.unpack(colour))
        markDirty()
    end

    focusTimer = FOCUS_TIME
    fading = false
    fadeTimer = 0
    if not root.layout.props.visible then root.layout.props.visible = true; markDirty() end
    if root.layout.props.alpha ~= 1 then root.layout.props.alpha = 1; markDirty() end
end

local function evaluate()
    if not settings:get('hitChanceIsActive') then return false end
    if camera.getMode() ~= camera.MODE.FirstPerson then return false end
    if types.Actor.getStance(self) ~= types.Actor.STANCE.Weapon then return false end

    local info = I.SME_CORE.getTargetInfo()
    local target = info and info.object or nil
    local distance = info and info.distance or nil
    if not target or not target:isValid() or not (types.NPC.objectIsInstance(target) or types.Creature.objectIsInstance(target)) then return false end
    if types.Actor.isDead(target) then return false end

    local carried = types.Actor.getEquipment(self, types.Actor.EQUIPMENT_SLOT.CarriedRight)
    local marksman = false
    if carried then
        if not types.Weapon.objectIsInstance(carried) then return false end
        local record = types.Weapon.record(carried)
        marksman = weaponSkillMap[record.type] == 'marksman'
    end

    if not marksman and (not distance or distance >= MELEE_RANGE + 1) then return false end

    local chance = calculateHitChance(target, carried)
    if chance == nil then return false end
    display(chance)
    return true
end

local function updateFade(dt)
    if focusTimer > 0 then
        focusTimer = math.max(0, focusTimer - dt)
    elseif root.layout.props.visible and not fading then
        fading = true
        fadeTimer = 0
    end

    if fading then
        fadeTimer = fadeTimer + dt
        root.layout.props.alpha = math.max(0, 1 - fadeTimer / FADE_TIME)
        markDirty()
        if fadeTimer >= FADE_TIME then
            root.layout.props.visible = false
            root.layout.props.alpha = 1
            fading = false
            fadeTimer = 0
            markDirty()
        end
    end
end

local function onUpdate(dt)
    if settingsDirty then
        settingsDirty = false
        applyStyle()
        if not settings:get('hitChanceIsActive') then hideImmediately() end
    end

    if dt <= 0 or core.isWorldPaused() then
        commit()
        return
    end

    if not I.UI.isHudVisible() then
        hideImmediately()
        commit()
        return
    end

    if not settings:get('hitChanceIsActive') then
        hideImmediately()
        commit()
        return
    end

    logicTimer = logicTimer + dt
    if logicTimer >= LOGIC_INTERVAL then
        logicTimer = logicTimer % LOGIC_INTERVAL
        evaluate()
    end

    updateFade(dt)
    commit()
end

applyStyle()
commit()

return { engineHandlers = { onUpdate = onUpdate } }
