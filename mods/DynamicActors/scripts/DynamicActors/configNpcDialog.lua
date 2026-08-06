local A = {
	bone_LowerBody = 0, bone_Torso = 1, bone_LeftArm = 2, bone_RightArm = 3,
	m0 = 0, m1 = 1, m2 = 2, m3 = 3, m4 = 4, m8 = 8, m12 = 12, m14 = 14, m15 = 15,
	p1 = 1, p2 = 2, p3 = 3, p4 = 4
}

local filters = {}

filters.priorityArms = { [A.bone_LeftArm] = A.p2, [A.bone_RightArm] = A.p2 }

filters.baseIdle = {
	{ "isMale", false, "handhippose", {loops=100, priority=A.p1, blendMask=A.m15, speed=0.5}, 1 },
	{ "isMale", true, "readypose", {loops=4, priority=A.p1, blendMask=A.m3}, 1 },
}

filters.greeting = {
	{ "class", "ordinator", "armsalmapray", {priority=A.p2}, 2 },
	{ "name", "ordinator", "armsalmapray", {priority=A.p2}, 2 },
--	{ "faction", "temple", "armsalmapray", {priority=A.p2}, 2 },
	{ "class", "^guard", "armsatback", {loops=3, priority=A.p2, blendMask=A.m12}, 2 },
--	{ "class", "^ordinator", "armsatback", {loops=3, priority=A.p2, blendMask=A.m12}, 2 },
	{ "isMale", true, {
			{ "armsakimbo", {loops=3, priority=A.p2, blendMask=A.m12} },
			{ "armsfolded", {loops=3, priority=A.p2, blendMask=A.m12} },
			{ "idle7_copy", {priority=A.p2, blendMask=A.m8} },
			{ "armsfolded", {loops=3, priority=A.p2, blendMask=A.m12} },
			{ "armsakimbo", {loops=3, priority=A.p2, blendMask=A.m8} },
		}, nil, 1
	},
	{ "isMale", false, {
			{ "posealma3", {loops=1, priority=A.p2} },
			{ "armsakimbo", {loops=1, priority=A.p2, blendMask=A.m12} },
			{ "armsgesture_greet", {loops=1, priority=A.p2, blendMask=A.m12} },
			{ "armsakimbo", {loops=1, priority=A.p2, blendMask=A.m4} },
		}, nil, 1
	}
}

filters.poseShifts = {
		{ {
	{ id="armsakimbo", opt={loops=1, priority=A.p2, blendMask=A.m12}, delay=9 },
	{ id="idle2_copy", opt={priority=A.p2, speed=1.5} },
		},
		{
	{ id="armsfolded", opt={loops=1, priority=A.p2, blendMask=A.m12}, delay=2.5 },
	{ id="idle8_copy", opt={priority=A.p2, speed=2} },
		} },

		{ {
	{ id="armsakimbo", opt={loops=1, priority=A.p2, blendMask=A.m12}, delay=9 },
	{ id="idle2_copy", opt={priority=A.p2, speed=1.5} },
		},
		{
	{ id="armsatback", opt={loops=1, priority=A.p2, blendMask=A.m12}, delay=2.5 },
	{ id="idle8_copy", opt={priority=A.p2, speed=2} },
		} }
	}

local beastBlendMasks = {
--	handhippose = A.m0, armsakimbo = A.m12, readypose = A.m12,
	armsfolded = A.m12, armsatback = A.m12, armssunshield = A.m8,
	armsalmapray = A.m12, posealma3 = A.m0, idle2_copy = A.m0, idle7_copy = A.m12, idle8_copy = A.m12
	}

local armAnims = { armsfolded=true, posealma3=true }

local voice = {
	disabled = true,
	options = {loops=20, speed=1, blendMask=A.m2, priority={[A.bone_Torso] = A.p3}},
	baseAnim = "", baseBone = A.bone_LowerBody,
	groups = {
		base = "idlespeak",
		posealma3 = "",
		handhippose = "idlespeak_handhip",
		readypose = "idlespeak_ready",
	}
}

local voice_beast = { base = "idlespeak", idle3 = "", idle9 = "" }

local voice_f = {
	base = "idlespeak",
	posealma3 = "",
	handhippose = "idlespeak_handhip",
	readypose = "idlespeak_ready",
	idle = "idlespeak_idlef",
--	idle4 = "idlespeak_idlef",
	idle5 = "idlespeak_handhip",
	idle7 = "idlespeak_idlef",
	idle7_copy = "idlespeak_idlef",
	idle8 = "idlespeak_idlef",
	idle8_copy = "idlespeak_idlef",
	armsakimbo = "idlespeak_idlef",
	armsalmapray = "idlespeak_idlef",
	armsfolded = "idlespeak_idlef",
	armsatback = "idlespeak_idlef",
	armssunshield = "idlespeak_idlef",
}

local idleGroups = {
	idle=true, handhippose=true, readypose=true, posealma3=true, idlespeak=true,
--	idle2_copy=true, idle7_copy=true, idle8_copy=true,
}
for i = 2, 9 do		idleGroups["idle"..i] = true			end

local bodyParts = { legs=A.m1, chest=A.m2, leftarm=A.m4, rightarm=A.m8, botharms=A.m12,
	armschest=A.m14, legschest=A.m3 }


return {
	filters = filters,
	beastBlendMasks = beastBlendMasks,
	armAnims = armAnims,
	voice = voice, voice_beast = voice_beast, voice_f = voice_f,
	idleGroups = idleGroups,
	bodyParts = bodyParts
}
