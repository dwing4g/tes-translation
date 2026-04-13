local tempKey
local orderCounter = 0
local function getOrder()
	orderCounter = orderCounter + 1
	return orderCounter
end

local settingsTemplate = {}
local presetColors = {
    "c83c1e", --HEALTH_COL red
    "9b050a", --HEALTHLAG_COL red dark
    "3ca01e", -- HEALING_COL green
    "00963c", -- FATIGUE_COL green
    "f3ed16", -- FATIGUELAG_COL yellow
    "35459f", -- MAGICKA_COL blue
    "5a0f8c", -- MAGICKALAG_COL purple

-- vanilla colors:
    "caa560", -- fontColor_color_normal
    "d4b77f", -- goldenMix
    "dfc99f", -- FontColor_color_normal_over
    "eee2c9", -- lightText
    "253170", -- fontColor_color_journal_link
    "3a4daf", -- fontColor_color_journal_link_over
    "707ecf", -- fontColor_color_journal_link_pressed
}


local colorRenderer =  "SuperColorPicker2"

tempKey = "General"
settingsTemplate[tempKey] = {
    key = 'Settings'..MODNAME..tempKey,
	page = MODNAME,
	l10n = MODNAME,
	name = tempKey.."                                             ", -- lol
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "LAGBAR",
			renderer = "checkbox",
			name = "Damage-Bar",
			description = "Visualizes recently lost resources",
			default = true,
		},
		{
			key = "HEALBAR",
			renderer = "checkbox",
			name = "Healbar",
			description = "Visualizes incoming healing",
			default = true,
		},
		{
			key = "PERFORMANCE_MODE",
			renderer = "checkbox",
			name = "Performance mode",
			description = "For low end systems or when you have a very high framerate anyway\nOnly updates one resource per frame",
			default = true,
		},
		{
			key = "POSITION",
			name = "Position",
			description = "you can drag them around if they are not locked",
			default = "Bottom Left", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = MODNAME, 
				items = {"Bottom Left", "Top Left"},
			},
		},
		{
			key = "LOCKED",
			renderer = "checkbox",
			name = "Position locked",
			description = "Lock bar position\nMakes bars click-through\nThis will also hide bars during loading screens",
			default = true,
		},
	},
}


tempKey = "Size"
settingsTemplate[tempKey] = {
    key = 'Settings'..MODNAME..tempKey,
	page = MODNAME,
	l10n = MODNAME,
	name = tempKey.."                                             ", -- lol
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "THICKNESS",
			name = "Thickness",
			description = "You can use the mousewheel when dragging them around\n(if they are not locked)",
			renderer = "number",
			default = 12,
			argument = {
				min = 1,
				max = 1000,
			},
		},
		{
			key = "SPACING",
			name = "Spacing",
			description = "Gap between the bars, in pixels",
			renderer = "number",
			default = 3,
			argument = {
				min = 0,
				max = 1000,
			},
		},
		{
			key = "LENGTH_MULT",
			name = "Bar length Multiplier",
			description = "",
			renderer = "number",
			default = 0.9,
			integer = false,
			argument = {
				min = 0.01,
				max = 1000,
				integer = false,
			},
		},
		{
			key = "MAX_LENGTH",
			name = "Max Length",
			description = "Squishes the bars if one exceeds this length",
			renderer = "number",
			default = 3800,
			argument = {
				min = 0.01,
				max = 9999,
			},
		},
		{
			key = "LENGTH_EQUALIZER",
			name = "Bar length Equalizer (0-1)",
			description = "",
			renderer = "number",
			default = 0,
			argument = {
				min = 0,
				max = 1,
			},
		},
	},
}

tempKey = "Appearance"
settingsTemplate[tempKey] = {
    key = 'Settings'..MODNAME..tempKey,
	page = MODNAME,
	l10n = MODNAME,
	name = tempKey.."                                             ", -- lol
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "SHOW_ICONS",
			renderer = "checkbox",
			name = "Show Icons",
			description = "Show colored stat icons to the left of each bar",
			default = false,
		},
		{
			key = "TEXT",
			name = "Text",
			description = "Show numbers on the bars",
			default = "current", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = MODNAME, 
				items = {"hidden", "current", "current/max"},
			},
		},
		{
			key = "TEXT_POS",
			name = "Text Position",
			description = "If the text isn't left, it will get colored when the bar flashes",
			default = "right outside", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = MODNAME, 
				items = {"left", "right", "right outside"}--,"stylized 1", "stylized 2", "stylized 3", "stylized 4"},
			},
		},
		{
			key = "BORDER_STYLE",
			name = "Border style",
			description = "",
			default = "thin", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = MODNAME, 
				items = {"none", "thin", "normal", "thick", "verythick"}--,"stylized 1", "stylized 2", "stylized 3", "stylized 4"},
			},
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
			description = "For how long the damage bar will indicate recently lost resources",
			default = 0.7, 
			min = 0.1,
			renderer = "number",
		},
		{
			key = "HEALTH_FLASHING_THRESHOLD",
			name = "Health Flashing Threshold",
			description = "in percent",
			default = 0.35, 
			argument = {
				min = 0,
				max = 1,
			},
			renderer = "number",
		},
		{
			key = "FATIGUE_FLASHING_THRESHOLD",
			name = "Fatigue Flashing Threshold",
			description = "in percent",
			default = 0.15, 
			argument = {
				min = 0,
				max = 1,
			},
			renderer = "number",
		},
		{
			key = "MAGICKA_FLASHING_THRESHOLD",
			name = "Magicka Flashing Threshold",
			description = "in percent",
			default = 0.25, 
			argument = {
				min = 0,
				max = 1,
			},
			renderer = "number",
		},
	},
}

tempKey = "Colors"
settingsTemplate[tempKey] = {
    key = 'Settings'..MODNAME..tempKey,
	page = MODNAME,
	l10n = MODNAME,
	name = tempKey.."                                             ", -- lol
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "HEALTH_COL",
			name = "Health Color",
			description = "",
			disabled = false,
			default =  util.color.hex("c83c1e"), --red
			--default =  util.color.hex("a00004"), --red
			--default =  util.color.hex("b7b7b7"), --white
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		},
		{
			key = "HEALTHLAG_COL",
			name = "Health Damage Color",
			description = "Color of recently lost health",
			disabled = false,
			default =  util.color.hex("9b050a"), --red
			--default =  util.color.hex("a00004"), --red
			--default =  util.color.hex("b7b7b7"), --white
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		},
		{
			key = "HEALING_COL",
			name = "Healing Color",
			description = "Color of incoming healing",
			disabled = false,
			default = util.color.hex("3ca01e"), --green
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		},
		{
			key = "FATIGUE_COL",
			name = "Fatigue Color",
			description = "",
			disabled = false,
			default = util.color.hex("00963c"), --green
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		},
		{
			key = "FATIGUELAG_COL",
			name = "Fatigue Damage Color",
			description = "Color of recently lost fatigue",
			disabled = false,
			default = util.color.hex("f3ed16"), --yellow
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		},
		{
			key = "MAGICKA_COL",
			name = "Magicka Color",
			description = "",
			disabled = false,
			default = util.color.hex("35459f"), --blue
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		},
		{
			key = "MAGICKALAG_COL",
			name = "Magicka Damage Color",
			description = "Color of recently lost magicka",
			disabled = false,
			default = util.color.hex("5a0f8c"), --purple
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		}
	},
}

-- Settings Migration
local legacySection = storage.playerSection('SettingsPlayer'..MODNAME)
if legacySection:get("TEXT") then
	for id, template in pairs(settingsTemplate) do
		local settingsSection = storage.playerSection(template.key)
		for i, entry in pairs(template.settings) do
			settingsSection:set(entry.key, legacySection:get(entry.key) or entry.default)
		end
	end
	legacySection:reset()
end

for id, template in pairs(settingsTemplate) do
	
	I.Settings.registerGroup(template)
end


I.Settings.registerPage {
    key = MODNAME,
    l10n = MODNAME,
    name = MODNAME,
    description = MODNAME
}

-- called on init and when settings change
local function readAllSettings()
	for _, template in pairs(settingsTemplate) do
		local settingsSection = storage.playerSection(template.key)
		for i, entry in pairs(template.settings) do
			local value = settingsSection:get(entry.key)
			if value == nil then
				value = entry.default
			end
			_G[entry.key] = value
		end
	end
end

readAllSettings()
for _, template in pairs(settingsTemplate) do
	local sectionName = template.key
	local settingsSection = storage.playerSection(template.key)
	settingsSection:subscribe(async:callback(function (_,setting)
		local oldValue = _G[setting]
		_G[setting] = settingsSection:get(setting)
		--print(setting.." changed to "..settingsSection:get(setting))
		--readAllSettings()
		if setting == "POSITION" then
			saveData.windowPos = nil
		end
		calculateBarPositions()
		if container and (setting == "THICKNESS" or setting == "SPACING") then
			calculateBarPositions() -- barThickness, verticalOffset
			local pos =  POSITION == "Bottom Left" and 0 or (4-#widgets) * verticalOffset - barThickness
	
			container.layout.props.size = v2(-startOffset,3*verticalOffset)
			container:update()
			
			for _,resource in pairs(widgets) do
				local bar = _G[resource]
				bar.barContainer.layout.props.size = v2(0,barThickness)
				bar.barContainer.layout.props.position = v2(0,-pos)
				bar.barContainer:update()
				if bar.textProps then
					bar.textProps.textSize = barThickness+math.floor(barThickness/6)
				end
				pos = pos+verticalOffset
			end
			updateAll = true
			for _,resource in pairs(widgets) do
				update(_G[resource], resource, 0, resource == "fatigue" and 1 or 0)
			end
			updateAll = false
			return
		end
		
		
		--readAllSettings()
		
		if container then
			container:destroy()
		end
		container = nil
	end))
end