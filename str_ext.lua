-- luajit str_ext.lua skyrim.txt skyrim_english skyrim_chinese skyrim.ext.txt

local function loadStrings(fn)
	local t = {}
	local lastK
	for line in io.lines(fn) do
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
	['ACTI.FULL'] = strings,
	['ACTI.RNAM'] = strings,
	['ALCH.FULL'] = strings,
	['AMMO.FULL'] = strings,
	['APPA.FULL'] = strings,
	['ARMO.FULL'] = strings,
	['AVIF.FULL'] = strings,
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
	['PERK.EPFD'] = strings,
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

	['INFO.NAM1'] = ilstrings,

	['ARMO.DESC'] = dlstrings,
	['AVIF.DESC'] = dlstrings,
	['BOOK.CNAM'] = dlstrings,
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
}

local i = 0
local function addEscape(s)
	if not s then return '<NA>' end
	s = s:gsub('\r', '')
	if s:find '"""' then
		error(i .. ': found """ in string: ' .. s)
	end
	return s:find '\n' and ('"""' .. s .. '"""') or s
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

local f = io.open(arg[4], 'wb')
local idTag, id
for line in io.lines(arg[1]) do
	i = i + 1
	local k, v = line:match '^%s*([%w_]+%.[%w_]+)%s+(["%[].*["%]])%s*$'
	if k then
		local strs = tags[k]
		if strs then
			if not idTag or idTag:sub(1,4) ~= k:sub(1,4) then
				error(i .. ': unmatch tag: ' .. (idTag or '<nil>') .. ' != ' .. k)
			end
			local idx = hexToInt(v)
			local e, c = strs[1][idx], strs[2][idx]
			if e or c then
				strs[4][idx] = true
				f:write('> ', k, ' ', id, ' <', strs[3], idx, '>\n', addEscape(e), '\n', addEscape(c), '\n\n')
			end
		elseif k:sub(-5, -1) == '.EDID' then
			idTag = k
			id = v:gsub('^["%[]', ''):gsub('["%]]$', ''):gsub('%$00$', '')
		end
	elseif line:sub(1, 1) == '-' then
		k, v = line:match '^%-([%w_]+)%s+%[%x+%s+%x+%s+%x+%s+%x+%s+(%x+%s+%x+%s+%x+%s+%x+)'
		if k then
			idTag = k
			id = '<' .. hexToInt(v) .. '>'
		end
	end
end
f:close()

local function check(t, name)
	for k, v in pairs(t[1]) do
		if not t[4][k] then
			print('WARN: unused in ' .. name .. ': ' .. k .. ': ' .. v)
		end
	end
end
check(strings  , 'strings')
check(ilstrings, 'ilstrings')
check(dlstrings, 'dlstrings')

print 'done!'
