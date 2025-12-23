-- luajit str_mux.lua LondonWorldSpace.en.ext.txt LondonWorldSpace.chs.ext.txt LondonWorldSpace.ext.txt

local newLine = true
local function warn(...)
	if not newLine then
		newLine = true
		io.stderr:write '\n'
	end
	io.stderr:write('WARN: ', ...)
	io.stderr:write '\n'
end

local multiLineMark = "'''"
local multiLineMarkR = multiLineMark:reverse()
local function addEscape(s)
	if not s then return '<NA>' end
	s = s:gsub('\r+', '')
	if s:find(multiLineMark, 1, true) then
		error('found ' .. multiLineMark .. ' in string: ' .. s)
	end
	return s:find '%c' and (multiLineMark .. s .. multiLineMark) or s
end
local function readStrExt(line, isFirstLine)
	if isFirstLine then
		if line:sub(1, 3) ~= multiLineMark then
			return line
		end
		line = line:sub(4, -1)
	end
	local p = line:reverse():find(multiLineMarkR, 1, true)
	if p then
		return line:sub(1, -p - 3)
	end
	return line, true
end
local function loadExt(fn, func)
	io.stderr:write('INFO: loading "', fn, '" ... ')
	newLine = false
	local s, i, n = 0, 0, 0
	local k, v1, v2 = nil, nil, nil
	for line in io.lines(fn) do
		line = line:gsub('\r+', '')
		i = i + 1
		if line ~= '' or s == 2 or s == 4 then
			if s == 0 then
				k = line:match '^> (.*)$'
				if not k then
					error('ERROR: require key line at line ' .. i .. ' in "' .. fn .. '"')
				end
				s = 1
			else
				if line:find '^> ' and s ~= 2 and s ~= 4 then
					-- error('ERROR: invalid key line at line ' .. i .. ' in "' .. fn .. '"')
				end
				if s <= 2 then
					local t, r = readStrExt(line, s == 1)
					v1 = v1 and (v1 .. '\n' .. t) or t
					s = r and 2 or 3
				else
					local t, r = readStrExt(line, s == 3)
					v2 = v2 and (v2 .. '\n' .. t) or t
					if r then
						s = 4
					else
						if v2 ~= '###' then
							local n1 = select(2, v1:gsub('([\r\n][\r\n ]*[^\r\n ])', '%1'))
							local n2 = select(2, v2:gsub('([\r\n][\r\n ]*[^\r\n ])', '%1'))
							local nd = n2 - n1
							if nd < 0 or nd > 1 then
								warn('unmatched lines(', nd, ') for translation: ', k) -- , '\n', v1, '\n', v2)
							end
							func(k, v1, v2)
							n = n + 1
						end
						s, k, v1, v2 = 0, nil, nil, nil
					end
				end
			end
		end
	end
	if s ~= 0 then
		error('ERROR: invalid eof in "' .. fn .. '"')
	end
	print('[' .. n .. ']')
	newLine = true
end

local trans = {}
loadExt(arg[2], function(k, v1, v2)
	if trans[k] then
		warn('duplicated key "', k, '" in "', arg[2], '"')
	else
		trans[k] = v2
	end
end)

local f = io.open(arg[3], 'wb')
loadExt(arg[1], function(k, v1, v2)
	f:write('> ', k, '\n', addEscape(v1), '\n', addEscape(trans[k] or v2), '\n\n')
end)
f:close()

print 'done!'
