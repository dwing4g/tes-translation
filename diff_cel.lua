local t1 = {}
for line in io.lines(arg[1]) do
	line = line:match '^(.+)\t'
	if line then
		t1[line] = true
	end
end

local t2 = {}
for line in io.lines(arg[2]) do
	line = line:match '^(.+)\t'
	if line then
		t2[line] = true
	end
end

for k in pairs(t1) do
	if not t2[k] then
		print('- ' .. k)
	end
end
for k in pairs(t2) do
	if not t1[k] then
		print('+ ' .. k)
	end
end
