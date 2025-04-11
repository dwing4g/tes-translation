-- luajit check_topic3.lua tes3cn_Morrowind.ext.txt 3 > errors3.txt

local ignores = {
	迪德拉式 = true,
	工作 = true,
	瓜尔 = true,
	老鼠 = true,
	忙 = true,
	沙尔 = true,
	事 = true,
	卫兵 = true,
	这些药水 = true,
}

local N = tonumber(arg[2])
local i = 0
for line in io.lines(arg[1]) do
	i = i + 1
	local topics = line:match " {([^}]+)}$"
	if topics then
		local n = 0
		for topic in topics:gmatch "[^,]+" do
			if not ignores[topic] then
				n = n + 1
			end
		end
		if n >= N then
			print("[" .. i .. "]: " .. line)
		end
	end
end
