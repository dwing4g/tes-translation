local anim = require("openmw.animation")
local oSelf = common.omw.self
local types = common.omw.types
local async = common.omw.async
local util = common.omw.util

local Actor, MD = common.Actor, common.MD

local Anim = {
	cancel = anim.cancel,
	isPlaying = anim.isPlaying,
	getActiveGroup = anim.getActiveGroup,
	hasAnimation = anim.hasAnimation
}

local L = {
	p1 = anim.PRIORITY.WeaponLowerBody,
	p2 = 2,
	p3 = 3,
	p5 = anim.PRIORITY.Movement,
	lower_b = anim.BONE_GROUP.LowerBody,
	torso_b = anim.BONE_GROUP.Torso,
	legs = 1, torso = 2, body = 3, arms = 12, arm_r = 8, bodyArms = 15, bodyArm_r = 11
}

L.arms_p1 = { [anim.BONE_GROUP.LeftArm] = L.p1, [anim.BONE_GROUP.RightArm] = L.p1 }
L.arms_p2 = { [anim.BONE_GROUP.LeftArm] = L.p2, [anim.BONE_GROUP.RightArm] = L.p2 }

Anim.tracked = { n=0, timer=0 }
Anim.idle = {
	mw = {
		idle=true, idlespell=true, idle1h=true, idle2c=true, idle2w=true, idlehh=true,
		idle1s=true, idle1b=true, idle2b=true, idlebow=true, idlecrossbow=true, idlethrowweapon=true,
		readypose=true, handhippose=true
	},
	base = { {g="none", speed=1, name="None" },
		{g="handhippose", speed=0.5, name="Hand on Hip contrapose" },
		{g="readypose", speed=0.5, name="Ready Pose" },
		{g="idle2", speed=0.7, name="Idle2" },
		{g="armsfolded", speed=0.5, name="Arms Folded" },
		{g="armsatback", speed=0.5, name="Arms Back Clasp" },
		{g="armsakimbo", speed=0.5, name="anim_akimbo" },
	},
	nothing = {
		Body = { g="", o={loops=900, priority=1, speed=1} },
		Arms = { g="", o={loops=900, priority=2, speed=1, blendMask=12} }
	},
	rnd = { num = 1,
		{	dialog=true, duration=8,
			{ g="armsfolded", o={loops=2, priority=L.p1, blendMask=L.arms} },
			{ g="idle8", o={loops=1, speed=2, priority=L.p2} }
		},
		{	start=true, dialog=true, duration=13,
			{ g="idle9", o={speed=2/3, priority=L.p1, blendMask=L.body}, startDelay=1 },
			{ g="idle7", o={priority=L.arms_p1, blendMask=L.arms} },
			{ g="armsfolded", o={loops=1, priority=L.arms_p1, blendMask=L.arms}, startDelay=7 },
		},
		{	dialog=true, duration=8,
			{ g="armsakimbo", o={loops=2, priority=L.p1, blendMask=L.arms} },
			{ g="idle4", o={speed=2, priority=L.p2} }
		},
--[[
		{	start=true, dialog=true, duration=13,
			{ g="idle9", o={speed=2/3, priority=L.p1, blendMask=L.body}, startDelay=1 },
			{ g="idle7", o={priority=L.arms_p1, blendMask=L.arms} },
			{ g="armsfolded", o={loops=1, priority=L.arms_p1, blendMask=L.arms}, startDelay=7 },
		},
		{	start=true, dialog=true, duration=9,
			{ g="armsakimbo", o={loops=2, priority=L.arms_p1, blendMask=L.arm_r} },
		--	{ g="idle9", o={speed=2/3, priority=L.p1, blendMask=L.body} }
			{ g="idle9", o={speed=1, priority=L.p1, blendMask=L.body} }
		},
		{	dialog=true, duration=8,
			{ g="armsfolded", o={loops=2, priority=L.p1, blendMask=L.arms} },
			{ g="idle8", o={loops=1, speed=2, priority=L.p2} }
		},
		{	dialog=true, duration=8,
			{ g="armsakimbo", o={loops=2, priority=L.p1, blendMask=L.arms} },
			{ g="idle4", o={speed=2, priority=L.p2} }
		},
		{	start=true, dialog=true, duration=12,
			{ g="armsfolded", o={loops=2, priority=L.arms_p2, blendMask=L.arms} },
			{ g="idle9", o={speed=2/3, priority=L.p2, blendMask=L.body} }
		},
--]]
	},
	dialog = {},
	weapon = {
		body = { g = "readypose", o = {speed=2/3, blendMask=L.body, priority=1, loops=1000} },
		weapon = { g = "armsweapon",
			o = { speed=2/3, blendMask=L.arms, priority=L.arms_p1, loops=1000 } },
		weaponSwitch = { g = "armsweapon_switch", noUpdate = true,
			o = { speed=2/3, blendMask=L.arms, priority=L.arms_p2, loops=1 } },
	},
	switchArms = function()		anim.cancel(oSelf, "armsweapon_switch")		end
}

for _, v in ipairs(Anim.idle.rnd) do
	if v.dialog then
		table.insert(Anim.idle.dialog, v)
	end
end

for k, v in ipairs(Anim.idle.base) do
	Anim.idle.base[v.name] = v
end


Anim.combo = { armsStrPose = { "handhippose", {mask=L.body} },
	armsFoldPose = { "handhippose", {mask=L.body}, "armsfolded", {mask=L.arms, spd=1} },
	armsOneBackPose = { "handhippose", {mask=3}, "armsatback", {mask=L.arm_r, spd=1} },
	armsBackClaspPose = { "handhippose", {mask=3}, "armsatback", {mask=L.arms, spd=1} },
	armsFoldedOrAkimbo = { "armsakimbo", {}, "armsfolded", {mask=L.arms, spd=1} },
}

Anim.clear = {}		Anim.FN = {}
Anim.clear.idle = { "handhippose", "readypose", "armsfolded", "armsakimbo", "armsatback", "posealma3",
	"idle2", "idle4", "idle7", "idle8", "idle9" }
Anim.clear.idleWpn = { "readypose", "armsweapon" }
Anim.poses = require("scripts.DynamicActors.userConfig.PoseMode Playlist")

Anim.idleGroups = { idle=true }
for _, v in ipairs(Anim.poses) do		Anim.idleGroups[v.id] = true		end
for _, v in ipairs(Anim.clear.idle) do		Anim.idleGroups[v] = true		end
for _, v in ipairs(Anim.clear.idleWpn) do	Anim.idleGroups[v] = true		end


Anim.beastBlendMasks = {
--	handhippose = 0, armsakimbo = L.arms,
--	readypose = 0,
	armsfolded = L.arms, armsatback = L.arms, armssunshield = L.arms_r,
	armsfoldpose = L.arms, armsstrpose = L.arms, armsonebackpose = L.arms,
	armsbackclasppose = L.arms,
	armsalmapray = L.arms, posealma3 = 0, idle2_copy = 0, idle7_copy = L.arms, idle8_copy = L.arms
}


local function playHandler(g, o)
	o.blendMask = o.blendMask or L.bodyArms
	local shield = MD.getMode() ~= MD.FirstPerson
		and (Anim.visibleShields or not anim.hasBone(oSelf, "Bip01 AttachShield"))
		and Actor.getEquipment(oSelf, Actor.Shield)
	local mask = shield and L.bodyArm_r
	mask = mask or ((anim.isPlaying(oSelf, "idlestorm") or anim.isPlaying(oSelf, "torch")) and L.bodyArm_r)
	if mask then
		mask = util.bitAnd(o.blendMask, mask)
		if g == "armsfolded" then
			g = "armsakimbo"
		elseif g == "posealma3" then
			mask = util.bitAnd(mask, L.body)
		end
	end

	if Anim.isBeast then
		mask = util.bitAnd(Anim.beastBlendMasks[g] or L.bodyArms, mask or o.blendMask)
	end
	if mask == 0 then		return			end

	if anim.isPlaying(oSelf, g) then
		if not g:find("^arms") then
			o.startPoint = anim.getCompletion(oSelf, g)
		end
		anim.cancel(oSelf, g)
	end
	local savedMask = o.blendMask		o.blendMask = mask or o.blendMask
	anim.playBlended(oSelf, g, o)
	o.startPoint = nil			o.blendMask = savedMask
end

function Anim.handler(a, g, o)
	local mask = 15
--[[
	if Anim.isBeast then
		if g:find("_copy$") then g = g:gsub("_copy$", "")	end
		local v = Anim.beastBlendMasks[g:lower()]
		if v and a == "play" then
			o = o or {}	mask = v or L.arms
			o.blendMask = o.blendMask or mask
			o.blendMask = util.bitAnd(v, mask)
		end
	end
--]]
	if Anim.isBeast and g:find("_copy$") then
		g = g:gsub("_copy$", "")
	end

	local combo = Anim.combo[g]
	local play = true
	if g == "none" then return true end
	if a == "isPlay" and not combo then
		return anim.isPlaying(oSelf, g)
	end
	if not combo then
		if a == "play" then playHandler(g, o)	else	anim.cancel(oSelf, g)	end
		return
	end
	if a == "isPlay" then
--[[
		if g == "armsFoldPose" and not anim.isPlaying(oSelf, "armsfolded") then
			play = false
		end
		if ( g == "armsBackClaspPose" or g == "armsOneBackPose" )
			and not anim.isPlaying(oSelf, "armsatback") then
			play = false
		end
--]]
		if not anim.isPlaying(oSelf, combo[1]) then	play = false		end
		return play
	end
	if a == "cancel" then
		if combo[3] then	anim.cancel(oSelf, combo[3])			end
		anim.cancel(oSelf, combo[1])
		return
	end

	local options = {}
	for k, v in pairs(o) do		options[k] = v		end
	if combo[4] then	o.blendMask = util.bitAnd(combo[4].mask, mask)		end
	options.blendMask = combo[2].mask or options.blendMask or 15
	options.blendMask = util.bitAnd(options.blendMask, mask)
--	print(mask, options.blendMask)
	o.priority = o.priority + 1
	playHandler(combo[1], options)
	if combo[3] then	playHandler(combo[3], o)		end
end

local stance
local weaponRec = ""
local weaponType = ""
local animOptions = {
	weapon = Anim.idle.weapon.weapon.o,
	weaponSwitch = Anim.idle.weapon.weaponSwitch.o
}

Anim.idleTimer = 2

function Anim.tracked:add(v, duration)
	local g = v.g
	if (not g) or g == "none" or g == "" then
		return
	end
	v.startTime = self.timer + (v.startDelay or 0)
	v.stopTime = self.timer + (duration or 1000)
	if v.startDelay == 0 or not v.startDelay then
		if not v.running and not v.noUpdate then
			v.running = true
			playHandler(g, v.o)
		end
	end
	table.insert(self, 1, v)		self.n = self.n + 1
end

function Anim.tracked:removeIndex(i)
	if self[i].running then
		self[i].running = false		Anim.cancel(oSelf, self[i].g)
	end
	table.remove(self, i)		self.n = self.n - 1
end

function Anim.tracked:removeGroup(g)
	for i = self.n, 1, -1 do
		if self[i].g == g then
			self[i].running = false		table.remove(self, i)
		end
	end
	Anim.cancel(oSelf, g)
	self.n = #self
end

function Anim.tracked:removeAll(keepDelayed)
	for i = self.n, 1, -1 do
		local v = self[i]
		if v.running or v.noUpdate or not keepDelayed then
			v.running = false		Anim.cancel(oSelf, v.g)
			table.remove(self, i)
		end
	end
	self.n = #self
end

function Anim.tracked:update(dt)
	self.timer = self.timer + dt
	for i = self.n, 1, -1 do
		local v = self[i]
		if v.noUpdate then
			if v.event then
				self[v.g](self, v.o)
				break
			end
		elseif v.stopTime <= self.timer then
			self:removeIndex(i)
		elseif not v.running and v.startTime <= self.timer then
			v.running = true
			playHandler(v.g, v.o)
		end
	end
end

function Anim:cancelAllIdles()
--	print("STOP ACTIVE IDLES")
	if self.playingIdle and self.tracked.n > 0 then
		self.tracked:removeAll()
	end
	self.playingIdle = false
end

local wpnRecords = { [""] = "" }

local function getWeaponType(id)
	-- print("WEAPON LOOKUP")
	local wt = ""
	local r = types.Weapon.records[id]
	if not r then
		wpnRecords[id] = wt		return wt
	end

	local name = r.name:lower()
	local T = types.Weapon.TYPE
	if r.type == T.MarksmanCrossbow then
		wt = "crossbow"
	elseif name:find("spear") or name:find("halberd")
			or r.type == T.SpearTwoWide or r.type == T.BluntTwoWide then
		wt = "twowide"
	elseif name:find("warhammer") or r.type == T.BluntTwoClose or r.type == T.AxeTwoHand then
		wt = "twoclose"
	elseif name:find("claymore") then
		wt = "twohand"
	end
	wpnRecords[id] = wt			return wt
end

local function updateCombatIdle(stop)
	if stop or Anim.notIdle then
--	print("STOP COMBAT IDLE")
		Anim:cancelAllIdles()
	else
--	print("PLAY COMBAT IDLE")
		Anim.playingIdle = true
		local idle = Anim.idle.weapon
		if stance == Actor.stanceWeapon then
			Anim.tracked:add(idle.weapon)
		end
		Anim.tracked:add(idle.body)
		Anim.tracked:add(idle.weaponSwitch)
	end
end

function Anim.updateWeaponAnim(s)
	weaponRec = s.weapon and s.weapon.recordId or ""
	local wt = wpnRecords[weaponRec] or getWeaponType(weaponRec)
	if wt == weaponType then		return			end

	weaponType = wt
	if wt == "" or wt == "crossbow" then
		animOptions.weapon.startKey = nil
		animOptions.weapon.stopKey = nil
	else
		animOptions.weapon.startKey = wt .. " start"
		animOptions.weapon.stopKey = wt .. " stop"
	end
	if not(stance == Actor.stanceWeapon) or not Anim.playingIdle then
		return
	end

--	print("WEAPON CHANGE", Anim.notIdle)
--	Anim.turnStopsIdle = wt == "crossbow"
--	Anim.walkStopsIdle = wt == "crossbow"
	anim.cancel(oSelf, "armsweapon")
	local start = anim.getCompletion(oSelf, "readypose")
	animOptions.weaponSwitch.startPoint = start
	animOptions.weapon.startPoint = start
	anim.playBlended(oSelf, "armsweapon_switch", animOptions.weaponSwitch)
	anim.playBlended(oSelf, "armsweapon", animOptions.weapon)
	animOptions.weapon.startPoint = nil
	async:newUnsavableSimulationTimer(0.5, Anim.idle.switchArms)
end

function Anim.idleController(status)
	if Anim.playingIdle or status.stanceIsNothing or not Anim.idle.playWeapon then
		return
	end
	if Anim.idleTimer > 0 then
		Anim.idleTimer = Anim.idleTimer - 1
		return
	end
	updateCombatIdle()
end

function Anim:updateStatus(status)
	local notIdle = status.inCombat or status.running or status.action
		or (self.walkStopsIdle and status.isMoving)
		or (self.turnStopsIdle and status.isTurning)
		or status.sneak
	self.notIdle = notIdle
	if notIdle then
		if self.playingIdle then
			self:cancelAllIdles()
		end
		self.idleTimer = status.attack and 4
			or (status.isMoving or status.isTurning) and 2
			or status.action and 2
			or 0
	end
	if stance == status.stance then		return		end

--	print(stance, status.stance)
	if status.stanceIsNothing then
		self.turnStopsIdle = false
		self.walkStopsIdle = true
	elseif status.stance == Actor.stanceWeapon then
		self.turnStopsIdle = true
		self.walkStopsIdle = true
	else
		self.turnStopsIdle = false
		self.walkStopsIdle = false
	end
	stance = status.stance
	if notIdle then			return		end

	self:cancelAllIdles()
	if not status.stanceIsNothing and Anim.idle.playWeapon then
		self.idleTimer = 2
		if stance == Actor.stanceWeapon or not self.playingIdle then
			async:newUnsavableSimulationTimer(0.5, updateCombatIdle)
		end
	end
end


return Anim
