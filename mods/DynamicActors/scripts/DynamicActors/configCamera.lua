local v3 = common.omw.util.vector3

local F = {
	z1 = { focal = v3(0, 0, 128 * 0.85) },
	z45 = { focal = v3(0, 0, 45) },
}

local M = {

	byAnim = {

	["meshes/"] = {},
	["meshes/base_anim.nif"] = {},
	["meshes/base_anim_female.nif"] = {},
	["meshes/base_animkna.nif"] = {},
	["meshes/epos_kha_upr_anim_f.nif"] = {},
	["meshes/epos_kha_upr_anim_m.nif"] = {},
	["meshes/pi_tsa_base_anim.nif"] = {},

	["am_beggar.nif"] = { 35, keys={"idle2", "idle3", "idle4", "idle"} },		-- headnode 0 3 49
	["am_dreamera.nif"] = { 45, keys={"idle2", "idle"} },
	["am_dreamerb.nif"] = { 45, keys={"idle6", "idle"} },
	["am_drummer03.nif"] = { 45, keys={"idle2", "idle"} },
	["am_eater.nif"] = { keys={"idle2"}, focal=v3(0, 25, 40) },	--headnode 0 10 58	headpos 52
	["am_fishman.nif"] = { 45, keys={"idle2", "idle3", "idle"} },
	["am_luteplaying.nif"] = { 45, keys={"idle2", "idle"}, focal=v3(0, 0, 44) },	--headnode 0 7 58	headpos 62
	["am_reader1.nif"] = {},
	["am_reader2.nif"] = { 45, keys={"idle2", "idle3", "idle4"} },
	["am_sitting.nif"] = { 52, keys={"idle2", "idle3", "idle4"}, focal=v3(0, 30, 40) },	-- headpos 52
	["am_writer02.nif"] = { 45, keys={"idle2", "idle3", "idle4"} },

	["am_sitbar.nif"] = { 45, keys={"idle8", "idle9"} },
	["bandit.nif"] = { 45, keys={"idle8"} },
	["farmer.nif"] = { 45, keys={"idle8"} },
	["farmer2.nif"] = {45, keys={"idle9"} },
	["prayerdf.nif"] = {53, keys={"idle9"} },
	["prayerdm.nif"] = {53, keys={"idle9"} },	-- headnode 0 13.5 76		idle 0 5.5 124.5
	["slavesitting.nif"] = { 35, keys={"idle9"} },

	["va_sitting.nif"] = { 45, keys={"idle2", "idle3", "idle4", "idle5", "idle6", "idle7", "idle8", "idle9"} },
	["va_sittingdunmertest.nif"] = { 45, keys={"idle2"} },

	["barsitter.nif"] = { 52, keys={"idle2", "idle3", "idle4", "idle5"}, focal=v3(0, 30, 35) },	-- headpos 52
	["wallean.nif"] = { 120, keys={"idle9"}, focal=v3(0, -29, 102) },	-- headpos 120

	["anim_sitpleading.nif"] = { 45, keys={"idle9"} },
	["anim_sitthreatening.nif"] = { 45, keys={"idle9"} },

	-- Shadow of Aetherius
	["sit1.nif"] = { keys={"idle9"}, focal=v3(0, -11, 90) },	-- headpos 90
	["sit2.nif"] = { keys={"idle9"}, focal=v3(0, -30, 25)},		-- headpos -40, 25
	["sit3.nif"] = { keys={"idle9"}, focal=v3(0, 0, 40)},		-- headpos 52

	-- Riders
	["mountedguar1.nif"] = {
		keys= { "idle", "idle3", "idle6", "idle2", "idle7", "idle8", "idle9",
			idle4 = v3(0, 25, 165), idle5 = v3(0, 50, 165),
			default = v3(0, 10, 190)
		},
		focal = v3(0, 10, 190), distance = 100
	},
	["mountedguar1muzzle.nif"] = {
		keys= { "idle", "idle3", "idle6", "idle2", "idle7", "idle8", "idle9",
			idle4 = v3(0, 25, 165), idle5 = v3(0, 50, 165),
			default = v3(0, 10, 190)
		},
		focal = v3(0, 10, 190), distance = 100
	},
	["mountedguar2.nif"] = {
		keys= { "idle", "idle3", "idle6", "idle2", "idle7", "idle8", "idle9",
			idle4 = v3(0, 50, 165), idle5 = v3(0, 70, 160),
			default = v3(0, 30, 195)
		},
		focal = v3(0, 30, 195), distance = 100
	},
	["mountedguar2muzzle.nif"] = {
		keys= { "idle", "idle3", "idle6", "idle2", "idle7", "idle8", "idle9",
			idle4 = v3(0, 50, 165), idle5 = v3(0, 70, 160),
			default = v3(0, 30, 195)
		},
		focal = v3(0, 30, 195), distance = 100
	},


--	["meshes/luce/am/am_luteplaying.nif"] = { }


	},

	byModel = {

		{ id="scamp_fetch.nif", height=90 },
		{ id="tr_vile_dae_c.nif", height=145 },

--[[
		{id="guar.nif$", height=120, radius=165},
		{id="^guar_", height=120, radius=165},
	--	{id="guar.nif$", height=120, radius=140, scale=0.3},
	--	{id="^guar_", height=120, radius=140, scale=0.3},
	--	{id="tr_gremlin", height=45},
--]]

	},

	byGroup = {
		idle = F.z1,

		-- Sit Down please groups
		vasitting2 = { focal = v3(0, 5, 66) },
		vasitting3 = { focal = v3(0, 0, 45) },
		vasitting4 = { focal = v3(0, 0, 45) },
		vasitting5 = { focal = v3(0, 0, 45) },
		vasitting6 = { focal = v3(0, 55, 85) },
		vasitting7 = { focal = v3(0, 30, 20) },
		vasitting8 = { focal = v3(0, -30, 20) },
		vasitting9 = { focal = v3(0, -35, 10) },

		sdpvasitting2 = { focal = v3(0, 5, 66) },
		sdpvasitting3 = { focal = v3(0, 0, 45) },
		sdpvasitting4 = { focal = v3(0, 0, 45) },
		sdpvasitting5 = { focal = v3(0, 0, 45) },
		sdpvasitting6 = { focal = v3(0, 55, 85) },
		sdpvasitting7 = { focal = v3(0, 30, 20) },
		sdpvasitting8 = { focal = v3(0, -30, 20) },
		sdpvasitting9 = { focal = v3(0, -35, 10) },

		sitidle1 = { focal = v3(0, 10, 70) },

		-- Dynamic Conversations

		alco = F.z1, alco9 = F.z1,					-- xam_alchemist.kf
		cough6 = F.z1,							-- xam_cough.kf
		eat1 = F.z1, drnk1 = { focal = v3(0, 25, 40) },			-- xam_eater.kf
		red1 = F.z1, red12 = F.z1, red13 = F.z1,			-- xam_reader1.kf
		red2 = F.z1, red22 = F.z45, red23 = F.z45, red24 = F.z45,	-- xam_reader2.kf
		sitz = F.z1, sitz2 = F.z45, sitz3 = F.z45, sitz4 = F.z45,	-- xam_sitting.kf
		smit = F.z1, smit2 = F.z1, smit3 = F.z1,			-- xam_smith.kf
		swp01 = F.z1,							-- xam_sweeping.kf
		f_sl8 = { focal = v3(35, -60, 10) }, f_sl7=F.z1, f_sl9=F.z1,	-- xanim_f_sleeping.kf
		guar = F.z1, guar2 = F.z1, guar3 = F.z1, guar4 = F.z1, guar5 = F.z1,	-- xguard.kf
		lie_female_02a9 = { focal = v3(15, -30, 20) },			-- xanim_lydown_female_02a.kf
		lie_female_02c9 = { focal = v3(15, -30, 20) },			-- xanim_lydown_female_02c.kf
		lie_male_02a9 = { focal = v3(0, -30, 10) },			-- xanim_lydown_male_02a.kf
		lie_male_02b9 = { focal = v3(0, -30, 10) },			-- xanim_lydown_male_02b.kf
		lie_male_02c9 = { focal = v3(0, -30, 10) },			-- xanim_lydown_male_02c.kf
		lieside_f_Br9 = { focal = v3(5, -35, 20) },			-- xanim_lydownside_f_Br.kf
		lieside_male_Br9 = { focal = v3(-5, -35, 20) },			-- xanim_lydownside_male_Br.kf
		lie_029= { focal = v3(0, -35, 10) },				-- xanim_lyingdown_02.kf
		m_sl8 = { focal = v3(-65, -10, 10) },				-- xanim_m_sleeping.kf
		s1_l9 = { focal = v3(55, -10, 10) },				-- xanim_s1_liedown1b.kf
		slee8 = { focal = v3(40, -55, 10) }, slee7=F.z1, slee9=F.z1,	-- xanim_sleeping.kf
		slee2x8 = { focal = v3(40, -55, 10) }, slee2x7=F.z1, slee2x9=F.z1,	-- xanim_sleeping2x.kf
		slav9 = { focal = v3(0, 0, 35) },				-- xslavesitting.kf
		swp02 = F.z1,							-- xsweep.kf
	}

}

function M:add(vec, list)
	for _, v in ipairs(list) do
		self.byGroup[v] = vec
	end
end

M:add(F.z1, {
	"idle", "idle2", "idle3", "idle4", "idle5", "idle6", "idle7", "idle8", "idle9",
	"idle2_copy", "idle7_copy", "idle8_copy",
	"armsfolded", "armsakimbo", "armsalmapray", "armssunshield", "armsatback",
	"armsgesture", "armsgesture_greet",
	"readypose", "handhippose", "posealma3"
})

-- Dynamic Conversations

M:add(F.z1, {
	"pcdc_greet_01", "pcdc_greet_02", "pcdc_greet_03", "pcdc_greet_04", "pcdc_greet_05",
	"pcdc_talk_01", "pcdc_talk_02", "pcdc_talk_03", "pcdc_talk_04", "pcdc_talk_05", "pcdc_talk_06",
	"pcdc_talk_07" , "pcdc_talk_08", "pcdc_talk_09"
})

M:add({ focal = v3(0, 0, 35) }, { "begg", "begg2", "begg3", "begg4" })
M:add({ focal = v3(0, 25, 40) }, { "eat1", "drnk1" })
M:add(F.z45, { "fish", "fish2", "fish3" })
M:add(F.z45, { "red22", "red23", "red24" })
M:add(F.z45, { "writ", "writ2", "writ3", "writ4" })

M:add(F.z1, { "spec", "spec2", "spec3", "spec4" })
M:add(F.z1, { "spc2", "spc22", "spc23", "spc24", "spc25", "spc26" })
M:add({ focal = v3(0, 0, 35) }, { "squa", "squa9" })
M:add(F.z45, { "skoo", "skoo2", "skoo3", "skoo4" })
M:add(F.z45, { "sbrr", "sbrr2", "sbrr3" })


return M

