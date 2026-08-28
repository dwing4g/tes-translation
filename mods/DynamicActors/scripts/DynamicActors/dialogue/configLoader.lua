local core = require("openmw.core")
local vfs = require("openmw.vfs")
local types = require("openmw.types")
local loadYaml = require("openmw.markup").loadYaml

local paths = {
	creatures = "mwse/config/animated-dialogue/animations/creatures/",
	overrides = "mwse/config/animated-dialogue/animations/override/",
	voices = "mwse/config/animated-dialogue/voices/",
	xbase = "animations/xbase_anim/",
	sounds = "sound/"
}

local overrides = { byId = {} }
local creatures = { byId = {} }
local voices = { byId = {} }

local M = {}

local function getOrInitKey(t, k)
	local v = t[k]
	if not v then
		v = {}		t[k] = v
	end
	return v
end

local function getMeshPath(f)
	if type(f) ~= "string" then
		return
	end
	f = f:lower():gsub("\\", "/")
	if not vfs.fileExists(f) then
		f = "meshes/" .. f
		if not vfs.fileExists(f) then
			return
		end
	end
	return f
end

local function normalizeStringList(list)
	if type(list) ~= "table" then
		return
	end
	for i = 1, #list do
		if type(list[i]) ~= "string" then
			return
		end
		list[i] = list[i]:lower()
	end
	return #list > 0
end

local function validateAnim(anim)
	if type(anim.prop) ~= "table" and type(anim.animation) ~= "table" then
		return
	end

	local file
	if type(anim.prop) == "table" then
		file = getMeshPath(anim.prop.file)
		if not file or type(anim.prop.attachTo) ~= "string" then
			print("Invalid prop", file, anim.prop.attachTo)
			return
		end
		anim.prop.attachTo = anim.prop.attachTo:lower()
		anim.prop.file = file
	--	if core.API_VERSION < ?? then
			file = file:gsub("%.nif$", "_prop.nif")
			if vfs.fileExists(file) then
				anim.prop.file = file
			end
	--	end
	end

	if type(anim.animation) == "table" then
		file = anim.animation.file
		if type(file) == "string" then
			file = file:lower():gsub("\\", "/")
			file = file:gsub("%.nif$", "")
			local i, j = string.find(file, "/[^/]*$")
			local group = i and file:sub(i + 1, j) or file
			file = paths.xbase .. group .. ".kf"
			if vfs.fileExists(file) then
				anim.animation.key = anim.animation.group
				anim.animation.group = group
			else
				print("Missing animation", file, group)
				return
			end
		end
	end

	return true
end

local function validateVoice(voice)
	if type(voice.sounds) ~= "table" then
		print("Missing sounds table.")
		return
	end
	local sounds = {}
	for _, v in ipairs(voice.sounds) do
		if type(v) == "string" then
			if vfs.fileExists(v) then
				sounds[#sounds + 1] = v
			else
				v = paths.sounds .. v
				if vfs.fileExists(v) then
					sounds[#sounds + 1] = v
				end
			end
		end
	end
--	print(#sounds, next(sounds))
	if not next(sounds) then
		print("Invalid sounds table.")
		return
	end
	voice.sounds = sounds
	local m = voice.conditions
	if type(m) ~= "table" then
		print("Invalid conditions table.")
		return
	end
	for _, v in ipairs { "actor", "race", "sex" } do
		if not normalizeStringList(m[v]) then
			m[v] = nil
		end
	end
--	print(m.sex, m.race, m.actor)
	if not( m.actor or (m.sex and m.race) ) then
		print("Conditions require either actor or sex+race filter.")
		return
	end

	return true
end

local function registerOverrides(list, config)
	for _, anim in ipairs(config) do
		local ids, topics
		if validateAnim(anim) then
			anim.source = anim.source or config.source
			ids, topics = anim.dialogueIds, anim.dialogueTopics
			anim.conditions = anim.conditions or {}
			anim.conditions.isOverride = true
			for _, id in ipairs(ids or {}) do
				table.insert(getOrInitKey(list, id), anim)
			end
			for _, id in ipairs(topics or {}) do
				table.insert(getOrInitKey(list, id), anim)
			end
		end
		if not(ids or topics) then
			print("Invalid override file, no dialogue IDs " .. config.source)
			return
		end
	end
end

local function registerCreatures(configs, data)
	local actor = data.actor
	for _, anim in ipairs(data) do
		anim.source = anim.source or data.source
		if type(anim.id) ~= "string" then
			print("Invalid creature file, missing record ID " .. data.source)
			break
		end
		anim.id = anim.id:lower()
		if anim.id == actor then
			table.insert(configs.byId, anim)
		elseif not anim.group then
			configs[anim.id] = nil
		else
			configs[anim.id] = anim
		end
	end
end

local function registerVoices(configs, data)
	local actor = data.actorId and { data.actorId } or nil
	for _, v in ipairs(data) do
		if actor then
			v.conditions = type(v.conditions) == "table" and v.conditions or {}
			v.conditions.actor = actor
		end
		if validateVoice(v) then
			v.source = data.source
			if actor then
				table.insert(configs.byId, v)
			--	print("ACTOR INSERT")
			else
				configs[#configs + 1] = v
			--	print("LIST INSERT", #configs, #voices)
			end
		else
			print("Invalid voice file " .. data.source)
		end
	end
end

local function getJsonYaml(path)
	local files, names = {}, {}
	for f in vfs.pathsWithPrefix(path) do
		if f:find("%.json$") or f:find("%.yaml$") then
			f = f:sub(1, -6)
			if not names[f] then
				files[#files + 1] = f		names[f] = true
			end
		end
	end
	return files
end

local function loadOverrides()
	local files = getJsonYaml(paths.overrides)
	local i = paths.overrides:len() + 1
	for _, f in ipairs(files) do
		local ext = vfs.fileExists(f .. ".yaml") and ".yaml" or ".json"
		local data = loadYaml(f .. ext)
		if type(data) == "table" then
			local id = f:sub(i)
		--	print(id)
			data.source = id .. ext
			data.actor = (types.NPC.records[id] or types.Creature.records[id])
				and id or nil
			if data.actor then
				local record = getOrInitKey(overrides.byId, id)
				registerOverrides(record, data)
			else
				registerOverrides(overrides, data)
			end
		end
	end
end

local function loadCreatures()
	local files = getJsonYaml(paths.creatures)
	local i = paths.creatures:len() + 1
	for _, f in ipairs(files) do
		local ext = vfs.fileExists(f .. ".yaml") and ".yaml" or ".json"
		local data = loadYaml(f .. ext)
		if type(data) == "table" then
			local id = f:sub(i)
		--	print(id)
			data.source = id .. ext
			data.actor = types.Creature.records[id] and id or nil
			registerCreatures(creatures, data)
		end
	end
	registerCreatures(creatures, creatures.byId)
end

local function loadVoices()
	local files = getJsonYaml(paths.voices)
	local i = paths.voices:len() + 1
	for _, f in ipairs(files) do
		local ext = vfs.fileExists(f .. ".yaml") and ".yaml" or ".json"
		local data = loadYaml(f .. ext)
		if type(data) == "table" then
			local id = f:sub(i)
		--	print(id)
			data.source = id .. ext
			data.actorId = (types.NPC.records[id] or types.Creature.records[id])
				and id or nil

			if data.actorId then
				local configs = getOrInitKey(voices.byId, id)
				registerVoices(configs, data)
			else
				registerVoices(voices, data)
			end
		end
	end
--	registerVoices(voices, voices.byId)
end

function M.reloadConfig(m)
	overrides, creatures, voices = table.unpack(m)
	for k, _ in next, overrides do		overrides[k] = nil		end
	overrides.byId = {}
	for k, _ in next, creatures do		creatures[k] = nil		end
	creatures.byId = {}
	for k, _ in next, voices do		voices[k] = nil			end
	voices.byId = {}
	loadCreatures()
	loadOverrides()
	loadVoices()
--	print(#overrides, #creatures, #voices)
end


return M
