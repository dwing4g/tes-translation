-- luajit tes3mod.lua Morrowind.txt tes3cn_Morrowind.ext.txt [topics.txt] tes3cn_Morrowind.txt

local io = io
local arg = arg
local error = error
local print = print
local table = table
local select = select

local newLine = true
local function warn(...)
	if not newLine then
		newLine = true
		io.stderr:write "\n"
	end
	io.stderr:write("WARN: ", ...)
	io.stderr:write "\n"
end

local topics = {}
for line in io.lines(#arg > 3 and arg[3] or "topics.txt") do
	local k, v = line:match "%[(.-)%]%s*=>%s*%[(.-)%]"
	if k then
		topics[k] = v
	end
end

local function readStr(line, isFirst)
	local s
	if isFirst then
		s = line:match '"(.*)$'
		if not s then
			s = line:match '(%[.*%])'
			if s then return s end
		end
		if not s then return "" end
		line = s
	end
	local p = line:gsub('""', '@@'):find '"'
	if p then
		return (line:sub(1, p - 1):gsub('""', '"'))
	end
	return (line:gsub('""', '"')), true
end

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

io.stderr:write("INFO: loading '", arg[2], "' ... ")
newLine = false
local trans = {}
local s, i, n = 0, 0, 0
local k, v1, v2 = nil, nil, nil
for line in io.lines(arg[2]) do
	i = i + 1
	if line ~= "" or s == 2 or s == 4 then
		if s == 0 then
			k = line:match "^> (.*)$"
			if not k then
				error("ERROR: require key line at line " .. i .. " in '" .. arg[2] .. "'")
			end
			s = 1
		else
			if line:find "^> " and s ~= 2 and s ~= 4 then
				error("ERROR: invalid key line at line " .. i .. " in '" .. arg[2] .. "'")
			end
			if s <= 2 then
				local t, r = readStrExt(line, s == 1)
				v1 = v1 and (v1 .. "\r\n" .. t) or t
				s = r and 2 or 3
			else
				local t, r = readStrExt(line, s == 3)
				v2 = v2 and (v2 .. "\r\n" .. t) or t
				if r then
					s = 4
				else
					if trans[k] then
						warn("duplicated key '", k, "' in '", arg[2], "'")
					end
					if v2 ~= "###" then
						local n1 = select(2, v1:gsub("([\r\n][\r\n ]*[^\r\n ])", "%1"))
						local n2 = select(2, v2:gsub("([\r\n][\r\n ]*[^\r\n ])", "%1"))
						local nd = n2 - n1
						if nd < 0 or nd > 1 then
							warn("unmatched lines(", nd, ") for translation: ", k) -- , "\n", v1, "\n", v2)
						end
						trans[k] = { v1, v2 }
						n = n + 1
					end
					s, k, v1, v2 = 0, nil, nil, nil
				end
			end
		end
	end
end
if s ~= 0 then
	error("ERROR: invalid eof in '" .. arg[2] .. "'")
end
print("[" .. n .. "]")
newLine = true

local kt = {
	["ACTI.NAME"] = true, ["ALCH.NAME"] = true, ["APPA.NAME"] = true, ["ARMO.NAME"] = true,
	["CLOT.NAME"] = true, ["CONT.NAME"] = true, ["CREA.NAME"] = true, ["DOOR.NAME"] = true,
	["INGR.NAME"] = true, ["LIGH.NAME"] = true, ["LOCK.NAME"] = true, ["MISC.NAME"] = true,
	["NPC_.NAME"] = true, ["PROB.NAME"] = true, ["REGN.NAME"] = true, ["REPA.NAME"] = true,
	["SPEL.NAME"] = true, ["WEAP.NAME"] = true,
	["MGEF.INDX"] = true, ["SKIL.INDX"] = true,
	["BSGN.NAME"] = true, ["CLAS.NAME"] = true, ["RACE.NAME"] = true,
	["BOOK.NAME"] = true,
	["GMST.NAME"] = true,
	["FACT.NAME"] = true,
	["INFO.INAM"] = true,
	["SCPT.SCHD"] = true,
}

local vt = {
	["ACTI.FNAM"] = true, ["ALCH.FNAM"] = true, ["APPA.FNAM"] = true, ["ARMO.FNAM"] = true,
	["CLOT.FNAM"] = true, ["CONT.FNAM"] = true, ["CREA.FNAM"] = true, ["DOOR.FNAM"] = true,
	["INGR.FNAM"] = true, ["LIGH.FNAM"] = true, ["LOCK.FNAM"] = true, ["MISC.FNAM"] = true,
	["NPC_.FNAM"] = true, ["PROB.FNAM"] = true, ["REGN.FNAM"] = true, ["REPA.FNAM"] = true,
	["SPEL.FNAM"] = true, ["WEAP.FNAM"] = true,
	["MGEF.DESC"] = true, ["SKIL.DESC"] = true,
	["BSGN.FNAM"] = true, ["CLAS.FNAM"] = true, ["RACE.FNAM"] = true,
	["BSGN.DESC"] = true, ["CLAS.DESC"] = true, ["RACE.DESC"] = true,
	["BOOK.FNAM"] = true,
	["BOOK.TEXT"] = true,
	["GMST.STRV"] = true,
	["FACT.FNAM"] = true, ["FACT.RNAM"] = true,
	["INFO.NAME"] = true,
}

io.stderr:write("INFO: modify '", arg[1], "' => '", arg[#arg], "' ... ")
newLine = false
local f = io.open(arg[#arg], "wb")
i, n = 0, 0
local function modScr(line, p, lineId)
	local lines = {}
	local i, mi, si, ci = 1, 0, 0, 0
	while i ~= 0 do
		local p = line:find("\n", i) or -1
		lines[#lines + 1] = line:sub(i, p)
		i = p + 1
	end
	for i = 1, #lines do
		line = lines[i]
		line = line:gsub("(\"[^\r\n]+\")", function(s)
			return s:gsub(";", "@TeS3ModmArK@")
		end)
		local t, e = line:match "^(.-)(;.*)$"
		if t then
			line = t
			e = e:gsub("@TeS3ModmArK@", ";")
		else
			e = ""
		end
		line = line:gsub("@TeS3ModmArK@", ";")
		line = line:gsub('([Aa]dd[Tt]opic[%s,]+)(%C+)', function(pre, str)
			local first = true
			str = str:gsub('"(.-)"', function(s)
				first = false
				local t = topics[s:lower()]
				if t then
					s = t
				else
					warn("not found topic '", s, "' at line ", lineId, " in '", arg[1], "'")
				end
				return '"' .. s .. '"'
			end)
			if first and not str:find '"' then
				str = str:gsub('(%S+)', function(s)
					local t = topics[s:lower()]
					if t then
						s = t
					else
						warn("not found topic '", s, "' at line ", lineId, " in '", arg[1], "'")
					end
					return '"' .. s .. '"'
				end)
			end
			return pre .. str
		end)
		line = line:gsub('([Mm]essage[Bb]ox[%s,]+)("[%C\t]+)', function(pre, str)
			return pre .. str:gsub('"(.-)"', function(s)
				if s:find "[%w\x80-\xff]" then
					mi = mi + 1
					local k = p .. "m" .. mi
					local t = trans[k]
					trans[k] = nil
					n = n + 1
					if t then
						if s == t[1] then
							s = t[2]
						else
							warn("unmatched translation key '", k, "' at line ", lineId, " in '", arg[1], '\':\n"""', s, '"""\n"""', t[1], '"""')
						end
					else
						warn("not found translation key '", k, "' at line ", lineId, " in '", arg[1], "'")
					end
				end
				return '"' .. s .. '"'
			end)
		end)
		line = line:gsub('([Ss]ay[%s,]+)("[%C\t]+)', function(pre, str)
			local first = true
			return pre .. str:gsub('"(.-)"', function(s)
				if first then
					first = false
				elseif s:find "[%w\x80-\xff]" then
					si = si + 1
					local k = p .. "s" .. si
					local t = trans[k]
					trans[k] = nil
					n = n + 1
					if t then
						if s == t[1] then
							s = t[2]
						else
							warn("unmatched translation key '", k, "' at line ", lineId, " in '", arg[1], '\':\n"""', s, '"""\n"""', t[1], '"""')
						end
					else
						warn("not found translation key '", k, "' at line ", lineId, " in '", arg[1], "'")
					end
				end
				return '"' .. s .. '"'
			end)
		end)
		line = line:gsub('^(%s*[Cc]hoice[%s,:]+)([%C\t]+)', function(pre, str)
			local first = true
			str = str:gsub('"(.-)"', function(s)
				first = false
				if s:find "[%w\x80-\xff]" then
					ci = ci + 1
					local k = p .. "c" .. ci
					local t = trans[k]
					trans[k] = nil
					n = n + 1
					if t then
						if s == t[1] then
							s = t[2]
						else
							warn("unmatched translation key '", k, "' at line ", lineId, " in '", arg[1], '\':\n"""', s, '"""\n"""', t[1], '"""')
						end
					else
						warn("not found translation key '", k, "' at line ", lineId, " in '", arg[1], "'")
					end
				end
				return '"' .. s .. '"'
			end)
			if first and not str:find '"' then
				str = str:gsub('([%a\x80-\xff]%S+)', function(s)
					ci = ci + 1
					local k = p .. "c" .. ci
					local t = trans[k]
					trans[k] = nil
					n = n + 1
					if t then
						if s == t[1] then
							s = t[2]
						else
							warn("unmatched translation key '", k, "' at line ", lineId, " in '", arg[1], '\':\n"""', s, '"""\n"""', t[1], '"""')
						end
					else
						warn("not found translation key '", k, "' at line ", lineId, " in '", arg[1], "'")
					end
					return '"' .. s .. '"'
				end)
			end
			return pre .. str
		end)
		lines[i] = line .. e
	end
	return table.concat(lines)
end
local k, v, t, r, tag, d, dl, fid
for line in io.lines(arg[1]) do
	i = i + 1
	if not v then
		tag = line:match "^ ([%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]%.[%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]) \""
		if not tag then
			tag = line:match "^ ([%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]%.[%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]) %["
		end
		r = nil
	else
		t, r = readStr(line)
		v = v .. "\r\n" .. t
		if r then line = nil end
	end
	if not r and tag then
		if kt[tag] then
			k, r = readStr(line, true)
			if r then
				error("ERROR: not single line key at line " .. i .. " in '" .. arg[1] .. "'")
			end
			k = k:gsub("%$%$", "@TeS3ModmArK@"):gsub("%$00.*$", ""):gsub("@TeS3ModmArK@", "$$")
			if tag == "INFO.INAM" then
				if not d then
					error("ERROR: not found DIAG.NAME before INFO at line " .. i .. " in '" .. arg[1] .. "'")
				end
				k = d .. " " .. k
			elseif tag == "FACT.NAME" then
				fid = 0
			end
		elseif vt[tag] then
			if not v then
				v, r = readStr(line, true)
			end
			if not r then
				local e = (v:gsub("%$%$", "@TeS3ModmArK@"):match "(%$00.*)$" or ""):gsub("@TeS3ModmArK@", "$$")
				if e ~= "" then v = v:sub(1, -1 - #e) end
				if v:find "[%w\x80-\xff]" then
					local kk = tag .. " " .. k
					if tag == "FACT.RNAM" then
						fid = fid + 1
						kk = tag .. " " .. k .. " " .. fid
					end
					t = trans[kk]
					trans[kk] = nil
					n = n + 1
					if t then
						if v == t[1] then
							v = t[2]
						else
							warn("unmatched translation key '", kk, "' at line ", i, " in '", arg[1], '\':\n"""', v, '"""\n"""', t[1], '"""')
						end
					else
						warn("not found translation key '", kk, "' at line ", i, " in '", arg[1], "'")
					end
				end
				line = " " .. tag .. ' "' .. (v .. e):gsub('"', '""') .. '"'
				v = nil
			else
				line = nil
			end
		elseif tag == "DIAL.NAME" then
			d, r = readStr(line, true)
			if r then
				error("ERROR: not single line DIAL.NAME at line " .. i .. " in '" .. arg[1] .. "'")
			end
			d = d:gsub("%$%$", "@TeS3ModmArK@"):gsub("%$00.*$", ""):gsub("@TeS3ModmArK@", "$$"):lower()
			dl, line = line, nil
		elseif tag == "DIAL.DATA" then
			if line:find "%[00%]" then
				dl = dl:gsub('"(.-)([%$"])', function(s, e)
					local t = topics[s:lower()]
					if t then
						s = t
					else
						warn("not found topic '", s, "' at line ", i, " in '", arg[1], "'")
					end
					return '"' .. s .. e
				end)
			end
			line = dl .. "\r\n" .. line
			dl = nil
		elseif tag == "INFO.BNAM" or tag == "SCPT.SCTX" then
			if not v then
				v, r = readStr(line, true)
			end
			if not r then
				v = modScr(v, tag .. " " .. k .. " ", i)
				line = " " .. tag .. ' "' .. v:gsub('"', '""') .. '"'
				v = nil
			else
				line = nil
			end
		end
	end
	if line then
		f:write(line, "\r\n")
	end
end
f:close()
if v then
	error("ERROR: invalid eof in '" .. arg[1] .. "'")
end
print("[" .. n .. "]")
newLine = true
for k, t in pairs(trans) do
	warn("unused key: '", k, "'")
end
