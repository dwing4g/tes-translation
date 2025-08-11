-- luajit terms_split.lua terms.csv terms_split.csv
-- luajit terms_split.lua _.cel     cel_split.csv
-- xxx, yyy, zzz	XXX，YYY，ZZZ
-- xxx yyy,XXX·YYY

-- luajit terms_split.lua Morrowind.cel ~$cel_split.csv
-- luajit terms_split.lua ~$ext2m\terms.csv ~$ext2m\terms_split.csv
-- luajit terms_split.lua ~$ext2t\terms.csv ~$ext2t\terms_split.csv
-- luajit terms_split.lua ~$ext2b\terms.csv ~$ext2b\terms_split.csv
-- luajit terms_split.lua TamrielRebuilt\TR_Mainland.cel TamrielRebuilt\~$cel_split.csv

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
local lineId = 0

local addIgnored = {
	Armory = true,
	Asharapli = true,
	Axe = true,
	Blessing = true,
	Chambers = true,
	Drarayne = true,
	Favani = true,
	Gift = true,
	Journal = true,
	Rest = true,
	Ring = true,
	Robe = true,
	Salen = true,
	Shield = true,
	Skirt = true,
	Spite = true,
	Staff = true,
	Tale = true,
	Tower = true,
	Uleni = true,
	Wake = true,
}
local t = {}
local tc = {}
local function add(k, v, c)
	k = k:gsub("^%s+", ""):gsub("%s+$", "")
	v = v:gsub("^%s+", ""):gsub("%s+$", "")
	if k ~= "" and v ~= "" then
		if t[k] then
			if t[k] ~= v then
				if tc[k] == c and not addIgnored[k] then
					error("ERROR(" .. lineId .. "): duplicated k=" .. k .. ", v=" .. t[k] .. " or " .. v .. ", c=" .. c)
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
		error("ERROR(" .. lineId .. "): empty k=" .. k .. " or v=" .. v)
	end
end

local subIgnored = {
	Ancestor = true,
	Apprentice = true,
	Arrille = true,
	Azura = true,
	Bungler = true,
	Duke = true,
	Erna = true, -- 厄娜给...的...
	Factor = true,
	Father = true,
	Fatleg = true,
	Fighters = true,
	God = true,
	Gondolier = true,
	Governor = true,
	Grandmaster = true,
	GrandMaster = true,
	Herder = true,
	Journeyman = true,
	King = true,
	Lady = true,
	Lizard = true,
	Lord = true,
	Mages = true,
	Master = true,
	Miner = true,
	Necromancer = true,
	Queen = true,
	Saint = true,
	SecretMaster = true,
	Shalk = true,
	Shara = true, -- 人名/地名不同
	Slave = true,
	Stahlman = true,
	Watcher = true,
	Wizard = true,
	["Apprentice's Armorer"] = true,
	["Arena Fighter"] = true,
	["GrandMaster's Armorer"] = true,
	["Her Hand"] = true,
	["Journeyman's Armorer"] = true,
	["Lower Queen"] = true,
	["Master's Armorer"] = true,
	["Redoran Watchman"] = true,
	["Secret Master"] = true,
	["Sewers: Thieves"] = true,
	["Sewers: Uriel"] = true,
	["The Lizard"] = true,
	["The Warrior"] = true,
	["Upper Queen"] = true,
}
local function addSub(line, k, v, c)
	k = k:gsub("^%s+", ""):gsub("%s+$", "")
	v = v:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^《", ""):gsub("》$", "")
	local k1, k2 = k:match "^(%a%S*)'s? (%a.*)$"
	if k1 and not subIgnored[k1] then
		local v1, v2 = v:match "^(...-)的(.+)$"
		if not v1 then
			v1, v2 = v:match "^(...-)之(.+)$"
			if not v1 then
				error("ERROR(" .. lineId .. "): unmatched line: " .. line)
			end
		end
		add(k1, v1, c)
		add(k2, v2, c)
	else
		local k4, k1, k2, k3 = k:match "^((%a%S*) (%a%S*))'s? (%a.*)$"
		if k1 and not subIgnored[k4] then
			local v4, v3 = v:match "^(...-)的(.+)$"
			if not v4 then
				v4, v3 = v:match "^(...-)之(.+)$"
				if not v4 then
					error("ERROR(" .. lineId .. "): unmatched line: " .. line)
				end
			end
			local v1, v2 = v4:match "^(...-)·(.+)$"
			if v1 then
				add(k1, v1, c)
				add(k2, v2, c)
			else
				add(k4, v4, c)
			end
			add(k3, v3, c)
		else
			local k1, k2 = k:match "^(%a%S*) (%a%S*)$"
			local v1, v2 = v:match "^(...-)·(.+)$"
			if k1 and v1 then
				add(k1, v1, c)
				add(k2, v2, c)
			end
		end
	end
end

for line in io.lines(arg[1]) do
	line = line:gsub("\r+$", "")
	lineId = lineId + 1
	if cel then
		local k, v = line:match "^(.+)\t(.+)$"
		if not k then
			error("ERROR(" .. lineId .. "): unknown line: " .. line)
		end
		local k1, k2, k3 = k:match "^([^,]+),([^,]+),([^,]+)$"
		if k1 then
			local v1, v2, v3 = v:match "^([^,]+)，([^,]+)，([^,]+)$"
			if not v1 then
				error("ERROR(" .. lineId .. "): unmatched line: " .. line)
			end
			add(k1, v1, "CEL")
			add(k2, v2, "CEL")
			add(k3, v3, "CEL")
			addSub(line, k1, v1, "CEL")
			addSub(line, k2, v2, "CEL")
			addSub(line, k3, v3, "CEL")
		else
			k1, k2 = k:match "^([^,]+),([^,]+)$"
			if k1 then
				local v1, v2 = v:match "^([^,]+)，([^,]+)$"
				if not v1 then
					error("ERROR(" .. lineId .. "): unmatched line: " .. line)
				end
				add(k1, v1, "CEL")
				add(k2, v2, "CEL")
				addSub(line, k1, v1, "CEL")
				addSub(line, k2, v2, "CEL")
			else
				add(k, v, "CEL")
				addSub(line, k, v, "CEL")
			end
		end
	else
		local k, v, c = line:match '^"(..-)","(..-)","(.*)"$'
		if k then
			k = k:gsub('""', '"')
			v = v:gsub('""', '"')
			c = c:gsub('""', '"')
		else
			k, v, c = line:match '^([^,]+),([^,]+),([^,]*)$'
			if not k then
				error("ERROR(" .. lineId .. "): unknown line: " .. line)
			end
		end
		add(k, v, c)
		addSub(line, k, v, c)
	end
end
f:close()
print "DONE!"
