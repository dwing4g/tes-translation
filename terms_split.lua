-- luajit terms_split.lua terms.csv terms_split.csv
-- luajit terms_split.lua _.cel     cel_split.csv
-- xxx, yyy, zzz	XXX£¬YYY£¬ZZZ
-- xxx yyy,XXX¡¤YYY

local ignored = {
	Armory = true,
}

local cel = arg[1]:find "%.cel$"
if not cel and not arg[1]:find "%.csv$" then
	error("ERROR: unknown format: " .. arg[1])
end

local f = io.open(arg[2], "wb")
local function write(k, v, c)
	if	k:find ','  or v:find ','  or c:find ',' or
		k:find '^"' or v:find '^"' or c:find '^"' then
		f:write('"', k:gsub('"', '""'), '","', v:gsub('"', '""'), '","', c:gsub('"', '""'), '"\n')
	else
		f:write(k, ',', v, ',', c, '\n')
	end
end

local t = {}
local tc = {}
local function add(k, v, c)
	k = k:gsub("^%s+", ""):gsub("%s+$", "")
	v = v:gsub("^%s+", ""):gsub("%s+$", "")
	if k ~= "" and v ~= "" then
		if t[k] then
			if t[k] ~= v then
				if tc[k] == c and not ignored[k] then
					error("ERROR: duplicated k=" .. k .. ", v=" .. t[k] .. " or " .. v .. ", c=" .. c)
				else
					t[k] = v
					tc[k] = c
					write(k, v, c)
				end
			elseif tc[k] ~= c then
				tc[k] = c
				write(k, v, c)
			end
		else
			t[k] = v
			tc[k] = c
			write(k, v, c)
		end
	else
		error("ERROR: empty k=" .. k .. " or v=" .. v)
	end
end

for line in io.lines(arg[1]) do
	if cel then
		local k, v = line:match "^(.+)\t(.+)$"
		if not k then
			error("ERROR: unknown line: " .. line)
		end
		local k1, k2, k3 = k:match "^([^,]+),([^,]+),([^,]+)$"
		if k1 then
			local v1, v2, v3 = v:match "^([^,]+)£¬([^,]+)£¬([^,]+)$"
			if not v1 then
				error("ERROR: unmatched line: " .. line)
			end
			add(k1, v1, "CEL")
			add(k2, v2, "CEL")
			add(k3, v3, "CEL")
		else
			k1, k2 = k:match "^([^,]+),([^,]+)$"
			if k1 then
				local v1, v2 = v:match "^([^,]+)£¬([^,]+)$"
				if not v1 then
					error("ERROR: unmatched line: " .. line)
				end
				add(k1, v1, "CEL")
				add(k2, v2, "CEL")
			else
				add(k, v, "CEL")
			end
		end
	else
		local k, v, c = line:match '^"(.-)","(.-)","(.-)"$'
		if k then
			k = k:gsub('""', '"')
			v = v:gsub('""', '"')
			c = c:gsub('""', '"')
		else
			k, v, c = line:match '^([^,]+),([^,]+),([^,]+)$'
			if not k then
				error("ERROR: unknown line: " .. line)
			end
		end
		local v1, v2 = v:match "^(.-)¡¤(.+)$"
		if v1 then
			local k1, k2 = k:match "^(%S+) (%S+)$"
			if k1 then
				add(k1, v1, c)
				add(k2, v2, c)
			else
				error("ERROR: unmatched line: " .. line)
			end
		end
	end
end
f:close()
print "DONE!"
