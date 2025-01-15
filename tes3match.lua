-- luajit tes3match.lua "original words" "translated words"

local write = io.write

local exts = {
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

local function loadExt(filename, callback)
	local k, e, c, m, n = nil, nil, nil, false, 0
	for line in io.lines(filename) do
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

local me = arg[1]:lower()
local mc = arg[2]:lower()
for _, ext in ipairs(exts) do
	-- write("======== ", ext, "\n")
	local n = 0
	loadExt(ext, function(k, e, c)
		local _, ne = e:lower():gsub(me, me)
		local _, nc = c:lower():gsub("{[^}]-}%s*$", ""):gsub(mc, mc)
		if ne ~= nc and c ~= "###" then
			n = n + 1
			write("---", k, "\n")
			if #e < 512 then
				write("<<<", ne, " ", e, "\n")
				write(">>>", nc, " ", c, "\n")
			end
		end
	end)
	write("======== ", ext, " (", n, " unmatched)\n")
end
