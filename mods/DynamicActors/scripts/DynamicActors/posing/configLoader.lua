local core = require("openmw.core")
local vfs = require("openmw.vfs")
local loadYaml = require("openmw.markup").loadYaml

local common = require("scripts.dynamicactors.common_player")
local Anim = common.Anim
local paths = common.paths

Anim.playlists = { nothing = {}, weapon = {}, spell = {} }
for k, v in next, Anim.playlists do
	v[1] = { name = "<none>", stance = k, save = 1, { name = "<none>", group = "", id = "" } }
	v.i = 1
end

Anim.poses = Anim.playlists.nothing[1]

local M = { index = 1 }

local function getOrInitKey(t, k)
	local v = t[k]
	if not v then
		v = {}		t[k] = v
	end
	return v
end

local function validatePose(p)
	if type(p) ~= "table" or type(p.name) ~= "string" then
		return
	end
	if p.speed and type(p.speed) ~="number" then	return		end
	local g = p.group
	if g and type(g) ~= "string" then		return		end

	g = g or ""
	g = not Anim.combo[g] and g:lower() or g
	p.id = g
--	p.group = g
	return true
end

local function validatePlaylist(l)
	if type(l.name) ~= "string" then		return		end
	local stance = type(l.stance) == "string" and l.stance:lower() or "nothing"
	local playlist = l.playlist
	if type(playlist) ~= "table" or #playlist < 1 then
		return
	end

	for k, v in ipairs(playlist) do
		if not validatePose(v) then
			print("Invalid pose :" .. k .. " in file " .. l.source)
			return
		end
	end

	playlist.name = l.name			playlist.stance = stance
	playlist.source = l.source		playlist.save = 1
	return playlist
end

local function registerPlaylist(configs, data)
	local playlist = validatePlaylist(data)
	if not playlist then
		print("Invalid playlist " .. data.source)
		return
	end
	local stance = configs[playlist.stance]
	if not stance then
		print("Invalid playlist stance " .. data.source)
		return
	end
	stance[#stance + 1] = playlist
end

function M.loadPlaylists()
	local configs = {
		nothing = {}, weapon = {}, spell = {}
	}
	local i = paths.playlists:len() + 1
	for f in vfs.pathsWithPrefix(paths.playlists) do
		if f:find("%.yaml$") then
			print("Loading playlist " .. f:sub(i))
			local data = loadYaml(f)
			if type(data) == "table" then
				data.source = f:sub(i)
			--	print(data.source)
				registerPlaylist(configs, data)
			end
		end
	end
	for _, v in next, configs do
		v.i = 1
		if #v < 1 then
			v[1] = { name = "<none>", stance = k, save = 1, { name = "<none>", group = "", id = "" } }
		end
	end
	Anim.playlists = configs
end


return M
