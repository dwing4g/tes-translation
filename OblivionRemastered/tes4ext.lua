-- luajit tes4ext.lua Game.en.locres.txt Game.locres.txt Game.ext.txt

local io = io
local arg = arg
local error = error
local pairs = pairs
local ipairs = ipairs

local function loadTxt(fn)
	local t = {}
	local i = 0
	for line in io.lines(fn) do
		i = i + 1
		local k, v = line:match "^(.-)=(.+)$"
		if not k or k == "" then
			error("ERROR: invalid line " .. i .. " in " .. fn)
		end
		if t[k] then
			error("ERROR: duplicated key '" .. k .. "' in " .. fn)
		end
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
table.sort(kt)
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
