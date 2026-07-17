-- update topicB.txt by using topicA.txt
-- luajit update_topic.lua topicA.txt topicB.txt

local io = io
local arg = arg

io.stderr:write("loading ", arg[1], " ... ")
local topics = {}
local n = 0
for line in io.lines(arg[1]) do
	local topic, checkTopic = line:match "%[(.-)%]%s*=>%s*%[(.-)%]"
	if topic then
		topics[topic] = checkTopic
		n = n + 1
	end
end
io.stderr:write(n, " topics\n")

io.stderr:write("loading ", arg[2], " ... ")
local lines = {}
local n = 0
for line in io.lines(arg[2]) do
	local topic, checkTopic = line:match "%[(.-)%]%s*=>%s*%[(.-)%]"
	if topic and topics[topic] and topics[topic] ~= checkTopic then
		lines[#lines + 1] = "[" .. topic .. "] => [" .. topics[topic] .. "]\n"
		n = n + 1
	else
		lines[#lines + 1] = line .. "\n"
	end
end
io.stderr:write(n, " topics updated\n")

io.stderr:write("loading ", arg[2], " ... ")
local f = io.open(arg[2], "wb")
f:write(table.concat(lines))
f:close()
io.stderr:write(#lines, " lines\n")
