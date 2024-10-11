-- luajit tes3name.lua > name.txt

local filenames = {
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

local fixed = {
	["Dead Body"] = "死尸",
	["Miner Arobar"] = "迈纳·阿罗巴",
	["Necromancer's"] = "死灵法师的",
	["Ordinator Guard"] = "神殿卫兵",
	["Ship Captain"] = "船长",
	["Smuggler Boss"] = "走私者头目",
	["'Ten-Tongues'"] = "“十舌”",
	Berserker = "狂战士",
	Big = "大",
	Buoyant = "灵动",
	Captain = "队长",
	Chaplain = "牧师",
	Crazy = "疯子",
	Dead = "死去的",
	Dreamer = "梦游者",
	Grand = "高级",
	Grandfather = "爷爷",
	Guard = "卫兵",
	Hag = "女巫",
	High = "高级",
	Imperial = "帝国",
	Insane = "疯狂的",
	Lord = "领主",
	Lunatic = "疯子",
	Miner = "矿工",
	placeholder = "占位符",
	Pretty = "漂亮",
	Rogue = "流氓",
	Skaal = "斯卡尔",
	Smuggler = "走私者",
	Tallowhand = "牛油手",
	Telvanni = "泰瓦尼",
	Uncle = "叔叔",
	Wandering = "流浪的",
	Widow = "寡妇",
	Witch = "女巫",
	Worker = "工人",
}

local s = ""
local dict = {}

local function count(c)
	local i, j, n = 1, 1, 0
	while true do
		i, j = s:find(c, i, true)
		if not i then
			break
		end
		i = j + 1
		n = n + 1
	end
	return n
end

local function addDict(e, c)
	if dict[e] then
		if dict[e] ~= c then
			print("ERROR: unmatched name translation: " .. e .. ": " .. dict[e] .. "(" .. count(dict[e]) .. ") | " .. c .. "(" .. count(c) .. ")")
		end
		return false
	end
	dict[e] = c
	-- print(e .. "\t" .. c)
	return true
end

for e, c in pairs(fixed) do
	addDict(e, c)
end

local function search()
	for e, c in s:gmatch "> NPC_%.FNAM %C+%c+(%C+)%c+(%C+)%c+" do
		if addDict(e, c) then
			local e1, e2 = e:match "^([%w%-']+) ([%w%-']+)$"
			if e1 then
				local c1, c2 = c:match "^(.-)·(.-)$"
				if c1 then
					addDict(e1, c1)
					addDict(e2, c2)
				elseif not fixed[e] then
					if fixed[e1] then
						c2 = c:gsub(fixed[e1], "")
						if c2 == c then
							print("WARN: unmatched name pair: " .. e .. ": " .. c)
						else
							addDict(e2, c2)
						end
					elseif fixed[e2] then
						c1 = c:gsub(fixed[e2], "")
						if c1 == c then
							print("WARN: unmatched name pair: " .. e .. ": " .. c)
						else
							addDict(e1, c1)
						end
					else
						print("WARN: unmatched name pair: " .. e .. ": " .. c)
					end
				end
			end
		end
	end
end

for _, filename in ipairs(filenames) do
	local f = io.open(filename, "rb")
	s = s .. f:read "*a"
	f:close()
end
search()
