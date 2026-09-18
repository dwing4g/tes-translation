local oSelf = require("openmw.self")
local types = require("openmw.types")
local input = require("openmw.input")
local async = require("openmw.async")
local core = require("openmw.core")
local util = require("openmw.util")
local camera = require("openmw.camera")
local ui = require("openmw.ui")
local I = require("openmw.interfaces")
local storage = require("openmw.storage")
local nearby = require("openmw.nearby")
local l10n = core.l10n("DynamicActors")

local common = require("scripts.dynamicactors.common_player")
local Actor, MD = common.Actor, common.MD
local _settings = common.settings

local dialogModes = {
	[I.UI.MODE.Barter] = true,
	[I.UI.MODE.Companion] = true,
	[I.UI.MODE.Dialogue] = true,
	[I.UI.MODE.Enchanting] = true,
	[I.UI.MODE.MerchantRepair] = true,
	[I.UI.MODE.Travel] = true,
	[I.UI.MODE.Training] = true,
	[I.UI.MODE.SpellBuying] = true,
	[I.UI.MODE.SpellCreation] = true,
--	[I.UI.MODE.Persuasion] = true,
	dialog = I.UI.MODE.Dialogue,
}

local forceHudModes = {
	[I.UI.MODE.Alchemy] = true,
	[I.UI.MODE.Barter] = true,
	[I.UI.MODE.Container] = true,
	[I.UI.MODE.Companion] = true,
	[I.UI.MODE.Enchanting] = true,
	[I.UI.MODE.MerchantRepair] = true,
	[I.UI.MODE.Recharge] = true,
	[I.UI.MODE.Repair] = true,
	[I.UI.MODE.SpellBuying] = true,
	[I.UI.MODE.SpellCreation] = true,
	[I.UI.MODE.Training] = true,
}

local raceChangeModes = {
	[I.UI.MODE.ChargenRace] = true,
	[I.UI.MODE.ChargenClassReview] = true
}


--[[
dialogCam = { controls=false, block=false, instant=false, firstAuto=false,
	height=100, interval=2, counter=0, adjust=true, pos=nil }
local zoom1st = {enabled=false, dist=70, speed=1, offset=0, force=false, level=0, vector=nil}
local _camSave = {
	mode = camera.getMode(), offset = nil, offset1st = nil,
	offset3rd = camera.getFocalPreferredOffset(),
	extrayaw = 0
}
local poseOpt = {save = 1, choose = false, count = 0, offset3rd = camera.getFocalPreferredOffset()}

common.poseOpt=poseOpt,
common.zoom1st, common.dialogCam, common.camSave = zoom1st, dialogCam, _camSave
--]]

common.omw = { self=oSelf, input=input, core=core, types=types, util=util, camera=camera,
		ui=ui, interfaces=I, async=async, nearby=nearby }

local Anim = require("scripts.DynamicActors.playerAnimations")
local Dcam = require("scripts.DynamicActors.playerCamera")
local Dialog = require("scripts.DynamicActors.dialogue.player")
--	Anim.reloadConfig()		Dcam.reloadConfig()

local _V = { idle2sec = 2, idleCounter = 0 }
local _helmetStance = Actor.getStance(oSelf)
local _posing = false
local _actionKey = nil
local _dialogTarget

local _camSave = common.camSave
local _doUpdates = false
local _combatActors = {}


local L = {
	getActiveGroup = Anim.getActiveGroup,
	getStance = types.Actor.getStance,
	activeEffects = types.Actor.activeEffects(oSelf),
	controls = oSelf.controls
}

function _settings.update.camera(_, key)
	Dcam.dialog.firstAuto = _settings.camera:get("dialog_1stperson")
	Dcam.dialog.firstZoom = _settings.camera:get("dialog_1st_zoom")
--	_Dcam.zoom1st.zoomIn = _settings.camera:get("dialog_1st_zoom")
	Dcam.zoom1st.dist = _settings.camera:get("dialog_1st_zoomdist")
end

function _settings.update.player(_, key)
	_actionKey = _settings.player:get("actionHotkey")
	if key and key:find("^baseIdleAnim_") then
--		print("Update idle animation")
		Anim:cancelAllIdles()
		_V.idleCounter = 6
	end
end

function _settings.update.global()
	local pause = _settings.global:get("unpause_dialog_opt") == "opt_alwayspause"
	for m in pairs(dialogModes) do
		I.UI.setPauseOnMode(m, pause)
	end
	I.UI.setPauseOnMode("Dialogue", true)
	common.logging = _settings.global:get("debuglog")	
	Anim.visibleShields = _settings.global:get("visible_shields")
end

for k, v in pairs(_settings.update) do
	v()
	_settings[k]:subscribe(async:callback(v))
end


local _helm = { idle = nil, combat = nil }
do
	local id = _settings.player:get("autoHelmItemID")
	_helm.combat = id and Actor.inventory(oSelf):find(id)
	local id2 = _settings.player:get("autoHelmItemID2")
	if id2 == id1 then id2 = nil		end
	_helm.idle = id2 and Actor.inventory(oSelf):find(id2)
end


--	Precaution if game was saved during dialogue
I.UI.setHudVisibility(true)


local function procStanceChange(inCombat)
	if Anim.isPlaying(oSelf, "spellcast") then	return		end
	if Actor.isWerewolf(oSelf) or not _settings.player:get("autoHelm") then
		_helmetStance = Actor.getStance(oSelf)
		return
	end
	local equip, head = Actor.getEquipment(oSelf), Actor.Helmet
	local h = equip[head]
	if inCombat and _helm.combat then
		equip[head] = _helm.combat
		Actor.setEquipment(oSelf, equip)
		return
	end
	local store1, store2 = _settings.player:get("autoHelmItemID"), _settings.player:get("autoHelmItemID2")
	local id = h and h.recordId
	if Actor.getStance(oSelf) == Actor.stanceNothing then
		_helm.combat = h
		if id and store1 ~= id then
			_settings.player:set("autoHelmItemID", id)
		end
		equip[head] = _helm.idle
	elseif _helmetStance == Actor.stanceNothing then
		if h ~= _helm.combat then _helm.idle = h			end
		if id and id ~= store2 and id ~= store1 then
			_settings.player:set("autoHelmItemID2", id)
		end
		if _helm.combat then equip[head] = _helm.combat		end
	end
	Actor.setEquipment(oSelf, equip)
	_helmetStance = Actor.getStance(oSelf)
end


--	local isSneaking = L.controls.sneak
--	local statusChange = {}

local function updateStatus(s)
	local legs = Anim.getActiveGroup(oSelf, 0)
	s.stance = L.getStance(oSelf)
	s.stanceIsNothing = s.stance == Actor.stanceNothing
	s.sneak = L.controls.sneak
	s.legGroup = legs
	s.isMoving = Actor.getCurrentSpeed(oSelf) > 0
	s.isTurning = legs:find("^turn") or legs:find("^spellturn")
	s.running = s.isMoving and L.controls.run
	s.attack = L.controls.use > 0
	s.action = s.attack or legs:find("^jump")
end

local function stopPosing()
	I.Controls.overrideMovementControls(false)
	camera.allowCharacterDeferredRotation(true)
--	types.Player.setControlSwitch(oSelf, types.Player.CONTROL_SWITCH.Controls, true)
	ui.showMessage(l10n("msg_moveon"))
	Anim.pose.pending = false		Anim.posing = false
	if not _posing then		return			end

	Anim.pose:stop()
	camera.setFocalPreferredOffset(_camSave.offset3rd)
	_posing, Anim.posing = false, false
	if MD.getMode() ~= MD.Preview then		return		end

	if _camSave.mode == MD.FirstPerson then
		async:newUnsavableSimulationTimer(0.1, function() MD.setMode(MD.FirstPerson) end)
	else
		-- camera.lua expects ThirdPerson when in combat stance
		if Actor.getStance(oSelf) ~= Actor.stanceNothing then
			async:newUnsavableSimulationTimer(1, function()
				if MD.getMode() == MD.Preview then
					MD.setMode(MD.ThirdPerson)
				end
			end)
		end
		MD.setMode(_camSave.mode)
	end
end

--[[
local function updatePose()
	if not _posing then		return			end

	local offset = Anim.poses[Anim.pose.index].offset or _camSave.offset3rd.y
	Anim.poseOffset = Anim.poseOffset + util.vector2(0, offset - Anim.poseAnimOffset)
	Anim.poseAnimOffset = offset
	camera.setFocalPreferredOffset(Anim.poseOffset)

	if offset then
		Anim.poseOffset = util.vector2(camSave.offset3rd.x, offset)
		camera.setFocalPreferredOffset(Anim.poseOffset)
	else
	--	Anim.poses.offset3rd = _camSave.offset3rd
		Anim.poseOffset = camera.getFocalPreferredOffset()
	end

	Anim.pose:start(Anim.pose.index)
end
--]]

local function canPose()
	if core.isWorldPaused() then		return		end
	local block = I.UI.getMode()
--	local block = I.UI.getMode() or (MD.getMode() == MD.Static)
	if block then				return		end
	if Anim.notIdle or L.activeEffects:getEffect("levitate").magnitude > 0
		or Actor.isSwimming(oSelf) or Actor.isWerewolf(oSelf)
			then
		return
	end

	return true
end

local function startPosing()
	if not Anim.pose.pending or (MD.getMode() == MD.FirstPerson) then
		return
	end
	if not canPose() then		return			end

	_camSave.offset3rd = camera.getFocalPreferredOffset()
	I.Controls.overrideMovementControls(true)
	camera.allowCharacterDeferredRotation(false)
--	types.Player.setControlSwitch(oSelf, types.Player.CONTROL_SWITCH.Controls, false)
	ui.showMessage(l10n("msg_moveoff"))
	Anim.pose:setPlaylist(Actor.getStance(oSelf))
--	Anim.pose.index = Anim.poses.save
	Anim.poses.save = Anim.poses.save <= #Anim.poses and Anim.poses.save or 1
	Anim.pose.pending = false
	Dcam.distance = camera.getThirdPersonDistance()
	Anim.pose.offset = camera.getFocalPreferredOffset()
	Anim.pose.offset_y = Anim.pose.offset.y
	_posing, Anim.posing = true, true			_doUpdates = true
	Anim.posing = true
	Anim:cancelAllIdles()
	Anim.pose:start()
end

local function onKeyPress(key)
	if (key.code ~= _actionKey) then	return		end
	if not canPose() then			return		end

--	print("KEYPRESS")
	if _posing or Anim.pose.pending then
		stopPosing()
		return
	end

--	print("CANPLAY")
--	print("PENDING")

	Anim.pose.pending = true
	_camSave.mode = camera.getMode()
	Anim:cancelAllIdles()
--	if Anim.poses[Anim.poses.save].turn then
--		async:newUnsavableSimulationTimer(0.2, function() core.sendGlobalEvent("objTurn", {object=oSelf, angle=180}) end)
--	end
	async:newUnsavableSimulationTimer(0, function()		MD.setMode(MD.Preview)		end)
	async:newUnsavableSimulationTimer(0.5, startPosing)
end

input.registerTriggerHandler("Jump", async:callback(function()
	if _dialogTarget or not _posing then		return		end

	Anim.pose.choose = not Anim.pose.choose
	if Anim.pose.choose then
		ui.showMessage(l10n("msg_selecton"))
	else
		ui.showMessage(l10n("msg_selectoff"))
		local playing = Anim.pose.playing
		if playing ~= Anim.poses[Anim.poses.save] then
			Anim.pose:stop()
		--	Anim.handler("cancel", playing.id)
		--	Anim.pose.index = Anim.poses.save
			async:newUnsavableSimulationTimer(0.5, function() Anim.pose:start() end)
		end
	end
end))

local _status = common.status
_status.controls = types.Player.getControlSwitch(oSelf, types.Player.CONTROL_SWITCH.Controls)
updateStatus(_status)

local function slowUpdate()
	local dt = 1
	async:newUnsavableSimulationTimer(dt, slowUpdate)
	local s = _status

	s.inFirst = MD.getMode() == MD.FirstPerson
	s.skipIdles = L.activeEffects:getEffect("levitate").magnitude > 0
		or Actor.isSwimming(oSelf) or Actor.isWerewolf(oSelf)
		or not Actor.isOnGround(oSelf) or not Actor.canMove(oSelf)
	updateStatus(s)
	if s.weapon ~= Actor.getEquipment(oSelf, Actor.Weapon) then
		s.weapon = Actor.getEquipment(oSelf, Actor.Weapon)
		Anim.updateWeaponAnim(s)
	end
	if s.stance ~= _helmetStance then
		procStanceChange()
	end
--	if _posing and not Anim.handler("isPlay", Anim.pose.playing.id) then
--		stopPosing()
--	end
	if _dialogTarget and s.inFirst then
		Dcam.autoCamUpdate(dt)
	end

	Anim:updateStatus(s)
	local block = Anim.notIdle or s.inFirst or s.skipIdles
	if block and _posing then
	--	print("FORCE STOP POSING")
		stopPosing()
	end
	block = block or _posing or not s.controls
	if block then
		if Anim.playingIdle then
			_V.idleCounter = 0		Anim:cancelAllIdles()
		end
		return
	end

	if not(Anim.playingIdle or Anim.idle.mw[s.legGroup]) then
		return
	end

	Anim.idleController(s)
	Anim.tracked:update(dt)
	_V.idle2sec = _V.idle2sec - 1		if _V.idle2sec > 0 then		return		end
	_V.idle2sec = 2			dt = 2

	s.controls = types.Player.getControlSwitch(oSelf, types.Player.CONTROL_SWITCH.Controls)
	if not s.stanceIsNothing then
		return	
	end

	local idle = Anim.idle.nothing			local track = Anim.tracked
	if not Anim.playingIdle then
--	print("IDLE CONTROLLER STARTED")
		Anim.playingIdle = true
		_V.idleCounter = 12
		idle.num = 2
	--	local body = Anim.idle.base[Anim.settings[_settings.player:get("baseIdleAnim_main")]]
	--	local arms = Anim.idle.base[Anim.settings[_settings.player:get("baseIdleAnim_upper")]]
		local body = Anim.idle.base[_settings.player:get("baseIdleAnim_main")]
	 	local arms = Anim.idle.base[_settings.player:get("baseIdleAnim_upper")]
		idle.enabled = not(body.g == "none" and arms.g == "none")
		if idle.enabled then
			idle.Body.g, idle.Body.o.speed = body.g, body.speed
			idle.Arms.g, idle.Arms.o.speed = arms.g, arms.speed
			idle.Body.startDelay, idle.Arms.startDelay = 4, 5
			track:add(idle.Body)		track:add(idle.Arms)
		end
	end
	_V.idleCounter = _V.idleCounter + dt

 	if _V.idleCounter > 2 and _V.idleCounter < 28 then
		return
	end

 	if _V.idleCounter >= 28 then
		if _settings.player:get("rndIdleAnim") then
			track:add { g="removeAll", o=true, startDelay=1, event=true, noUpdate=true }
			_V.idleCounter = 0
		else
			_V.idleCounter = 4
		end
	end
	if _V.idleCounter ~= 2  then
		return
	end

	track:removeAll()

	local rnd = Anim.idle.rnd
--	if rnd.num > #rnd then rnd.num = 1		end
	local new = rnd[rnd.num]		local d = new.duration or 8
	if idle.enabled then
	--	track:add { g="removeAll", o=true, startDelay=d, event=true, noUpdate=true }
	--	idle.Body.startDelay, idle.Arms.startDelay = d + 1, d + 2
		idle.Body.startDelay, idle.Arms.startDelay = d, d + 1
		track:add(idle.Body)		track:add(idle.Arms)
	end
	local max = (new.start or idle.num > 1) and #new or 1
	for i=1, max do		track:add(new[i], d)	end
	rnd.num = 1 + (rnd.num < #rnd and rnd.num or 0)
	if idle.num == 1 then idle.num = 2		end

end

async:newUnsavableSimulationTimer(math.random() * 2, slowUpdate)

local function processCamera(dt)
	local mode, active = camera.getMode()
	if _dialogTarget then
		Dcam.dialogControls(dt, mode, Dcam.dialog)
		return
	end

	if _posing then
		if Actor.controls.movement == 0 and Actor.controls.sideMovement == 0
				and not I.UI.getMode() then
		--	if mode == MD.ThirdPerson and not _status.stanceIsNothing then
			if mode == MD.ThirdPerson or mode == MD.Vanity then
				MD.setMode(MD.Preview)
			end
			if mode == MD.Preview then
				Dcam.processControls(dt)
			end
		else
		--	print("MOVE UI STOP POSING")
			stopPosing()
		end
		return
	end

	if Dcam.zoom1st.zoomOut then
		Dcam.zoomOut1st(dt)
		return
	end

	_doUpdates = false
--	print("processCamera OFF")
end

local skipActorUpdate

I.AnimationController.addPlayBlendedAnimationHandler(function(g, o)
	if g:find("^idle") and _status.attack then
		return
	end
	_status.lastGroup = g
	_status.inFirst = MD.getMode() == MD.FirstPerson
	skipActorUpdate = false
end)


local function onUpdate(dt)
	if dt <= 0 then		return				end
	if _doUpdates then	processCamera(dt)		end

	if skipActorUpdate then		return			end

--	print("onUPDATE ACTOR UPDATE")
	skipActorUpdate = true		local s, a = _status, Anim
	updateStatus(s)			a:updateStatus(s)
	local block = a.notIdle or s.inFirst or s.skipIdles
	if block and _posing then
	--	print("ONUPDATE STOP POSING")
	--	print(a.notIdle, s.isMoving, s.isTurning, s.inFirst)
		stopPosing()
	end
	block = block or _posing or not s.controls
	if block and a.playingIdle then		a:cancelAllIdles()	end
end


input.registerTriggerHandler("dActors_pause", async:callback(function()
	if _dialogTarget then
		Dialog.manualPause = true
		core.sendGlobalEvent("dynForcePause")
	end
end))


local function uiModeChanged(data)
	if raceChangeModes[data.oldMode] then
		Anim.isBeast = types.NPC.races.records[types.NPC.records[oSelf.recordId].race].isBeast
	--	print("TRACK RACE MENU EVENT")
	end
	if data.newMode == dialogModes.dialog and not dialogModes[data.oldMode]
		and data.arg and _dialogTarget ~= data.arg then
		data.player = oSelf		data.near = oSelf.cell == data.arg.cell and data.arg.enabled
		for _, v in ipairs(nearby.actors) do
			if _combatActors[v.id] and not Actor.isDead(v) then
				data.pause = true
			end
		end
		if not data.pause then		_combatActors = {}		end
		Dialog.manualPause = false
		if data.arg ~= oSelf and Actor.isActor(data.arg) then
			I.UI.setPauseOnMode(dialogModes.dialog, true)
			if data.arg == Dialog.lastGreeting.actor then
				data.greeting = Dialog.lastGreeting
			end
			Dialog.lastGreeting = {}
			core.sendGlobalEvent("dynDialogOpened", data)
			_dialogTarget = data.arg			_doUpdates = true
			data.povPressed = input.getBooleanActionValue("dActors_togglepov")
				or input.getBooleanActionValue("TogglePOV")
			Dialog.hasOpened(data)
		end
	elseif _dialogTarget and dialogModes[data.newMode] then
	--	core.sendGlobalEvent("dynDialogChange", data)
		if Dialog.manualPause then
			I.UI.setPauseOnMode(data.newMode, true)
		end
		core.sendGlobalEvent("dynDialogChange", Dialog.manualPause)
	elseif data.newMode == nil and _dialogTarget then
		core.sendGlobalEvent("dynDialogClosed", data)
		_dialogTarget = nil
		Dialog.hasClosed(data)
		if Dialog.manualPause then		_settings.update.global()	end
	end
	if not _dialogTarget then	return		end
	if forceHudModes[data.newMode] then
		if not I.UI.isHudVisible() then I.UI.setHudVisibility(true)		end
	elseif _settings.camera:get("dialog_disableHud") and I.UI.isHudVisible() then
		if data.newMode then I.UI.setHudVisibility(false)			end
	end
end

async:newUnsavableSimulationTimer(0, function()
	Anim.reloadConfig()		Dcam.reloadConfig()
end)

return {
	engineHandlers = {
		onUpdate = onUpdate, onKeyPress = onKeyPress,
		onQuestUpdate = function(id, stage)
			if _dialogTarget then
				_dialogTarget:sendEvent("DynamicActors",
					{event="onQuestUpdate", questId=id, questStage=stage})
			end
		end,
		onConsoleCommand = function(_, c)
			c = c:lower()
			if not c:find("^lua dactors ") then	return		end
			c = c:sub(13, -1)
			if c ~= "reload" then			return		end

			ui.printToConsole("Dynamic Actors: Reloading config files", util.color.hex("ffffff"))
			core.sendGlobalEvent("DynamicActors", { event = "reloadConfig" })
			print("Reloading Dynamic Actors player config files.")
			stopPosing()
			Anim.reloadConfig()		Dcam.reloadConfig()
		end
	},
	eventHandlers = {
		UiModeChanged = uiModeChanged,
		DialogueResponse = Dialog.DialogueResponse,
		tes3InfoGetText = Dialog.tes3InfoGetText,
		dynUiMessage = function(e)	ui.showMessage(l10n(e))		end,
		dynUpdateDCam = function()	Dcam.autoCamUpdate(5)		end,
		OMWMusicCombatTargetsChanged = function(e)
			if not e.actor then		return		end
			local targetPlayer
		--	if not types.Actor.isDead(e.actor) then
			if e.targets and next(e.targets) ~= nil then
				for _, target in ipairs(e.targets) do
					if target == oSelf.object then
						targetPlayer = true
						break
					end
				end
			end
			_combatActors[e.actor.id] = targetPlayer
			local inCombat = next(_combatActors) ~= nil
			if _status.inCombat == inCombat then	return		end

		--	print("COMBAT STATUS CHANGE")
			_status.inCombat = inCombat		Anim:updateStatus(_status)
			if not inCombat then		return			end

			if _dialogTarget and not core.isWorldPaused() then
				core.sendGlobalEvent("dynForcePause")
			end
			local pos1, pos2 = e.actor.position, oSelf.object.position
			if (pos1 - pos2):length() < 2000 and math.abs(pos1.z - pos2.z) < 1000 then
				procStanceChange(true)
			end
		end
	},

	interfaceName = "DynamicActors",
	interface = {
		version = 137,
--[[
		updates = function()	return _doUpdates		end,
		c = common,
		dcam = Dcam,

		anim = Anim,
		dialog = Dialog,
		posing = function()	return _posing			end,
		combat = function()	return _combatActors		end
--]]
	}

}
