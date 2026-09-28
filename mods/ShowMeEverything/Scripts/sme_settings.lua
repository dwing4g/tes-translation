local async = require('openmw.async')
local core = require('openmw.core')
local I = require('openmw.interfaces')
local storage = require('openmw.storage')

if core.API_REVISION < 129 then
    error('Show Me Everything 2.0 requires OpenMW 0.51.0 / Lua API v129 or newer')
end

I.Settings.registerPage {
    key = 'SMESettingsBehavior',
    l10n = 'SME',
    name = 'Show Me Everything: Actor UI',
    description = 'Behavior settings for the widget.',
}

I.Settings.registerPage {
    key = 'SMESettingsStyle',
    l10n = 'SME',
    name = 'Show Me Everything: Visual',
    description = 'Style settings for the widget.',
}

I.Settings.registerPage {
    key = 'SMEhitChance',
    l10n = 'SME',
    name = 'Show Me Everything: Hit Chance',
    description = 'Hit chance widget. Base of the original code and idea by Safeicus Boxius.',
}

I.Settings.registerGroup {
    key = 'SMESettingsBh',
    page = 'SMESettingsBehavior',
    l10n = 'SME',
    name = 'Behavior',
    permanentStorage = true,
    settings = {
        { key = 'SMEisActive', renderer = 'checkbox', name = 'Modification is enabled', description = 'Enable the actor information widget.', default = true },
        { key = 'SMEClass', renderer = 'checkbox', name = 'Show NPC class', description = 'Show the class of NPCs.', default = true },
        { key = 'SMELevel', renderer = 'checkbox', name = 'Show NPC level', description = 'Show actor level.', default = true },
        { key = 'SMEHealth', renderer = 'checkbox', name = 'Show NPC health values', description = 'Show numeric health values.', default = true },
        { key = 'SMEDamage', renderer = 'checkbox', name = 'Show damage widget', description = 'Show accumulated damage after the player deals health damage.', default = true },
        {
            key = 'SMEShowDistance', name = 'Widget display distance',
            description = 'Distance at which actor information is displayed. 192 roughly matches vanilla activation range.',
            default = 500, renderer = 'number', argument = { min = 192, max = 1000, integer = true },
        },
        { key = 'SMEStance', renderer = 'checkbox', name = 'Only show in combat stance', description = 'Show focus information only while a combat stance is active. Damage can still reveal a target.', default = false },
        { key = 'SMEonHit', renderer = 'checkbox', name = 'Only show on damage', description = 'Show actor information only after the player deals health damage.', default = false },
        { key = 'SMEnotForDead', renderer = 'checkbox', name = 'Show the widget for dead actors', description = 'If disabled, dead actors are ignored when looking at them.', default = true },
    },
}

I.Settings.registerGroup {
    key = 'SMESettingsSt',
    page = 'SMESettingsStyle',
    l10n = 'SME',
    name = 'Visuals',
    permanentStorage = true,
    settings = {
        {
            key = 'SMEWidgetStyle', name = 'Actor UI preset', description = 'Choose the actor UI visual preset.',
            default = 'Vanilla', renderer = 'select',
            argument = { disabled = false, l10n = 'SME', items = {'Vanilla', 'Skyrim', 'Sky Nostalgy', 'Flat', 'Minimal Vanilla', 'Sixth House'} },
        },
    },
}

I.Settings.registerGroup {
    key = 'SMEHitChanceSettings',
    page = 'SMEhitChance',
    l10n = 'SME',
    name = 'Hit Chance widget settings.',
    permanentStorage = true,
    settings = {
        { key = 'hitChanceIsActive', renderer = 'checkbox', name = 'Hit Chance indicator switch', description = 'Enable the hit chance indicator.', default = true },
        {
            key = 'SMEhitChanceWidget', name = 'Hit Chance preset', description = 'Choose the hit chance indicator preset.',
            default = 'Percent', renderer = 'select',
            argument = { disabled = false, l10n = 'SME', items = {'Percent', 'Circle', 'Scale'} },
        },
        { key = 'SMEhitChanceReticle', renderer = 'checkbox', name = 'Hit Chance colored reticle', description = 'Color the reticle according to hit chance.', default = false },
    },
}

local behavior = storage.playerSection('SMESettingsBh')
local hitChance = storage.playerSection('SMEHitChanceSettings')

local function updateActorUiArguments()
    local disabled = not behavior:get('SMEisActive')
    for _, key in ipairs({'SMEClass', 'SMELevel', 'SMEHealth', 'SMEDamage', 'SMEShowDistance', 'SMEStance', 'SMEonHit', 'SMEnotForDead'}) do
        I.Settings.updateRendererArgument('SMESettingsBh', key, { disabled = disabled })
    end
    I.Settings.updateRendererArgument('SMESettingsSt', 'SMEWidgetStyle', {
        disabled = disabled,
        l10n = 'SME',
        items = {'Vanilla', 'Skyrim', 'Sky Nostalgy', 'Flat', 'Minimal Vanilla', 'Sixth House'},
    })
end

local resolvingBehavior = false
local function onBehaviorChanged(_, key)
    if resolvingBehavior then return end

    if key == 'SMEStance' and behavior:get('SMEStance') and behavior:get('SMEonHit') then
        resolvingBehavior = true
        behavior:set('SMEonHit', false)
        resolvingBehavior = false
    elseif key == 'SMEonHit' and behavior:get('SMEonHit') and behavior:get('SMEStance') then
        resolvingBehavior = true
        behavior:set('SMEStance', false)
        resolvingBehavior = false
    end

    -- Rebuilding renderer arguments causes OpenMW to rebuild the settings row.
    -- Only do it when the master switch actually changes, not on every setting edit.
    if key == 'SMEisActive' then
        updateActorUiArguments()
    end
end

local function updateHitChanceArguments()
    local disabled = not hitChance:get('hitChanceIsActive')
    I.Settings.updateRendererArgument('SMEHitChanceSettings', 'SMEhitChanceReticle', { disabled = disabled })
    I.Settings.updateRendererArgument('SMEHitChanceSettings', 'SMEhitChanceWidget', {
        disabled = disabled,
        l10n = 'SME',
        items = {'Percent', 'Circle', 'Scale'},
    })
end

local function onHitChanceChanged(_, key)
    if key == 'hitChanceIsActive' then
        updateHitChanceArguments()
    end
end

updateActorUiArguments()
updateHitChanceArguments()
behavior:subscribe(async:callback(onBehaviorChanged))
hitChance:subscribe(async:callback(onHitChanceChanged))

return {}
