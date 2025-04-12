-- luajit str_dec.lua Fallout4_en.ILSTRINGS Fallout4_en.ILSTRINGS.txt

local function read4(s, p)
	return s:byte(p + 1) + s:byte(p + 2) * 0x100 + s:byte(p + 3) * 0x10000 + s:byte(p + 4) * 0x1000000
end

local f = io.open(arg[1], "rb")
local s = f:read "*a"
f:close()

local f = io.open(arg[2], "wb")
local n = read4(s, 0)
local b = 8 + n * 8
local noLen = arg[1]:lower():find "%.strings$"
for i = 1, n do
	local idx = read4(s, i * 8)
	local pos = b + read4(s, i * 8 + 4)
	local len
	if noLen then
		len = (s:find("%z", pos + 1) or #s) - (pos + 1)
	else
		len = read4(s, pos)
		pos = pos + 4
	end
	f:write("<", idx, "> ", s:sub(pos + 1, pos + len):gsub("%z+$", ""), "\n")
end

f:close()
print "done!"
