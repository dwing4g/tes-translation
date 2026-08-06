local world = require("openmw.world")
local core = require("openmw.core")
local vfs = require('openmw.vfs')
local async = require('openmw.async')
local types = require("openmw.types")
local I = require("openmw.interfaces")
local storage = require("openmw.storage")
local markup = require("openmw.markup")

local paths = {
	overrides = "mwse/config/animated-dialogue/animations/override/",
	xbase = "animations/xbase_anim/",
}

local overrides = { byId = {} }


local M = { overrides = overrides }


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

local function validateAnim(anim)
	if type(anim.prop) ~= "table" and type(anim.animation) ~= "table" then
		return
	end

	local file
	if type(anim.prop) == "table" then
		file = getMeshPath(anim.prop.file)
		if not file or type(anim.prop.attachTo) ~= "string" then
			print("Invalid prop", file, anim.prop.file)
			return
		end
		anim.prop.file = file
		anim.prop.attachTo = anim.prop.attachTo:lower()
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
			file = file:lower():gsub("%.nif$", "")
			file = file:gsub("\\", "/")
			local i, j = string.find(file, "/[^/]*$")
			local group = i and file:sub(i + 1, j) or file
			if vfs.fileExists(paths.xbase .. group .. ".kf") then
				anim.animation.group = group
			else
				print("Invalid animation", file, group)
				return
			end
		end
	end

	return true
end

local function registerOverrides(config, list)
	for _, anim in ipairs(config) do
		if validateAnim(anim) then
			anim.source = config.source
			for _, id in ipairs(anim.dialogueIds or {}) do
				table.insert(getOrInitKey(list, id), anim)
			end
			for _, id in ipairs(anim.dialogueTopics or {}) do
				table.insert(getOrInitKey(list, id), anim)
			end
		else
			print("Invalid override file " .. config.source)
			return
		end
	end
end

local function loadOverrides()
	local files = {}
	for f in vfs.pathsWithPrefix(paths.overrides) do
		if f:find("%.json$") or f:find("%.yaml$") then
			f = f:gsub("%.json$", "")		f = f:gsub("%.yaml$", "")
			if not files[f] then
				files[#files + 1] = f		files[f] = true
			end
		end
	end
	local i = paths.overrides:len() 
	for _, f in ipairs(files) do
		local ext = vfs.fileExists(f .. ".yaml") and ".yaml" or ".json"
		local data = markup.loadYaml(f .. ext)
		if type(data) == "table" then
			local id = f:sub(i + 1, f:len())
		--	print(id)
			data.source = id .. ext
			if types.NPC.records[id] or types.Creature.records[id] then
				local record = getOrInitKey(overrides.byId, id)
				data.actor = id
				registerOverrides(data, record)
			else
				registerOverrides(data, overrides)
			end
		end
	end
end

function M.reloadOverrides()
	for k, _ in next, overrides do		overrides[k] = nil		end
	overrides.byId = {}
	loadOverrides()
end

function M.resolveInfo(e)
	local info = overrides[e.infoId]
	if not info or not next(info) then
		return
	end

	local m
	for i = #info, 1, -1 do
		local conditions = info[i].conditions
		if not conditions then
			m = info[i]
			break
		end
		local actor = conditions.actor
		if actor and actor:lower() == e.actor then
			m = info[i]
			break
		end
		local class = conditions.class
		if class and class:lower() == e.actor.type.records[e.actor].class then
			m = info[i]
			break
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

end


return M
