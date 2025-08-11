-- luajit str_enc.lua Fallout4_en.ILSTRINGS.txt Fallout4_en.ILSTRINGS

local floor = math.floor
local char = string.char
local tonumber = tonumber

local function write4(t, v)
	t[#t + 1] = char(v % 0x100, floor(v / 0x100) % 0x100, floor(v / 0x10000) % 0x100, floor(v / 0x1000000))
end

local t, t1, t2 = {}, {}, {}
local strs = {}
local pos = 0
for line in io.lines(arg[1]) do
	line = line:gsub("\r+$", "")
	local idx, str = line:match "^<(%d+)> ?(.*)$"
	if idx then
		idx = tonumber(idx)
		if str == "" then str = " " end
		str = str .. "\0"
		local p = strs[str]
		if not p then
			p = pos
			strs[str] = p
			write4(t2, #str)
			t2[#t2 + 1] = str
			pos = pos + 4 + #str
		end
		t[#t + 1] = { idx, p }
	end
end
t2 = table.concat(t2)

write4(t1, #t)
write4(t1, #t2)
for i = 1, #t do
	write4(t1, t[i][1])
	write4(t1, t[i][2])
end

local f = io.open(arg[2], "wb")
f:write(table.concat(t1), t2)
f:close()
print "done!"
