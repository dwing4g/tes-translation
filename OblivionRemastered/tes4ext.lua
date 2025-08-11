-- luajit tes4ext.lua Game.en.locres.txt Game.locres.txt Game.ext.txt

local io = io
local arg = arg
local error = error
local pairs = pairs

local kindTable = {
	["ST_HardcodedContent::LOC_HC"]  = "0",
	["ST_MissingEntries::LOC_ME"]    = "1",
	["ST_AltarStaticTexts::LOC_AS"]  = "2",
	["ST_AltarStaticTexts::LOC_AD"]  = "3",
	["ST_AltarDynamicTexts::LOC_AD"] = "4",
	["ST_Descriptions::LOC_DE"]      = "5",
	["ST_BookContent::LOC_BK"]       = "6",
	["ST_ScriptContent::LOC_SC"]     = "7",
	["ST_FullNames::LOC_FN"]         = "8",
	["ST_LogEntries::LOC_LE"]        = "8",
	["ST_ResponseTexts::LOC_RT"]     = "8",
}

local kinds = {}
local function loadTxt(fn)
	local t = {}
	local i = 0
	for line in io.lines(fn) do
		line = line:gsub("\r+$", "")
		i = i + 1
		local k, v = line:match "^(.-)=(.+)$"
		if not k or k == "" then
			error("ERROR: invalid line " .. i .. " in " .. fn)
		end
		if t[k] then
			error("ERROR: duplicated key '" .. k .. "' in " .. fn)
		end
		local kind, id = k:match "^([%w_]+::%w+_%w+)_"
		if not kind then error("ERROR: invalid key: " .. k) end
		if not kindTable[kind] then
			print("WARN: unknown kind: " .. k)
			kindTable[kind] = kind
		end
		kinds[kind] = true
		t[k] = v
	end
	return t, i
end

local function escape(s)
	if s:find '"""' then
		error('ERROR: found """ in string: ' .. s .. "'")
	end
	s = s:gsub("<lf>", "\n")
	if s:find "\n" or s == "" then
		s = '"""' .. s .. '"""'
	end
	return s
end

io.stderr:write("INFO: loading '", arg[1], "' ...\n")
local et, en = loadTxt(arg[1])
local kt = {}
for k in pairs(et) do
	kt[#kt + 1] = k
end
table.sort(kt, function(a, b)
	local ka = a:gsub("^([%w_]+::%w+_%w+)_", kindTable)
	local kb = b:gsub("^([%w_]+::%w+_%w+)_", kindTable)
	if ka ~= kb then return ka < kb end
	return a < b
end)
io.stderr:write("INFO: en = ", en, "\n")

io.stderr:write("INFO: loading '", arg[2], "' ...\n")
local ct, cn = loadTxt(arg[2])
for k in pairs(ct) do
	if not et[k] then
		error("ERROR: unknown key '" .. k .. "' in " .. arg[2])
	end
end
io.stderr:write("INFO: cn = ", cn, "\n")

io.stderr:write("INFO: writing '", arg[3], "' ...\n")
local f = io.open(arg[3], "wb")
for _, k in ipairs(kt) do
	local e, c = et[k], ct[k]
	f:write("> ", k, "\r\n")
	f:write(escape(e), "\r\n")
	f:write((e == c or not c) and "###" or escape(c), "\r\n\r\n")
end
f:close()

--[[
kt = {}
for k in pairs(kinds) do
	kt[#kt + 1] = k
end
table.sort(kt)
for _, k in ipairs(kt) do
	print(k)
end
--]]
