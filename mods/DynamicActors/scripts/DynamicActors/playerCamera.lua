local common = common
local self = common.omw.self
local input = common.omw.input
local core = common.omw.core
local types = common.omw.types
local util = common.omw.util
local camera = common.omw.camera
local ui = common.omw.ui
local I = common.omw.interfaces
local async = require("openmw.async")

local Anim = common.Anim
local MD = common.MD

local M = {}

function M.processControls(dt, inDialog)
	local p = Anim.poses

	local yaw, pitch, dist, moved = camera.getYaw(), camera.getPitch(), camera.getThirdPersonDistance()
	local move_x = input.getMouseMoveX() + input.getAxisValue(input.CONTROLLER_AXIS.LookLeftRight) * 10
	local move_y = input.getMouseMoveY() + input.getAxisValue(input.CONTROLLER_AXIS.LookUpDown) * 10
--	local move_x = input.getNumberActionValue("LookLeftRight")
--	local move_y = input.getNumberActionValue("LookUpDown")
	local zoom = input.getNumberActionValue("Zoom3rdPerson")
	camera.showCrosshair(true)
	if inDialog then
		if move_x ~= 0 or move_y ~= 0 then
			moved = true
			yaw = yaw + 0.5 * move_x * dt
			pitch = pitch + 0.5 * move_y * dt
		end
		if zoom ~= 0 then
			moved = true
			dist = dist - zoom
		end
	end

	-- avoid triggering camera.lua autoswitch to 1st person
	dist = math.max(36, dist)

	move_x = input.getRangeActionValue("MoveForward") - input.getRangeActionValue("MoveBackward")
	move_y = input.getRangeActionValue("MoveRight") - input.getRangeActionValue("MoveLeft")
	if p.choose then p.count = p.count - dt end
	if p.choose and math.abs(move_y) > 0.7 and p.count < 1 then
		p.count = 1.25
		local new = p.save + (move_y > 0 and 1 or -1)
		if new > #Anim.poses then new = 1		end
		if new < 1 then new = #Anim.poses		end
		p.save = new
		ui.showMessage(Anim.poses[new].name.." ("..Anim.poses[new].id..")")
	end
	if (move_x ~= 0 or move_y ~= 0) and not p.choose then
		moved = true
		Anim.poseOffset = Anim.poseOffset + util.vector2(100 * move_y * dt, 100 * move_x * dt)
	end
	if not moved then		return		end

	camera.setFocalPreferredOffset(Anim.poseOffset)
	camera.setPreferredThirdPersonDistance(dist)
	camera.instantTransition()
	camera.setYaw(yaw)
	camera.setPitch(pitch)
end


local FullBlackBG = {
	type = ui.TYPE.Image,
	props = {
		resource = ui.texture { path = 'white' },
		color = util.color.rgb(0, 0, 0),
	},
}
	
local blackBars = ui.create {
	layer = "FadeToBlack",
	props = {
		relativeSize = util.vector2(1, 1),
		visible = false
	},
	content = ui.content {
		{
			template = FullBlackBG,
			props = {
				relativeSize = util.vector2(1, 0.1),
			},
		},
		{
			template = FullBlackBG,
			props = {
				relativePosition = util.vector2(0, 1),
				relativeSize = util.vector2(1, 0.1),
				anchor = util.vector2(0, 1),
			},
		},
	},
}

local Bars = {
	screenRatio = 1.8,
	size = 0,
	props = blackBars.layout.props,
	propsB1 = blackBars.layout.content[1].props,
	propsB2 = blackBars.layout.content[2].props,
}

local function setBarsRatio(ratio)
	local vec = util.vector2(1, (1 - Bars.screenRatio / (ratio or Bars.screenRatio)) / 2)
	Bars.propsB1.relativeSize = vec
	Bars.propsB2.relativeSize = vec
	blackBars:update()
end

M.bars = {
	ratio = setBarsRatio,
	enable = function(m)
		Bars.props.visible = m
		blackBars:update()
	end,
	element = function()	return blackBars		end,
}

function M.enableShaders(m)
	Bars.screenRatio = ui.screenSize().x / ui.screenSize().y
	local targetRatio = math.max(common.dialogCam.barsRatio, Bars.screenRatio)
	Bars.size = (1 - Bars.screenRatio / targetRatio) / 2
	if Bars.size < 0.01 then
		Bars.size = nil
	end
	if m and Bars.size then
		Bars.props.visible = true
	else
		Bars.props.visible = false
		blackBars:update()
	--	print("BLACK BARS OFF")
	end

	if not I.DynamicCamera or not I.DynamicCamera.shaders then	return		end
	local shaders = common.dialogCam.shaders
	if m and not shaders then
		common.dialogCam.shaders = {
			dof = I.DynamicCamera.shaders["hexDoFProgrammable"].u,
			bars = I.DynamicCamera.shaders["blackBarsProgrammable"].u
		}
	elseif not m and shaders then
		shaders.dof.uAperture = 0
		shaders.bars.ratio = 0
	end
end

function M.autoCam(dt)
	local z = common.zoom1st
	local d = common.dialogCam
	local ctrls = self.controls

	-- Force-set 1st person zoom every frame, to counter camera.lua resetting it
	local lerp
	if z.vector then
		camera.setFirstPersonOffset(z.vector["0xy"] * (1 - (z.level - 1) ^ 6))
	end
	if z.extraYaw ~= 0 then
		camera.setExtraYaw(z.extraYaw)
	end
	ctrls.movement = 0
	ctrls.sideMovement = 0
	local turningToTarget = false

	local deltaPos = d.vecEyeToHead
	local destVec = deltaPos.xy:rotate(camera.getYaw())
	local deltaYaw = math.atan2(destVec.x, destVec.y)
--	local deltaYaw = math.atan2(destVec.x, destVec.y) + z.extraYaw
	if math.abs(deltaYaw) > math.rad(10) then
		turningToTarget = true
	end
	lerp = math.min((8 * math.abs(deltaYaw) / math.pi) ^ 2 + 0.03, 1.3)
	local v = dt * 3.5 * lerp
	if d.instant then
		v = math.min(math.abs(deltaYaw), 0.75)
		d.instant = false
	end
	if math.abs(deltaYaw) > math.rad(0.1) then
		ctrls.yawChange = util.clamp(deltaYaw, -v, v)
	end

	local lengthXY = deltaPos.xy:length() - d.radius
	local deltaPitch = - math.atan2(deltaPos.z, math.max(lengthXY, d.radius))
		- self.rotation:getPitch()
	if math.abs(deltaPitch) > math.rad(10) then
		turningToTarget = true
	end
	lerp = (8 * math.abs(deltaPitch) / math.pi) ^ 2 + 0.001
	v = dt * 3.5 * lerp
	if math.abs(deltaPitch) > math.rad(1) then
		ctrls.pitchChange = util.clamp(deltaPitch, -v, v)
	end

	if turningToTarget or z.delay > 0 then
		z.delay = z.delay - dt
		return
	end
--	if z.offset ~= 0 and z.level > 0.2 then
	if z.offset ~= 0 then
		if z.extraYaw ~= z.offset then
			local yaw = z.offset - z.extraYaw
		--	v = dt * 3.5 * math.min((6 * math.abs(yaw) / math.pi) ^ 2 + 0.03, 0.1)
			v = dt * 3.5 * math.min((6 * yaw / math.pi) ^ 2 + 0.03, 0.3 * math.abs(z.offset))
			z.extraYaw = z.extraYaw + util.clamp(yaw, -v, v)
		end
	end
	if z.level >= 1 or not(z.zoomIn or z.offset ~= 0 or d.aperture > 0 or Bars.size) then
		return
	end

        z.level = z.level + (dt * z.speed)
	z.level = math.min(1, z.level)
--	if z.level >= 1 then		print("ZOOM IN DONE")		z.level = 1	end
	destVec = util.vector2(lengthXY, deltaPos.z)
	local distance = (destVec:length() - d.radius) * z.scale
	if z.zoomIn then
	--	if not z. vector then
	-- print(d.deltaPos:length(), distance, destVec:length(), math.max(distance - 300, z.dist))
	--	end
	--	d.dDist = distance		d.destVec = destVec		d.lxy = lengthXY
		z.vector = destVec:normalize() * util.clamp(distance - z.dist, -5, 300)
	end
	if d.aperture > 0 and z.level > 0.4 then
		lerp = math.min(z.level - 0.4, 0.2) / 0.2
		local dof = d.shaders.dof
		local depth = z.zoomIn and z.dist or distance
		dof.uDepth = d.radius / 3 + math.max(distance - 300, depth)
		dof.uAperture = d.aperture * lerp
	end
	if Bars.size and z.level > 0.2 then
		lerp = math.min(z.level - 0.2, 0.4) / 0.4
	--	d.shaders.bars.ratio = 1.8 + math.max(d.barsRatio - 1.8, 0) * lerp
		local barSize = util.vector2(1, Bars.size * lerp)
		Bars.propsB1.relativeSize = barSize
		Bars.propsB2.relativeSize = barSize
		blackBars:update()
	end
end

function M.autoCamUpdate(dt)
	local d = common.dialogCam
	d.counter = d.counter - dt	if d.counter > 0 then	return		end
	d.counter = d.interval

	local npc = d.target
	if d.adjust then
	--	d.pos = npc.position
		d.deltaPos = npc.position - self.position
	end
	if not Anim.hasAnimation(npc) then		return			end

	local isPlaying = Anim.getActiveGroup(npc, 0)
	local keys, focal = d.animKeys
	if keys then
		for _, v in ipairs(keys) do 
			if isPlaying == v then
				focal = d.headPosAnim
			end
		end
		if not focal then
			focal = keys[Anim.getActiveGroup(npc, 0)] or keys.default
			focal = focal and d.npcSizeRatios:apply(focal) * npc.scale
		end
		if common.logging then print(isPlaying, focal)		end
	end

	if not focal and not types.NPC.objectIsInstance(npc) then
		focal = d.vecFocalDefault
	end

	if not focal then
		local group = M.heights.byGroup[isPlaying]
		if not group and (isPlaying:find("^idle") or isPlaying:find("^turn")) then
			group = M.heights.byGroup.idle
		end
		if group then
			focal = d.npcSizeRatios:apply(group.focal) * npc.scale
			if common.logging then
				print("USE LOOKUP FOR", isPlaying)
			end
		end
	end

	if focal then
		focal = util.transform.rotateZ(npc.rotation:getYaw()):apply(focal)
	elseif d.lastPlaying == isPlaying and dt > 0 and d.lastFocal then
		focal = d.lastFocal
	else
		-- use bounding box to guess focal point
		if common.logging then print("USE BOX FOR", isPlaying)		end
		local box = npc:getBoundingBox()
		focal = (box.center - npc.position)
		focal = focal.xy0 + util.vector3(0, 0, (math.abs(focal.z) + box.halfSize.z) * 0.85)
	end

--	focal = d.lastPlaying == isPlaying and dt > 0 and d.lastFocal or focal
	d.lastPlaying = isPlaying		d.lastFocal = focal

	d.vecEyeToHead = d.deltaPos + focal - d.playerEyesVec
end

_controlsTimer = 0.25

function M.dialogControls(dt, mode, d)
	if mode == MD.FirstPerson then
		if d.isActive then		M.autoCam(dt)		end
		return
	end

	if d.controls then		MD.setMode(MD.Preview)		end
	local toggle = input.getBooleanActionValue("dActors_togglepov")
		or input.getBooleanActionValue("TogglePOV")
	if not toggle then	_controlsTimer = 0.25		return		end
	if _controlsTimer > 0 then
		_controlsTimer = _controlsTimer - dt
		return
	end
	
	if not d.controls then
		d.controls = true
	--	ui.showMessage("CAMERA CONTROLS")
	end
	M.processControls(dt, true)
end

function M.restoreCamera()
	local saved, mode = common.camSave, camera.getMode()
	local controls = common.dialogCam.controls

	if mode == MD.Preview and saved.mode == mode
		and types.Actor.getStance(self) == types.Actor.STANCE.Nothing then
			return
	end
	if saved.mode == MD.Preview and not Anim.posing then
		saved.mode = MD.ThirdPerson
	end


--	print("Reset previous camera mode and view")
	-- directly switching 1stPerson-->Preview using setMode will glitch
	if mode == MD.FirstPerson and saved.mode == MD.Preview then
		saved.mode = MD.ThirdPerson
	end

	if controls and mode ~= MD.FirstPerson and saved.mode ~= MD.FirstPerson then
	--	ui.showMessage("CAMERA RESET")
		camera.setYaw(saved.yaw)
		camera.setPitch(saved.pitch)
	--	camera.instantTransition()
		camera.setPreferredThirdPersonDistance(saved.dist3rd)
	end
	camera.setMode(saved.mode)
end

function M.zoomOut1st(dt)
	local z = common.zoom1st	local cam = common.dialogCam
	local inFirst = camera.getMode() == MD.FirstPerson
	local lerp

	if inFirst then
		if z.vector then
			camera.setFirstPersonOffset(z.vector["0xy"] * z.level ^ 4)
		end
		if z.extraYaw ~= 0 then
			local yaw = 0 - z.extraYaw
			local v = dt * 3.5 * math.min((8 * math.abs(yaw) / math.pi) ^ 2 + 0.03, 2)
			z.extraYaw = z.extraYaw + util.clamp(yaw, -v, v)
			camera.setExtraYaw(z.extraYaw)
		end

		if cam.aperture > 0 and z.zoomIn and z.level > 0.5 then
			lerp = util.clamp(z.level - 0.6, 0, 0.4) / 0.4
			local dof = cam.shaders.dof
			dof.uDepth = z.dist	dof.uAperture = cam.aperture * lerp
		end

		if Bars.size then
			lerp = util.remap(z.level, 0.5, 1, 0, 1)
		--	setBarsRatio(1.8 + math.max(cam.barsRatio - 1.8, 0) * lerp)
			local barSize = util.vector2(1, Bars.size * lerp)
			Bars.propsB1.relativeSize = barSize
			Bars.propsB2.relativeSize = barSize
			blackBars:update()
		end

	end
	z.level = math.max(z.level - (dt * z.speed), 0)

	local floor = common.camSave.mode == MD.FirstPerson and 0.2 or 0.5
	if inFirst and (z.extraYaw ~= 0 or (z.vector and z.level > floor)) then
		return
	end

--	print("Reset zoom and first person")
	camera.setFirstPersonOffset(common.camSave.offset1st)
	if z.offset ~= 0 then
		camera.setExtraYaw(0)
	end
	z.level, z.vector = 0		z.zoomOut = false
	M.enableShaders(false)
	if inFirst then		M.restoreCamera()		end
end


return M
