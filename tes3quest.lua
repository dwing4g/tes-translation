local ffi = require "ffi"
local ffistr = ffi.string
local ffichars = ffi.typeof "char[?]"
ffi.cdef[[
int __stdcall MultiByteToWideChar(int,int,const char*,int,char*,int);
int __stdcall WideCharToMultiByte(int,int,const char*,int,char*,int,const char*,int*);
]]
local C = ffi.C

local function mb2wc(src, cp)
	local srclen = #src
	local dst = ffichars(srclen * 2)
	return ffistr(dst, C.MultiByteToWideChar(cp or 65001, 0, src, srclen, dst, srclen) * 2)
end

local function wc2mb(src, cp)
	local srclen = #src / 2
	local dstlen = srclen * 3
	local dst = ffichars(dstlen)
	return ffistr(dst, C.WideCharToMultiByte(cp or 65001, 0, src, srclen, dst, dstlen, nil, nil))
end

local function loadExt(filename, callback)
	local k, e, c, m, n = nil, nil, nil, false, 0
	for line in io.lines(filename) do
		line = line:gsub("\r+$", "")
		n = n + 1
		if line ~= "" or m then
			if not k then
				if line:sub(1, 2) == "> " then
					k = line
				else
					error("ERROR: invalid line(" .. n .. "): " .. line)
				end
			elseif not e then
				e = line
				m = line:sub(1, 3) == '"""' and not line:sub(4, -1):find '"""'
			elseif e and m and not c then
				e = e .. "\r\n" .. line
				if line:find '"""' then
					m = false
				end
			elseif not c then
				c = line
				m = line:sub(1, 3) == '"""' and not line:sub(4, -1):find '"""'
				if not m then
					callback(k, e, c)
					k, e, c, m = nil, nil, nil, false
				end
			elseif c and m then
				c = c .. "\r\n" .. line
				if line:find '"""' then
					callback(k, e, c)
					k, e, c, m = nil, nil, nil, false
				end
			else
				error("ERROR: invalid line(" .. n .. "): " .. line)
			end
		end
	end
end

local t = {}
local function loadExt2(filename)
	io.write("loading ", filename, " ... ")
	local n = 0
	loadExt(filename, function(k, e, c)
		t[e] = c
		n = n + 1
	end)
	print(n .. " items")
end

loadExt2 "tes3cn_Morrowind.ext.txt"
loadExt2 "tes3cn_Tribunal.ext.txt"
loadExt2 "tes3cn_Bloodmoon.ext.txt"

-- fixes
t["East Empire Company: Raven Rock"]				= t["East Empire Company: Raven Rock Updates"]
t["Fighters Guild: Lirielle's Debt"]				= t["Fighter's Guild: Lirielle's Debt"]
t["House Telvanni: Drake's Pride"]					= t["House Redoran: Drake's Pride"]
t["Morag Tong: A Contact in the Dark Brotherhood"]	= t["Mages Guild: A Contact in the Dark Brotherhood"]
t["Morag Tong: Writ for Mathyn Bemis"]				= t["Mages Guild: Writ for Mathyn Bemis"]

local fne = "mods/SkyrimStyleQuest/Scripts/SSQN/qnamelist.lua"
local fnc = "mods/SkyrimStyleQuest/Scripts/SSQN/qnamelist_cn.lua"
io.write("loading ", fne, " and saving " .. fnc .. " ... ")
local fc = io.open(fnc, "wb")
local n = 0
for line in io.lines(fne) do
	line = line:gsub("\r+$", "")
	-- ["a1_10_mehramilo"] = "Meet Mehra Milo",
	line = line:gsub('%["(.-)("%]%s*=%s*")(.-)"', function(k, m, e)
		local c = t[e:gsub("\\'", "'")]
		if c then
			c = wc2mb(mb2wc(c, 936), 65001)
			n = n + 1
		end
		return '["' .. k .. m .. (c or e) .. '"'
	end)
	fc:write(line, "\n")
end
fc:close()
print(n .. " items")
