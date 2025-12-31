local util = require('openmw.util')
local storage = require('openmw.storage')
local playerSettings = storage.playerSection('SettingsPlayerHPBars')
local types = require('openmw.types')
local core = require('openmw.core')
local v2 = require('openmw.util').vector2
local I = require("openmw.interfaces")

local presetColors = {
	"ffffff", -- white
	"aaaaaa", -- gray
	"a00004", -- red
	"300004", -- dark red
	"600004", -- darker red
	"cc1a1a", -- bright red
	"bb2100", -- red-orange
	"cc2a00", -- red-orange 2
	"b55500", -- orange
	"9a5517", -- brown-orange
	"ccbb00", -- yellow
	"cccc00", -- yellow 2
	"ada11a", -- olive
	"c5a15e", -- tan
	"9a5e3a", -- brown
	"ad6364", -- dusty rose
	"3ca01e", -- green
	"1263b0", -- blue
	"4c6188", -- gray-blue
	"0011ee", -- bright blue
}

local orderCounter = 0
local function getOrder()
	orderCounter = orderCounter + 1
	return orderCounter
end

local settingsTemplate = {}

settingsTemplate["Layout"] = {
	key = "SettingsPlayerHPBars_Layout",
	page = "HPBars",
	l10n = "HPBars",
	name = "Layout",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "ROW1",
			name = "Row 1 Widget",
			description = "The HP Bars consist of 4 rows, select what's displayed on the first",
			default = "nothing", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"nothing", "Actor Name", "HP", "HP/MaxHP", "Buffs"},
			},
		},
		{
			key = "ROW2",
			name = "Row 2 Widget",
			description = "",
			default = "nothing", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"nothing", "Actor Name", "HP", "HP/MaxHP", "Buffs"},
			},
		},
		{
			key = "ROW3",
			name = "Row 3 Text (on bar)",
			description = "Can only be text",
			default = "HP/MaxHP", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"nothing", "Actor Name", "HP", "HP/MaxHP"},
			},
		},
		{
			key = "ROW4",
			name = "Row 4 Widget",
			description = "",
			default = "Buffs", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"nothing", "Actor Name", "HP", "HP/MaxHP", "Buffs"},
			},
		},
		{
			key = "RESOURCES",
			name = "Resources",
			description = "Fatigue + Magicka",
			default = "nothing", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"nothing", "Fatigue", "Magicka", "Fatigue + Magicka"},
			},
		},
		{
			key = "ANCHOR",
			name = "Bar anchor",
			description = "",
			default = "head", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"feet", "head"},
			},
		},
	},
}

settingsTemplate["Visibility"] = {
	key = "SettingsPlayerHPBars_Visibility",
	page = "HPBars",
	l10n = "HPBars",
	name = "Visibility",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "OWN_BAR",
			renderer = "checkbox",
			name = "Own bar",
			description = "Show your own healthbar (in 3rd person)",
			default = false,
		},
		{
			key = "ONLY_IN_COMBAT",
			name = "Only Render Bars For Actors In Combat",
			description = "Only shows bars for actors with a weapon or spell readied (works for creatures too)",
			default = true, 
			renderer = "checkbox",
		},
		{
			key = "ALWAYS_CHECK_BUFFS",
			name = "Always show spell targets",
			description = "Always show bars for actors that have active magic effects from you",
			renderer = "checkbox",
			default = true,
		},
		{
			key = "MAX_DISTANCE",
			name = "Max Distance",
			description = "Disables HP bars for actors that are further away than this",
			min = 100,
			default = 1500, 
			renderer = "number",
		},
		{
			key = "RAYTRACING",
			name = "Occlusion Detection",
			description = "Hide healthbars for actors that are behind objects",
			default = true, 
			renderer = "checkbox",
		},
		{
			key = "DAMAGED_ACTORS",
			name = "Damaged Actors",
			description = "Always show bars of actors that don't have full health",
			default = true, 
			renderer = "checkbox",
		},
		{
			key = "UNDER_CROSSHAIR",
			name = "Targeted Actor",
			description = "Always show bar of the actor under the crosshair",
			default = "off", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"off", "Weapon readied", "always", "Weapon readied = everyone"},
			},
		},
		{
			key = "ALWAYS_SHOW_NAME",
			name = "Always Show Name",
			description = "Show Name even when the actor is not in combat. can get overridden by the setting which hides the name in combat",
			default = false,
			renderer = "checkbox",
		},
	},
}

settingsTemplate["Animation"] = {
	key = "SettingsPlayerHPBars_Animation",
	page = "HPBars",
	l10n = "HPBars",
	name = "Animation",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "LAGBAR",
			renderer = "checkbox",
			name = "Damage-Bar",
			description = "Visualizes recently taken damage",
			default = true,
		},
		{
			key = "HEALBAR",
			renderer = "checkbox",
			name = "Enemy healbar",
			description = "Visualizes incoming enemy healing",
			default = true,
		},
		{
			key = "LERPSPEED",
			name = "Animation Speed",
			description = "How fast the bars are animated, for example on physical damage taken",
			default = 128,
			min = 1,
			renderer = "number",
		},
		{
			key = "LAGDURATION",
			name = "Damage Taken Visualizer Duration",
			description = "For how long the damage bar will indicate recently taken damage",
			default = 0.7, 
			min = 0.1,
			renderer = "number",
		},
	},
}

settingsTemplate["Text"] = {
	key = "SettingsPlayerHPBars_Text",
	page = "HPBars",
	l10n = "HPBars",
	name = "Text & Font",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "FONT",
			name = "Font",
			description = "Global Addon Font",
			default = "Pelagiad", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"Pelagiad", "MysticCards", "Daedra", "OpenSans", "Roboto", "BlackOps", "Asul"},
			},
		},
		{
			key = "HP_SIZE",
			name = "HP Text size",
			description = "Percentage of bar height, 0-1",
			renderer = "number",
			max = 1,
			min = 0.01,
			default = 0.73,
		},
		{
			key = "TEXT_OFFSET",
			name = "Text offset",
			description = "Global text offset, 0-1",
			renderer = "number",
			max = 0.5,
			min = 0.01,
			default = 0.08,
		},
		{
			key = "NAME_SIZE",
			name = "Name size",
			description = "Percentage of bar height, 0-1",
			renderer = "number",
			max = 1,
			min = 0.1,
			default = 0.7,
		},
		{
			key = "NAME_BEHAVIOR",
			name = "Name Behavior",
			description = "When to show the actor's name",
			default = "hidden in combat", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"always", "hidden in combat", "reaction color"},
			},
		},
		{
			key = "NAME_COL",
			name = "Name Color",
			description = "Color of the actor's name (ignored if reaction color is used)",
			default = util.color.hex("ffffff"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "HP_TEXT_COL",
			name = "HP Text Color",
			description = "Color of the HP/MaxHP text",
			default = util.color.hex("ffffff"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "BUFF_ICONSIZE",
			name = "Buff IconSize",
			description = "",
			renderer = "number",
			max = 1,
			min = 0.1,
			default = 1,
		},
	},
}

settingsTemplate["Level"] = {
	key = "SettingsPlayerHPBars_Level",
	page = "HPBars",
	l10n = "HPBars",
	name = "Level Display",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "LEVEL",
			name = "Level number",
			description = "Level color and hide/show",
			default = "color-coded", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"hidden", "white", "gray", "bar-color", "color-coded"},
			},
		},
		{
			key = "LEVEL_POSITION",
			name = "Level Position",
			description = "Right or left of the HP Bar if not hidden in the setting above",
			default = "left", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"left", "right"},
			},
		},
		{
			key = "REQUIRED_LEVEL",
			name = "Required level to see level",
			description = "Relative to the actor's level",
			renderer = "number",
			default = -8,
			integer = true
		},
		{
			key = "REQUIRED_HP",
			name = "Required level to see HP",
			description = "Relative to the actor's level",
			renderer = "number",
			default = -4,
			integer = true
		},
		{
			key = "hideLevelInsteadOfObscuring",
			name = "Hide Level Instead Of Obscuring",
			description = "If your level is too low, hides the actor's level instead of using the daedric font",
			renderer = "checkbox",
			default = false,
		},
		{
			key = "LEVELTEXT_SIZE",
			name = "Level Number size",
			description = "Percentage of bar height, 0-1",
			renderer = "number",
			max = 1,
			min = 0.1,
			default = 0.8,
		},
	},
}

settingsTemplate["Size"] = {
	key = "SettingsPlayerHPBars_Size",
	page = "HPBars",
	l10n = "HPBars",
	name = "Size & Position",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "SCALE",
			name = "HP Bars Scale",
			description = "Multiplier on the final bar scale (after distance scaling)",
			default = 0.9,
			min = 0.1,
			renderer = "number",
		},
		{
			key = "THICKNESS",
			name = "HP Bars Thickness",
			description = "Multiplier on the bar thichness",
			default = 0.999,
			min = 0.1,
			renderer = "number",
		},
		{
			key = "OFFSET_X",
			name = "Offset X",
			description = "Moves the bars left or right",
			default = 0, 
			renderer = "number",
		},
		{
			key = "OFFSET_Y",
			name = "Offset Y",
			description = "Moves the bars up or down",
			default = -8, 
			renderer = "number",
		},
		{
			key = "BORDER_STYLE",
			name = "Border style",
			description = "Max performance disables the transparency changing of the borders (which is in 0.1 steps), but then the bars will look less natural in the distance",
			default = "thin", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"none", "max performance", "thin", "normal", "thick", "verythick"},
			},
		},
		{
			key = "BORDER_COLOR",
			name = "Color Borders",
			description = "Colors the borders based on ..",
			default = "default", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"default", "relative level", "reaction"},
			},
		},
	},
}

settingsTemplate["Colors"] = {
	key = "SettingsPlayerHPBars_Colors",
	page = "HPBars",
	l10n = "HPBars",
	name = "Colors",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "COLOR_PRESET",
			name = "Color Preset",
			description = "Feel free to share cool color combinations in the comments",
			default = "Y/T/B/R/G  ", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "HPBars", 
				items = {"Y/T/B/R/G  ", "O/T/B/R/G  ", "R/T/B/W/G ", "O/Y2/B/W/G","O/Y/B/R/G  ","O/B/R/G    "},
			},
		},
		{
			key = "HOSTILE_COL",
			name = "Hostile HP Bar Color",
			description = "Health color for actors that are attacking you.",
			default = util.color.hex("a00004"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "HOSTILE_DAMAGED_COL",
			name = "Hostile+Damaged HP Bar Color",
			description = "Health color at 0 HP for actors that are attacking you.",
			default = util.color.hex("300004"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "NEUTRAL_COL",
			name = "Neutral HP Bar Color",
			description = "Health color for normal actors",
			default = util.color.hex("ccbb00"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "NEUTRAL_DAMAGED_COL",
			name = "Neutral+Damaged HP Bar Color",
			description = "Health color at 0 HP for normal actors.",
			default = util.color.hex("a00004"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "ALLY_COL",
			name = "Allied HP Bar Color",
			description = "Allied Health color",
			default = util.color.hex("1263b0"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "ALLY_DAMAGED_COL",
			name = "Allied+Damaged HP Bar Color",
			description = "Health color at 0 HP for allied actors.",
			default = util.color.hex("1263b0"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "DAMAGE_COL",
			name = "Damage Color",
			description = "'Lag-Bar' color",
			default = util.color.hex("a00004"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "HEAL_COL",
			name = "Healing Color",
			description = "Color of incoming healing",
			default = util.color.hex("3ca01e"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "FATIGUE_COL",
			name = "Fatigue Color",
			description = "Color of the fatigue bar, if enabled",
			default = util.color.hex("cccc00"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
		{
			key = "MAGICKA_COL",
			name = "Magicka Color",
			description = "Color of the magicka bar, if enabled",
			default = util.color.hex("0011ee"),
			renderer = "SuperColorPicker2",
			argument = { presetColors = presetColors },
		},
	},
}

-- Settings Migration from old single-section format
local legacySection = storage.playerSection('SettingsPlayerHPBars')
if legacySection:get("ROW1") ~= nil then
	for _, template in pairs(settingsTemplate) do
		local settingsSection = storage.playerSection(template.key)
		for _, entry in ipairs(template.settings) do
			local legacyValue = legacySection:get(entry.key)
			if legacyValue ~= nil then
				settingsSection:set(entry.key, legacyValue)
			end
		end
	end
	legacySection:reset()
end

-- Initialize all settings as globals
-- Note: RESOURCES setting stored as RESOURCES_SETTING to avoid collision with layout table
local function readAllSettings()
	for _, template in pairs(settingsTemplate) do
		local settingsSection = storage.playerSection(template.key)
		for _, entry in ipairs(template.settings) do
			if entry.key == "RESOURCES" then
				RESOURCES_SETTING = settingsSection:get(entry.key)
			else
				_G[entry.key] = settingsSection:get(entry.key)
			end
		end
	end
end

local previousSettings = {
	ROW1 = storage.playerSection(settingsTemplate["Layout"].key):get("ROW1"),
	ROW2 = storage.playerSection(settingsTemplate["Layout"].key):get("ROW2"),
	ROW3 = storage.playerSection(settingsTemplate["Layout"].key):get("ROW3"),
	ROW4 = storage.playerSection(settingsTemplate["Layout"].key):get("ROW4"),
}


local function verifyRows (changedSetting, option, backwards)
--print(backwards)
	local currentSetting = option or _G[changedSetting]
	if currentSetting == "nothing" then
		return currentSetting
	end
	local options = {"nothing", "Actor Name", "HP", "HP/MaxHP", "Buffs"}
	local occupiedSettings = {}
	for i=1,4 do
		if "ROW"..i ~= changedSetting then
			occupiedSettings[_G["ROW"..i]] = true
		end
	end
	if occupiedSettings["HP"] or occupiedSettings["HP/MaxHP"] then 
		occupiedSettings["HP/MaxHP"] = true
		occupiedSettings["HP"] = true
	end
	local nextSetting = currentSetting
	local infiniteLoop = 0
	while nextSetting == nil or occupiedSettings[nextSetting] and nextSetting ~= "nothing" do
		nextSetting = nextValue(options, nextSetting, backwards)
		--print(nextSetting)
		if changedSetting == "ROW3" and nextSetting == "Buffs" then
			nextSetting = nextValue(options, nextSetting, backwards)
		end
		infiniteLoop = infiniteLoop +1
		if infiniteLoop > 7 then
			return "nothing"
		end
	end
	return nextSetting
end




local function applyRows ()
	NAME = nil
	HP = nil
	HP_MAXHP = nil
	BUFFS = nil
	local fontYOffset = {
		MysticCards = -0.007,
		OpenSans = -0.03,
		Roboto = -0.01,
		BlackOps = -0.04,
		Asul = -0.01,
	}
	local textYOffset = fontYOffset[FONT] or 0
	local borderOffset = BORDER_STYLE == "verythick" and 4 or BORDER_STYLE == "thick" and 3 or BORDER_STYLE == "normal" and 2 or (BORDER_STYLE == "thin" or BORDER_STYLE == "max performance") and 1 or 0
	HPBARS = {
		relativePosition = v2(0.25,0.5+ THICKNESS*0.25),
		position = v2(borderOffset, -borderOffset),
		size = v2(-borderOffset*2,1), -- !! at least 1 pixel width
		anchor = v2(0,1),
	}
	local resourcesHeight = RESOURCES_SETTING == "Stamina + Mana" and 4 or 2
	RESOURCES = {
		relativePosition = v2(0.25,0.5+ THICKNESS*0.25),
		relativeSize = v2(0.5,THICKNESS*0.25),
		--position = v2(0,math.min(resourcesHeight,borderOffset)),
		position = v2(borderOffset, -borderOffset),
		size = v2(-borderOffset*2,-borderOffset*2),
		anchor = v2(0,1),
	}
	BORDERS = {
		relativePosition = v2(0.25,0.5+ THICKNESS*0.25),
		relativeSize  = v2(0.5,THICKNESS*0.25),
		size = v2(0,borderOffset*2+1),
		anchor = v2(0,1),
	}
	LEVELTEXT = {
		position = v2(0,-borderOffset),
		relativePosition = v2(LEVEL_POSITION == "left" and 0.24 or 0.77, 0.5 + THICKNESS*0.125 + textYOffset),
	}
	--local options = {"nothing", "Actor Name", "HP", "HP/MaxHP", "Buffs"}
	local dublicates = {}
	local ROWS = {
		ROW1 = ROW1,
		ROW2 = ROW2,
		ROW3 = ROW3,
		ROW4 = ROW4,
	}
	
	local ROWSETTINGS = {
		ROW1 = {
			relativePosition = v2(0.5, 0.125+ 0),
			position = v2(0,0),
			anchor = v2(0,0),
		},
		ROW2 = {
			relativePosition = v2(0.5, 0.125+ 0.250),
			position = v2(0,0),
			anchor = v2(0,0),
		},
		ROW3 = {
			relativePosition = v2(0.5,0.5+ THICKNESS*0.125),
			position = v2(0,-borderOffset),
			anchor = v2(0,0.5),
		},
		ROW4 = {
			relativePosition = v2(0.5, 0.125+ 0.5+0.25*THICKNESS),
			position = v2(0,borderOffset),
			anchor = v2(0,0),
		},
	}
	local BUFFSETTINGS = {
		ROW1 = {
			relativePosition = v2(0.5, 0),
			position = v2(0,0),
			anchor = v2(0.5,0),
		},
		ROW2 = {
			relativePosition = v2(0.5, 0.5),
			position = v2(0,0),
			anchor = v2(0.5,1),
			BUFFANCHOR = "bottom",
		},
		ROW4 = {
			relativePosition = v2(0.5, 0.25*THICKNESS+ 0.5),
			anchor = v2(0.5,0),
		},
	}
	
	if ROWS.ROW2 == "Buffs" then --buffs above
		--borderOffset = borderOffset *-1
		BORDERS = {
			relativeSize  = v2(0.5,THICKNESS*0.25),
			relativePosition= v2(0.25,0.5),
			size = v2(0,borderOffset*2+1),
		}
		HPBARS = {
			relativePosition = v2(0.25,0.5),
			anchor = v2(0,0),
			position = v2(borderOffset, borderOffset),
			size = v2(-borderOffset*2,1),
		}
		
		RESOURCES.anchor = v2(0,0)
		RESOURCES.relativePosition = v2(0.25,0.5)
		RESOURCES.position = v2(borderOffset, borderOffset)
		RESOURCES.size = v2(-borderOffset*2,1)
		ROWSETTINGS.ROW2.relativePosition = v2(0.5,0.5)
		ROWSETTINGS.ROW2.position = v2(0,0)
		ROWSETTINGS.ROW2.anchor = v2(0,1)
		
		ROWSETTINGS.ROW3.position = v2(0,borderOffset)
		LEVELTEXT = {
			position = v2(0,borderOffset),
			relativePosition = v2(LEVEL_POSITION == "left" and 0.24 or 0.77, 0.5 + THICKNESS*0.125 + textYOffset), --same
		}
	end
	
	for a,b in pairs (ROWS) do
		local s = b
		if s == "HP/MaxHP" then
			s = "HP"
		end
		if dublicates[s] then
			--table.insert(queueSettingsChange,{a,"nothing"})
			--return
		end
		dublicates[s] = true
		if b == "Actor Name" then
			NAME = {relativePosition = ROWSETTINGS[a].relativePosition, position = ROWSETTINGS[a].position}
		elseif b == "HP" then
			local rp = ROWSETTINGS[a].relativePosition
			HP = {relativePosition = v2(rp.x, rp.y + textYOffset), position = ROWSETTINGS[a].position}
		elseif b == "HP/MaxHP" then
			local rp = ROWSETTINGS[a].relativePosition
			HP_MAXHP = {relativePosition = v2(rp.x, rp.y + textYOffset), position = ROWSETTINGS[a].position}
		elseif b == "Buffs" then
			BUFFS = BUFFSETTINGS[a]
		end
	end
end


local updateSettings = function (section, setting)
	-- Update global variable for this setting
	-- Note: RESOURCES stored as RESOURCES_SETTING to avoid collision with layout table
	local settingsSection = storage.playerSection(section)
	if setting == "RESOURCES" then
		RESOURCES_SETTING = settingsSection:get(setting)
	else
		_G[setting] = settingsSection:get(setting)
	end
	
	if setting=="COLOR_PRESET" then
		if COLOR_PRESET == "Y/T/B/R/G  " then
			table.insert(queueSettingsChange,{"HOSTILE_COL",util.color.rgb(204/255,187/255,0)})
			table.insert(queueSettingsChange,{"HOSTILE_DAMAGED_COL",util.color.rgb(204/255,42/255,0)})
			table.insert(queueSettingsChange,{"NEUTRAL_COL",util.color.hex("c5a15e")})
			table.insert(queueSettingsChange,{"NEUTRAL_DAMAGED_COL",util.color.hex("9a5e3a")})
			table.insert(queueSettingsChange,{"ALLY_COL",util.color.hex("1263b0")})
			table.insert(queueSettingsChange,{"ALLY_DAMAGED_COL",util.color.hex("4c6188")})
			table.insert(queueSettingsChange,{"DAMAGE_COL",util.color.hex("a00004")})
			table.insert(queueSettingsChange,{"HEAL_COL",util.color.hex("3ca01e")})
		elseif COLOR_PRESET == "O/T/B/R/G  " then
			table.insert(queueSettingsChange,{"HOSTILE_COL",util.color.hex("b55500")})
			table.insert(queueSettingsChange,{"HOSTILE_DAMAGED_COL",util.color.hex("bb2100")})
			table.insert(queueSettingsChange,{"NEUTRAL_COL",util.color.hex("c5a15e")})
			table.insert(queueSettingsChange,{"NEUTRAL_DAMAGED_COL",util.color.hex("9a5e3a")})
			table.insert(queueSettingsChange,{"ALLY_COL",util.color.hex("1263b0")})
			table.insert(queueSettingsChange,{"ALLY_DAMAGED_COL",util.color.hex("4c6188")})
			table.insert(queueSettingsChange,{"DAMAGE_COL",util.color.hex("a00004")})
			table.insert(queueSettingsChange,{"HEAL_COL",util.color.hex("3ca01e")})
		elseif COLOR_PRESET == "R/T/B/W/G " then
			table.insert(queueSettingsChange,{"HOSTILE_COL",util.color.hex("a00004")})
			table.insert(queueSettingsChange,{"HOSTILE_DAMAGED_COL",util.color.hex("600004")})
			table.insert(queueSettingsChange,{"NEUTRAL_COL",util.color.hex("c5a15e")})
			table.insert(queueSettingsChange,{"NEUTRAL_DAMAGED_COL",util.color.hex("9a5e3a")})
			table.insert(queueSettingsChange,{"ALLY_COL",util.color.hex("1263b0")})
			table.insert(queueSettingsChange,{"ALLY_DAMAGED_COL",util.color.hex("4c6188")})
			table.insert(queueSettingsChange,{"DAMAGE_COL",util.color.hex("AAAAAA")})
			table.insert(queueSettingsChange,{"HEAL_COL",util.color.hex("3ca01e")})
		elseif COLOR_PRESET == "O/Y2/B/W/G" then
			table.insert(queueSettingsChange,{"HOSTILE_COL",util.color.hex("b55500")})
			table.insert(queueSettingsChange,{"HOSTILE_DAMAGED_COL",util.color.hex("a00004")})
			table.insert(queueSettingsChange,{"NEUTRAL_COL",util.color.hex("ccbb00")})
			table.insert(queueSettingsChange,{"NEUTRAL_DAMAGED_COL",util.color.hex("ccbb00")})
			table.insert(queueSettingsChange,{"ALLY_COL",util.color.hex("1263b0")})
			table.insert(queueSettingsChange,{"ALLY_DAMAGED_COL",util.color.hex("4c6188")})
			table.insert(queueSettingsChange,{"DAMAGE_COL",util.color.hex("FFFFFF")})
			table.insert(queueSettingsChange,{"HEAL_COL",util.color.hex("3ca01e")})
		elseif COLOR_PRESET == "O/Y/B/R/G  " then
			table.insert(queueSettingsChange,{"HOSTILE_COL",util.color.hex("b55500")})
			table.insert(queueSettingsChange,{"HOSTILE_DAMAGED_COL",util.color.hex("9a5517")})
			table.insert(queueSettingsChange,{"NEUTRAL_COL",util.color.hex("ccbb00")})
			table.insert(queueSettingsChange,{"NEUTRAL_DAMAGED_COL",util.color.hex("ada11a")})
			table.insert(queueSettingsChange,{"ALLY_COL",util.color.hex("1263b0")})
			table.insert(queueSettingsChange,{"ALLY_DAMAGED_COL",util.color.hex("4c6188")})
			table.insert(queueSettingsChange,{"DAMAGE_COL",util.color.hex("a00004")})
			table.insert(queueSettingsChange,{"HEAL_COL",util.color.hex("3ca01e")})
		elseif COLOR_PRESET == "O/B/R/G    " then
			table.insert(queueSettingsChange,{"HOSTILE_COL",util.color.rgb(204/255,187/255,0)})
			table.insert(queueSettingsChange,{"NEUTRAL_COL",util.color.rgb(204/255,187/255,0)})
			table.insert(queueSettingsChange,{"HOSTILE_DAMAGED_COL",util.color.rgb(204/255,42/255,0)})
			table.insert(queueSettingsChange,{"NEUTRAL_DAMAGED_COL",util.color.rgb(204/255,42/255,0)})
			table.insert(queueSettingsChange,{"ALLY_COL",util.color.rgb(18/255,99/255,176/255)})
			table.insert(queueSettingsChange,{"ALLY_DAMAGED_COL",util.color.rgb(173/255,99/255,100/255)})
			table.insert(queueSettingsChange,{"DAMAGE_COL",util.color.hex("a00004")})
			table.insert(queueSettingsChange,{"HEAL_COL",util.color.hex("3ca01e")})
		end
	elseif setting == "FONT" then
		glyphs,lineHeight = readFont("textures\\FloatingHealthbars_fonts\\"..FONT..".fnt")
		lineXOffset = 0.0
	elseif setting:sub(1,-2) == "ROW" then
		local options = {"nothing", "Actor Name", "HP", "HP/MaxHP", "Buffs"}
		local newSettingIndex = tableFind(options, _G[setting])
		local oldSettingIndex = tableFind(options, previousSettings[setting])
		local backwards = false
		if newSettingIndex < oldSettingIndex and oldSettingIndex - newSettingIndex <2 or newSettingIndex - oldSettingIndex > 2 then
			backwards = true
		end
		local validSetting = verifyRows (setting, nil, backwards) 
		if validSetting ~= _G[setting] then
			table.insert(queueSettingsChange,{setting,validSetting})
		end
		previousSettings = {
			ROW1 = ROW1,
			ROW2 = ROW2,
			ROW3 = ROW3,
			ROW4 = ROW4,
		}
	end
	
	for a,c in pairs(barCache) do
		if c.bar then
			c.bar:destroy()
		end
		c.bar = nil
		c.cachedHealth = types.Actor.stats.dynamic.health(c.actor).current
		c.cachedLerpHealth = c.lerpHealth
		c.allyCache = nil
		c.cachedHealthLag = c.healthLag
		c.cachedIncomingHealing = 0
		c.cachedBorderAlpha = 0.5
		c.textVisible = true
		c.lastBuffUpdate = core.getRealTime()
		c.hasBuffs = true
	end
	applyRows()
end


-- Register all setting groups
for _, template in pairs(settingsTemplate) do
	I.Settings.registerGroup(template)
end

local settingsKeyToSection = {}
for _, template in pairs(settingsTemplate) do
	for _, entry in pairs(template.settings) do
		settingsKeyToSection[entry.key] = template.key
	end
end

function setSetting(key, value)
	local sectionKey = settingsKeyToSection[key]
	if sectionKey then
		storage.playerSection(sectionKey):set(key, value)
	end
end


I.Settings.registerPage {
    key = "HPBars",
    l10n = "HPBars",
    name = 'Floating Healthbars',
    description = 'Floating Healthbars'
}

-- Initialize all settings as globals on load
readAllSettings()

-- Subscribe to all settings groups
for _, template in pairs(settingsTemplate) do
	local settingsSection = storage.playerSection(template.key)
	settingsSection:subscribe(async:callback(function(_, setting)
		updateSettings(template.key, setting)
	end))
end



return {updateSettings, applyRows, readAllSettings, settingsTemplate}