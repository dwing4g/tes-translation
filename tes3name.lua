-- luajit tes3name.lua > name.txt

local print = print

local filenames = {
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

local fixed = {
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

	Arobar = "阿罗巴",
	Edd = "埃德",
	Ettiene = "艾蒂安",
	Fallaise = "法莱兹",
	Glenmoril = "格伦莫莉",
	Goris = "格里斯",
	Isobel = "伊索贝尔",
	Jodoin = "乔多因",
	Nalcarya = "娜尔卡娅",
	Roberto = "罗伯托",
	Theman = "希曼",
	Ulfgar = "乌夫加尔",

	["Captain Roberto Jodoin"] = "罗伯托·乔多因船长",
	["Dead Body"] = "死尸",
	["Ettiene of Glenmoril Wyrd"] = "格伦莫莉女巫团的艾蒂安",
	["Fallaise of Glenmoril Wyrd"] = "格伦莫莉女巫团的法莱兹",
	["Ghost of Ulfgar the Unending"] = "无尽者乌夫加尔的鬼魂",
	["Goris the Maggot King"] = "蝇蛆之王格里斯",
	["Hides His Eyes"] = "隐-其-目",
	["Isobel of Glenmoril Wyrd"] = "格伦莫莉女巫团的伊索贝尔",
	["Miner Arobar"] = "迈纳·阿罗巴",
	["Nalcarya of White Haven"] = "白港的娜尔卡娅",
	["Necromancer's"] = "死灵法师的",
	["Ordinator Guard"] = "神殿卫兵",
	["Recently slain Knight"] = "最近被杀的骑士",
	["Ship Captain"] = "船长",
	["Smuggler Boss"] = "走私者头目",
	["Snow Bear armor test guy"] = "雪熊盔甲测试人",
	["Snow Wolf armor test guy"] = "雪狼盔甲测试人",
	["'Ten-Tongues'"] = "“十舌”",
	["Todd's Super Tester Guy"] = "陶德的超级无敌测试工具人",
	["Used Clutter Salesman"] = "二手杂物推销员",
	["Viciously clawed dead smuggler"] = "被紧抓住的死亡走私者",
	['Edd "Fast Eddie" Theman'] = "埃德·“飞毛腿埃迪”·希曼",

	["Black Dart"] = "黑镖",
	["Corpse"] = "尸体",
	["Dark Brotherhood"] = "黑暗兄弟会",
	["Duke"] = "公爵",
	["Female Imperial"] = "女帝国人",
	["Female Nord"] = "女诺德人",
	["Gentleman"] = "绅士",
	["Hand"] = "阿玛莱西娅之手",
	["King"] = "国王",
	["Mistress"] = "夫人",
	["of Cloudrest"] = "云息城的",
	["of Hircine"] = "希尔辛的",
	["of Shimmerene"] = "微光城的",
	["Serjo"] = "Serjo（大人）",
	["Test guy"] = "测试人",
	["the Bloody"] = "血腥者",
	["the Bold"] = "勇者",
	["the Braggart"] = "鼓吹者",
	["the Candle"] = "烛光",
	["the Clerk"] = "书记员",
	["the Craven"] = "懦夫",
	["the Crow"] = "乌鸦",
	["the Dreamer"] = "空想者",
	["the Easterner"] = "东方人",
	["the Fair"] = "公平的",
	["the Flayer"] = "劫掠者",
	["the Gentle"] = "绅士",
	["the Halt"] = "止步者",
	["the Harrier"] = "鹞子",
	["the Jeweler"] = "珠宝商",
	["the Lean"] = "瘦子",
	["the Liar"] = "骗子",
	["the Long"] = "长长",
	["the Mumbling"] = "喃喃者",
	["the Outlaw"] = "不法之徒",
	["the Peacock"] = "孔雀",
	["the Quiet"] = "静谧者",
	["the Rascal"] = "无赖",
	["the Raven"] = "“渡鸦”",
	["the Roarer"] = "咆哮者",
	["the Seal"] = "密封者",
	["the Smith"] = "铁匠",
	["the Stone"] = "石头",
	["the Stout"] = "坚定的",
	["the Strange"] = "怪异者",
	["the Strong"] = "强壮者",
	["the Sweltering"] = "闷热者",
	["the Unending"] = "无尽者",
	["the Unworthy"] = "卑劣者",
	["the White"] = "苍白者",
	["the Wild"] = "狂野者",
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

for _, filename in ipairs(filenames) do
	local f = io.open(filename, "rb")
	s = s .. f:read "*a"
	f:close()
end

for e, c in s:gmatch "> NPC_%.FNAM %C+%c+(%C+)%c+(%C+)%c+" do
	e = e:gsub(" +$", "")
	if addDict(e, c) then
		local e1, e2 = e:match "^([%w%-'$]+) ([%w%-'$]+)$"
		if e1 then
			local c1, c2 = c:match "^(.-)·(.-)$"
			if c1 then
				addDict(e1, c1)
				addDict(e2, c2)
			elseif not fixed[e] then
				if fixed[e1] then
					c2 = c:gsub(fixed[e1], "")
					if c2 == c then
						print("WARN: unmatched name pair1: " .. e .. ": " .. c)
					else
						addDict(e2, c2)
					end
				elseif fixed[e2] then
					c1 = c:gsub(fixed[e2], "")
					if c1 == c then
						print("WARN: unmatched name pair2: " .. e .. ": " .. c)
					else
						addDict(e1, c1)
					end
				else
					print("WARN: unmatched name pair3: " .. e .. ": " .. c)
				end
			end
		else
			local e1, e2, e3 = e:match "^([%w%-'$]+) ([%w%-'$]+) ([%w%-'$]+)$"
			if e1 then
				local e12 = e1 .. " " .. e2
				local e23 = e2 .. " " .. e3
				if fixed[e12] then
					local c2 = c:gsub(fixed[e12], "")
					if c2 == c then
						print("WARN: unmatched name pair4: " .. e .. ": " .. c)
					else
						addDict(e3, c2)
					end
				elseif fixed[e23] then
					local c1 = c:gsub(fixed[e23], "")
					if c1 == c then
						print("WARN: unmatched name pair5: " .. e .. ": " .. c)
					else
						addDict(e1, c1)
					end
				elseif fixed[e1] then
					local c2 = c:gsub(fixed[e1], "")
					if c2 == c then
						print("WARN: unmatched name pair6: " .. e .. ": " .. c)
					else
						addDict(e23, c2)
						local c1, c2 = c2:match "^(.-)·(.-)$"
						if c1 then
							addDict(e2, c1)
							addDict(e3, c2)
						end
					end
				elseif fixed[e3] then
					local c1 = c:gsub(fixed[e3], "")
					if c1 == c then
						print("WARN: unmatched name pair7: " .. e .. ": " .. c)
					else
						addDict(e12, c1)
						local c1, c2 = c1:match "^(.-)·(.-)$"
						if c1 then
							addDict(e1, c1)
							addDict(e2, c2)
						end
					end
				else
					print("WARN: unmatched name pair8: " .. e .. ": " .. c)
				end
			elseif not e:find "^([%w%-'$]+)$" then
				print("WARN: unknown name pattern: " .. e .. ": " .. c)
			end
		end
	end
end

local dict2 = {
	High = "高",
	Red = "红",
}
--[[
for e, c in s:gmatch "> INFO%.NAME %C+%c+(%C+)%c+(%C+)%c+" do
	if e:sub(1, 3) ~= '"""' then
		for ew in e:gmatch "[%w%-'$]+" do
			local cw = dict[ew]
			if cw and not c:find(cw, 1, true) then
				local cw2 = dict2[ew]
				if not cw2 or not c:find(cw2, 1, true) then
					print("WARN: unmatched INFO translation: " .. ew .. " => " .. cw .. "\n" .. e .. "\n" .. c)
				end
			end
		end
	end
end
]]
