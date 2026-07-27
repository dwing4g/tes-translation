types = require('openmw.types')
NPC = require('openmw.types').NPC
core = require('openmw.core')
storage = require('openmw.storage')
MODNAME = "OwnlysQuickLoot"
--playerSection = storage.playerSection('SettingsPlayer'..MODNAME)
I = require("openmw.interfaces")
self = require("openmw.self")
nearby = require('openmw.nearby')
camera = require('openmw.camera')
Camera = require('openmw.interfaces').Camera
util = require('openmw.util')
ui = require('openmw.ui')
auxUi = require('openmw_aux.ui')
async = require('openmw.async')
vfs = require('openmw.vfs')
KEY = require('openmw.input').KEY
input = require('openmw.input')
v2 = util.vector2
v3 = util.vector3
local animation = require('openmw.animation')
local Controls = require('openmw.interfaces').Controls

if not core.mwscripts then
	ui.showMessage("QuickLoot requires OpenMW 0.50 or newer")
	return
end

qlppInstalled = vfs.fileExists("scripts/OwnlysQuickLoot/ql_pickpocket_overhaul.lua")

require("scripts.OwnlysQuickLoot.ql_settings")
makeBorder = require("scripts.OwnlysQuickLoot.ql_makeborder")
local helpers = require("scripts.OwnlysQuickLoot.ql_helpers")
readFont, texText, rgbToHsv, hsvToRgb,fromutf8,toutf8,hextoutf8,formatNumber,tableContains = unpack(helpers)
background = ui.texture { path = 'black' }
white = ui.texture { path = 'white' }
valueTex = ui.texture { path = 'textures/QuickLoot/coins.dds' }
valueByWeightTex = ui.texture { path = 'textures/QuickLoot/scale.dds' }
backpackTex = ui.texture { path = 'textures/QuickLoot/backpack.dds' }
weightTex = ui.texture { path = 'textures/QuickLoot/weight.dds' }
pickpocketTex =   ui.texture { path = 'textures/QuickLoot/pick3.png' }
pickpocketTex2 =   ui.texture { path = 'textures/QuickLoot/pickpocket_halo1.dds' }
pickpocketTex3 =   ui.texture { path = 'textures/QuickLoot/pickpocket_halo2.dds' }
fSymbolicTex =   ui.texture { path = 'textures/QuickLoot/F_symbolic.dds' }
rSymbolicTex =   ui.texture { path = 'textures/QuickLoot/R_symbolic.dds' }
fKeyTex =   ui.texture { path = 'textures/QuickLoot/F.dds' }
rKeyTex =   ui.texture { path = 'textures/QuickLoot/R.dds' }
handTex =   ui.texture { path = 'textures/QuickLoot/hand.dds' }

------------------------------ keybinding hint icons ------------------------------
local usingGamepad = false

-- openmw key code -> glyph for keys that have a generated icon
local keyGlyph = {}
for byte = string.byte("A"), string.byte("Z") do
	keyGlyph[KEY[string.char(byte)]] = string.char(byte)
end
for digit = 0, 9 do
	keyGlyph[KEY["_"..digit]] = tostring(digit)
end
keyGlyph[KEY.Minus] = "-"
keyGlyph[KEY.Equals] = "="
keyGlyph[KEY.LeftBracket] = "["
keyGlyph[KEY.RightBracket] = "]"
keyGlyph[KEY.BackSlash] = "\\"
keyGlyph[KEY.Semicolon] = ";"
keyGlyph[KEY.Apostrophe] = "'"
keyGlyph[KEY.Comma] = ","
keyGlyph[KEY.Period] = "."
keyGlyph[KEY.Slash] = "/"
keyGlyph[KEY.Space] = " "

-- sdl mouse button -> art file
local mouseArt = {
	[1] = "mouse_m1",
	[2] = "mouse_m3",
	[3] = "mouse_m2",
	[4] = "mouse_m4",
	[5] = "mouse_m5",
}

-- engine defaults
local hintDefaults = {
	ToggleWeapon = { keyboard = KEY.F, controller = input.CONTROLLER_BUTTON.X },
	ToggleSpell = { keyboard = KEY.R, controller = input.CONTROLLER_BUTTON.Y },
}

local keyIconCache = {}

-- keybind hint if you've configured a custom QL key or default
local function resolveHint(action, override)
	local device, button
	if override then
		-- quickloot encoding: >=1000 gamepad, <0 mouse, else keyboard
		if override >= 1000 then
			device, button = "controller", override - 1000
		elseif override < 0 then
			device, button = "mouse", -override
		else
			device, button = "keyboard", override
		end
	else
		local default = hintDefaults[action]
		device = usingGamepad and "controller" or "keyboard"
		button = usingGamepad and default.controller or default.keyboard
	end
	
	local path
	if device == "keyboard" then
		local glyph = keyGlyph[button]
		if glyph then
			path = ("textures/QuickLoot/keys/%04X.png"):format(string.byte(glyph))
		end
	elseif device == "mouse" then
		local art = mouseArt[button]
		if art then
			path = "textures/QuickLoot/keys/"..art..".png"
		end
	else
		path = ("textures/QuickLoot/keys/%d.png"):format(1000 + button)
	end
	if not path or not vfs.fileExists(path) then
		return nil
	end
	keyIconCache[path] = keyIconCache[path] or ui.texture { path = path }
	return keyIconCache[path]
end
------------------------------------------------------------

inspectedContainer = nil
crimesVersion = 0
local selectedIndex = 1
local backupSelectedIndex = 1
local scrollPos = 1
local backupSelectedContainer = nil
local depositSelectedIndex = 1
local depositBackupSelectedIndex = 1
local depositScrollPos = 1
local containerItems = {}
local containerGroups = {}
uiLoc = v2(X/100,Y/100)
uiSize = v2(WIDTH/100,HEIGHT/100)
textSizeMult = (ui.screenSize().y/1200*(uiSize.y/0.4))^0.5*TEXTSIZEMULT/100
local textureCache = {}
local bookSection = storage.playerSection('ReadBooks3'..MODNAME)
local bookTimer = 0
local currentBook = nil
local encumbranceCurrent = 0
local organicContainers = {
	barrel_01_ahnassi_drink=true,
	barrel_01_ahnassi_food =true,
	com_chest_02_fg_supply =true,
	com_chest_02_mg_supply =true,
	flora_treestump_unique =true,
}
modEnabled = true
modDisableFlags = {}
local shiftPressed = false
local layerId = ui.layers.indexOf("HUD")
uiWidth = ui.layers[layerId].size.x 
uiHeight = ui.layers[layerId].size.y
local screenres = ui.screenSize()
local uiScale = screenres.x / uiWidth

-- ------------------------------ loose aiming ------------------------------
local looseAimOffsets = {}
do
	local aspect = screenres.x / screenres.y
	local rings = {
		{ radius = 0.006, points = 8 },
		{ radius = 0.011, points = 8, stagger = math.pi / 8 },
	}
	for _, ring in ipairs(rings) do
		for i = 1, ring.points do
			local angle = (2 * math.pi / ring.points) * i + (ring.stagger or 0)
			looseAimOffsets[#looseAimOffsets + 1] = v2(
				0.5 + ring.radius * math.cos(angle),
				0.5 + ring.radius * math.sin(angle) * aspect
			)
		end
	end
end
local looseAimSlots = {}
local looseAimCursor = 1
-- ------------------------------------------------------------------------

local function buildTooltipArgs(item, isPickpocketing, style, deposit)
	local merged = {
		textAlignment = TOOLTIPS_TEXT_ALIGNMENT,
		compact = TOOLTIPS_COMPACT,
		shortText = TOOLTIPS_SHORT_TEXT,
		thousandsSeparator = THOUSANDS_SEPARATOR,
	}
	if TOOLTIPS_MATCH_HUD then
		merged.transparency = TRANSPARENCY
		merged.borderStyle = BORDER_STYLE
		merged.textSize = itemFontSize*textSizeMult
	end
	if BORDER_FIX then
		merged.borderPath = "textures/QuickLoot/ql_makeborder/"
	end
	for key, value in pairs(style or {}) do
		merged[key] = value
	end
	
	local context = {
		source = "QuickLoot",
		isPickpocketing = isPickpocketing,
		deposit = deposit,
	}
	
	--[[
	------------------ ENCHANT OVERRIDE TEST ------------------
	local overrides = {value = 9000}
	if item.type == types.Weapon or item.type == types.Armor or item.type == types.Clothing then
		local record = item.type.records[item.recordId]
		if record.enchant and core.magic.enchantments.records[record.enchant] then
			local enchantRecord = core.magic.enchantments.records[record.enchant]
		
			local enchant = {
				type = enchantRecord.type,
				cost = enchantRecord.cost,
				charge = enchantRecord.charge,
				autocalc = enchantRecord.isAutocalc,
				effects = {},
			}
	
			for i, eff in ipairs(enchantRecord.effects) do
				enchant.effects[i] = {
					id = eff.id,
					range = eff.range,
					area = eff.area,
					duration = 300,
					affectedSkill = eff.affectedSkill,
					affectedAttribute = eff.affectedAttribute,
					magnitudeMin = (eff.magnitudeMin or 0) * 2,
					magnitudeMax = (eff.magnitudeMax or 0) * 2,
				}
			end
			overrides = overrides or {}
			overrides.enchant = enchant
		end
	end
	
	------------------------------ GOLD IS A HEALING POTION TEST ------------------------------
	if item.recordId == "gold_001" then
		local healEffect = {
			id = "restorehealth",
			duration = 5,
			magnitudeMin = 10,
			magnitudeMax = 20,
		}
 
		overrides = overrides or {}
		overrides.potionEffects = { healEffect }
		context.alchemySkill = math.huge
	end
	------------------------------------------------------------
	--]]
	
	return overrides, merged, context
end

-- places the tooltip next to the hud, tracked element in a host owned placement shell
local function makeTooltip(item, highlightPosition, isPickpocketing, deposit, style)
	if TOOLTIPS_MODE == "off" then return end
	local overrides, merged, context = buildTooltipArgs(item, isPickpocketing, style, deposit)
	local handle = I.SharedTooltip.create(item, overrides, merged, context)
	if not handle then return end
	local tooltipLayer = "Notification"
	if core.isWorldPaused() then
		tooltipLayer = "HUD"
	end
	local hudLayerSize = ui.layers[ui.layers.indexOf("HUD")].size
	local rootWidth = hudLayerSize.x * uiSize.x
	local rootHeight = hudLayerSize.y * uiSize.y
	local absPos = v2(hudLayerSize.x * uiLoc.x, hudLayerSize.y * uiLoc.y)
	local anchor, pos
	if TOOLTIPS_MODE == "top" then
		anchor, pos = v2(0.5,1), v2(absPos.x, absPos.y-rootHeight/2)
	elseif TOOLTIPS_MODE == "bottom" then
		local temp = FOOTER_HINTS == "Disabled" and outerHeaderFooterHeight or 0
		anchor, pos = v2(0.5,0), v2(absPos.x, absPos.y+rootHeight/2+1-temp)
	elseif TOOLTIPS_MODE == "left" then
		anchor, pos = v2(1,0), v2(absPos.x-rootWidth/2, absPos.y-rootHeight/2+highlightPosition)
	elseif TOOLTIPS_MODE == "right" then
		anchor, pos = v2(0,0), v2(absPos.x+rootWidth/2, absPos.y-rootHeight/2+highlightPosition)
	elseif TOOLTIPS_MODE == "left (fixed)" then
		anchor, pos = v2(1,0.5), v2(absPos.x-rootWidth/2, absPos.y)
	elseif TOOLTIPS_MODE == "left (fixed 2)" then
		anchor, pos = v2(1,0), v2(absPos.x-rootWidth/2, absPos.y-boxHeight/4)
	elseif TOOLTIPS_MODE == "left (fixed 3)" then
		anchor, pos = v2(0.5,0), v2(math.max(absPos.x-rootWidth*0.9,(absPos.x-rootWidth/2)/2), absPos.y-boxHeight/4)
	elseif TOOLTIPS_MODE == "right (fixed 2)" then
		anchor, pos = v2(0,0), v2(absPos.x+rootWidth/2, absPos.y-boxHeight/4)
	elseif TOOLTIPS_MODE == "right (fixed 3)" then
		anchor, pos = v2(0.5,0), v2(math.min(99999999,(uiWidth+absPos.x+rootWidth/2)/2), absPos.y-boxHeight/4)
	elseif TOOLTIPS_MODE == "crosshair" then
		anchor, pos = v2(0.5,0), v2(uiWidth/2, uiHeight/2+20)
	else --right (fixed)
		anchor, pos = v2(0,0.5), v2(absPos.x+rootWidth/2, absPos.y)
	end
	-- host owned shell carries layer and placement, the tracked element embeds
	handle.shell = ui.create {
		type = ui.TYPE.Container,
		layer = tooltipLayer,
		name = 'itemTooltip',
		props = {
			anchor = anchor,
			position = pos,
		},
		content = ui.content { handle.element },
	}
	return handle
end
local containerHash = 0
local ambient = require('openmw.ambient')
local pickpocket
local qlppInstalled = vfs.fileExists("scripts/OwnlysQuickLoot/ql_pickpocket_overhaul.lua")
if qlppInstalled then
	pickpocket = require("scripts.OwnlysQuickLoot.ql_pickpocket_overhaul")
else
	pickpocket = require("scripts.OwnlysQuickLoot.ql_pickpocket")
end
local printThrottle = 0
local lastPrint = {}
local deposit = false
local questItems = require("scripts.OwnlysQuickLoot.ql_questItems")
local redStealingWindow = true
-- probe: run onactivate mwscripts
local probe = nil
local approvedContainer = nil
local scriptVerdicts = {}

-- leaks qlScriptBlacklist and qlScriptWhitelist
require("scripts.OwnlysQuickLoot._SCRIPT_BLACKLIST")

local function log(...)
	local newPrint = {...}
	local sameMessage = true
	for a,b in pairs(newPrint) do
		if lastPrint[a] ~=b then
			sameMessage = false
			break
		end
	end
	lastPrint = newPrint
	if not sameMessage or printThrottle <=0 then
		printThrottle = 1
		print(...)
	end
end

-- every group the engine can play on death, deathStateToAnimGroup covers exactly these
local deathGroups = {
	["death1"] = true,
	["death2"] = true,
	["death3"] = true,
	["death4"] = true,
	["death5"] = true,
	["deathknockdown"] = true,
	["deathknockout"] = true,
	["swimdeath"] = true,
	["swimdeathknockdown"] = true,
	["swimdeathknockout"] = true,
}

function updateModEnabled()
	local tempState = true
	for a,b in pairs(modDisableFlags) do
		if not b then
			tempState = false
		end
	end
	
	modEnabled=ENABLED and tempState
	closeHud()
	core.sendGlobalEvent("OwnlysQuickLoot_playerToggledMod",{self,modEnabled})
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' or orig_type == 'userdata' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


quickLootText = {
	props = {
		textColor = FONT_TINT,
		textShadow = true,
		textShadowColor = util.color.rgba(0,0,0,0.75),
	}
}

itemFontSize = 20

function getTexture(path)
	if not textureCache[path] then
		textureCache[path] = ui.texture{path = path}
	end
	return textureCache[path]
end

------------------------------ chain api ------------------------------
-- generic modifier chain
local function makeChain()
	local list = {}
	local seq = 0
	local chain = {
		entries = list
	}
	function chain.register(opts)
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

local lootInterceptorChain = makeChain()
local hudModifierChain = makeChain()
local targetFilterChain = makeChain()

------------------------------ bound items ------------------------------
-- the engine blacklists whatever the sMagicBound* gmsts name, gmsts cannot be enumerated from lua so the 12 vanilla names are fixed
local BOUND_ITEM_GMSTS = {
	"sMagicBoundBattleAxeID",
	"sMagicBoundBootsID",
	"sMagicBoundCuirassID",
	"sMagicBoundDaggerID",
	"sMagicBoundHelmID",
	"sMagicBoundLeftGauntletID",
	"sMagicBoundLongbowID",
	"sMagicBoundLongswordID",
	"sMagicBoundMaceID",
	"sMagicBoundRightGauntletID",
	"sMagicBoundShieldID",
	"sMagicBoundSpearID",
}

local boundRecordIds = {}
for _, gmst in ipairs(BOUND_ITEM_GMSTS) do
	local id = core.getGMST(gmst)
	if id and id ~= "" then
		boundRecordIds[id:lower()] = true -- gmst values are not normalized, recordIds are
	end
end
------------------------------------------------------------

-- false blocks action
local function lootAllowed(action, item)
	-- conjured gear never changes owner, same refusals the container window gives
	if item and boundRecordIds[item.recordId] then
		ui.showMessage(core.getGMST(action == "take" and "sContentsMessage1" or "sBarterDialog12"))
		return false
	end
	local cont = inspectedContainer
	local ctx = {
		target = cont,
		item = item,
		action = action,
		isPickpocket = types.Actor.objectIsInstance(cont) and not types.Actor.isDead(cont),
	}
	for _, entry in ipairs(lootInterceptorChain.entries) do
		if entry.func(ctx) == false then
			return false
		end
	end
	return true
end
------------------------------------------------------------

------------------------------ custom keybindings ------------------------------
-- renderer stores: 1-511 = key code, -1..-99 = mouse button, 1000 + id = gamepad, nil = unbound

-- take/give switch or search window, shared by ToggleSpell and ALT_KEY
local function secondaryPressed()
	local isPickpocketing = pickpocket.validateTarget(self, inspectedContainer, input)
	local effectiveDeposit = R_DEPOSIT2 == "Yes" or (R_DEPOSIT2 == "Only when pickpocketing" and isPickpocketing)
	if effectiveDeposit ~= input.isShiftPressed() then
		if not isPickpocketing or pickpocket.version then
			deposit = not deposit
			selectedIndex, depositSelectedIndex = depositSelectedIndex, selectedIndex
			backupSelectedIndex, depositBackupSelectedIndex = depositBackupSelectedIndex, backupSelectedIndex
			scrollPos, depositScrollPos = depositScrollPos, scrollPos
			drawUI()
		end
	else
		-- vanilla window skips activation handlers, interceptors get their shot here
		if not lootAllowed("open") then
			return
		end
		I.UI.setMode("Container",{target = inspectedContainer})
	end
end

-- persistent corpses never despawn, vanilla refuses to dispose them
-- isPersistent needs openmw 0.52, on older builds it reads nil and disposal stays unrestricted
local function disposeAllowed(corpse)
	if not (types.Actor.objectIsInstance(corpse) and types.Actor.isDead(corpse)) then
		return false
	end
	if corpse.type.record(corpse).isPersistent then
		ui.showMessage(core.getGMST("sDisposeCorpseFail"))
		return false
	end
	return true
end

-- take all / deposit all, shared by ToggleWeapon and TAKE_ALL_KEY
local function takeAllPressed()
	if types.Actor.objectIsInstance(inspectedContainer) and not types.Actor.isDead(inspectedContainer) then
		return
	end
	if not lootAllowed(deposit and "depositAll" or "takeAll") then
		return
	end
	if deposit then
		core.sendGlobalEvent("OwnlysQuickLoot_depositAll",{self, inspectedContainer, input.isShiftPressed() and SELECTIVE_DEPOSIT, EXPERIMENTAL_LOOTING})
	else
		core.sendGlobalEvent("OwnlysQuickLoot_takeAll",{self, inspectedContainer, DISPOSE_CORPSE == "Shift + F" and input.isShiftPressed() and disposeAllowed(inspectedContainer), EXPERIMENTAL_LOOTING})
	end
	if types.Container.objectIsInstance(inspectedContainer) and CONTAINER_ANIMATION == "on take" then
		inspectedContainer:sendEvent("OwnlysQuickLoot_openAnimation",self)
	end
end

-- wheel, dpad and UP/DOWN keys, delta 0 still rolls the pickpocket chance
local function moveSelection(delta)
	local shouldRefresh = pickpocket.scroll(self, inspectedContainer, input)
	local newIndex = selectedIndex
	local jumped = false
	if delta ~= 0 and GROUP_JUMP and input.isShiftPressed() then
		local prevStart, nextStart, firstStart, lastStart
		local startCount = 0
		for i = 1, #containerItems do
			if i == 1 or containerGroups[i] ~= containerGroups[i-1] then
				startCount = startCount + 1
				firstStart = firstStart or i
				lastStart = i
				if i < selectedIndex then
					prevStart = i
				elseif i > selectedIndex and not nextStart then
					nextStart = i
				end
			end
		end
		if startCount > 1 then
			newIndex = delta > 0 and (nextStart or firstStart) or (prevStart or lastStart)
			jumped = true
		end
	end
	if not jumped then
		newIndex = selectedIndex + delta
		if newIndex <= 0 then
			newIndex = math.max(1,#containerItems)
		elseif newIndex > #containerItems then
			newIndex = 1
		end
	end
	if selectedIndex ~= newIndex or shouldRefresh then
		selectedIndex = newIndex
		backupSelectedIndex = newIndex
		drawUI()
	end
end

-- configured keys replace the default triggers, true = consumed
local function customKeybindPressed(code)
	if not inspectedContainer or I.UI.getMode() then
		return false
	end
	if code == TAKE_KEY then
		lootItem()
	elseif code == TAKE_ALL_KEY then
		takeAllPressed()
	elseif code == ALT_KEY then
		secondaryPressed()
	elseif code == UP_KEY then
		moveSelection(-1)
	elseif code == DOWN_KEY then
		moveSelection(1)
	else
		return false
	end
	return true
end

-- a bound function mutes its own default trigger, unbound ones keep theirs
input.registerTriggerHandler("ToggleSpell", async:callback(function(dt, use, sneak, run)
	if inspectedContainer and not ALT_KEY then
		secondaryPressed()
	end
end))

input.registerTriggerHandler("ToggleWeapon", async:callback(function(dt, use, sneak, run)
	if inspectedContainer and not TAKE_ALL_KEY then
		takeAllPressed()
	end
end))

input.registerTriggerHandler("Jump", async:callback(function(dt, use, sneak, run)
	if inspectedContainer and DISPOSE_CORPSE == "Jump" and types.Actor.objectIsInstance(inspectedContainer)
	and types.Actor.isDead(inspectedContainer) then
		if not lootAllowed("takeAll") then
			return
		end
		-- persistent corpses only get looted
		core.sendGlobalEvent("OwnlysQuickLoot_takeAll",{self, inspectedContainer, disposeAllowed(inspectedContainer), EXPERIMENTAL_LOOTING})
	end
end))

input.bindAction('Use', async:callback(function(dt, use, sneak, run)
	if types.Actor.getStance(self) ~= types.Actor.STANCE.Nothing and use then
		closeHud()
	end
	
	return use
end), {  })

function isQuestItem(item)
	local record = item.type.record(item)
	local scriptName = record.mwscript
	-- works, but goes too deep maybe
	if types.Player.quests(self)["TR_m3_AT_RatFriend"] and types.Player.quests(self)["TR_m3_AT_RatFriend"].stage>=10 and not types.Player.quests(self)["TR_m3_AT_RatFriend"].finished then
		local requirements = {
			p_restore_magicka_q          =true,
			ingred_bread_01              =true,
			ingred_red_lichen_01         =true,
			potion_cyro_brandy_01        =true,
			tr_m3_at_ratfriend_journal   =true,
		}
		if requirements[item.recordId] then
			return true
		end
	end
	if scriptName then
		if scriptName:find("cursed") 
		or scriptName:sub(-6,-1) == "dae_01"
		or scriptName == "tr_m3_aar_clo_dubious"
		or scriptName == "tr_m1_ench_shield_i62"
		or scriptName == "t_de_goldcoinghost_05"
		or scriptName == "tr_m1_soulgem_curse_i62"
		or scriptName == "t_ingmine_emeralddetomb_01"
		or scriptName == "tr_m7_armiger_note_gh"
		or scriptName == "t_com_goldcoindae_05"
		or scriptName == "t_ingmine_rubydetomb_01"
		or scriptName == "t_ingmine_pearldetomb_01"
		or scriptName == "t_ingmine_diamonddetomb_01"
		then
			return false
		end
		
		local script = core.mwscripts.records[scriptName]
		if script then
			-- record is userdata, the source lives in .text
			local scriptText = script.text:lower()
			if scriptText:find("setjournal") or scriptText:find("startscript") or scriptText:find("addtopic") or scriptText:find("journal ") then
				return true
			end
		end
	end
	if not questItems[item.recordId] then 
		return false 
	end 
	
	local itemType = item.type
	if itemType == types.Ingredient then
		return false
	elseif itemType == types.Miscellaneous or itemType == types.Book then
		return true
	end
	return true --?
end

local pickpocketTimeSlowed = false
function setPickpocketTimeScale(active)
	local shouldSlow = active and PICKPOCKET_TIME_SCALE and PICKPOCKET_TIME_SCALE < 1
	if shouldSlow == pickpocketTimeSlowed then return end
	pickpocketTimeSlowed = shouldSlow
	core.sendGlobalEvent("SetSimulationTimeScale", shouldSlow and PICKPOCKET_TIME_SCALE or 1)
end

local poisonCache = {}
local function isPoison(item)
	if poisonCache[item.recordId] == nil then
		poisonCache[item.recordId] = false
		if types.Potion.objectIsInstance(item) then
			local record = types.Potion.record(item)
			for _, effect in pairs(record.effects) do
				if effect.effect.harmful then
					poisonCache[item.recordId] = true
					break
				end
			end
		end
	end
	return poisonCache[item.recordId]
end


function drawUI()
	local isPickpocketing = pickpocket.validateTarget(self, inspectedContainer, input)
	setPickpocketTimeScale(isPickpocketing)
	--if isPickpocketing and not startedPickpocketing then
	--	pickpocket.messageShown = false
	--end
	
	local transparency = TRANSPARENCY
	local hudLayerSize = ui.layers[ui.layers.indexOf("HUD")].size
	local rootWidth = hudLayerSize.x * uiSize.x
	local rootHeight = hudLayerSize.y * uiSize.y
	local header_footer_setting = HEADER_FOOTER
	core.sendGlobalEvent("OwnlysQuickLoot_freshLoot",{self, inspectedContainer})
	if backupSelectedContainer == inspectedContainer then
		selectedIndex = backupSelectedIndex
	else
		scrollPos = 1
		depositSelectedIndex = 1
		depositBackupSelectedIndex = 1
		depositScrollPos = 1
		deposit = false
	end
	backupSelectedIndex = selectedIndex
	backupSelectedContainer = inspectedContainer 
	local uiSize = uiSize
	
	if root then
		root:destroy()
	end
	if tooltip then
		tooltip.shell:destroy()
		tooltip.destroy()
		tooltip = nil
	end
	local localizedName = inspectedContainer.type.records[inspectedContainer.recordId].name
	local absPos = v2(hudLayerSize.x * uiLoc.x, hudLayerSize.y * uiLoc.y)
	root = ui.create({	--root
		type = ui.TYPE.Widget,
		layer = 'HUD',
		name = 'QuickLootBox',
		props = {
			anchor = v2(0.5,0.5), 
			position = absPos,
			size = v2(rootWidth, rootHeight),
		},
		content = ui.content {
		}
	})
	
	textSizeMult = ui.screenSize().y /1200*(uiSize.y/0.4)
	local outerHeaderFooterScale = (textSizeMult^0.5)/textSizeMult*uiScale
	textSizeMult = textSizeMult^0.5
	textSizeMult=textSizeMult*TEXTSIZEMULT/100
	outerHeaderFooterScale = outerHeaderFooterScale*TEXTSIZEMULT/100

	local outerHeaderFooterMargin = 0.005 *rootHeight
	outerHeaderFooterHeight = 0.06*outerHeaderFooterScale*rootHeight
	local captionOffset = 0

	

	local stealCol = nil
	if isPickpocketing
	or inspectedContainer.owner.recordId
	or inspectedContainer.owner.factionId and not types.NPC.getFactionRank(self, inspectedContainer.owner.factionId)
	or inspectedContainer.owner.factionId and types.NPC.getFactionRank(self, inspectedContainer.owner.factionId) < (inspectedContainer.owner.factionRank or 999) then
		--stealCol = util.color.rgba(1,0.714, 0.706, 1)
		stealCol = util.color.rgba(1,0.05, 0.05, 1)
		--STEALING ICON
		--captionOffset = outerHeaderFooterHeight/hudAspectRatio
		
	end
	

	--Caption: CONTAINER NAME
	local headline ={
		name = "headline",
		type = ui.TYPE.Flex,
		props = {
			position = v2(0, 0),
			size  = v2(1,outerHeaderFooterHeight),
			position = v2(0 + captionOffset, 0.011*rootHeight),
			anchor = v2(0,0),
			horizontal = true,
		},
		content = ui.content({})
	}
	root.layout.content:add(headline)
	local titleText = ""..localizedName.." "
	if deposit then
		titleText = "->> "..localizedName.." "
	end
	headline.content:add({
		name = "titleText",
		type = ui.TYPE.Text,
		template = quickLootText,
		props = {
			text = titleText,
			textSize= 25*textSizeMult,
			position = v2(0, 0),
			size  = v2(rootWidth,outerHeaderFooterHeight),
			position = v2(0.015*rootWidth + captionOffset, outerHeaderFooterHeight/2),
			anchor = v2(0,0.5),
			textColor = stealCol or ICON_TINT,
		}
	})
	
	if stealCol and HAND_SYMBOL then
		headline.content:add({
			name = "stealHandIcon",
			type = ui.TYPE.Image,
			props = {
				resource = handTex,
				tileH = false,
				tileV = false,
				position = v2(0, 0),
				--relativeSize  = v2(1,1),
				size = v2(outerHeaderFooterHeight*0.8,outerHeaderFooterHeight*0.8),
				alpha = 0.8,
			}
		})
	end
	stealCol = stealCol and util.color.rgba(1,0.4, 0.4, 1)
	borderFile = "thin"
	local BORDER_STYLE = BORDER_STYLE
	if BORDER_STYLE == "verythick" or BORDER_STYLE == "thick" then
		borderFile = "thick"
	end
	borderOffset = BORDER_STYLE == "verythick" and 4 or BORDER_STYLE == "thick" and 3 or BORDER_STYLE == "normal" and 2 or 1
	-- caller owns the texture folder now, inset frame with no padding matches the old look
	local borderPath = BORDER_FIX and "textures/QuickLoot/ql_makeborder/" or "textures/"
	borderTemplate = makeBorder(borderPath, borderFile, stealCol or borderColor or nil, borderOffset)
	
	-- BOX
	boxHeight = rootHeight - 2 * (outerHeaderFooterHeight + outerHeaderFooterMargin)
	local box = { -- r.1.7
		name = "box",
		type = ui.TYPE.Widget,
		props = {
			size = v2(rootWidth, boxHeight),
			position = v2(0, outerHeaderFooterHeight + outerHeaderFooterMargin),
		},
		content = ui.content {}
	}
	root.layout.content:add( box)
	
	--box BACKGROUND
	box.content:add( {
		name = "boxBackground",
		type = ui.TYPE.Image,
		props = {
			resource = background,
			tileH = false,
			tileV = false,
			relativeSize  = v2(1,1),
			relativePosition = v2(0,0),
			alpha = transparency,
		}
	})
	--box BORDER
	box.content:add( {
		name = "boxBorder",
		template = BORDER_STYLE ~= "none" and borderTemplate or nil,
		props = {
			relativeSize  = v2(1,1),
			alpha = 0.5,
		}
	})
	
	local widgets = {} --inverse sorting
	if isPickpocketing and COLUMN_WV_PICKPOCKETING or not isPickpocketing and COLUMN_WV then
		table.insert(widgets,"valueByWeight")
	end
	if isPickpocketing and COLUMN_VALUE_PICKPOCKETING or not isPickpocketing and COLUMN_VALUE then
		table.insert(widgets,"value")
	end
	if isPickpocketing and COLUMN_WEIGHT_PICKPOCKETING or not isPickpocketing and COLUMN_WEIGHT then
		table.insert(widgets,"weight")
	end
	if isPickpocketing and COLUMN_PICKPOCKET then
		table.insert(widgets,"pickpocket")
	end
	
	encumbranceCurrent = types.Actor.getEncumbrance(self)
	local encumbranceMax = types.Actor.stats.attributes.strength(self).modified*core.getGMST("fEncumbranceStrMult")
	
	local headerFooterHeight = math.floor(itemFontSize*textSizeMult*1.25)
	local listHeight = boxHeight-2*borderOffset
	local listY = borderOffset
	--if header_footer_setting == "only top" or header_footer_setting == "all top" or header_footer_setting == "hide both" then -- WHY?
	--	listHeight = listHeight-2
	--end
	if header_footer_setting == "show both" then
		listHeight = listHeight - 2*(headerFooterHeight)
	elseif header_footer_setting ~= "hide both" then
		listHeight = listHeight - (headerFooterHeight)
	end
	
	if header_footer_setting == "show both" or header_footer_setting == "all top" or header_footer_setting == "only top" then
		listY = listY + headerFooterHeight
	end
	
	local function filterItems(t)
		local ret = {}
		for i, item in pairs(t) do
			if item.recordId:sub(1,9) ~= "_mca_mask" and item.recordId:sub(1,8) ~= "_mca_wig" then
				table.insert(ret,item)
			end
		end
		return ret
	end
	--GET CONTENTS
	if deposit then
		containerItems = types.Container.inventory(self):getAll()
		containerItems = filterItems(containerItems)
	else
		containerItems = types.Container.inventory(inspectedContainer):getAll()
		containerItems = filterItems(containerItems)
		if isPickpocketing then
			containerItems = pickpocket.filterItems(self, inspectedContainer, containerItems)
		end
	
	end
	
	-- HEADER
	if header_footer_setting == "show both" or header_footer_setting == "all top" or header_footer_setting ==  "only top" then
		local header = { -- r.1.7
			name = "header",
			type = ui.TYPE.Widget,
			props = {
				size = v2(rootWidth-2*borderOffset, headerFooterHeight),
				position = v2(borderOffset, borderOffset),
			},
			content = ui.content {}
		}
		box.content:add( header)
		--list HEADER Background
		header.content:add(
		{
			name = "headerBackground",
			type = ui.TYPE.Image,
			props = {
				resource = background,
				tileH = false,
				tileV = false,
				relativeSize  = v2(1,1),
				size = v2(0,0),
				--size = v2(-borderOffset*2,itemBoxHeaderFooterHeight-borderOffset),
				position = v2(0,0),
				relativePosition = v2(0, 0),
				alpha = transparency*0.4 + 0.1,
			}
		})
		--list HEADER Line
		if BORDER_STYLE ~= "none" then
			header.content:add(
			{
				name = "headerLine",
				type = ui.TYPE.Image,
				props = {
					resource = BORDER_FIX and getTexture("textures/QuickLoot/ql_makeborder/menu_thin_border_bottom.dds") or getTexture("textures/menu_thin_border_bottom.dds"),
					tileH = false,
					tileV = false,
					relativeSize  = v2(1,0),
					size = v2(0,1),
					position = v2(0,-1),
					relativePosition = v2(0, 1),
					alpha = 0.4,
					color = stealCol
				}
			})
		end
		if (header_footer_setting == "all top" or header_footer_setting ==  "only top") and isPickpocketing and pickpocket.footerText then

			header.content:add{
				name = "headerPickpocketIcon",
				type = ui.TYPE.Image,
				props = {
					resource = pickpocketTex,
					tileH = false,
					tileV = false,
					size  = v2(0.85*headerFooterHeight,0.85*headerFooterHeight),
					position = v2(6,0),
					alpha = 0.7,
					anchor = v2(0,0),
					color = pickpocket.footerColor or FONT_TINT
				}
			}
			header.content:add{
				name = "headerPickpocketText",
				type = ui.TYPE.Text,
				template = quickLootText,
				props = {
					text = ""..pickpocket.footerText.." ",
					textSize= headerFooterHeight*0.82,----20*textSizeMult,
					position = v2(0.85*headerFooterHeight+8, headerFooterHeight/2+1),
					size  = v2(55+0.85*headerFooterHeight,0.85*headerFooterHeight),
					anchor = v2(0,0.5),
					textColor = pickpocket.footerColor or FONT_TINT
				},
			}
		elseif header_footer_setting == "all top" then
			local encumbranceColor = FONT_TINT
			local encumbranceIconColor = ICON_TINT
			if encumbranceCurrent > encumbranceMax then
				encumbranceColor = util.color.rgb(0.85,0, 0)
				encumbranceIconColor = util.color.rgb(1,0, 0)
			end
			--list HEADER ENCUMBRANCE ICON
			header.content:add({
				name = "headerEncumbranceIcon",
				type = ui.TYPE.Image,
				props = {
					resource = backpackTex,
					tileH = false,
					tileV = false,
					size  = v2(0.85*headerFooterHeight,0.85*headerFooterHeight),
					position = v2(8,2),
					alpha = 0.5,
					anchor = v2(0,0),
					color = encumbranceIconColor,
				}
			})
			
			--list HEADER ENCUMBRANCE TEXT
			header.content:add({
				name = "headerEncumbranceText",
				type = ui.TYPE.Text,
				template = quickLootText,
				props = {
					text = ""..math.floor(encumbranceCurrent+0.5).. "/"..math.floor(encumbranceMax+0.5),
					textSize= headerFooterHeight*0.82,----20*textSizeMult,
					position = v2(0.85*headerFooterHeight+8, headerFooterHeight/2+1),
					size  = v2(55+0.85*headerFooterHeight,0.85*headerFooterHeight),
					anchor = v2(0,0.5),
					textColor = encumbranceColor,
				},
			})
		end

		local widgetOffset = 0.05 -- for scrollbar
		--list HEADER ICONS
		for _, widget in pairs(widgets) do
			header.content:add({
				name = "headerColumnIcon_"..widget,
				type = ui.TYPE.Image,
				props = {
					resource = _G[widget.."Tex"],
					tileH = false,
					tileV = false,
					size  = v2(0.95*headerFooterHeight,0.95*headerFooterHeight),
					relativePosition = v2(1-widgetOffset, -0.05),--itemBoxHeaderFooterHeight),
					position = v2(0,-1.5),
					anchor = v2(1,0),
					alpha = 0.8,
					color = ICON_TINT,
				}
			})
			widgetOffset =widgetOffset+ math.max(0.12,0.105*textSizeMult)--itemBoxHeaderFooterHeight*headerFooterScale
		end
	end
	-- /HEADER
	
	local entryWidth = 0.7*rootWidth

	local maxItems = math.floor(listHeight / (itemFontSize*textSizeMult*1.39+1))

	local relLineHeight = 1/maxItems
	local absLineHeight = relLineHeight * listHeight
	local position = 0
	
	

	

	
	local sortedItems = {
		{}, --poisons --1
		{}, --questItems --2
		{}, --cash --3
		{}, --keys --4
		{}, --lockpicks --5
		{}, --soulgems --6
		{}, --ingredients(light) + repair --7
		{}, --ingredients(heavy) --8
		{}, --other --9
	}
	local plantingPoisons = CONTAINER_SORTING_POISONS and qlppInstalled and deposit and isPickpocketing
	for _,item in pairs(containerItems) do
		local itemType = item.type
		local itemRecordId =item.recordId
		local itemRecord = item.type.record(itemRecordId)


		if not itemRecord.name
		or itemRecord.name == ""
		or not types.Item.isCarriable(item)
		then
			-- ignore
		elseif plantingPoisons and isPoison(item) then
			table.insert(sortedItems[1], {item, itemRecord.value, itemRecord.weight})
		elseif CONTAINER_SORTING_QUEST and isQuestItem(item) then
			table.insert(sortedItems[2], {item, itemRecord.value, itemRecord.weight})
		elseif itemType == types.Miscellaneous and itemRecordId == "gold_001" and CONTAINER_SORTING_CASH then
			table.insert(sortedItems[3], {item, itemRecord.value, itemRecord.weight})
		elseif itemType == types.Miscellaneous and itemRecord.isKey and CONTAINER_SORTING_KEYS then
			table.insert(sortedItems[4], {item, itemRecord.value, itemRecord.weight})
		elseif (itemType == types.Lockpick or itemType == types.Probe) and CONTAINER_SORTING_LOCKPICKS then
			table.insert(sortedItems[5], {item, itemRecord.value, itemRecord.weight})
		elseif itemType == types.Miscellaneous and itemRecordId:sub(1,12) == "misc_soulgem" and CONTAINER_SORTING_SOULGEMS then
			table.insert(sortedItems[6], {item, itemRecord.value, itemRecord.weight})
		elseif itemType == types.Ingredient and CONTAINER_SORTING_INGREDIENTS > 0 then
			if itemRecord.weight <= CONTAINER_SORTING_INGREDIENTS then
				table.insert(sortedItems[7], {item, itemRecord.value, itemRecord.weight})
			else
				table.insert(sortedItems[8], {item, itemRecord.value, itemRecord.weight})
			end
		elseif itemType == types.Repair and CONTAINER_SORTING_REPAIR then
			table.insert(sortedItems[7], {item, itemRecord.value, itemRecord.weight})
		else
			table.insert(sortedItems[9], {item, itemRecord.value, itemRecord.weight})
		end
	end
	containerItems = {}
	containerGroups = {}
	for cat, tbl in ipairs(sortedItems) do
		if CONTAINER_SORTING_STATS ~= "Vanilla" then
			table.sort(tbl, function(a, b)
				if CONTAINER_SORTING_STATS == "Lowest Weight" then
					return a[3] < b[3] or (a[3] == b[3] and a[1].type.record(a[1]).name:lower() < b[1].type.record(b[1]).name:lower())
				elseif CONTAINER_SORTING_STATS == "Highest Value" then
					return a[2] > b[2] or (a[2] == b[2] and a[1].type.record(a[1]).name:lower() < b[1].type.record(b[1]).name:lower())
				else -- "Best W/V"
					local a_WV = a[2] / math.max(0.1, a[3])
					local b_WV = b[2] / math.max(0.1, b[3])
					return a_WV > b_WV or (a_WV == b_WV and a[1].type.record(a[1]).name:lower() < b[1].type.record(b[1]).name:lower())
				end
			end)
		else
			local prio={
				Weapon = 20,
				Armor = 18,
				Clothing = 16,
				Potion = 14,
				Ingredient = 12,
				Apparatus = 10,
				Book = 8,
				Light = 6,
				Miscellaneous = 4,
				Lockpick = 2,
				Repair = 0,
				Probe = -2,
			}
			table.sort(tbl, function(a,b)
				if (prio[tostring(a[1].type)] or -99) == (prio[tostring(b[1].type)] or -99) then
					return string.upper(a[1].type.record(a[1]).name) < string.upper(b[1].type.record(b[1]).name)
				else
					return (prio[tostring(a[1].type)] or -99) > (prio[tostring(b[1].type)] or -99)
				end
			end)
			--print(tostring(tbl[1].type))
			
		end
		for _, itemData in ipairs(tbl) do
			table.insert(containerItems,itemData[1])
			containerGroups[#containerItems] = cat
		end
	end
	-- /SORTING
	
	-- LIST
	local list = {
		name = "list",
		type = ui.TYPE.Widget,
		props = {
			size = v2(rootWidth-borderOffset*2, listHeight),
			position = v2(borderOffset, listY),
		},
		content = ui.content {}
	}
	box.content:add( list)
	
	local containerItemCount = #containerItems
	if pickpocket.message then
		containerItemCount = containerItemCount + 1
	end
	
	--SCROLLBAR
	local highlightWidth = 1
	selectedIndex = math.min(selectedIndex,#containerItems)
	if selectedIndex >= scrollPos+maxItems-1 then
		scrollPos = math.min(containerItemCount-maxItems+1, selectedIndex - maxItems+2)
	elseif selectedIndex <= scrollPos then
		scrollPos = math.max(1,selectedIndex-1)
	end
	scrollPos = math.min(scrollPos, math.max(1,containerItemCount+2-maxItems))
	local visibleItems = math.min(maxItems,containerItemCount-scrollPos+1)
	if scrollPos > 1 or containerItemCount > maxItems then -- show scrollbar?
		highlightWidth = 0.96
		
		-- rounding fix:
		local visibleStart = math.floor((scrollPos-1)/containerItemCount*listHeight+0.5)
		local visibleEnd = math.ceil((scrollPos-1+visibleItems)/containerItemCount*listHeight)
		local visibleLength = math.min(listHeight, visibleEnd - visibleStart)
		
		local selectedStart = math.floor((selectedIndex-1)/containerItemCount*listHeight+0.5)
		local selectedEnd = math.ceil((selectedIndex-1+1)/containerItemCount*listHeight)
		local selectedLength = math.min(listHeight, selectedEnd - selectedStart)

		--SCROLLBAR BACKGROUND
		list.content:add(
		{
			name = "scrollbarBackground",
			type = ui.TYPE.Image,
			props = {
				resource = background,
				tileH = false,
				tileV = false,
				anchor=v2(1,0),
				relativePosition = v2(1,0),
				relativeSize = v2(0.04,1),
				alpha = math.min(1,transparency*1.25),
				color = FONT_TINT,
			}
		})
		--SCROLLBAR VISIBLE RANGE
		list.content:add(
		{
			name = "scrollbarVisible",
			type = ui.TYPE.Image,
			props = {
				resource = white,
				relativePosition = v2(1,0),
				relativeSize  = v2(0.04,0),
				position = v2(0,visibleStart),
				size = v2(0,visibleLength),
				alpha = 0.15,
				anchor= v2(1,0),
				color = ICON_TINT,
				
			}
		})
		--SCROLLBAR SELECTED
		list.content:add(
		{
			name = "scrollbarSelected",
			type = ui.TYPE.Image,
			props = {
				resource = white,
				relativePosition = v2(1,0),
				relativeSize  = v2(0.04,0),
				position = v2(0,selectedStart),
				size = v2(0,    selectedLength),
				alpha = 0.5,
				anchor=v2(1,0),
				color = ICON_TINT,
			}
		})
	end

	-- ITEMS
	local relativePosition = 0
	local renderedEntries = 0
	
	if not isPickpocketing or pickpocket.showContents or deposit then			
		for i, thing in pairs(containerItems) do
			local thingRecord = thing.type.records[thing.recordId]
			if not thingRecord then
				ui.showMessage("ERROR: no record for "..thing.id.." (please report this bug)")
			elseif i >=scrollPos and renderedEntries < maxItems then
				renderedEntries = renderedEntries + 1
				local thingName =  thingRecord.name or thing.id
				--thingName= fromutf8(thingName)
				local icon = thingRecord.icon
				local thingCount = thing.count or 1
				local countText = thingCount > 1 and " ("..thing.count..")" or ""
				if i == selectedIndex then
					-- SELECTION HIGHLIGHT
					local stealCol = stealCol
					if stealCol then
						stealCol = util.color.rgba(stealCol.r*1.4,stealCol.g*1.4,stealCol.b*1.4,stealCol.a)
					end
					list.content:add( {
						name = "selectionHighlight",
						type = ui.TYPE.Image,
						props = {
							resource = white,
							tileH = false,
							tileV = false,
							relativeSize  = v2(highlightWidth,0),
							size = v2(1,math.ceil(relLineHeight*listHeight)),
							relativePosition = v2(0,relativePosition),
							position = v2(0,0),
							alpha = 0.3,
							color = stealCol or ICON_TINT,
						}
					})
					tooltip = makeTooltip(
						thing
						,
						-- box position
						outerHeaderFooterHeight + outerHeaderFooterMargin
						-- list position
						+listY
						-- highlight position * list height
						+relativePosition*listHeight
						,
						isPickpocketing,
						deposit,
						-- steal tint styles the border
						stealCol and { borderColor = util.color.rgba(stealCol.r, stealCol.g, stealCol.b, 0.5) } or nil
					)
				end
				local ench = thing and (thing.enchant or thingRecord.enchant ~= "" and thingRecord.enchant or types.Item.itemData(thing).soul)
				local tempTemplate = nil
				if deposit and types.Actor.hasEquipped(self,thing) or types.Actor.hasEquipped(inspectedContainer,thing) then
					tempTemplate = borderTemplate
				end
				local iconBox ={
						name = "itemIconBox_"..i,
						template = tempTemplate,
						props = {
							relativePosition = v2(0,relativePosition),
							size = v2(absLineHeight-1,absLineHeight-1),
							position = v2(1,1),
							alpha = 0.85,
						},
						content = ui.content{}
					}
				list.content:add( iconBox)
				if icon then
					if ench then 
						--ENCHANT ICON
						iconBox.content:add( {
							name = "itemEnchantIcon_"..i,
							type = ui.TYPE.Image,
							props = {
								resource = getTexture("textures/menu_icon_magic_mini.dds"),
								tileH = false,
								tileV = false,
								--relativePosition = v2(0,relativePosition),
								--size = v2(absLineHeight-2,absLineHeight-2),
								relativeSize = v2(1,1),
								--position = v2(-1,-1),
								--size = v2(1,1),
								alpha = 0.7,
							}
						})			
					end
					-- ITEM ICON
					iconBox.content:add( {
						name = "itemIcon_"..i,
						type = ui.TYPE.Image,
						props = {
							resource = getTexture(icon),
							tileH = false,
							tileV = false,
							--relativePosition = v2(0,relativePosition),
							--size = v2(absLineHeight-2,absLineHeight-2),
							--anchor = v2(0,0),
							--position = v2(1,1),
							relativeSize = v2(1,1),
							alpha = 0.9,
						}
					})
				end
				local readItem = "" --(not FONT_FIX and hextoutf8(0xd83d) or "(R)")
				local readElement = {
						name = "itemReadIcon_"..i,
						type = ui.TYPE.Image,
						props = {
							resource = getTexture("textures/QuickLoot/read_indicator.dds"),
							tileH = false,
							tileV = false,
							--relativePosition = v2(0,relativePosition),
							--size = v2(absLineHeight*0.7,absLineHeight*0.7),
							--relativePosition = v2(0,relativePosition),
							--size = v2(absLineHeight-2,absLineHeight-2),
							relativePosition = v2(0,0),
							relativeSize = v2(1,1),
							anchor = v2(0,0),
							alpha = 0.7,
							--position = v2(3,1),
							color = FONT_TINT,
						}
					}
				if ench or thing.itemRecordId =="sc_paper plain" or READ_BOOKS == "off" or thing.type ~= types.Book then
					readElement = nil
				else
					if READ_BOOKS == "bookworm unread" then
						local DBentry = bookSection:get(thing.recordId)
						if savegameData.bookSection[thing.recordId] then
							readElement.props.resource = getTexture("textures/QuickLoot/hearteye3.dds")
						end
						if DBentry and DBentry >= 20 then
							readElement = nil
						end
					elseif READ_BOOKS == "bookworm" then
						local DBentry = bookSection:get(thing.recordId)
						if not savegameData.bookSection[thing.recordId] then
							readElement = nil
						elseif DBentry and DBentry >= 20 then
							readElement.props.resource = getTexture("textures/QuickLoot/hearteye3.dds")
						end
					elseif READ_BOOKS == "read" then
						local DBentry = bookSection:get(thing.recordId)
						if not savegameData.bookSection[thing.recordId] then
							readElement = nil
						elseif DBentry and DBentry >= 20 then
							readElement.props.resource = getTexture("textures/QuickLoot/hearteye.dds")
						end
					else
						if savegameData.bookSection[thing.recordId] then
							readElement = nil
						end
					end
				end
				if readElement then
					iconBox.content:add( readElement)
				end
				if isQuestItem(thing) then
					iconBox.content:add{
						name = "itemQuestIcon_"..i,
						type = ui.TYPE.Image,
						props = {
							resource = getTexture("textures/QuickLoot/questItem2.dds"),
							tileH = false,
							tileV = false,
							--relativePosition = v2(0,relativePosition),
							--size = v2(absLineHeight*0.7,absLineHeight*0.7),
							--relativePosition = v2(0,relativePosition),
							--size = v2(absLineHeight-2,absLineHeight-2),
							relativePosition = v2(0,0),
							relativeSize = v2(1,1),
							anchor = v2(0,0),
							alpha = 1,
							--position = v2(3,1),
							--color = FONT_TINT,
						}
					}
				end
				-- ITEM NAME + COUNT
				list.content:add( {
					name = "itemName_"..i,
					type = ui.TYPE.Text,
					template = quickLootText,
					props = {
						text = ""..thingName..countText..readItem,--..hextoutf8(0xd83d)..hextoutf8(0xd83e),--thingName..countText,
						textSize = itemFontSize*textSizeMult,--itemFontSize*textSizeMult,
						
						relativeSize  = v2(entryWidth,relLineHeight),
						relativePosition = v2(0, relativePosition+relLineHeight/2),
						position = v2(absLineHeight+3,0), --icon shift
						anchor = v2(0,0.5),
					},
					})
				
				local widgetOffset = 0.05 --scrollbar
				local thingValue = thingRecord.value
				local thingWeight = thingRecord.weight
				if thingRecord.isKey then
					thingValue = 0
				end
				for _, widget in pairs(widgets) do
					local textColor = nil
					local text = ""
					local shownNumber
					if widget == "valueByWeight" then
						if thingValue == 0 and thingWeight == 0 then
							text = "-"
						else
							shownNumber = thingValue/thingWeight
							text = formatNumber(shownNumber, "v/w")
						end
					elseif widget == "weight" then
						shownNumber = thingWeight
						text = formatNumber(shownNumber, "weight")
						if thingWeight+encumbranceCurrent > encumbranceMax then
							textColor = util.color.rgb(0.85,0, 0)
						end
					elseif widget == "pickpocket" then
						text = pickpocket.getColumnText(self, inspectedContainer, thing, deposit)
					else
						shownNumber = thingValue
						text = formatNumber(shownNumber, "value")
					end

					local tempSize = v2(1.1*headerFooterHeight,relLineHeight)
					-- inf icon derived from the column's own number, formatNumber leaves "-" in that case
					if FONT_FIX and shownNumber == 1/0 then
						list.content:add( {
							name = "itemColumnInf_"..i.."_"..widget,
							type = ui.TYPE.Image,
							--template = quickLootText,
							props = {
								resource = getTexture("textures/QuickLoot/inf.dds"),
								tileH = false,
								tileV = false,
								--relativeSize  = tempSize,
								relativePosition = v2(1-widgetOffset, relativePosition+relLineHeight/2),
								anchor = v2(1,0.5),
								size = v2(itemFontSize*0.65,itemFontSize*0.65),
								color = FONT_TINT,
								--alpha = 0.4,
							},
						})
					else
						list.content:add( {
							name = "itemColumn_"..i.."_"..widget,
							type = ui.TYPE.Text,
							template = quickLootText,
							props = {
								text = text,
								textSize = itemFontSize*textSizeMult,
								relativeSize  = tempSize,
								relativePosition = v2(1-widgetOffset, relativePosition+relLineHeight/2),
								anchor = v2(1,0.5),
								textColor = textColor,
							},
						})
					end
					widgetOffset = widgetOffset + math.max(0.12,0.105*textSizeMult)
				end
				relativePosition = relativePosition + relLineHeight--
			end
		end
	end
	if pickpocket.message then
		list.content:add( {
			name = "pickpocketMessage",
			type = ui.TYPE.Text,
			template = quickLootText,
			props = {
				text = pickpocket.message,--..hextoutf8(0xd83d)..hextoutf8(0xd83e),--thingName..countText,
				textSize = itemFontSize*textSizeMult,--itemFontSize*textSizeMult,
				
				relativeSize  = v2(entryWidth,relLineHeight),
				relativePosition = v2(0, relativePosition+relLineHeight/2),
				position = v2(absLineHeight+3,0), --icon shift
				anchor = v2(0,0.5),
			},
		})
	end
	-- FOOTER
	if header_footer_setting == "show both" or header_footer_setting == "all bottom" or header_footer_setting ==  "only bottom" then
		local footer = { -- r.1.7
			name = "footer",
			type = ui.TYPE.Widget,
			props = {
				size = v2(rootWidth-2*borderOffset, headerFooterHeight),
				position = v2(borderOffset, boxHeight-headerFooterHeight-borderOffset),
			},
			content = ui.content {}
		}
		box.content:add( footer)
		--list FOOTER Background
		footer.content:add(
		{
			name = "footerBackground",
			type = ui.TYPE.Image,
			props = {
				resource = background,
				tileH = false,
				tileV = false,
				relativeSize  = v2(1,1),
				size = v2(0,0),
				--size = v2(-borderOffset*2,itemBoxHeaderFooterHeight-borderOffset),
				position = v2(0,0),
				relativePosition = v2(0, 0),
				alpha = transparency*0.3+0.1,
			}
		})
		--list FOOTER Line
		if BORDER_STYLE ~= "none" then
			footer.content:add(
			{
				name = "footerLine",
				type = ui.TYPE.Image,
				props = {
					resource = BORDER_FIX and getTexture("textures/QuickLoot/ql_makeborder/menu_thin_border_bottom.dds") or getTexture("textures/menu_thin_border_bottom.dds"),
					tileH = false,
					tileV = false,
					relativeSize  = v2(1,0),
					size = v2(0,1),
					position = v2(0,0),
					relativePosition = v2(0, 0),
					alpha = 0.4,
					color = stealCol
				}
			})
		end
		local encumbranceColor = FONT_TINT
		local encumbranceIconColor = ICON_TINT
		if encumbranceCurrent > encumbranceMax then
			encumbranceColor = util.color.rgb(0.85,0, 0)
			encumbranceIconColor = util.color.rgb(1,0, 0)
		end
		if isPickpocketing and pickpocket.footerText and (header_footer_setting ==  "all bottom") then

			footer.content:add{
				name = "footerPickpocketIcon",
				type = ui.TYPE.Image,
				props = {
					resource = pickpocketTex,
					tileH = false,
					tileV = false,
					size  = v2(0.8*headerFooterHeight,0.8*headerFooterHeight),
					position = v2(8,1),
					color = pickpocket.footerColor or FONT_TINT,
					alpha = 0.7,
				}
			}
			footer.content:add{
				name = "footerPickpocketText",
				type = ui.TYPE.Text,
				template = quickLootText,
				props = {
					text = ""..pickpocket.footerText.." ",
					textSize= headerFooterHeight*0.82,----20*textSizeMult,
					position = v2(0.85*headerFooterHeight+10, headerFooterHeight/2+1),
					size  = v2(55+0.85*headerFooterHeight,0.85*headerFooterHeight),
					anchor = v2(0,0.5),
					textColor = pickpocket.footerColor or FONT_TINT,
				},
			}
		else
			--list FOOTER ENCUMBRANCE ICON
			footer.content:add({
				name = "footerEncumbranceIcon",
				type = ui.TYPE.Image,
				props = {
					resource = backpackTex,
					tileH = false,
					tileV = false,
					size  = v2(0.85*headerFooterHeight,0.85*headerFooterHeight),
					position = v2(8,2),
					alpha = 0.5,
					anchor = v2(0,0),
					color = encumbranceIconColor,
				}
			})
			
			--list FOOTER ENCUMBRANCE TEXT
			footer.content:add({
				name = "footerEncumbranceText",
				type = ui.TYPE.Text,
				template = quickLootText,
				props = {
					text = ""..math.floor(encumbranceCurrent+0.5).. "/"..math.floor(encumbranceMax+0.5),
					textSize= headerFooterHeight*0.82,----20*textSizeMult,
					position = v2(0.85*headerFooterHeight+8, headerFooterHeight/2+1),
					size  = v2(55+0.85*headerFooterHeight,0.85*headerFooterHeight),
					anchor = v2(0,0.5),
					textColor = encumbranceColor,
				},
			})
		end
		if isPickpocketing and pickpocket.footerText and (header_footer_setting == "show both" or header_footer_setting == "only bottom") then
			local flex = {
				name = "footerPickpocketFlex",
				type = ui.TYPE.Flex,
				props = {
					--size  = v2(0.85*headerFooterHeight,0.85*headerFooterHeight),
					anchor = v2(1,0),
					relativePosition = v2(1,0),
					horizontal = true,
					position = v2(0,1)
				},
				content = ui.content{}
			}
			footer.content:add(flex)
			
			flex.content:add{
				name = "footerFlexPickpocketIcon",
				type = ui.TYPE.Image,
				props = {
					resource = pickpocketTex,
					tileH = false,
					tileV = false,
					size  = v2(0.85*headerFooterHeight,0.85*headerFooterHeight),
					--position = v2(8,2),
					--alpha = 0.5,
					--anchor = v2(0,0),
					color = pickpocket.footerColor or FONT_TINT,
					alpha = 0.7,
				}
			}
			flex.content:add{ name = "footerFlexSpacer", props = { size = v2(1, 1) * 2 } }
			flex.content:add{
				name = "footerFlexPickpocketText",
				type = ui.TYPE.Text,
				template = quickLootText,
				props = {
					text = ""..pickpocket.footerText.." ",
					textSize= headerFooterHeight*0.82,----20*textSizeMult,
					--position = v2(0.85*headerFooterHeight+8, headerFooterHeight/2+1),
					--size  = v2(55+0.85*headerFooterHeight,0.85*headerFooterHeight),
					--anchor = v2(0,0.5),
					textColor = pickpocket.footerColor or FONT_TINT,
				},
			}
		end
		if header_footer_setting == "all bottom" then
			local widgetOffset = 0.05 -- for scrollbar
			--list FOOTER ICONS
			for _, widget in pairs(widgets) do
				footer.content:add({
					name = "footerColumnIcon_"..widget,
					type = ui.TYPE.Image,
					props = {
						resource = _G[widget.."Tex"],
						tileH = false,
						tileV = false,
						size  = v2(0.95*headerFooterHeight,0.95*headerFooterHeight),
						relativePosition = v2(1-widgetOffset, -0.05),--itemBoxHeaderFooterHeight),
						position = v2(0,0),
						anchor = v2(1,0),
						alpha = 0.8,
						color = ICON_TINT,
					}
				})
				widgetOffset =widgetOffset+ math.max(0.12,0.105*textSizeMult)--itemBoxHeaderFooterHeight*headerFooterScale
			end
		end
	end
	-- /FOOTER
	
	
	-- SUB-FOOTER
	if FOOTER_HINTS ~= "Disabled" then
		-- right slot = take all = ToggleWeapon, left slot = search = ToggleSpell
		local fTex, rTex
		if FOOTER_HINTS == "Keys" then
			fTex = resolveHint("ToggleWeapon", TAKE_ALL_KEY) or fKeyTex
			rTex = resolveHint("ToggleSpell", ALT_KEY) or rKeyTex
		else
			fTex = fSymbolicTex
			rTex = rSymbolicTex
		end
			
		--SUB-FOOTER ICON Right
		root.layout.content:add({
			name = "subFooterIconRight",
			type = ui.TYPE.Image,
			props = {
				resource = fTex,
				tileH = false,
				tileV = false,
				size  = v2(outerHeaderFooterHeight*0.8,outerHeaderFooterHeight*0.8),
				position = v2(rootWidth*0.505,rootHeight-outerHeaderFooterHeight/2),
				anchor = v2(0,0.5),
				alpha = 0.6,
				color = ICON_TINT,
				
			}
		})
		--SUB-FOOTER TEXT Right
		root.layout.content:add({
			name = "subFooterTextRight",
			type = ui.TYPE.Text,
			template = quickLootText,
			props = {
				text = deposit and "Deposit All" or "Take All",
				textSize= 20*textSizeMult,
				position = v2(rootWidth*0.508+outerHeaderFooterHeight*0.8,rootHeight-outerHeaderFooterHeight/2+1),
				textColor = ICON_TINT,
				anchor = v2(0,0.5),
			},	})
		--SUB-FOOTER ICON Left
		root.layout.content:add({
			name = "subFooterIconLeft",
			type = ui.TYPE.Image,
			props = {
				resource = rTex,
				tileH = false,
				tileV = false,
				
				size = v2(outerHeaderFooterHeight*0.8,outerHeaderFooterHeight*0.8),
				position = v2(rootWidth*0.495,rootHeight-outerHeaderFooterHeight/2),
				anchor = v2(1,0.5),
				alpha = 0.6,
				color = ICON_TINT,
			}
		})
		--SUB-FOOTER TEXT Left
		local searchText = "Search"
		local effectiveDeposit = R_DEPOSIT2 == "Yes" or (R_DEPOSIT2 == "Only when pickpocketing" and isPickpocketing)
		if effectiveDeposit then
			if deposit then
				searchText = "Withdraw"
			else
				searchText = "Deposit"
			end
		end
		root.layout.content:add({
			name = "subFooterTextLeft",
			type = ui.TYPE.Text,
			template = quickLootText,
			props = {
				text = searchText,
				textSize= 20*textSizeMult,
				textAlignH = ui.ALIGNMENT.End,
				position = v2(rootWidth*0.493-outerHeaderFooterHeight*0.8,rootHeight-outerHeaderFooterHeight/2+1),
				anchor = v2(1,0.5),
				textColor = ICON_TINT,
			},
		})
	end
	-- /SUB-FOOTER
	
	-- hud modifiers
	local modCtx = {
		element = root,
		layout = root.layout,
		target = inspectedContainer,
		items = containerItems,
		selectedIndex = selectedIndex,
		scrollPos = scrollPos,
		renderedCount = renderedEntries,
		deposit = deposit,
		isPickpocket = isPickpocketing,
		formatNumber = formatNumber,
	}
	for _, entry in ipairs(hudModifierChain.entries) do
		local ok, result = pcall(entry.func, modCtx)
		if not ok then
			print("QuickLoot hud modifier "..tostring(entry.id or "?").." failed: "..tostring(result))
		elseif result == false then
			break
		end
	end
end

function closeHud()
	if inspectedContainer then
		setPickpocketTimeScale(false)
		inspectedContainer:sendEvent("OwnlysQuickLoot_closeAnimation",self)
		local closingStamp = savegameData.probeStamps[inspectedContainer.id]
		if closingStamp and closingStamp > 0 then
			savegameData.probeStamps[inspectedContainer.id] = math.max(closingStamp, core.getSimulationTime() - PROBE_CACHE)
		end
		inspectedContainer = nil
		Controls.overrideCombatControls(false)
		types.Player.setControlSwitch(self, types.Player.CONTROL_SWITCH.Magic, true) 
		types.Player.setControlSwitch(self, types.Player.CONTROL_SWITCH.Fighting, true)
		types.Player.setControlSwitch(self, types.Player.CONTROL_SWITCH.Jumping, true)
		core.sendGlobalEvent("OwnlysQuickLoot_closeGUI", self.object)
		Camera.enableZoom("quickloot")
		containerHash = 99999999
		pickpocket.closeHud(self)
		approvedContainer = nil
		if root then
			root:destroy()
		end
		if tooltip then
			tooltip.shell:destroy()
			tooltip.destroy()
			tooltip = nil
		end
	end
end

function scriptAllows(cont)
	if types.Actor.objectIsInstance(cont) and not types.Actor.isDead(cont) then
		return true
	end
	if types.Lockable.getTrapSpell(cont) then
		return false
	end
	local script = cont.type.record(cont).mwscript
	if not script then
		return true
	end
	if qlScriptWhitelist[script] then
		log(script.." ok (whitelisted)")
		return true
	end
	if qlScriptBlacklist[script] then
		log(script.." not ok (blacklisted)")
		return false
	end
	local verdict = scriptVerdicts[script]
	if not verdict then
		local scriptRecord = core.mwscripts.records[script]
		local body = ""
		-- x->onactivate suppresses x, only the bare forms touch this object
		if scriptRecord then
			body = ("\n"..scriptRecord.text:lower().."\n"):gsub(";[^\n]*", "")
			body = body:gsub("%->%s*onactivate", "")
			body = body:gsub("%->%s*activate", "")
		end
		if not body:find("[^%w_]onactivate[^%w_]") then
			verdict = "loot"
		elseif (body:gsub("onactivate", "")):find("[^%w_]activate[^%w_]") then
			verdict = "probe"
		else
			-- reads its own flag and never activates itself, the window can never open
			verdict = "inert"
		end
		scriptVerdicts[script] = verdict
	end
	if verdict == "loot" then
		return true
	end
	if verdict == "inert" then
		log(script.." not ok (never activates itself)")
		return false
	end
	if not PROBE_SCRIPTS then
		return false
	end
	if approvedContainer == cont.id then
		return true
	end
	local now = core.getSimulationTime()
	local stamp = savegameData.probeStamps[cont.id]
	local trustedFor = 3 + (stamp and stamp > 0 and PROBE_CACHE or 0)
	if not probe and (not stamp or now - math.abs(stamp) > trustedFor) then
		savegameData.probeStamps[cont.id] = -now
		probe = {container = cont, framesLeft = 10}
		if I.InventoryExtender and I.InventoryExtender.disableAllWindows then
			I.InventoryExtender.disableAllWindows(true)
			probe.ieMuted = true
		end
		core.sendGlobalEvent("OwnlysQuickLoot_probeActivation", {self, cont})
	end
	return not probe and (stamp or 0) > 0
end



function chargenFinished()
	if savegameData.chargenFinished then
		return true
	end
	if types.Player.getBirthSign(self) ~= "" then
		savegameData.chargenFinished = true
		return true
	end
	if types.Player.isCharGenFinished(self) then
		savegameData.chargenFinished = true
		return true
	end
	if types.Actor.inventory(self):find("chargen statssheet") then
		savegameData.chargenFinished = true
		return true
	end
	return false
end


local function targetFiltered(obj)
	for _, entry in ipairs(targetFilterChain.entries) do
		if entry.func(obj) == false then
			return true
		end
	end
	return false
end

local function isValidTarget(obj)
	if not obj then return false end
	if targetFiltered(obj) then return false end
	-- the engine only fires Died once the animation stops, opening earlier beats on-death scripts to the corpse
	local corpseReady = false
	if (obj.type == types.NPC or obj.type == types.Creature) and types.Actor.isDead(obj) then
		if LOOT_DURING_DEATH_ANIMATION == "immediately" or types.Actor.isDeathFinished(obj) then
			corpseReady = true
		elseif LOOT_DURING_DEATH_ANIMATION == "near the end" then
			for groupName in pairs(deathGroups) do
				local completion = animation.getCompletion(obj, groupName)
				if completion and completion > 0.55 then
					corpseReady = true
					break
				end
			end
		end
	end
	return (
		obj.type == types.Container
		and (not types.Container.record(obj).isOrganic or organicContainers[obj.recordId])
	) or corpseReady or (
		crimesVersion >= 2
		and PICKPOCKETING
		and pickpocket.validateTarget(self, obj, input)
	)
end

local function looseAimTarget(obj)
	return obj and (
		(
			obj.type == types.Container
			and (not types.Container.record(obj).isOrganic or organicContainers[obj.recordId])
		)
		or (crimesVersion >= 2 and PICKPOCKETING and pickpocket.validateTarget(self, obj, input))
	)
end

local function engineWillActivate(obj)
	if not obj then return false end
	local objType = obj.type
	if objType == types.Static or objType == types.BodyPart then
		return false
	end
	if objType == types.Activator then
		local name = types.Activator.record(obj).name
		return name ~= nil and name ~= ""
	end
	if objType == types.Light then
		return types.Light.record(obj).isCarriable
	end
	return true
end

-- async ring probe delivery, slot index baked into each callback
local looseAimCallbacks = {}
for i = 1, #looseAimOffsets do
	looseAimCallbacks[i] = async:callback(function(ringRes)
		looseAimSlots[i] = looseAimTarget(ringRes.hitObject) and ringRes or nil
	end)
end



function onFrame(dt)

	--print("onframe", I.UI.getMode() or "I.UI.getMode() = nil")
	printThrottle = printThrottle - dt
	-- pending probe
	if probe then
		if dt > 0 then
			probe.framesLeft = probe.framesLeft - 1
			if probe.framesLeft <= 0 then
				if probe.ieMuted then I.InventoryExtender.disableAllWindows(false) end
				probe = nil
			end
		end
	end
	--if inspectedContainer then
	--	-- Get the yaw angle of the container
	--	local containerYaw = inspectedContainer.rotation:getYaw()
	--	
	--	-- Calculate the angle from container to player in the horizontal plane
	--	local deltaX = self.position.x - inspectedContainer.position.x
	--	local deltaY = self.position.y - inspectedContainer.position.y
	--	local playerAngle = math.atan2(deltaX, deltaY)
	--	
	--	-- Calculate the relative angle (how far the player is from the container's forward direction)
	--	local relativeAngle = playerAngle - containerYaw
	--	-- Normalize to -pi to pi range
	--	while relativeAngle > math.pi do relativeAngle = relativeAngle - 2*math.pi end
	--	while relativeAngle < -math.pi do relativeAngle = relativeAngle + 2*math.pi end
	--	
	--	-- Determine the direction based on the angle
	--	local direction
	--	if math.abs(relativeAngle) < math.pi/4 then
	--		direction = "in front"
	--	elseif math.abs(relativeAngle) > 3*math.pi/4 then
	--		direction = "behind"
	--	elseif relativeAngle > 0 then
	--		direction = "right"
	--	else
	--		direction = "left"
	--	end
	--end
	if types.Actor.getStance(self) ~= types.Actor.STANCE.Nothing and input.getBooleanActionValue("Use") then
		return false
	end
	--if inspectedContainer and core.contentFiles.has("QuickSpellCast.omwscripts")  and types.Actor.getStance(self) == types.Actor.STANCE.Spell then
		--types.Actor.setStance(self, types.Actor.STANCE.Nothing)
	--end
 --self.controls.use = 0
	if not modEnabled then
		return
	end
	if not I.UI.isHudVisible() then
		closeHud()
		return
	end
	if not chargenFinished() then
		return
	end
	
	if I.UI.getMode() and not showInMainMenuOverride then
		return
	end
	if CONTAINER_ANIMATION == "disabled by shift" then
		local newShiftPressed = input.isShiftPressed()
		if shiftPressed ~= newShiftPressed then
			if inspectedContainer then
				if newShiftPressed then
					inspectedContainer:sendEvent("OwnlysQuickLoot_closeAnimation",self)
				else
					inspectedContainer:sendEvent("OwnlysQuickLoot_openAnimation",self)
				end
			end
		end
		shiftPressed = newShiftPressed
	end
	local camera = require('openmw.camera')
	local cameraPos = camera.getPosition()
	local iMaxActivateDist = core.getGMST("iMaxActivateDist")+0.1
	local activationDistance = iMaxActivateDist + camera.getThirdPersonDistance();
	local bonusDistance = 0
	if hoveredContainer then
		bonusDistance = 20
	end
	local telekinesis = types.Actor.activeEffects(self):getEffect(core.magic.EFFECT_TYPE.Telekinesis);
	if (telekinesis) then
		activationDistance = activationDistance + (telekinesis.magnitude * 22);
	end
	activationDistance = activationDistance+0.1
	
	local options
	if camera.getMode() ~= camera.MODE.FirstPerson then
		options = { ignore = self }
	end
	
	local res = I.SharedRay.get()
	-- ------------------------------ loose aiming ------------------------------
	-- ring probe fires every frame so slots stay fresh while the center ray has a target
	if LOOSE_AIMING == "shotgun" then
		local slot = looseAimCursor
		nearby.asyncCastRenderingRay(
			looseAimCallbacks[slot],
			cameraPos,
			cameraPos + camera.viewportToWorldVector(looseAimOffsets[slot]) * activationDistance,
			{ ignore = self }
		)
		looseAimCursor = slot % #looseAimOffsets + 1
	end
	if not engineWillActivate(res.hitObject) then
		if LOOSE_AIMING == "boundingbox" then
			local hit = nearby.castRay(
				cameraPos,
				cameraPos + camera.viewportToWorldVector(v2(0.5,0.5)) * (activationDistance + bonusDistance),
				options
			)
			if hit.hitObject
				and looseAimTarget(hit.hitObject)
				and (cameraPos - hit.hitPos):length() <= activationDistance + bonusDistance then
				res = hit
			end
		elseif LOOSE_AIMING == "shotgun" then
			for i = 1, #looseAimOffsets do
				if looseAimSlots[i] then
					res = looseAimSlots[i]
					break
				end
			end
		end
	end
	-- ------------------------------------------------------------------------
	if (not res.hitObject or (res.hitObject.type ~= types.Container and not types.Actor.objectIsInstance(res.hitObject))) then
		res = {hitObject = nil}
	end
	hoveredContainer = res.hitObject
	if inspectedContainer and (
		res.hitObject == nil
		or res.hitObject ~= inspectedContainer
		or (inspectedContainer.type == types.Container and types.Lockable.getTrapSpell(inspectedContainer))
		or targetFiltered(inspectedContainer)
	) then
		closeHud()
	elseif inspectedContainer and types.Actor.getEncumbrance(self) ~= encumbranceCurrent then
		drawUI()
	end
	--if inspectedContainer then
	--	print(inspectedContainer.rotation)
	--end
	
	if inspectedContainer 
	and res.hitObject
	and res.hitObject.type == types.NPC
	and not types.Actor.isDead(res.hitObject) --opened container that is not dead
	and not (
			crimesVersion >= 2
			and PICKPOCKETING
			and pickpocket.validateTarget(self, res.hitObject, input)
		)
	
	--(
	--	types.Actor.getStance(res.hitObject) ~= types.Actor.STANCE.Nothing 
	--	or not input.getBooleanActionValue("Sneak") -- but it's also not idle or the player not sneaking (anymore)
	--)
	then
		closeHud()
	end
	if inspectedContainer then
		pickpocket.onFrame(self, inspectedContainer, input, drawUI)
	elseif not inspectedContainer
	and res.hitObject
	and isValidTarget (res.hitObject)
	and not types.Lockable.isLocked(res.hitObject)
	and not types.Lockable.getTrapSpell(res.hitObject)
	and scriptAllows(res.hitObject)
	then
		if not types.Container.inventory(res.hitObject):isResolved() then
			core.sendGlobalEvent("OwnlysQuickLoot_resolve",res.hitObject)
		else
			core.sendGlobalEvent("OwnlysQuickLoot_resolve",res.hitObject)
			inspectedContainer = res.hitObject
			self.controls.use = 0
			Controls.overrideCombatControls(true)
			types.Player.setControlSwitch(self, types.Player.CONTROL_SWITCH.Magic, false) 
			types.Player.setControlSwitch(self, types.Player.CONTROL_SWITCH.Fighting, false)
			core.sendGlobalEvent("OwnlysQuickLoot_openGUI",self.object)

			-- custom keys can collide with any engine action, block everything but movement and camera
			if TAKE_KEY or TAKE_ALL_KEY or ALT_KEY or UP_KEY or DOWN_KEY
			or (DISPOSE_CORPSE == "Jump" and types.Actor.objectIsInstance(inspectedContainer)) then
				types.Player.setControlSwitch(self, types.Player.CONTROL_SWITCH.Jumping, false)
			end
			Camera.disableZoom("quickloot")
			if CONTAINER_ANIMATION == "immediately" or CONTAINER_ANIMATION == "disabled by shift" and not input.isShiftPressed() then
				inspectedContainer:sendEvent("OwnlysQuickLoot_openAnimation",self)
			end
			selectedIndex = 1
		end
	end
	if inspectedContainer then
		local newHash = ""
		local entryCount = 0
		local inv =nil
		if deposit then
			inv = types.Container.inventory(self):getAll()
		else
			inv = types.Container.inventory(inspectedContainer):getAll()
		end
		for _, thing in pairs(inv) do
			--itemCount = itemCount + thing.count
			newHash = newHash..thing.count..thing.recordId
			entryCount = entryCount + 1
		end
		if entryCount < selectedIndex then
			selectedIndex = entryCount
		end
		
		--print(newHash)
		if containerHash ~= newHash then
			drawUI()
		end
		
		containerHash = newHash
	end
end

local function onKey(key)
	usingGamepad = false
	if not modEnabled then
		return
	end
	customKeybindPressed(key.code)
end
local function onMouseButton(button)
	usingGamepad = false
	if not modEnabled then
		return
	end
	customKeybindPressed(-button)
end
local function onMouseWheel(vertical)
	usingGamepad = false
	if not modEnabled then
		return
	end
	if inspectedContainer then
		moveSelection(-vertical)
	end
end

function onControllerButtonPress(ctrl)
	usingGamepad = true
	if not modEnabled then
		return
	end
	if customKeybindPressed(1000 + ctrl) then
		return
	end
	if inspectedContainer then
		local delta = 0
		if ctrl == input.CONTROLLER_BUTTON.DPadDown then
			delta = 1
		elseif ctrl == input.CONTROLLER_BUTTON.DPadUp then
			delta = -1
		end
		moveSelection(delta)
	end
end

function lootItem()
	--local function activatedContainer(data)
	--local cont = data[1]
	local cont = inspectedContainer
	--local isAlive = data[2] --isPickpocketing (nil for containers)
	if not modEnabled or not cont then
		return
	end
	if not lootAllowed(deposit and "deposit" or "take", containerItems[selectedIndex]) then
		return
	end
	local isActor = types.Actor.objectIsInstance(cont)
	local isAlive = isActor and not types.Actor.isDead(cont)  --isPickpocketing (nil for containers)
	--print(inspectedContainer,cont)
	--if inspectedContainer == cont then
	if containerItems[selectedIndex] then
		if isAlive then
			if deposit and pickpocket.version then
				pickpocket.reversePickpocket(self, inspectedContainer, containerItems[selectedIndex])
			else
				pickpocket.stealItem(self, inspectedContainer, containerItems[selectedIndex])
			end
			drawUI()
		else
			if deposit then
				core.sendGlobalEvent("OwnlysQuickLoot_deposit",{self, cont, containerItems[selectedIndex], isAlive, EXPERIMENTAL_LOOTING})
			else
				core.sendGlobalEvent("OwnlysQuickLoot_take",{self, cont, containerItems[selectedIndex], isAlive, EXPERIMENTAL_LOOTING})
			end
		end
		if not isActor and CONTAINER_ANIMATION == "on take" then
			inspectedContainer:sendEvent("OwnlysQuickLoot_openAnimation",self)
		end
	else
		core.sendGlobalEvent("OwnlysQuickLoot_transferIfEmpty",{self, cont, containerItems[selectedIndex], isAlive, EXPERIMENTAL_LOOTING})
	end
	if pickpocket.activate(self, inspectedContainer, input) then
		drawUI()
	end
	--elseif not inspectedContainer and not scriptAllows(cont) then
	--	core.sendGlobalEvent("OwnlysQuickLoot_vanillaActivate",{self, cont, true})
	--end
end
input.registerTriggerHandler('Activate', async:callback(function()
	if TAKE_KEY then
		return
	end
	local faced = I.SharedRay.get().hitObject
	if faced and faced ~= inspectedContainer and engineWillActivate(faced) then
		return
	end
	lootItem()
end))
--end

local function UiModeChanged(data)
	if (data.newMode == "Book" or data.newMode == "Scroll") and data.arg.recordId then
		local now = core.getRealTime()
		currentBook = data.arg.recordId
		if not bookSection:get(currentBook) then
			if data.newMode == "Book" then
				bookSection:set(currentBook, 0)
			else
				bookSection:set(currentBook, 10)
			end
		end
		bookTimer = now
		savegameData.bookSection[data.arg.recordId] = true
	elseif (data.oldMode == "Book" or data.oldMode == "Scroll") and currentBook then
		local now = core.getRealTime()
		local DBentry = bookSection:get(currentBook)
		bookSection:set(currentBook, DBentry + now - bookTimer)
		--print("read for "..(now-bookTimer).." seconds")
	end
	if not modEnabled then
		return
	end
	if data.newMode then
		if probe and data.newMode == "Container" and data.arg and data.arg.id == probe.container.id then
			I.UI.removeMode("Container")
			if probe.ieMuted then I.InventoryExtender.disableAllWindows(false) end
			savegameData.probeStamps[probe.container.id] = math.abs(savegameData.probeStamps[probe.container.id])
			approvedContainer = probe.container.id
			probe = nil
		else
			if probe and probe.ieMuted then I.InventoryExtender.disableAllWindows(false) end
			probe = nil
			closeHud()
		end
	end
	showInMainMenuOverride = false
end

local function onLoad(data)
	updateModEnabled()
	core.sendGlobalEvent("OwnlysQuickLoot_getCrimesVersion",self)
	if data then
		savegameData = data.savegameData or {}
	else
		savegameData = {}
	end
	if not savegameData.probeStamps then
		savegameData.probeStamps = {}
	end
	if not savegameData.bookSection then
		savegameData.bookSection = {}
	end
end

local function onSave()
    return {
        savegameData = savegameData
    }
end

local function receiveCrimesVersion(ver)
	if ver < 2 then
		print("OpenMW version too low, no pickpocket support")
	end
	crimesVersion = ver
end

local function toggle(onOff,uniqueFlag)
	modDisableFlags[uniqueFlag] = onOff
	updateModEnabled()
end

local function windowVisible()
	if inspectedContainer then
		return true
	end
	return false
end

local function playSound(sound)
	ambient.playSound(sound)
end

-- re-equips granted ammo, the engine never auto stacks into an equipped slot
local function equipAmmo(data)
	local equipment = types.Actor.getEquipment(self)
	equipment[data[2]] = data[1]
	types.Actor.setEquipment(self, equipment)
end

local function refreshUi()
	if root then
		drawUI()
	end
end

-- shared tooltip registrations, onActive so the winning module version is settled
local function onActive()
	if pickpocket.registerTooltipModifier then
		pickpocket.registerTooltipModifier()
	end
end


return {    
	eventHandlers = {
		UiModeChanged = UiModeChanged,
		OwnlysQuickLoot_windowVisible = windowVisible,
		OwnlysQuickLoot_toggle = toggle, -- toggle(<true/false>, "myModName")
		OwnlysQuickLoot_receiveCrimesVersion = receiveCrimesVersion,
		OwnlysQuickLoot_playSound = playSound,
		OwnlysQuickLoot_equipAmmo = equipAmmo,
		OwnlysQuickLoot_refreshUi = refreshUi,
	},
	engineHandlers = {
		onFrame = onFrame,
		onUpdate = onUpdate,
		onKeyPress = onKey,
		onMouseButtonPress = onMouseButton,
		onMouseWheel = onMouseWheel,
		onControllerButtonPress = onControllerButtonPress,
        onSave = onSave,
        onLoad = onLoad,
        onInit = onLoad,
        onActive = onActive,
    },
	interfaceName = "QuickLoot",
	interface = {
		version = 6,
		lootItem = lootItem,
		isBookRead = function(recordId)
			return savegameData.bookSection[recordId] == true
		end,
		getReadBooks = function()
			return savegameData.bookSection
		end,
		getReadingTime = function(recordId)
			return bookSection:get(recordId) or 0
		end,
		registerLootInterceptor = lootInterceptorChain.register,
		unregisterLootInterceptor = lootInterceptorChain.unregister,
		registerTargetFilter = targetFilterChain.register,
		unregisterTargetFilter = targetFilterChain.unregister,
		registerHudModifier = hudModifierChain.register,
		unregisterHudModifier = hudModifierChain.unregister,
	}
	--eventHandlers = {
    --    FHB_AI_update = AI_update,
    --}
}