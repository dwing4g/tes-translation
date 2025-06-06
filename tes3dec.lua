-- luajit tes3dec.lua Morrowind.esm [1252|gbk|utf8] [raw] > Morrowind.txt

local string = string
local byte = string.byte
local char = string.char
local format = string.format
local sub = string.sub
local table = table
local concat = table.concat
local io = io
local write = io.write
local clock = os.clock
local ipairs = ipairs
local arg = arg
local error = error

local ENCODING = arg[2] or "1252" -- "1252", "gbk", "jis", "utf8"
local RAW = arg[3] == "raw"

local escapeKeys =
{
	["wulfharth\x92s cups\0"] = true,
	["yat\xFAr gro-shak\0"] = true,
	["at\xFAlg gro-larg\xFAm\0"] = true,
}

local isStr, addEscape
if ENCODING == "1252" then --TODO: 0x92 0xA0 0xE0 0xE1 0xE9 0xF3 used in TR_Mainland.esm
	isStr = function(s)
		local n = #s
		while n > 0 and byte(s, n) == 0 do n = n - 1 end
		if n == 0 and #s > 0 then return end
		for i = 1, n do
			local c = byte(s, i)
			if c >= 0x7f and c ~= 0x92 and c ~= 0x93 and c ~= 0x94 and c ~= 0xad and c ~= 0xef and c ~= 0xfa then return end -- ’“”­ïú used in official english Morrowind.esm
			if c < 0x20 and c ~= 9 and c ~= 10 and c ~= 13 then	return end
		end
		return true
	end
	addEscape = function(s)
		local t = {}
		local b, i, n = 1, 1, #s
		local c, e
		while i <= n do
			c, e = byte(s, i), 0
			if c <= 0x7e then
				if c >= 0x20 or c == 9 then e = 1 -- \t
				elseif c == 13 and i < n and byte(s, i + 1) == 10 then e = 2 -- \r\n
				end
			-- elseif c == 0x92 or c == 0x93 or c == 0x94 or c == 0xad or c == 0xef or c == 0xfa then e = 1 -- ’“”­ïú used in official english Morrowind.esm
			end
			if e == 0 then
				if b < i then t[#t + 1] = sub(s, b, i - 1) end
				i = i + 1
				b = i
				t[#t + 1] = format("$%02X", c)
			else
				if e == 1 and (c == 0x22 or c == 0x24) then -- ",$ => "",$$
					if b < i then t[#t + 1] = sub(s, b, i - 1) end
					b = i
					t[#t + 1] = char(c)
				end
				i = i + e
			end
		end
		if b < i then t[#t + 1] = sub(s, b, i - 1) end
		return concat(t):gsub("\r", "") -- windows console will add \r
	end
elseif ENCODING == "gbk" then
	isStr = function(s)
		local n = #s
		if n == 4 and byte(s, 4) == 0 and byte(s, 1) > 0x7f then return end
		while n > 0 and byte(s, n) == 0 do n = n - 1 end
		if n == 0 and #s > 0 then return end
		local b = 0
		for i = 1, n do
			local c = byte(s, i)
			if b == 1 then
				if c < 0x40 or c > 0xfe or c == 0x7f then return end
				b = 0
			elseif c >= 0x7f then
				if c < 0x81 or c > 0xfe or c == 0x7f then return end
				b = 1
			elseif c < 0x20 and c ~= 9 and c ~= 10 and c ~= 13 then	return
			end
		end
		return b == 0
	end
	addEscape = function(s)
		local t = {}
		local b, i, n = 1, 1, #s
		local c, d, e
		local es = escapeKeys[s]
		while i <= n do
			c, e = byte(s, i), 0
			if c <= 0x7e then
				if c >= 0x20 or c == 9 then e = 1 -- \t
				elseif c == 13 and i < n and byte(s, i + 1) == 10 then e = 2 -- \r\n
				end
			elseif i < n and c >= 0x81 and c <= 0xfe and c ~= 0x7f then
				local d = byte(s, i + 1)
				if d >= 0x40 and d <= 0xfe and d ~= 0x7f and not es then e = 2 end
			end
			if e == 0 then
				if b < i then t[#t + 1] = sub(s, b, i - 1) end
				i = i + 1
				b = i
				t[#t + 1] = format("$%02X", c)
			else
				if e == 1 and (c == 0x22 or c == 0x24) then -- ",$ => "",$$
					if b < i then t[#t + 1] = sub(s, b, i - 1) end
					b = i
					t[#t + 1] = char(c)
				end
				i = i + e
			end
		end
		if b < i then t[#t + 1] = sub(s, b, i - 1) end
		return concat(t):gsub("\r", "") -- windows console will add \r
	end
elseif ENCODING == "jis" then
	isStr = function(s)
		local n = #s
		if n == 4 and byte(s, 4) == 0 and byte(s, 1) > 0x7f then return end
		while n > 0 and byte(s, n) == 0 do n = n - 1 end
		if n == 0 and #s > 0 then return end
		local b = 0
		for i = 1, n do
			local c = byte(s, i)
			if b == 1 then
				if c < 0x40 or c > 0xfc or c == 0x7f then return end
				b = 0
			elseif c >= 0x7f then
				if c < 0xa1 or c > 0xdf then -- 1-byte japanese char
					if c < 0x81 or c > 0xfc or c == 0x7f then return end
					b = 1
				end
			elseif c < 0x20 and c ~= 9 and c ~= 10 and c ~= 13 then	return
			end
		end
		return b == 0
	end
	addEscape = function(s)
		local t = {}
		local b, i, n = 1, 1, #s
		local c, d, e
		local es = escapeKeys[s]
		while i <= n do
			c, e = byte(s, i), 0
			if c <= 0x7e then
				if c >= 0x20 or c == 9 then e = 1 -- \t
				elseif c == 13 and i < n and byte(s, i + 1) == 10 then e = 2 -- \r\n
				end
			elseif i < n and c >= 0x81 and c <= 0xfc and c ~= 0x7f then
				if c >= 0xa1 and c <= 0xdf then -- 1-byte japanese char
					e = 1
				else
					local d = byte(s, i + 1)
					if d >= 0x40 and d <= 0xfc and d ~= 0x7f and not es then e = 2 end
				end
			end
			if e == 0 then
				if b < i then t[#t + 1] = sub(s, b, i - 1) end
				i = i + 1
				b = i
				t[#t + 1] = format("$%02X", c)
			else
				if e == 1 and (c == 0x22 or c == 0x24) then -- ",$ => "",$$
					if b < i then t[#t + 1] = sub(s, b, i - 1) end
					b = i
					t[#t + 1] = char(c)
				end
				i = i + e
			end
		end
		if b < i then t[#t + 1] = sub(s, b, i - 1) end
		return concat(t):gsub("\r", "") -- windows console will add \r
	end
else -- "utf8"
	isStr = function(s)
		local n = #s
		while n > 0 and byte(s, n) == 0 do n = n - 1 end
		if n == 0 and #s > 0 then return end
		local b = 0
		for i = 1, n do
			local c = byte(s, i)
			if b > 0 then
				if c < 0x80 or c >= 0xc0 then return end
				b = b - 1
			elseif c < 0x7f then
				if c < 0x20 and c ~= 9 and c ~= 10 and c ~= 13 then	return
			elseif c >= 0xf8 then return end
			elseif c >= 0xf0 then if i + 3 <= n and (c > 0xf0 or byte(s, i + 1) >= 0x90) then b = 3 else return end
			elseif c >= 0xe0 then if i + 2 <= n and (c > 0xe0 or byte(s, i + 1) >= 0xa0) then b = 2 else return end
			elseif c >= 0xc0 then if i + 1 <= n and c >= 0xc4 then b = 1 else return end
			else return
			end
		end
		return b == 0
	end
	addEscape = function(s)
		local t = {}
		local b, i, n = 1, 1, #s
		local c, d, e
		while i <= n do
			c, e = byte(s, i), 0
			if c <= 0x7e then
				if c >= 0x20 or c == 9 then e = 1 -- \t
				elseif c == 13 and i < n and byte(s, i + 1) == 10 then e = 2 -- \r\n
				end
			elseif c >= 0xc0 and c < 0xf8 then
				if c >= 0xf0 and i + 3 <= n then
					local x, y, z = byte(s, i + 1, i + 3)
					if x >= 0x80 and x < 0xc0 and y >= 0x80 and y < 0xc0 and z >= 0x80 and z < 0xc0 and (c > 0xf0 or x >= 0x90) then e = 4 end
				elseif c >= 0xe0 and i + 2 <= n then
					local x, y = byte(s, i + 1, i + 2)
					if x >= 0x80 and x < 0xc0 and y >= 0x80 and y < 0xc0 and (c > 0xe0 or x >= 0xa0) then e = 3 end
				elseif c >= 0xc0 and i + 1 <= n then
					local x = byte(s, i + 1)
					if x >= 0x80 and x < 0xc0 and c >= 0xc4 then e = 2 end
				end
			end
			if e == 0 then
				if b < i then t[#t + 1] = sub(s, b, i - 1) end
				i = i + 1
				b = i
				t[#t + 1] = format("$%02X", c)
			else
				if e == 1 and (c == 0x22 or c == 0x24) then -- ",$ => "",$$
					if b < i then t[#t + 1] = sub(s, b, i - 1) end
					b = i
					t[#t + 1] = char(c)
				end
				i = i + e
			end
		end
		if b < i then t[#t + 1] = sub(s, b, i - 1) end
		return concat(t):gsub("\r", "") -- windows console will add \r
	end
end

local f = io.open(arg[1], "rb")
if not f then
	error("ERROR: can not open: " .. arg[1])
end

local zlib, ffistr, ffichars, ffilong1
local function ensureInit()
	if not zlib then
		local ffi = require "ffi"
		ffistr = ffi.string
		ffichars = ffi.typeof "char[?]"
		ffilong1 = ffi.typeof "long[1]"
		ffi.cdef[[
			int uncompress(char* dest, long* destLen, const char* source, long sourceLen);
			int compress2 (char* dest, long* destLen, const char* source, long sourceLen, int level);
			long compressBound(long sourceLen);
		]]
		zlib = ffi.load(ffi.os == "Windows" and "zlib1" or "z")
	end
end
local function uncompress(s, dstLen)
	ensureInit()
	local dst = ffichars(dstLen)
	local pDstLen = ffilong1(dstLen)
	-- io.stderr:write("--- ", #s, " ", dstLen, "\n")
	local r = zlib.uncompress(dst, pDstLen, s, #s)
	-- io.stderr:write("=== ", r, " ", pDstLen[0], "\n")
	if r ~= 0 then
		local msg = format(": uncompress failed: %d, size=%d=>%d(%d) 0x%08X:[%02X %02X ...]", r, #s, dstLen, pDstLen[0], f:seek() - #s, s:byte(1), s:byte(2))
		if pDstLen[0] ~= dstLen then
			error("ERROR" .. msg)
		else
			io.stderr:write("WARN", msg, "\n")
		end
	end
	if pDstLen[0] ~= dstLen then
		error(format("ERROR: uncompress size unmatched: %d ~= %d", pDstLen[0], dstLen))
	end
	return ffistr(dst, pDstLen[0])
end

local function readInt2(src, p)
	local a, b
	if src then
		a, b = byte(src, p+1, p+2)
	else
		a, b = byte(f:read(2), 1, 2)
	end
	return a + b * 0x100
end

local function readInt4(limit, src, p)
	local a, b, c, d
	if src then
		a, b, c, d = byte(src, p+1, p+4)
	else
		a, b, c, d = byte(f:read(4), 1, 4)
	end
	local v = a + b * 0x100 + c * 0x10000 + d * 0x1000000
	if limit and v > limit then error(format("ERROR: 0x%08X: too large value: %d > %d", src and p+4 or f:seek(), v, limit)) end
	return v, p
end

local stringTags = {
	"BNAM", "FNAM", "NAME", "RNAM", "SCHD", "SCTX", "TEXT",
	"GMST.DATA",
}
local binaryTags = {
	"ACID", "BYDT", "CAST", "COUN", "DATA", "DISP", "DODT", "EFID", "FLAG", "FLTV", "FRMR",
	"HCLR", "ICNT", "INDX", "INTV", "LNAM", "MODB", "MCDT", "MGEF", "NAM0", "NAM9", "NPDT",
	"PKID", "RGNC", "SCRI", "SPAW", "STAR", "STBA", "WNAM", "XSCL",
}
for _, v in ipairs(stringTags) do stringTags[v] = true end
for _, v in ipairs(binaryTags) do binaryTags[v] = true end
--[[ classes for translation
class *.esm         tes3cn.esp Morrowind_cn.esp
TES3: 1                        -> 1
ACTI: 697+346+202              -> 697   NAME -> FNAM       地点名
ALCH: 258+2+6                  -> 258   NAME -> FNAM       药水名
APPA: 22+5+0                   -> 22    NAME -> FNAM       炼金器材名
ARMO: 280+79+96                -> 280   NAME -> FNAM       重甲盾牌名
BOOK: 574+44+49       -> 574   -> 574   NAME -> FNAM,TEXT  书籍标题,书籍内容
BSGN: 13                       -> 13    NAME -> FNAM       星座名
CELL: 2538+276+121             -> 2538  NAME -> NAME       地区名
CLAS: 77+1+5          -> 77    -> 77    NAME -> FNAM,DESC  职业名,职业描述
CLOT: 510+42+31                -> 510   NAME -> FNAM       轻甲饰品名
CONT: 890+133+104              -> 890   NAME -> FNAM       场景物品名
CREA: 260+75+97                -> 260   NAME -> FNAM       战斗NPC名
DIAL: 2358+860+893    -> 4053  -> 2354  NAME -> NAME(部分) 关键词
DOOR: 140+95+87                -> 139   NAME -> FNAM       传送门名
ENCH: 708+42+46                -> 708   NAME -> ????       ????
FACT: 22+2+3                   -> 22    NAME -> FNAM,RNAM  家族名,家族成员名
GMST: 1449+102+101    -> 1220  -> 1521  NAME -> STRV       全局字符串,界面文字(PNAM,NNAM->NAME)
INFO: 23693+6504+6757 -> 23690 -> 23692 INAM -> NAME,BNAM  普通对话
INGR: 95+26+12                 -> 95    NAME -> FNAM       炼金材料名
LIGH: 574+74+44                -> 574   NAME -> FNAM       灯源名
LOCK: 6                        -> 6     NAME -> FNAM       开锁器名
MGEF: 137+4+1         -> 137   -> 137   INDX -> DESC       魔法效果描述
MISC: 536+76+55                -> 536   NAME -> FNAM       杂项物品名
NPC_: 2675+215+159             -> 2675  NAME -> FNAM       NPC名
PROB: 6                        -> 6     NAME -> FNAM       侦测器名
RACE: 10              -> 10    -> 10    NAME -> FNAM,DESC  种族名,种族描述
REGN: 9+6+1                    -> 9     NAME -> FNAM       区域名
REPA: 6+4+0                    -> 6     NAME -> FNAM       修理锤名
SCPT: 632+336+263     -> 182   -> 632   SCHD -> SCTX       脚本
SKIL: 27              -> 27    -> 27    INDX -> DESC       技能描述
SPEL: 990+33+45       -> 990   -> 990   NAME -> FNAM       魔法名
WEAP: 485+110+74               -> 485   NAME -> FNAM       武器名
TOTAL:                            40744
--]]

local classSize
local classZeroData

local function readFields(class, pos, len, src)
	local largeSize
	local p = 0
	while true do
		if p >= len then
			if p == len then return end
			error(format("ERROR: read overflow 0x%X > 0x%X", pos + p, pos + len))
		end
		local tag = src and src:sub(p+1,p+4) or f:read(4)
		p = p + 4
		if not tag:find "^[%u%d_<=>?:;@%z\x01-\x14][%u%d_]+$" then error(format("ERROR: 0x%08X: unknown tag: %q", pos + p, tag)) end
		tag = tag:gsub("^[%z\x01-\x14]", function(s) return char(byte(s, 1) + 0x61) end)
		if tag == "XXXX" then
			local n = readInt2(src, p)
			p = p + 2
			if n ~= 4 then error(format("ERROR: 0x%08X: invalid size for XXXX", pos + p)) end
			largeSize = readInt4(0x10000000, src, p)
			p = p + 4
		else
			local classTag = class .. "." .. tag
			write(RAW and format(" %s ", classTag) or format("%08X: %s ", pos + p, classTag))
			local n = classSize == 8 and readInt4(0x10000000, src, p) or readInt2(src, p)
			p = p + (classSize == 8 and 4 or 2)
			if largeSize then
				if n ~= 0 then error(format("ERROR: 0x%08X: invalid size after XXXX", pos + p)) end
				n = largeSize
			end
			largeSize = nil
			local s = n > 0 and (src and src:sub(p+1,p+n) or f:read(n)) or ""
			if n > 0 then p = p + n end
			if not binaryTags[classTag] and stringTags[classTag] or not binaryTags[tag] and (stringTags[tag] or isStr(s)) then
				write("\"", addEscape(s), "\"\n") -- :gsub("%z$", "")
			else
				for i = 1, n do
					write(format(i == 1 and "[%02X" or " %02X", byte(s, i)))
				end
				write(n > 0 and "]\n" or "[]\n")
			end
		end
	end
end

local count = {}
local function readClasses(posEnd)
	while true do
		local pos = f:seek()
		if pos >= posEnd then
			if pos == posEnd then return end
			error(format("ERROR: read overflow 0x%X > 0x%X", pos, posEnd))
		end
		local tag = f:read(4)
		if not tag:find "^[%u%d_<=>?:;@%z\x01-\x14][%u%d_]+$" then error(format("ERROR: 0x%08X: unknown tag: %q", pos, tag)) end
		tag = tag:gsub("^[%z\x01-\x14]", function(s) return char(byte(s, 1) + 0x61) end)
		if not classSize then
			local p = f:seek()
			classSize = tag == "TES3" and 8 or (byte(f:read(0x14), 0x14) == 0 and 16 or 12)
			classZeroData = ("\0"):rep(classSize)
			f:seek("set", p)
		end
		count[tag] = (count[tag] or 0) + 1
		local pre = tag == "GRUP" and "{" or "-"
		write(RAW and format("%s%s", pre, tag) or format("%08X:%s%s", pos, pre, tag))
		local n = readInt4(0x40000000)
		local b = f:read(classSize)
		local comp = false
		if b ~= classZeroData then
			comp = math.floor(byte(b, 3) / 4) % 2 == 1 -- zlib compressed
			if comp and tag ~= "GRUP" then
				b = b:sub(1, 2) .. char(byte(b, 3) - 4) .. b:sub(4) -- remove compressed mark
			end
			for j = 1, classSize do
				write(format(j == 1 and " [%02X" or " %02X", byte(b, j)))
			end
			write "]"
		end
		write "\n"
		if tag == "GRUP" then
			readClasses(pos + n)
			write(RAW and format("}\n") or format("%08X:}\n", f:seek()))
		else
			if comp then
--[[
				write(RAW and format(" ") or format("%08X: ", f:seek()))
				b = n > 0 and f:read(n) or ""
				for i = 1, n do
					write(format(i == 1 and "[%02X" or " %02X", byte(b, i)))
				end
				write(n > 0 and "]\n" or "[]\n")
--]]
				if n < 4 then error(format("ERROR: 0x%08X: n=%d < 4", pos, n)) end
				write "<\n" -- compress begin
				local dn = readInt4(0x10000)
				n = n - 4
				b = n > 0 and f:read(n) or ""
				if b ~= "" then
					local d = uncompress(b, dn)
					readFields(tag, 0, #d, d)
				end
				write ">\n" -- compress end
			else
				readFields(tag, f:seek(), n)
			end
		end
	end
end

local posEnd = f:seek "end"
f:seek "set"
local t = clock()
readClasses(posEnd)
f:close()
io.stderr:write("done! ", clock() - t, " seconds\n")

local n = 0
local index = {}
for k in pairs(count) do
	index[#index + 1] = k
end
table.sort(index)
for _, k in ipairs(index) do
	n = n + count[k]
	io.stderr:write(k, ": ", count[k], "\n")
end
io.stderr:write("TOTAL: ", n, "\n")
