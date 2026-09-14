local self = require("openmw.self")
local types = require("openmw.types")
local camera = require("openmw.camera")
local storage = require("openmw.storage")
local core = require("openmw.core")
local input = require("openmw.input")

local common = {}

common.l10n = core.l10n("DynamicActors")

local function merge(t, data)
	for k, v in pairs(data) do
		t[k] = v
	end
end

common.Input = {
	getRange = input.getRangeActionValue,
	getNumber = input.getNumberActionValue,
	getAxis = input.getAxisValue,
	press = input.isControllerButtonPressed,
	mouseX = input.getMouseMoveX,
	mouseY = input.getMouseMoveY,
	c = {}
}
merge(common.Input.c, input.CONTROLLER_BUTTON)
merge(common.Input.c, input.CONTROLLER_AXIS) 

--[[
for k, v in pairs(input.CONTROLLER_BUTTON) do
	common.Input.c[k] = v
end
for k, v in pairs(input.CONTROLLER_AXIS) do
	common.Input.c[k] = v
end
--]]

common.Actor = {
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

common.MD = {
	getMode = camera.getMode,
	setMode = camera.setMode,
	getFocalPreferredOffset = camera.getFocalPreferredOffset,
	setFocalPreferredOffset = camera.setFocalPreferredOffset
}
merge(common.MD, camera.MODE)

common.paths = {
	configCam = "scripts.DynamicActors.configCamera",
	configPosing = "scripts.DynamicActors.posing.configLoader",
	npcPos = "config/dynamic-actors/dialog-npc-camera-positions.yaml",
	playlists = "config/dynamic-actors/playlists/",
	nothing = "config/dynamic-actors/playlists/base-poses.yaml",
	weapon = "config/dynamic-actors/playlists/weapon-poses.yaml",
	spell = "config/dynamic-actors/playlists/spellcast-poses.yaml",
}

common.settings = { names = {
	{ "camera", "Settings_dynactors_camera", "playerSection" },
	{ "player", "Settings_dynactors_player", "playerSection" },
	{ "global", "Settings_dynamicactors", "globalSection" }
	},
	storage = {},
	update = {}
}

for _, v in ipairs(common.settings.names) do
	common.settings[v[1]] = storage[v[3]](v[2])
	common.settings.storage[v[1]] = v[2]
end

common.camSave = {
	mode = camera.getMode(),
	offset3rd = camera.getFocalPreferredOffset(),
	extrayaw = 0
}
common.status = { legGroup="", lastGroup="" }


return common
