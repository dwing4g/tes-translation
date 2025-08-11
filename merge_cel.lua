-- luajit merge_cel.lua A.cel [B.cel ...] AB.cel

local io = io
local arg = arg

local cels = {}
local err = 0

local function errwrite(...)
	io.stderr:write(...)
end

local function loadCels(filename)
	errwrite("loading ", filename, " ... ")
	local newLine = false
	local i = 1
	for line in io.lines(filename) do
		line = line:gsub("\r+$", "")
		local cel, checkCel = line:match "^([^\t]+)\t+(.*)$"
		if not cel then
			if not newLine then newLine = true errwrite "\n" end
			errwrite("ERROR: invalid cel file at line ", i, ": ", line, "\n")
			err = err + 1
		else
			if cels[cel] then
				if checkCel ~= cel and cels[cel] ~= cel and cels[cel] ~= "" and cels[cel] ~= checkCel then
					if not newLine then newLine = true errwrite "\n" end
					errwrite("ERROR: unmatched translation of cel [", cel, "] => [", cels[cel], "] [", checkCel, "] at line ", i, "\n")
					err = err + 1
				end
				if cels[cel] == cel then
					cels[cel] = checkCel
				end
			else
				cels[cel] = checkCel
			end
			i = i + 1
		end
	end
	errwrite(i - 1, " cels\n")
end

for i = 1, #arg - 1 do
	loadCels(arg[i])
end

if err == 0 then
	local ks = {}
	for cel in pairs(cels) do
		ks[#ks + 1] = cel
	end
	table.sort(ks)

	errwrite("saving ", arg[#arg], " ... ")
	local f = io.open(arg[#arg], "wb")
	for _, cel in ipairs(ks) do
		f:write(cel, "\t", cels[cel], "\n")
	end
	f:close()
	errwrite(#ks, " cels\n")
else
	print("ERROR: " .. err .. " errors")
end
