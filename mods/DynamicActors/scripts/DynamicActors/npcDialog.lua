local core = require("openmw.core")
local anim = require("openmw.animation")
local self = require("openmw.self")
local util = require("openmw.util")
local types = require("openmw.types")
local ai = require("openmw.interfaces").AI
local I = require("openmw.interfaces")

if not self:isActive() then
	core.sendGlobalEvent("DynamicActors",
		{ event="removeScript", object=self, script="npcdialog.lua" })
	return
end

local _actor = {
	getStance = types.Actor.getStance,
	stanceNone = types.Actor.STANCE.Nothing,
	isNPC = types.NPC.objectIsInstance,
	isCreature = types.Creature.objectIsInstance,
	record = self.type.records[self.recordId],
	isSayActive = core.sound.isSayActive,
	getActiveGroup = anim.getActiveGroup,
	controls = self.controls,
}

local _config = require("openmw.storage").globalSection("dActors_tempStore"):getCopy("npcDialog")
local _filters = _config.filters
local _beastBlendMasks = _config.beastBlendMasks
local _armAnims = _config.armAnims

local _poseShiftType = 0
local _poseTable, infoList
local _idleAnim = { name=nil, opt={} }

interop = {}

local _dialogTarget = nil
local _turningEnabled, _visibleShield, _validAnim
local _animQueue = { timer = 10 }
local _override = {}

local _voice = _config.voice
local _isBeast, _isGuard

if _actor.isNPC(self) then
	local npcRace = _actor.record.race
	_isBeast = types.NPC.races.records[npcRace].isBeast
	_isGuard = _actor.record.class == "guard"
	if npcRace == "wood elf" then
		_voice.options.speed = 1.5
	end
-- print(_isBeast, npcRace)
	if _isBeast then
		_voice.groups = _config.voice_beast
		_voice.options.blendMask = 3		_voice.options.priority = { [0]=3, [1]=3 }
		_voice.baseAnim = ""	_voice.baseBone = anim.BONE_GROUP.RightArm
	elseif not _actor.record.isMale and anim.hasGroup(self, "idlespeak_idlef") then
		_voice.groups = _config.voice_f
	end

end


local function addHandlers(m)
	local skipFn = function() end
	for _, v in ipairs
		{ "onUpdate", "closeDialog", "DialogueResponse", "onQuestUpdate", "onInfoGetText", "onInit" }
			do
		m[v] = m[v] or skipFn
	end
end

local _plugin = {}		addHandlers(_plugin)
local _logLevel = 0

local function debug(m, l)
	if _logLevel >= (l or 1) then		print(m)		end
end

local function playHandler(g, o)
	if not _validAnim or _actor.getStance(self) ~= _actor.stanceNone then
		return
	end

	o.blendMask = o.blendMask or 15
	local mask = _visibleShield and 11
	mask = mask or ((anim.isPlaying(self, "idlestorm") or anim.isPlaying(self, "torch")) and 11)
	if mask then
		mask = util.bitAnd(o.blendMask, mask)
		g = (not _armAnims[g]) and g or "armsakimbo"
	end
	if _isBeast then
		if g:find("_copy$") then g = g:gsub("_copy$", "")	end
		mask = util.bitAnd(mask or o.blendMask, _beastBlendMasks[g] or 15)
--		print(g, mask, o.blendMask)
	end
	if mask == 0 then		return			end

	if anim.isPlaying(self, g) then
		if not g:find("^arms") then
			o.startPoint = anim.getCompletion(self, g)
		end
		anim.cancel(self, g)
	end
	local savedMask = o.blendMask		o.blendMask = mask or o.blendMask
	anim.playBlended(self, g, o)
	o.startPoint = nil			o.blendMask = savedMask
end

local _idleGroups = _config.idleGroups

local function hasValidAnim()
	local leg = _actor.getActiveGroup(self, 0)
	leg = leg:match("[^_]+") or leg
	local valid = _idleGroups[leg] or leg:find("^turn") or leg:find("^walk") or leg:find("^run")
		or leg:find("^arms")
--	if not valid then	print("NOT VALID ANIM", leg)		end
	return valid
end

local function shiftPose(e)
--	if _voice.playing or _poseShiftType == 0 then	return		end
	if _poseShiftType == 0 or not _validAnim then
		return
	end
	if e == "playBase" then
		if _idleAnim.name and _idleAnim.opt.loops > 50 then playHandler(_idleAnim.name, _idleAnim.opt) end
		return
	end
	if _idleAnim.name then anim.cancel(self, _idleAnim.name) end
	local newPose = _poseTable[math.random(#_poseTable)]
--	local name, options = table.unpack(newPose[1])
--	playHandler(name, options)
	_animQueue.play = newPose[1]
	_animQueue.time = core.getSimulationTime() + (_animQueue.play.delay or 0)
	playHandler(newPose[2].id, newPose[2].opt)
end

_filters.evals = {
	faction = function(o) return next(types.NPC.getFactions(o)) end
}

local function checkFilters(t)
	if not _actor.isNPC(self) then		return		end
	for i=1, #t do
		local k, v, name, options, shift = table.unpack(t[i])
		local m = false
		local eval = _filters.evals[k]
		if eval then
			_, eval = eval(self)
		else
			eval = _actor.record[k]
		end
		if type(eval) == type(v) then
			if type(v) == "string" and string.find(eval:lower(), v) then m = true
			elseif eval == v then m = true end
		end
		if m then return name, options, shift		end
	end
end

local function forcePause()
	local aipack, pause = ai.getActivePackage(), false
	if aipack == nil then		return pause		end
--	if _isGuard and aipack.type == "Unknown" and aipack.target == nil then force=true end
	local t = aipack.type
	if t == "Combat" or t == "Pursue" or t == "Flee" then
		pause = true
	end
	if pause then core.sendGlobalEvent("dynForcePause")		end
	return pause
end

local function initNPCdiag(data)
	if forcePause() or not anim.hasAnimation(self) then
		return
	end

	local idleSet, path, logging
	_dialogTarget, idleSet, path = data.player, data.idleLevel, data.plugin
	_logLevel = data.logging and 1 or _logLevel
	_turningEnabled = data.isMobile
	interop = {self=self, player=_dialogTarget, lookAt=_dialogTarget}
	local aipack = ai.getActivePackage()
	if aipack and data.canTurn then
		if (aipack.type == "Wander" and aipack.distance and aipack.distance > 0)
			or (aipack.type == "Travel" and aipack.destPosition) then
			_turningEnabled = true
		end
	end
	if data.groups then
		for _, v in ipairs(data.groups) do
			if v == "all" or anim.isPlaying(self, v) then
				debug(("Found blocked anim group %s"):format(v))
				idleSet = 0		_turningEnabled = false
				break
			end
		end
	end

--	local bipedal = self.type == types.NPC or _actor.record.isBiped
--	print(_actor.record.type, types.Creature.TYPE.Humanoid)
--	if _actor.record.type == types.Creature.TYPE.Humanoid then bipedal = true	end
--	if not bipedal then return end

	local var = interop
	if path then
		_plugin = require(path) or {}
		if _plugin.infoList then
			infoList = {}
			for k, v in pairs(_plugin.infoList) do
				infoList[k:lower()] = v
			end
		end
		addHandlers(_plugin)		_plugin.onInit(data.pluginData)
		if _plugin.getVariableStore then _plugin.getVariableStore(var) end
	end
	if data.greeting then
		data.greeting.event = "DialogueResponse"
		self:sendEvent("DynamicActors", data.greeting)
	end

	if idleSet == 0 or (_actor.isCreature(self) and not path) then
		_poseShiftType = 0
		return
	end

	_visibleShield = (data.shields or not anim.hasBone(self, "Bip01 AttachShield"))
		and types.Actor.getEquipment(self, types.Actor.EQUIPMENT_SLOT.CarriedLeft)

	local static = true
	if aipack ~= nil then
		debug(("%s %s %s %s"):format(self, aipack.destPosition, aipack.target, aipack.type))
		if aipack.destPosition ~= util.vector3(0,0,0) then static = false end
	else
		debug("No AI package")
	end
	core.sendGlobalEvent("actorMonitor", { actor=self, reset=static })

	_validAnim = hasValidAnim()
	if not _validAnim then
		debug("Unknown animation playing. Blocking initial idle.")
	end

	local name, options, shift
	if _plugin.baseIdle then
		name, options, shift = table.unpack(_plugin.baseIdle)
	end
	if not name then
		name, options, shift = checkFilters(_filters.baseIdle)
	end
	if name then
		_poseShiftType = shift or 1
		if not _isBeast then
			_idleAnim.name, _idleAnim.opt = name, options
			playHandler(name, options)
		end
	end

	if _plugin.greeting then
		name, options, shift = table.unpack(_plugin.greeting)
	else
		name, options, shift = checkFilters(_filters.greeting)
	end
	if type(name) == "table" then
		local rnd = math.random(#name)
		name, options = table.unpack(name[rnd])
	end

	if name then
		_poseShiftType = shift or 1
		playHandler(name, options)
	end
	if idleSet < 3 then _poseShiftType = 0		end
	if _poseShiftType > 0 then _poseTable = _filters.poseShifts[_poseShiftType]		end
	if idleSet > 0 and anim.hasGroup(self, "idlespeak") then
		_voice.disabled = false
	end

end

local function cancelOverride()
	if _override.prop then
		anim.removeVfx(self, _override.prop.options.vfxId)
		_override.prop = nil
	end
end

local function closeNPCdiag()
	if anim.hasAnimation(self) then
		if _voice.playing then
			anim.cancel(self, _voice.playing)
		end
		if _idleAnim.name then
			anim.setLoopingEnabled(self, _idleAnim.name, false)
		end
		if _override.groupName then
			anim.cancel(self, _override.groupName)
		end
		cancelOverride()
	end
	core.sendGlobalEvent("DynamicActors",
		{ event="removeScript", object = self, script = "npcDialog.lua" })
	_plugin.closeDialog(_dialogTarget)
	_dialogTarget = nil
	_poseShiftType = 0
end

local bodyParts = _config.bodyParts

local function getBodyPart(mask)
	return type(mask) == "string" and bodyParts[mask:lower()] or 15
end

local events = {}

function events.DialogueResponse(e)
	_plugin.onInfoGetText { info = { id = e.infoId } }
	_plugin.DialogueResponse(e)
	if not infoList then 		return		end
	local m = infoList[e.infoId] or infoList[e.recordId or ""]
	m = type(m) == "function" and { FN=m } or m
	if type(m) ~= "table" then	return		end
	if m.pause then
		core.sendGlobalEvent("DynamicActors", { event="Pause" })
		return
	end

	local name, o
	if type(m.FN) == "function" then
		local f = m.FN(e)
		if f == false then		return		end
		if type(f) == "table" then
			name, o = f.groupName, f.options
		end
	end

	name = name or m.name or m.groupName
	if type(name) ~= "string" then		return		end
	name = name:lower()		local mask = m.bodypart
	o = type(o) == "table" and o or m.options or {}
	o.blendMask = o.blendMask or getBodyPart(mask)
	o.priority = o.priority or 4
	debug(("Play plugin anim %s %s"):format(name, mask))
	playHandler(name, o)
end

function events.onInfoGetText(e)
--	_plugin.onInfoGetText(e)
	events.DialogueResponse { infoId = e.info.id }
end

function events.Override(e)
	cancelOverride()
	if e.prop then
		local prop = e.prop
		local t = core.getSimulationTime()
		prop.start = prop.start + t		prop.stop = prop.stop + t
		_override.prop = prop
	end
	if e.groupName then
		I.AnimationController.playBlendedAnimation(e.groupName, e.options)
		_override.groupName = e.groupName
		_dialogTarget:sendEvent("dynUpdateDCam")
	end
end

function events.onQuestUpdate(e)
	debug(("Quest %s %s"):format(e.questId, e.questStage))
	_plugin.onQuestUpdate(e.questId, e.questStage)
end


local function onUpdate(dt)
	if dt <= 0 then					return		end
	if (not _dialogTarget) or forcePause() then	return		end
	_validAnim = hasValidAnim()
	local turningToTarget = false
	if _turningEnabled and _validAnim then
		local deltaPos = _dialogTarget.position - self.position
		local targetYaw = math.atan2(deltaPos.x, deltaPos.y)
		local deltaYaw = util.normalizeAngle(targetYaw - self.rotation:getYaw())
	--	local deltaYaw = (targetYaw - self.rotation:getYaw())
	--	deltaYaw = deltaYaw > math.pi and (deltaYaw - 2 * math.pi) or deltaYaw
	--	deltaYaw = (deltaYaw + math.pi) % (2 * math.pi) - math.pi
		local direction = deltaYaw > 0 and 1 or -1		deltaYaw = math.abs(deltaYaw)
		if deltaYaw > math.rad(20) then
			turningToTarget = true
		--	local bezier = (4 * deltaYaw / 3.1) ^ 2
			local v = ((deltaYaw * 1.3) ^ 2) * math.pi / 2
			v = util.clamp(v, math.rad(40), 4)
			v = v * dt
			_actor.controls.yawChange = direction * math.min(deltaYaw, v)
		end
	end
	if not turningToTarget then
		_actor.controls.yawChange = 0
	end
	_actor.controls.movement = 0
	_actor.controls.sideMovement = 0

	if _override.prop then
		local t = core.getSimulationTime()
		local prop = _override.prop
		if prop.start and prop.start <= t then
			anim.addVfx(self, prop.model, prop.options)
			prop.start = nil
		elseif prop.stop <= t then
			cancelOverride()
		end
	end

	if not _validAnim then
		if _voice.playing then
			anim.cancel(self, _voice.playing)
			_voice.playing = nil
		end
		return
	end

	_plugin.onUpdate(dt)
	if _animQueue.time and _animQueue.time < core.getSimulationTime() then
		playHandler(_animQueue.play.id, _animQueue.play.opt)
		_animQueue.time = nil
	end
	_animQueue.timer = _animQueue.timer - dt
	if _animQueue.timer < 0 then
		_animQueue.timer = 35
	--	shiftPose()
	end

	if _voice.disabled or _actor.getStance(self) ~= _actor.stanceNone then
		if _voice.playing then
			anim.cancel(self, _voice.playing)
			_voice.playing = nil
		end
		return
	end
	if _voice.playing and not _actor.isSayActive(self) then
		anim.cancel(self, _voice.playing)
		_voice.playing = nil
	elseif _voice.playing and _actor.getActiveGroup(self, _voice.baseBone) ~= _voice.baseAnim then
		_voice.baseAnim = _actor.getActiveGroup(self, _voice.baseBone)
		local newIdle = _voice.groups[_voice.baseAnim] or _voice.groups.base
		debug(("%s %s"):format(_voice.playing, newIdle))
		if newIdle == "" then
			anim.cancel(self, _voice.playing)
			_voice.playing = nil
		elseif _voice.playing ~= newIdle then
			_voice.options.startPoint = anim.getCompletion(self, _voice.playing)
			anim.cancel(self, _voice.playing)
			anim.playBlended(self, newIdle, _voice.options)
			_voice.playing = newIdle
		end
	elseif not _voice.playing and _actor.isSayActive(self) then
		_voice.baseAnim = _actor.getActiveGroup(self, _voice.baseBone)
		local g = _voice.groups[_voice.baseAnim] or _voice.groups.base
		if g ~= "" then
			debug(g)
			_voice.options.startPoint = 0
			anim.playBlended(self, g, _voice.options)
			_voice.playing = g
		end
	end
end


return {
	engineHandlers = { onUpdate = onUpdate },
	eventHandlers = {
		initNPCdiag = initNPCdiag,
		closeNPCdiag = closeNPCdiag,
		shiftPose = shiftPose,
		dynInfoEvent = events.onInfoGetText,
		DynamicActors = function(e)
			if e.event and events[e.event] then events[e.event](e)		end
		end
	},
}
