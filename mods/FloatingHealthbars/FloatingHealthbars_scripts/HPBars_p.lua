local computeBoundingBoxes = false -- DO NOT USE THIS SETTING ON YOUR SAVEGAME -- set to true here and in HPBars_g.lua, use tcl to go out of bounds (below the world) and press "f". when it's done, press "h" and copy the console output into computedBoxes {} (in database.lua)

--secret setting: (0-1)
HP_TEXT_ALPHA = nil
--the actor's level reaches it's maximum shade of green or red if it's this much above/below the player:
LEVEL_COLOR_RANGE = 8

types = require('openmw.types')
NPC = require('openmw.types').NPC
core = require('openmw.core')
storage = require('openmw.storage')
I = require("openmw.interfaces")
self = require("openmw.self")
nearby = require('openmw.nearby')
camera = require('openmw.camera')
util = require('openmw.util')
ui = require('openmw.ui')
auxUi = require('openmw_aux.ui')
async = require('openmw.async')
vfs = require('openmw.vfs')
input = require('openmw.input')
v2 = util.vector2
v3 = util.vector3
local modData = storage.globalSection('HPBars')
local KEY = require('openmw.input').KEY
local boxCache = {}
local makeBorder = require("FloatingHealthbars_scripts.makeborder")
local frame = 0
local animation = require('openmw.animation')
local lastCameraRotation = camera.viewportToWorldVector(v2(0.5,0.5))




NAME = nil
HP = nil
HP_MAXHP = nil
BUFFS = nil
local helpers = require("FloatingHealthbars_scripts.helpers")
hdTexPath, vfx, unpackV3, nextValue, tableFind, readFont, toutf8, fromutf8 = unpack(helpers)

local s = require("FloatingHealthbars_scripts.settings")
local updateSettings, applyRows, readAllSettings, settingsTemplate = unpack(s)

local database = require("FloatingHealthbars_scripts.database")
local customHeights, computedBoxes, customScales, modelBlacklist, checkedModels  = unpack(database)

if computeBoundingBoxes then
	require("FloatingHealthbars_scripts.computeBoundingBoxes")
end

--local inProgress = {}
barCache = {}
local AI_DB = {}
--raytracing
local raytracing = {}
local nextRay = nil
local raysPerTick = 1
-- Textures
local foreground = ui.texture { path = "textures/HPBARS_Bar.dds" }
local background = ui.texture { path = 'black' }

local buffCache = {}
local iconCache = {}
local nextBuffUpdate = nil
queueSettingsChange = {}
local activeBars = {}
local stylizedCache = {}
stylizedBars = {
	["stylized 1"] = {
		path = "1",
		start = 67,
		["end"] = 1690,
		width = 1757,
		height = 147,
		deco=false,
	},
	["stylized 2"] = {
		path = "4",
		start = 91,
		["end"] = 1720,
		width = 1812,
		height = 137,
		deco=true,
	},
	["stylized 3"] = {
		path = "8",
		start = 65,
		["end"] = 1691,
		width = 1830,
		height = 56,
		deco=false,
	},
	["stylized 4"] = {
		path = "9",
		start = 56,
		["end"] = 1752,
		width = 1808,
		height = 120,
		deco=false,
	},
}


applyRows()


-- lineheight is the absolute minimum that the font needs to be displayed, not the real font's line height, so the font might not be centered
glyphs,lineHeight = readFont("textures\\FloatingHealthbars_fonts\\"..FONT..".fnt")
lineXOffset = 0.0
daedric,daedricHeight = readFont("textures\\FloatingHealthbars_fonts\\ayembedt.fnt")


local containerContent = {}
local container = {	
	type = ui.TYPE.Container,
	layer = 'HUD',
	content = ui.content(containerContent)
}
local hud = ui.create(container)



local function ownlysLag(current, lerped, cached, paused, lag, timer, dt, drainSpeed, timerLength, treshold)
	local mult = drainSpeed/8
	if current > lerped then
		lerped = math.min(current,lerped*(1-dt*mult) + current*dt*mult)
	else
		lerped = math.max(current,lerped*(1-dt*mult) + current*dt*mult)
	end
	--lerped = math.max(current,lerped - dt * drainSpeed)
	if current > paused then
		paused = current
	end
	if current > lag then
		lag = lerped
	end
	if current < cached -treshold then 
		timer = 0
	else
		timer = timer + dt 
	end
	if timer > timerLength then
		paused = current
	end
	if lag > paused  then 
		lag = math.max(paused,lag - dt * drainSpeed)
	end
	return paused, lag, timer, lerped
end

function calculateHealing(actor)
	local timeBand = 3
	local incomingHealing = 0
	for a,b in pairs(types.Actor.activeSpells(actor)) do
		for c,d in pairs(b.effects) do
			if d.id == "restorehealth" then --and d.durationlLeft then -- should permanent effects count? let's say yes
				local duration = math.max(0,math.min(timeBand,d.durationLeft or timeBand))
				incomingHealing= incomingHealing +(d.maxMagnitude+d.minMagnitude)/2*duration
			end
		end
	end
	return incomingHealing
end



local function texText(t)--currentHealth,maxHealth,size,color, widgetWidth, widgetHeight, align)
	if t.currentHealth == "player" then
		return {}
	end
	local glyphs = glyphs
	local lineHeight = lineHeight
	if t.obscured then
		glyphs = daedric
		lineHeight = daedricHeight
	end
	local widgetWidth = t.widgetWidth or 50
	local widgetHeight = t.widgetHeight or 14
	local lineLevel = 0
	local size = (t.size or HP_SIZE)
	local relScale = 1/lineHeight*size
	local aspectRatio = widgetHeight/widgetWidth
	local str = ""
	if type(t.currentHealth) == "number" then
		str= str..math.floor(t.currentHealth)
	else
		str = str..(t.currentHealth or "")
	end
	if HP_MAXHP and t.maxHealth then
		str = str.."/"..math.floor(t.maxHealth)
	end
	local ret = {}
	local totalWidth = 0
	
	local middleOffset = 0
	local stretchGlyph = 1.1
	local gapMult = 0.5
	str = fromutf8(str)
	for i=1, #str do
		local symbol = str:sub(i,i)
		if glyphs[symbol] and glyphs[symbol].width then
			local glyphHeight = lineHeight
			--local glyphHeight = glyphs[symbol].height
			local spaceLeft = glyphs[symbol].xoffset*gapMult
			local spaceRight = (glyphs[symbol].xadvance- glyphs[symbol].xoffset- glyphs[symbol].width)*gapMult
			local glyphWidth =  glyphs[symbol].width*stretchGlyph
			if symbol == " " then
				glyphWidth = glyphWidth+8
			end
			local total = spaceLeft+spaceRight+glyphWidth
			local relTotal = relScale* total   *aspectRatio
			if symbol =="/" then
				middleOffset = totalWidth+relTotal/2
			end
			totalWidth = totalWidth+relTotal
		end
	end
	if middleOffset > 0 then
		middleOffset = totalWidth/2-middleOffset
	end
	local currentPos = 0.5-totalWidth/2+middleOffset
	if t.align =="right" then
		currentPos = 0
	elseif t.align == "left" then
		currentPos = 1-totalWidth
	end
	local levelChars = {"a","b","c","d","e"}
	local lineLevel= 0
	for a,b in pairs(levelChars) do
		if glyphs[b] then
			lineLevel = math.max(lineLevel, glyphs[b].height+glyphs[b].yoffset)
		end
	end
	if lineLevel == 0 then
		lineLevel = glyphs["0"].height+glyphs["0"].yoffset
	end
	lineLevel = lineLevel+0.005
	for i=1, #str do
		local symbol = str:sub(i,i)
		if glyphs[symbol] and glyphs[symbol].width then
			local glyphHeight = lineHeight
			--local glyphHeight = glyphs[symbol].height
			local spaceLeft = glyphs[symbol].xoffset*gapMult
			local spaceRight = (glyphs[symbol].xadvance- glyphs[symbol].xoffset- glyphs[symbol].width)*gapMult
			local glyphWidth =  glyphs[symbol].width*stretchGlyph
			if symbol == " " then
				glyphWidth = glyphWidth+10
			end
			local total = spaceLeft+spaceRight+glyphWidth
			local relSpaceLeft = relScale*spaceLeft*aspectRatio
			local relSpaceRight = relScale*spaceRight*aspectRatio
			local relWidth = relScale*glyphWidth*aspectRatio
			--print(relScale,glyphWidth,aspectRatio)
			--print(glyphs[symbol].height*relScale,glyphs[symbol].height,relScale)
			local relTotal = relScale*total*aspectRatio
			local letterDepth = (glyphs[symbol].height+glyphs[symbol].yoffset-lineLevel)/lineHeight
			if math.abs(letterDepth) < 0.01 then
				letterDepth = math.max(0, letterDepth)
			end
			local yPos = 0.41+size/3+letterDepth*relScale*160+TEXT_OFFSET
			local anchor = letterDepth / (glyphs[symbol].height*relScale)/1.5
			table.insert(ret,{
				type = ui.TYPE.Image,
				props = {
					resource = glyphs[symbol].texture,
					relativePosition= v2(currentPos+relSpaceLeft, yPos),--glyphs[symbol].yoffset*relScale+(1-size)/2),
					relativeSize  = v2(relWidth, glyphs[symbol].height*relScale),
					color = t.color,
					anchor = v2(0,1)
				}
			} )
			currentPos = currentPos + relTotal
		end
	end
	--table.insert(ret,{
	--	type = ui.TYPE.Image,
	--	props = {
	--		resource = background,
	--		tileH = false,
	--		tileV = false,
	--		relativeSize  = v2(1,1),
	--		alpha = 0.6,
	--	},
	--})
	return ret
end

local function shortestBuff(actor)
	local shortest =9000
	for a,b in pairs(types.Actor.activeSpells(actor)) do
		--if ( b.caster ~=actor) then
			for c,d in pairs(b.effects) do
				if (d.duration) then
					shortest = math.min(shortest,d.duration)
				end
			end
		--end
	end
	return shortest~=9000 and shortest
end


local function updateBuffIcons(c)
	local actor = c.actor
	--local isntPlayer = c.actor ~= self.object
	local content = {}
	local i = 0
	local iconSize = math.min(2,BUFF_ICONSIZE)*0.5
	local width = iconSize*7/50*2
	local bc = buffCache[actor.id]
	local multSizes = 1
	if width*(bc.buffCount+bc.debuffCount) > 0.97 then
		multSizes = 0.97/(width*(bc.buffCount+bc.debuffCount))
	end
	local buffCount = 0
	local debuffCount = 0
	local aboveBelow =  BUFFS.BUFFANCHOR ~= "bottom" and 0 or 1
--	local relPos = 
	--if BUFFS.BUFFANCHOR == "bottom" then
		
	if (bc.buffCount+bc.debuffCount) > 0 or #c.bar.layout.content[1].layout.content[5].layout.content > 0 then
		for a,b in pairs(bc.buffs) do
			buffCount=buffCount+1
			table.insert(content,{
				type = ui.TYPE.Image,
				props = {
					resource = iconCache[b[1]],
					relativePosition= v2(1-buffCount*width*multSizes,(1-iconSize*multSizes)*aboveBelow),
					relativeSize  = v2(width*multSizes*1.007,iconSize*multSizes*1.007),
					alpha = b[2],
				}
			} )
		end
		for a,b in pairs(bc.debuffs) do
			table.insert(content,{
				type = ui.TYPE.Image,
				props = {
					resource = iconCache[b[1]],
					relativePosition= v2(debuffCount*width*multSizes,(1-iconSize*multSizes)*aboveBelow),
					relativeSize  = v2(width*multSizes*1.007,iconSize*multSizes*1.007),
					alpha = b[2],
				}
			} )
			debuffCount=debuffCount+1
		end
		--table.insert(content,{
		--	type = ui.TYPE.Image,
		--	props = {
		--		resource = background,
		--		tileH = false,
		--		tileV = false,
		--		relativeSize  = v2(1,1),
		--		alpha = 0.6,
		--	},
		--})
		c.bar.layout.content[1].layout.content[5].layout.content = ui.content (content)
		c.bar.layout.content[1].layout.content[5]:update()
	end
	
end

local function update(c,currentHealth,maxHealth,sizeMult)
	local now = core.getSimulationTime()
	local level = nil
	local levelColor = nil
	local borderColor = nil
	local healthPct = math.min(1,currentHealth/maxHealth)
	local fatigue = types.Actor.stats.dynamic.fatigue(c.actor).current
	local magicka = types.Actor.stats.dynamic.magicka(c.actor).current
	local maxFatigue = types.Actor.stats.dynamic.fatigue(c.actor).base
	local maxMagicka = types.Actor.stats.dynamic.magicka(c.actor).base
	--print(fatigue/maxFatigue)
	local t

	local hostileColor =  util.color.rgb(unpackV3(HOSTILE_COL:asRgb()*healthPct+HOSTILE_DAMAGED_COL:asRgb()*(1-healthPct)))
	local neutralColor = util.color.rgb(unpackV3(NEUTRAL_COL:asRgb()*healthPct+NEUTRAL_DAMAGED_COL:asRgb()*(1-healthPct)))
	local allyColor = util.color.rgb(unpackV3(ALLY_COL:asRgb()*healthPct+ALLY_DAMAGED_COL:asRgb()*(1-healthPct)))
	local DAMAGE_COL = DAMAGE_COL
	local HEAL_COL = HEAL_COL
	local actorAI = AI_DB[c.actor.id]
	local isAlly = (types.Player.objectIsInstance(c.actor) or 
					actorAI and ( 
						actorAI.Follow and not actorAI.Combat or 
						actorAI.Follow and actorAI.Combat and actorAI.Combat < actorAI.Follow -1 
					)) == true
	local aggro = (not types.Player.objectIsInstance(c.actor) and actorAI and actorAI.Combat and actorAI.Combat > now-0.6) == true
	local reaction = aggro and "hostile" or isAlly and "ally" or "neutral"
	if aggro then
		HPBAR_COL = hostileColor
	elseif isAlly then
		HPBAR_COL = allyColor
	else
		HPBAR_COL = neutralColor
	end
	if c.reactionCache == nil then c.reactionCache = reaction end
	local playerLevel = types.Actor.stats.level(self).current
	local level = types.Actor.stats.level(c.actor).current
	if (LEVEL ~= "hidden" or BORDER_COLOR == "relative level") and c.actor ~= self.object then
		if LEVEL == "color-coded" or BORDER_COLOR == "relative level" then
			local r = math.max(0,math.min(1,1-(playerLevel-level)/LEVEL_COLOR_RANGE))
			local g = math.max(0,math.min(1,1-(level-playerLevel)/LEVEL_COLOR_RANGE))
			levelColor = util.color.rgb(r,g,0)
			if BORDER_COLOR == "relative level" then
				borderColor = util.color.rgb(r,g,0)
			end
		elseif LEVEL == "gray" then
			levelColor = util.color.rgb(0.75,0.75,0.75)
		elseif LEVEL == "bar-color" then
			levelColor = HPBAR_COL
		end
	end
	if BORDER_COLOR == "reaction" then
		
		if AI_DB[c.actor.id] and AI_DB[c.actor.id].Combat and AI_DB[c.actor.id].Combat > now-0.5 then
			borderColor = util.color.rgb(0.8,0.1,0.1)
		end
	end
	local nameColor
	if NAME_BEHAVIOR == "reaction color" then
		if reaction == "hostile" then
			nameColor = HOSTILE_COL
		else
			nameColor = util.color.hex("ffffff")
		end
	else
		nameColor = NAME_COL or util.color.hex("ffffff")
	end
	local incomingHealing = calculateHealing(c.actor)
	local template = stylizedBars[BORDER_STYLE]
	local resourceTemplate = {}
	if RESOURCES_SETTING == "Fatigue + Magicka" then
		resourceTemplate = {
			{ 
				type = ui.TYPE.Image,
				props = {
					resource = foreground,
					tileH = false,
					tileV = false,
					color = FATIGUE_COL,
					relativeSize  = v2(fatigue/maxFatigue,1),
					position = v2(0,-1), --for guarranteed visibility far away, but it seems to be always 1 pixel anyway
					anchor = v2(0,-0.9)
				},
			},
			{ 
				type = ui.TYPE.Image,
				props = {
					resource = foreground,
					tileH = false,
					tileV = false,
					color = MAGICKA_COL,
					relativeSize  = v2(magicka/maxMagicka,1),
					--position = v2(0,-1), --for guarranteed visibility far away, but it seems to be always 1 pixel anyway
					anchor = v2(0,-0.95)
				},
			}
		}
	elseif RESOURCES_SETTING~="nothing" then
		resourceTemplate = {
			{ 
				type = ui.TYPE.Image,
				props = {
					resource = foreground,
					tileH = false,
					tileV = false,
					color = RESOURCES_SETTING == "Magicka" and MAGICKA_COL or FATIGUE_COL,
					relativeSize  = v2(RESOURCES_SETTING == "Magicka" and magicka/maxMagicka or fatigue/maxFatigue,1),
					position = v2(0,0), --for guarranteed visibility far away, but it seems to be always 1 pixel anyway
					anchor = v2(0,-0.95)
				},
			}
		}
	end
	local borderOffset = BORDER_STYLE == "verythick" and 4 or BORDER_STYLE == "thick" and 3 or BORDER_STYLE == "normal" and 2 or (BORDER_STYLE == "thin" or BORDER_STYLE == "max performance") and 1 or 0
	if not c.bar then
		local actorName
		if NAME then
			actorName = c.actor.recordId
			if reaction == "hostile" and NAME_BEHAVIOR == "hidden in combat" then
				actorName = "player"
			end
			local npcRecord = types.NPC.record(actorName)
			if npcRecord and actorName ~= "player" then
				actorName = npcRecord.name
			end
			local creatureRecord = types.Creature.record(actorName)
			if creatureRecord then
				actorName = creatureRecord.name
			end
		end
		--TESTING (misc version)
		--local model = types.Creature.objectIsInstance(c.actor) and types.Creature.records[c.actor.recordId].model
		--if model then
		--	actorName = model
		--end
		local borderFile = "thin"
		if BORDER_STYLE == "verythick" or BORDER_STYLE == "thick" then
			borderFile = "thick"
		end
		local resources = {}
		borderTemplate =  makeBorder(borderFile, borderColor or nil, borderOffset).borders
		c.bar = 
			ui.create({	--root
				type = ui.TYPE.Widget,
				layer = 'HUD',
				props = {
					position = v2(65,10),
					size = v2(100*sizeMult+2,28*sizeMult+2),
					anchor = v2(0.5,0.75),
				},
				content = ui.content {
					
					ui.create({ --r.1
						type = ui.TYPE.Widget,
						props = {relativeSize  = v2(1,1)},
						content = ui.content {
							ui.create({ --r.1.1
								type = ui.TYPE.Widget,
								props = {
									relativeSize = BORDERS.relativeSize,
									relativePosition = BORDERS.relativePosition,
									size = BORDERS.size,
									--position = BORDERS.position,
									anchor = BORDERS.anchor,
									visible = not c.nameOnly,
								},
								content = ui.content ({
									{
										type = ui.TYPE.Image,
										props = {
											resource = background,
											tileH = false,
											tileV = false,
											--relativePosition= v2(0,0.5),
											--position=v2(1,1),
											--size = v2(-2,-2),
											relativeSize  = v2(1,1),
											--position = v2(1, 1),
											alpha = 0.5,
										},
									},
									BORDER_STYLE~="none" and 
									{ -- Border
										template = borderTemplate,
										props = {
											--relativeSize  = v2(1/2,0.5*THICKNESS),
											--relativeSize  = v2(0.999/2,0.999),
											relativeSize  = v2(1,1),
											--size = v2(1,-1),
											alpha = 0.5,
											--relativePosition= v2(0,0),
										}
									} or {},
								})
							}),
							ui.create({-- r.1.2
								type = ui.TYPE.Widget,
								props = {
									relativeSize  = v2(1,THICKNESS*0.25),
									relativePosition= HPBARS.relativePosition,
									anchor = HPBARS.anchor,
									--size = v2(-4,-4),
									--position = v2(1, 1),
									position = HPBARS.position, --v2(borderOffset, -borderOffset),
									size = HPBARS.size, --v2(-borderOffset*2,-borderOffset*2),
									visible = not c.nameOnly,
								},
								content = ui.content {
									LAGBAR and { -- Damage Bar r.1.2/1
										type = ui.TYPE.Image,
										props = {
											resource = foreground,
											--relativePosition= v2(0,0.5),
											tileH = true,
											tileV = false,
											color =  DAMAGE_COL,
											--position = v2(1, 1),
											--size = v2(-2,-3),
											size = v2(-borderOffset,0),
											relativeSize  = v2(c.healthLag/maxHealth/2,1)
										}
									} or {},
									{ -- HP Bar r.1.2/2
										type = ui.TYPE.Image,
										props = {
											resource = foreground,
											tileH = false,
											tileV = false,
											color = HPBAR_COL,
											--position = v2(1, 1),
											size = v2(-borderOffset,0),
											relativeSize  = v2(c.lerpHealth/maxHealth/2,1),
											relativePosition= v2(0,0),
										},
									},
									{ -- Healing r.1.2/3
										type = ui.TYPE.Image,
										props = {
											resource = foreground,
											tileH = true,
											tileV = false,
											color =  HEAL_COL,
											alpha = 0.45,
											size = v2(0,0),
											position = v2(-borderOffset,0),
											--size = v2(0,-2),
											relativePosition= v2(0,0),
										}
									},
								},
							}),
							RESOURCES_SETTING ~="nothing" and ui.create({ -- r.1.3
								type = ui.TYPE.Widget,
								props = {
									--position = v2(0, 1),
									relativeSize  = RESOURCES.relativeSize,
									size  = RESOURCES.size,
									--relativePosition = v2(0.5, 0.5+THICKNESS*0.25),
									position= RESOURCES.position,
									relativePosition= RESOURCES.relativePosition,
									anchor = RESOURCES.anchor,
									visible = not c.nameOnly,
									--size = v2(0,1),
									--props = {
									--	relativeSize  = v2(1,THICKNESS*0.249999),
									--	relativePosition= v2(0.25,0.5),
									--	size = v2(4,4),
									--	--position = v2(1, 1),
									--},
									--anchor=v2(0,-THICKNESS*28*0.25)
									--size = v2(0,1),
									--position = v2(0,-1),
									--visible = c.textVisible and  playerLevel>=level + REQUIRED_HP,
									--anchor = v2(0.5,0.5)
								},
								content = ui.content (resourceTemplate)
								--content = ui.content {{
								--		type = ui.TYPE.Image,
								--		props = {
								--			resource = background,
								--			tileH = false,
								--			tileV = false,
								--			relativeSize  = v2(1,1),
								--			alpha = 0.6,
								--		},
								--	},},
							}) or {},
							(HP or HP_MAXHP) and ui.create({ -- HP Numbers r.1.4
								type = ui.TYPE.Widget,
								props = {
									--position = v2(1, 1),
									relativeSize  = v2(0.5,0.4),
									relativePosition = (HP and HP.relativePosition or HP_MAXHP and HP_MAXHP.relativePosition),
									position = (HP and HP.position or HP_MAXHP and HP_MAXHP.position),
									--v2(0.5,0.25+ (
									--	HP_POSITION == "other side of buffs" and (
									--		BUFFS_SETTING == "above" and 0.25+THICKNESS*0.25+0.125-(1-HP_SIZE)/16 --below
									--		or 0.125+(1-HP_SIZE)/16 --above
									--	)
									--	or 0.25 + THICKNESS*0.125 --on bar
									--)),
									--0.01*(THICKNESS-HP_SIZE)),
									visible = not c.nameOnly and c.textVisible and  playerLevel>=level + REQUIRED_HP,
									anchor = v2(0.5,0.5),
									alpha = HP_TEXT_ALPHA,
								},
								content = ui.content (texText({currentHealth = currentHealth,maxHealth = maxHealth,widgetWidth = 100*0.5, widgetHeight = 28*0.4, color = HP_TEXT_COL}))
								--content = ui.content {{
								--		type = ui.TYPE.Image,
								--		props = {
								--			resource = background,
								--			tileH = false,
								--			tileV = false,
								--			relativeSize  = v2(1,1),
								--			alpha = 0.6,
								--		},
								--	},},
							}) or {},
							BUFFS and ui.create({ -- MGEF r.1.5
								type = ui.TYPE.Widget,
								props = {
									--position = v2(0, 2),
									relativeSize  = v2(0.5,0.5),
									relativePosition = BUFFS.relativePosition,--v2(0.25, BUFFS_SETTING == "above" and 0.2505 or 0.505+0.25*THICKNESS)
									position = BUFFS.position,--v2(0.25, BUFFS_SETTING == "above" and 0.2505 or 0.505+0.25*THICKNESS)
									visible = not c.nameOnly,
									anchor = BUFFS.anchor
									--size = v2(borderOffset*2,borderOffset*2),
								},
								content = ui.content ({})
							}) or{},
							LEVEL ~= "hidden" and c.actor ~= self.object and ui.create({ -- r.1.6
								type = ui.TYPE.Widget,
								props = {
									--position = v2(0, 1),
									relativeSize  = v2(0.1,0.25),
									anchor = v2(LEVEL_POSITION == "left" and 1 or 0,0.5),
									--relativePosition = v2(0.52,0.5-0.25*(1-THICKNESS)),
									position = LEVELTEXT.position,
									relativePosition = LEVELTEXT.relativePosition,
									visible = not c.nameOnly and not (hideLevelInsteadOfObscuring and playerLevel <level+REQUIRED_LEVEL),
								},
								content = ui.content (texText({currentHealth = level,size = LEVELTEXT_SIZE,color = levelColor,widgetWidth = 100*0.1,widgetHeight = 28*0.25,align = LEVEL_POSITION ,obscured = playerLevel <level+REQUIRED_LEVEL}))
							}) or {},
							NAME and ui.create({ -- r.1.7
								type = ui.TYPE.Widget,
								props = {
									---position = v2(0, 2),
									relativeSize  = v2(1,0.4),
									relativePosition = NAME.relativePosition,
									position = NAME.position,
									--visible = c.textVisible and  playerLevel>=level + REQUIRED_HP,
									anchor = v2(0.5,0.5)
								},
								content = ui.content (texText({currentHealth = actorName,widgetWidth=100*1,widgetHeight = 28*0.4, color = nameColor, size = NAME_SIZE}))
								--content = ui.content {{
								--		type = ui.TYPE.Image,
								--		props = {
								--			resource = background,
								--			tileH = false,
								--			tileV = false,
								--			relativeSize  = v2(1,1),
								--			alpha = 0.6,
								--		},
								--	},},
							}) or {},
								--items = {"nothing", "Stamina", "Mana", "Stamina + Mana"},
						}
					}),
					--{
					--	type = ui.TYPE.Image,
					--	props = {
					--		resource = background,
					--		tileH = false,
					--		tileV = false,
					--		--relativePosition= v2(0,0.5),
					--		position=v2(1,1),
					--		size = v2(-2,-2),
					--		relativeSize  = v2(0.999,0.999),
					--		alpha = 0.3,
					--	},
					--},
				}
			})
	else
		-- Update visibility if nameOnly state changed
		if c.cachedNameOnly ~= c.nameOnly then
			c.bar.layout.content[1].layout.content[1].layout.props.visible = not c.nameOnly
			c.bar.layout.content[1].layout.content[1]:update()
			c.bar.layout.content[1].layout.content[2].layout.props.visible = not c.nameOnly
			c.bar.layout.content[1].layout.content[2]:update()
			if RESOURCES_SETTING ~= "nothing" then
				c.bar.layout.content[1].layout.content[3].layout.props.visible = not c.nameOnly
				c.bar.layout.content[1].layout.content[3]:update()
			end
			if HP or HP_MAXHP then
				c.bar.layout.content[1].layout.content[4].layout.props.visible = not c.nameOnly and c.textVisible and playerLevel>=level + REQUIRED_HP
				c.bar.layout.content[1].layout.content[4]:update()
			end
			if BUFFS then
				c.bar.layout.content[1].layout.content[5].layout.props.visible = not c.nameOnly
				c.bar.layout.content[1].layout.content[5]:update()
			end
			if LEVEL ~= "hidden" and c.actor ~= self.object then
				c.bar.layout.content[1].layout.content[6].layout.props.visible = not c.nameOnly and not (hideLevelInsteadOfObscuring and playerLevel <level+REQUIRED_LEVEL)
				c.bar.layout.content[1].layout.content[6]:update()
			end
			c.cachedNameOnly = c.nameOnly
		end
		local updateResources = false
		if RESOURCES_SETTING ~="nothing" then
			if RESOURCES_SETTING == "Fatigue + Magicka" then
				if math.abs(fatigue-c.cachedFatigue) >1 or math.abs(magicka-c.cachedMagicka) >1 then
					c.bar.layout.content[1].layout.content[3].layout.content[1].props.relativeSize = v2(fatigue/maxFatigue,1)
					c.bar.layout.content[1].layout.content[3].layout.content[2].props.relativeSize = v2(magicka/maxMagicka,1)
					c.bar.layout.content[1].layout.content[3]:update()
					c.cachedMagicka = magicka
					c.cachedFatigue = fatigue
				end
			elseif RESOURCES_SETTING == "Fatigue" then
				if math.abs(fatigue-c.cachedFatigue) >1 then
					c.bar.layout.content[1].layout.content[3].layout.content[1].props.relativeSize = v2(fatigue/maxFatigue,1)
					c.bar.layout.content[1].layout.content[3]:update()
					c.cachedMagicka = magicka
					c.cachedFatigue = fatigue
				end
			elseif RESOURCES_SETTING == "Magicka" then
				if math.abs(magicka-c.cachedMagicka) >1 then
					c.bar.layout.content[1].layout.content[3].layout.content[1].props.relativeSize = v2(magicka/maxMagicka,1)
					c.bar.layout.content[1].layout.content[3]:update()
					c.cachedMagicka = magicka
					c.cachedFatigue = fatigue
				end
			end
		end
		if updateResources then
			c.bar.layout.content[1].layout.content[3].layout.content = ui.content(resourceTemplate)
			c.bar.layout.content[1].layout.content[3]:update()
			c.cachedMagicka = magicka
			c.cachedFatigue = fatigue
		end
		--c.bar.layout.content[1].layout.content[5].layout.content = ui.content (buffIcons(c.actor))
		local updateLevel = false
		local updateBorders = false
		local targetBorderAlpha = math.max(0.1,math.min(0.71,sizeMult/3))
		if (BORDER_STYLE=="thin" or BORDER_STYLE=="normal" or BORDER_STYLE=="thick" or BORDER_STYLE=="verythick") and math.abs(targetBorderAlpha-c.cachedBorderAlpha) >= 0.1 then
			updateBorders = true
			--print("-----------")
		end
		if (HP or HP_MAXHP) and (sizeMult>1 and math.floor(c.cachedHealth)~=math.floor(currentHealth) or (sizeMult>1 ~=c.textVisible)) then
			c.bar.layout.content[1].layout.content[4].layout.content = ui.content (texText({currentHealth = currentHealth,maxHealth = maxHealth,widgetWidth = 100*0.5, widgetHeight = 28*0.4, color = HP_TEXT_COL}))
			c.textVisible = sizeMult>1
			c.bar.layout.content[1].layout.content[4].layout.props.visible = not c.nameOnly and c.textVisible and playerLevel>=level + REQUIRED_HP
			c.bar.layout.content[1].layout.content[4]:update()
			--print("-----")
		end
		
		local updateBars = false
		if math.abs(c.cachedLerpHealth - c.lerpHealth)/maxHealth >= 1/(50 *sizeMult) then
			updateBars = true
			updateLevel = true
		end
		local updateName = false
		if c.reactionCache ~=reaction then
			--print(reaction,c.reactionCache)
			updateBars = true
			if BORDER_COLOR == "reaction" then
				updateBorders = true
			end
			if NAME and (NAME_BEHAVIOR == "reaction color" or NAME_BEHAVIOR == "hidden in combat") then
				updateName = true
			end
			updateLevel = true
		end
		if LAGBAR and math.abs(c.cachedHealthLag -c.healthLag) / maxHealth >= 1/(50 *sizeMult) then
			updateBars = true
		end
		if (HEALBAR or isAlly or not isAlly and c.cachedIncomingHealing > 0) and math.abs(c.cachedIncomingHealing - incomingHealing) / maxHealth >= 1/(50 *sizeMult) then
			updateBars = true
		end
		
		if updateLevel and LEVEL == "bar-color" then
			c.bar.layout.content[1].layout.content[6].layout.content = ui.content (texText({currentHealth = level,size = LEVELTEXT_SIZE,color = levelColor,widgetWidth = 100*0.1,widgetHeight = 28*0.25,align = LEVEL_POSITION ,obscured = playerLevel <level+REQUIRED_LEVEL}))
			c.bar.layout.content[1].layout.content[6]:update()
		end
		
		if updateBorders then
			if BORDER_COLOR == "reaction" then
				local borderColor = nil
				if aggro then
					borderColor = util.color.rgb(0.8,0.1,0.1)
				end
				local borderTemplate = (BORDER_STYLE == "thick" or BORDER_STYLE == "verythick") and makeBorder('thick',borderColor,borderOffset).borders or makeBorder('thin',borderColor,borderOffset).borders
				c.bar.layout.content[1].layout.content[1].layout.content[2].template = borderTemplate
				c.reactionCache = reaction
			end
			if BORDER_STYLE=="thin" or BORDER_STYLE=="normal" or BORDER_STYLE=="thick" or BORDER_STYLE=="verythick" then
				c.cachedBorderAlpha = math.floor(targetBorderAlpha*10)/10
				c.bar.layout.content[1].layout.content[1].layout.content[2].props.alpha = c.cachedBorderAlpha
			end
			c.bar.layout.content[1].layout.content[1]:update()
		end
		if updateName then
			local actorName = c.actor.recordId
			if reaction == "hostile" and NAME_BEHAVIOR == "hidden in combat" then
				actorName = "player"
			end
			local npcRecord = types.NPC.record(actorName)
			if npcRecord and actorName ~= "player" then
				actorName = npcRecord.name
			end
			local creatureRecord = types.Creature.record(actorName)
			if creatureRecord then
				actorName = creatureRecord.name
			end
			c.bar.layout.content[1].layout.content[7].layout.content =  ui.content (texText({currentHealth = actorName,widgetWidth=100*1,widgetHeight = 28*0.4, color = nameColor, size = NAME_SIZE}))
			c.bar.layout.content[1].layout.content[7]:update()
		end
		if updateBars then
			if math.abs(1-c.lerpHealth/maxHealth) <= 1/(50 *sizeMult) then
				c.bar.layout.content[1].layout.content[2].layout.content[2].props.relativeSize  = v2(1/2,1)
			else
				c.bar.layout.content[1].layout.content[2].layout.content[2].props.relativeSize  = v2(c.lerpHealth/maxHealth/2,1)
				--c.bar.layout.content[1].layout.content[2].layout.content[2].props.resource = ui.texture{ path = "textures\\hpbars\\"..template.path.."\\fill.dds", size = v2(c.lerpHealth/maxHealth*template.width,template.height)}
			end
			c.cachedLerpHealth = c.lerpHealth
			if COLOR_PRESET == "dynamic1" then
				c.bar.layout.content[1].layout.content[2].layout.content[2].props.color = HPBAR_COL
			end
			
			c.bar.layout.content[1].layout.content[2].layout.content[2].props.color = HPBAR_COL
			c.reactionCache = reaction
			if LAGBAR then
				if math.abs((c.healthLag-c.lerpHealth)/maxHealth) <= 1/(50 *sizeMult) then
					c.bar.layout.content[1].layout.content[2].layout.content[1].props.relativeSize  = v2(c.lerpHealth/maxHealth/2,1)
					c.cachedHealthLag = c.lerpHealth
				else
					c.bar.layout.content[1].layout.content[2].layout.content[1].props.relativeSize  = v2(c.healthLag/maxHealth/2,1)
					c.cachedHealthLag = c.healthLag
				end
			end
			
			if (HEALBAR or isAlly or not isAlly and c.cachedIncomingHealing > 0) then
				if not HEALBAR and not isAlly and c.cachedIncomingHealing > 0 then
					c.bar.layout.content[1].layout.content[2].layout.content[3].props.relativeSize  = v2(0,0)
					c.bar.layout.content[1].layout.content[2].layout.content[3].props.relativePosition = v2(0,0)
					c.cachedIncomingHealing = 0
				else
					if math.abs((incomingHealing+currentHealth-c.cachedLerpHealth)/maxHealth) <= 1/(50 *sizeMult) then
						c.bar.layout.content[1].layout.content[2].layout.content[3].props.relativeSize  = v2(0,1)
						c.cachedIncomingHealing = incomingHealing
					else
						c.bar.layout.content[1].layout.content[2].layout.content[3].props.relativeSize  = v2((incomingHealing+currentHealth-c.cachedLerpHealth)/maxHealth/2,1)
						c.bar.layout.content[1].layout.content[2].layout.content[3].props.relativePosition = v2(c.cachedLerpHealth/maxHealth/2,0)
						c.cachedIncomingHealing = incomingHealing
					end
				end
			end
			--print("---")
			c.bar.layout.content[1].layout.content[2]:update()
		end
	end
end

local function checkBuffs (actor, checkType)
	if checkType == "debuffs" then
		if not ALWAYS_CHECK_BUFFS then
			return false
		end
	end
	local isntPlayer = actor ~= self.object
	if not buffCache[actor.id] then
		buffCache[actor.id] = {
			buffs = {},
			debuffs = {},
			buffCount = 0,
			debuffCount = 0,
			lastUpdateFrame = frame-1,
			oldBuffChecksum = "",
			oldDebuffChecksum = "",
			buffCheckSum = "",
			debuffCheckSum = "",
		}
	end
	local bc = buffCache[actor.id]
	if bc.lastUpdateFrame <frame then
		bc.buffs = {}
		bc.debuffs = {}
		bc.buffCount = 0
		bc.debuffCount = 0
		bc.lastUpdateFrame = frame
		bc.buffCheckSum = ""
		bc.debuffCheckSum = ""
		
		for a,b in pairs(types.Actor.activeSpells(actor)) do
			for c,d in pairs(b.effects) do
				local duration = d.duration
				if (duration) then
					local buffId = d.id
					if not iconCache[buffId] then
						local icon = core.magic.effects.records[buffId].icon
						iconCache[buffId] =  ui.texture { path = hdTexPath(icon) }
					end
					if isntPlayer == ( b.caster ==actor) then
						table.insert(bc.buffs,{buffId,d.durationLeft/duration})
						bc.buffCount=bc.buffCount+1
						bc.buffCheckSum = bc.buffCheckSum..buffId..","
					else
						table.insert(bc.debuffs,{buffId,d.durationLeft/duration})
						bc.debuffCount=bc.debuffCount+1
						bc.debuffCheckSum = bc.debuffCheckSum..buffId..","
					end
				end
			end
		end
	end
	if checkType == "debuffs" then
		return bc.debuffCount>0
	elseif checkType == "checksum-last" then
		local ret = bc.oldDebuffChecksum ~= bc.debuffCheckSum or bc.oldBuffChecksum ~= bc.buffCheckSum
		bc.oldDebuffChecksum = bc.debuffCheckSum 
		bc.oldBuffChecksum = bc.buffCheckSum
		return ret
	end
	return true
end

local function rootViewpPosCheck(actorPos)


end

local function onFrame(dt)

	local HUDMBlacklist = types.Actor.activeEffects(self):getEffect("detectanimal").magnitude > 0 and I.HUDMarkers and I.HUDMarkers.version >= 3 and math.random() < 0.25 and {}
	
	frame = frame+1
	if computeBoundingBoxes then
		computeBoundingBoxes_tick()
	end
	--local heightDB = modData:getCopy("heightDB")
	for a,b in pairs(queueSettingsChange) do
		setSetting(b[1], b[2])
	end
	queueSettingsChange = {}
	local cameraPos = camera.getPosition()
	local playerPos = self.position
	local fastCheckPos = cameraPos --v3(cameraPos.x,cameraPos.y, playerPos.z)
	local now = core.getRealTime()
	local nowSim = core.getSimulationTime()
	local drainSpeed = LERPSPEED
	local timerLength = LAGDURATION
	local layerId = ui.layers.indexOf("HUD")
	local width = ui.layers[layerId].size.x 
	local screenres = ui.screenSize()
	local uiScale = screenres.x / width
	screenres= screenres:ediv(v2(uiScale,uiScale))
	local viewportToWorldVector = camera.viewportToWorldVector(v2(0.5, 0.5))
	local viewportLength = viewportToWorldVector:length()
	local isFirstPerson = camera.getMode() == camera.MODE.FirstPerson
	
	local actorOffset = ANCHOR == "head" and v3(0,0,100) or v3(0,0,0)
	
	-- fov calculation:
	local leftEdge = camera.viewportToWorldVector(util.vector2(0, 0.5))
	local halfFovDot = viewportToWorldVector:dot(leftEdge)
	local halfFovLength = viewportToWorldVector:length() * leftEdge:length()
	local halfFovCosine = halfFovDot / halfFovLength * (isFirstPerson and 0.95 or 0.9)
	
	local OWN_BAR = OWN_BAR
	local MAX_DISTANCE = MAX_DISTANCE
	local updateBars = {}
	--local usedThisFrame = {}
	local crosshairFilter = false
	if UNDER_CROSSHAIR == "Weapon readied = everyone" then
		if types.Actor.getStance(self) ~= types.Actor.STANCE.Nothing then
			crosshairFilter = true
		end
	elseif UNDER_CROSSHAIR == "Weapon readied" then
		if types.Actor.getStance(self) ~= types.Actor.STANCE.Nothing then
			local res = nearby.castRenderingRay(cameraPos, cameraPos+viewportToWorldVector:emul(v3(2000,2000,2000)))
			crosshairFilter = res.hitObject
		end
	elseif UNDER_CROSSHAIR == "always" then
		local res = nearby.castRenderingRay(cameraPos, cameraPos+viewportToWorldVector:emul(v3(2000,2000,2000)))
		crosshairFilter = res.hitObject
	end 
	for _,actor in pairs(nearby.actors) do
		--print(actor.id)
		local actorPos = actor.position
		local toObject = (actorPos + actorOffset) - fastCheckPos
		local dotProduct = viewportToWorldVector:dot(toObject)
		if dotProduct > 0 and (actor~=self.object or OWN_BAR and not isFirstPerson) then
			local toObjectLength = toObject:length()
			if toObjectLength < MAX_DISTANCE and (dotProduct / (viewportLength * toObjectLength) > halfFovCosine or toObjectLength <200) then
				--print(actor.type)
				
				local height = false
				local actorRecordId = actor.recordId
				local actorScale = actor.scale
				if not boxCache[actorRecordId] or math.random()<0.15 and dt > 0 then
					local npcRecord = types.NPC.record(actorRecordId)
					if npcRecord then-- and types.NPC.races.record(npcRecord.race).isBeast then -- somehow beasts have huge bounding boxes
						if not boxCache[actorRecordId] then
							if npcRecord.isMale then
								boxCache[actorRecordId] = {v3(0,0,types.NPC.races.record(npcRecord.race).height.male*67.5/actorScale),v3(0,0,types.NPC.races.record(npcRecord.race).height.male*67.5/actorScale)}
							else
								boxCache[actorRecordId] = {v3(0,0,types.NPC.races.record(npcRecord.race).height.female*67.5/actorScale),v3(0,0,types.NPC.races.record(npcRecord.race).height.female*67.5/actorScale)}
							end
						end
					else
						--print(actor:getBoundingBox().halfSize)
						local box = actor:getBoundingBox()
						local newCache = {box.center-actorPos:ediv(v3(actorScale,actorScale,actorScale)), box.halfSize:ediv(v3(actorScale,actorScale,actorScale)), 1}
						
						--print( actorRecordId,box.center,box.halfSize)
						if not boxCache[actorRecordId] then
							boxCache[actorRecordId] = newCache
						else
							local strength = 1/(boxCache[actorRecordId][3]+1)+0.01
							boxCache[actorRecordId] = {boxCache[actorRecordId][1]*(1-strength)+newCache[1]*strength, boxCache[actorRecordId][2]*(1-strength)+newCache[2]*strength, boxCache[actorRecordId][3]+1}
						end
						--print(box.center, box.halfSize)
						--print(boxCache[actorRecordId][1],boxCache[actorRecordId][2])
					end
					--print(actorRecordId, boxCache[actorRecordId])
				end
				
				--core.sendGlobalEvent("HPBars_VFX",actorPos-boxCache[actorRecordId][2])
				--local hugeness = math.log10(boxCache[actorRecordId][2].x*boxCache[actorRecordId][2].y*boxCache[actorRecordId][2].z)
				
				local barPos = actorPos
				local barOffset=v3(0,0,0)
				--print(actorRecordId)
				local model = types.Creature.objectIsInstance(actor) and types.Creature.records[actor.recordId].model:lower()
				if model then
					--box center:
					barOffset = (computedBoxes[model] and computedBoxes[model][1]:emul(v3(0,0,1)) or boxCache[actorRecordId][1]:emul(v3(0,0,1)))*actorScale
					--print(computedBoxes[model] and computedBoxes[model][1]:emul(v3(1,1,1)))
					if ANCHOR == "head" then
						--barOffset =  boxCache[actorRecordId][2]:emul(v3(0,0,actorScale))
						if customHeights[model] then
							barOffset = v3(barOffset.x, barOffset.y, customHeights[model]*actorScale)
						elseif computedBoxes[model] then
							barOffset = v3(0,0, barOffset.z + computedBoxes[model][2].z/2*actorScale)
						else
							barOffset = v3(0,0, barOffset.z + boxCache[actorRecordId][2].z*actorScale)
						end
					else
						if computedBoxes[model] then
							barOffset = v3(0,0, barOffset.z - computedBoxes[model][2].z/2*actorScale)
						else
							barOffset = v3(0,0, barOffset.z - boxCache[actorRecordId][2].z*actorScale)
						end
					end
				else
					if ANCHOR == "head" then --npcs are too predictable to use the engine's buggy bounding boxes as fallback already
						barOffset = boxCache[actorRecordId][1]+boxCache[actorRecordId][2]
					else
						barOffset = v3(0,0,0)
					end
				end
					--print(animation.getTextKeyTime(actor, "knockout: start"))
					--print(animation.getTextKeyTime(actor, "knockdown: loop start"))
					
					--print(animation.getCurrentTime(actor, "knockout"))
				local currentHealth = types.Actor.stats.dynamic.health(actor).current
				local isDead = types.Actor.isDead(actor)
				--local deathAnim = nil
				if animation.hasAnimation(actor) then
					if (animation.isPlaying(actor, "knockout") ) then
						local animStart = animation.getTextKeyTime(actor, "knockout: start")
						local animStop = animation.getTextKeyTime(actor, "knockout: stop")-animStart
						local animLoopStart = animation.getTextKeyTime(actor, "knockout: loop start")-animStart
						local animLoopStop = animation.getTextKeyTime(actor, "knockout: loop stop")-animStart
						local animCurrent = animation.getCurrentTime(actor, "knockout")-animStart
						if animCurrent <= animLoopStart then
							local animPct = ((animCurrent/animLoopStart)*1.25-0.25)^2
							barOffset = barOffset*(1-animPct) + barOffset/2*animPct
						elseif animCurrent >= animLoopStop then
							animCurrent = animCurrent - animLoopStop
							animStop = animStop - animLoopStop
							animStop = animStop *0.9
							animLoopStop = 0
							local animPct = math.min(1,((animCurrent/animStop)*1.2-0.2)^2)
							barOffset = barOffset/2*(1-animPct) + barOffset*animPct
						else
							barOffset = barOffset / 2
						end
						if barCache[actor.id] then
							barCache[actor.id].lastBarOffset = barOffset
						end
					elseif animation.isPlaying(actor, "knockdown") then
						local animStart = animation.getTextKeyTime(actor, "knockdown: start")
						local animStop = animation.getTextKeyTime(actor, "knockdown: stop")-animStart
						local animMiddle = animStop/2
						local animCurrent = animation.getCurrentTime(actor, "knockdown")-animStart
						if animCurrent <= animStop/4 then
							local animPct = math.min(1,((animCurrent/(animStop/4))*1.2-0.2)^2)
							barOffset = barOffset*(1-animPct) + barOffset*3/4*animPct
						elseif animCurrent >= animStop*3/4 then
							animCurrent = animCurrent - animStop*3/4
							local animPct = math.min(1,((animCurrent/(animStop/4))*1.2-0.2)^2)
							barOffset = barOffset*3/4*(1-animPct) + barOffset*animPct
						else
							barOffset = barOffset*3/4
						end
						if barCache[actor.id] then
							barCache[actor.id].lastBarOffset = barOffset
						end
					--elseif animation.isPlaying(actor, "deathknockout") then
					--	deathAnim = "deathknockout"
					--elseif animation.isPlaying(actor, "deathknockdown") then
					--	deathAnim = "deathknockdown"
					--elseif animation.isPlaying(actor, "death1") then
					--	deathAnim = "death1"
					--elseif animation.isPlaying(actor, "death2") then
					--	deathAnim = "death2"
					--elseif animation.isPlaying(actor, "death3") then
					--	deathAnim = "death3"
					--elseif animation.isPlaying(actor, "death4") then
					--	deathAnim = "death4"
					--elseif animation.isPlaying(actor, "death5") then
					--	deathAnim = "death5"
					end
				end
				--if (deathAnim or currentHealth <= 0) and barCache[actor.id] then
				if isDead and barCache[actor.id] then
					--local animStart = animation.getTextKeyTime(actor, deathAnim..": start")
					--local animStop = (animation.getTextKeyTime(actor, deathAnim..": stop")-animStart+3)/3
					--local animCurrent = animation.getCurrentTime(actor, deathAnim)-animStart
					--local animPct = ((animCurrent/animStop)*2)^2
					local animPct = (barCache[actor.id].deathTimer/0.75)^2
					barOffset = barCache[actor.id].lastBarOffset*(1-animPct) + barCache[actor.id].lastBarOffset*0.8*animPct
				end
				--print(barOffset)
				barPos =  barPos + barOffset
				local viewPos_XYZ = camera.worldToViewportVector(barPos)
				local rootViewPos_XYZ = camera.worldToViewportVector(actorPos)
				local viewpPos = v2(viewPos_XYZ.x/uiScale, viewPos_XYZ.y/uiScale)
				local rootViewpPos = v2(rootViewPos_XYZ.x/uiScale, rootViewPos_XYZ.y/uiScale)
				local v = viewportToWorldVector
				local u = (barPos - cameraPos):normalize()
				--print(v,u)
				--print(v*u)
				local angleInRadians = math.acos(v:dot(u) / math.max(0.0001,v * u))
				local stanceFilter = true
				if ONLY_IN_COMBAT and types.Actor.getStance(actor) == types.Actor.STANCE.Nothing and (not AI_DB[actor.id] or math.max(AI_DB[actor.id].Combat, AI_DB[actor.id].Pursue) < nowSim-1) then
					stanceFilter = false
				end
				
				local maxHealth = types.Actor.stats.dynamic.health(actor).base
				local yPosFactor = -(0.02)
				if toObjectLength < 200 then
					yPosFactor = yPosFactor - (200-toObjectLength)/400
				end
				if (not model or not modelBlacklist[model]) 
				and (barCache[actor.id] or not isDead)  
				--and viewPos_XYZ.z < MAX_DISTANCE +100
				and angleInRadians < math.pi/2 and viewpPos.x >= screenres.x*-0.1 
				and viewpPos.x <= screenres.x*1.1
				-- above screen
				and (viewpPos.y >= screenres.y*yPosFactor or toObjectLength < 400 and dotProduct / (viewportLength * toObjectLength) > 0.7)
				and viewpPos.y <= screenres.y*(ANCHOR == "head" and 1.02 or 1.4)
				and (stanceFilter 
					or (DAMAGED_ACTORS and currentHealth ~= maxHealth) 
					or checkBuffs (actor, "debuffs") 
					or crosshairFilter == true 
					or crosshairFilter == actor
					or ALWAYS_SHOW_NAME) then
					-- nameOnly: show only name when actor is visible solely due to ALWAYS_SHOW_NAME
					local nameOnly = ALWAYS_SHOW_NAME and NAME
						and not stanceFilter
						and not (DAMAGED_ACTORS and currentHealth ~= maxHealth)
						and not checkBuffs(actor, "debuffs")
						and crosshairFilter ~= true
						and crosshairFilter ~= actor
					--print(hugeness)
					
					if not raytracing[actor.id] then
						raytracing[actor.id] = {}
						raytracing[actor.id].lastHit = 0
						raytracing[actor.id].actor = actor
						raytracing[actor.id].failedHits = 0
					end
					raytracing[actor.id].healthPct = currentHealth/maxHealth
					raytracing[actor.id].lastHealthUpdate = now
					raytracing[actor.id].barPos = barPos
					raytracing[actor.id].actorPos = actorPos
					raytracing[actor.id].distance = viewPos_XYZ.z
					local rayCheck = true
					local raytracingAlphaMult = 1
					if RAYTRACING then
						if raytracing[actor.id].lastHit < now-1 then
							rayCheck = false
						elseif raytracing[actor.id].lastHit < now-0.05 then
							raytracingAlphaMult = 1-(now - raytracing[actor.id].lastHit)/1
						end
					end
					if rayCheck then
						--local hugeness1 = (boxCache[actorRecordId][2].x+boxCache[actorRecordId][2].y)
						--
						local hugeness2 = 0.85
						local hugeness3 = 0.85
						local hugeness = 0.85--model and customScales[model] and customScales[model]/100 or 1
						if model then
							local height = boxCache[actorRecordId][2].z*2
							if customHeights[model] then
								height = math.max(height,customHeights[model])
							end
							if computedBoxes[model] then
								height = math.max(height, computedBoxes[model][2].z)
							end
							height = height*actorScale
							if height < 110 then
								hugeness = 0.66 + height/323								
							else
								hugeness = 1 + 3*(1-0.7^((height-110)/215))
							end
						end
						if model then
							if computedBoxes[model] then
								hugeness2 = (computedBoxes[model][2].x*computedBoxes[model][2].y*computedBoxes[model][2].z)^0.333 / 90
								hugeness3 = (computedBoxes[model][2].x*computedBoxes[model][2].y)^0.333 / 90
							else
								hugeness2 = (boxCache[actorRecordId][2].x*boxCache[actorRecordId][2].y*boxCache[actorRecordId][2].z)^0.333 / 90
								hugeness3 = (boxCache[actorRecordId][2].x*boxCache[actorRecordId][2].y)^0.5 / 90
							end
						end
							
						hugeness = 0.3 + hugeness/4 + hugeness2/4 + hugeness3/4 + math.log10(maxHealth/10)/4
						if model then
							hugeness = hugeness + (customScales[model] or 0)
						end
						local offsetScale = 500/ viewPos_XYZ.z*SCALE
						if offsetScale >1 then
							offsetScale = 1 + 10.7*(1-0.75^((offsetScale-1)/3))
						end
						local sizeMult = offsetScale*hugeness*0.85
						local c = barCache[actor.id]
						if not c or c.lastRender < now-1 then
							if c and c.bar then
								c.bar:destroy()
							end
							c = {
								actor = actor,
								lastRender = now,
								healthPaused = currentHealth,
								healthTimer = 0,
								lerpHealth = currentHealth,
								healthLag = currentHealth,
								cachedHealth = currentHealth,
								cachedLerpHealth = currentHealth,
								cachedIncomingHealing = 0,
								cachedHealthLag = currentHealth,
								cachedBorderAlpha = 0.5,
								textVisible = sizeMult>1,
								deathTimer = 0,
								lastBuffUpdate = now,
								hasBuffs = true,
								cachedFatigue = types.Actor.stats.dynamic.fatigue(actor).current,
								cachedMagicka = types.Actor.stats.dynamic.magicka(actor).current,
								lastBarOffset = barOffset,
								nameOnly = nameOnly,
								cachedNameOnly = nameOnly,
							}
							if HUDMBlacklist then
								HUDMBlacklist[actor.id] = true
							end
							barCache[actor.id] = c
						else
							if dt == 0 then
								c.lastRender = now
							end
							c.healthPaused, c.healthLag, c.healthTimer, c.lerpHealth = ownlysLag(currentHealth, c.lerpHealth, c.cachedHealth, c.healthPaused, c.healthLag, c.healthTimer, now-c.lastRender, drainSpeed, timerLength, 0)
							c.lastRender = now
							c.nameOnly = nameOnly
							if HUDMBlacklist then
								HUDMBlacklist[actor.id] = true
							end
						end
						
						if c.deathTimer <0.75 then
							if isDead then
								c.deathTimer = c.deathTimer+dt
							end
							if stylizedBars[BORDER_STYLE] then
								updateStylized(c, currentHealth, maxHealth,sizeMult)
							else
								update(c, currentHealth, maxHealth,sizeMult)
							end
							viewpPos = v2(viewpPos.x+OFFSET_X*offsetScale,viewpPos.y+OFFSET_Y*offsetScale)
							if ANCHOR == "head" then
								if viewpPos.y < (28*sizeMult+2)*2/4  then
									viewpPos = v2(viewpPos.x,(28*sizeMult+2)*2/4)
								--	c.bar.layout.props.anchor = v2(0.5,0.25)
								--else
								--	c.bar.layout.props.anchor = v2(0.5,0.625)
								end
							else
								if viewpPos.y > screenres.y  then
									viewpPos = v2(viewpPos.x,screenres.y)
								end
							end
							c.bar.layout.props.position = viewpPos
							c.bar.layout.props.alpha = math.max(0,math.min(1, 1.1-(1.219^(c.deathTimer*5)-1) ))*raytracingAlphaMult
							c.bar.layout.props.size = v2(100*sizeMult+2,28*sizeMult+2)
							updateBars[sizeMult] = c.bar
							--c.bar:update()
							c.cachedHealth = currentHealth
						else
							if c.bar then
								c.bar:destroy()
							end
							barCache[actor.id] = nil
						end
					end
				end
			end
		end
	end
	if HUDMBlacklist then
		I.HUDMarkers.FHBarsBlacklist(HUDMBlacklist)
	end
	local sortBars = {}
	for a,b in pairs(updateBars) do
		table.insert(sortBars,a)
	end
	table.sort(sortBars)
	for a,b in pairs(sortBars) do
		updateBars[b]:update()
	end
	if RAYTRACING then
		rayCounter = 0
		for i=1,15 do
			if not raytracing[nextRay] then
				nextRay = nil
			end
			nextRay = next(raytracing,nextRay)
			if not raytracing[nextRay] or raytracing[nextRay].lastHealthUpdate < now or raytracing[nextRay].distance > MAX_DISTANCE then
				
			else
				rayCounter = rayCounter + 1
				--print("queuing "..raytracing[nextRay].actor.id)
				--print(camera.getPosition(), raytracing[nextRay].actorPos)
				--local rayTarget = (raytracing[nextRay].barPos-camera.getPosition()):normalize():emul(v3(MAX_DISTANCE))
				local rayTarget = nil
				local forward = (raytracing[nextRay].barPos-cameraPos):normalize()
				local up = v3(0,0,1)
				local right = forward:cross(up)
				--print("right",right)
				local actorId = nextRay
				if raytracing[actorId].failedHits %4 == 0 then
					rayTarget = raytracing[nextRay].barPos +right:emul(v3(20,20,20))
				elseif raytracing[actorId].failedHits %4 == 1 then
					rayTarget = raytracing[nextRay].barPos -right:emul(v3(20,20,20))
				elseif raytracing[actorId].failedHits %4 == 2 then
					rayTarget = (raytracing[nextRay].barPos + raytracing[nextRay].actorPos):ediv(v3(2,2,2))+right:emul(v3(20,20,20))
				elseif raytracing[actorId].failedHits %4 == 3 then
					rayTarget = (raytracing[nextRay].barPos + raytracing[nextRay].actorPos):ediv(v3(2,2,2))-right:emul(v3(20,20,20))
				end
				--vfx(rayTarget)
				local startPos = cameraPos
				nearby.asyncCastRenderingRay(
					async:callback(function(res)
						if not res.hit or res.hitObject and res.hitObject == raytracing[actorId].actor then
							raytracing[actorId].lastHit = now
							raytracing[actorId].failedHits = 0
						elseif (res.hitPos - startPos):length() < raytracing[actorId].distance-100 then
							raytracing[actorId].failedHits = raytracing[actorId].failedHits + 1
						else
							raytracing[actorId].lastHit = now
							raytracing[actorId].failedHits = 0
						end
					end), 
					cameraPos,rayTarget )
			end
			if rayCounter >= raysPerTick then
				break
			end
		end
			
		for a,b in pairs(raytracing) do
			if b.lastHealthUpdate < now or b.distance > MAX_DISTANCE then
				raytracing[a] = nil
			end
		end
	
	end
	
	if BUFFS then
		for i=1,10 do
			if not barCache[nextBuffUpdate] then
				nextBuffUpdate = nil
			end
			nextBuffUpdate = next(barCache,nextBuffUpdate)
			local c = barCache[nextBuffUpdate]
			if c and c.bar and (checkBuffs(c.actor, "checksum-last") or c.lastBuffUpdate < now-0.125) then
			--print(1)
				--local shortest= shortestBuff(c.actor)
				--if not shortest and c.hasBuffs or shortest and c.lastBuffUpdate < now-shortest/20 then
					updateBuffIcons(c)
					c.lastBuffUpdate = now
					--break
				--end
			end
		end
	end
	for a,b in pairs(barCache) do
		if b.lastRender < now and b.bar then
			b.bar:destroy()
			b.bar = nil
		end
	end
end


 
function AI_update(param)
	
	AI_DB[param.id] = AI_DB[param.id] or {Combat = 0, Follow = 0, Pursue = 0}
	if param.package == "Combat" then
		AI_DB[param.id].Combat = core.getSimulationTime()
	elseif param.package == "Follow" then
		AI_DB[param.id].Follow = core.getSimulationTime()
	elseif param.package == "Pursue" then
		AI_DB[param.id].Pursue = core.getSimulationTime()
	end
end




return {    
	engineHandlers = {
		onFrame = onFrame,
		onKeyPress = onKey
    },
	eventHandlers = {
        FHB_AI_update = AI_update,
    }
}