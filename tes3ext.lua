-- luajit tes3ext.lua Morrowind.txt tes3cn_Morrowind.txt tes3cn_Morrowind.ext.txt

local io = io
local arg = arg
local type = type
local error = error
local ipairs = ipairs

local topics = {}
for line in io.lines("topics.txt") do
	local k, v = line:match "%[(.-)%] => %[(.-)%]"
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
		if t[k] then
			if k ~= "FACT.RNAM" and k ~= "FACT.ANAM" and k ~= "FACT.INTV" and k ~= "RACE.NPCS" and k ~= "BSGN.NPCS" then
				-- error("ERROR: duplicated key: '" .. k .. "'" .. " in '" .. fn .. "'")
			end
			if type(t[k]) ~= "table" then
				t[k] = {{ k, t[k] }}
			end
			t[k][#t[k] + 1] = { k, v:gsub('""', '"'):gsub("%$00.*$", "") }
		else
			t[k] = v:gsub('""', '"'):gsub("%$00.*$", "")
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
			v = line:sub(13, -1)
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
					v = v .. "\n" .. line
				end
			end
		end
	end
	if v then addKV() end
	if t then addTable() end
	return all
end

local function extTxt(en)
	local et, es = {}, {}
	local function addKV(k, v)
		if k then
			if type(k) == "table" then
				for i = 1, #k do
					addKV(k[i], v[i])
				end
			else
				if et[k] then
					io.stderr:write("WARN: duplicated key: '", k, "'\n")
					-- error("ERROR: duplicated key: '" .. k .. "'")
				end
				if not v then
					error("ERROR: no v for key: '" .. k .. "'")
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
			if not v and (tag == "ACTI" or tag == "CLOT" or tag == "DOOR" or tag == "LIGH" or tag == "MISC" or tag == "WEAP") then k = nil end
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
			kk = tag .. ".TEXT " .. t[tag .. ".NAME"]
			vv = t[tag .. ".TEXT"]
			if not vv then kk = nil end
		elseif tag == "GMST" then
			k = "GMST " ..  t["GMST.NAME"]
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
			local p = tag .. ".NAME " .. t[tag .. ".SCHD"]:gsub("%$00.*$", "") .. " "
			local tt = t[tag .. ".SCTX"]
			local i = 0
			kk, vv = {}, {}
			for line in tt:gmatch "[Aa]dd[Tt]opic[%s,]+(.-)[\r\n]" do
				local str = line:match "\"(.-)\""
				i = i + 1
				kk[i] = p .. i
				vv[i] = str
			end
			for line in tt:gmatch "[Mm]essage[Bb]ox[%s,]+(.-)[\r\n]" do
				for str in line:gmatch "\"(.-)\"" do
					i = i + 1
					kk[i] = p .. i
					vv[i] = str
				end
			end
			for line in tt:gmatch "[Ss]ay[%s,]+(.-)[\r\n]" do
				local j = false
				for str in line:gmatch "\"(.-)\"" do
					if j then -- skip first filename
						i = i + 1
						kk[i] = p .. i
						vv[i] = str
					end
					j = true
				end
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
	s = s:gsub('\\', '\\\\'):gsub('"', '\\"')
	if s:find "\n" then
		s = '"' .. s .. '"'
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

io.stderr:write("INFO: writing '", arg[3], "' ...\n")
local f = io.open(arg[3], "wb")
for _, k in ipairs(es) do
	f:write("> ", k, "\r\n")
	f:write(escape(et[k]), "\r\n")
	if ct[k] then
		f:write(escape(ct[k]), "\r\n\r\n")
		ct[k] = nil
	else
		f:write("###\r\n\r\n")
		io.stderr:write("WARN: unmatched key '", k, "'\n")
	end
end
f:close()

for _, k in ipairs(cs) do
	if ct[k] then
		io.stderr:write("WARN: unused key '", k, "'\n")
	end
end

io.stderr:write("INFO: es = ", #es, "\n")
io.stderr:write("INFO: cs = ", #cs, "\n")
