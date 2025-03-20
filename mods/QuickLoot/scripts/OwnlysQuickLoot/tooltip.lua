local types = require('openmw.types')
local core = require('openmw.core')
local util = require('openmw.util')


function getMaxEnchantmentCharge(enchantment)
	if not enchantment.autocalcFlag then
		return enchantment.charge
	end
	local cost = 0
	for _, effect in pairs(enchantment.effects) do
		-- note: EffectCostMethod = EffectCostMethod::GameEnchantment
	
		-- float calcEffectCost(
        -- const ESM::ENAMstruct& effect, const ESM::MagicEffect* magicEffect, const EffectCostMethod method)
		-- {
        -- const MWWorld::ESMStore& store = *MWBase::Environment::get().getESMStore();
		--  if (!magicEffect)
		-- magicEffect = store.get<ESM::MagicEffect>().find(effect.mEffectID);
		local hasMagnitude = effect.effect.hasMagnitude -- bool hasMagnitude = !(magicEffect->mData.mFlags & ESM::MagicEffect::NoMagnitude);
        local hasDuration = effect.effect.hasDuration -- bool hasDuration = !(magicEffect->mData.mFlags & ESM::MagicEffect::NoDuration);
        local appliedOnce = effect.effect.isAppliedOnce -- bool appliedOnce = magicEffect->mData.mFlags & ESM::MagicEffect::AppliedOnce;
		local minMagn = hasMagnitude and effect.magnitudeMin or 1; -- int minMagn = hasMagnitude ? effect.mMagnMin : 1;
		local maxMagn = hasMagnitude and effect.magnitudeMax or 1; -- int maxMagn = hasMagnitude ? effect.mMagnMax : 1;
		--if (method == EffectCostMethod::PlayerSpell || method == EffectCostMethod::GameSpell)
        --{
        --    minMagn = std::max(1, minMagn);
        --    maxMagn = std::max(1, maxMagn);
        --}
		local duration = hasDuration and effect.duration or 1; -- int duration = hasDuration ? effect.mDuration : 1;
		if not appliedOnce then -- if (!appliedOnce)
			duration = math.max(1, duration) -- duration = std::max(1, duration);
		end
		local fEffectCostMult = core.getGMST("fEffectCostMult") -- static const float fEffectCostMult = store.get<ESM::GameSetting>().find("fEffectCostMult")->mValue.getFloat();
		-- static const float iAlchemyMod = store.get<ESM::GameSetting>().find("iAlchemyMod")->mValue.getFloat();
		local durationOffset = 0;            -- int durationOffset = 0;
        local minArea = 0;                   -- int minArea = 0;
        local costMult = fEffectCostMult;  -- float costMult = fEffectCostMult;
		-- if (method == EffectCostMethod::PlayerSpell)
        -- {
        --     durationOffset = 1;
        --     minArea = 1;
        -- }
        -- else if (method == EffectCostMethod::GamePotion)
        -- {
        --     minArea = 1;
        --     costMult = iAlchemyMod;
        -- }
		local x = 0.5 * (minMagn + maxMagn);                                          -- float x = 0.5 * (minMagn + maxMagn);
		x = x * (0.1 * effect.effect.baseCost);                                      -- x *= 0.1 * magicEffect->mData.mBaseCost;
		x = x * (durationOffset + duration);                                               -- x *= durationOffset + duration;
		x = x + (0.05 * math.max(minArea, effect.area) * effect.effect.baseCost);   -- x += 0.05 * std::max(minArea, effect.mArea) * magicEffect->mData.mBaseCost;
		
		if effect.range == core.magic.RANGE.Target then	--if (effect.mData.mRange == ESM::RT_Target)
			x = x * 1.5 -- effectCost *= 1.5;
		end
		x = math.floor(x * costMult)
		cost = cost + x
		
	end
	
	if enchantment.type == core.magic.ENCHANTMENT_TYPE.CastOnce then
		cost = cost * core.getGMST("iMagicItemChargeOnce")
	elseif enchantment.type == 	core.magic.ENCHANTMENT_TYPE.CastOnUse then
		cost = cost * core.getGMST("iMagicItemChargeUse")
	elseif enchantment.type == 	core.magic.ENCHANTMENT_TYPE.CastOnStrike then
		cost = cost * core.getGMST("iMagicItemChargeStrike")
	elseif enchantment.type == 	core.magic.ENCHANTMENT_TYPE.ConstantEffect then
		cost = cost * core.getGMST("iMagicItemChargeConst")
	end
	return cost or 0
end


-- Alternative function that takes pre-parsed character data for better performance
function createFontWidthCalculator(fontData)
	-- Parse the .fnt file data to extract character widths
	local charWidthMap = {}
	
	-- Default width for unknown characters
	local defaultWidth = 16
	
	-- Parse character data from the .fnt file
	for line in fontData:gmatch("[^\r\n]+") do
		if line:match("^char%s+id=") then
			local id, width, xoffset, xadvance = line:match("id=(%d+)%s+.-%s+width=(%d+)%s+.-%s+xoffset=(%-?%d+)%s+.-%s+xadvance=(%d+)")
			if id and width and xoffset and xadvance then
				charWidthMap[tonumber(id)] = tonumber(xadvance)
			end
		end
	end
	
	-- Return a function closure that can calculate string widths quickly
	return function(text)
		local totalWidth = 0
		
		for i = 1, #text do
			local charCode = string.byte(text, i)
			local charWidth = charWidthMap[charCode] or defaultWidth
			totalWidth = totalWidth + charWidth
		end
		
		return totalWidth/13.37
	end
end

-- Example usage:
local fontData = [[ info face="Mystic Cards" size=32 bold=0 italic=0 charset="RUSSIAN" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0
common lineHeight=32 base=27 scaleW=256 scaleH=256 pages=2 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0
page id=0 file="mc_0.tga"
page id=1 file="mc_1.tga"
chars count=176
char id=13   x=252   y=0	 width=3	 height=1	 xoffset=-1	yoffset=31	xadvance=1	 page=0  chnl=15
char id=32   x=27	y=29	width=3	 height=1	 xoffset=-1	yoffset=31	xadvance=14	page=0  chnl=15
char id=33   x=24	y=183   width=7	 height=21	xoffset=0	 yoffset=7	 xadvance=7	 page=0  chnl=15
char id=34   x=0	 y=0	 width=10	height=10	xoffset=1	 yoffset=5	 xadvance=12	page=1  chnl=15
char id=35   x=22	y=58	width=18	height=25	xoffset=0	 yoffset=5	 xadvance=18	page=0  chnl=15
char id=36   x=0	 y=32	width=17	height=26	xoffset=0	 yoffset=4	 xadvance=17	page=0  chnl=15
char id=37   x=0	 y=135   width=24	height=23	xoffset=0	 yoffset=6	 xadvance=25	page=0  chnl=15
char id=38   x=46	y=109   width=22	height=24	xoffset=1	 yoffset=6	 xadvance=24	page=0  chnl=15
char id=39   x=249   y=173   width=6	 height=10	xoffset=0	 yoffset=5	 xadvance=6	 page=0  chnl=15
char id=40   x=65	y=55	width=9	 height=25	xoffset=2	 yoffset=5	 xadvance=13	page=0  chnl=15
char id=41   x=75	y=54	width=9	 height=25	xoffset=2	 yoffset=5	 xadvance=13	page=0  chnl=15
char id=42   x=143   y=243   width=15	height=12	xoffset=0	 yoffset=6	 xadvance=16	page=0  chnl=15
char id=43   x=158   y=196   width=16	height=15	xoffset=1	 yoffset=11	xadvance=18	page=0  chnl=15
char id=44   x=111   y=246   width=7	 height=9	 xoffset=1	 yoffset=22	xadvance=9	 page=0  chnl=15
char id=45   x=144   y=0	 width=11	height=4	 xoffset=0	 yoffset=17	xadvance=11	page=1  chnl=15
char id=46   x=119   y=246   width=6	 height=5	 xoffset=1	 yoffset=23	xadvance=8	 page=0  chnl=15
char id=47   x=158   y=0	 width=8	 height=27	xoffset=1	 yoffset=5	 xadvance=11	page=0  chnl=15
char id=48   x=48	y=183   width=14	height=20	xoffset=1	 yoffset=7	 xadvance=16	page=0  chnl=15
char id=49   x=237   y=174   width=11	height=19	xoffset=3	 yoffset=8	 xadvance=16	page=0  chnl=15
char id=50   x=63	y=182   width=14	height=20	xoffset=1	 yoffset=7	 xadvance=16	page=0  chnl=15
char id=51   x=108   y=178   width=13	height=20	xoffset=2	 yoffset=7	 xadvance=16	page=0  chnl=15
char id=52   x=193   y=174   width=14	height=19	xoffset=1	 yoffset=8	 xadvance=16	page=0  chnl=15
char id=53   x=223   y=174   width=13	height=19	xoffset=1	 yoffset=8	 xadvance=16	page=0  chnl=15
char id=54   x=93	y=178   width=14	height=20	xoffset=1	 yoffset=7	 xadvance=16	page=0  chnl=15
char id=55   x=208   y=174   width=14	height=19	xoffset=1	 yoffset=8	 xadvance=16	page=0  chnl=15
char id=56   x=78	y=179   width=14	height=20	xoffset=1	 yoffset=7	 xadvance=16	page=0  chnl=15
char id=57   x=32	y=183   width=15	height=20	xoffset=0	 yoffset=7	 xadvance=16	page=0  chnl=15
char id=58   x=248   y=209   width=7	 height=14	xoffset=0	 yoffset=14	xadvance=8	 page=0  chnl=15
char id=59   x=107   y=199   width=8	 height=17	xoffset=1	 yoffset=14	xadvance=9	 page=0  chnl=15
char id=60   x=77	y=238   width=16	height=13	xoffset=2	 yoffset=12	xadvance=20	page=0  chnl=15
char id=61   x=22	y=0	 width=19	height=8	 xoffset=0	 yoffset=15	xadvance=19	page=1  chnl=15
char id=62   x=94	y=233   width=16	height=13	xoffset=1	 yoffset=12	xadvance=20	page=0  chnl=15
char id=63   x=76	y=155   width=12	height=23	xoffset=0	 yoffset=6	 xadvance=13	page=0  chnl=15
char id=64   x=222   y=103   width=25	height=23	xoffset=1	 yoffset=6	 xadvance=27	page=0  chnl=15
char id=65   x=150   y=79	width=23	height=24	xoffset=0	 yoffset=4	 xadvance=23	page=0  chnl=15
char id=66   x=198   y=79	width=22	height=24	xoffset=1	 yoffset=3	 xadvance=23	page=0  chnl=15
char id=67   x=188   y=27	width=21	height=25	xoffset=0	 yoffset=4	 xadvance=22	page=0  chnl=15
char id=68   x=210   y=27	width=21	height=25	xoffset=1	 yoffset=4	 xadvance=23	page=0  chnl=15
char id=69   x=102   y=0	 width=21	height=27	xoffset=1	 yoffset=3	 xadvance=22	page=0  chnl=15
char id=70   x=113   y=104   width=17	height=24	xoffset=0	 yoffset=4	 xadvance=17	page=0  chnl=15
char id=71   x=89	y=155   width=23	height=22	xoffset=1	 yoffset=5	 xadvance=25	page=0  chnl=15
char id=72   x=174   y=79	width=23	height=24	xoffset=1	 yoffset=4	 xadvance=25	page=0  chnl=15
char id=73   x=240   y=53	width=15	height=24	xoffset=0	 yoffset=4	 xadvance=16	page=0  chnl=15
char id=74   x=146   y=0	 width=11	height=27	xoffset=1	 yoffset=4	 xadvance=14	page=0  chnl=15
char id=75   x=167   y=128   width=22	height=23	xoffset=0	 yoffset=4	 xadvance=22	page=0  chnl=15
char id=76   x=80	y=0	 width=21	height=27	xoffset=1	 yoffset=4	 xadvance=23	page=0  chnl=15
char id=77   x=154   y=54	width=28	height=24	xoffset=0	 yoffset=4	 xadvance=28	page=0  chnl=15
char id=78   x=212   y=53	width=27	height=24	xoffset=2	 yoffset=4	 xadvance=30	page=0  chnl=15
char id=79   x=52	y=81	width=24	height=24	xoffset=1	 yoffset=3	 xadvance=27	page=0  chnl=15
char id=80   x=23	y=110   width=22	height=24	xoffset=1	 yoffset=4	 xadvance=24	page=0  chnl=15
char id=81   x=27	y=0	 width=28	height=28	xoffset=2	 yoffset=3	 xadvance=27	page=0  chnl=15
char id=82   x=0	 y=85	width=26	height=24	xoffset=1	 yoffset=4	 xadvance=27	page=0  chnl=15
char id=83   x=143   y=28	width=22	height=25	xoffset=0	 yoffset=4	 xadvance=21	page=0  chnl=15
char id=84   x=66	y=28	width=25	height=25	xoffset=-1	yoffset=3	 xadvance=23	page=0  chnl=15
char id=85   x=50	y=134   width=23	height=23	xoffset=1	 yoffset=4	 xadvance=25	page=0  chnl=15
char id=86   x=69	y=106   width=21	height=24	xoffset=0	 yoffset=3	 xadvance=22	page=0  chnl=15
char id=87   x=85	y=54	width=34	height=24	xoffset=1	 yoffset=3	 xadvance=37	page=0  chnl=15
char id=88   x=235   y=127   width=19	height=23	xoffset=1	 yoffset=4	 xadvance=21	page=0  chnl=15
char id=89   x=39	y=159   width=18	height=23	xoffset=1	 yoffset=4	 xadvance=20	page=0  chnl=15
char id=90   x=221   y=0	 width=21	height=26	xoffset=0	 yoffset=4	 xadvance=21	page=0  chnl=15
char id=91   x=26	y=31	width=7	 height=26	xoffset=2	 yoffset=5	 xadvance=11	page=0  chnl=15
char id=92   x=243   y=0	 width=8	 height=26	xoffset=2	 yoffset=6	 xadvance=12	page=0  chnl=15
char id=93   x=18	y=31	width=7	 height=26	xoffset=2	 yoffset=5	 xadvance=11	page=0  chnl=15
char id=94   x=42	y=0	 width=14	height=6	 xoffset=0	 yoffset=10	xadvance=15	page=1  chnl=15
char id=95   x=229   y=252   width=19	height=3	 xoffset=-1	yoffset=27	xadvance=17	page=0  chnl=15
char id=96   x=103   y=247   width=7	 height=7	 xoffset=0	 yoffset=8	 xadvance=7	 page=0  chnl=15
char id=97   x=43	y=239   width=16	height=13	xoffset=0	 yoffset=14	xadvance=15	page=0  chnl=15
char id=98   x=160   y=152   width=16	height=21	xoffset=0	 yoffset=6	 xadvance=17	page=0  chnl=15
char id=99   x=221   y=224   width=13	height=13	xoffset=0	 yoffset=14	xadvance=14	page=0  chnl=15
char id=100  x=177   y=152   width=16	height=21	xoffset=1	 yoffset=6	 xadvance=17	page=0  chnl=15
char id=101  x=206   y=225   width=14	height=13	xoffset=0	 yoffset=14	xadvance=14	page=0  chnl=15
char id=102  x=146   y=152   width=13	height=22	xoffset=1	 yoffset=6	 xadvance=11	page=0  chnl=15
char id=103  x=162   y=174   width=15	height=19	xoffset=1	 yoffset=13	xadvance=17	page=0  chnl=15
char id=104  x=194   y=152   width=16	height=21	xoffset=1	 yoffset=6	 xadvance=18	page=0  chnl=15
char id=105  x=0	 y=205   width=8	 height=19	xoffset=1	 yoffset=8	 xadvance=11	page=0  chnl=15
char id=106  x=244   y=78	width=9	 height=24	xoffset=-1	yoffset=8	 xadvance=10	page=0  chnl=15
char id=107  x=113   y=154   width=17	height=22	xoffset=0	 yoffset=5	 xadvance=17	page=0  chnl=15
char id=108  x=248   y=103   width=7	 height=22	xoffset=1	 yoffset=5	 xadvance=9	 page=0  chnl=15
char id=109  x=0	 y=225   width=26	height=14	xoffset=0	 yoffset=13	xadvance=26	page=0  chnl=15
char id=110  x=91	y=218   width=17	height=14	xoffset=0	 yoffset=13	xadvance=18	page=0  chnl=15
char id=111  x=191   y=210   width=15	height=14	xoffset=0	 yoffset=13	xadvance=16	page=0  chnl=15
char id=112  x=75	y=203   width=15	height=18	xoffset=1	 yoffset=14	xadvance=17	page=0  chnl=15
char id=113  x=9	 y=205   width=17	height=18	xoffset=1	 yoffset=14	xadvance=19	page=0  chnl=15
char id=114  x=173   y=241   width=13	height=13	xoffset=1	 yoffset=14	xadvance=15	page=0  chnl=15
char id=115  x=242   y=238   width=11	height=13	xoffset=1	 yoffset=14	xadvance=13	page=0  chnl=15
char id=116  x=191   y=194   width=12	height=15	xoffset=1	 yoffset=12	xadvance=14	page=0  chnl=15
char id=117  x=159   y=227   width=15	height=13	xoffset=1	 yoffset=14	xadvance=16	page=0  chnl=15
char id=118  x=109   y=217   width=16	height=14	xoffset=0	 yoffset=13	xadvance=16	page=0  chnl=15
char id=119  x=204   y=194   width=27	height=14	xoffset=0	 yoffset=13	xadvance=27	page=0  chnl=15
char id=120  x=111   y=232   width=15	height=13	xoffset=1	 yoffset=14	xadvance=18	page=0  chnl=15
char id=121  x=27	y=205   width=15	height=18	xoffset=1	 yoffset=14	xadvance=17	page=0  chnl=15
char id=122  x=175   y=194   width=15	height=15	xoffset=1	 yoffset=13	xadvance=17	page=0  chnl=15
char id=123  x=53	y=55	width=11	height=25	xoffset=0	 yoffset=5	 xadvance=12	page=0  chnl=15
char id=124  x=0	 y=0	 width=4	 height=31	xoffset=2	 yoffset=1	 xadvance=9	 page=0  chnl=15
char id=125  x=41	y=55	width=11	height=25	xoffset=1	 yoffset=5	 xadvance=13	page=0  chnl=15
char id=126  x=78	y=0	 width=17	height=5	 xoffset=0	 yoffset=15	xadvance=17	page=1  chnl=15
char id=133  x=57	y=0	 width=20	height=5	 xoffset=1	 yoffset=23	xadvance=22	page=1  chnl=15
char id=145  x=250   y=151   width=5	 height=10	xoffset=0	 yoffset=5	 xadvance=5	 page=0  chnl=15
char id=146  x=249   y=224   width=6	 height=10	xoffset=0	 yoffset=5	 xadvance=5	 page=0  chnl=15
char id=147  x=11	y=0	 width=10	height=10	xoffset=0	 yoffset=5	 xadvance=11	page=1  chnl=15
char id=148  x=127   y=245   width=10	height=10	xoffset=1	 yoffset=5	 xadvance=11	page=0  chnl=15
char id=150  x=117   y=0	 width=14	height=4	 xoffset=1	 yoffset=17	xadvance=13	page=1  chnl=15
char id=151  x=96	y=0	 width=20	height=4	 xoffset=1	 yoffset=17	xadvance=20	page=1  chnl=15
char id=168  x=5	 y=0	 width=21	height=30	xoffset=1	 yoffset=0	 xadvance=22	page=0  chnl=15
char id=173  x=132   y=0	 width=11	height=4	 xoffset=0	 yoffset=17	xadvance=11	page=1  chnl=15
char id=174  x=238   y=151   width=11	height=21	xoffset=0	 yoffset=6	 xadvance=12	page=0  chnl=15
char id=176  x=94	y=247   width=8	 height=7	 xoffset=1	 yoffset=8	 xadvance=10	page=0  chnl=15
char id=177  x=144   y=176   width=17	height=19	xoffset=1	 yoffset=6	 xadvance=18	page=0  chnl=15
char id=181  x=0	 y=183   width=11	height=21	xoffset=0	 yoffset=6	 xadvance=12	page=0  chnl=15
char id=182  x=226   y=152   width=11	height=21	xoffset=0	 yoffset=6	 xadvance=12	page=0  chnl=15
char id=183  x=12	y=183   width=11	height=21	xoffset=0	 yoffset=6	 xadvance=12	page=0  chnl=15
char id=184  x=178   y=174   width=14	height=19	xoffset=0	 yoffset=8	 xadvance=14	page=0  chnl=15
char id=192  x=126   y=79	width=23	height=24	xoffset=0	 yoffset=4	 xadvance=23	page=0  chnl=15
char id=193  x=91	y=105   width=21	height=24	xoffset=1	 yoffset=3	 xadvance=24	page=0  chnl=15
char id=194  x=221   y=78	width=22	height=24	xoffset=1	 yoffset=3	 xadvance=23	page=0  chnl=15
char id=195  x=58	y=158   width=17	height=23	xoffset=1	 yoffset=4	 xadvance=19	page=0  chnl=15
char id=196  x=199   y=0	 width=21	height=26	xoffset=2	 yoffset=4	 xadvance=24	page=0  chnl=15
char id=197  x=124   y=0	 width=21	height=27	xoffset=1	 yoffset=3	 xadvance=22	page=0  chnl=15
char id=198  x=131   y=104   width=30	height=23	xoffset=1	 yoffset=4	 xadvance=32	page=0  chnl=15
char id=199  x=213   y=128   width=21	height=23	xoffset=0	 yoffset=4	 xadvance=22	page=0  chnl=15
char id=200  x=74	y=131   width=23	height=23	xoffset=1	 yoffset=4	 xadvance=25	page=0  chnl=15
char id=201  x=56	y=0	 width=23	height=27	xoffset=1	 yoffset=0	 xadvance=25	page=0  chnl=15
char id=202  x=144   y=128   width=22	height=23	xoffset=0	 yoffset=4	 xadvance=22	page=0  chnl=15
char id=203  x=118   y=28	width=24	height=25	xoffset=1	 yoffset=4	 xadvance=25	page=0  chnl=15
char id=204  x=183   y=54	width=28	height=24	xoffset=0	 yoffset=4	 xadvance=28	page=0  chnl=15
char id=205  x=102   y=79	width=23	height=24	xoffset=1	 yoffset=4	 xadvance=25	page=0  chnl=15
char id=206  x=27	y=84	width=24	height=24	xoffset=1	 yoffset=3	 xadvance=27	page=0  chnl=15
char id=207  x=25	y=135   width=24	height=23	xoffset=0	 yoffset=4	 xadvance=24	page=0  chnl=15
char id=208  x=0	 y=110   width=22	height=24	xoffset=1	 yoffset=4	 xadvance=24	page=0  chnl=15
char id=209  x=166   y=28	width=21	height=25	xoffset=0	 yoffset=4	 xadvance=22	page=0  chnl=15
char id=210  x=92	y=28	width=25	height=25	xoffset=-1	yoffset=3	 xadvance=23	page=0  chnl=15
char id=211  x=20	y=159   width=18	height=23	xoffset=0	 yoffset=4	 xadvance=18	page=0  chnl=15
char id=212  x=192   y=104   width=29	height=23	xoffset=1	 yoffset=4	 xadvance=31	page=0  chnl=15
char id=213  x=0	 y=159   width=19	height=23	xoffset=1	 yoffset=4	 xadvance=21	page=0  chnl=15
char id=214  x=232   y=27	width=21	height=25	xoffset=1	 yoffset=4	 xadvance=23	page=0  chnl=15
char id=215  x=98	y=130   width=22	height=23	xoffset=1	 yoffset=4	 xadvance=24	page=0  chnl=15
char id=216  x=162   y=104   width=29	height=23	xoffset=0	 yoffset=4	 xadvance=30	page=0  chnl=15
char id=217  x=167   y=0	 width=31	height=26	xoffset=0	 yoffset=4	 xadvance=32	page=0  chnl=15
char id=218  x=190   y=128   width=22	height=23	xoffset=1	 yoffset=4	 xadvance=25	page=0  chnl=15
char id=219  x=120   y=54	width=33	height=24	xoffset=1	 yoffset=4	 xadvance=36	page=0  chnl=15
char id=220  x=121   y=129   width=22	height=23	xoffset=1	 yoffset=4	 xadvance=24	page=0  chnl=15
char id=221  x=0	 y=59	width=21	height=25	xoffset=1	 yoffset=4	 xadvance=23	page=0  chnl=15
char id=222  x=34	y=29	width=31	height=25	xoffset=0	 yoffset=3	 xadvance=32	page=0  chnl=15
char id=223  x=77	y=80	width=24	height=24	xoffset=1	 yoffset=4	 xadvance=27	page=0  chnl=15
char id=224  x=60	y=238   width=16	height=13	xoffset=0	 yoffset=14	xadvance=15	page=0  chnl=15
char id=225  x=131   y=153   width=14	height=22	xoffset=1	 yoffset=5	 xadvance=16	page=0  chnl=15
char id=226  x=159   y=241   width=13	height=13	xoffset=1	 yoffset=14	xadvance=15	page=0  chnl=15
char id=227  x=229   y=238   width=12	height=13	xoffset=0	 yoffset=14	xadvance=13	page=0  chnl=15
char id=228  x=211   y=152   width=14	height=21	xoffset=0	 yoffset=6	 xadvance=15	page=0  chnl=15
char id=229  x=191   y=225   width=14	height=13	xoffset=0	 yoffset=14	xadvance=14	page=0  chnl=15
char id=230  x=52	y=223   width=19	height=14	xoffset=1	 yoffset=13	xadvance=21	page=0  chnl=15
char id=231  x=235   y=224   width=13	height=13	xoffset=0	 yoffset=14	xadvance=14	page=0  chnl=15
char id=232  x=127   y=231   width=15	height=13	xoffset=1	 yoffset=14	xadvance=17	page=0  chnl=15
char id=233  x=91	y=200   width=15	height=17	xoffset=1	 yoffset=10	xadvance=17	page=0  chnl=15
char id=234  x=221   y=209   width=13	height=14	xoffset=1	 yoffset=13	xadvance=14	page=0  chnl=15
char id=235  x=126   y=216   width=16	height=14	xoffset=0	 yoffset=13	xadvance=17	page=0  chnl=15
char id=236  x=24	y=240   width=18	height=13	xoffset=1	 yoffset=14	xadvance=20	page=0  chnl=15
char id=237  x=175   y=210   width=15	height=14	xoffset=0	 yoffset=13	xadvance=16	page=0  chnl=15
char id=238  x=159   y=212   width=15	height=14	xoffset=0	 yoffset=13	xadvance=16	page=0  chnl=15
char id=239  x=175   y=225   width=15	height=13	xoffset=1	 yoffset=14	xadvance=17	page=0  chnl=15
char id=240  x=43	y=204   width=15	height=18	xoffset=1	 yoffset=14	xadvance=17	page=0  chnl=15
char id=241  x=187   y=239   width=13	height=13	xoffset=0	 yoffset=14	xadvance=14	page=0  chnl=15
char id=242  x=0	 y=240   width=23	height=13	xoffset=1	 yoffset=14	xadvance=25	page=0  chnl=15
char id=243  x=59	y=204   width=15	height=18	xoffset=1	 yoffset=14	xadvance=17	page=0  chnl=15
char id=244  x=122   y=177   width=21	height=19	xoffset=0	 yoffset=13	xadvance=22	page=0  chnl=15
char id=245  x=143   y=229   width=15	height=13	xoffset=1	 yoffset=14	xadvance=18	page=0  chnl=15
char id=246  x=142   y=197   width=15	height=16	xoffset=1	 yoffset=14	xadvance=16	page=0  chnl=15
char id=247  x=201   y=239   width=13	height=13	xoffset=1	 yoffset=14	xadvance=15	page=0  chnl=15
char id=248  x=27	y=224   width=24	height=14	xoffset=1	 yoffset=14	xadvance=26	page=0  chnl=15
char id=249  x=116   y=199   width=25	height=16	xoffset=1	 yoffset=13	xadvance=27	page=0  chnl=15
char id=250  x=143   y=214   width=15	height=14	xoffset=1	 yoffset=13	xadvance=17	page=0  chnl=15
char id=251  x=72	y=223   width=18	height=14	xoffset=1	 yoffset=13	xadvance=20	page=0  chnl=15
char id=252  x=207   y=209   width=13	height=14	xoffset=1	 yoffset=13	xadvance=14	page=0  chnl=15
char id=253  x=235   y=209   width=12	height=14	xoffset=1	 yoffset=13	xadvance=14	page=0  chnl=15
char id=254  x=232   y=194   width=20	height=14	xoffset=2	 yoffset=13	xadvance=22	page=0  chnl=15
char id=255  x=215   y=239   width=13	height=13	xoffset=1	 yoffset=14	xadvance=15	page=0  chnl=15
 ]]
local estimateStringWidth = createFontWidthCalculator(fontData)



local function getWeaponTypeName(typeId)
	-- Use the weapon type from the API's constants
	--local weaponTypes = types.Weapon.TYPE
	--
	---- Find the name by comparing the ID with the API constants
	--for name, id in pairs(weaponTypes) do
	--	if id == typeId then
	--		-- Format the name (convert from e.g. "LongBlade" to "Long Blade")
	--		return name
	--	end
	--end
	
	--return "Unknown Weapon Type"
	if typeId == types.Weapon.TYPE.Arrow then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.AxeOneHand then
		return core.getGMST("sSkillAxe")..", "..core.getGMST("sOneHanded")
	elseif typeId == types.Weapon.TYPE.AxeTwoHand then
		return core.getGMST("sSkillAxe")..", "..core.getGMST("sTwoHanded")
	elseif typeId == types.Weapon.TYPE.BluntOneHand then
		return core.getGMST("sSkillBluntweapon")..", "..core.getGMST("sOneHanded")
	elseif typeId == types.Weapon.TYPE.BluntTwoClose then
		return core.getGMST("sSkillBluntweapon")..", "..core.getGMST("sTwoHanded")
	elseif typeId == types.Weapon.TYPE.BluntTwoWide then
		return core.getGMST("sSkillBluntweapon")..", "..core.getGMST("sTwoHanded")
	elseif typeId == types.Weapon.TYPE.Bolt then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.LongBladeOneHand then
		return core.getGMST("sSkillLongblade")..", "..core.getGMST("sOneHanded")
	elseif typeId == types.Weapon.TYPE.LongBladeTwoHand then
		return core.getGMST("sSkillLongblade")..", "..core.getGMST("sTwoHanded")
	elseif typeId == types.Weapon.TYPE.MarksmanBow then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.MarksmanCrossbow then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.MarksmanThrown then
		return core.getGMST("sSkillMarksman")
	elseif typeId == types.Weapon.TYPE.ShortBladeOneHand then
		return core.getGMST("sSkillShortblade")..", "..core.getGMST("sOneHanded")
	elseif typeId == types.Weapon.TYPE.SpearTwoWide then
		return core.getGMST("sSkillSpear")..", "..core.getGMST("sTwoHanded")
	end
	return "Unknown"
end

-- Get armor type name using the API
local function getArmorTypeName(typeId)
	-- Use the armor type from the API's constants
	local armorTypes = types.Armor.TYPE
	
	-- Find the name by comparing the ID with the API constants
	for name, id in pairs(armorTypes) do
		if id == typeId then
			return name
		end
	end
	
	return "Unknown Armor Type"
end

-- Get clothing type name using the API
local function getClothingTypeName(typeId)
	-- Use the clothing type from the API's constants
	local clothingTypes = types.Clothing.TYPE
	
	-- Find the name by comparing the ID with the API constants
	for name, id in pairs(clothingTypes) do
		if id == typeId then
			return name
		end
	end
	
	return "Unknown Clothing Type"
end


-- Get magic effect name using the API
local function getMagicEffectName(effectId)
	-- Use the magic effect from the API
	local effect = core.magic.effects.records[effectId]
	--local gm = core.getGMST("sEffect"..effectId)
	--print(effectId,effectId,gm,gm)
	if effectId == "fortifyskill" or effectId == "fortifyattribute" then
		return core.getGMST("sFortify")
	end
	-- If the effect exists, return its name
	if effect then
		return effect.name
	end
	
	return "Unknown Effect"
end

-- Get attribute name using the API
local function getAttributeName(attributeId)
	-- Get the attribute from the API's constants
	local attributes = core.stats.ATTRIBUTE
	
	-- Find the name by comparing the ID with the API constants
	for name, id in pairs(attributes) do
		if id == attributeId then
			return name
		end
	end
	
	return "Unknown Attribute"
end

-- Get skill name using the API
local function getSkillName(skillId)
	-- Get the skill from the API's constants
	local skills = core.stats.SKILL
	
	-- Find the name by comparing the ID with the API constants
	for name, id in pairs(skills) do
		if id == skillId then
			return name
		end
	end
	
	return "Unknown Skill"
end

-- Helper function for enchantment type names
local function getEnchantmentTypeName(typeId)
	local types = {
		[core.magic.ENCHANTMENT_TYPE.CastOnce] = "sItemCastOnce",
		[core.magic.ENCHANTMENT_TYPE.CastOnUse] = "sItemCastWhenUsed",
		[core.magic.ENCHANTMENT_TYPE.CastOnStrike] = "sItemCastWhenStrikes",
		[core.magic.ENCHANTMENT_TYPE.ConstantEffect] = "sItemCastConstant"
	}

	return core.getGMST(types[typeId] or "sMagicEffects")
end


-- Get detailed weapon data
local function getWeaponData(weapon)
	local record = types.Weapon.record(weapon)
   -- local durability = types.Weapon.durability(weapon)
	local durabilityCurrent = types.Item.itemData(weapon).condition
	local durabilityMax = types.Weapon.records[weapon.recordId].health
	
	
	return {
		type = record.type,
		typeName = getWeaponTypeName(record.type),
		subtype = record.subtype,
		damage = {
			chopMin = record.chopMinDamage,
			chopMax = record.chopMaxDamage,
			slashMin = record.slashMinDamage,
			slashMax = record.slashMaxDamage, 
			thrustMin = record.thrustMinDamage,
			thrustMax = record.thrustMaxDamage,
			
		},
		speed = record.speed,
		reach = record.reach,
		--ignoresNormalWeaponResistance = record.ignoresNormalWeaponResistance,
		--silver = record.silver,
		durability = durabilityCurrent and {
			current = durabilityCurrent,
			max = durabilityMax
		}
	}
end

-- Get detailed armor data
local function getArmorData(armor)
	local record = types.Armor.record(armor)
	--local durability = types.Armor.durability(armor)
	local durabilityCurrent = types.Item.itemData(armor).condition
	local durabilityMax = record.health
	--print((durabilityCurrent or "nil").." / "..(durabilityMax or "nil"))
	local baseArmor = record.baseArmor
	local referenceWeight = 0
	local recordType = record.type
	if recordType == types.Armor.TYPE.Boots then
		referenceWeight = core.getGMST("iBootsWeight")
	elseif recordType == types.Armor.TYPE.Cuirass then
		referenceWeight = core.getGMST("iCuirassWeight")
	elseif recordType == types.Armor.TYPE.Greaves then
		referenceWeight = core.getGMST("iGreavesWeight")
	elseif recordType == types.Armor.TYPE.Helmet then
		referenceWeight = core.getGMST("iHelmWeight")
	elseif recordType == types.Armor.TYPE.LBracer then
		referenceWeight = core.getGMST("iGauntletWeight")
	elseif recordType == types.Armor.TYPE.RBracer then
		referenceWeight = core.getGMST("iGauntletWeight")
	elseif recordType == types.Armor.TYPE.LPauldron then
		referenceWeight = core.getGMST("iPauldronWeight")
	elseif recordType == types.Armor.TYPE.RPauldron then
		referenceWeight = core.getGMST("iPauldronWeight")
	elseif recordType == types.Armor.TYPE.LGauntlet then
		referenceWeight = core.getGMST("iGauntletWeight")
	elseif recordType == types.Armor.TYPE.RGauntlet then
		referenceWeight = core.getGMST("iGauntletWeight")
	elseif recordType == types.Armor.TYPE.Shield then
		referenceWeight = core.getGMST("iShieldWeight")
	end
	local epsilon = 5e-4
	local class = "???"
	local skill = 0
	if record.weight == 0 then
		class = core.getGMST("sSkillUnarmored")
		skill = types.Player.stats.skills.unarmored(self).modified
	elseif record.weight <= referenceWeight * core.getGMST("fLightMaxMod") + epsilon then
		class = core.getGMST("sSkillLightarmor")
		skill = types.Player.stats.skills.lightarmor(self).modified
	elseif record.weight <= referenceWeight * core.getGMST("fMedMaxMod") + epsilon then
		class = core.getGMST("sSkillMediumarmor")
		skill = types.Player.stats.skills.mediumarmor(self).modified
	else
		class = core.getGMST("sSkillHeavyarmor")
		skill = types.Player.stats.skills.heavyarmor(self).modified
	end
	local playerArmor = baseArmor * skill / core.getGMST("iBaseArmorSkill")
	return {
		type = recordType,
		typeName = getArmorTypeName(record.type),
		baseArmor = baseArmor,
		class = class,
		playerArmor = playerArmor,
		durability = durabilityCurrent and {
			current = durabilityCurrent or 0,
			max = durabilityMax or 0
		}
	}
end

-- Get detailed clothing data
local function getClothingData(clothing)
	local record = types.Clothing.record(clothing)
	
	return {
		type = record.type,
		typeName = getClothingTypeName(record.type),
		enchantCapacity = record.enchantCapacity
	}
end


local function getEffects(eff, type)
	local effects = {}
	for i, effect in ipairs(eff) do
		local text = getMagicEffectName(effect.id)
		if effect.affectedSkill then
			text = text.." "..(core.getGMST("sSkill"..effect.affectedSkill) or "??")
		elseif effect.affectedAttribute then
			text = text.." "..(core.getGMST("sAttribute"..effect.affectedAttribute) or "??")
		end
		local effectPrototype = core.magic.effects.records[effect.id]
		if effectPrototype.hasMagnitude then
			if effect.magnitudeMin == effect.magnitudeMax then
				text = text.." "..effect.magnitudeMin
			else
				text = text.." "..effect.magnitudeMin.."-"..effect.magnitudeMax
			end
			text = text.." "..core.getGMST("sPoints")
		end
		if type ~= "constant" then --enchantmentRecord.type ~= core.magic.ENCHANTMENT_TYPE.ConstantEffect then
			if effectPrototype.hasDuration then
				local dur = math.max(1,effect.duration)
				text = text.." "..core.getGMST("sfor")
				text = text.." "..dur
				if dur == 1 then
					text = text.." "..core.getGMST("ssecond")
				else
					text = text.." "..core.getGMST("sseconds")
				end
			end
			if type ~= "potion" then
				text = text.." "..core.getGMST("sonword")
				if effect.range == core.magic.RANGE.Self then
					text = text.." "..core.getGMST("sRangeSelf")
				elseif effect.range == core.magic.RANGE.Target then
					text = text.." "..core.getGMST("sRangeTarget")		
				elseif effect.range == core.magic.RANGE.Touch then
					text = text.." "..core.getGMST("sRangeTouch")
				end
			end
		end
		--if effect.id >= 0 then -- Valid effect
			table.insert(effects, {
				id = effect.id,
				text = text,
			   -- subEffect = effect.subEffect,
				skillId = effect.affectedSkill,
				attributeId = effect.affectedAttribute,
				range = effect.range,
				area = effect.area,
				icon = effect.effect.icon,
				duration = effect.duration,
				magnitude = {
					min = effect.magnitudeMin,
					max = effect.magnitudeMax
				}
			})
		--end
	end
	return effects
end


-- Get enchantment data if present
local function getEnchantmentData(item)
	-- Check if item has an enchantment
   --if not types.Enchantment.objectHasRecord(item) then
   --	return nil
   --end
	--core.magic.enchantments.records['marara's boon']
   -- local enchantment = types.Enchantment.record(item)
	local record = item.type.record(item)
	local enchantment = item and (record.enchant or record.enchant ~= "" and record.enchant )
	if not enchantment then return nil end
	
	local enchantmentRecord = core.magic.enchantments.records[enchantment]
	if not enchantmentRecord then return nil end
	
	local maxCharge = getMaxEnchantmentCharge(enchantmentRecord) --enchantmentRecord.charge or 0

	local charge = {
		current = types.Item.itemData(item).enchantmentCharge or 0,
		max = maxCharge
	}
	
	local effects = getEffects(enchantmentRecord.effects, enchantmentRecord.type == core.magic.ENCHANTMENT_TYPE.ConstantEffect and "constant")
	
	if enchantmentRecord.type == core.magic.ENCHANTMENT_TYPE.CastOnce then
		charge = nil
	elseif enchantmentRecord.type == core.magic.ENCHANTMENT_TYPE.ConstantEffect then
		charge = nil
	end
	
	
	return {
		type = enchantmentRecord.type,
		typeName = getEnchantmentTypeName(enchantmentRecord.type),
		cost = enchantmentRecord.cost,
		charge = charge,
		effects = effects,
		autocalc = enchantmentRecord.autocalcFlag
	}
end


-- Function to format effect description for display
local function getEffectDescription(effect)
	local desc = getMagicEffectName(effect.id)
	
	-- Add attribute or skill name if applicable
	if effect.attributeId >= 0 then
		desc = desc .. " " .. getAttributeName(effect.attributeId)
	elseif effect.skillId >= 0 then
		desc = desc .. " " .. getSkillName(effect.skillId)
	end
	
	-- Add magnitude
	if effect.magnitude[1] > 0 then
		if effect.magnitude[1] == effect.magnitude[2] then
			desc = desc .. " " .. effect.magnitude[1]
		else
			desc = desc .. " " .. effect.magnitude[1] .. "-" .. effect.magnitude[2]
		end
		
		-- Add percentage for certain effects
		local percentageEffects = {
			[28] = true, -- Weakness to Fire
			[29] = true, -- Weakness to Frost
			[30] = true, -- Weakness to Shock
			-- Add other percentage-based effects
		}
		
		if percentageEffects[effect.id] then
			desc = desc .. "%"
		end
	end
	
	-- Add duration if applicable
	if effect.duration > 0 then
		desc = desc .. " for " .. effect.duration .. " sec"
	end
	
	-- Add area if applicable
	if effect.area > 0 then
		desc = desc .. " in " .. effect.area .. " ft"
	end
	
	return desc
end

function getIngredientEffects(item)
	local effects = {}
	for a,effect in pairs(types.Ingredient.record(item).effects) do
		local text = getMagicEffectName(effect.id)
		if effect.affectedSkill then
			text = text.." "..(core.getGMST("sSkill"..effect.affectedSkill) or "??")
		elseif effect.affectedAttribute then
			text = text.." "..(core.getGMST("sAttribute"..effect.affectedAttribute) or "??")
		end
		--if effect.id >= 0 then -- Valid effect?
		table.insert(effects, {
			id = effect.id,
			text = text,
			skillId = effect.affectedSkill,
			attributeId = effect.affectedAttribute,
			icon = effect.effect.icon,
		})
	end
	return effects
end

local function getItemInfo(item)
	if not item then return nil end
	local record = item.type.records[item.recordId]
	
	local info = {
		name = record.name,
		id = item.id,
		weight = record.weight,
		value = record.value,
		description = record.description or "",
		icon = record.icon
	}
	
	-- Determine item type and get type-specific data
	if types.Weapon.objectIsInstance(item) then
		info.type = "weapon"
		info.weaponData = getWeaponData(item)
	elseif types.Armor.objectIsInstance(item) then
		info.type = "armor"
		info.armorData = getArmorData(item)
	elseif types.Clothing.objectIsInstance(item) then
		info.type = "clothing"
		info.clothingData = getClothingData(item)
	elseif types.Ingredient.objectIsInstance(item) then
		info.type = "ingredient"
		info.ingredientEffects = getIngredientEffects(item)
	elseif types.Potion.objectIsInstance(item) then
		info.type = "potion"
		info.potionEffects = getEffects(types.Potion.record(item).effects, "potion")
	elseif types.Apparatus.objectIsInstance(item) then
		info.type = "apparatus"
		info.quality = types.Apparatus.record(item).quality
	elseif types.Lockpick.objectIsInstance(item) then
		info.type = "lockpick"
		info.quality = types.Lockpick.record(item).quality
		info.uses =  types.Item.itemData(item).condition
	elseif types.Probe.objectIsInstance(item) then
		info.type = "probe"
		info.quality = types.Probe.record(item).quality
		info.uses =  types.Item.itemData(item).condition
	elseif types.Repair.objectIsInstance(item) then
		info.type = "repair"
		info.quality = types.Repair.record(item).quality
		info.uses =  types.Item.itemData(item).condition
	end
	info.enchantment = getEnchantmentData(item)
	
	return info
end



-- MAIN FUNCTION
return function (item,highlightPosition) --makeTooltip
	if playerSection:get("TOOLTIP_MODE") == "off" then
		return
	end
	local itemRecord = item.type.records[item.recordId]
	local info = getItemInfo(item)

	local hudLayerSize = ui.layers[ui.layers.indexOf("HUD")].size
	local rootWidth = hudLayerSize.x * uiSize.x
	local rootHeight = hudLayerSize.y * uiSize.y
	local absPos = v2(hudLayerSize.x * uiLoc.x, hudLayerSize.y * uiLoc.y)

	local root = ui.create({
		type = ui.TYPE.Widget,
		layer = 'HUD',
		name = 'itemTooltip',
		props = {
		},
		content = ui.content {
		}
	})
	if playerSection:get("TOOLTIP_MODE") == "top" then
		root.layout.props = {
			anchor = v2(0.5,1), 
			position = v2(absPos.x, absPos.y-rootHeight/2),
			size = v2(100, 100),
		}
	elseif playerSection:get("TOOLTIP_MODE") == "bottom" then
		local temp = 0
		if playerSection:get("FOOTER_HINTS") == "Disabled" then
			temp = outerHeaderFooterHeight
		end
		root.layout.props = {
			anchor = v2(0.5,0), 
			position = v2(absPos.x, absPos.y+rootHeight/2+1-temp),
			size = v2(100, 100),
		}
	elseif playerSection:get("TOOLTIP_MODE") == "left" then
		root.layout.props = {
			anchor = v2(1,0), 
			position = v2(absPos.x-rootWidth/2, absPos.y-rootHeight/2+highlightPosition),
			size = v2(100, 100),
		}
	elseif playerSection:get("TOOLTIP_MODE") == "right" then
		root.layout.props = {
			anchor = v2(0,0), 
			position = v2(absPos.x+rootWidth/2, absPos.y-rootHeight/2+highlightPosition),
			size = v2(100, 100),
		}
	elseif playerSection:get("TOOLTIP_MODE") == "left (fixed)" then
		root.layout.props = {
			anchor = v2(1,0.5), 
			position = v2(absPos.x-rootWidth/2, absPos.y),
			size = v2(100, 100),
		}
	else --right (fixed)
		root.layout.props = {
			anchor = v2(0,0.5), 
			position = v2(absPos.x+rootWidth/2, absPos.y),
			size = v2(100, 100),
		}
	end
	
	table.insert(root.layout.content,
		{
			type = ui.TYPE.Image,
			props = {
				resource = background,
				tileH = false,
				tileV = false,
				relativeSize  = v2(1,1),
				size = v2(0,0),
				--size = v2(-borderOffset*2,itemBoxHeaderFooterHeight-borderOffset),
				position = v2(0,0),
				relativePosition = v2(0, 0),
				alpha = 0.4,
			}
		})
	--box BORDER
	table.insert(root.layout.content, {
		template = borderTemplate,
		props = {
			relativeSize  = v2(1,1),
			alpha = 0.5,
		}
	})
	local ench = item and (item.enchant or item.enchant ~= "" and item.enchant )
	local totalHeight = 0
	local maxWidth = 0
	local fontWidthMult = playerSection:get("TOOLTIP_FONT_WIDTH")
	local function textElement(str, color)
		table.insert(root.layout.content, { 
			type = ui.TYPE.Text,
			template = quickLootText,
			props = {
				text = " "..str.." ",--..hextoutf8(0xd83d)..hextoutf8(0xd83e),--thingName..countText,
				textSize = itemFontSize*textSizeMult,--itemFontSize*textSizeMult,
				size = v2(0,itemFontSize*textSizeMult),
				relativeSize  = v2(0,1),
				relativePosition = v2(0.5, 0),
				position = v2(0,totalHeight),
				anchor = v2(0.5,0),
				textAlignH = ui.ALIGNMENT.Center,
				textColor = color,
			},
		})
		totalHeight = totalHeight + itemFontSize*textSizeMult
		maxWidth = math.max(maxWidth, estimateStringWidth(str) * itemFontSize*textSizeMult*fontWidthMult)
	end
	
	totalHeight = totalHeight + 1
	local name = info.name
	if item.count and item.count > 1 then
		name = name.." ("..item.count..")"
	end
	textElement(name, playerSection:get("ICON_TINT"))
	totalHeight = totalHeight + 1
	if info.uses then
		textElement(core.getGMST("sUses")..": "..math.floor(info.uses))
	end
	if info.quality then
		textElement(core.getGMST("sQuality")..": "..math.floor(info.quality*10+0.5)/10)
	end
	if info.type == "armor" then
		textElement(core.getGMST("sArmorRating")..": ".. math.floor(info.armorData.playerArmor))
	end
	
	if info.type == "weapon" then
		textElement(core.getGMST("sType").." ".. info.weaponData.typeName)
		if info.weaponData.typeName == core.getGMST("sSkillMarksman") then
			textElement(core.getGMST("sAttack")..": ".. info.weaponData.damage.chopMin.."-"..info.weaponData.damage.chopMax)
		else
			textElement(core.getGMST("sChop")..": ".. info.weaponData.damage.chopMin.."-"..info.weaponData.damage.chopMax)
			textElement(core.getGMST("sSlash")..": ".. info.weaponData.damage.slashMin.."-"..info.weaponData.damage.slashMax)
			textElement(core.getGMST("sThrust")..": ".. info.weaponData.damage.thrustMin.."-"..info.weaponData.damage.thrustMax)
		end
	end
	
	local weaponOrArmor = info.weaponData or info.armorData
	if weaponOrArmor and weaponOrArmor.durability then
		textElement(core.getGMST("sCondition")..": ".. weaponOrArmor.durability.current.."/"..weaponOrArmor.durability.max)
	end
	
	if info.weight then
		local armorClass = info.armorData and info.armorData.class
		if armorClass then
			armorClass = " ("..armorClass..")"
		else
			armorClass = ""
		end
		textElement(core.getGMST("sWeight")..": ".. formatNumber(info.weight, "weight")..armorClass)
	end
	if info.value then
		textElement(core.getGMST("sValue")..": ".. formatNumber(info.value, "value"))
	end
	
	
	local function printEffects(effects)
		for a,effect in pairs(effects) do
			local flex ={
				type = ui.TYPE.Flex,
				props = {
					position = v2(0, 0),
					size = v2(0,itemFontSize*textSizeMult),
					position = v2(0,totalHeight),
					anchor = v2(0.5,0),
					relativePosition = v2(0.5, 0),
					horizontal = true,
				},
				content = ui.content({})
			}
			table.insert(root.layout.content,flex)
			--textElement(effect.text)
			table.insert(flex.content, {
				type = ui.TYPE.Image,
				props = {
					resource = getTexture(effect.icon),
					tileH = false,
					tileV = false,
					size = v2(itemFontSize*textSizeMult-1,itemFontSize*textSizeMult-1),
					alpha = 0.7,
				}
			})
			table.insert(flex.content, { 
				type = ui.TYPE.Text,
				template = quickLootText,
				props = {
					text = " "..effect.text.." ",
					textSize = itemFontSize*textSizeMult,
					size = v2(0,itemFontSize*textSizeMult),
					textAlignH = ui.ALIGNMENT.Center,
				},
			})
			totalHeight = totalHeight + itemFontSize*textSizeMult
			maxWidth = math.max(maxWidth, estimateStringWidth(effect.text) * itemFontSize*textSizeMult*fontWidthMult + itemFontSize*textSizeMult-1)
		end
	end
	
	if info.enchantment then
		textElement(info.enchantment.typeName or "???")
		totalHeight = totalHeight + 2
		printEffects(info.enchantment.effects)
		if info.enchantment.charge then
			totalHeight = totalHeight + 3
			--textElement(info.enchantment.charge.current.." / "..info.enchantment.charge.max)
			local flex ={
				type = ui.TYPE.Flex,
				props = {
					position = v2(0, 0),
					size = v2(0,itemFontSize*textSizeMult),
					position = v2(0,totalHeight),
					anchor = v2(0.5,0),
					relativePosition = v2(0.5, 0),
					horizontal = true,
				},
				content = ui.content({})
			}
			table.insert(root.layout.content,flex)
			--textElement(effect.text)
			table.insert(flex.content, { 
				type = ui.TYPE.Text,
				template = quickLootText,
				props = {
					text = core.getGMST("sCharges").." ",
					textSize = itemFontSize*textSizeMult,
					size = v2(0,itemFontSize*textSizeMult),
					textAlignH = ui.ALIGNMENT.Center,
				},
			})
			-- PROGRESS BAR
			local progressBar = 
			{
				type = ui.TYPE.Widget,
				props = {
					size = v2(itemFontSize*textSizeMult*6, itemFontSize*textSizeMult),
					anchor = v2(0.5,0),
					relativePosition = v2(0.5, 0),
				},
				content = ui.content {}
			}
			table.insert(flex.content, progressBar)
			table.insert(progressBar.content, {
				type = ui.TYPE.Image,
				props = {
					resource = background,
					tileH = false,
					tileV = false,
					relativeSize  = v2(1,1),
					relativePosition = v2(0,0),
					alpha = 0.3,
				}
			})
			table.insert(progressBar.content, {
				type = ui.TYPE.Image,
				props = {
					resource = white,
					tileH = false,
					tileV = false,
					relativeSize  = v2(math.min(1,info.enchantment.charge.current/info.enchantment.charge.max),1),
					relativePosition = v2(0,0),
					alpha = 0.8,
					color = util.color.hex("9c2e17"),
				}
			})
			table.insert(progressBar.content, { 
				type = ui.TYPE.Text,
				template = quickLootText,
				props = {
					text = info.enchantment.charge.current.." / "..info.enchantment.charge.max,--..hextoutf8(0xd83d)..hextoutf8(0xd83e),--thingName..countText,
					textSize = itemFontSize*textSizeMult,--itemFontSize*textSizeMult,
					size = v2(0,itemFontSize*textSizeMult),
					relativeSize  = v2(0,1),
					relativePosition = v2(0.5, 0),
					anchor = v2(0.5,0),
					textAlignH = ui.ALIGNMENT.Center,
					textColor = color,
				},
			})
			
			table.insert(progressBar.content, {
				template = borderTemplate,
				props = {
					relativeSize  = v2(1,1),
					alpha = 0.5,
				}
			})
		
			totalHeight = totalHeight + itemFontSize*textSizeMult
			maxWidth = math.max(maxWidth, estimateStringWidth(core.getGMST("sCharges").." ")* itemFontSize*textSizeMult*fontWidthMult+itemFontSize*textSizeMult*6)
		end
	end
	if info.potionEffects then
		totalHeight = totalHeight + 1
		printEffects(info.potionEffects)
	end
	if info.ingredientEffects then
		totalHeight = totalHeight + 1
		local skill = types.Player.stats.skills.alchemy(self).modified
		local gmst = core.getGMST("fWortChanceValue")
		
		for i,effect in pairs(info.ingredientEffects) do
			if skill >= i * gmst then
				local flex ={
					type = ui.TYPE.Flex,
					props = {
						position = v2(0, 0),
						size = v2(0,itemFontSize*textSizeMult),
						position = v2(0,totalHeight),
						anchor = v2(0.5,0),
						relativePosition = v2(0.5, 0),
						horizontal = true,
					},
					content = ui.content({})
				}
				table.insert(root.layout.content,flex)
				table.insert(flex.content, {
					type = ui.TYPE.Image,
					props = {
						resource = getTexture(effect.icon),
						tileH = false,
						tileV = false,
						size = v2(itemFontSize*textSizeMult-1,itemFontSize*textSizeMult-1),
						alpha = 0.7,
					}
				})
				table.insert(flex.content, { 
					type = ui.TYPE.Text,
					template = quickLootText,
					props = {
						text = " "..effect.text.." ",
						textSize = itemFontSize*textSizeMult,
						size = v2(0,itemFontSize*textSizeMult),
						textAlignH = ui.ALIGNMENT.Center,
					},
				})
				totalHeight = totalHeight + itemFontSize*textSizeMult
				maxWidth = math.max(maxWidth, estimateStringWidth(effect.text) * itemFontSize*textSizeMult*fontWidthMult + itemFontSize*textSizeMult-1)
			else
				textElement("?")
			end
		end
		
	end
	totalHeight = totalHeight + 2
	root.layout.props.size = v2(maxWidth, totalHeight)
	--root:update()
	return root
end