-- local anim = require("openmw.animation")
local self = require("openmw.self")
local types = require("openmw.types")
local time = require("openmw_aux.time")
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


-- local ST = types.Actor.STANCE
local Actor = {
	getCurrentSpeed = types.Actor.getCurrentSpeed,
	getStance = types.Actor.getStance,
	getEquipment = types.Actor.getEquipment,
	inventory = types.Actor.inventory,
	isActor = types.Actor.objectIsInstance,
	isSwimming = types.Actor.isSwimming,
	isDead = types.Actor.isDead,
	isWerewolf = types.NPC.isWerewolf,
	setEquipment = types.Actor.setEquipment,
	isOnGround = types.Actor.isOnGround,
	canMove = types.Actor.canMove,
	controls = self.controls,

	Helmet = types.Actor.EQUIPMENT_SLOT.Helmet,
	Shield = types.Actor.EQUIPMENT_SLOT.CarriedLeft,
	Weapon = types.Actor.EQUIPMENT_SLOT.CarriedRight,
	stanceNothing = types.Actor.STANCE.Nothing,
	stanceWeapon = types.Actor.STANCE.Weapon,
	stanceSpell = types.Actor.STANCE.Spell
}
local stance = Actor.getStance(self)		local v3 = util.vector3
local helmetStance = stance

local MD = {
	FirstPerson = camera.MODE.FirstPerson,
	ThirdPerson = camera.MODE.ThirdPerson,
	Preview = camera.MODE.Preview,
	Static = camera.MODE.Static,
	getMode = camera.getMode,
	setMode = camera.setMode
}


local settings = { names = {
	{ "camera", "Settings_dynactors_camera", "playerSection" },
	{ "player", "Settings_dynactors_player", "playerSection" },
	{ "global", "Settings_dynamicactors", "globalSection" }
	},
	storage = {},
	update = {}
}

for _, v in ipairs(settings.names) do
	settings[v[1]] = storage[v[3]](v[2])
	settings.storage[v[1]] = v[2]
end


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

local _posing = false
local V = { idle2sec = 2, idleCounter = 0 }

local actionKey = nil
local dialogTarget
dialogCam = { controls=false, block=false, instant=false, firstAuto=false,
	height=100, interval=2, counter=0, adjust=true, pos=nil }
local zoom1st = {enabled=false, dist=70, speed=1, offset=0, force=false, level=0, vector=nil}
local camsave = {
	mode = camera.getMode(), offset = nil, offset1st = nil,
	offset3rd = camera.getFocalPreferredOffset(),
	extrayaw = 0
}

common = {
--	poseOpt=poseOpt,
	zoom1st=zoom1st, dialogCam=dialogCam, camSave = camsave,
	MD=MD, Actor = Actor, settings = settings,
	omw = { self=self, input=input, core=core, types=types, util=util, camera=camera,
		ui=ui, interfaces=I, async=async, nearby=nearby }
}


local Anim = require("scripts.DynamicActors.playerAnimations")
Anim.isBeast = types.NPC.races.records[types.NPC.records[self.recordId].race].isBeast
common.anims = Anim		common.Anim = Anim
--	local poseOpt = {save = 1, choose = false, count = 0, offset3rd = camera.getFocalPreferredOffset()}

local Dcam = require("scripts.DynamicActors.playerCamera")
local heights = require("scripts.DynamicActors.configCamera")
heights.byRecord = require("scripts.DynamicActors.userConfig.Dialog NPC Camera positions")
Dcam.heights = heights
common.Dcam = Dcam		common.heights = heights

local dialog = require("scripts.DynamicActors.dialogue.player")

local doUpdates = false
local logging = false
local combatActors = {}


local L = {
	getActiveGroup = Anim.getActiveGroup,
	getStance = types.Actor.getStance,
	activeEffects = types.Actor.activeEffects(self),
	controls = self.controls
}

function settings.update.camera(_, key)
	dialogCam.firstAuto = settings.camera:get("dialog_1stperson")
	dialogCam.firstZoom = settings.camera:get("dialog_1st_zoom")
--	zoom1st.zoomIn = settings.camera:get("dialog_1st_zoom")
	zoom1st.dist = settings.camera:get("dialog_1st_zoomdist")
end

function settings.update.player(_, key)
	actionKey = settings.player:get("actionHotkey")
	if key and key:find("^baseIdleAnim_") then
--		print("Update idle animation")
		Anim:cancelAllIdles()
		V.idleCounter = 6
	end
end

function settings.update.global()
	local pause = settings.global:get("unpause_dialog_opt") == "opt_alwayspause"
	for m in pairs(dialogModes) do
		I.UI.setPauseOnMode(m, pause)
	end
	I.UI.setPauseOnMode("Dialogue", true)
	logging = dialog.set.logging(settings.global:get("debuglog"))	common.logging = logging
	Anim.visibleShields = settings.global:get("visible_shields")
end

for k, v in pairs(settings.update) do
	v()
	settings[k]:subscribe(async:callback(v))
end


local helm = { idle = nil, combat = nil }
do
	local id = settings.player:get("autoHelmItemID")
	helm.combat = id and Actor.inventory(self):find(id)
	local id2 = settings.player:get("autoHelmItemID2")
	if id2 == id1 then id2 = nil		end
	helm.idle = id2 and Actor.inventory(self):find(id2)
end


--	Precaution if game was saved during dialogue
I.UI.setHudVisibility(true)


local function stopPosing()
	I.Controls.overrideMovementControls(false)
	ui.showMessage(l10n("msg_moveon"))
	Anim.posePending = false		Anim.posing = false
	if not _posing then		return			end

	Anim.handler("cancel", Anim.poses[Anim.poseIndex].id)
	camera.setFocalPreferredOffset(camsave.offset3rd)
	_posing = dialog.set.posing(false)
	if camera.getMode() ~= MD.Preview then		return		end

	if camsave.mode == MD.FirstPerson then
		async:newUnsavableSimulationTimer(0.1, function() camera.setMode(MD.FirstPerson) end)
	else
		-- camera.lua expects ThirdPerson when in combat stance
		if Actor.getStance(self) ~= Actor.stanceNothing then
			async:newUnsavableSimulationTimer(1, function()
				if camera.getMode() == MD.Preview then
					camera.setMode(MD.ThirdPerson)
				end
			end)
		end
		camera.setMode(camsave.mode)
	end
end

local function procStanceChange(inCombat)
	if Anim.isPlaying(self, "spellcast") then	return		end
	if Actor.isWerewolf(self) or not settings.player:get("autoHelm") then
		helmetStance = Actor.getStance(self)
		return
	end
	local equip, head = Actor.getEquipment(self), Actor.Helmet
	local h = equip[head]
	if inCombat and helm.combat then
		equip[head] = helm.combat
		Actor.setEquipment(self, equip)
		return
	end
	local store1, store2 = settings.player:get("autoHelmItemID"), settings.player:get("autoHelmItemID2")
	local id = h and h.recordId
	if Actor.getStance(self) == Actor.stanceNothing then
		helm.combat = h
		if id and store1 ~= id then
			settings.player:set("autoHelmItemID", id)
		end
		equip[head] = helm.idle
	elseif helmetStance == Actor.stanceNothing then
		if h ~= helm.combat then helm.idle = h			end
		if id and id ~= store2 and id ~= store1 then
			settings.player:set("autoHelmItemID2", id)
		end
		if helm.combat then equip[head] = helm.combat		end
	end
	Actor.setEquipment(self, equip)
	helmetStance = Actor.getStance(self)
end


--	local isSneaking = L.controls.sneak
--	local statusChange = {}

local function updateStatus(s)
	local legs = Anim.getActiveGroup(self, 0)
	s.stance = L.getStance(self)
	s.stanceIsNothing = s.stance == Actor.stanceNothing
	s.sneak = L.controls.sneak
	s.legGroup = legs
	s.isMoving = Actor.getCurrentSpeed(self) > 0
	s.isTurning = legs:find("^turn") or legs:find("^spellturn")
	s.running = s.isMoving and L.controls.run
	s.attack = L.controls.use > 0
	s.action = s.attack or legs:find("^jump")
end

local Status = { legGroup="", lastGroup="" }
Status.controls = types.Player.getControlSwitch(self, types.Player.CONTROL_SWITCH.Controls)
updateStatus(Status)

time.runRepeatedly(function()
	local dt = 1		local s = Status

	s.inFirst = MD.getMode() == MD.FirstPerson
	s.skipIdles = L.activeEffects:getEffect("levitate").magnitude > 0
		or Actor.isSwimming(self) or Actor.isWerewolf(self)
		or not Actor.isOnGround(self) or not Actor.canMove(self)
	updateStatus(s)
	if s.weapon ~= Actor.getEquipment(self, Actor.Weapon) then
		s.weapon = Actor.getEquipment(self, Actor.Weapon)
		Anim.updateWeaponAnim(s)
	end
	if s.stance ~= helmetStance then
		procStanceChange()
	end
--	if _posing and not Anim.handler("isPlay", Anim.poses[Anim.poseIndex].id) then
--		stopPosing()
--	end
	if dialogTarget and s.inFirst then
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
			V.idleCounter = 0		Anim:cancelAllIdles()
		end
		return
	end

	if not(Anim.playingIdle or Anim.idle.mw[s.legGroup]) then
		return
	end

	Anim.idleController(s)
	Anim.tracked:update(dt)
	V.idle2sec = V.idle2sec - 1		if V.idle2sec > 0 then		return		end
	V.idle2sec = 2			dt = 2

	s.controls = types.Player.getControlSwitch(self, types.Player.CONTROL_SWITCH.Controls)
	if not s.stanceIsNothing then
		return	
	end

	local idle = Anim.idle.nothing			local track = Anim.tracked
	if not Anim.playingIdle then
--	print("IDLE CONTROLLER STARTED")
		Anim.playingIdle = true
		V.idleCounter = 12
		idle.num = 2
	--	local body = Anim.idle.base[Anim.settings[settings.player:get("baseIdleAnim_main")]]
	--	local arms = Anim.idle.base[Anim.settings[settings.player:get("baseIdleAnim_upper")]]
		local body = Anim.idle.base[settings.player:get("baseIdleAnim_main")]
	 	local arms = Anim.idle.base[settings.player:get("baseIdleAnim_upper")]
		idle.enabled = not(body.g == "none" and arms.g == "none")
		if idle.enabled then
			idle.Body.g, idle.Body.o.speed = body.g, body.speed
			idle.Arms.g, idle.Arms.o.speed = arms.g, arms.speed
			idle.Body.startDelay, idle.Arms.startDelay = 4, 5
			track:add(idle.Body)		track:add(idle.Arms)
		end
	end
	V.idleCounter = V.idleCounter + dt

 	if V.idleCounter > 2 and V.idleCounter < 28 then
		return
	end

 	if V.idleCounter >= 28 then
		if settings.player:get("rndIdleAnim") then
			track:add { g="removeAll", o=true, startDelay=1, event=true, noUpdate=true }
			V.idleCounter = 0
		else
			V.idleCounter = 4
		end
	end
	if V.idleCounter ~= 2  then
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

end, 1 * time.second)


local function updatePose()
	if not _posing then		return			end

	local offset = Anim.poses[Anim.poseIndex].offset
	if offset then
		Anim.poseOffset = util.vector2(camsave.offset3rd.x, offset)
		camera.setFocalPreferredOffset(Anim.poseOffset)
	else
	--	Anim.poses.offset3rd = camsave.offset3rd
		Anim.poseOffset = camera.getFocalPreferredOffset()
	end
	Anim.startPose(Anim.poseIndex)
end

local function startPosing()
--	camera.setMode(MD.Preview)
	if not Anim.posePending then		return		end

	Anim.posePending = false
	_posing = dialog.set.posing(true)			doUpdates = true
	Anim.posing = true
	Anim:cancelAllIdles()
	updatePose()
end

local function onKeyPress(key)
	if (key.code ~= actionKey) then		return		end
	if core.isWorldPaused() then		return		end
	local block = I.UI.getMode() or (MD.getMode() == MD.Static)
	if block then				return		end
--	print("KEYPRESS")
	if _posing or Anim.posePending then
		stopPosing()
		return
	end
--	if Anim.notIdle or Actor.getStance(self) ~= Actor.stanceNothing
	if Anim.notIdle or L.activeEffects:getEffect("levitate").magnitude > 0
		or Actor.isSwimming(self) or Actor.isWerewolf(self)
			then
		return
	end

--	print("CANPLAY")
--	print("PENDING")

	Anim.posePending = true
	camsave.mode, camsave.offset3rd = camera.getMode(), camera.getFocalPreferredOffset()
	I.Controls.overrideMovementControls(true)
	ui.showMessage(l10n("msg_moveoff"))
	Anim:cancelAllIdles()
	Anim.setPlaylist(Actor.getStance(self))
	Anim.poseIndex = Anim.poses.save
	Anim.poseIndex = Anim.poseIndex <= #Anim.poses and Anim.poseIndex or 1
	if Anim.poses[Anim.poseIndex].turn then
		async:newUnsavableSimulationTimer(0.2, function() core.sendGlobalEvent("objTurn", {object=self, angle=180}) end)
	end
	async:newUnsavableSimulationTimer(0, function()		MD.setMode(MD.Preview)		end)
	async:newUnsavableSimulationTimer(0.5, function()	startPosing()			end)
end

input.registerTriggerHandler("Jump", async:callback(function()
	if dialogTarget or not _posing then		return		end

	Anim.poses.choose = not Anim.poses.choose
	if Anim.poses.choose then
		ui.showMessage(l10n("msg_selecton"))
	else
		ui.showMessage(l10n("msg_selectoff"))
		if Anim.poseIndex ~= Anim.poses.save then
			Anim.handler("cancel", Anim.poses[Anim.poseIndex].id)
			Anim.poseIndex = Anim.poses.save
			async:newUnsavableSimulationTimer(0.5, updatePose)
		end
	end
end))


local function processCamera(dt)
	local mode, active = camera.getMode()
	if dialogTarget then
		Dcam.dialogControls(dt, mode, dialogCam)
		return
	end

	if _posing then
		if Actor.controls.movement == 0 and Actor.controls.sideMovement == 0 then
		--	if mode == MD.ThirdPerson and not Status.stanceIsNothing then
			if mode == MD.ThirdPerson then
				MD.setMode(MD.Preview)
			end
			if mode == MD.Preview then
				Dcam.processControls(dt)
			end
		else
			stopPosing()
		end
		return
	end

	if zoom1st.zoomOut then
		Dcam.zoomOut1st(dt)
		return
	end

	doUpdates = false
--	print("processCamera OFF")
end

local skipActorUpdate

I.AnimationController.addPlayBlendedAnimationHandler(function(g, o)
	if g:find("^idle") and Status.attack then
		return
	end
	Status.lastGroup = g
	Status.inFirst = MD.getMode() == MD.FirstPerson
	skipActorUpdate = false
end)


local function onUpdate(dt)
	if dt <= 0 then		return				end
	if doUpdates then	processCamera(dt)		end

	if skipActorUpdate then		return			end

--	print("onUPDATE ACTOR UPDATE")
	skipActorUpdate = true		local s, a = Status, Anim
	updateStatus(s)
--	local wasIdle = not a.notIdle
	a:updateStatus(s)
--	if a.notIdle and wasIdle then
--		print("SET NOTIDLE FLAG TRUE")
--	end
	if _posing and Anim.poses.doUpdate then
		Anim.poses.doUpdate = false
	end
	local block = a.notIdle or s.inFirst or s.skipIdles
	if block and _posing then		stopPosing()		end
	block = block or _posing or not s.controls
	if block and a.playingIdle then		a:cancelAllIdles()	end
end


input.registerTriggerHandler("dActors_pause", async:callback(function()
	if dialogTarget then
		dialog.manualPause = true
		core.sendGlobalEvent("dynForcePause")
	end
end))


local function uiModeChanged(data)
	if raceChangeModes[data.oldMode] then
		Anim.isBeast = types.NPC.races.records[types.NPC.records[self.recordId].race].isBeast
	--	print("TRACK RACE MENU EVENT")
	end
	if data.newMode == dialogModes.dialog and not dialogModes[data.oldMode]
		and data.arg and dialogTarget ~= data.arg then
		data.player = self		data.near = self.cell == data.arg.cell and data.arg.enabled
		for _, v in ipairs(nearby.actors) do
			if combatActors[v.id] and not Actor.isDead(v) then
				data.pause = true
			end
		end
		if not data.pause then		combatActors = {}		end
		dialog.manualPause = false
		if data.arg ~= self and Actor.isActor(data.arg) then
			I.UI.setPauseOnMode(dialogModes.dialog, true)
			if data.arg == dialog.lastGreeting.actor then
				data.greeting = dialog.lastGreeting
			end
			dialog.lastGreeting = {}
			core.sendGlobalEvent("dynDialogOpened", data)
			dialogTarget = data.arg			doUpdates = true
			data.povPressed = input.getBooleanActionValue("dActors_togglepov")
				or input.getBooleanActionValue("TogglePOV")
			dialog.hasOpened(data)
		end
	elseif dialogTarget and dialogModes[data.newMode] then
	--	core.sendGlobalEvent("dynDialogChange", data)
		if dialog.manualPause then
			I.UI.setPauseOnMode(data.newMode, true)
		end
		core.sendGlobalEvent("dynDialogChange", dialog.manualPause)
	elseif data.newMode == nil and dialogTarget then
		core.sendGlobalEvent("dynDialogClosed", data)
		dialogTarget = nil
		dialog.hasClosed(data)
		if dialog.manualPause then		settings.update.global()	end
	end
	if not dialogTarget then	return		end
	if forceHudModes[data.newMode] then
		if not I.UI.isHudVisible() then I.UI.setHudVisibility(true)		end
	elseif settings.camera:get("dialog_disableHud") and I.UI.isHudVisible() then
		if data.newMode then I.UI.setHudVisibility(false)			end
	end
end


return {
	engineHandlers = {
		onUpdate = onUpdate, onKeyPress = onKeyPress,
		onQuestUpdate = function(id, stage)
			if dialogTarget then
				dialogTarget:sendEvent("DynamicActors",
					{event="onQuestUpdate", questId=id, questStage=stage})
			end
		end,
		onConsoleCommand = function(_, c)
			if not c:find("^lua dactors") then		return		end
			c = c:sub(13, -1):lower()
			if c == "reload" then
				core.sendGlobalEvent("DynamicActors", { event = "reloadConfig" })
				ui.printToConsole("Dynamic Actors: Reloading config files", util.color.hex("ffffff"))
			end
		end
	},
	eventHandlers = {
		UiModeChanged = uiModeChanged,
		DialogueResponse = dialog.DialogueResponse,
		tes3InfoGetText = dialog.tes3InfoGetText,
		dynUiMessage = function(e)	ui.showMessage(l10n(e))		end,
		dynUpdateDCam = function()	Dcam.autoCamUpdate(5)		end,
		OMWMusicCombatTargetsChanged = function(e)
			if not e.actor then		return		end
			local targetPlayer
		--	if not types.Actor.isDead(e.actor) then
			if e.targets and next(e.targets) ~= nil then
				for _, target in ipairs(e.targets) do
					if target == self.object then
						targetPlayer = true
						break
					end
				end
			end
			combatActors[e.actor.id] = targetPlayer
			local inCombat = next(combatActors) ~= nil
			if Status.inCombat == inCombat then	return		end

		--	print("COMBAT STATUS CHANGE")
			Status.inCombat = inCombat		Anim:updateStatus(Status)
			if not inCombat then		return			end

			if dialogTarget and not core.isWorldPaused() then
				core.sendGlobalEvent("dynForcePause")
			end
			local pos1, pos2 = e.actor.position, self.object.position
			if (pos1 - pos2):length() < 2000 and math.abs(pos1.z - pos2.z) < 1000 then
				procStanceChange(true)
			end
		end
	},

	interfaceName = "DynamicActors",
	interface = {
		version = 136,
--[[
		c = function()		return common			end,
		help = function()	return dialog.omw50		end,
		updates = function()	return doUpdates		end,
		dcam = Dcam,

		dialog = function()	return dialog			end,
		posing = function()	return _posing			end,
		anim = function()	return Anim			end,
		combat = function()	return combatActors		end
--]]
	}

}
