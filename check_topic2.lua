-- luajit check_topic2.lua topics.txt tes3cn_Morrowind.ext.txt > errors2.txt

local io = io
local ipairs = ipairs
local arg = arg

local function errwrite(...)
	io.stderr:write(...)
end

local newLine = true
local function warn(...)
	if not newLine then
		newLine = true
		errwrite "\n"
	end
	errwrite("WARN: ", ...)
	errwrite "\n"
end

local topics_filename = arg[1]
local topics = {}
local i = 1
errwrite("loading ", topics_filename, " ... ")
newLine = false
local err = 0
local check0, check1 = {}, {}
for line in io.lines(topics_filename) do
	line = line:gsub("\r+$", "")
	local et, ct = line:match "^%s*%[(.-)%]%s*=>%s*%[(.-)%]"
	if et then
		topics[#topics + 1] = { et:lower(), ct:lower() }
		i = i + 1
	end
end
errwrite(i - 1, " topics\n")
newLine = true

local f = io.open(arg[2], "rb")
local s = f:read "*a"
f:close()

local n = 0
for k, es, cs in s:gmatch "(> INFO.NAME %C+)[\r\n]+(%C+)[\r\n]+(%C+)[\r\n]+" do
	es = es:lower()
	cs = cs:lower()
	for _, topic in ipairs(topics) do
		if cs:find(topic[2], 1, true) and not es:find(topic[1], 1, true) then
			io.stdout:write(k, "\n", es, "\n", cs, "\n[", topic[1], "] => [", topic[2], "]\n\n")
			n = n + 1
		end
	end
end

errwrite("done (", n, " errors)")
