-- luajit tes3check.lua [minLen=20] [maxLen=1000000]

local write = io.write

local exts = {
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

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

local minLen = tonumber(arg[1]) or 20
local maxLen = tonumber(arg[2]) or 1000000
local t = {}
local n = 0
for _, ext in ipairs(exts) do
	-- write("======== ", ext, "\n")
	loadExt(ext, function(k, e, c)
		c = c:gsub(" %{.-%}$", "")
		if not t[e] then
			t[e] = c
		elseif t[e] ~= c and #e >= minLen and #e <= maxLen then
			write("e> ", e, "\n")
			write("c> ", t[e], "\n")
			write("C> ", c, "\n")
			write("k", k, "\n")
			write("--------\n")
			n = n + 1
		end
	end)
	write("======== ", ext, " (", n, " unmatched)\n")
end
