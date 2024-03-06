-- luajit tes3ext.lua Morrowind.txt tes3cn_Morrowind.txt tes3cn_Morrowind.ext.txt

local io = io
local arg = arg
local type = type
local error = error
local ipairs = ipairs

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
for line in io.lines("topics.txt") do
	local k, v = line:match "%[(.-)%]%s*=>%s*%[(.-)%]"
	if k then
		topics[v] = k
	end
end

local function loadTxt(fn)
	local all = {}
	local t, k, v
	local i = 0

	local function addKV()
		local e = v:sub(-1, -1)
		if e ~= '"' and (e ~= ']' or k ~= "MGEF.INDX" and k ~= "SKIL.INDX") then
			error("ERROR: bad line end at line " .. i .. " in '" .. fn .. "'")
		end
		if e == '"' then v = v:sub(1, -2) end
		v = v:gsub("%$%$", "@TeS3ExTmArK@"):gsub("%$00.*$", ""):gsub("@TeS3ExTmArK@", "$$")
		if t[k] then
			if k ~= "FACT.RNAM" and k ~= "FACT.ANAM" and k ~= "FACT.INTV" and k ~= "RACE.NPCS" and k ~= "BSGN.NPCS" then
				-- error("ERROR: duplicated key: '" .. k .. "'" .. " in '" .. fn .. "'")
			end
			if type(t[k]) ~= "table" then
				t[k] = {{ k, t[k] }}
			end
			t[k][#t[k] + 1] = { k, v }
		else
			t[k] = v
		end
		k, v = nil, nil
	end

	local function addTable()
		all[#all + 1] = t
		t = nil
	end

	for line in io.lines(fn) do
		i = i + 1
		local m = line:match "^ ([%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]%.[%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]) \""
		if m then
			if v then addKV() end
			k = m
			v = line:sub(13, -1):gsub('""', '"')
		else
			m = line:match "^ ([%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]%.[%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]) %["
			if m then
				if v then addKV() end
				if m == "SKIL.INDX" or m == "MGEF.INDX" then
					k = m
					v = line:sub(12, -1)
				end
				-- ignore
			else
				m = line:match "^%-([%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_])$"
				if not m then m = line:match "^%-([%u%d_<=>?:;@%z\x01-\x14][%u%d_][%u%d_][%u%d_]) %[" end
				if m then
					if v then addKV() end
					if t then addTable() end
					t = { [""] = m }
				else
					if not v then
						error("ERROR: bad line at line " .. i .. " in '" .. fn .. "'")
					end
					v = v .. "\r\n" .. line:gsub('""', '"')
				end
			end
		end
	end
	if v then addKV() end
	if t then addTable() end
	return all
end

local function extScr(line, p)
	line = "\n" .. line:gsub("(\"[^\r\n]+\")", function(s)
		return s:gsub(";", "@TeS3ExTmArK@")
	end):gsub(";[^\r\n]*", ""):gsub("@TeS3ExTmArK@", ";")
	local kk, vv, i, mi, si, ci = {}, {}, 0, 0, 0, 0
--	for s in line:gmatch '[Aa]dd[Tt]opic[%s,]+"?([^"%c]+)' do
--		ai = ai + 1
--		kk[i] = p .. "a" .. ai
--		vv[i] = s
--	end
	for str in line:gmatch '[Mm]essage[Bb]ox[%s,]+("[%C\t]+)' do
		for s in str:gmatch '"(.-)"' do
			i = i + 1
			mi = mi + 1
			kk[i] = p .. "m" .. mi
			vv[i] = s
		end
	end
	for str in line:gmatch '[Ss]ay[%s,]+("[%C\t]+)' do
		local j = false
		for s in str:gmatch '"(.-)"' do
			if j then -- skip first filename
				i = i + 1
				si = si + 1
				kk[i] = p .. "s" .. si
				vv[i] = s
			end
			j = true
		end
	end
	for str in line:gmatch '\n%s*[Cc]hoice[%s,:]+([%C\t]+)' do
		local j = false
		for s in str:gmatch '"(.-)"' do
			i = i + 1
			ci = ci + 1
			kk[i] = p .. "c" .. ci
			vv[i] = s
			j = true
		end
		if not j and not str:find '"' then
			for s in str:gmatch '(%a%S+)' do
				i = i + 1
				ci = ci + 1
				kk[i] = p .. "c" .. ci
				vv[i] = s
			end
		end
	end
	return kk, vv
end

local function extTxt(en)
	local et, es = {}, {}
	local function addKV(k, v)
		if k then
			if type(k) == "table" then
				for i = 1, #k do
					addKV(k[i], v[i])
				end
			elseif not v then
				error("ERROR: no v for key: '" .. k .. "'")
			elseif v:find "[%a\x80-\xff]" then
				if et[k] then
					warn("duplicated key: '", k, "'")
					-- error("ERROR: duplicated key: '" .. k .. "'")
				end
				et[k] = v
				es[#es + 1] = k
			end
		end
	end
	local k, v, kk, vv, dn
	for _, t in ipairs(en) do
		local tag = t[""]
			if tag == "ACTI" or tag == "ALCH" or tag == "APPA" or tag == "ARMO"
			or tag == "CLOT" or tag == "CONT" or tag == "CREA" or tag == "DOOR"
			or tag == "INGR" or tag == "LIGH" or tag == "LOCK" or tag == "MISC"
			or tag == "NPC_" or tag == "PROB" or tag == "REGN" or tag == "REPA"
			or tag == "SPEL" or tag == "WEAP" then -- special: SPEL.NAME "wulfharth$92s cups$00"
			k = tag .. ".FNAM " .. t[tag .. ".NAME"]
			v = t[tag .. ".FNAM"]
			if not v and (tag == "ACTI" or tag == "CLOT" or tag == "CONT" or tag == "DOOR" or tag == "LIGH" or tag == "MISC" or tag == "NPC_" or tag == "WEAP") then k = nil end
		elseif tag == "MGEF" or tag == "SKIL" then
			k = tag .. ".DESC " .. t[tag .. ".INDX"]
			v = t[tag .. ".DESC"]
			if not v and tag == "MGEF" then k = nil end
		elseif tag == "BSGN" or tag == "CLAS" or tag == "RACE" then
			k = tag .. ".FNAM " .. t[tag .. ".NAME"]
			v = t[tag .. ".FNAM"]
			if not v and tag == "CLAS" then k = nil end
			kk = tag .. ".DESC " .. t[tag .. ".NAME"]
			vv = t[tag .. ".DESC"]
			if not vv and tag == "CLAS" then kk = nil end
		elseif tag == "BOOK" then
			k = tag .. ".FNAM " .. t[tag .. ".NAME"]
			v = t[tag .. ".FNAM"]
			if not v then k = nil end
			kk = tag .. ".TEXT " .. t[tag .. ".NAME"]
			vv = t[tag .. ".TEXT"]
			if not vv then kk = nil end
		elseif tag == "GMST" then
			k = "GMST.STRV " ..  t["GMST.NAME"]
			v = t["GMST.STRV"]
			if not v then k = nil end
		elseif tag == "DIAL" then
			dn = t[tag .. ".NAME"]:lower()
			if topics[dn] then
				dn = topics[dn]
			end
		elseif tag == "INFO" then
			k = tag .. ".NAME " .. dn .. " " .. t[tag .. ".INAM"]
			v = t[tag .. ".NAME"]
			local tt = t[tag .. ".BNAM"]
			if tt then
				kk, vv = extScr(tt, "INFO.BNAM " .. dn .. " " .. t[tag .. ".INAM"] .. " ")
			end
			if not v then k = nil end
		elseif tag == "FACT" then
			k = tag .. ".FNAM " .. t[tag .. ".NAME"]
			v = t[tag .. ".FNAM"]
			local tt = t[tag .. ".RNAM"]
			if tt then
				if type(tt) == "table" then
					kk, vv = {}, {}
					for i = 1, #tt do
						kk[i] = tag .. ".RNAM " .. t[tag .. ".NAME"] .. " " .. i
						vv[i] = tt[i][2]
					end
				else
					kk = tag .. ".RNAM " .. t[tag .. ".NAME"] .. " 1"
					vv = tt
				end
			end
		elseif tag == "SCPT" then
			local tt = t[tag .. ".SCTX"]
			if tt then
				kk, vv = extScr(tt, "SCPT.SCTX " .. t["SCPT.SCHD"] .. " ")
			end
		elseif tag == "BODY" or tag == "ENCH" or tag == "GLOB" or tag == "LEVC"
			or tag == "LEVI" or tag == "LTEX" or tag == "SNDG" or tag == "SOUN"
			or tag == "STAT" or tag == "TES3" or tag == "SSCR" then
			-- ignore
		else
			error("ERROR: unknown tag: '" .. tag .. "'")
		end
		addKV(k, v)
		addKV(kk, vv)
		k, v, kk, vv = nil, nil, nil, nil
	end
	return et, es
end

local function escape(s)
	if s:find '"""' then
		error('ERROR: found """ in string: ' .. s .. "'")
	end
	if s:find "\n" or s == "" then
		s = '"""' .. s .. '"""'
	end
	return s
end

io.stderr:write("INFO: loading '", arg[1], "' ...\n")
local en = loadTxt(arg[1])
local et, es = extTxt(en)
en = nil

io.stderr:write("INFO: loading '", arg[2], "' ...\n")
local cn = loadTxt(arg[2])
local ct, cs = extTxt(cn)
cn = nil

-- local f = io.open("e.txt", "wb")
-- for _, k in ipairs(es) do
-- 	f:write("> ", k, "\r\n")
-- 	f:write(escape(et[k]), "\r\n\r\n")
-- end
-- f:close()

-- local f = io.open("c.txt", "wb")
-- for _, k in ipairs(cs) do
-- 	f:write("> ", k, "\r\n")
-- 	f:write(escape(ct[k]), "\r\n\r\n")
-- end
-- f:close()

local noTrans = {
	["SCPT.SCTX SoundTest m1"] = true,
	["SCPT.SCTX SoundTest m2"] = true,
	["SCPT.SCTX SoundTest m3"] = true,
	["SCPT.SCTX SoundTest m4"] = true,
	["SCPT.SCTX SoundTest m5"] = true,
	["SCPT.SCTX SoundTest m6"] = true,
	["SCPT.SCTX SoundTest m7"] = true,
	["SCPT.SCTX SoundTest m8"] = true,
	["SCPT.SCTX SoundTest m9"] = true,
	["SCPT.SCTX SoundTest m10"] = true,
	["SCPT.SCTX SoundTest m11"] = true,
	["SCPT.SCTX SoundTest m12"] = true,
	["SCPT.SCTX SoundTest m13"] = true,
	["SCPT.SCTX SoundTest m14"] = true,
	["SCPT.SCTX SoundTest m15"] = true,
	["BOOK.TEXT bk_nemindasorders"] = true,
	["BOOK.TEXT bk_ordersforbivaleteneran"] = true,
	["BOOK.TEXT bk_treasuryreport"] = true,
	["BOOK.TEXT bk_responsefromdivaythfyr"] = true,
	["BOOK.TEXT bk_EggOfTime"] = true,
	["BOOK.TEXT bk_BM_StoneMap"] = true,
	["INFO.NAME 11111 test journal 128914348295877816"] = true,
	["INFO.NAME 11111 test journal 32056462707524390"] = true,
}

io.stderr:write("INFO: writing '", arg[3], "' ...\n")
local f = io.open(arg[3], "wb")
for _, k in ipairs(es) do
	f:write("> ", k, "\r\n")
	local e, c = et[k], ct[k]
	f:write(escape(e), "\r\n")
	if c then
		ct[k] = nil
	else
		c = e
		warn("unmatched key '", k, "'")
	end
	f:write(e == c and not noTrans[k] and not k:find "^GMST.STRV" and (not e:find "^[%w]*_[%w_]*$" ) and "###" or escape(c), "\r\n\r\n")
end
f:close()

for _, k in ipairs(cs) do
	if ct[k] then
		warn("unused key '", k, "'")
	end
end

io.stderr:write("INFO: es = ", #es, "\n")
io.stderr:write("INFO: cs = ", #cs, "\n")
