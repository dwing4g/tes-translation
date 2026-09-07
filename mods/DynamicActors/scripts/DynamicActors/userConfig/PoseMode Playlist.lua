
local base = { name = "Base poses",
	{name="Arms Folded contrapose", group="armsFoldPose", speed = 0.5},
	{name="Arms Back Clasp contrapose", group="armsBackClaspPose", speed = 0.5},
	{name="Arms Straight contrapose", group="armsStrPose", speed = 0.5},
	{name="Hand on Hip contrapose", group="handhippose", speed = 0.5},
	{name="Hands on Hips Idle", group="armsakimbo"},
	{name="Searching Horizon Idle", group="armssunshield"},
	{name="Arms Folded Idle", group="armsFoldedOrAkimbo"},
	{name="Wall Lean 180", group="posewalllean180"},
	{name="Wall Lean", group="posewalllean"},
	{name="GV Squat down", group="gvsquat", offset = -70},
	{name="VA Sitting Chair 180", group="vasitting6", offset = -70},
	{name="VA Sitting Floor", group="vasittingfloor", offset = -70, speed = 0.5},
	{name="VA Sitting cross legged", group="vasitting4", offset = -70, speed = 0.5},
	{name="VA Sitting hugging knees", group="vasitting5", offset = -70, speed = 0.5},
	{name="VA Praying on knees", group="vasitting2", offset = -70, speed = 0.5},
--	{name="AM Sitting 2", group="amsitting2", turn = true, offset = -70, speed = 0.5},
	{name="VA Lying on side", group="vasitting7", offset = -90, speed = 0.5},
	{name="VA Sleeping on side", group="vasitting8", offset = -90},
	{name="VA Lying on back", group="vasitting9", offset = -90},
	{name="Twerk", group="twerk"},
--	{name="RX Chair Sit Casual pose", group="rxsitcasual", offset = -70},
--	{name="RX Chair Sit Upright pose", group="rxsitupright", offset = -70},
}

local weapon = { name = "Weapon poses",
	{ name = "Weapon 1H", group = "idle1h" },
	{ name = "Weapon 1H Blunt", group = "idle1b" },
	{ name = "Weapon 2H Blunt", group = "idle2b" },
	{ name = "Weapon 2H Close", group = "idle2c" },
	{ name = "Weapon 2H Wide", group = "idle2w" },
	{ name = "<No pose>", group = "" },
}

local spell = { name = "Spellcast poses",
	{ name = "Spell Ready Pose", group = "spellReady" },
	{ name = "Spell Weapon 1h", group = "spellIdle1h" },
	{ name = "Spell Contrapose", group = "spellPose" },
	{ name = "<No pose>", group = "" },
}

return { base = base, weapon = weapon, spell = spell }
