local oSelf = common.omw.self
local types = common.omw.types
local core = common.omw.core
local util = common.omw.util
local camera = common.omw.camera
local I = common.omw.interfaces
local nearby = common.omw.nearby

local v3 = util.vector3
local L = {
	isActor = types.Actor.objectIsInstance,
	getStance = types.Actor.getStance,
	activeEffects = types.Actor.activeEffects(oSelf),
	controls = oSelf.controls
}

local MD = {
	FirstPerson = camera.MODE.FirstPerson,
	ThirdPerson = camera.MODE.ThirdPerson,
	Preview = camera.MODE.Preview,
	Static = camera.MODE.Static,
	getMode = camera.getMode,
	setMode = camera.setMode
}


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


local posing = false
local logging = false

local dialog = { lastGreeting = {} }
dialog.set = {
	posing = function(m)		posing = m	return m		end,
	logging = function(m)		logging = m	return m		end
}

local settings = common.settings
dialog.Cam = common.dialogCam
local zoom1st = common.zoom1st
dialog.zoom1st = zoom1st
local camsave = common.camSave
local dCam  = common.dCam
local heights = common.heights

local infoIndex = require("openmw.storage").globalSection("temp_dActors_infoIndex")


local function getActorHeight(o)
	if types.Creature.objectIsInstance(o) then
		local box = o:getBoundingBox()
		return (box.center.z + box.halfSize.z - o.position.z) / o.scale
	end
	local rec = types.NPC.records[o.recordId]
	local gender = rec.isMale and "male" or "female"
	return types.NPC.races.records[rec.race].height[gender] * 128
end

local function getActorRatios(o)
	if types.Creature.objectIsInstance(o) then
		return util.transform.scale(1, 1, 1)
	end
	local rec = types.NPC.records[o.recordId]
	local gender = rec.isMale and "male" or "female"
	local height = types.NPC.races.records[rec.race].height[gender]
	local weight = types.NPC.races.records[rec.race].weight[gender]
	return util.transform.scale(weight, weight, height)
end


function dialog.hasOpened(data)
	camsave.offset1st = camera.getFirstPersonOffset()
	camsave.dist3rd = camera.getThirdPersonDistance()
	camsave.hud = I.UI.isHudVisible()
	zoom1st.scale, zoom1st.force, zoom1st.zoomOut = 1, false, false
	zoom1st.extraYaw, zoom1st.vector = 0
	zoom1st.speed = settings.camera:get("dialog_1st_zoom_speed") / 100
	zoom1st.offset = math.rad(settings.camera:get("dialog_1st_zoom_offset"))
	zoom1st.dist = settings.camera:get("dialog_1st_zoomdist")
	camsave.yaw, camsave.pitch, camsave.extrayaw = camera.getYaw(), camera.getPitch(), camera.getExtraYaw()
	dialog.Cam.barsRatio, dialog.Cam.aperture = 0, 0
	local npc = data.arg			dialog.Target = npc
	if data.pause or not data.near or (npc.position - oSelf.position):length() > 1000 then
		return
	end

	local d = dialog.Cam
	d.interval, d.counter, d.adjust = 2, 0, true
--	d.playerHeight = getActorHeight(oSelf) * oSelf.scale
--	d.playerEyesVec = v3(0, 0, d.playerHeight * 0.974)
	d.playerEyesVec = v3(0, 0, getActorHeight(oSelf) * oSelf.scale * 0.974)
	d.target = npc
	d.radius, d.head, d.animKeys = 0
	d.npcSizeRatios = getActorRatios(npc)
--	d.height = types.Creature.objectIsInstance(npc) and getActorHeight(npc) * 0.85 or 128 * 0.85
--	d.vecFocalDefault = d.npcSizeRatios:apply(v3(0, 0, d.height * npc.scale))
	d.vecFocalDefault = v3(0, 0, getActorHeight(npc) * npc.scale * 0.85)

	d.barsRatio = settings.camera:get("dialog_1st_ratio") or 0
	dCam.enableShaders(true)
	d.aperture = d.shaders and settings.camera:get("dialog_1st_dof_str") / 100 or 0
--	d.ratio = d.shaders and settings.camera:get("dialog_1st_ratio") or 0

	local file = npc.type.records[npc.recordId].model:lower() or ""
	local height = heights.byAnim[file]
	if not height then
		local i, j = string.find(file, "/[^/]*$")
		file = i and string.sub(file, i+1, j) or file
		height = heights.byAnim[file]
	end

	local useBox, focusHeight, focusVec = true
	if height then
		useBox = false
		d.animKeys = height.keys
		local vec = height.focal or (height[1] and v3(0, 0, height[1]))
		d.headPosAnim = vec and d.npcSizeRatios:apply(vec) * npc.scale or d.vecFocalDefault
		if logging and next(height) then	print(file)		end
		zoom1st.dist = height.distance and math.max(height.distance, zoom1st.dist) or zoom1st.dist
	elseif types.Creature.objectIsInstance(npc) then
		for _, v in ipairs(heights.byModel) do
			if file:find(v.id) then
		--		print(v.id, v.height, v.scale)
				useBox = false
				focusHeight = v.height
				if v.scale then zoom1st.scale = v.scale		end
				if v.radius then d.radius = v.radius		end
				if v.focal then focusVec = v.focal		end
			end
		end
	end
	for _, v in ipairs(heights.byRecord) do
		if string.find(npc.recordId, "^"..v.id) then
			useBox = false
			if v.height then focusHeight = v.height		end
		--	if v.camAdjust then d.adjust = v.camAdjust		end
			if v.camAdjust ~= nil then d.adjust = v.camAdjust	end
		--	if v.scale then zoom1st.scale = v.scale			end
			if v.radius then d.radius = v.radius			end
			if v.focal then focusVec = v.focal			end
			zoom1st.dist = v.distance and math.max(v.distance, zoom1st.dist) or zoom1st.dist
			break
		end
	end

	if focusHeight and not focusVec then
		focusVec = v3(0, 0, focusHeight)
	end
	if focusVec then
		d.vecFocalDefault = d.npcSizeRatios:apply(focusVec) * npc.scale
	end
	if useBox then
		if logging then print("OPENED: USEBOX FOR")		end
		local box = npc:getBoundingBox()
		focusVec = (npc.position - box.center)
		focusVec = focusVec.xy0 + util.vector3(0, 0, (math.abs(focusVec.z) + box.halfSize.z) * 0.85)
		if types.Creature.objectIsInstance(npc) then
			d.radius = math.max(box.halfSize.x, box.halfSize.y)
		end
	end
	focusVec = focusVec or d.vecFocalDefault

	d.deltaPos = npc.position - oSelf.position
	dCam.autoCamUpdate(0)
	d.radius = d.radius * npc.scale
	if logging then print(focusVec, d.radius)		end

	zoom1st.zoomIn = d.firstZoom		zoom1st.delay = 0
	local res = nearby.castRay(d.playerEyesVec + oSelf.position, focusVec + npc.position,
		{ ignore={oSelf, npc} })
	if res.hitObject and L.isActor(res.hitObject)
		and (oSelf.position - npc.position):length() < 250 then
	elseif res.hit then
		zoom1st.zoomIn = false
	end
	zoom1st.level = 0
--	zoom1st.level = (zoom1st.offset ~= 0 and not zoom1st.zoomIn and 1) or 0

	d.controls, d.isActive, d.instant = false, true, false
	if settings.camera:get("dialog_disableHud") and I.UI.isHudVisible() then
		I.UI.setHudVisibility(false)
	end
	if not posing then
		camsave.mode, camsave.offset3rd = camera.getMode(), camera.getFocalPreferredOffset()
		if d.firstAuto and settings.global:get("unpause_dialog_opt") ~= "opt_alwayspause" then
			if camera.getMode() ~= MD.FirstPerson then
				camera.setMode(MD.FirstPerson)
				d.instant = true		zoom1st.delay = 0.2
			end
		end
	end
end

function dialog.hasClosed(data)
	dialog.Target = nil
	I.UI.setHudVisibility(true)
	dialog.Cam.isActive = false		zoom1st.zoomIn = false
--	if zoom1st.extraYaw ~= 0 and camera.getMode() == MD.FirstPerson then
--		camera.setExtraYaw(camsave.extrayaw)
	if zoom1st.vector or zoom1st.extraYaw ~= 0
		or dialog.Cam.aperture > 0 or dialog.Cam.barsRatio > 0
			then
		zoom1st.zoomOut = true
	end
	if not posing then
		camera.setFocalPreferredOffset(camsave.offset3rd)
		if not zoom1st.zoomOut then	dCam.restoreCamera()		end
	end
end


function dialog.DialogueResponse(e)
	if not(e.type == "topic" or e.type == "greeting") then
		return
	end

	if e.recordId then
		e.infoIndex = e.infoIndex or infoIndex:get(e.recordId .. "_" .. e.infoId) or 0
	end
	if e.infoIndex == 0 and e.type ~= "greeting" then
		local infos, infoId = core.dialogue[e.type].records[e.recordId].infos, e.infoId
		for i = 1, #infos do
			if infos[i].id == infoId then
				e.infoIndex = i
				break
			end
		end
	--	print(infos, e.infoIndex)
	end
	if dialog.Target == e.actor then
		e.event = "DialogueResponse"
		dialog.Target:sendEvent("DynamicActors", e)
		core.sendGlobalEvent("DynamicActors", e)
		e.event = nil
	elseif e.type == "greeting" then
		dialog.lastGreeting = { actor = e.actor, type = e.type,
			infoId = e.infoId, recordId = e.recordId, infoIndex = e.infoIndex }
	end
end

if core.API_REVISION < 129 then
	dialog.tes3InfoGetText = function(e)
		local infoId = e.info.id
		if not dialog.Target or not infoId then
			return
		end
		local info = { actor = dialog.Target, type = "topic", infoId = infoId }
		for _, v in ipairs(infoIndex:get("greeting")) do
			local i = infoIndex:get(v .. "_" .. infoId)
			if i then
				info.type = "greeting"		info.recordId = v	info.infoIndex = i
				break
			end
		end
		for _, v in ipairs(infoIndex:get("topic")) do
			local i = infoIndex:get(v .. "_" .. infoId)
			if i then
				info.type = "topic"		info.recordId = v	info.infoIndex = i
				break
			end
		end

		dialog.DialogueResponse(info)
	end
end


return dialog
