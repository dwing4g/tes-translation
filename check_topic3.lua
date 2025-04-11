-- luajit check_topic3.lua tes3cn_Morrowind.ext.txt 3 > errors3.txt

local ignores = {
	�ϵ���ʽ = true,
	���� = true,
	�϶� = true,
	���� = true,
	æ = true,
	ɳ�� = true,
	�� = true,
	���� = true,
	��Щҩˮ = true,
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
