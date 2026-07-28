local function getColorFromGameSettings(colorTag)
    local result = core.getGMST(colorTag)
	if not result then
		return util.color.rgb(1,1,1)
	end
    local rgb = {}
    for color in string.gmatch(result, '(%d+)') do
        table.insert(rgb, tonumber(color))
    end
    if #rgb ~= 3 then
        print("UNEXPECTED COLOR: rgb of size=", #rgb)
        return util.color.rgb(1, 1, 1)
    end
    return util.color.rgb(rgb[1] / 255, rgb[2] / 255, rgb[3] / 255)
end
-- Settings Migration
local legacySection = storage.playerSection('SettingsPlayer'..MODNAME)
if legacySection:get("FOOTER_HINTS") ==  "F / R" then
	legacySection:set("FOOTER_HINTS", "Symbolic")
end
local hasInventoryExtender = core.contentFiles.has("InventoryExtender.omwscripts") or I.InventoryExtender

local tempKey
local orderCounter = 0
local function getOrder()
	orderCounter = orderCounter + 1
	return orderCounter
end

local function boolDefault(value, default)
	if value == nil then return default end
	return value
end

local settingsTemplate = {}

local numberRenderer = "SuperSlider6"
local colorRenderer = "SuperColorPicker4"
local inputRenderer = "SuperKeybind2"
local optionalSelectRenderer = "OptionalSelectRenderer1"
local optionalCheckboxRenderer = "OptionalCheckboxRenderer1"

local presetColors = {
	"caa560", -- fontColor_color_normal
	"d4b77f", -- goldenMix
	"dfc99f", -- FontColor_color_normal_over
	"eee2c9", -- lightText
	"253170", -- fontColor_color_journal_link
	"3a4daf", -- fontColor_color_journal_link_over
	"707ecf", -- fontColor_color_journal_link_pressed
}


tempKey = "General"
settingsTemplate[tempKey] = {
    key = 'SettingsPlayer'..MODNAME..tempKey,
    page = MODNAME,
    l10n = "QuickLoot",
    name = tempKey.."                                                    ", -- "select" renderer fix
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "ENABLED",
			name = "Enabled",
			description = "Allows disabling the mod entirely",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("ENABLED"), true),
		},
		{
			key = "CONTAINER_ANIMATION",
			name = "Container Animation",
			description = "For 'Animated Containers' \nCan make looting stuff on top of containers more difficult\nIf it doesn't work, your OpenMW version might not be recent enough",
			default = legacySection:get("CONTAINER_ANIMATION") or "immediately", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"off", "immediately", "on take", "disabled by shift"},
			},
		},
		{
			key = "PICKPOCKETING",
			name = "Enable Pickpocketing",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("PICKPOCKETING"), true)
		},
		{
			key = "LOOSE_AIMING",
			name = "Loose Aiming",
			description = "Detects targets slightly off-center so you don't have to aim exactly\nboundingbox: one physics ray, hits collision boxes (cheap)\nshotgun: a spread of view rays, catches more but costs more",
			default = "boundingbox",
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot",
				items = {"off", "boundingbox", "shotgun"},
			},
		},
		{
			key = "PICKPOCKET_TIME_SCALE",
			name = "Time Speed While Pickpocketing",
			description = "Slows the whole game while the pickpocketing\n1 = normal speed, 0.5 = half speed",
			renderer = numberRenderer,
			default = legacySection:get("PICKPOCKET_TIME_SCALE") or 0.5,
			argument = {
				min = 0.1,
				max = 1,
				step = 0.05,
				default = legacySection:get("PICKPOCKET_TIME_SCALE") or 0.5,
				showDefaultMark = true,
				width = 160,
			},
		},
	},
}

tempKey = "UI"
settingsTemplate[tempKey] = {
    key = 'SettingsPlayer'..MODNAME..tempKey,
    page = MODNAME,
    l10n = "QuickLoot",
    name = tempKey,
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "WIDTH",
			name = "Width (%)",
			--description = "of the ui element (1-100)",
			renderer = numberRenderer,
			default = legacySection:get("WIDTH") or 23,
			argument = {
				min = 1,
				max = 100,
				step = 1,
				default = legacySection:get("WIDTH") or 23,
				showDefaultMark = true,
				width = 160,
			},
		},
		{
            key = "HEIGHT",
            name = "Height (%)",
           -- description = "of the ui element (1-100)",
            renderer = numberRenderer,
            default = legacySection:get("HEIGHT") or 35,
            argument = {
                min = 1,
                max = 100,
                step = 1,
				default = legacySection:get("HEIGHT") or 35,
                showDefaultMark = true,
                --showResetButton = true,
                --minLabel = "Small",
                --maxLabel = "Large",
				width = 160,
            },
        },
		{
			key = "X",
			name = "X Position (%)",
			--description = "Location of the center (1-100)",
			renderer = numberRenderer,
			default = legacySection:get("X") or 71,
			argument = {
				min = 1,
				max = 100,
				step = 1,
				default = legacySection:get("X") or 71,
				showDefaultMark = true,
				width = 160,
			},
		},
		{
			key = "Y",
			name = "Y Position (%)",
			--description = "Location of the center (1-100)",
			renderer = numberRenderer,
			default = legacySection:get("Y") or 50,
			argument = {
				min = 1,
				max = 100,
				step = 1,
				default = legacySection:get("Y") or 50,
				showDefaultMark = true,
				width = 160,
			},
		},
		{
			key = "TEXTSIZEMULT",
			name = "Text Size Multiplier (%)",
			--description = "1-200",
			renderer = numberRenderer,
			default = legacySection:get("textSizeMult") or 93,
			argument = {
				min = 1,
				max = 200,
				step = 1,
				default = legacySection:get("textSizeMult") or 93,
				showDefaultMark = true,
				width = 160,
			},
		},
		{
			key = "HEADER_FOOTER",
			name = "List Header/Footer",
			description = "Show list header/footer",
			default = legacySection:get("HEADER_FOOTER") or "show both", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"hide both", "show both", "all top", "all bottom", "only top", "only bottom"},
			},
		},
		{
			key = "FOOTER_HINTS",
			name = "Keybinding Hints",
			description = "Shows the keybinding hints for 'Take All' and 'Search'",
			default = legacySection:get("FOOTER_HINTS") or "Symbolic", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"Disabled", "Symbolic", "Keys"},
			},
		},
		{
			key = "BORDER_STYLE",
			name = "Border Style",
			description = "",
			default = legacySection:get("BORDER_STYLE") or "thin", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"none", "thin", "normal", "thick", "verythick"}--,"stylized 1", "stylized 2", "stylized 3", "stylized 4"},
			},
		},
		{
			key = "BORDER_FIX",
			name = "Border Fix",
			description = "Use vanilla borders, so the equipped indicator doesnt turn invisible",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("BORDER_FIX"), true)
		},
		{
			key = "FONT_TINT",
			name = "Font Color",
			description = "",
			disabled = false,
			default = legacySection:get("FONT_TINT") or getColorFromGameSettings("FontColor_color_normal"), --green
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		},
		{
			key = "ICON_TINT",
			name = "Icon Tint",
			description = "",
			disabled = false,
			default = legacySection:get("ICON_TINT") or getColorFromGameSettings("FontColor_color_normal_over"), --green
			renderer = colorRenderer,
			argument = {presetColors = presetColors},
		},
		{
			key = "HAND_SYMBOL",
			name = "Stealing Hand Symbol",
			description = "Enable the pink hand next to the red text when the container belongs to someone",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("HAND_SYMBOL"), true)
		},
		{
			key = "TRANSPARENCY",
			name = "Transparency",
			description = "",
			renderer = numberRenderer,
			default = legacySection:get("TRANSPARENCY") or 0.7,
			argument = {
				min = 0,
				max = 1,
				step = 0.05,
				default = legacySection:get("TRANSPARENCY") or 0.7,
				showDefaultMark = true,
				width = 160,
			},
		},
		{
			key = "FONT_FIX",
			name = "Fix buggy font",
			description = "If you see boxes or questionmarks where there should be numbers, enable this setting to disable reliance on the included font",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("FONT_FIX"), true)
		},
		{
			key = "THOUSANDS_SEPARATOR",
			name = "Thousands separator",
			description = "Sits between the thousands and the hundreds of a large number\nThe narrow one is a hair space and needs a font that has it",
			renderer = "select",
			default = "",
			argument = {
				disabled = false,
				l10n = "QuickLoot",
				items = {"", string.char(0xE2,0x80,0x8A,0xE2,0x80,0x8A), " ", "'", ",", "."},
			},
		},
	},
}

tempKey = "Sorting"
settingsTemplate[tempKey] = {
    key = 'SettingsPlayer'..MODNAME..tempKey,
    page = MODNAME,
    l10n = "QuickLoot",
    name = tempKey,
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "CONTAINER_SORTING_STATS",
			name = "Item Sorting by Value / Weight",
			description = "Changes the order of icons in containers",
			default = legacySection:get("CONTAINER_SORTING_STATS") or "Best V/W", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"Vanilla", "Lowest Weight", "Highest Value", "Best V/W"},
			},
		},
		{
			key = "GROUP_JUMP",
			name = "Shift + Scroll Jumps Groups",
			description = "Shift and the wheel (or the up/down keys) land on the first entry of the next group\nLeave it off if your sneak key is Shift",
			renderer = "checkbox",
			default = false,
		},
		{
			key = "CONTAINER_SORTING_POISONS",
			name = "Sorting: Poisons On Top",
			description = "Only while planting items on someone\nRequires the Pickpocket Overhaul addon",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("CONTAINER_SORTING_POISONS"), true),
			argument = {
				disabled = not qlppInstalled,
			},
		},
		{
			key = "CONTAINER_SORTING_QUEST",
			name = "Sorting: Quest Items On Top",
			description = "Let me know if you find any that got falsely flagged as quest",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("CONTAINER_SORTING_QUEST"), true)
		},
		{
			key = "CONTAINER_SORTING_CASH",
			name = "Sorting: Cash On Top",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("CONTAINER_SORTING_CASH"), true)
		},
		{
			key = "CONTAINER_SORTING_KEYS",
			name = "Sorting: Keys On Top",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("CONTAINER_SORTING_KEYS"), true)
		},
		{
			key = "CONTAINER_SORTING_LOCKPICKS",
			name = "Sorting: Lockpicks On Top",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("CONTAINER_SORTING_LOCKPICKS"), true)
		},
		{
			key = "CONTAINER_SORTING_SOULGEMS",
			name = "Sorting: Soulgems On Top",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("CONTAINER_SORTING_SOULGEMS"), true)
		},
		{
			key = "CONTAINER_SORTING_INGREDIENTS",
			name = "Sorting: Ingredients Below [x] Weight On Top",
			description = "0 = Disable",
			renderer = "number",
			default = legacySection:get("CONTAINER_SORTING_INGREDIENTS") or 1.5,
			argument = {
				min = 0,
				max = 200,
			},
		},
		{
			key = "CONTAINER_SORTING_REPAIR",
			name = "Sorting: Repair Tools On Top",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("CONTAINER_SORTING_REPAIR"), true)
		},
	},
}

tempKey = "Keybindings"
settingsTemplate[tempKey] = {
    key = 'SettingsPlayer'..MODNAME..tempKey,
    page = MODNAME,
    l10n = "QuickLoot",
    name = tempKey,
	description = "custom keybindings are highly experimental, do not expect support if something's odd.\nA single bound key already alters the behaviour of the mod.",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "TAKE_KEY",
			name = "Take Key",
			description = "Take the currently selected entry",
			renderer = inputRenderer,
			default = nil,
			argument = {},
		},
		{
			key = "TAKE_ALL_KEY",
			name = "Take All Key",
			description = "Take all the items",
			renderer = inputRenderer,
			default = nil,
			argument = {},
		},
		{
			key = "ALT_KEY",
			name = "Secondary Key",
			description = "By default, switches between take and give",
			renderer = inputRenderer,
			default = nil,
			argument = {},
		},
		{
			key = "UP_KEY",
			name = "Up Key",
			description = "Move up 1 entry",
			renderer = inputRenderer,
			default = nil,
			argument = {},
		},
		{
			key = "DOWN_KEY",
			name = "Down Key",
			description = "Move down 1 entry",
			renderer = inputRenderer,
			default = nil,
			argument = {},
		},
	},
}

tempKey = "Columns"
settingsTemplate[tempKey] = {
    key = 'SettingsPlayer'..MODNAME..tempKey,
    page = MODNAME,
    l10n = "QuickLoot",
    name = tempKey,
	permanentStorage = true,
	order = getOrder(),
	settings = {
				{
			key = "COLUMN_PICKPOCKET",
			name = "Show Pickpocket Column",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("COLUMN_PICKPOCKET"), true)
		},
		{
			key = "COLUMN_WEIGHT",
			name = "Show Weight Column",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("COLUMN_WEIGHT"), true)
		},
		{
			key = "COLUMN_WEIGHT_PICKPOCKETING",
			name = "Show Weight Column When Pickpocketing",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("COLUMN_WEIGHT_PICKPOCKETING"), true)
		},
		{
			key = "COLUMN_VALUE",
			name = "Show Value Column",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("COLUMN_VALUE"), true)
		},
		{
			key = "COLUMN_VALUE_PICKPOCKETING",
			name = "Show Value Column When Pickpocketing",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("COLUMN_VALUE_PICKPOCKETING"), true)
		},
		{
			key = "COLUMN_WV",
			name = "Show V/W Column",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("COLUMN_WV"), true)
		},
		{
			key = "COLUMN_WV_PICKPOCKETING",
			name = "Show V/W Column When Pickpocketing",
			description = "",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("COLUMN_WV_PICKPOCKETING"), false)
		},
	},
}

tempKey = "Tooltip"
settingsTemplate[tempKey] = {
    key = 'SettingsPlayer'..MODNAME..tempKey,
    page = MODNAME,
    l10n = "QuickLoot",
    name = tempKey,
	description = "Unchecked settings fall back to the shared tooltip style, editable on the new Tooltip settings page",
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "TOOLTIPS_MODE",
			name = "Tooltip position",
			description = "",
			default = legacySection:get("TOOLTIP_MODE") or "left", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"off", "left","left (fixed)", "left (fixed 2)", "left (fixed 3)", "right", "right (fixed)", "right (fixed 2)", "right (fixed 3)", "crosshair", "bottom", "top"}--,"stylized 1", "stylized 2", "stylized 3", "stylized 4"},
			},
		},
		{
			key = "TOOLTIPS_MATCH_HUD",
			name = "Match the loot window",
			description = "Draw the tooltip with the transparency, border and text size of the loot window instead of the shared tooltip ones",
			renderer = "checkbox",
			default = false,
		},
		{
			key = "TOOLTIPS_TEXT_ALIGNMENT",
			name = "Tooltip text alignment",
			description = "",
			default = {
				enabled = false,
				value = "center",
			},
			renderer = optionalSelectRenderer,
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"center", "left", "right"}--,"stylized 1", "stylized 2", "stylized 3", "stylized 4"},
			},
		},
		{
			key = "TOOLTIPS_SHORT_TEXT",
			name = "Shorter tooltip texts",
			description = "Shortens effect texts",
			renderer = optionalCheckboxRenderer,
			default = {
				enabled = false,
				value = true,
			},
		},
		{
			key = "TOOLTIPS_COMPACT",
			name = "Compact weight and value",
			description = "Show weight and value as one line",
			renderer = optionalCheckboxRenderer,
			default = {
				enabled = false,
				value = true,
			},
		},
	},
}

tempKey = "Misc"
settingsTemplate[tempKey] = {
    key = 'SettingsPlayer'..MODNAME..tempKey,
    page = MODNAME,
    l10n = "QuickLoot",
    name = tempKey,
	permanentStorage = true,
	order = getOrder(),
	settings = {
		{
			key = "READ_BOOKS",
			name = "Show read books",
			description = "Bookworm will highlight books that you have actually read (for 20 seconds)",
			default = legacySection:get("READ_BOOKS") or "read", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"off", "unread", "read", "bookworm", "bookworm unread"}--,"stylized 1", "stylized 2", "stylized 3", "stylized 4"},
			},
		},
		{
			key = "DISPOSE_CORPSE",
			name = "Dispose corpse Key",
			description = "",
			default = legacySection:get("DISPOSE_CORPSE") or "Shift + F", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"disabled", "Shift + F", "Jump"}--,"stylized 1", "stylized 2", "stylized 3", "stylized 4"},
			},
		},
		{
			key = "EXPERIMENTAL_LOOTING",
			name = "Experimental looting workaround",
			description = "If you have some ammo mod that keeps deleting your ammo for some reason",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("EXPERIMENTAL_LOOTING"), false)
			
		},
		{
			key = "LOOT_DURING_DEATH_ANIMATION",
			name = "can loot during death animation",
			description = "The engine only runs on-death scripts once the animation stops, looting before that can hand you equipment a mod was about to strip from the corpse\noff: wait for the animation to end\nnear the end: open at 55% of the animation\nimmediately: open the moment it dies",
			default = "off",
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot",
				items = {"off", "near the end", "immediately"},
			},
		},
		{
			key = "PROBE_SCRIPTS",
			name = "Probe scripted containers",
			description = "Run a container's mwscript by activating it on inspection; if it allows the activation, the quickloot hud opens. Disabled: quickloot ignores these containers and the activate key handles them normally",
			renderer = "checkbox",
			default = boolDefault(legacySection:get("PROBE_SCRIPTS"), true)
		},
		{
			key = "PROBE_CACHE",
			name = "Trust a probe for (seconds)",
			description = "How long a successful probe of the container's mwscript stays valid\n0 re-runs the script every time\nblocked containers always re-check after a few seconds",
			renderer = numberRenderer,
			default = 0,
			argument = {
				min = 0,
				max = 900,
				step = 15,
				default = 0,
				showDefaultMark = true,
				width = 160,
			},
		},
		{
			key = "R_DEPOSIT2",
			name = "R switches to deposit",
			description = "Instead of opening the inventory, switch between deposit and withdraw with the ToggleSpell key\nShift + R always does the other thing",
			renderer = "select",
			default = "Yes",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"Yes", "No", "Only when pickpocketing"}
			},
		},
		{
			key = "SELECTIVE_DEPOSIT",
			name = "Shift + Deposit All Mode",
			description = "What to deposit when pressing shift+F in deposit mode\nIt always ignores equipped items",
			default = legacySection:get("SELECTIVE_DEPOSIT") or "ingredients", 
			renderer = "select",
			argument = {
				disabled = false,
				l10n = "QuickLoot", 
				items = {"ingredients", "restack"},
			},
		},
	},
}

legacySection:reset()


I.Settings.registerPage {
    key = MODNAME,
    l10n = "QuickLoot",
    name = "QuickLoot",
    description = "If you're aiming at a container, a preview will appear as soon as you change a setting"
}


for id, template in pairs(settingsTemplate) do
	I.Settings.registerGroup(template)
end

function readAllSettings()
	for _, template in pairs(settingsTemplate) do
		local settingsSection = storage.playerSection(template.key)
		for i, entry in pairs(template.settings) do
			local value = settingsSection:get(entry.key)
			-- optional wrappers resolve to nil while unchecked
			if type(value) == "userdata" and value.enabled ~= nil and value.value ~= nil then
				if value.enabled then
					value = value.value
				else
					value = nil
				end
			end
			_G[entry.key] = value
		end
	end
end

readAllSettings()


-- ────────────────────────────────────────────────────────────────────────── Settings Event ──────────────────────────────────────────────────────────────────────────

for _, template in pairs(settingsTemplate) do
	local sectionName = template.key
	local settingsSection = storage.playerSection(template.key)
	settingsSection:subscribe(async:callback(function (_,setting)
		local oldValue = _G[setting]
		readAllSettings()
		showInMainMenuOverride = true
		uiLoc = v2(X/100,Y/100)
		uiSize = v2(WIDTH/100,HEIGHT/100)
		closeHud()
		--core.sendGlobalEvent("OwnlysQuickLoot_playerToggledMod",{self,ENABLED})
		updateModEnabled()
		quickLootText = {
			props = {
				textColor = FONT_TINT,--util.color.rgba(1, 1, 1, 1),
				textShadow = true,
				textShadowColor = util.color.rgba(0,0,0,0.75),
				--textAlignV = ui.ALIGNMENT.Center,
				--textAlignH = ui.ALIGNMENT.Center,
			}
		}
		makeBorder = require("scripts.OwnlysQuickLoot.ql_makeborder")
		textSizeMult = (ui.screenSize().y/1200*(uiSize.y/0.4))^0.5*TEXTSIZEMULT/100
	end))
end