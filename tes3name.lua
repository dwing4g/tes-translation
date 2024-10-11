-- luajit tes3name.lua > name.txt

local filenames = {
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

local fixed = {
	["Dead Body"] = "��ʬ",
	["Miner Arobar"] = "���ɡ����ް�",
	["Necromancer's"] = "���鷨ʦ��",
	["Ordinator Guard"] = "�������",
	["Ship Captain"] = "����",
	["Smuggler Boss"] = "��˽��ͷĿ",
	["'Ten-Tongues'"] = "��ʮ�ࡱ",
	Berserker = "��սʿ",
	Big = "��",
	Buoyant = "�鶯",
	Captain = "�ӳ�",
	Chaplain = "��ʦ",
	Crazy = "����",
	Dead = "��ȥ��",
	Dreamer = "������",
	Grand = "�߼�",
	Grandfather = "үү",
	Guard = "����",
	Hag = "Ů��",
	High = "�߼�",
	Imperial = "�۹�",
	Insane = "����",
	Lord = "����",
	Lunatic = "����",
	Miner = "��",
	placeholder = "ռλ��",
	Pretty = "Ư��",
	Rogue = "��å",
	Skaal = "˹����",
	Smuggler = "��˽��",
	Tallowhand = "ţ����",
	Telvanni = "̩����",
	Uncle = "����",
	Wandering = "���˵�",
	Widow = "�Ѹ�",
	Witch = "Ů��",
	Worker = "����",
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
				local c1, c2 = c:match "^(.-)��(.-)$"
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
