-- ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
-- │ * $root                                                                                                                                                                                                                                                                    │
-- │ (Container, createLayout return, caller sets layer + position, borderTemplate carries the frame and the padding setting, no wrapper flexes, boxes are real containers, when: is the condition, side by side is real adjacency)                                             │
-- │ tpl: borderTemplate                                                                                                                                                                                                                                                        │
-- │ ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐ │
-- │ │ "tooltipFlex"                                                                                                                                                                                                                                                          │ │
-- │ │ (Flex, vertical, autoSize, arrange = style.align (textAlignment setting))                                                                                                                                                                                              │ │
-- │ │ - "name" (Text, always)  text=item name (+count) (+soul unless the soul line shows)                                                                                                                                                                                    │ │
-- │ │ - "nameSpacer" 0x1                                                                                                                                                                                                                                                     │ │
-- │ │ - "uses" (Text, when: lockpick, probe, repair)                                                                                                                                                                                                                         │ │
-- │ │ - "quality" (Text, when: lockpick, probe, repair)                                                                                                                                                                                                                      │ │
-- │ │ - "armorClass" (Text, when: armor + compact)                                                                                                                                                                                                                           │ │
-- │ │ - "armorRating" (Text, when: armor)                                                                                                                                                                                                                                    │ │
-- │ │ - "weaponType" (Text, when: weapon)                                                                                                                                                                                                                                    │ │
-- │ │ - "attack" (Text, when: weapon, marksman)                                                                                                                                                                                                                              │ │
-- │ │ - "chop" "slash" "thrust" (Text, when: weapon, melee)                                                                                                                                                                                                                  │ │
-- │ │ - "condition" (Text, when: weapon/armor + durabilityDisplay vanilla or colored, colored tints the current value)                                                                                                                                                       │ │
-- │ │ - "conditionBarTopSpacer" 0x1 (when: durabilityDisplay bar)                                                                                                                                                                                                            │ │
-- │ │ ┌──────────────────────────────────────────────────────────────────────────────┐                                                                                                                                                                                       │ │
-- │ │ │ "conditionBar"                                                               │                                                                                                                                                                                       │ │
-- │ │ │ (Flex, when: weapon/armor + durabilityDisplay bar, bar row via makeBarRow)   │                                                                                                                                                                                       │ │
-- │ │ │ ["label" (barLabels)] ["spacer"] ["bar" like "charge"'s] ["rightSpacer" 5x0] │                                                                                                                                                                                       │ │
-- │ │ └──────────────────────────────────────────────────────────────────────────────┘                                                                                                                                                                                       │ │
-- │ │ - "conditionBarBottomSpacer" 0x1 (when: durabilityDisplay bar)                                                                                                                                                                                                         │ │
-- │ │ - "enchantCapacity" (Text, when: setting on + unenchanted)                                                                                                                                                                                                             │ │
-- │ │ - "range" (Text, when: weapon + setting, off by default)                                                                                                                                                                                                               │ │
-- │ │ - "speed" (Text, when: weapon + setting, off by default)                                                                                                                                                                                                               │ │
-- │ │ - "soul" (Text, when: filled soulgem + full mode + soulValue setting, creature name (soul value))                                                                                                                                                                      │ │
-- │ │ - "weight" (Text, when: full mode, armor class name appended)                                                                                                                                                                                                          │ │
-- │ │ - "value" (Text, when: full mode)                                                                                                                                                                                                                                      │ │
-- │ │ - "qualityMult" (Text, when: override, crafting quality percent, red below 1)                                                                                                                                                                                          │ │
-- │ │ - "anchorStats" 0x0 (mod anchor after the stat lines)                                                                                                                                                                                                                  │ │
-- │ │ - "conditionBarTopSpacer" 0x1 (when: durabilityDisplay bar (above enchantments))                                                                                                                                                                                       │ │
-- │ │ ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐                                                                                                                                 │ │
-- │ │ │ "conditionBar"                                                                                                                     │                                                                                                                                 │ │
-- │ │ │ (Flex, when: weapon/armor + durabilityDisplay bar (above enchantments), right above the enchantment block, bar row via makeBarRow) │                                                                                                                                 │ │
-- │ │ │ ["label" (barLabels)] ["spacer"] ["bar" like "charge"'s] ["rightSpacer" 5x0]                                                       │                                                                                                                                 │ │
-- │ │ └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘                                                                                                                                 │ │
-- │ │ - "conditionBarBottomSpacer" 0x1 (when: durabilityDisplay bar (above enchantments))                                                                                                                                                                                    │ │
-- │ │ - "enchantType" (Text, when: enchanted, enchantBlockColor)  text=Cast When Used ...                                                                                                                                                                                    │ │
-- │ │ ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐                                                                             │ │
-- │ │ │ "enchantEffects"                                                                                                                                                                       │                                                                             │ │
-- │ │ │ (Flex, when: enchanted, vertical group via addEffectGroup, alignedEffects flushes the rows, else each row follows the tooltip alignment, mods re-render: clear content + printEffects) │                                                                             │ │
-- │ │ │ ┌─────────────────────────────────────────────────────────────┐                                                                                                                        │                                                                             │ │
-- │ │ │ │ "enchantEffects1..N"                                        │                                                                                                                        │                                                                             │ │
-- │ │ │ │ (Flex, horizontal, one per effect, mirrored on right align) │                                                                                                                        │                                                                             │ │
-- │ │ │ │ ["indentSpacer" 2x0] ["icon"] ["spacer"] ["text"]           │                                                                                                                        │                                                                             │ │
-- │ │ │ └─────────────────────────────────────────────────────────────┘                                                                                                                        │                                                                             │ │
-- │ │ │ ┌────────────────────────────────────────────────┐                                                                                                                                     │                                                                             │ │
-- │ │ │ │ unknown effect row                             │                                                                                                                                     │                                                                             │ │
-- │ │ │ │ (when: alchemy skill below the knowledge gate) │                                                                                                                                     │                                                                             │ │
-- │ │ │ │ ["indentSpacer" 7x0] ["text" = ?]              │                                                                                                                                     │                                                                             │ │
-- │ │ │ └────────────────────────────────────────────────┘                                                                                                                                     │                                                                             │ │
-- │ │ │ - "effectSpacer"N 0 x effectSpacing (after every row, the last one included)                                                                                                           │                                                                             │ │
-- │ │ └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘                                                                             │ │
-- │ │ - "chargeTopSpacer" 0x1 (when: enchant charge + chargeDisplay bar)                                                                                                                                                                                                     │ │
-- │ │ ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐                                             │ │
-- │ │ │ "charge"                                                                                                                                                                                                               │                                             │ │
-- │ │ │ (Flex, when: enchant charge + chargeDisplay bar, bar row via makeBarRow, "bar" overlays "background" "fill" "text" cur / max "border" (makeBar, barGradient swaps the fill), right align puts the cost before the bar) │                                             │ │
-- │ │ │ ["useCostCounterweight" (center align)] ["label" (barLabels)] ["spacer"] ["bar" barWidth x ts] ["useCostSpacer" 0.25ts] ["useCost" -N, fixed 2ts (useCost setting)] ["rightSpacer" 5x0]                                │                                             │ │
-- │ │ └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘                                             │ │
-- │ │ - "chargeBottomSpacer" 0x1, 0x0 when the bottom conditionBar follows (when: enchant charge + chargeDisplay bar)                                                                                                                                                        │ │
-- │ │ - "conditionBarTopSpacer" 0x1 (when: durabilityDisplay bar (bottom))                                                                                                                                                                                                   │ │
-- │ │ ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────┐                                                                                                                                                          │ │
-- │ │ │ "conditionBar"                                                                                            │                                                                                                                                                          │ │
-- │ │ │ (Flex, when: weapon/armor + durabilityDisplay bar (bottom), right below "charge", bar row via makeBarRow) │                                                                                                                                                          │ │
-- │ │ │ ["label" (barLabels)] ["spacer"] ["bar" like "charge"'s] ["rightSpacer" 5x0]                              │                                                                                                                                                          │ │
-- │ │ └───────────────────────────────────────────────────────────────────────────────────────────────────────────┘                                                                                                                                                          │ │
-- │ │ - "conditionBarBottomSpacer" 0x1 (when: durabilityDisplay bar (bottom))                                                                                                                                                                                                │ │
-- │ │ - "potionEffectsSpacer" 0x1 (when: potion or override)                                                                                                                                                                                                                 │ │
-- │ │ ┌──────────────────────────────────────────────────────────────────┐                                                                                                                                                                                                   │ │
-- │ │ │ "potionEffects"                                                  │                                                                                                                                                                                                   │ │
-- │ │ │ (Flex, when: potion or override, same shape as "enchantEffects") │                                                                                                                                                                                                   │ │
-- │ │ └──────────────────────────────────────────────────────────────────┘                                                                                                                                                                                                   │ │
-- │ │ - "ingredientEffectsSpacer" 0x1 (when: ingredient or override)                                                                                                                                                                                                         │ │
-- │ │ ┌──────────────────────────────────────────────────────────────────────┐                                                                                                                                                                                               │ │
-- │ │ │ "ingredientEffects"                                                  │                                                                                                                                                                                               │ │
-- │ │ │ (Flex, when: ingredient or override, same shape as "enchantEffects") │                                                                                                                                                                                               │ │
-- │ │ └──────────────────────────────────────────────────────────────────────┘                                                                                                                                                                                               │ │
-- │ │ - "anchorEffects" 0x0 (mod anchor after the special blocks)                                                                                                                                                                                                            │ │
-- │ │ - "statLoftSpacer" 0x0, 0x2 when the loft is filled                                                                                                                                                                                                                    │ │
-- │ │ ┌───────────────────────────────────────────────────────────────────────────────────┐                                                                                                                                                                                  │ │
-- │ │ │ "statLoft"                                                                        │                                                                                                                                                                                  │ │
-- │ │ │ (Flex, horizontal, empty shelf above the stat row, mods fill it via ctx.statLoft) │                                                                                                                                                                                  │ │
-- │ │ └───────────────────────────────────────────────────────────────────────────────────┘                                                                                                                                                                                  │ │
-- │ │ - "statRowSpacer" 0x0, 0x2 when addStat fills the row                                                                                                                                                                                                                  │ │
-- │ │ ┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐ │ │
-- │ │ │ "statRow"                                                                                                                                                                                                                                                          │ │ │
-- │ │ │ (Flex, when: compact mode (addStat fills it), horizontal, order flips on right align)                                                                                                                                                                              │ │ │
-- │ │ │ ["valueSeparator" 7x0] ["valueIcon"] ["valueSpacer" 0.25ts] ["valueText"] ["weightSeparator" 7x0] ["weightIcon"] ["weightSpacer" 0.25ts] ["weightText"] ["soulSeparator" 7x0] ["soulIcon"] ["soulSpacer" 0.25ts] ["soulText" (filled soulgem + soulValue setting)] │ │ │
-- │ │ └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘ │ │
-- │ │ - "dividerTopSpacer" 0x0, 0x3 when enabled                                                                                                                                                                                                                             │ │
-- │ │ - "divider" (Image, when: a custom line lands or a modifier calls enableDivider, alpha 0 and 0 high until then, thin border line under the stat row)                                                                                                                   │ │
-- │ │ - "dividerBottomSpacer" 0x0, 0x2 when enabled                                                                                                                                                                                                                          │ │
-- │ │ - "customLine" (Text, when: override, caller supplied, enables the divider)                                                                                                                                                                                            │ │
-- │ │ - "chainLine1..N" (Text, when: registerLine mods return a line, enables the divider, no spacers, the lines stack on font leading)                                                                                                                                      │ │
-- │ └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘ │
-- └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
--[[
	Shared Tooltip v1

	Usage:
		local tip = I.SharedTooltip.create(item, overrides, style, context)
		tip.element: live element without a layer, embed it on your own
		tip.rebuild(): re-runs the whole build in place, modifiers included, tip.element stays valid
		tip.destroy(): releases handle and element, destroy through this instead of tip.element:destroy() (uses deepDestroy())
		tip.item, tip.overrides, tip.style, tip.context: build args can be mutated, .rebuild() honors them
		I.SharedTooltip.activeTooltips() lists every live handle
		item: game object, record, or record id string
			without a live object the build fakes a pristine instance,
			full condition and charge, count 1, empty soul, overrides win

	Unmanaged layouts:
		I.SharedTooltip.createLayout(item, overrides, style, context) -> layout table or nil, settings changes and activeTooltips never see it

	Settings preview:
		I.SharedTooltip.showPreview(item, overrides, style, context)
			top right corner sample for 5 realtime seconds, args optional
		I.SharedTooltip.setAutoPreview(bool)
			allows changing this mod's settings section without automatically triggering a preview

	Modifiers: (apply @ engineHandlers.onActive)
		I.SharedTooltip.registerModifier{
			id = "myMod",
			priority = 0,
			func = function(ctx)
			   -- edit the layout, do what you want
			end,
		}
		I.SharedTooltip.registerLine{
			id = "myModLine",
			priority = 0,
			func = function(ctx)
				return "extra line"
			end,
		}
		I.SharedTooltip.unregisterModifier("myMod") / unregisterLine("myModLine")

	ctx - lines and modifiers:
		item (nil for record tooltips), info (instance values land here under
		their engine names: condition, enchantmentCharge, soul, count,
		override beats live object, plain records read as a pristine instance),
		record (record-field overrides baked in),
		rawRecord (the plain engine record), itemType (its store, types.Weapon etc.),
		compact, style (resolved), overrides, labelTag,
		valueTag (inline "#RRGGBB" color tags), plus everything from context
	ctx - modifiers only:
		root, flex, statLoft, enableDivider(), 
		textElement(str, color, name, index),
		addStat(texture, valueStr, statName, color), addEffectGroup(groupName),
		makeBar(size, ratio, fillColor, overlayText, textColor) -> element,
		makeBarRow(labelText, labelColor, bar, rowName) -> element, add the result to flex yourself
		getConditionColor(current, max), formatNumber(num, mode, fontFix),
		mirrored (true on right align, flip horizontal child order to match)
		printEffects(target, effects, isAlchemy, color, alchemySkill)
			effects table in the parsed info form (text, icon, (known)),
			isAlchemy "potion" gates in engine pairs, any other truthy one effect per step
		normalizeEffects(effects) -> engine-shaped clones, the overrides effects format in,
			defaults filled, effect record backfilled, unknown ids dropped,
			build your row texts from these and hand them to printEffects
		getMaxEnchantmentCharge(enchantmentRecord) -> max charge, base cast cost,
			autocalc solved with the engine formula, preview tables need normalized effects
	
	notes:
		durability lookup: the text line is named 'condition', the bar modes build a 'conditionBar' flex instead (style.durabilityDisplay)
		bar rows ( eg. 'charge', 'conditionBar') always sit between their own <row>TopSpacer and <row>BottomSpacer in the main flex

	overrides: preview data, every key shadows the matching record, gameobject or itemData field, like:
		name, value, weight, health, condition, soul, enchantmentCharge, enchantCapacity, baseArmor, effects, damage, ...
		instance keys (condition, enchantmentCharge, soul, count) resolve into ctx.info under their engine names
		enchant: id string, false or a preview table {type, cost, charge, autocalc, effects}
		effects: list of {id, magnitudeMin, magnitudeMax, duration, range, area, affectedSkill, affectedAttribute, known} or engine effect objects,
			only ingredient and potion records read it (enchant effects nest inside enchant),
			known = true/false beats the knowledge gate on alchemy objects
		potionEffects, ingredientEffects: same list format, force the block on any item type,
			replacing the native block (beats effects), foreign blocks stack alongside
		display extras (not fields): count, qualityMult (percent line, red below 1), customLine, customLineColor
	style:
		borderStyle ("none" drops the frame), borderColor, borderPath,
		borderFile, borderOffset, borderless (borderStyle derives these, set one and it wins),
		background (texture), backgroundColor, transparency, padding (px inside the frame),
		nameColor, labelColor, valueColor, compactIconColor,
		enchantBlockColor (tints the enchantment block, charge bar text included),
		textSize (px), textAlignment ("left"/"center"/"right"), fontFix (plain number characters),
		weightTex, valueTex (compact stat icons),
		compact, shortText, renameEffects (cosmetic renames like Restore Health -> Heal),
		alignedEffects (flush effect rows, off follows textAlignment per line), effectSpacing (px between rows),
		barGradient (vanilla bar fill), barLabels, barWidth (px, both bars), useCost (cast cost by the charge bar),
		chargeDisplay ("none" drops the charge bar, no setting behind it), chargeBarColor,
		durabilityDisplay ("none"/"vanilla"/"colored"/"bar"/"bar (above enchantments)"/"bar (bottom)"), durabilityBarColor,
		weaponSpeed, weaponRange, enchantCapacity,
		soulValue (soul line / compact stat, only the name suffix otherwise),
		soulgemRebalance (mcp soulgem pricing, mirror the launcher toggle)
	context: call site metadata, every key passes through to ctx
		source (mod that spawned the tooltip), isPickpocketing, deposit
		alchemySkill (stands in for the player's skill in the knowledge gate,
			math.huge shows every effect, 0 hides them all)
	bundling:
		ship this one file
		renderer copies flag their newest version at the unnumbered key
			in player storage "InstalledSettingsRenderers" (session flag),
		the settings page appends it to build the newest renderer id, engine renderers otherwise
]]

local I = require("openmw.interfaces")
local core = require('openmw.core')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')
local self = require('openmw.self')
local storage = require('openmw.storage')
local async = require('openmw.async')
local auxUi = require('openmw_aux.ui')
local v2 = util.vector2

local MY_VERSION = 1

-- version check
if I.SharedTooltip and I.SharedTooltip.version >= MY_VERSION then
	return
end

-- content:insert corrupts ui content before api 139 or 140
local contentInsertFixed = core.API_REVISION >= 140

local textureCache = {}
local function getTexture(path)
	if not textureCache[path] then
		textureCache[path] = ui.texture{ path = path }
	end
	return textureCache[path]
end

------------------------------ style presets ------------------------------
local background = ui.texture { path = 'black' }
local white = ui.texture { path = 'white' }
local shadowColor = util.color.rgba(0, 0, 0, 0.75)

-- vanilla is the baseline for all presets
local stylePresets = {
	vanilla = {
		borderStyle = 'normal',
		borderColor = util.color.hex('ffffff'),
		transparency = 0.84, -- engine menu transparency default
		padding = 6, -- engine pads 8 but its border eats into that, 6 matches by eye
		nameColor = util.color.hex('dfc99f'), -- FontColor_color_header
		labelColor = util.color.hex('caa560'), -- FontColor_color_normal
		valueColor = util.color.hex('caa560'), -- vanilla renders the whole stat line in normal, not header
		compactIconColor = util.color.hex('D4D48E'),
		chargeBarColor = util.color.hex('c83c1e'), -- FontColor_color_health
		barGradient = true,
		barLabels = true,
		barWidth = 216, -- vanilla bars run much wider
		useCost = false,
		durabilityDisplay = 'vanilla',
		durabilityBarColor = util.color.hex('c83c1e'), -- FontColor_color_health
		textSize = 19,
		textAlignment = 'center',
		fontFix = true,
		compact = false,
		shortText = false,
		renameEffects = false,
		alignedEffects = false, -- vanilla centers every effect line
		effectSpacing = 5,
		weaponSpeed = false,
		weaponRange = false,
		enchantCapacity = false,
		soulValue = false, -- vanilla only names the soul
	},
	minimal = {
		shortText = true,
		renameEffects = true,
		compact = true,
		transparency = 0.7,
		durabilityDisplay = 'colored',
		alignedEffects = true,
		chargeBarColor = util.color.hex('35459f'), -- FontColor_color_magic
		durabilityBarColor = util.color.hex('c83c1e'), -- FontColor_color_health
		valueColor = util.color.hex('dfc99f'), -- FontColor_color_normal_over
		barGradient = true,
		soulValue = true,
		barLabels = false,
		barWidth = 120,
		useCost = true,
		padding = 2,
		effectSpacing = 0,
	},
	extended = {
		compact = true,
		renameEffects = true,
		durabilityDisplay = 'bar (above enchantments)',
		alignedEffects = true,
		chargeBarColor = util.color.hex('35459f'), -- FontColor_color_magic
		valueColor = util.color.hex('dfc99f'), --FontColor_color_normal_over
		barWidth = 120,
		useCost = true,
		padding = 2,
		weaponSpeed = true,
		weaponRange = true,
		enchantCapacity = true,
		soulValue = true,
		effectSpacing = 1,
	},
}

-- the look a fresh install lands on
local defaultPreset = 'minimal'

-- preset value over the vanilla base, the way the picker applies it
local function presetDefault(key)
	local value = stylePresets[defaultPreset][key]
	if value == nil then
		value = stylePresets.vanilla[key]
	end
	return value
end

------------------------------ player settings ------------------------------
-- renderer families store their newest version at the unnumbered key
local installedRenderers = storage.playerSection("InstalledSettingsRenderers")
local sliderVersion = installedRenderers:get("SuperSlider")
local numberRenderer = sliderVersion and "SuperSlider" .. sliderVersion or "number"
local pickerVersion = installedRenderers:get("SuperColorPicker")
local colorRenderer = pickerVersion and "SuperColorPicker" .. pickerVersion or "color"

local presetColors = {
	"dfc99f", -- name
	"caa560", -- label and value
	"D4D48E", -- compact icon
	"35459f", -- blue bar
	"1e2759", -- darker ^^
	"c83c1e", -- red bar
	"681E0F", -- darker ^^
	"ffffff", -- border tint
}

I.Settings.registerPage {
	key = 'SharedTooltip',
	l10n = 'none',
	name = 'Tooltip',
	description = 'Base style for every tooltip rendered through SharedTooltip. Mods can still override single properties per tooltip. Changes show a sample tooltip in the top right corner.',
}

local settingsCount = 0
local function countSettings()
	settingsCount = settingsCount + 1
	return settingsCount
end

-- fixed column width in the menu
local function padName(name)
	return name .. string.rep(" ", math.max(0, 45 - #name))
end

local settingsTemplate = {}

local tempKey = 'Style'
settingsTemplate[tempKey] = {
	key = 'SettingsSharedTooltip'..tempKey,
	page = 'SharedTooltip',
	l10n = 'none',
	name = padName(tempKey),
	permanentStorage = true,
	order = countSettings(),
	settings = {
		{
			key = 'borderStyle',
			renderer = 'select',
			name = 'Border',
			default = presetDefault('borderStyle'),
			argument = {
				l10n = 'none',
				items = {'none', 'thin', 'normal', 'thick', 'verythick'},
			},
		},
		{
			key = 'borderColor',
			renderer = colorRenderer,
			name = 'Border tint',
			default = presetDefault('borderColor'),
			argument = {presetColors = presetColors},
		},
		{
			key = 'transparency',
			renderer = numberRenderer,
			name = 'Background opacity',
			default = presetDefault('transparency'),
			argument = {
				min = 0,
				max = 1,
				step = 0.05,
				default = presetDefault('transparency'),
				width = 160,
				showDefaultMark = true,
			},
		},
		{
			key = 'padding',
			renderer = numberRenderer,
			name = 'Window padding (px)',
			default = presetDefault('padding'),
			argument = {
				min = 0,
				max = 30,
				step = 1,
				default = presetDefault('padding'),
				width = 160,
				showDefaultMark = true,
				integer = true,
			},
		},
		{
			key = 'textSize',
			renderer = numberRenderer,
			name = 'Text size',
			default = presetDefault('textSize'),
			argument = {
				min = 8,
				max = 48,
				step = 1,
				default = presetDefault('textSize'),
				width = 160,
				showDefaultMark = true,
				integer = true,
			},
		},
		{
			key = 'textAlignment',
			renderer = 'select',
			name = 'Text alignment',
			default = presetDefault('textAlignment'),
			argument = {
				l10n = 'none',
				items = {'left', 'center', 'right'},
			},
		},
		{
			key = 'fontFix',
			renderer = 'checkbox',
			name = 'Plain number characters (font fix)',
			default = presetDefault('fontFix'),
		},
	},
}

tempKey = 'Colors'
settingsTemplate[tempKey] = {
	key = 'SettingsSharedTooltip'..tempKey,
	page = 'SharedTooltip',
	l10n = 'none',
	name = padName(tempKey),
	permanentStorage = true,
	order = countSettings(),
	settings = {
		{
			key = 'nameColor',
			renderer = colorRenderer,
			name = 'Item name color',
			default = presetDefault('nameColor'),
			argument = {presetColors = presetColors},
		},
		{
			key = 'labelColor',
			renderer = colorRenderer,
			name = 'Label color',
			default = presetDefault('labelColor'),
			argument = {presetColors = presetColors},
		},
		{
			key = 'valueColor',
			renderer = colorRenderer,
			name = 'Value color',
			default = presetDefault('valueColor'),
			argument = {presetColors = presetColors},
		},
		{
			key = 'compactIconColor',
			renderer = colorRenderer,
			name = 'Compact icon color',
			default = presetDefault('compactIconColor'),
			argument = {presetColors = presetColors},
		},
		{
			key = 'chargeBarColor',
			renderer = colorRenderer,
			name = 'Charge bar color',
			default = presetDefault('chargeBarColor'),
			argument = {presetColors = presetColors},
		},
		{
			key = 'durabilityBarColor',
			renderer = colorRenderer,
			name = 'Durability bar color',
			default = presetDefault('durabilityBarColor'),
			argument = {presetColors = presetColors},
		},
	},
}

tempKey = 'Bars'
settingsTemplate[tempKey] = {
	key = 'SettingsSharedTooltip'..tempKey,
	page = 'SharedTooltip',
	l10n = 'none',
	name = padName(tempKey),
	permanentStorage = true,
	order = countSettings(),
	settings = {
		{
			key = 'barGradient',
			renderer = 'checkbox',
			name = 'Gradient bars',
			default = presetDefault('barGradient'),
		},
		{
			key = 'barLabels',
			renderer = 'checkbox',
			name = 'Bar labels',
			default = presetDefault('barLabels'),
		},
		{
			key = 'barWidth',
			renderer = numberRenderer,
			name = 'Bar width (px)',
			default = presetDefault('barWidth'),
			argument = {
				min = 40,
				max = 400,
				step = 5,
				default = presetDefault('barWidth'),
				width = 160,
				showDefaultMark = true,
				integer = true,
			},
		},
		{
			key = 'useCost',
			renderer = 'checkbox',
			name = 'Cast cost next to the charge bar',
			default = presetDefault('useCost'),
		},
		{
			key = 'durabilityDisplay',
			renderer = 'select',
			name = 'Durability display',
			default = presetDefault('durabilityDisplay'),
			argument = {
				l10n = 'none',
				items = {'none', 'vanilla', 'colored', 'bar', 'bar (above enchantments)', 'bar (bottom)'},
			},
		},
	},
}

tempKey = 'Content'
settingsTemplate[tempKey] = {
	key = 'SettingsSharedTooltip'..tempKey,
	page = 'SharedTooltip',
	l10n = 'none',
	name = padName(tempKey),
	permanentStorage = true,
	order = countSettings(),
	settings = {
		{
			key = 'compact',
			renderer = 'checkbox',
			name = 'Compact tooltips',
			default = presetDefault('compact'),
		},
		{
			key = 'shortText',
			renderer = 'checkbox',
			name = 'Short effect text',
			default = presetDefault('shortText'),
		},
		{
			key = 'renameEffects',
			renderer = 'checkbox',
			name = 'Rename effects',
			default = presetDefault('renameEffects'),
		},
		{
			key = 'alignedEffects',
			renderer = 'checkbox',
			name = 'Aligned effect list',
			default = presetDefault('alignedEffects'),
		},
		{
			key = 'effectSpacing',
			renderer = numberRenderer,
			name = 'Effect spacing (px)',
			default = presetDefault('effectSpacing'),
			argument = {
				min = 0,
				max = 10,
				step = 1,
				default = presetDefault('effectSpacing'),
				width = 160,
				showDefaultMark = true,
				integer = true,
			},
		},
		{
			key = 'weaponSpeed',
			renderer = 'checkbox',
			name = 'Weapon speed',
			default = presetDefault('weaponSpeed'),
		},
		{
			key = 'weaponRange',
			renderer = 'checkbox',
			name = 'Weapon range',
			default = presetDefault('weaponRange'),
		},
		{
			key = 'enchantCapacity',
			renderer = 'checkbox',
			name = 'Enchant capacity',
			default = presetDefault('enchantCapacity'),
		},
		{
			key = 'soulValue',
			renderer = 'checkbox',
			name = 'Soul value',
			default = presetDefault('soulValue'),
		},
		{
			key = 'soulgemRebalance',
			renderer = 'checkbox',
			name = 'Soul gem value rebalance',
			description = 'Match the "rebalance soul gem values" option in the launcher, scripts cannot read it.',
			default = false,
		},
	},
}

for _, template in pairs(settingsTemplate) do
	I.Settings.registerGroup(template)
end

-- section lookup
local sectionForKey = {}
for _, template in pairs(settingsTemplate) do
	local section = storage.playerSection(template.key)
	for _, entry in pairs(template.settings) do
		sectionForKey[entry.key] = section
	end
end

------------------------------ style defaults ------------------------------
local function getSetting(key)
	return sectionForKey[key]:get(key)
end

-- subscribers by the tracked tooltips keep this in sync with the player settings
local styleDefaults = {
	borderStyle = getSetting('borderStyle'),
	borderColor = getSetting('borderColor'),
	transparency = getSetting('transparency'),
	padding = getSetting('padding'),
	textSize = getSetting('textSize'),
	textAlignment = getSetting('textAlignment'),
	fontFix = getSetting('fontFix'),
	nameColor = getSetting('nameColor'),
	labelColor = getSetting('labelColor'),
	valueColor = getSetting('valueColor'),
	compactIconColor = getSetting('compactIconColor'),
	chargeBarColor = getSetting('chargeBarColor'),
	durabilityBarColor = getSetting('durabilityBarColor'),
	barGradient = getSetting('barGradient'),
	barLabels = getSetting('barLabels'),
	barWidth = getSetting('barWidth'),
	useCost = getSetting('useCost'),
	durabilityDisplay = getSetting('durabilityDisplay'),
	compact = getSetting('compact'),
	shortText = getSetting('shortText'),
	renameEffects = getSetting('renameEffects'),
	alignedEffects = getSetting('alignedEffects'),
	effectSpacing = getSetting('effectSpacing'),
	weaponSpeed = getSetting('weaponSpeed'),
	weaponRange = getSetting('weaponRange'),
	enchantCapacity = getSetting('enchantCapacity'),
	soulValue = getSetting('soulValue'),
	soulgemRebalance = getSetting('soulgemRebalance'),
	-- no setting behind these:
	background = background, -- texture
	borderPath = "textures/",
	weightTex = getTexture('textures/SharedTooltip/weight.dds'),
	-- the vanilla gold icon divided by the default compactIconColor, so the tint paints the gold back on
	valueTex = getTexture('textures/SharedTooltip/gold.dds'),
	--enchantBlockColor = color, tints all the enchantment texts including the text on the charge bar
	--chargeDisplay = "none", drops the charge bar row
	-- derived off borderStyle:
	--borderFile = "thin"/"thick"
	--borderOffset = px thickness
	--borderless = bool
}

-- preset picker (seperate)
I.Settings.registerGroup {
	key = 'SettingsSharedTooltipPresets',
	page = 'SharedTooltip',
	l10n = 'none',
	name = 'Presets',
	permanentStorage = true,
	order = -1,
	settings = {
		{
			key = 'preset',
			renderer = 'select',
			name = 'Preset',
			description = 'Applying a preset overwrites every style setting below.',
			default = defaultPreset,
			argument = {
				l10n = 'none',
				items = {'vanilla', 'minimal', 'extended'},
			},
		},
	},
}
local presetSection = storage.playerSection('SettingsSharedTooltipPresets')
presetSection:subscribe(async:callback(function()
	-- a newer copy took over after we loaded, the preset cascade retires with it
	if I.SharedTooltip and I.SharedTooltip.version ~= MY_VERSION then return end
	local preset = stylePresets[presetSection:get('preset')]
	if not preset then return end
	for key, value in pairs(stylePresets.vanilla) do
		sectionForKey[key]:set(key, value)
	end
	for key, value in pairs(preset) do
		sectionForKey[key]:set(key, value)
	end
end))
------------------------------------------------------------

-- utf8 codepoint to bytes
local bytemarkers = { {0x7FF,192}, {0xFFFF,224}, {0x1FFFFF,240} }
local function hextoutf8(decimal)
	if decimal < 128 then return string.char(decimal) end
	local charbytes = {}
	for bytes, vals in ipairs(bytemarkers) do
		if decimal <= vals[1] then
			for b = bytes+1, 2, -1 do
				local mod = decimal % 64
				decimal = (decimal - mod) / 64
				charbytes[b] = string.char(128 + mod)
			end
			charbytes[1] = string.char(vals[2] + decimal)
			break
		end
	end
	return table.concat(charbytes)
end

-- number to short string, thin spaces group thousands
local function formatNumber(num, mode, fontFix)
	local text = math.floor(num*10)/10
	if mode == "v/w" then
		text = (math.floor(num*10+0.5)/10)
	elseif mode == "weight" then
		text = math.floor(num*10+0.5)/10
	end
	if text > 99 or text > 1.2 and (text%1 <= 0.1 or text%1 >= 0.9) then
		text = math.floor(text)
	end
	if text == 1/0 then
		if not fontFix then
			text = hextoutf8(0x221e)
		else
			-- callers derive the inf case from the number itself
			text = "-"
		end
	elseif text >= 10^6-100 then
		text = text/1000
		local e = math.floor(math.log10(text))
		text = text + 10^e*1.005 - 10^e
		local suffixes = {"K","M","G","T","P","E","Z"}
		local i = 1
		while text >= 1000 do
			text = text/1000
			i = i+1
		end
		-- control rounding instead of string format
		text = math.floor(text*100)/100
		text = string.format("%.2f", text)
		if #text == 6 then
			text = text:sub(1,3)
		else
			text = text:sub(1,4)
		end
		text = text.." "..suffixes[i]
	elseif text >= 1000 then
		text = math.floor(text/1000)..(not fontFix and hextoutf8(0x200a)..hextoutf8(0x200a) or "")..string.format("%03d", text%1000)
	end
	return ""..text
end

------------------------------ borders ------------------------------
-- bundled ql_makeborder
local sideParts = {
	left = v2(0, 0),
	right = v2(1, 0),
	top = v2(0, 0),
	bottom = v2(0, 1),
}
local cornerParts = {
	top_left = v2(0, 0),
	top_right = v2(1, 0),
	bottom_left = v2(0, 1),
	bottom_right = v2(1, 1),
}
local borderPieceCache = {}
-- outset reaches past the content so an auto sizing Container grows around the frame
-- inset keeps the frame within a parent that already carries a size
local function makeBorder(path, thickness, color, borderSize, background, padding, outset)
	-- piece templates per texture folder and thickness
	local pieces = borderPieceCache[path..thickness]
	if not pieces then
		pieces = {}
		for part in pairs(sideParts) do
			local horizontal = part == 'top' or part == 'bottom'
			pieces[part] = {
				type = ui.TYPE.Image,
				props = {
					resource = getTexture(path..('menu_%s_border_%s.dds'):format(thickness, part)),
					tileH = horizontal,
					tileV = not horizontal,
				},
			}
		end
		for part in pairs(cornerParts) do
			pieces[part] = {
				type = ui.TYPE.Image,
				props = {
					resource = getTexture(path..('menu_%s_border_%s_corner.dds'):format(thickness, part)),
				},
			}
		end
		borderPieceCache[path..thickness] = pieces
	end
	local borderV = v2(1, 1) * borderSize
	-- slot sits this far in, padding buys clearance on top of the frame itself
	local inset = borderSize + (padding or 0)
	local insetV = v2(1, 1) * inset
	-- outset pieces land this far past the content, which is what drags a Container's size out
	local reach = 2 * inset - borderSize
	local borders = {
		content = ui.content {},
	}
	if background then
		-- the parent grew, stretch the background back over the whole frame
		if outset then background.props.size = insetV * 2 end
		borders.content:add(background)
	end
	for part, v in pairs(sideParts) do
		local horizontal = part == 'top' or part == 'bottom'
		local direction = horizontal and v2(1, 0) or v2(0, 1)
		local position = (direction - v) * borderSize
		local size = (v2(1, 1) - direction * 3) * borderSize
		if outset then
			position = direction * borderSize + v * reach
			size = (v2(1, 1) - direction) * borderSize + direction * (reach - borderSize)
		end
		borders.content:add {
			template = pieces[part],
			props = {
				position = position,
				relativePosition = v,
				size = size,
				relativeSize = direction,
				color = color,
				alpha = color and color.a or nil,
			}
		}
	end
	for part, v in pairs(cornerParts) do
		borders.content:add {
			template = pieces[part],
			props = {
				position = outset and v * reach or -v * borderSize,
				relativePosition = v,
				size = borderV,
				color = color,
				alpha = color and color.a or nil,
			},
		}
	end
	local slot = {
		external = { slot = true },
		props = {
			position = insetV,
			relativeSize = v2(1, 1),
		}
	}
	-- inset has no room to grow into, pull the slot in instead
	if not outset then slot.props.size = insetV * -2 end
	borders.content:add(slot)
	return borders
end
------------------------------------------------------------

-- stores searched when resolving a record or record id string
local itemTypeStores = {
	types.Weapon,
	types.Armor,
	types.Clothing,
	types.Book,
	types.Ingredient,
	types.Potion,
	types.Apparatus,
	types.Lockpick,
	types.Probe,
	types.Repair,
	types.Light,
	types.Miscellaneous,
}

------------------------------ tooltip api ------------------------------
local function makeTooltipChain()
	local list = {}
	local seq = 0
	local chain = {
		entries = list
	}
	function chain.register(opts)
		-- replace any existing entry sharing the id
		if opts.id then
			for i, entry in ipairs(list) do
				if entry.id == opts.id then
					table.remove(list, i)
					break
				end
			end
		end
		seq = seq + 1
		table.insert(list, {
			id = opts.id,
			priority = opts.priority or 0,
			seq = seq,
			func = opts.func,
		})
		-- lower priority first, insertion order breaks ties
		table.sort(list, function(a, b)
			if a.priority ~= b.priority then
				return a.priority < b.priority
			end
			return a.seq < b.seq
		end)
	end
	function chain.unregister(key)
		for i, entry in ipairs(list) do
			if entry.id == key or entry.func == key then
				table.remove(list, i)
				return
			end
		end
	end
	return chain
end

local tooltipLineChain = makeTooltipChain()
local tooltipModifierChain = makeTooltipChain()

------------------------------------------------------------

local function getMaxEnchantmentCharge(enchantment)
	-- record shape, the preview table key autocalc works too
	if not (enchantment.isAutocalc or enchantment.autocalcFlag or enchantment.autocalc) then
		return enchantment.charge, enchantment.cost
	end
	local cost = 0
	for _, effect in pairs(enchantment.effects) do
		-- note: EffectCostMethod = EffectCostMethod::GameEnchantment
	
		--float calcEffectCost(
		--const ESM::ENAMstruct& effect, const ESM::MagicEffect* magicEffect, const EffectCostMethod method)
		--{
		--const MWWorld::ESMStore& store = *MWBase::Environment::get().getESMStore();
		--	if (!magicEffect)
		--magicEffect = store.get<ESM::MagicEffect>().find(effect.mEffectID);
		local hasMagnitude = effect.effect.hasMagnitude -- bool hasMagnitude = !(magicEffect->mData.mFlags & ESM::MagicEffect::NoMagnitude);
		local hasDuration = effect.effect.hasDuration -- bool hasDuration = !(magicEffect->mData.mFlags & ESM::MagicEffect::NoDuration);
		local appliedOnce = effect.effect.isAppliedOnce -- bool appliedOnce = magicEffect->mData.mFlags & ESM::MagicEffect::AppliedOnce;
		local minMagn = hasMagnitude and effect.magnitudeMin or 1; -- int minMagn = hasMagnitude ? effect.mMagnMin : 1;
		local maxMagn = hasMagnitude and effect.magnitudeMax or 1; -- int maxMagn = hasMagnitude ? effect.mMagnMax : 1;
		--if (method == EffectCostMethod::PlayerSpell || method == EffectCostMethod::GameSpell)
		--{
		--	minMagn = std::max(1, minMagn);
		--	maxMagn = std::max(1, maxMagn);
		--}
		local duration = hasDuration and effect.duration or 1; -- int duration = hasDuration ? effect.mDuration : 1;
		if not appliedOnce then -- if (!appliedOnce)
			duration = math.max(1, duration) -- duration = std::max(1, duration);
		end
		local fEffectCostMult = core.getGMST("fEffectCostMult") -- static const float fEffectCostMult = store.get<ESM::GameSetting>().find("fEffectCostMult")->mValue.getFloat();
		-- static const float iAlchemyMod = store.get<ESM::GameSetting>().find("iAlchemyMod")->mValue.getFloat();
		local durationOffset = 0;            -- int durationOffset = 0;
		local minArea = 0;                   -- int minArea = 0;
		local costMult = fEffectCostMult;  -- float costMult = fEffectCostMult;
		--if (method == EffectCostMethod::PlayerSpell)
		--{
		--	durationOffset = 1;
		--	minArea = 1;
		--}
		--else if (method == EffectCostMethod::GamePotion)
		--{
		--	minArea = 1;
		--	costMult = iAlchemyMod;
		--}
		local x = 0.5 * (minMagn + maxMagn);                                          -- float x = 0.5 * (minMagn + maxMagn);
		x = x * (0.1 * effect.effect.baseCost);                                      -- x *= 0.1 * magicEffect->mData.mBaseCost;
		x = x * (durationOffset + duration);                                               -- x *= durationOffset + duration;
		x = x + (0.05 * math.max(minArea, effect.area) * effect.effect.baseCost);   -- x += 0.05 * std::max(minArea, effect.mArea) * magicEffect->mData.mBaseCost;
		
		if effect.range == core.magic.RANGE.Target then	--if (effect.mData.mRange == ESM::RT_Target)
			x = x * 1.5 -- effectCost *= 1.5;
		end
		x = math.floor(x * costMult + 0.5) -- round here i think (not 100% sure)
		cost = cost + x
		
	end
	
	local baseCost = cost
	if enchantment.type == core.magic.ENCHANTMENT_TYPE.CastOnce then
		cost = cost * core.getGMST("iMagicItemChargeOnce")
	elseif enchantment.type == 	core.magic.ENCHANTMENT_TYPE.CastOnUse then
		cost = cost * core.getGMST("iMagicItemChargeUse")
	elseif enchantment.type == 	core.magic.ENCHANTMENT_TYPE.CastOnStrike then
		cost = cost * core.getGMST("iMagicItemChargeStrike")
	elseif enchantment.type == 	core.magic.ENCHANTMENT_TYPE.ConstantEffect then
		cost = cost * core.getGMST("iMagicItemChargeConst")
	end
	return cost or 0, baseCost
end

local function getWeaponTypeName(typeId)
	if typeId == types.Weapon.TYPE.Arrow then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.AxeOneHand then
		return core.getGMST("sSkillAxe")..", "..core.getGMST("sOneHanded")
	elseif typeId == types.Weapon.TYPE.AxeTwoHand then
		return core.getGMST("sSkillAxe")..", "..core.getGMST("sTwoHanded")
	elseif typeId == types.Weapon.TYPE.BluntOneHand then
		return core.getGMST("sSkillBluntweapon")..", "..core.getGMST("sOneHanded")
	elseif typeId == types.Weapon.TYPE.BluntTwoClose then
		return core.getGMST("sSkillBluntweapon")..", "..core.getGMST("sTwoHanded")
	elseif typeId == types.Weapon.TYPE.BluntTwoWide then
		return core.getGMST("sSkillBluntweapon")..", "..core.getGMST("sTwoHanded")
	elseif typeId == types.Weapon.TYPE.Bolt then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.LongBladeOneHand then
		return core.getGMST("sSkillLongblade")..", "..core.getGMST("sOneHanded")
	elseif typeId == types.Weapon.TYPE.LongBladeTwoHand then
		return core.getGMST("sSkillLongblade")..", "..core.getGMST("sTwoHanded")
	elseif typeId == types.Weapon.TYPE.MarksmanBow then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.MarksmanCrossbow then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.MarksmanThrown then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.ShortBladeOneHand then
		return core.getGMST("sSkillShortblade")..", "..core.getGMST("sOneHanded")
	elseif typeId == types.Weapon.TYPE.SpearTwoWide then
		return core.getGMST("sSkillSpear")..", "..core.getGMST("sTwoHanded")
	end
	return "Unknown"
end

-- Armor.TYPE: find the key of the enum
local function getArmorTypeName(typeId)
	local armorTypes = types.Armor.TYPE
	
	for name, id in pairs(armorTypes) do
		if id == typeId then
			return name
		end
	end
	
	return "Unknown Armor Type"
end

-- Clothing.TYPE: find the key of the enum
local function getClothingTypeName(typeId)
	local clothingTypes = types.Clothing.TYPE
	
	for name, id in pairs(clothingTypes) do
		if id == typeId then
			return name
		end
	end
	
	return "Unknown Clothing Type"
end

local effectFamilyGMST = {
	absorbattribute = "sAbsorb",
	absorbskill = "sAbsorb",
	damageattribute = "sDamage",
	damageskill = "sDamage",
	drainattribute = "sDrain",
	drainskill = "sDrain",
	fortifyattribute = "sFortify",
	fortifyskill = "sFortify",
	restoreattribute = "sRestore",
	restoreskill = "sRestore",
}

local function getMagicEffectName(effectId, hasArg)
	if hasArg and effectFamilyGMST[effectId] then
		return core.getGMST(effectFamilyGMST[effectId])
	end
	local effect = core.magic.effects.records[effectId]
	if effect then
		return effect.name
	end
	return "Unknown Effect"
end

-- Helper function for enchantment type names
local function getEnchantmentTypeName(typeId)
	local types = {
		[core.magic.ENCHANTMENT_TYPE.CastOnce] = "sItemCastOnce",
		[core.magic.ENCHANTMENT_TYPE.CastOnUse] = "sItemCastWhenUsed",
		[core.magic.ENCHANTMENT_TYPE.CastOnStrike] = "sItemCastWhenStrikes",
		[core.magic.ENCHANTMENT_TYPE.ConstantEffect] = "sItemCastConstant"
	}

	return core.getGMST(types[typeId] or "sMagicEffects")
end


-- Get detailed weapon data
local function getWeaponData(record, condition)
	local durabilityCurrent = condition
	local durabilityMax = record.health
	return {
		type = record.type,
		typeName = getWeaponTypeName(record.type),
		subtype = record.subtype,
		damage = {
			chopMin = math.min(record.chopMinDamage, record.chopMaxDamage),
			chopMax = record.chopMaxDamage,
			slashMin = math.min(record.slashMinDamage, record.slashMaxDamage),
			slashMax = record.slashMaxDamage, 
			thrustMin = math.min(record.thrustMinDamage, record.thrustMaxDamage),
			thrustMax = record.thrustMaxDamage,
			
		},
		speed = record.speed,
		reach = record.reach,
		--ignoresNormalWeaponResistance = record.ignoresNormalWeaponResistance,
		--silver = record.silver,
		durability = durabilityCurrent and {
			current = durabilityCurrent,
			max = durabilityMax
		}
	}
end

-- Get detailed armor data
local function getArmorData(record, condition)
	local durabilityCurrent = condition
	local durabilityMax = record.health
	--print((durabilityCurrent or "nil").." / "..(durabilityMax or "nil"))
	local baseArmor = record.baseArmor
	local referenceWeight = 0
	local recordType = record.type
	if recordType == types.Armor.TYPE.Boots then
		referenceWeight = core.getGMST("iBootsWeight")
	elseif recordType == types.Armor.TYPE.Cuirass then
		referenceWeight = core.getGMST("iCuirassWeight")
	elseif recordType == types.Armor.TYPE.Greaves then
		referenceWeight = core.getGMST("iGreavesWeight")
	elseif recordType == types.Armor.TYPE.Helmet then
		referenceWeight = core.getGMST("iHelmWeight")
	elseif recordType == types.Armor.TYPE.LBracer then
		referenceWeight = core.getGMST("iGauntletWeight")
	elseif recordType == types.Armor.TYPE.RBracer then
		referenceWeight = core.getGMST("iGauntletWeight")
	elseif recordType == types.Armor.TYPE.LPauldron then
		referenceWeight = core.getGMST("iPauldronWeight")
	elseif recordType == types.Armor.TYPE.RPauldron then
		referenceWeight = core.getGMST("iPauldronWeight")
	elseif recordType == types.Armor.TYPE.LGauntlet then
		referenceWeight = core.getGMST("iGauntletWeight")
	elseif recordType == types.Armor.TYPE.RGauntlet then
		referenceWeight = core.getGMST("iGauntletWeight")
	elseif recordType == types.Armor.TYPE.Shield then
		referenceWeight = core.getGMST("iShieldWeight")
	end
	local epsilon = 5e-4
	local class = "???"
	local skillName = "???"
	local skill = 0
	if record.weight == 0 then
		class = core.getGMST("sSkillUnarmored")
		skillName = core.getGMST("sSkillUnarmored")
		skill = types.Player.stats.skills.unarmored(self).modified
	elseif record.weight <= referenceWeight * core.getGMST("fLightMaxMod") + epsilon then
		class = core.getGMST("sLight")
		skillName = core.getGMST("sSkillLightarmor")
		skill = types.Player.stats.skills.lightarmor(self).modified
	elseif record.weight <= referenceWeight * core.getGMST("fMedMaxMod") + epsilon then
		class = core.getGMST("sMedium")
		skillName = core.getGMST("sSkillMediumarmor")
		skill = types.Player.stats.skills.mediumarmor(self).modified
	else
		class = core.getGMST("sHeavy")
		skillName = core.getGMST("sSkillHeavyarmor")
		skill = types.Player.stats.skills.heavyarmor(self).modified
	end
	-- weightless armor reads its raw rating, the engine skips the skill scaling
	local playerArmor = record.weight == 0 and baseArmor or baseArmor * skill / core.getGMST("iBaseArmorSkill")
	return {
		type = recordType,
		typeName = getArmorTypeName(record.type),
		baseArmor = baseArmor,
		class = class,
		skillName = skillName,
		playerArmor = playerArmor,
		durability = durabilityCurrent and {
			current = durabilityCurrent or 0,
			max = durabilityMax or 0
		}
	}
end

-- Get detailed clothing data
local function getClothingData(record)
	return {
		type = record.type,
		typeName = getClothingTypeName(record.type),
		enchantCapacity = record.enchantCapacity
	}
end


-- vanilla magnitude suffix per effect, keyed by id, points is the fallback
-- ported from loadmgef.cpp getMagnitudeDisplayType (fixed effect index ranges)
local magnitudeDisplayType = {}
do
	local ET = core.magic.EFFECT_TYPE
	magnitudeDisplayType[ET.FortifyMaximumMagicka] = "timesInt"
	for _, id in ipairs({ ET.Telekinesis, ET.DetectAnimal, ET.DetectEnchantment, ET.DetectKey }) do
		magnitudeDisplayType[id] = "feet"
	end
	for _, id in ipairs({ ET.CommandCreature, ET.CommandHumanoid }) do
		magnitudeDisplayType[id] = "level"
	end
	for _, id in ipairs({
		ET.Chameleon, ET.Blind, ET.Dispel, ET.Reflect,
		ET.WeaknessToFire, ET.WeaknessToFrost, ET.WeaknessToShock, ET.WeaknessToMagicka,
		ET.WeaknessToCommonDisease, ET.WeaknessToBlightDisease, ET.WeaknessToCorprusDisease,
		ET.WeaknessToPoison, ET.WeaknessToNormalWeapons,
		ET.ResistFire, ET.ResistFrost, ET.ResistShock, ET.ResistMagicka,
		ET.ResistCommonDisease, ET.ResistBlightDisease, ET.ResistCorprusDisease,
		ET.ResistPoison, ET.ResistNormalWeapons, ET.ResistParalysis,
	}) do
		magnitudeDisplayType[id] = "percent"
	end
end

-- cosmetic short names applied when renameEffects is on, keyed by the localized name
-- umlauts are data here, they must match the strings the engine returns
local effectAliases = {
	-- english
	["Restore Health"] = "Heal",
	["Fortify Maximum Magicka"] = "Fortify Max Magicka",
	["Detect Enchantment"] = "Detect Magic",
	["Spell Absorption"] = "Absorb Spell",
	["Weakness to Fire"] = "Weak to Fire",
	["Weakness to Frost"] = "Weak to Frost",
	["Weakness to Shock"] = "Weak to Shock",
	["Weakness to Magicka"] = "Weak to Magicka",
	["Weakness to Common Disease"] = "Weak to Common Disease",
	["Weakness to Blight Disease"] = "Weak to Blight Disease",
	["Weakness to Corprus Disease"] = "Weak to Corprus Disease",
	["Weakness to Poison"] = "Weak to Poison",
	["Weakness to Normal Weapons"] = "Weak to Normal Weapons",
	-- german
	["Lebensenergie wiederherstellen"] = "Heilung",
	["Maximalen Magiewert festigen"] = "Max. Magiewert festigen",
	["Anfälligkeit für Feuer"] = "Anfällig für Feuer",
	["Anfälligkeit für Eis"] = "Anfällig für Eis",
	["Anfälligkeit für Blitz"] = "Anfällig für Blitz",
	["Anfälligkeit für Magie"] = "Anfällig für Magie",
	["Anfälligkeit für Krankheiten"] = "Anfällig für Krankheiten",
	["Anfälligkeit für Pest"] = "Anfällig für Pest",
	["Anfälligkeit für Corprus"] = "Anfällig für Corprus",
	["Anfälligkeit für Gift"] = "Anfällig für Gift",
	["Anfälligkeit für normale Waffen"] = "Anfällig für normale Waffen",
}

-- shorttext range affix, verbose localized words trimmed, keyed by the gmst value
local rangeAliases = {
	["sich selbst"] = "Selbst",
	-- eyeballed guesses below, misses just pass through untrimmed
	["soi-même"] = "soi",
	["sur soi-même"] = "soi",
	["a sí mismo"] = "sí mismo",
	["en sí mismo"] = "sí mismo",
	["на себя"] = "себя",
}

local function getEffects(eff, enchantType, shortTexts, renameEffects)
	local effects = {}

	for i, effect in ipairs(eff) do
		local text = getMagicEffectName(effect.id, effect.affectedSkill or effect.affectedAttribute)
		--for a,b in pairs(core.magic.EFFECT_TYPE) do
		--	if b == effect.id then
		--		print(a)
		--	end
		--end
		local statSpacer = " "
		if effect.affectedSkill then
			text = text.." "..(core.getGMST("sSkill"..effect.affectedSkill) or "??")
			if shortTexts then
				if effect.id == core.magic.EFFECT_TYPE.FortifySkill then
					statSpacer = ""
					text = (core.getGMST("sSkill"..effect.affectedSkill) or "??").. " +"
				elseif effect.id == core.magic.EFFECT_TYPE.DrainSkill then
					statSpacer = ""
					text = (core.getGMST("sSkill"..effect.affectedSkill) or "??").. " -"
				end
			end
		elseif effect.affectedAttribute then
			text = text.." "..(core.getGMST("sAttribute"..effect.affectedAttribute) or "??")
			if shortTexts then
				if effect.id == core.magic.EFFECT_TYPE.FortifyAttribute then
					statSpacer = ""
					text = (core.getGMST("sAttribute"..effect.affectedAttribute) or "??").. " +"
				elseif effect.id == core.magic.EFFECT_TYPE.DrainAttribute then
					statSpacer = ""
					text = (core.getGMST("sAttribute"..effect.affectedAttribute) or "??").. " -"
				end
			end
		end
		-- optional cosmetic short name, off for faithful vanilla text
		if renameEffects and effectAliases[text] then
			text = effectAliases[text]
		end
		local effectPrototype = core.magic.effects.records[effect.id]
		local magMin, magMax = effect.magnitudeMin, effect.magnitudeMax
		-- the engine hides a 0-0 magnitude
		if effectPrototype.hasMagnitude and (magMin ~= 0 or magMax ~= 0) then
			local displayType = magnitudeDisplayType[effect.id]
			if shortTexts then
				-- short keeps its terse form, no unit words, only Chameleon marks its percent
				if displayType == "timesInt" then
					text = text..(magMin == magMax and statSpacer.. magMin/10 or statSpacer .. magMin/10 .."-"..magMax/10).."INT"
				else
					-- ranged magnitudes keep the space, "+5-10" would read as two signed values
					text = text..(magMin == magMax and statSpacer..magMin or " "..magMin.."-"..magMax)
					if effect.id == core.magic.EFFECT_TYPE.Chameleon then
						text = text.."%"
					end
				end
			elseif displayType == "timesInt" then
				-- magnitude is tenths, one decimal like the engine
				local lo = string.format("%.1f", magMin/10)
				local hi = string.format("%.1f", magMax/10)
				text = text.." "..(magMin == magMax and lo or lo.." "..core.getGMST("sTo").." "..hi)..core.getGMST("sXTimesINT")
			else
				-- vanilla suffix per display type, points is the fallback
				local numStr = magMin == magMax and tostring(magMin) or magMin.." "..core.getGMST("sTo").." "..magMax
				local singular = magMin == magMax and math.abs(magMin) == 1
				text = text.." "..numStr
				if displayType == "percent" then
					text = text..core.getGMST("spercent")
				elseif displayType == "feet" then
					text = text.." "..core.getGMST("sfeet")
				elseif displayType == "level" then
					text = text.." "..core.getGMST(singular and "sLevel" or "sLevels")
				else
					text = text.." "..core.getGMST(singular and "spoint" or "spoints")
				end
			end
		end
		if enchantType ~= "constant" then --enchantmentRecord.type ~= core.magic.ENCHANTMENT_TYPE.ConstantEffect then
			if effectPrototype.hasDuration then
				local dur = effect.duration
				-- applied once effects keep their raw duration, the rest read at least 1
				if not effectPrototype.isAppliedOnce then
					dur = math.max(1, dur)
				end
				if shortTexts then
					if dur > 1 then
						text = text.." x "..dur.."s"
					end
				elseif dur > 0 then
					text = text.." "..core.getGMST("sfor")
					text = text.." "..dur
					if dur == 1 then
						text = text.." "..core.getGMST("ssecond")
					else
						text = text.." "..core.getGMST("sseconds")
					end
				end
			end
			-- area tail like the engine, shorttext keeps it terse
			if (effect.area or 0) > 0 then
				text = text..(shortTexts and (" "..effect.area.."ft") or (" "..core.getGMST("sin").." "..effect.area.." "..core.getGMST("sfootarea")))
			end
			if enchantType ~= "potion" then
				if shortTexts then
					local word
					if effect.range == core.magic.RANGE.Self then
						word = core.getGMST("sRangeSelf")
					elseif effect.range == core.magic.RANGE.Target then
						word = core.getGMST("sRangeTarget")
					elseif effect.range == core.magic.RANGE.Touch then
						word = core.getGMST("sRangeTouch")
					end
					if word then
						text = text.." ("..(rangeAliases[word] or word)..")"
					end
				else
					text = text.." "..core.getGMST("sonword")
					if effect.range == core.magic.RANGE.Self then
						text = text.." "..core.getGMST("sRangeSelf")
					elseif effect.range == core.magic.RANGE.Target then
						text = text.." "..core.getGMST("sRangeTarget")		
					elseif effect.range == core.magic.RANGE.Touch then
						text = text.." "..core.getGMST("sRangeTouch")
					end
				end
			end
		end
		--if effect.id >= 0 then -- Valid effect
			-- and-or would eat known = false
			local known
			if type(effect) == "table" then
				known = effect.known
			end
			table.insert(effects, {
				id = effect.id,
				known = known,
				text = text,
			   -- subEffect = effect.subEffect,
				skillId = effect.affectedSkill,
				attributeId = effect.affectedAttribute,
				range = effect.range,
				area = effect.area,
				icon = effect.effect.icon,
				duration = effect.duration,
				magnitude = {
					min = effect.magnitudeMin,
					max = effect.magnitudeMax
				}
			})
		--end
	end
	return effects
end

-- clone effect entries field by field, plain tables and engine effect objects both work
local function normalizeEffects(effects)
	local normalized = {}
	for _, eff in ipairs(effects or {}) do
		local clone = {
			id = eff.id,
			range = eff.range,
			area = eff.area or 0,
			duration = eff.duration or 0,
			magnitudeMin = eff.magnitudeMin or 0,
			affectedSkill = eff.affectedSkill,
			affectedAttribute = eff.affectedAttribute,
			effect = eff.effect or eff.id and core.magic.effects.records[eff.id],
		}
		clone.magnitudeMax = eff.magnitudeMax or clone.magnitudeMin
		-- known only exists on plain tables, engine objects may balk at unknown props
		if type(eff) == "table" then
			clone.known = eff.known
		end
		-- unknown effect ids would error below, drop them
		if clone.id and clone.effect then
			table.insert(normalized, clone)
		end
	end
	return normalized
end

-- Get enchantment data if present
local function getEnchantmentData(record, shortTexts, currentCharge, renameEffects)
	-- record.enchant picks up overrides.enchant through the overlay
	local enchantment = record.enchant
	if not enchantment or enchantment == "" then return nil end
	local enchantmentRecord
	if type(enchantment) == "table" then
		-- preview table stands in for an enchantment record
		enchantmentRecord = {
			type = enchantment.type,
			cost = enchantment.cost,
			charge = enchantment.charge,
			isAutocalc = enchantment.autocalc or enchantment.isAutocalc or enchantment.autocalcFlag,
			effects = normalizeEffects(enchantment.effects),
		}
	else
		enchantmentRecord = core.magic.enchantments.records[enchantment:lower()]
		if not enchantmentRecord then return nil end
	end

	local maxCharge, baseCastCost = getMaxEnchantmentCharge(enchantmentRecord)

	-- nil charge: plain record or preview enchant, treat as full
	local charge = maxCharge and maxCharge > 0 and {
		current = currentCharge or maxCharge,
		max = maxCharge
	} or nil
	
	local effects = getEffects(enchantmentRecord.effects, enchantmentRecord.type == core.magic.ENCHANTMENT_TYPE.ConstantEffect and "constant", shortTexts, renameEffects)
	
	if enchantmentRecord.type == core.magic.ENCHANTMENT_TYPE.CastOnce then
		charge = nil
	elseif enchantmentRecord.type == core.magic.ENCHANTMENT_TYPE.ConstantEffect then
		charge = nil
	end
	
	
	-- cast cost per use after the enchant skill discount, engine formula
	local useCost
	if charge and baseCastCost and baseCastCost > 0 then
		local enchantSkill = types.Player.stats.skills.enchant(self).modified
		useCost = math.floor(math.max(1, baseCastCost - baseCastCost/100*(enchantSkill-10)))
	end
	return {
		type = enchantmentRecord.type,
		typeName = getEnchantmentTypeName(enchantmentRecord.type),
		cost = enchantmentRecord.cost,
		charge = charge,
		maxCharge = maxCharge,
		useCost = useCost,
		effects = effects,
		autocalc = enchantmentRecord.isAutocalc or enchantmentRecord.autocalcFlag
	}
end



local function getIngredientEffects(effectList)
	local effects = {}
	for _,effect in ipairs(effectList) do
		local text = getMagicEffectName(effect.id, effect.affectedSkill or effect.affectedAttribute)
		if effect.affectedSkill then
			text = text.." "..(core.getGMST("sSkill"..effect.affectedSkill) or "??")
		elseif effect.affectedAttribute then
			text = text.." "..(core.getGMST("sAttribute"..effect.affectedAttribute) or "??")
		end
		--if effect.id >= 0 then -- Valid effect?
		local known
		if type(effect) == "table" then
			known = effect.known
		end
		table.insert(effects, {
			id = effect.id,
			known = known,
			text = text,
			skillId = effect.affectedSkill,
			attributeId = effect.affectedAttribute,
			icon = effect.effect.icon,
		})
	end
	return effects
end

-- the engine normalizes carried gold to gold_001, these appear placed in the world
local goldIds = {
	gold_001 = true,
	gold_005 = true,
	gold_010 = true,
	gold_025 = true,
	gold_100 = true,
	gold_dae_cursed_001 = true,
	gold_dae_cursed_005 = true,
}

local function getItemInfo(item, record, itemType, style, overrides)
	if not record then return nil end
	overrides = overrides or {}
	local info = {
		name = record.name,
		id = item and item.id or record.id,
		weight = record.weight,
		value = record.value,
		description = record.description or "",
		icon = record.icon
	}

	-- instance values, override first, live object second, plain records fake a pristine instance below
	local itemData = item and types.Item.itemData(item)
	info.condition = overrides.condition or itemData and itemData.condition
	-- a preview enchant invalidates the live charge
	info.enchantmentCharge = overrides.enchantmentCharge or overrides.charge or overrides.enchant == nil and itemData and itemData.enchantmentCharge or nil
	info.soul = overrides.soul or itemData and itemData.soul
	info.count = overrides.count or item and item.count or 1

	-- type-specific data, instance-only fields fall back to record data
	if itemType == types.Weapon then
		info.type = "weapon"
		info.condition = info.condition or record.health
		info.weaponData = getWeaponData(record, info.condition)
	elseif itemType == types.Armor then
		info.type = "armor"
		info.condition = info.condition or record.health
		info.armorData = getArmorData(record, info.condition)
	elseif itemType == types.Clothing then
		info.type = "clothing"
		info.clothingData = getClothingData(record)
	elseif itemType == types.Ingredient then
		info.type = "ingredient"
		info.ingredientEffects = getIngredientEffects(record.effects)
	elseif itemType == types.Potion then
		info.type = "potion"
		info.potionEffects = getEffects(record.effects, "potion", style.shortText, style.renameEffects)
	elseif itemType == types.Apparatus then
		info.type = "apparatus"
		info.quality = record.quality
	elseif itemType == types.Lockpick then
		info.type = "lockpick"
		info.quality = record.quality
		info.condition = info.condition or record.maxCondition
		info.uses = info.condition
	elseif itemType == types.Probe then
		info.type = "probe"
		info.quality = record.quality
		info.condition = info.condition or record.maxCondition
		info.uses = info.condition
	elseif itemType == types.Repair then
		info.type = "repair"
		info.quality = record.quality
		info.condition = info.condition or record.maxCondition
		info.uses = info.condition
	elseif itemType == types.Light then
		info.type = "light"
		info.condition = info.condition or record.duration
	elseif itemType == types.Miscellaneous then
		if goldIds[record.id] or record.isKey then
			info.value = 0
			--return nil
		end
		if record.id:sub(1, #"misc_soulgem_") == "misc_soulgem_" then
			local soulId = info.soul
			if soulId then
				local creature = types.Creature.records[soulId]
				if creature then
					info.soulName = creature.name ~= "" and creature.name or soulId
					info.soulValue = creature.soulValue
					-- mcp formula, the engine prices with it when the launcher toggle is on
					if style.soulgemRebalance then
						info.value = math.floor(0.0001 * info.soulValue ^ 3 + 2 * info.soulValue)
						-- azura's star keeps its own worth on top
						if record.id == "misc_soulgem_azura" then
							info.value = info.value + record.value
						end
					else
						info.value = math.floor(record.value * info.soulValue)
					end
				end
			end
		end
	end
	-- forced effect blocks, any item type, the key picks the formatting
	if overrides.potionEffects then
		info.potionEffects = getEffects(normalizeEffects(overrides.potionEffects), "potion", style.shortText, style.renameEffects)
	end
	if overrides.ingredientEffects then
		info.ingredientEffects = getIngredientEffects(normalizeEffects(overrides.ingredientEffects))
	end
	info.enchantment = getEnchantmentData(record, style.shortText, info.enchantmentCharge, style.renameEffects)
	-- plain records read a full charge, like the engine's untouched read
	if info.enchantment then
		info.enchantmentCharge = info.enchantmentCharge or info.enchantment.maxCharge
	end
	-- explicit overrides beat derived values
	if overrides.value then
		info.value = overrides.value
	end
	info.qualityMult = overrides.qualityMult
	-- display-ready capacity, weapon/armor/clothing/book records have it
	if record.enchantCapacity then
		info.enchantCapacity = record.enchantCapacity/0.1*core.getGMST("fEnchantmentMult")
	end

	return info
end







------------------------------ tooltip builder ------------------------------
-- these override keys resolve into info, the overlay skips them
local instanceOverrides = {
	condition = true,
	charge = true,
	enchantmentCharge = true,
	soul = true,
	count = true,
}
-- exposed @ I.SharedTooltip.createLayout, overrides, style and context documented in the header
-- style merges into a fresh copy, everything below indexes style directly
local function buildTooltipLayout(item, overrides, style, context)
	context = context or {}
	overrides = overrides or {}
	-- accept a live object, a record or a record id string
	local itemRecord, itemType
	local inputType = type(item)
	if inputType == "userdata" and item.recordId then
		itemType = item.type
		itemRecord = itemType.records[item.recordId]
	else
		local recordId = inputType == "string" and item or (inputType == "userdata" or inputType == "table") and item.id
		item = nil
		if recordId and recordId ~= "" then
			recordId = recordId:lower()
			for _, store in ipairs(itemTypeStores) do
				if store.records[recordId] then
					itemType = store
					itemRecord = store.records[recordId]
					break
				end
			end
		end
	end
	if not itemRecord then return end
	local rawRecord = itemRecord
	-- overrides shadow record and instance fields for the whole build
	if next(overrides) ~= nil then
		local overlay = {}
		for key, value in pairs(overrides) do
			if not instanceOverrides[key] then
				overlay[key] = value
			end
		end
		-- caller effect lists need their engine lookups backfilled
		if overlay.effects then
			overlay.effects = normalizeEffects(overlay.effects)
		end
		itemRecord = setmetatable({}, {__index = function(_, key)
			local value = overlay[key]
			if value ~= nil then return value end
			return rawRecord[key]
		end})
	end
	-- copy defaults, caller overrides win, styleDefaults tracks the player settings live
	local resolved = {}
	for key, value in pairs(styleDefaults) do
		resolved[key] = value
	end
	for key, value in pairs(style or {}) do
		resolved[key] = value
	end
	style = resolved
	-- borderStyle names a file and a thickness, only for the keys the caller left nil
	if style.borderFile == nil then
		style.borderFile = (style.borderStyle == "verythick" or style.borderStyle == "thick") and "thick" or "thin"
	end
	if style.borderOffset == nil then
		style.borderOffset = style.borderStyle == "verythick" and 4 or style.borderStyle == "thick" and 3 or style.borderStyle == "normal" and 2 or style.borderStyle == "none" and 0 or 1
	end
	if style.borderless == nil then
		style.borderless = style.borderStyle == "none"
	end
	-- derived values, elements read these straight off style
	style.align = style.textAlignment == "left" and ui.ALIGNMENT.Start or style.textAlignment == "right" and ui.ALIGNMENT.End or ui.ALIGNMENT.Center
	style.oppositeAlign = style.align == ui.ALIGNMENT.Start and ui.ALIGNMENT.End or style.align == ui.ALIGNMENT.End and ui.ALIGNMENT.Start or ui.ALIGNMENT.Center
	local info = getItemInfo(item, itemRecord, itemType, style, overrides)
	if not info then return end
	local backgroundImage = {
		type = ui.TYPE.Image,
		props = {
			resource = style.background,
			relativeSize  = v2(1,1),
			alpha = style.transparency,
			color = style.backgroundColor,
		}
	}
	-- borderless keeps the background but drops the frame
	local borderTemplate
	local barBorderTemplate
	if style.borderless then
		local padV = v2(1, 1) * style.padding
		-- copy the background before the padded one gets resized
		local barBackground = auxUi.deepLayoutCopy(backgroundImage)
		backgroundImage.props.size = padV * 2
		borderTemplate = {
			type = ui.TYPE.Container,
			content = ui.content {
				backgroundImage,
				{ external = { slot = true }, props = { position = padV, relativeSize = v2(1,1) } },
				-- spacer reaches past the content so the container grows around the padding
				{ props = { position = padV, relativePosition = v2(1,1), size = padV } },
			}
		}
		barBorderTemplate = {
			content = ui.content {
				barBackground,
				{ external = { slot = true }, props = { relativeSize = v2(1,1) } },
			}
		}
	else
		-- copy the background before the outset pass resizes it
		local barBackground = auxUi.deepLayoutCopy(backgroundImage)
		-- root is a Container, its frame has to reach past the content and carries the padding
		borderTemplate = makeBorder(style.borderPath, style.borderFile, style.borderColor, style.borderOffset, backgroundImage, style.padding, true)
		-- bars carry an explicit size, their frame stays inside it
		barBorderTemplate = makeBorder(style.borderPath, style.borderFile, style.borderColor, style.borderOffset, barBackground)
	end
	
	-- fallback: build tooltip natively
	local root = {
		type = ui.TYPE.Container,
		template = borderTemplate,
		props = {
		},
		content = ui.content {
		}
	}
	
	local flex = {
		type = ui.TYPE.Flex,
		name = 'tooltipFlex',
		props = {
			autoSize = true,
			arrange = style.align,
		},
		content = ui.content {
		}
	}

	root.content:add(flex)
	
	
	local function textElement(str, color, name, index)
		local element = {
			type = ui.TYPE.Text,
			name = name,
			props = {
				text = str,
				textSize = style.textSize,
				textAlignH = ui.ALIGNMENT.End,
				textAlignV = ui.ALIGNMENT.Center,
				textColor = color or style.labelColor,
				textShadow = true,
				textShadowColor = shadowColor,
				autoSize = true
			},
		}
		if index then
			if contentInsertFixed then
				flex.content:insert(math.min(index, #flex.content+1), element)
			else
				-- rebuild because insert corrupts the content keys in 0.51
				local elements = {}
				for i, child in ipairs(flex.content) do
					if i == index then
						table.insert(elements, element)
					end
					table.insert(elements, child)
				end
				if index > #flex.content then
					table.insert(elements, element)
				end
				flex.content = ui.content(elements)
			end
		else
			flex.content:add(element)
		end
	end

	-- inline color tags derived from the style colors
	local labelTag = "#"..style.labelColor:asHex()
	local valueTag = "#"..style.valueColor:asHex()

	-- condition tint: default color above half, sliding orange to red below
	local conditionOrange = util.color.rgb(0.9, 0.55, 0.1)
	local conditionRed = util.color.rgb(0.8, 0.15, 0.1)
	local function getConditionColor(current, max)
		local ratio = max > 0 and util.clamp(current/max, 0, 1) or 1
		if ratio > 0.5 then
			local t = (ratio-0.5) * 2
			return util.color.rgb(
				conditionOrange.r + (style.valueColor.r-conditionOrange.r) * t,
				conditionOrange.g + (style.valueColor.g-conditionOrange.g) * t,
				conditionOrange.b + (style.valueColor.b-conditionOrange.b) * t
			)
		end
		local t = ratio * 2
		return util.color.rgb(
			conditionRed.r + (conditionOrange.r-conditionRed.r) * t,
			conditionRed.g + (conditionOrange.g-conditionRed.g) * t,
			conditionRed.b + (conditionOrange.b-conditionRed.b) * t
		)
	end

	-- progress bar widget, the gradient setting swaps the fill texture
	local function makeBar(size, ratio, fillColor, overlayText, textColor)
		local bar = {
			type = ui.TYPE.Widget,
			name = 'bar',
			template = barBorderTemplate,
			props = {
				size = size,
			},
			content = ui.content {
				{
					type = ui.TYPE.Image,
					name = 'background',
					props = {
						resource = background,
						tileH = false,
						tileV = false,
						relativeSize = v2(1, 1),
						alpha = 0.3,
					}
				},
				{
					type = ui.TYPE.Image,
					name = 'fill',
					props = {
						resource = style.barGradient and getTexture('textures/menu_bar_gray.dds') or white,
						tileH = false,
						tileV = false,
						relativeSize = v2(util.clamp(ratio, 0, 1), 1),
						alpha = 0.8,
						color = fillColor,
					}
				},
			}
		}
		if overlayText then
			bar.content:add {
				type = ui.TYPE.Text,
				name = 'text',
				props = {
					text = overlayText,
					textSize = style.textSize,
					relativePosition = v2(0.5, 0.5),
					position = v2(0, -1),
					anchor = v2(0.5, 0.5),
					textAlignH = ui.ALIGNMENT.Center,
					textAlignV = ui.ALIGNMENT.Center,
					textColor = textColor,
					textShadow = true,
					textShadowColor = shadowColor,
				},
			}
		end
		return bar
	end

	-- builds a bar row, the caller places it and owns the spacers around it
	local function makeBarRow(labelText, labelColor, bar, rowName)
		local row = {
			type = ui.TYPE.Flex,
			name = rowName,
			props = {
				horizontal = true,
				arrange = ui.ALIGNMENT.Center,
			},
			content = ui.content {}
		}
		if labelText and style.barLabels then
			row.content:add {
				type = ui.TYPE.Text,
				name = 'label',
				props = {
					text = labelText,
					textSize = style.textSize,
					size = v2(0, style.textSize),
					textAlignH = ui.ALIGNMENT.Center,
					textColor = labelColor,
					textShadow = true,
					textShadowColor = shadowColor,
				},
			}
			row.content:add{ name = 'spacer', props = { size = v2(math.floor(style.textSize*0.25), 0) } }
		end
		row.content:add(bar)
		return row
	end

	local name = info.name
	local count = info.count
	if count and count > 1 then
		name = name.." ("..count..")"
	end
	-- the soulValue setting moves the soul into its own line in full mode
	if info.soulName and (style.compact or not style.soulValue) then
		name = name.." ("..info.soulName..")"
	end
	textElement(name, style.nameColor, 'name')

	flex.content:add{ name = 'nameSpacer', props = { size = v2(0, 1) } }
	
	if info.uses then
		textElement(labelTag..core.getGMST("sUses")..": "..valueTag..math.floor(info.uses), nil, 'uses')
	end

	if info.quality then
		-- engine prints two decimals and trims the zeros
		textElement(labelTag..core.getGMST("sQuality")..": "..valueTag..(string.format("%.2f", info.quality):gsub("%.?0+$", "")), nil, 'quality')
	end

	if info.type == "armor" then
		-- in compact view, the armor skill is the first line (like weaponType)
		if info.armorData.skillName and style.compact then
			textElement(labelTag..info.armorData.skillName, nil, 'armorClass')
		end
		textElement(labelTag..core.getGMST("sArmorRating")..": "..valueTag..math.floor(info.armorData.playerArmor), nil, 'armorRating')
	end
	
	if info.type == "weapon" then
		-- engine leads with sType and spaces the damage ranges, shortText drops both
		local typePrefix = style.shortText and "" or core.getGMST("sType").." "
		local dmgSep = style.shortText and "-" or " - "
		textElement(labelTag..typePrefix..info.weaponData.typeName, nil, 'weaponType')
		if info.weaponData.typeName == core.getGMST("sSkillMarksman") then
			-- thrown weapons hit as weapon and ammo at once, the engine doubles the display
			local mult = info.weaponData.type == types.Weapon.TYPE.MarksmanThrown and 2 or 1
			textElement(labelTag..core.getGMST("sAttack")..": "..valueTag..(info.weaponData.damage.chopMin*mult)..dmgSep..(info.weaponData.damage.chopMax*mult), nil, 'attack')
		else
			textElement(labelTag..core.getGMST("sChop")..": "..valueTag..info.weaponData.damage.chopMin..dmgSep..info.weaponData.damage.chopMax, nil, 'chop')
			textElement(labelTag..core.getGMST("sSlash")..": "..valueTag..info.weaponData.damage.slashMin..dmgSep..info.weaponData.damage.slashMax, nil, 'slash')
			textElement(labelTag..core.getGMST("sThrust")..": "..valueTag..info.weaponData.damage.thrustMin..dmgSep..info.weaponData.damage.thrustMax, nil, 'thrust')
		end
	end
	
	local weaponOrArmor = info.weaponData or info.armorData
	
	-- bar modes replace the condition text, "bar (above enchantments)" renders above the enchantment block, "bar (bottom)" below the charge bar
	local enchantConditionBar, bottomConditionBar
	if weaponOrArmor and weaponOrArmor.durability and style.durabilityDisplay ~= "none" then
		local durability = weaponOrArmor.durability
		local ratio = durability.max > 0 and durability.current/durability.max or 1
		local function addConditionBar()
			local barText = math.floor(durability.current+0.5).." / "..math.floor(durability.max+0.5)
			local bar = makeBar(v2(style.barWidth, style.textSize), ratio, style.durabilityBarColor, barText, style.labelColor)
			-- sCharges carries its own colon, sCondition does not
			local row = makeBarRow(core.getGMST("sCondition")..":", style.labelColor, bar, 'conditionBar')
			row.content:add{ name = 'rightSpacer', props = { size = v2(5, 0) } }
			flex.content:add{ name = 'conditionBarTopSpacer', props = { size = v2(0, 1) } }
			flex.content:add(row)
			flex.content:add{ name = 'conditionBarBottomSpacer', props = { size = v2(0, 1) } }
		end
		if style.durabilityDisplay == "bar" then
			addConditionBar()
		elseif style.durabilityDisplay == "bar (above enchantments)" then
			enchantConditionBar = addConditionBar
		elseif style.durabilityDisplay == "bar (bottom)" then
			bottomConditionBar = addConditionBar
		else
			local conditionTag = style.durabilityDisplay == "vanilla" and valueTag or "#"..getConditionColor(durability.current, durability.max):asHex()
			textElement(labelTag..core.getGMST("sCondition")..": "..conditionTag..math.floor(durability.current+0.5)..valueTag.."/"..math.floor(durability.max+0.5), nil, 'condition')
		end
	end

	if style.enchantCapacity and info.enchantCapacity and info.enchantCapacity > 0 and not info.enchantment then
		textElement(labelTag..core.getGMST("sEnchanting")..": "..valueTag..math.floor(info.enchantCapacity), nil, 'enchantCapacity')
	end

	-- ammo has no meaningful reach, attack speed or charge
	local isProjectile = info.weaponData and (info.weaponData.type == types.Weapon.TYPE.Arrow
		or info.weaponData.type == types.Weapon.TYPE.Bolt
		or info.weaponData.type == types.Weapon.TYPE.MarksmanThrown)

	if info.type == "weapon" and not isProjectile and style.weaponRange then
		textElement(labelTag..core.getGMST("sRange")..": "..valueTag..(math.floor((info.weaponData.reach*6.05)*10)/10).." "..core.getGMST("sfootarea"), nil, 'range')
	end
	if info.type == "weapon" and not isProjectile and style.weaponSpeed then
		textElement(labelTag..core.getGMST("sAttributeSpeed")..": "..valueTag..math.floor((info.weaponData.speed)*100+0.5).."%", nil, 'speed')
	end

	if not style.compact then
		if info.soulName and style.soulValue then
			textElement(labelTag.."Soul: "..valueTag..info.soulName.." ("..info.soulValue..")", nil, 'soul')
		end
		if info.weight and info.weight > 0 then
			local suffix = info.armorData and (" ("..info.armorData.class..")") or ""
			textElement(labelTag..core.getGMST("sWeight")..": "..valueTag..formatNumber(info.weight, "weight", style.fontFix)..suffix, nil, 'weight')
		end

		if info.value and info.value > 0 then
			textElement(labelTag..core.getGMST("sValue")..": "..valueTag..formatNumber(info.value, "value", style.fontFix), nil, 'value')
		end
	end
	
	-- crafting quality percent, red when below vanilla
	if info.qualityMult and info.qualityMult ~= 1 then
		local qualityTag = "#"..(info.qualityMult < 1 and util.color.rgb(1, 0.4, 0.4) or style.valueColor):asHex()
		textElement(labelTag..core.getGMST("sQuality")..": "..qualityTag..math.floor(info.qualityMult*100+0.5).."%", nil, 'qualityMult')
	end

	-- after stat lines, before special blocks
	flex.content:add{ name = 'anchorStats', props = { size = v2(0, 0) } }
	
	-- right aligned tooltips mirror the rows so icons sit on the flush edge
	local mirrored = style.align == ui.ALIGNMENT.End
	style.effectAlignment = style.alignedEffects and (mirrored and ui.ALIGNMENT.End or ui.ALIGNMENT.Start) or style.align
	-- new named group in the main flex, printEffects fills it
	local function addEffectGroup(groupName)
		local group = {
			type = ui.TYPE.Flex,
			name = groupName,
			props = {
				-- flush list when aligned, each row follows the tooltip alignment otherwise
				arrange = style.effectAlignment,
			},
			content = ui.content({})
		}
		flex.content:add(group)
		return group
	end

	-- fills target with rows from a parsed effect list (info form)
	local function printEffects(target, effects, isAlchemy, color, alchemySkill)
		local skill = alchemySkill or context.alchemySkill or types.Player.stats.skills.alchemy(self).modified
		local gmst = core.getGMST("fWortChanceValue")
		for i,effect in ipairs(effects) do
			-- per effect known flag beats the index gate
			local known = effect.known
			if known == nil then
				if not isAlchemy then
					known = true
				elseif isAlchemy == "potion" then
					-- the engine reveals potion effects in pairs, ingredients one per step
					known = skill >= gmst * math.ceil(i/2)
				else
					known = skill >= i * gmst
				end
			end
			if known then
				local effectFlex2 ={
					type = ui.TYPE.Flex,
					name = (target.name or 'effect')..i,
					props = {
						horizontal = true,
					},
					content = ui.content({})
				}
				target.content:add(effectFlex2)
				local rowIndent = { name = 'indentSpacer', props = { size = v2(2, 0) } }
				local rowIcon = {
					type = ui.TYPE.Image,
					name = 'icon',
					props = {
						resource = getTexture(effect.icon),
						tileH = false,
						tileV = false,
						size = v2(style.textSize-1,style.textSize-1),
						alpha = 0.7,
					}
				}
				local rowSpacer = { name = 'spacer', props = { size = v2(math.floor(style.textSize*0.25), 0) } }
				local rowText = {
					type = ui.TYPE.Text,
					name = 'text',
					props = {
						text = effect.text,
						textSize = style.textSize,
						size = v2(0,style.textSize),
						textAlignH = ui.ALIGNMENT.Center,
						textColor = color or style.labelColor,
						textShadow = true,
						textShadowColor = shadowColor,
					},
				}
				if mirrored then
					effectFlex2.content:add(rowText)
					effectFlex2.content:add(rowSpacer)
					effectFlex2.content:add(rowIcon)
					effectFlex2.content:add(rowIndent)
				else
					effectFlex2.content:add(rowIndent)
					effectFlex2.content:add(rowIcon)
					effectFlex2.content:add(rowSpacer)
					effectFlex2.content:add(rowText)
				end
			else
				-- unknown effect, row stays inside the group so the order holds
				local unknownFlex = {
					type = ui.TYPE.Flex,
					name = (target.name or 'effect')..i,
					props = {
						horizontal = true,
					},
					content = ui.content({})
				}
				target.content:add(unknownFlex)
				-- "?" sits in the text column
				--local unknownIndent = { name = 'indentSpacer', props = { size = v2(2 + style.textSize-1 + math.floor(style.textSize*0.25), 1) } }
				-- "?" sits in the icon column
				local unknownIndent = { name = 'indentSpacer', props = { size = style.effectAlignment == ui.ALIGNMENT.Center and v2(0, 0) or v2(7, 0) } }
				local unknownText = {
					type = ui.TYPE.Text,
					name = 'text',
					props = {
						text = "?",
						textSize = style.textSize,
						size = v2(0,style.textSize),
						textAlignH = ui.ALIGNMENT.Center,
						textColor = color or style.labelColor,
						textShadow = true,
						textShadowColor = shadowColor,
					},
				}
				if mirrored then
					unknownFlex.content:add(unknownText)
					unknownFlex.content:add(unknownIndent)
				else
					unknownFlex.content:add(unknownIndent)
					unknownFlex.content:add(unknownText)
				end
			end
			-- gap after every row, the last one included
			target.content:add{ name = 'effectSpacer'..i, props = { size = v2(0, style.effectSpacing) } }
		end
	end

	-- condition bar right above the enchantment block
	if enchantConditionBar then
		enchantConditionBar()
	end

	if info.enchantment then
		textElement(info.enchantment.typeName or "???", style.enchantBlockColor, 'enchantType')
		printEffects(addEffectGroup('enchantEffects'), info.enchantment.effects, nil, style.enchantBlockColor)
		if info.enchantment.charge and not isProjectile and style.chargeDisplay ~= "none" then
			local chargeColor = style.enchantBlockColor or style.labelColor
			local chargeText = math.floor(info.enchantment.charge.current).." / "..math.floor(info.enchantment.charge.max)
			-- autocalc can price a trivial enchantment at 0 charge, avoid 0/0
			local chargeRatio = info.enchantment.charge.max > 0 and info.enchantment.charge.current/info.enchantment.charge.max or 1
			local bar = makeBar(v2(style.barWidth, style.textSize), chargeRatio, style.chargeBarColor, chargeText, chargeColor)
			local row = makeBarRow(core.getGMST("sCharges"), chargeColor, bar, 'charge')
			-- cast cost per use next to the bar, fixed width so the row width is known
			if style.useCost and info.enchantment.useCost then
				local costText = "-"..info.enchantment.useCost
				local costWidth = math.floor(style.textSize*#costText*0.8)
				local costGap = math.floor(style.textSize*0.25)
				local costSpacer = { name = 'useCostSpacer', props = { size = v2(costGap, 0) } }
				local costText = {
					type = ui.TYPE.Text,
					name = 'useCost',
					props = {
						autoSize = false,
						text = costText,
						textSize = style.textSize-2,
						size = v2(costWidth, style.textSize),
						textAlignH = mirrored and ui.ALIGNMENT.End or ui.ALIGNMENT.Start,
						textAlignV = ui.ALIGNMENT.Start,
						textColor = chargeColor,
						textShadow = true,
						textShadowColor = shadowColor,
					},
				}
				if mirrored then
					-- right aligned: cost left of the bar keeps both bars flush on the edge
					local elements = {}
					for _, child in ipairs(row.content) do
						if child.name == 'bar' then
							table.insert(elements, costText)
							table.insert(elements, costSpacer)
						end
						table.insert(elements, child)
					end
					row.content = ui.content(elements)
				else
					-- centered: a counterweight on the far side keeps the bar in the middle
					if style.align == ui.ALIGNMENT.Center then
						local elements = { { name = 'useCostCounterweight', props = { size = v2(costWidth + costGap, 0) } } }
						for _, child in ipairs(row.content) do
							table.insert(elements, child)
						end
						row.content = ui.content(elements)
					end
					row.content:add(costSpacer)
					row.content:add(costText)
				end
			end

			row.content:add{ name = 'rightSpacer', props = { size = v2(5, 0) } }
			flex.content:add{ name = 'chargeTopSpacer', props = { size = v2(0, 1) } }
			flex.content:add(row)
			-- the bottom conditionBar carries its own top spacer
			flex.content:add{ name = 'chargeBottomSpacer', props = { size = v2(0, bottomConditionBar and 0 or 1) } }
		end
	end

	-- condition bar right below the charge bar
	if bottomConditionBar then
		bottomConditionBar()
	end

	if info.potionEffects then
		flex.content:add{ name = 'potionEffectsSpacer', props = { size = v2(0, 1) } }
		printEffects(addEffectGroup('potionEffects'), info.potionEffects, "potion")
	end
	
	if info.ingredientEffects then
		flex.content:add{ name = 'ingredientEffectsSpacer', props = { size = v2(0, 1) } }
		printEffects(addEffectGroup('ingredientEffects'), info.ingredientEffects, "ingredient")
	end
	
	-- mod anchor: after special blocks (enchant/potion/ingredient)
	flex.content:add{ name = 'anchorEffects', props = { size = v2(0, 0) } }

	-- stat loft: spare stat row above the real one, zero height until a mod fills it
	local statLoftSpacer = { name = 'statLoftSpacer', props = { size = v2(0, 0) } }
	local statLoftFlex = {
		type = ui.TYPE.Flex,
		name = 'statLoft',
		props = {
			horizontal = true,
			align = style.oppositeAlign,
			arrange = ui.ALIGNMENT.Center,
		},
		external = {
			stretch = 1,
		},
		content = ui.content {}
	}
	flex.content:add(statLoftSpacer)
	flex.content:add(statLoftFlex)

	-- stat row
	local statRowFlex = {
		type = ui.TYPE.Flex,
		name = 'statRow',
		props = {
			horizontal = true,
			align = style.oppositeAlign,
			arrange = ui.ALIGNMENT.Center,
		},
		-- stretch full width so align has room to push to the far side
		external = {
			stretch = 1,
		},
		content = ui.content {}
	}

	local statRowSpacer = { name = 'statRowSpacer', props = { size = v2(0, 0) } }
	flex.content:add(statRowSpacer)
	flex.content:add(statRowFlex)

	-- shared divider under the stat row, custom lines below enable it, modifiers via ctx.enableDivider
	local dividerTopSpacer = { name = 'dividerTopSpacer', props = { size = v2(0, 0) } }
	local dividerLine = {
		type = ui.TYPE.Image,
		name = 'divider',
		props = {
			resource = getTexture(style.borderPath.."menu_thin_border_bottom.dds"),
			tileH = false,
			tileV = false,
			size = v2(0, 0),
			color = style.borderColor,
			alpha = 0,
		},
		external = {
			stretch = 1,
		},
	}
	local dividerBottomSpacer = { name = 'dividerBottomSpacer', props = { size = v2(0, 0) } }
	flex.content:add(dividerTopSpacer)
	flex.content:add(dividerLine)
	flex.content:add(dividerBottomSpacer)

	local function enableDivider()
		dividerTopSpacer.props.size = v2(0, 3)
		dividerLine.props.size = v2(0, 1)
		dividerLine.props.alpha = 0.4
		dividerBottomSpacer.props.size = v2(0, 2)
	end

	-- caller supplied free line, sits under the divider
	if overrides.customLine then
		enableDivider()
		textElement(overrides.customLine, overrides.customLineColor, 'customLine')
	end

	-- I.SharedTooltip.registerLine
	local lineCtx = {}
	for key, value in pairs(context) do
		lineCtx[key] = value
	end
	lineCtx.item = item
	lineCtx.info = info
	lineCtx.record = itemRecord
	lineCtx.rawRecord = rawRecord
	lineCtx.itemType = itemType
	lineCtx.compact = style.compact
	lineCtx.style = style
	lineCtx.overrides = overrides
	lineCtx.labelTag = labelTag
	lineCtx.valueTag = valueTag
	for i, entry in ipairs(tooltipLineChain.entries) do
		local text = entry.func(lineCtx)
		if text then
			enableDivider()
			textElement(text, nil, 'chainLine'..i)
		end
	end

	-- bottom stat row
	local function addStat(tex, valueStr, statName, color)
		-- the first stat earns the row its gap
		statRowSpacer.props.size = v2(0, 2)
		-- stat icon
		local statIcon = {
			type = ui.TYPE.Image,
			name = statName..'Icon',
			props = {
				resource = tex,
				tileH = false,
				tileV = false,
				size = v2(style.textSize, style.textSize),
				alpha = 0.8,
				color = color,
			}
		}
		-- stat value
		local statText = {
			type = ui.TYPE.Text,
			name = statName..'Text',
			props = {
				text = tostring(valueStr),
				textSize = style.textSize,
				textColor = style.valueColor,
				textShadow = true,
				textShadowColor = shadowColor,
			}
		}
		local statSpacer = { name = statName..'Spacer', props = { size = v2(math.floor(style.textSize*0.25), 0) } }
		local statSeparator = { name = statName..'Separator', props = { size = v2(7, 0) } }
		-- reverse if right aligned
		if style.oppositeAlign == ui.ALIGNMENT.End then
			if contentInsertFixed then
				statRowFlex.content:insert(1, statSeparator)
				statRowFlex.content:insert(1, statText)
				statRowFlex.content:insert(1, statSpacer)
				statRowFlex.content:insert(1, statIcon)
			else
				-- rebuild because insert corrupts the content keys in 0.51
				local elements = { statIcon, statSpacer, statText, statSeparator }
				for _, child in ipairs(statRowFlex.content) do
					table.insert(elements, child)
				end
				statRowFlex.content = ui.content(elements)
			end
		else
			statRowFlex.content:add(statSeparator)
			statRowFlex.content:add(statIcon)
			statRowFlex.content:add(statSpacer)
			statRowFlex.content:add(statText)
		end
	end

	if style.compact then
		if info.value and info.value > 0 then
			addStat(style.valueTex, formatNumber(info.value, "value", style.fontFix), 'value', style.compactIconColor)
		end
		if info.weight and info.weight > 0 then
			addStat(style.weightTex, formatNumber(info.weight, "weight", style.fontFix), 'weight', style.compactIconColor)
		end
		if info.soulValue and style.soulValue then
			addStat(getTexture("textures/SharedTooltip/soul.dds"), info.soulValue, 'soul')
		end
	end

	-- I.SharedTooltip.registerModifier
	local modCtx = {}
	for key, value in pairs(context) do
		modCtx[key] = value
	end
	modCtx.root = root
	modCtx.flex = flex
	modCtx.statLoft = statLoftFlex
	modCtx.enableDivider = enableDivider
	modCtx.textElement = textElement
	modCtx.addStat = addStat
	modCtx.addEffectGroup = addEffectGroup
	modCtx.printEffects = printEffects
	modCtx.normalizeEffects = normalizeEffects
	modCtx.getMaxEnchantmentCharge = getMaxEnchantmentCharge
	modCtx.makeBar = makeBar
	modCtx.makeBarRow = makeBarRow
	modCtx.getConditionColor = getConditionColor
	modCtx.formatNumber = formatNumber
	modCtx.mirrored = mirrored
	modCtx.item = item
	modCtx.info = info
	modCtx.record = itemRecord
	modCtx.rawRecord = rawRecord
	modCtx.itemType = itemType
	modCtx.compact = style.compact
	modCtx.style = style
	modCtx.overrides = overrides
	modCtx.labelTag = labelTag
	modCtx.valueTag = valueTag
	modCtx.print = print
	for i, entry in ipairs(tooltipModifierChain.entries) do
		local ok, result = pcall(entry.func, modCtx)
		if not ok then
			print(result)
		elseif result == false then
			break
		end
	end

	if #statLoftFlex.content > 0 then
		statLoftSpacer.props.size = v2(0, 2)
	end

	return root
end

------------------------------ tracked tooltips ------------------------------
local trackedTooltips = {}

-- I.SharedTooltip.create
local function createTooltip(item, overrides, style, context)
	local layout = buildTooltipLayout(item, overrides, style, context)
	if not layout then return end
	local handle = {
		element = ui.create(layout),
		item = item,
		overrides = overrides,
		style = style,
		context = context,
	}
	function handle.rebuild()
		if not trackedTooltips[handle] then return end
		local ok, err = pcall(function()
			local old = handle.element.layout
			-- args read off the handle
			local fresh = buildTooltipLayout(handle.item, handle.overrides, handle.style, handle.context)
			if not fresh then return end
			fresh.name = old.name
			fresh.props = old.props
			handle.element.layout = fresh
			handle.element:update()
			auxUi.deepDestroy(old)
		end)
		if not ok then
			trackedTooltips[handle] = nil
			print("SharedTooltip: rebuild failed, dropping tooltip: "..tostring(err))
		end
	end
	function handle.destroy()
		if handle.destroyed then return end
		handle.destroyed = true
		trackedTooltips[handle] = nil
		auxUi.deepDestroy(handle.element)
	end
	trackedTooltips[handle] = true
	return handle
end

-- I.SharedTooltip.activeTooltips
local function getActiveTooltips()
	local list = {}
	for handle in pairs(trackedTooltips) do
		table.insert(list, handle)
	end
	return list
end

------------------------------ settings preview ------------------------------
local previewTip
local previewShell
local previewDeadline = 0
local previewTickArmed = false
-- setAutoPreview(false) lets mods write our settings without popping the sample
local autoPreview = true
-- dragged sample spot, dedicated section, no settings page
local previewPosSection = storage.playerSection("SharedTooltipPreviewPosition")

local function destroySettingsPreview()
	if not previewTip then return end
	auxUi.deepDestroy(previewShell)
	previewTip.destroy()
	previewShell = nil
	previewTip = nil
end

-- keeps a grabbable strip by the anchor corner on screen
local function clampPreviewPos(pos)
	-- layer size is in scaled ui space, screenSize would be real pixels
	local screen = ui.layers[ui.layers.indexOf('Popup')].size
	return v2(
		math.max(40 - screen.x, math.min(0, pos.x)),
		math.max(0, math.min(screen.y - 40, pos.y))
	)
end

-- exposed @ I.SharedTooltip.showPreview, args optional
local function showSettingsPreview(item, overrides, style, context)
	previewDeadline = core.getRealTime() + 5
	-- no args and already exists - refresh
	if previewTip and not item then
		previewTip.rebuild()
		previewShell:update()
		return
	end
	-- no args and doesnt exist yet - init
	if not item then
		local record = types.Weapon.records["mace of molag bal_unique"]
		if not record then return end
		item = "mace of molag bal_unique"
		overrides = {
			condition = math.floor(record.health * 0.65),
		}
		local enchantmentRecord = record.enchant and core.magic.enchantments.records[record.enchant:lower()]
		if enchantmentRecord then
			overrides.enchantmentCharge = math.floor(getMaxEnchantmentCharge(enchantmentRecord) * 0.4)
		end
		context = {source = "SharedTooltip"}
	end
	-- with args: caller requested custom tooltip
	if previewTip then
		previewTip.item = item
		previewTip.overrides = overrides
		previewTip.style = style
		previewTip.context = context
		previewTip.rebuild()
		previewShell:update()
		return
	end
	previewTip = createTooltip(item, overrides, style, context)
	if not previewTip then return end
	previewShell = ui.create {
		layer = 'Popup',
		type = ui.TYPE.Container,
		props = {
			relativePosition = v2(1, 0),
			anchor = v2(1, 0),
			position = clampPreviewPos(v2(previewPosSection:get("x") or -8, previewPosSection:get("y") or 8)),
		},
		userData = {
			isDragging = false,
			lastMousePos = v2(0, 0),
		},
		events = {
			mousePress = async:callback(function(data, layout)
				if data.button == 1 then
					layout.userData.isDragging = true
					layout.userData.lastMousePos = data.position
					previewDeadline = core.getRealTime() + 5
				end
			end),
			mouseRelease = async:callback(function(data, layout)
				if layout.userData.isDragging then
					layout.userData.isDragging = false
					local pos = layout.props.position
					previewPosSection:set("x", pos.x)
					previewPosSection:set("y", pos.y)
				end
			end),
			mouseMove = async:callback(function(data, layout)
				if not layout.userData.isDragging then return end
				local delta = data.position - layout.userData.lastMousePos
				layout.userData.lastMousePos = data.position
				layout.props.position = clampPreviewPos(layout.props.position + delta)
				previewShell:update()
				previewDeadline = core.getRealTime() + 5
			end),
		},
		content = ui.content {previewTip.element},
	}
	if not previewTickArmed then
		previewTickArmed = true
		self:sendEvent('OwnlysSharedTooltipTick')
	end
end

-- one self sent event per frame while the preview lives, delivery ignores pause
local function onPreviewTick()
	previewTickArmed = false
	if not previewTip then return end
	if core.getRealTime() >= previewDeadline then
		destroySettingsPreview()
		return
	end
	previewTickArmed = true
	self:sendEvent('OwnlysSharedTooltipTick')
end

-- changed settings land in styleDefaults
for _, template in pairs(settingsTemplate) do
	local section = storage.playerSection(template.key)
	section:subscribe(async:callback(function(_, key)
		-- a newer copy took over after we loaded, the reactive side retires
		if I.SharedTooltip and I.SharedTooltip.version ~= MY_VERSION then return end
		-- keyless section:reset() pushes error right here, deservedly
		styleDefaults[key] = section:get(key)
		for handle in pairs(trackedTooltips) do
			if handle ~= previewTip then
				handle.rebuild()
			end
		end
		if autoPreview then
			showSettingsPreview() -- handle == previewTip
		end
	end))
end

return {
	interfaceName = "SharedTooltip",
	interface = {
		version = MY_VERSION,
		createLayout = buildTooltipLayout,
		create = createTooltip,
		activeTooltips = getActiveTooltips,
		showPreview = showSettingsPreview,
		setAutoPreview = function(enabled) autoPreview = enabled end,
		registerLine = tooltipLineChain.register,
		unregisterLine = tooltipLineChain.unregister,
		registerModifier = tooltipModifierChain.register,
		unregisterModifier = tooltipModifierChain.unregister,
	},
	eventHandlers = {
		OwnlysSharedTooltipTick = onPreviewTick,
	},
}