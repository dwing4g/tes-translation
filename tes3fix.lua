-- luajit tes3fix.lua tes3cn_Morrowind.ext.txt

local io = io
local arg = arg
local ipairs = ipairs
local print = print
local error = error
local char = string.char
local concat = table.concat

local function getEnd(line)
	local ee = ""
	while true do
		local e = line:sub(-1, -1)
		if e == "," or e == "." or e == ";" or e == ":" or e == "?" or e == "!" then
			ee = e .. ee
			line = line:sub(1, -2)
		else
			e = line:sub(-2, -1)
			if e == "£¬" or e == "¡£" or e == "£»" or e == "£º" or e == "£¿" or e == "£¡" or e == "¡­" then
				ee = e .. ee
				line = line:sub(1, -3)
			else
				return ee
			end
		end
	end
end

local trans = {
	[","] = "£¬",
	["."] = "¡£",
	[";"] = "£»",
	[":"] = "£º",
	["?"] = "£¿",
	["!"] = "£¡",
	[".."] = "¡­",
	["..."] = "¡­",
	["...."] = "¡­¡­",
	["....."] = "¡­¡­",
	["......"] = "¡­¡­",
	["......."] = "¡­¡­¡­",
	["........"] = "¡­¡­¡­",
	["........."] = "¡­¡­¡­",
	["??"] = "£¿£¿",
	["?!"] = "£¿£¡",
	["!?"] = "£¡£¿",
	["!!"] = "£¡£¡",
	["???"] = "£¿£¿£¿",
	["!!!"] = "£¡£¡£¡",
	["!!!!"] = "£¡£¡£¡£¡",
	["!!!!!"] = "£¡£¡£¡£¡£¡",
	["!!!!!!"] = "£¡£¡£¡£¡£¡£¡",
	["?."] = "£¿",
	["?.."] = "£¿¡­",
	["?..."] = "£¿¡­",
	["?...."] = "£¿¡­¡­",
	["?....."] = "£¿¡­¡­",
	["?......"] = "£¿¡­¡­",
	["!..."] = "£¡¡­",
	["...!"] = "¡­£¡",
	["...?"] = "¡­£¿",
	[".!"] = "£¡",
}

local ignores = {
	["Numpad ,"] = true,
	["a.m."] = true,
	["p.m."] = true,
}

local i = 0

local function fix(e, c, i)
	if ignores[e] or c:find "^¡¶.-¡·$" or c == "###" or c:find "^%s.-%s$" then
		return c
	end
	local cc = c:match "{[^{}]*}$"
	if cc then
		c = c:sub(1, -#cc - 1):gsub("[ \t]+$", "")
	elseif not e:find "[ \t]$" then
		c = c:gsub("[ \t]+$", "")
	end
	local ee = getEnd(e:gsub("[%s%c]+$", ""))
	local ce = getEnd(c)
	if ee == "" and e:find '%.["\']$' then
		ee = "."
	end
	if ee == "" then
		if ce ~= "" then
			c = c:sub(1, -#ce - 1):gsub("[ \t]+$", "")
		end
	else
		local tee = trans[ee]
		if not tee then
			error("ERROR: unknown end: '" .. ee .. "' at line " .. i)
		end
		if tee ~= ce then
			if tee == "¡£" and c:find '¡£¡±$' then
			else
				c = c:sub(1, -#ce - 1):gsub("[ \t]+$", "") .. tee
			end
		end
	end
	c = c
		:gsub("%.%.%.%.+", "¡­¡­")
		:gsub("%.%.+", "¡­")
--		:gsub(",", "£¬")
		:gsub("%.[ \t]+", "¡£")
		:gsub(";", "£»")
		:gsub(":", "£º")
		:gsub("%?", "£¿")
		:gsub("!", "£¡")
		:gsub(",[ \t]+", "£¬")
		:gsub("£¬[ \t]+", "£¬")
		:gsub("¡£[ \t]+", "¡£")
		:gsub("£»[ \t]+", "£»")
		:gsub("£º[ \t]+", "£º")
		:gsub("£¿[ \t]+", "£¿")
		:gsub("£¡[ \t]+", "£¡")
		:gsub("¡­[ \t]+", "¡­")
--		:gsub("¡¸(.-)¡¹", "¡°%1¡±")
--		:gsub("¡º(.-)¡»", "¡®%1¡¯")
	return cc and (c .. " " .. cc) or c
end

local function fixMark(e, c, i)
	if not c:find "[\x80-\xff] +[\x80-\xff]" then
		return c
	end
	local cc = c:match "{[^{}]*}$"
	if cc then
		c = c:sub(1, -#cc - 1):gsub("[ \t]+$", "")
	end
	local em = {}
	for s in e:gmatch "[,.;:?!]+" do
		if #s == 1 then
			em[#em + 1] = s
		else
			for i = 1, #s do
				local ss = s:sub(i, i)
				if ss == "." and s:sub(i - 1, i - 1) == "." then
					em[#em] = em[#em] .. "."
				else
					em[#em + 1] = ss
				end
			end
		end
	end
	for _, m in ipairs(em) do
		if not trans[m] then
			error("ERROR: unknown mark: '" .. m .. "' at line " .. i)
		end
	end
	local ct = {}
	local half = false
	for i = 1, #c do
		local b = c:byte(i)
		if half then
			ct[#ct + 1] = c:sub(i - 1, i)
			half = false
		elseif b >= 0x80 then
			half = true
		else
			ct[#ct + 1] = char(b)
		end
	end
	if half then
		error("ERROR: unexpected half char: '" .. c .. "' at line " .. i)
	end
	local j = 1
	local fail = false
	for i, b in ipairs(ct) do
		if b == "¡£" or b == "£»" or b == "£¿" or b == "£¡" then
			if trans[em[j]] == b then
				j = j + 1
			else
				fail = true
				break
			end
		elseif b == "£º" then
			if em[j] == ":" or em[j] == "." then
				j = j + 1
			else
				fail = true
				break
			end
		elseif b == "£¬" then
			if em[j] == "," or em[j] == "." then
				j = j + 1
			else
				fail = true
				break
			end
		elseif b == "¡­" and ct[i - 1] ~= "¡­" then
			if em[j] and #em[j] > 1 then
				j = j + 1
			else
				fail = true
				break
			end
		elseif b == " " then
			ct[i] = trans[em[j]]
			j = j + 1
		end
	end
	if j ~= #em + 1 then
		fail = true
	end
	if not fail then
		c = concat(ct)
	end
	return cc and (c .. " " .. cc) or c
end

local lines = {}
local checks = {}
local n, s, e = 0, 0
for line in io.lines(arg[1]) do
	i = i + 1
	if line:find "^> " then
		s, e = 1
	elseif s == 1 then
		if not e then
			if line:sub(1, 1) ~= '"' then
				e = line
			else
				s, e = 0
			end
		else
			if line:sub(1, 1) ~= '"' then
				local line1 = fixMark(e, fix(e, line, i), i)
				if line1 ~= line then
					line = line1
					n = n + 1
				end
				local ce = checks[e]
				if not ce then
					local c = line:gsub(" *{[^{}]*}$", "")
					checks[e] = c
					if select(2, c:gsub("([\x80-\xff] [\x80-\xff])", "%1")) >= 10 then
						print("WARN: too many space in translation: " .. c)
					end
				elseif ce ~= line:gsub(" *{[^{}]*}$", "") and #e > 11 then
					print("WARN: unmatched translation: " .. e .. "\n" .. ce .. "\n" .. line .. "\n")
				end
			end
			s, e = 0
		end
	end
	lines[#lines + 1] = line
end

if n > 0 then
	local f = io.open(arg[1], "wb")
	f:write(concat(lines, "\r\n"), "\r\n")
	f:close()
end
print("done! (" .. n .. " fixed)")
