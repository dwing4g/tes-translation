-- luajit tes3match.lua "original words" "translated words"

local write = io.write

local exts = {
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

local function lowerGBK(s)
	if not s:find "[A-Z]" then
		return s
	end
	if not s:find "[\x80-\xff]" then
		return s:lower()
	end
	local t = {}
	local i = 1
	while i <= #s do
		if s:byte(i) < 0x80 then
			t[#t + 1] = s:sub(i, i):lower()
			i = i + 1
		else
			t[#t + 1] = s:sub(i, i + 1)
			i = i + 2
		end
	end
	return table.concat(t)
end

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

local me = lowerGBK(arg[1])
local mc = lowerGBK(arg[2])
for _, ext in ipairs(exts) do
	-- write("======== ", ext, "\n")
	local n = 0
	loadExt(ext, function(k, e, c)
		local _, ne = lowerGBK(e):gsub(me, me)
		local _, nc = lowerGBK(c):gsub("{[^}]-}%s*$", ""):gsub(mc, mc)
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
