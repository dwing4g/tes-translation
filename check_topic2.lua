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

local function lowerGBK(s)
	if not s:find "[A-Z]" then
		return s
	end
	if not s:find "[\x80-\xff]" then
		return s:lower()
	end
	local t = {}
	local i = 1
	while i <= #s do
		if s:byte(i) < 0x80 then
			t[#t + 1] = s:sub(i, i):lower()
			i = i + 1
		else
			t[#t + 1] = s:sub(i, i + 1)
			i = i + 2
		end
	end
	return table.concat(t)
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
		topics[#topics + 1] = { lowerGBK(et), lowerGBK(ct) }
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
	es = lowerGBK(es)
	cs = lowerGBK(cs)
	for _, topic in ipairs(topics) do
		if cs:find(topic[2], 1, true) and not es:find(topic[1], 1, true) then
			io.stdout:write(k, "\n", es, "\n", cs, "\n[", topic[1], "] => [", topic[2], "]\n\n")
			n = n + 1
		end
	end
end

errwrite("done (", n, " errors)")
