-- for %a in (*.esm)    do luajit ../tes3dec.lua %a 1252 raw > %~na.txt
-- for %a in (*strings) do luajit ../str_dec.lua %a %a.txt
-- check and change *_en.*strings.txt to utf-8

-- luajit ../str_ext.lua Skyrim.txt      skyrim_english      skyrim_chinese      Skyrim.ext.txt
-- luajit ../str_ext.lua Dawnguard.txt   dawnguard_english   dawnguard_chinese   Dawnguard.ext.txt
-- luajit ../str_ext.lua Dragonborn.txt  dragonborn_english  dragonborn_chinese  Dragonborn.ext.txt
-- luajit ../str_ext.lua HearthFires.txt hearthfires_english hearthfires_chinese HearthFires.ext.txt

-- luajit ../str_ext.lua Fallout4.txt      Fallout4_en      Fallout4_cn      Fallout4.ext.txt
-- luajit ../str_ext.lua DLCCoast.txt      DLCCoast_en      DLCCoast_cn      DLCCoast.ext.txt
-- luajit ../str_ext.lua DLCNukaWorld.txt  DLCNukaWorld_en  DLCNukaWorld_cn  DLCNukaWorld.ext.txt
-- luajit ../str_ext.lua DLCRobot.txt      DLCRobot_en      DLCRobot_cn      DLCRobot.ext.txt
-- luajit ../str_ext.lua DLCworkshop01.txt DLCworkshop01_en DLCworkshop01_cn DLCworkshop01.ext.txt
-- luajit ../str_ext.lua DLCworkshop02.txt DLCworkshop02_en DLCworkshop02_cn DLCworkshop02.ext.txt
-- luajit ../str_ext.lua DLCworkshop03.txt DLCworkshop03_en DLCworkshop03_cn DLCworkshop03.ext.txt

-- luajit ../str_ext.lua Starfield.txt starfield_en starfield_zhhans Starfield.ext.txt

-- luajit ../str_ext.lua LondonWorldSpace.txt - - LondonWorldSpace.chs.ext.txt

local starfield = arg[1]:find '[Ss]tar[Ff]ield'

local function loadStrings(fn)
	if fn:find '^%-' then return false end
	local t = {}
	local lastK
	for line in io.lines(fn) do
		line = line:gsub('\r+', '')
		local k, v = line:match '^<(%d+)> (.*)$'
		if k then
			lastK = tonumber(k)
			t[lastK] = v
		elseif lastK then
			t[lastK] = t[lastK] .. '\n' .. line
		else
			error('loadStrings(' .. fn .. '): invalid line: ' .. line)
		end
	end
	return t
end

local   strings = { loadStrings(arg[2] ..   '.strings.txt'), loadStrings(arg[3] ..   '.strings.txt'), '' , {} }
local ilstrings = { loadStrings(arg[2] .. '.ilstrings.txt'), loadStrings(arg[3] .. '.ilstrings.txt'), 'i', {} }
local dlstrings = { loadStrings(arg[2] .. '.dlstrings.txt'), loadStrings(arg[3] .. '.dlstrings.txt'), 'd', {} }

local tags = {
	-- Skyrim
	['ACTI.FULL'] = strings,
	['ACTI.RNAM'] = strings,
	['ALCH.FULL'] = strings,
	['AMMO.FULL'] = strings,
	['APPA.FULL'] = strings,
	['ARMO.FULL'] = strings,
	['AVIF.ANAM'] = strings,
	['AVIF.FULL'] = strings,
	['BOOK.CNAM'] = strings,
	['BOOK.FULL'] = strings,
	['BPTD.BPTN'] = strings,
	['CELL.FULL'] = strings,
	['CLAS.FULL'] = strings,
	['CLFM.FULL'] = strings,
	['CONT.FULL'] = strings,
	['DIAL.FULL'] = strings,
	['DOOR.FULL'] = strings,
	['ENCH.FULL'] = strings,
	['EXPL.FULL'] = strings,
	['EYES.FULL'] = strings,
	['FACT.FNAM'] = strings,
	['FACT.FULL'] = strings,
	['FACT.MNAM'] = strings,
	['FLOR.FULL'] = strings,
	['FLOR.RNAM'] = strings,
	['FURN.FULL'] = strings,
	['GMST.DATA'] = strings,
	['HAZD.FULL'] = strings,
	['HDPT.FULL'] = strings,
	['INFO.RNAM'] = strings,
	['INGR.FULL'] = strings,
	['KEYM.FULL'] = strings,
	['LCTN.FULL'] = strings,
	['LIGH.FULL'] = strings,
	['LSCR.DESC'] = strings,
	['MESG.FULL'] = strings,
	['MESG.ITXT'] = strings,
	['MGEF.DNAM'] = strings,
	['MGEF.FULL'] = strings,
	['MISC.FULL'] = strings,
	['NPC_.FULL'] = strings,
	['NPC_.SHRT'] = strings,
	['PERK.EPF2'] = strings,
	['PERK.EPFD'] = starfield and strings or nil,
	['PERK.FULL'] = strings,
	['PROJ.FULL'] = strings,
	['QUST.FULL'] = strings,
	['QUST.NNAM'] = strings,
	['RACE.FULL'] = strings,
	['REFR.FULL'] = strings,
	['REGN.RDMP'] = strings,
	['SCRL.FULL'] = strings,
	['SHOU.FULL'] = strings,
	['SLGM.FULL'] = strings,
	['SNCT.FULL'] = strings,
	['SPEL.FULL'] = strings,
	['TACT.FULL'] = strings,
	['TREE.FULL'] = strings,
	['WATR.FULL'] = strings,
	['WEAP.FULL'] = strings,
	['WOOP.FULL'] = strings,
	['WOOP.TNAM'] = strings,
	['WRLD.FULL'] = strings,
	-- Fallout4 addons
	['ACTI.ATTX'] = strings,
	['ALCH.DNAM'] = strings,
	['AMMO.ONAM'] = strings,
	['CMPO.FULL'] = strings,
	['DOOR.CNAM'] = strings,
	['DOOR.ONAM'] = strings,
	['FLOR.ATTX'] = strings,
	['FLST.FULL'] = strings,
	['FURN.ATTX'] = strings,
	['INNR.WNAM'] = strings,
	['KYWD.FULL'] = strings,
	['LVLI.ONAM'] = strings,
	['MESG.NNAM'] = strings,
	['MSTT.FULL'] = strings,
	['NOTE.FULL'] = strings,
	['NPC_.ATTX'] = strings,
	['OMOD.FULL'] = strings,
	['RACE.FMRN'] = strings,
	['RACE.MPPN'] = strings,
	['RACE.TTGP'] = strings,
	['SCOL.FULL'] = strings,
	['STAT.FULL'] = strings,
	['TERM.BTXT'] = strings,
	['TERM.FULL'] = strings,
	['TERM.ITXT'] = strings,
	['TERM.NAM0'] = strings,
	['TERM.RNAM'] = strings,
	['TERM.UNAM'] = strings,
	['TERM.WNAM'] = strings,
	-- Starfield addons
	['BIOM.FULL'] = strings,
	['BOOK.ENAM'] = strings,
	['BOOK.FNAM'] = strings,
	['CHAL.FULL'] = strings,
	['DMGT.FULL'] = strings,
	['GBFM.FULL'] = strings,
	['GBFM.HULL'] = strings,
	['IDLE.FULL'] = strings,
	['IRES.FULL'] = strings,
	['IRES.NNAM'] = strings,
	['LVLN.ONAM'] = strings,
	['MISC.NNAM'] = strings,
	['NPC_.LNAM'] = strings,
	['PKIN.FULL'] = strings,
	['PMFT.FULL'] = strings,
	['PNDT.FULL'] = strings,
	['QUST.QMDP'] = strings,
	['QUST.QMDS'] = strings,
	['QUST.QMDT'] = strings,
	['QUST.QMSU'] = strings,
	['RACE.FDSL'] = strings,
	['RACE.SNAM'] = strings,
	['REFR.UNAM'] = strings,
	['RSPJ.FULL'] = strings,
	['STDT.FULL'] = strings,
	['TMLM.BTXT'] = strings,
	['TMLM.FULL'] = strings,
	['TMLM.INAM'] = strings,
	['TMLM.ISTX'] = strings,
	['TMLM.ITXT'] = strings,
	['TMLM.UNAM'] = strings,
	['WEAP.WABB'] = strings,

	['INFO.NAM1'] = ilstrings,

	-- Skyrim
	['AMMO.DESC'] = dlstrings,
	['ARMO.DESC'] = dlstrings,
	['AVIF.DESC'] = dlstrings,
	['BOOK.DESC'] = dlstrings,
	['COLL.DESC'] = dlstrings,
	['MESG.DESC'] = dlstrings,
	['PERK.DESC'] = dlstrings,
	['QUST.CNAM'] = dlstrings,
	['RACE.DESC'] = dlstrings,
	['SCRL.DESC'] = dlstrings,
	['SHOU.DESC'] = dlstrings,
	['SPEL.DESC'] = dlstrings,
	['WEAP.DESC'] = dlstrings,
	-- Fallout4 addons
	['ALCH.DESC'] = dlstrings,
	['COBJ.DESC'] = dlstrings,
	['OMOD.DESC'] = dlstrings,
	-- Starfield addons
	['CHAL.DESC'] = dlstrings,
	['RSPJ.DESC'] = dlstrings,
}

local multiLineMark = "'''"
local i = 0
local function addEscape(s)
	if not s then return '<NA>' end
	s = s:gsub('\r+', '')
	if s:find(multiLineMark, 1, true) then
		error(i .. ': found ' .. multiLineMark .. ' in string: ' .. s)
	end
	return s:find '%c' and (multiLineMark .. s .. multiLineMark) or s
end
local function hexToInt(s)
	local r, f = 0, 1
	local t = s:match '^"(.*)"$'
	if t then
		local i = 1
		while i <= #t do
			local b = t:byte(i)
			if b == 0x24 then -- '$'
				local v
				if t:byte(i+1) == 0x24 then -- '$'
					v = 0x24
					i = i + 2
				else
					v = tonumber(t:sub(i+1,i+2), 16)
					if not v then error(i .. ': invalid hex: ' .. s) end
					i = i + 3
				end
				r = r + v * f
			elseif b == 0x22 then -- '"'
				if t:byte(i+1) ~= 0x22 then -- '"'
					error(i .. ': invalid hex: ' .. s)
				end
				r = r + 0x22 * f
				i = i + 2
			else
				r = r + b * f
				i = i + 1
			end
			f = f * 256
		end
	else
		for b in s:gmatch '%x%x' do
			r = r + tonumber(b, 16) * f
			f = f * 256
		end
	end
	return r
end
local function getStr(t, idx, s)
	if t then
		return t[idx]
	end
	local t = {}
	if s:find '^"' then
		local i, b, n = 2, 2, #s
		while i <= n do
			local c = s:byte(i)
			if c == 0x22 then -- "
				if i + 1 <= n and s:byte(i + 1) == 0x22 then
					if b < i then t[#t + 1] = s:sub(b, i - 1) end
					i = i + 1
					b = i
				else
					break
				end
			elseif c == 0x24 then -- $
				if b < i then t[#t + 1] = s:sub(b, i - 1) end
				local d = s:sub(i + 1, i + 2)
				if d:find '%x%x' then
					t[#t + 1] = string.char(tonumber(d, 16))
					i = i + 2
					b = i + 1
				else
					i = i + 1
					b = i
				end
			end
			i = i + 1
		end
		if b < i then t[#t + 1] = s:sub(b, i - 1) end
	else
		for b in s:gmatch '%x%x' do
			t[#t + 1] = string.char(tonumber(b, 16))
		end
	end
	s = table.concat(t):gsub('%z$', '')
	return s:find '%z' and '' or s
end

local f = io.open(arg[4], 'wb')
local idTag, id, n, k, v
for line in io.lines(arg[1]) do
	line = line:gsub('\r+', '')
	i = i + 1
	if not k then
		k, v = line:match '^%s*([%w_]+%.[%w_]+)%s+(["%[].*)$'
	else
		v = v .. '\n' .. line
	end
	if k then
		if v:sub(2, -1):gsub('""', '@'):find '["%]]$' then
			local strs = tags[k]
			if strs then
				if not idTag or idTag:sub(1,4) ~= k:sub(1,4) then
					error(i .. ': unmatch tag: ' .. (idTag or '<nil>') .. ' != ' .. k)
				end
				local idx = strs[1] and hexToInt(v)
				local e, c = getStr(strs[1], idx, v), getStr(strs[2], idx, v)
				if e and e ~= '' or c and c ~= '' then
					strs[4][idx] = true
					if idx then
						f:write('> ', k, ' ', id, ' <', strs[3], idx, '>\n', addEscape(e), '\n', addEscape(c), '\n\n')
					elseif n == 0 then
						f:write('> ', k, ' ', id, '\n', addEscape(e), '\n', addEscape(c), '\n\n')
					else
						f:write('> ', k, ' ', id, ' <', n, '>\n', addEscape(e), '\n', addEscape(c), '\n\n')
					end
					n = n + 1
				end
			elseif k:sub(-5, -1) == '.EDID' then
				idTag = k
				id = v:gsub('^["%[]', ''):gsub('["%]]$', ''):gsub('%$00$', '')
				n = 0
			end
			k = nil
		end
	elseif line:sub(1, 1) == '-' then
		k, v = line:match '^%-([%w_]+)%s+%[%x+%s+%x+%s+%x+%s+%x+%s+(%x+%s+%x+%s+%x+%s+%x+)'
		if k then
			idTag = k
			id = '<' .. hexToInt(v) .. '>'
			n = 0
			k = nil
		end
	end
end

local function check(t, name)
	if not t[1] then return end
	local n = 0
	local st = {}
	for k in pairs(t[1]) do
		if not t[4][k] then
			st[#st + 1] = k
		end
		n = n + 1
	end
	table.sort(st)
	for _, k in ipairs(st) do
		local e, c = t[1][k], t[2][k]
		print('WARN: unused in ' .. name .. ': ' .. k .. ': ' .. e)
		f:write('> ****.**** <', t[3], k, '>\n', addEscape(e), '\n', addEscape(c), '\n\n')
	end
	print('INFO: ' .. (n - #st) .. '/' .. n .. ' ' .. name)
end
check(strings  , 'strings')
check(ilstrings, 'ilstrings')
check(dlstrings, 'dlstrings')
f:close()

print 'done!'
