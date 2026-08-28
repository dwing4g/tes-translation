-- Script to loop play one of the standard idle animations during dialogue
-- Variable 'idleAnimation' is the groupname of the target idle
-- Variable 'idleAnimationSpeed' is the speed of the target idle
-- NOTE: Setting 'idleAnimation' to the groupname 'idle' won't work

local idleAnimation, loopStop
local idleAnimationSpeed = 1


local anim = require("openmw.animation")
local self = require("openmw.self")
local controls = self.controls
local skipUpdate = true
local frameTimer = 2

-- Function to play smooth transition out of 'idleAnimation' when dialogue is closed

local function closeDialog()
	if idleAnimation and anim.hasAnimation(self) and anim.isPlaying(self, idleAnimation) then
		local options = { priority=1, startPoint=anim.getCompletion(self, idleAnimation) }
		anim.cancel(self, idleAnimation)
		anim.playBlended(self, idleAnimation, options)
	end
end


-- Do checks to only start 'idleAnimation' when it's certain that it won't be overridden

local function onUpdate()
	if skipUpdate then
		return
	end
	if frameTimer > 0 then
		frameTimer = frameTimer - 1
		return
	end
	frameTimer = 2

	-- Don't start 'idleAnimation' if NPC is still turning
	if controls.yawChange ~= 0 then
		return
	end

	local start = anim.getCompletion(self, idleAnimation)
	local loops = anim.getLoopCount(self, idleAnimation) or 0
	if not start or (loops < 1 and start < loopStop) then
	--	print("OVERRIDE STARTED")
		local options = { priority=1, speed=idleAnimationSpeed, loops=1000, forceloop=true }
		if start and not started then
			options.startPoint = start
			anim.cancel(self, idleAnimation)
		end
		anim.playBlended(self, idleAnimation, options)
	end
end

local function onInit(e)
	if not anim.hasAnimation(self) or not e.group or not anim.hasGroup(self, e.group) then
		return
	end

	idleAnimation = e.group
	idleAnimationSpeed = e.speed or idleAnimationSpeed
	skipUpdate = false
	loopStop = anim.getTextKeyTime(self, idleAnimation .. ": stop") or 1
	loopStop = (anim.getTextKeyTime(self, idleAnimation .. ": loop stop") or loopStop) / loopStop
	loopStop = math.min(1, loopStop - 0.01)
end


return {
	onInit = onInit,
	onUpdate = onUpdate,
	closeDialog = closeDialog,
	baseIdle = { "", {}, 0},
	greeting = {},
}
