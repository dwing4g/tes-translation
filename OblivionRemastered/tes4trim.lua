-- luajit tes4trim.lua Oblivion.txt > Oblivion.trim.txt
-- move /y Oblivion.trim.txt Oblivion.txt
-- ref: https://en.uesp.net/wiki/Oblivion_Mod:Mod_File_Format

local char = string.char
local tonumber = tonumber
local print = print

local reserved = {
	GMST = true, -- DATA
--	GLOB = true,
	CLAS = true, -- FULL DESC
	FACT = true, -- FULL FNAM MNAM
	HAIR = true, -- FULL
	EYES = true, -- FULL
	RACE = true, -- DESC
--	SOUN = true,
	SKIL = true, -- DESC ANAM ENAM JNAM MNAM
	MGEF = true, -- FULL
	SCPT = true,
--	LTEX = true,
	ENCH = true, -- FULL
	SPEL = true, -- FULL
	BSGN = true, -- FULL DESC
	ACTI = true, -- FULL
	APPA = true, -- FULL
	ARMO = true, -- FULL
	BOOK = true, -- FULL DESC
	CLOT = true, -- FULL
	CONT = true, -- FULL
	DOOR = true, -- FULL
	INGR = true, -- FULL
	LIGH = true, -- FULL
	MISC = true, -- FULL
--	STAT = true,
--	GRAS = true,
--	TREE = true,
	FLOR = true, -- FULL
	FURN = true, -- FULL
	WEAP = true, -- FULL ANAM
	AMMO = true, -- FULL
	NPC_ = true, -- GRUP [4E 50 43 5F 00 00 00 00 0F 0E 02 00] need zlib decompress
	CREA = true, -- FULL BNAM
--	LVLC = true,
	SLGM = true, -- FULL
	KEYM = true, -- FULL
	ALCH = true, -- FULL
--	SBSP = true,
	SGST = true, -- FULL
--	LVLI = true,
--	WTHR = true,
--	CLMT = true,
	REGN = true, -- FULL RDMP
	CELL = true, -- FULL (only reserve 4 levels GRUP)
	WRLD = true, -- FULL (part, need REFR.FULL)
	DIAL = true, -- FULL (INFO.NAME INFO.NAM1)
	QUST = true, -- FULL CNAM
--	IDLE = true,
--	PACK = true,
--	CSTY = true,
	LSCR = true, -- DESC
--	LVSP = true,
--	ANIO = true,
--	WATR = true,
--	EFSH = true,
}

local g = 0
local ln = 0
for line in io.lines(arg[1]) do
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
