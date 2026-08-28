local core = require("openmw.core")
local async = require("openmw.async")
local types = require("openmw.types")
local storage = require("openmw.storage")

local paths = {
	loader = "scripts.dynamicactors.dialogue.configLoader",
	filters = "scripts.dynamicactors.dialogue.conditionController",
	npcScript = "scripts.dynamicactors.dialogue.creaturePlugin"
}

local overrides, creatures, voices = {}, {}, {}

local M = { overrides = overrides, creatures = creatures, voices = voices }
local filters = require(paths.filters)		M.filters = filters
local loader = require(paths.loader)

local lastInfo = {}
local lastVoiceTime = 0
local voiceChance = 0.35
local voiceInterval = 5
local actorData = {}

M.infoIndex = storage.globalSection("temp_dActors_infoIndex")
M.infoIndex:setLifeTime(storage.LIFE_TIME.GameSession)

local function indexInfos(record)
	if not record then		return		end
	local id, i = record.id, M.infoIndex
	for k, v in ipairs(record.infos) do
		i:set(id .. "_" .. v.id, k)
	end
end

local function indexTopics(records)
	local topics = {}
	for _, record in ipairs(records) do
		topics[#topics + 1] = record.id
		indexInfos(record)
	end
	return topics
end

if not M.infoIndex:get("initialized") then
	local topics = indexTopics(core.dialogue.greeting.records)
	M.infoIndex:set("greeting", topics)
	topics = { "background", "little advice", "little secret", "latest rumors", "my trade" }
	for _, v in ipairs(topics) do
		indexInfos(core.dialogue.topic.records[v])
	end
	M.infoIndex:set("topic", topics)
	M.infoIndex:set("initialized", true)
end

local function applyFilters(configs, e)
	local filtered = {}
	for i = #configs, 1, -1 do
		local c = configs[i]
	--	actorData.c = c
		if filters.resolve(c.conditions, actorData, e) then
			filtered[#filtered + 1] = c
		end
	end
	return next(filtered) and filtered or nil
end

local function genericResponse(e)
	if not M.Target or e ~= lastInfo then
		return
	end

	local time = core.getSimulationTime()
	if time - lastVoiceTime < voiceInterval then
	--	print("VOICE INTERVAL")
		return
	end
	if core.sound.isSayActive(e.actor) then
		lastVoiceTime = time
	--	print("VOICE PLAYING")
		return
	end

	--	process generic voice line
	if math.random() > voiceChance then
	--	print("VOICE RANDOM")
		return
	end

	local m = voices.byId[e.actor]
	m = m and applyFilters(m, e) or applyFilters(voices, e)
	actorData.m = m

	m = m and m[math.random(#m)]
	if m then
		lastVoiceTime = time
		local sound = m.sounds[math.random(#m.sounds)]
		core.sound.say(sound, e.actor)
	end

end

function M.reloadConfig()
	loader.reloadConfig{ overrides, creatures, voices }
end
function M.actorData()
	return actorData
end

function M.resolveCreature(o)
	if not types.Creature.objectIsInstance(o) then
		return
	end
	local anim = creatures[o.recordId]
	if anim then
		return paths.npcScript, anim
	end
end

local function resolveOverrides(configs, e)
	local m
	for i = #configs, 1, -1 do
		local c = configs[i]
		if filters.resolve(c.conditions, actorData, e) then
			m = c		break
		end
	end
	if not m then
		return
	end

	print("Animated Override", (m.source or ""):upper())
	local anim = { event = "Override" }
	if m.animation then
		anim.groupName, anim.options = m.animation.group, { priority=4 }
	end
	if m.prop then
		anim.prop = {
			model = m.prop.file, start = m.prop.spawnAfter, stop = m.prop.despawnAfter,
			options = { boneName = m.prop.attachTo,
				vfxId = "prop_" .. m.prop.attachTo, useAmbientLight=false, loop=true }
		}
	end

	e.actor:sendEvent("DynamicActors", anim)
	return true
end

function M.resolveInfo(e)
	lastInfo = e		actorData.info = filters.getInfoData(e)
	if core.isWorldPaused() then
		return
	end

	if e.recordId and e.recordId ~= "" then
		async:newUnsavableSimulationTimer(0.5, function()
			genericResponse(e)
		end)
	end

	local configs = overrides.byId[e.actor]
	configs = configs and (configs[e.infoId] or configs[e.recordId])
	if configs and next(configs) then
		if resolveOverrides(configs, e) then
			return
		end
	end
	configs = overrides[e.infoId]
	if configs and next(configs) then
		resolveOverrides(configs, e)
	end
end

function M.Opened(actor)
	actorData = filters.getActorData(actor)
end


return M
