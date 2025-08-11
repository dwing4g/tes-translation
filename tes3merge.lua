-- luajit tes3merge.lua old.txt new.txt patch_from.txt patch_to.txt
-- luajit tes3merge.lua nexus\tes3cn_Morrowind.ext.old.txt nexus\tes3cn_Morrowind.ext.txt tes3cn_Morrowind.ext.old.txt tes3cn_Morrowind.ext.txt
-- luajit tes3merge.lua nexus\tes3cn_Tribunal.ext.old.txt  nexus\tes3cn_Tribunal.ext.txt  tes3cn_Tribunal.ext.old.txt  tes3cn_Tribunal.ext.txt
-- luajit tes3merge.lua nexus\tes3cn_Bloodmoon.ext.old.txt nexus\tes3cn_Bloodmoon.ext.txt tes3cn_Bloodmoon.ext.old.txt tes3cn_Bloodmoon.ext.txt

local function loadExt(filename, callback)
	local k, e, c, m, n = nil, nil, nil, false, 0
	for line in io.lines(filename) do
		line = line:gsub("\r+$", "")
		n = n + 1
		if line ~= "" or m then
			if not k then
				if line:sub(1, 2) == "> " then
					k = line
				else
					error("ERROR: invalid line(" .. n .. "): " .. line)
				end
			elseif not e then
				e = line
				m = line:sub(1, 3) == '"""' and not line:sub(4, -1):find '"""'
			elseif e and m and not c then
				e = e .. "\r\n" .. line
				if line:find '"""' then
					m = false
				end
			elseif not c then
				c = line
				m = line:sub(1, 3) == '"""' and not line:sub(4, -1):find '"""'
				if not m then
					callback(k, e, c)
					k, e, c, m = nil, nil, nil, false
				end
			elseif c and m then
				c = c .. "\r\n" .. line
				if line:find '"""' then
					callback(k, e, c)
					k, e, c, m = nil, nil, nil, false
				end
			else
				error("ERROR: invalid line(" .. n .. "): " .. line)
			end
		end
	end
end

io.write("loading ", arg[1], " ... ")
local n = 0
local oldT = {}
loadExt(arg[1], function(k, e, c)
	oldT[k] = c
	n = n + 1
end)
print(n .. " items")

io.write("loading ", arg[2], " ... ")
local m, n = 0, 0
local newT = {}
loadExt(arg[2], function(k, e, c)
	if oldT[k] ~= c then
		newT[k] = c
		m = m + 1
	end
	n = n + 1
end)
print(n .. " items, " .. m .. " modified")

local f = io.open(arg[4], "wb")
io.write("loading ", arg[3], " ... ")
m, n = 0, 0
loadExt(arg[3], function(k, e, c)
	local done = false
	local newC = newT[k]
	if newC then
		local oldC = oldT[k]
		if c == oldC then
			c = newC
		elseif c ~= newC then
			-- f:write(k, "\r\n", e, "\r\n<<<", oldC or "", "\r\n>>>", newC, "\r\n===", c, "\r\n\r\n")
			-- done = true
			m = m + 1
		end
	end
	if not done then
		f:write(k, "\r\n", e, "\r\n", c, "\r\n\r\n")
	end
	n = n + 1
end)
f:close()
print(n .. " items, " .. m .. " conflicted")
