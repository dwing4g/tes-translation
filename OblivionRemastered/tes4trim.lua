-- luajit tes4trim.lua Oblivion.txt > Oblivion.trim.txt
-- move /y Oblivion.trim.txt Oblivion.txt
-- ref: https://en.uesp.net/wiki/Oblivion_Mod:Mod_File_Format

local char = string.char
local tonumber = tonumber
local print = print

local reserved = {
	GMST = true, -- DATA 全局字符串
--	GLOB = true,
	CLAS = true, -- FULL+DESC 职业
	FACT = true, -- FULL+(MNAM+FNAM)* 派系
	HAIR = true, -- FULL 发型
	EYES = true, -- FULL 眼型
	RACE = true, -- FULL DESC 种族
--	SOUN = true,
	SKIL = true, -- DESC+ANAM+JNAM+ENAM+MNAM 技能
	MGEF = true, -- FULL 法术效果
	SCPT = true, -- SCTX 脚本
--	LTEX = true,
	ENCH = true, -- FULL 附魔
	SPEL = true, -- FULL 法术
	BSGN = true, -- FULL+DESC 星座
	ACTI = true, -- FULL 触发器
	APPA = true, -- FULL 炼金仪器
	ARMO = true, -- FULL 盔甲
	BOOK = true, -- FULL DESC 书信
	CLOT = true, -- FULL 衣衫
	CONT = true, -- FULL 物品容器
	DOOR = true, -- FULL 门
	INGR = true, -- FULL 炼金材料
	LIGH = true, -- FULL 火把
	MISC = true, -- FULL 杂物
--	STAT = true,
--	GRAS = true,
--	TREE = true,
	FLOR = true, -- FULL 食物
	FURN = true, -- FULL 家具
	WEAP = true, -- FULL 武器
	AMMO = true, -- FULL 箭只
	NPC_ = true, -- FULL NPC (zlib compressed)
	CREA = true, -- FULL 敌人
--	LVLC = true,
	SLGM = true, -- FULL 灵魂石
	KEYM = true, -- FULL 钥匙
	ALCH = true, -- FULL 药水
--	SBSP = true,
	SGST = true, -- FULL 印记石
--	LVLI = true,
--	WTHR = true,
--	CLMT = true,
	REGN = true, -- RDMP 室外区域
	CELL = true, -- FULL 室内区域
	WRLD = true, -- FULL+REFR.FULL* 世界+传送点
	DIAL = true, -- FULL+INFO.NAM1* 话题+对话
	QUST = true, -- FULL+CNAM* 任务
--	IDLE = true,
--	PACK = true,
--	CSTY = true,
	LSCR = true, -- DESC 加载提示
--	LVSP = true,
--	ANIO = true,
--	WATR = true,
--	EFSH = true,
}

local g = 0
local ln = 0
for line in io.lines(arg[1]) do
	line = line:gsub("\r+$", "")
	ln = ln + 1
	local g1, g2, g3, g4 = line:match "^{GRUP %[(%x+) (%x+) (%x+) (%x+)"
	if g1 then
		g = g + 1
		if g == 1 then
			local tag = char(tonumber(g1, 16)) .. char(tonumber(g2, 16)) .. char(tonumber(g3, 16)) .. char(tonumber(g4, 16))
			print(tag, line) --TODO
		else
			--TODO
		end
	elseif line:find "^}" then
		g = g - 1
	else
		--TODO
	end
end
print(g) --TODO
