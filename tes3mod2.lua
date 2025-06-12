-- luajit tes3mod2.lua fix.ext.txt tag from.txt to.txt
-- luajit tes3mod2.lua TamrielData\tes3cn_Tamriel_Data.ext.txt ACTI.FNAM TamrielData\~$ext2\ACTI.FNAM.txt TamrielData\~$ext2\ACTI.FNAM.c.txt

local io = io
local write = io.write
local arg = arg
local error = error

local ffi = require 'ffi'
ffi.cdef[[
int __stdcall MultiByteToWideChar(int cp, int flag, const char* src, int srclen, char* wdst, int wdstlen);
int __stdcall WideCharToMultiByte(int cp, int flag, const char* src, int srclen, char* dst, int dstlen, const char* defchar, int* used);
]]
local function mb2wc(src, cp)
	local srclen = #src
	local dst = ffi.typeof 'char[?]'(srclen * 2)
	return ffi.string(dst, ffi.C.MultiByteToWideChar(cp or 65001, 0, src, srclen, dst, srclen) * 2)
end
local function wc2mb(src, cp)
	local srclen = #src / 2
	local dstlen = srclen * 3
	local dst = ffi.typeof 'char[?]'(dstlen)
	return ffi.string(dst, ffi.C.WideCharToMultiByte(cp or 65001, 0, src, srclen, dst, dstlen, nil, nil))
end
local function utf8_local(s)
	return wc2mb(mb2wc(s), 1)
end
local function local_utf8(s)
	return wc2mb(mb2wc(s, 1))
end

local trans = {}
local lines = {}
write("loading '" .. arg[3] .. "' ... ")
for line in io.lines(arg[3]) do
	lines[#lines + 1] = line
end
write("OK (" .. #lines .. " lines)\n")
local n = 0
write("loading '" .. arg[4] .. "' ... ")
for line in io.lines(arg[4]) do
	n = n + 1
	if n > #lines then
		error("ERROR: too many lines")
	end
	trans[lines[n]] = utf8_local(line)
end
if n < #lines then
	error("ERROR: not enough lines")
end
write("OK (" .. n .. " lines)\n")

local function readStrExt(line, isFirst)
	if isFirst then
		if line:sub(1, 3) ~= '"""' then
			return line
		end
		line = line:sub(4, -1)
	end
	local p = line:reverse():find '"""'
	if p then
		return line:sub(1, -p - 3)
	end
	return line, true
end

write("loading '" .. arg[1] .. "' ... ")
lines = {}
local i, s = 0, 0
local tag, k, v1, v2
local newLineMark = "<n/>" -- 主要出现在INFO里的txt中
for line in io.lines(arg[1]) do
	i = i + 1
	if line ~= "" or s == 2 or s == 4 then
		if s == 0 then
			tag, k = line:match "^>%s+(.-)%s+(.+)$"
			if not tag then
				error("ERROR: require key line at line " .. i)
			end
			s = 1
		else
			if line:find "^> " and s ~= 2 and s ~= 4 then
				error("ERROR: invalid key line at line " .. i)
			end
			if s <= 2 then
				local t, r = readStrExt(line, s == 1)
				if tag ~= "BOOK.TEXT" then
					if t:find(newLineMark, 1, true) then
						error("ERROR: found newLineMark at line " .. i)
					end
					v1 = v1 and (v1 .. newLineMark .. t) or t
				else
					v1 = v1 and (v1 .. "\r\n" .. t) or t
				end
				s = r and 2 or 3
			else
				local t, r = readStrExt(line, s == 3)
				v2 = v2 and (v2 .. "\r\n" .. t) or t
				if r then
					s = 4
				else
					local t = trans[v1]
					lines[#lines + 1] = "> " .. tag .. " " .. k
					v1 = v1:gsub("<n/>", "\r\n")
					if v1:find "\n" then
						lines[#lines + 1] = '"""' .. v1 .. '"""'
					else
						lines[#lines + 1] = v1
					end
					if tag == arg[2] then
						if not t then
							error("ERROR: not translate for: " .. tag .. " " .. k)
						end
						v2 = t
					end
					v2 = v2:gsub("<n/>", "\r\n")
					if v2:find "\n" then
						lines[#lines + 1] = '"""' .. v2 .. '"""'
					else
						lines[#lines + 1] = v2
					end
					lines[#lines + 1] = ""
					s, tag, k, v1, v2 = 0, nil, nil, nil, nil
				end
			end
		end
	end
end
write "OK!\n"

write("saving '" .. arg[1] .. "' ... ")
local f = io.open(arg[1], "wb")
f:write(table.concat(lines, "\r\n"), "\r\n")
f:close()
write "OK!\n"
