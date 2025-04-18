-- luajit tes3name.lua > name.txt

local print = print

local filenames = {
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

local fixed = {
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

	Arobar = "���ް�",
	Edd = "����",
	Ettiene = "���ٰ�",
	Fallaise = "������",
	Glenmoril = "����Ī��",
	Goris = "����˹",
	Isobel = "��������",
	Jodoin = "�Ƕ���",
	Nalcarya = "�ȶ����",
	Roberto = "�޲���",
	Theman = "ϣ��",
	Ulfgar = "�ڷ�Ӷ�",

	["Captain Roberto Jodoin"] = "�޲��С��Ƕ��򴬳�",
	["Dead Body"] = "��ʬ",
	["Ettiene of Glenmoril Wyrd"] = "����Ī��Ů���ŵİ��ٰ�",
	["Fallaise of Glenmoril Wyrd"] = "����Ī��Ů���ŵķ�����",
	["Ghost of Ulfgar the Unending"] = "�޾����ڷ�Ӷ��Ĺ��",
	["Goris the Maggot King"] = "Ӭ��֮������˹",
	["Hides His Eyes"] = "��-��-Ŀ",
	["Isobel of Glenmoril Wyrd"] = "����Ī��Ů���ŵ���������",
	["Miner Arobar"] = "���ɡ����ް�",
	["Nalcarya of White Haven"] = "�׸۵��ȶ����",
	["Necromancer's"] = "���鷨ʦ��",
	["Ordinator Guard"] = "�������",
	["Recently slain Knight"] = "�����ɱ����ʿ",
	["Ship Captain"] = "����",
	["Smuggler Boss"] = "��˽��ͷĿ",
	["Snow Bear armor test guy"] = "ѩ�ܿ��ײ�����",
	["Snow Wolf armor test guy"] = "ѩ�ǿ��ײ�����",
	["'Ten-Tongues'"] = "��ʮ�ࡱ",
	["Todd's Super Tester Guy"] = "�յµĳ����޵в��Թ�����",
	["Used Clutter Salesman"] = "������������Ա",
	["Viciously clawed dead smuggler"] = "����ץס��������˽��",
	['Edd "Fast Eddie" Theman'] = "���¡�����ë�Ȱ��ϡ���ϣ��",

	["Black Dart"] = "����",
	["Corpse"] = "ʬ��",
	["Dark Brotherhood"] = "�ڰ��ֵܻ�",
	["Duke"] = "����",
	["Female Imperial"] = "Ů�۹���",
	["Female Nord"] = "Ůŵ����",
	["Gentleman"] = "��ʿ",
	["Hand"] = "���������֮��",
	["King"] = "����",
	["Mistress"] = "����",
	["of Cloudrest"] = "��Ϣ�ǵ�",
	["of Hircine"] = "ϣ������",
	["of Shimmerene"] = "΢��ǵ�",
	["Serjo"] = "Serjo�����ˣ�",
	["Test guy"] = "������",
	["the Bloody"] = "Ѫ����",
	["the Bold"] = "����",
	["the Braggart"] = "�Ĵ���",
	["the Candle"] = "���",
	["the Clerk"] = "���Ա",
	["the Craven"] = "ų��",
	["the Crow"] = "��ѻ",
	["the Dreamer"] = "������",
	["the Easterner"] = "������",
	["the Fair"] = "��ƽ��",
	["the Flayer"] = "������",
	["the Gentle"] = "��ʿ",
	["the Halt"] = "ֹ����",
	["the Harrier"] = "����",
	["the Jeweler"] = "�鱦��",
	["the Lean"] = "����",
	["the Liar"] = "ƭ��",
	["the Long"] = "����",
	["the Mumbling"] = "����",
	["the Outlaw"] = "����֮ͽ",
	["the Peacock"] = "��ȸ",
	["the Quiet"] = "������",
	["the Rascal"] = "����",
	["the Raven"] = "����ѻ��",
	["the Roarer"] = "������",
	["the Seal"] = "�ܷ���",
	["the Smith"] = "����",
	["the Stone"] = "ʯͷ",
	["the Stout"] = "�ᶨ��",
	["the Strange"] = "������",
	["the Strong"] = "ǿ׳��",
	["the Sweltering"] = "������",
	["the Unending"] = "�޾���",
	["the Unworthy"] = "������",
	["the White"] = "�԰���",
	["the Wild"] = "��Ұ��",
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
			local c1, c2 = c:match "^(.-)��(.-)$"
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
						local c1, c2 = c2:match "^(.-)��(.-)$"
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
						local c1, c2 = c1:match "^(.-)��(.-)$"
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
	High = "��",
	Red = "��",
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
