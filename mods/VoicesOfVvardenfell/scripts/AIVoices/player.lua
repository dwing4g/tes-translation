--- Voices of Vvardenfell - OpenMW 0.51 player script.

local core    = require('openmw.core')
local types   = require('openmw.types')
local vfs     = require('openmw.vfs')
local storage = require('openmw.storage')
local self    = require('openmw.self')
local I       = require('openmw.interfaces')

local PLAYER       = self.object or self
local BASE_PATH    = 'Vo\\AIV'
local SOUND_PREFIX = 'Sound\\'

I.Settings.registerPage {
    key         = 'AIVoices',
    l10n        = 'AIVoices',
    name        = 'PageName',
    description = 'PageDescription',
}

I.Settings.registerGroup {
    key              = 'SettingsPlayerAIVoices',
    page             = 'AIVoices',
    l10n             = 'AIVoices',
    name             = 'GroupName',
    permanentStorage = true,
    settings         = {
        {
            key         = 'greetingsOnly',
            renderer    = 'checkbox',
            name        = 'greetingsOnly_name',
            description = 'greetingsOnly_description',
            default     = false,
        },
        {
            key         = 'stopOnExit',
            renderer    = 'checkbox',
            name        = 'stopOnExit_name',
            description = 'stopOnExit_description',
            default     = true,
        },
    },
}

I.Settings.registerGroup {
    key              = 'SettingsPlayerAIVoicesPersuasion',
    page             = 'AIVoices',
    l10n             = 'AIVoices',
    name             = 'PersuasionGroupName',
    description      = 'PersuasionGroupDescription',
    permanentStorage = true,
    settings         = {
        { key = 'blockAdmire',         renderer = 'checkbox', name = 'blockAdmire_name',         default = false },
        { key = 'blockIntimidate',     renderer = 'checkbox', name = 'blockIntimidate_name',     default = false },
        { key = 'blockTaunt',          renderer = 'checkbox', name = 'blockTaunt_name',          default = false },
        { key = 'blockBribe',          renderer = 'checkbox', name = 'blockBribe_name',          default = false },
        { key = 'blockServiceRefusal', renderer = 'checkbox', name = 'blockServiceRefusal_name', default = false },
        { key = 'blockInfoRefusal',    renderer = 'checkbox', name = 'blockInfoRefusal_name',    default = false },
    },
}

local settings           = storage.playerSection('SettingsPlayerAIVoices')
local persuasionSettings = storage.playerSection('SettingsPlayerAIVoicesPersuasion')

--- Reports whether greetings-only mode is enabled.
--- @return boolean
local function greetingsOnly()
    return settings:get('greetingsOnly') == true
end

--- Reports whether a playing line should stop when the dialogue menu closes (defaults to true).
--- @return boolean
local function stopOnExit()
    return settings:get('stopOnExit') ~= false
end

--- Maps a persuasion record (matched by its leading word) to the setting that mutes it.
local persuasionBlockKeys = {
    admire     = 'blockAdmire',
    intimidate = 'blockIntimidate',
    taunt      = 'blockTaunt',
    bribe      = 'blockBribe',
    service    = 'blockServiceRefusal',
    info       = 'blockInfoRefusal',
}

--- Reports whether the player has muted the persuasion outcome named by a record id,
--- matched on its leading word (e.g. "Admire" -> blockAdmire).
--- @param recordId string
--- @return boolean
local function isPersuasionBlocked(recordId)
    local action = recordId and recordId:match('^(%a+)')
    local key = action and persuasionBlockKeys[action:lower()]
    return key ~= nil and persuasionSettings:get(key) == true
end

--- Builds a voice path from the supplied actor/faction details. Any nil component is
--- omitted, which is how the fallback chain narrows the lookup.
--- @param race string|nil
--- @param sex string|nil
--- @param infoId string|nil
--- @param actorId string|nil
--- @param factionId string|nil
--- @param factionRank number|nil
--- @return string
local function constructVoicePath(race, sex, infoId, actorId, factionId, factionRank)
    local path = BASE_PATH
    if race then
        path = path .. '\\' .. race
    else
        path = path .. '\\creature'
    end
    if sex then path = path .. '\\' .. sex end
    if actorId then path = path .. '\\' .. actorId end
    if factionId then path = path .. '\\' .. factionId end
    if factionRank and factionRank >= 0 then path = path .. '\\' .. factionRank end
    if infoId then path = path .. '\\' .. infoId .. '.mp3' end
    return path
end

--- Reports whether a voice file exists in the VFS (which uses forward slashes).
--- @param path string Voice path relative to the Sound folder, backslash-separated.
--- @return boolean
local function isPathValid(path)
    return vfs.fileExists((SOUND_PREFIX .. path):gsub('\\', '/'))
end

--- Resolves the most specific existing voice path, falling back through less specific
--- variants (drop rank, then faction, then actor) before giving up. Mirrors the MWSE
--- script's fallback order exactly.
--- @param race string|nil
--- @param sex string|nil
--- @param infoId string|nil
--- @param actorId string|nil
--- @param factionId string|nil
--- @param factionRank number|nil
--- @return string The first valid path, or the most specific path if none exist (for logging).
local function getVoicePath(race, sex, infoId, actorId, factionId, factionRank)
    local primary = constructVoicePath(race, sex, infoId, actorId, factionId, factionRank)
    if isPathValid(primary) then return primary end

    local fallbacks = {
        constructVoicePath(race, sex, infoId, actorId, factionId, nil),
        constructVoicePath(race, sex, infoId, actorId, nil,       nil),
        constructVoicePath(race, sex, infoId, nil,     factionId, factionRank),
        constructVoicePath(race, sex, infoId, nil,     factionId, nil),
        constructVoicePath(race, sex, infoId, nil,     nil,       nil),
        constructVoicePath(nil,  nil,  infoId, actorId, factionId, factionRank),
        constructVoicePath(nil,  nil,  infoId, actorId, factionId, nil),
        constructVoicePath(nil,  nil,  infoId, actorId, nil,       nil),
        constructVoicePath(nil,  nil,  infoId, nil,     factionId, factionRank),
        constructVoicePath(nil,  nil,  infoId, nil,     factionId, nil),
        constructVoicePath(nil,  nil,  infoId, nil,     nil,       nil),
    }
    for _, path in ipairs(fallbacks) do
        if isPathValid(path) then return path end
    end

    return primary
end

--- Returns the player's rank in the given faction, or nil if the player is not a member.
--- @param factionId string
--- @return number|nil
local function playerRankInFaction(factionId)
    local factions = types.NPC.getFactions(PLAYER)
    if factions then
        for _, f in ipairs(factions) do
            if string.lower(f) == string.lower(factionId) then
                local rank = types.NPC.getFactionRank(PLAYER, factionId)
                if rank and rank >= 0 then return rank end
                return nil
            end
        end
    end
    return nil
end

--- Extracts the voice-path inputs (race, sex, actor id, faction, player rank) from an
--- actor; creatures return only their record id, non-actors return nil.
--- @param actor any The speaking actor game object.
--- @return table|nil
local function deriveInputs(actor)
    local actorId = actor.recordId
    if types.Creature.objectIsInstance(actor) then
        return { actorId = actorId }
    end
    if not types.NPC.objectIsInstance(actor) then return nil end

    local rec = types.NPC.record(actor)
    local inputs = {
        race    = rec.race and string.lower(rec.race) or nil,
        sex     = rec.isMale and 'm' or 'f',
        actorId = actorId,
    }

    local factions = types.NPC.getFactions(actor)
    if factions and factions[1] then
        inputs.factionId   = factions[1]
        inputs.factionRank = playerRankInFaction(factions[1])
    end
    return inputs
end

local SKIP_TYPES = { voice = true, journal = true }
local dialogTarget = nil

--- DialogueResponse handler: resolves the line for the speaking actor and asks the
--- global script to voice it, honouring greetings-only / persuasion-mute / skip-types.
--- @param e any DialogueResponse event data (actor, type, recordId, infoId).
local function onDialogueResponse(e)
    if not e.actor then return end
    if SKIP_TYPES[e.type] then return end
    if greetingsOnly() and e.type ~= 'greeting' then return end
    if e.type == 'persuasion' and isPersuasionBlocked(e.recordId) then return end

    local inp = deriveInputs(e.actor)
    if not inp then return end

    local voicePath = getVoicePath(inp.race, inp.sex, e.infoId, inp.actorId, inp.factionId, inp.factionRank)
    if not isPathValid(voicePath) then
        print(string.format('VoV: Missing Line at %s', voicePath))
        return
    end

    print(string.format('VoV: Playing Line at %s', voicePath))
    core.sendGlobalEvent('VoV_PlayLine', { actor = e.actor, file = SOUND_PREFIX .. voicePath })
end

--- UiModeChanged handler: tracks the dialogue actor on entering Dialogue mode and
--- stops its line (when configured) on leaving any menu.
--- @param e any UiModeChanged event data (newMode, arg).
local function onUiModeChanged(e)
    if e.newMode == nil then
        if dialogTarget then
            if stopOnExit() then
                core.sendGlobalEvent('VoV_StopLine', { actor = dialogTarget })
            end
            dialogTarget = nil
        end
    elseif e.newMode == I.UI.MODE.Dialogue and e.arg then
        dialogTarget = e.arg
    end
end

return {
    engineHandlers = {
        UiModeChanged = onUiModeChanged,
    },
    eventHandlers = {
        DialogueResponse = onDialogueResponse,
    },
}
