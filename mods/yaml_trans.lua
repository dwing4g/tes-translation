local t = {}
for line in io.lines(arg[1]) do
	local k, v = line:match '^%s*"(.-)"%s*:%s*"(.-)"'
	if k then t[k] = v end
end

local o = {}
for line in io.lines(arg[2]) do
	local k = line:match '^%s*"(.-)"'
	if k then
		o[#o + 1] = '"' .. k .. '": "' .. (t[k] or k) .. '"\n'
	else
		o[#o + 1] = line .. '\n'
	end
end

local f = io.open(arg[3] or arg[2], 'wb')
f:write(table.concat(o))
f:close()

print 'done!'
