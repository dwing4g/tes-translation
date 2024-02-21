-- luajit tes3fix.lua tes3cn_Morrowind.ext.txt

local io = io
local arg = arg
local print = print

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
	["??"] = "£¿£¿",
	["?!"] = "£¿£¡",
	["!?"] = "£¡£¿",
	["!!"] = "£¡£¡",
	["???"] = "£¿£¿£¿",
	["!!!"] = "£¡£¡£¡",
	["!!!!"] = "£¡£¡£¡£¡",
	["!!!!!"] = "£¡£¡£¡£¡£¡",
	["!!!!!!"] = "£¡£¡£¡£¡£¡£¡",
	["?.."] = "£¿¡­",
	["?..."] = "£¿¡­",
	["?...."] = "£¿¡­¡­",
	["?....."] = "£¿¡­¡­",
	["?......"] = "£¿¡­¡­",
}

local ignores = {
	["Numpad ,"] = true,
	["a.m."] = true,
	["p.m."] = true,
}

local i = 0

local function fix(e, c)
	if ignores[e] then
		return c
	end
	local cc = c:match "{[^{}]*}$"
	if cc then
		c = c:sub(1, -#cc - 1):gsub("[ \t]+$", "")
	end
	local ee = getEnd(e:gsub("[ \t]+$", ""))
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
			error("ERROR: unknown end: " .. ee)
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
				local line1 = fix(e, line)
				if line1 ~= line then
					line = line1
					n = n + 1
				end
				local ce = checks[e]
				if not ce then
					checks[e] = line:gsub(" *{[^{}]*}$", "")
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
	f:write(table.concat(lines, "\r\n"), "\r\n")
	f:close()
end
print("done! (" .. n .. " fixed)")
