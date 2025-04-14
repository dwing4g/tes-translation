local self = require("openmw.self")
local types = require("openmw.types")
local time = require("openmw_aux.time")
local ui = require("openmw.ui")
local core = require("openmw.core")
local I = require("openmw.interfaces")
local util = require('openmw.util')
local async = require('openmw.async')
local ambient = require("openmw.ambient")
local vfs = require('openmw.vfs')
local storage = require('openmw.storage')
local l10n = core.l10n("SSQN")


local soundfiles = require("scripts.SSQN.configSound")
local comments = require("scripts.SSQN.comments")
comments.enabled = false

local settings = storage.playerSection("Settings_openmw_SSQN")


local playerqlist = { ["testbanner_id"] = true }
local element = nil
local questnames
if core.dialogue then
	questnames = {}
else
	questnames = require("scripts.SSQN.qnamelist")
	print("No dialogue API. Using qnamelist.lua ...")
end
local iconlist = {}		local ignorelist = {}
local updateList = {}

local questLog = {}		local proxy = {}

local function parseList(list, isMain)
	if type(list) ~= "table" then return		end
	for k, v in pairs(list) do
		if not iconlist[k:lower()] or isMain then
			if v:find("^\\") then v = string.sub(v, 2, -1)		end
			iconlist[k:lower()] = v
		end
	end
end

local M = require("scripts.SSQN.iconlist")
parseList(M, true)
for i in vfs.pathsWithPrefix("scripts/SSQN/iconlists/") do
	if i:find(".lua$") then
		print("Loading iconlist "..i)
		i = string.gsub(i, ".lua", "")		i = string.gsub(i, "/", ".")
		M = require(i)
		parseList(M, true)
	end
end


-- Legacy sound names
local legacy = {
	keys = { "soundfile", "soundfilefin", "soundfileupdate" },
	update = {
		["Book Page 1"] = "snd_book1",
		["Book Page 2"] = "snd_book2",
		["SkyUI New Quest"] = "snd_ui_quest_new",
		["SkyUI Objective 1"] = "snd_ui_obj_new_01",
		["SkyUI Skill Increase"] = "snd_ui_skill_inc",
		["None"] = "snd_none", ["Custom"] = "snd_custom", ["Same as Start"] = "snd_same"
		}
}

local function updateKeys()
	for _, v in ipairs(legacy.keys) do
		local key = settings:get(v)
	--	print(v, key)
		if key and legacy.update[key] then
	--		print(v, legacy.update[key])
			settings:set(v, legacy.update[key])
		end
	end
end

updateKeys()


local function gmstToRgb(id, blend)
	local gmst = core.getGMST(id)
	if not gmst then return util.color.rgb(0.6, 0.6, 0.6) end
	local col = {}
	for v in string.gmatch(gmst, "(%d+)") do col[#col + 1] = tonumber(v) end
	if #col ~= 3 then print("Invalid RGB from "..gmst.." "..id) return util.color.rgb(0.6, 0.6, 0.6) end
	if blend then
		for i = 1, 3 do col[i] = col[i] * blend[i] end
	end
	return util.color.rgb(col[1] / 255, col[2] / 255, col[3] / 255)
end

local uiTheme = {
	normal = gmstToRgb("FontColor_color_normal"),
	header = gmstToRgb("FontColor_color_header"),
	baseSize = 16
	}

local function initQuestlist()
	print("Building existing player quest list")
	local quests = types.Player.quests(self)
	for _,v in pairs(quests) do
		local qid = v.id:lower()
       		if playerqlist[qid] == nil then
			playerqlist[qid] = v.finished
	--		if playerqlist[qid] then print(qid, "finished")
	--		else print(qid) end
		end
	end
end

local function iconpicker(qIDString)
    qIDString = qIDString:lower()
    --checks for full name of index first as requested, then falls back on finding prefix
    if (iconlist[qIDString] ~= nil) then
        return iconlist[qIDString]
    else
		local j = 0 --Just to prevent a possible infinite loop
		repeat
			j = j + 1
			local loc = nil
			local i = 0
			repeat
				i = i - 1
				loc = string.find(qIDString, "_", i)
			until (loc ~= nil) or (i == -string.len(qIDString))
			if ( loc ~= nil ) then
				qIDString = string.sub(qIDString,1,loc)
				if (iconlist[qIDString] ~= nil) then
					break
				else
					qIDString = string.sub(qIDString,1,loc - 1)
				end
			else
				qIDString = ""
				break
			end
		until (iconlist[qIDString] ~= nil) or (qIDString == "") or (j == 10)
		
        if (iconlist[qIDString] ~= nil) then
	        return iconlist[qIDString]
        else
            return "Icons\\SSQN\\DEFAULT.dds" --Default in case no icon is found
        end
    end
end

local function removePopup()
	if not element or type(element) == "number" then element = nil	return		end
	element:destroy()
	element = nil
end

local function getQuestName(i)
	if i == "testbanner_id" then
		return "Skyrim Style Quest Notifications"
	end
	local name
	if core.dialogue then
		name = core.dialogue.journal.records[i].questName
		if name == nil then name = "skip" end
	else
		name = questnames[i]
	end
	return name
end


local fader = {}

local function displayPopup(questId, index)
	local e = {
		x=settings:get("bannerposx"), y=settings:get("bannerposy"),
		showTitle = true, showIcon = settings:get("showicon"),
		width = 420, height = 72,	textX = 0.56, textY = 0.7,
	}

	local qname = getQuestName(questId) or questId
	local notificationImage = iconpicker(questId)
	print(questId, notificationImage)
	if not vfs.fileExists(notificationImage) then notificationImage = "Icons\\SSQN\\DEFAULT.dds" end

	local notificationText
	if not index then
		notificationText = playerqlist[questId] and "text_questfin" or "text_queststart"
	else
		local obj = comments[questId]		if obj then obj = obj[index]	end
		notificationText = qname
		if obj then
			qname = obj
		else
			qname = "New Journal Entry"
		end
	end

	local template = settings:get("bannertransp") and I.MWUI.templates.boxTransparentThick
		or I.MWUI.templates.boxSolidThick
	local l = qname:len()		local pt = tonumber(settings:get("textSize"))
	local bodySize = (l > 34 and pt) or (l > 24 and pt*1.25) or (pt*1.5)
	if index then
		e.textX = 0.5		e.showIcon = false
		bodySize = (l > 40 and pt) or (pt*1.25)
		if qname ~= "New Journal Entry" then
			e.textY = 0.5	e.showTitle = false	e.height = 48
		end
	elseif not e.showIcon then
		e.textX = 0.5	e.textY = 0.7
		bodySize = (l > 40 and pt) or (l > 30 and pt*1.25) or (pt*1.5)
	end

	bodySize = tonumber(settings:get("textSizeTitle"))
--	print(bodySize)


local minHeight = { type = ui.TYPE.Image,
		props = {
			size = util.vector2(8, e.height - 2),
			resource = ui.texture { path = "white" },
			color = util.color.hex("ff0000"), alpha = 0,
		}
	}

local minWidth = { type = ui.TYPE.Image,
		props = {
			size = util.vector2(e.width - 16, 1),
			resource = ui.texture { path = "white" },
			color = util.color.hex("00ff00"), alpha = 0,
		}
	}

local spacer = { type = ui.TYPE.Image,
		props = {
			visible = e.showTitle,
			size = util.vector2(20, 8),
			resource = ui.texture { path = "white" },
			color = util.color.hex("00ff00"), alpha = 0,
		}
	}

local contentIcon = {
	type = ui.TYPE.Image,
	props = {
			--** Size of Icon 48 x 48. Change values in line below.
                size = util.vector2(48, 48),
		resource = ui.texture { path = notificationImage },
	},
}

local contentLabel = {
	template = I.MWUI.templates.textNormal,
	type = ui.TYPE.Text,
	props = {
	    text = l10n(notificationText),
	    textSize =  uiTheme.baseSize, textColor = uiTheme.normal,
	},
}


local contentText = {}
table.insert(contentText, minWidth)
if e.showTitle then
	table.insert(contentText, spacer)
	table.insert(contentText, contentLabel)
	if bodySize == 16 then
		table.insert(contentText, spacer)
	end
end
table.insert(contentText, spacer)
table.insert(contentText,
	{ template = I.MWUI.templates.textHeader,
	type = ui.TYPE.Text,
	props = {
		text = qname,
		textSize = bodySize, textColor = uiTheme.header,
		},
	})

table.insert(contentText, spacer)
table.insert(contentText, minWidth)


local contentBanner = {}
if e.showIcon then
	table.insert(contentBanner, minHeight)
	table.insert(contentBanner, contentIcon)
end
table.insert(contentBanner, minHeight)
table.insert(contentBanner,
        { template = I.MWUI.templates.padding, alignment = ui.ALIGNMENT.Center, content = ui.content {
		{ type = ui.TYPE.Flex,
			props = { horizontal = false,
                	   align = ui.ALIGNMENT.Center,
                	    arrange = ui.ALIGNMENT.Center,
			},
			content = ui.content(contentText)
		},
	}, })

table.insert(contentBanner, minHeight)


element = ui.create {
	layer = 'Notification',
	template = template,
	type = ui.TYPE.Container,
	props = {
	visible = true,
	relativePosition = util.vector2(e.x, e.y),
	anchor = util.vector2(0.5, 0.5),
	alpha = 0,
	},
	content = ui.content {

	{ type = ui.TYPE.Flex, props = { horizontal = true,
                   align = ui.ALIGNMENT.Center,
                    arrange = ui.ALIGNMENT.Center,
			},
	content = ui.content(contentBanner)
	},

	},

}

--	async:newUnsavableSimulationTimer(settings:get("bannertime") - 1, function() removePopup() end)

	fader.count = 0		fader.time = settings:get("bannertime")
	fader.stop = time.runRepeatedly(function()
		local m = fader
		m.count = m.count + 0.04
		if m.count > m.time + 1 then
			m.stop()
			removePopup()
			return
		end
		if not element then		return		end
		if m.count < 0.6 then
			element.layout.props.alpha = util.clamp(m.count / 0.5, 0, 1)
			element:update()			
		elseif m.count > m.time - 1.5 and m.count < m.time + 0.2 then
			element.layout.props.alpha = util.clamp(1 - (m.count + 1.5 - m.time) / 1.5, 0, 1)
			element:update()
		end
	end, 0.04 * time.second)

	local soundfile
	if index then
		soundfile = "Fx\\ui\\ui_objective_new_01.wav"
	elseif notificationText == "text_queststart" then
		soundfile = soundfiles[settings:get("soundfile")]
		if soundfile == "custom" then soundfile = settings:get("soundcustom")	end
	else
		soundfile = soundfiles[settings:get("soundfilefin")]
		if soundfile == "same" then
			soundfile = soundfiles[settings:get("soundfile")]
		elseif soundfile == "custom" then
			soundfile = settings:get("soundcustomfin")
		end
	end

	if soundfile ~= nil then ambient.playSoundFile("Sound\\"..soundfile)		end
end

local function getQuestchange(quests)
	for _,v in pairs(quests) do
		local qid = v.id:lower()
       		if playerqlist[qid] ~= nil then
			if v.finished and not playerqlist[qid] then
				playerqlist[qid] = true
				return qid
			end
		end
		if playerqlist[qid] == nil then
			playerqlist[qid] = v.finished
			if getQuestName(qid) ~= "skip" then return qid end
		end
	end
	return nil
end

local function journalHandler()
	if element or #updateList == 0 then		return		end
	local msg = updateList[1]		table.remove(updateList, 1)
--	print(msg.id, msg.index, msg.type)
	if msg.type == "quest" then
		displayPopup(msg.id)
	elseif msg.type == "objective" then
--		print(msg.id, msg.index)
		displayPopup(msg.id, msg.index)
	end
end

time.runRepeatedly(function()
	if not settings:get("bannerdemo") then journalHandler()
	elseif element == nil then
		displayPopup("testbanner_id")
		playerqlist.testbanner_id = not playerqlist.testbanner_id
	end
end, 1 * time.second)


local function updateJournal(id, stage, info)

	local quest = questLog[id]
	if not quest then
		quest = {}		questLog[id] = quest
	end
	quest[stage] = { id=info.id, time=core.getGameTime() }

	local q = {}
	for k, v in pairs(quest) do
		q[k] = util.makeReadOnly(v)
	end
	proxy[id] = util.makeReadOnly(q)

end

local function onQuestUpdate(id, stage)

	local infos = core.dialogue.journal.records[id].infos
	local journal = questLog[id] or {}
	for _, v in ipairs(infos) do
		if v.questStage == stage and v.text and v.text ~= "" and not journal[stage] then
	--		journal[stage] = { id=v.id, time=core.getGameTime() }
			updateJournal(id, stage, v)
		end
	end

	if not ignorelist[id] and settings:get("enabled") then
		if getQuestchange(types.Player.quests(self)) then
			updateList[#updateList + 1] = { id=id, index=stage, type="quest" }
		end
		if comments.enabled then
			updateList[#updateList + 1] = { id=id, index=stage, type="objective" }
		end
	end
	local soundfile = soundfiles[settings:get("soundfileupdate")]
	if soundfile == "custom" then soundfile = settings:get("soundcustomupdate")	end
	if soundfile == nil then return end
	if element == nil and not core.isWorldPaused() then
		element = 1
		async:newUnsavableSimulationTimer(1, function() removePopup() end)
	end
	ambient.playSoundFile("Sound\\"..soundfile)
end


return {
	engineHandlers = {
		onQuestUpdate = onQuestUpdate,
		onInit = initQuestlist,
		onLoad = function(e)
			if e and e.journal then
				questLog = e.journal
				for k, v in pairs(questLog) do
					local q = {}
					for k, v in pairs(v) do
						q[k] = util.makeReadOnly(v)
					end
					proxy[k] = util.makeReadOnly(q)
				end
			end
			initQuestlist()
		end,
		onSave = function() return{ version=130, journal = questLog }		end
	},

	eventHandlers = {
		UiModeChanged = function(e)
			if element then self:sendEvent("ssqnRemove")		end
		end,
		ssqnRemove = function()
			if not element then		return		end
			local visible = element.layout.props.visible
			if visible and core.isWorldPaused() then
				element.layout.props.visible = false
				element:update()
			elseif not visible and not core.isWorldPaused() then
				element.layout.props.visible = true
				element:update()
			end
		end
	},

	interfaceName = "SSQN",
	interface = {
		version = 130,
		registerQIcon = function(id, path)
			if path:find("^\\") then path = string.sub(path, 2, -1)		end
			iconlist[id:lower()] = path
		end,
		getQIcon = function(id) return iconpicker(id)				end,
		blockQBanner = function(id) ignorelist[id:lower()] = true		end,
		isQBannerBlocked = function(id) return ignorelist[id] == true		end,
		addQComment = function(id, index, text)
			id = id:lower()		local q = comments[id]
			if not q then q = {}	comments[id] = q		end
			q[index] = text
		end,
		getJournal = function()		return util.makeReadOnly(proxy)		end
	}
}
