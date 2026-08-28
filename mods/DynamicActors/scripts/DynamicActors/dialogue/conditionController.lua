local core = require("openmw.core")
local types = require("openmw.types")


local function contains(strings, value)
	for _, v in ipairs(strings) do
		if v == value then
			return true
		end
	end
end

local function matchPatterns(patterns, text)
	for i = 1, #patterns do
		if text:find(patterns[i]) then
			return true
		end
	end
end

local function getPunctuation(text)
	if type(text) ~= "string" or text == "" then
		return "statement"
	end
	local last = (text:gsub("[%s\"'%)%]}]+$", ""))		last = last:sub(-1)
	return last == "?" and "question" or last == "!" and "exclamation" or "statement"
end

local conditions = {}

conditions.actor = function(c, m)
	return contains(c, m.recordId)
end
conditions.class = function(c, m)
	return m.class and contains(c, m.class)
end
conditions.faction = function(c, m)
	return m.faction and contains(c, m.faction)
end
conditions.interior = function(c, m)
	return c.interior == m.interior
end
conditions.race = function(c, m)
	return m.race and contains(c, m.race)
end
conditions.sex = function(c, m)
	return m.sex and contains(c, m.sex)
end

conditions.dialogueIds = function(c, _, info)
	return contains(c, info.infoId)
end
conditions.dialogueTypes = function(c, _, info)
	return contains(c, info.type)
end
conditions.dialogueTopics = function(c, _, info)
	return contains(c, info.topic)
end
conditions.keywordPatterns = function(c, m)
	local text = m.info.text
	if text and text ~= "" then
		return matchPatterns(c, text)
	end
end
conditions.punctuation = function(c, m)
	return contains(c, m.info.punctuation)
end
conditions.isOverride = function()	return true		end
conditions.null = function() end

function conditions.getActorData(o)
	local m = {}
	local rec = o.type.records[o.recordId]
	m.recordId = o.recordId
	m.race = rec.race
	m.class = rec.class
	m.info = {}

	local c
	c = o.type.getFactions		c = c and c(o)
	m.faction = c and c[1] or nil
	c = o.cell
	m.interior = not(c.isExterior or c:hasTag("QuasiExterior"))
	c = rec.isMale
	m.sex = c ~= nil and (c and "male" or "female") or nil
	return m
end

function conditions.getInfoData(e)
	local info = { id = e.infoId, type = e.type, topic = e.recordId or "", punctuation = "statement" }
	local rec = core.dialogue[info.type].records[info.topic]
	if not rec then
		return info
	end

	local infoId = e.infoId
	--	print(rec, infoId, e.infoIndex)
	info.record = rec.infos[e.infoIndex] or nil		info.infoIndex = e.infoIndex
	if not info.record then
		return info
	end

	info.text = info.record.text		info.text = info.text and info.text:lower()
	info.punctuation = getPunctuation(info.text)
	return info
end

function conditions.resolve(c, actor, info)
	if not c then
		return
	end
	for k, v in next, c do
		local m = conditions[k]
		if not m or not m(v, actor, info) then
			return
		end
	end
	return true
end


return conditions
