local ipairs = ipairs

local filenames = {
	"topics.txt",
	"Morrowind.cel",
	"tes3cn_Morrowind.ext.txt",
	"tes3cn_Tribunal.ext.txt",
	"tes3cn_Bloodmoon.ext.txt",
}

local forbids = arg[1] and arg or {
	"艾德拉", -- 伊德拉
	"艾德洛", -- 伊德拉
	"代德拉", -- 迪德拉
	"代德洛", -- 迪德拉
	"勒多兰", -- 瑞多然
	"希尔辛", -- 海尔辛
	"灰烬汉", -- 灰烬可汗
	"灰烬汗", -- 灰烬可汗
	"古拉汉", -- 古拉可汗
	"古拉汗", -- 古拉可汗
	"马拉卡斯", -- 玛拉凯斯
	"吉伽拉格", -- 杰盖拉格
	"谢尔格拉斯", -- 谢尔格拉
	"勒丹亚", -- 瑞达尼亚 Redaynia
	"勒斯丹", -- 瑞斯代尼亚 Resdaynia
}

for _, filename in ipairs(filenames) do
	local i = 0
	for line in io.lines(filename) do
		i = i + 1
		for _, forbid in ipairs(forbids) do
			if line:find(forbid, 1, true) then
				print(filename .. "(" .. i .. "): " .. forbid)
			end
		end
	end
end

print "done!"
