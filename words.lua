local function extWords()
	local t = {}
	local i = 0
	for line in io.lines "../ECDICT/ecdict.csv" do -- https://github.com/skywind3000/ECDICT
		i = i + 1
		local words
		if line:byte(1) == 0x22 then -- '"'
			words = line:match '^"(.-)",'
			if words then
				words = words:gsub('""', '"')
			end
		else
			words = line:match "^(.-),"
		end
		if not words then
			error("1: " .. i)
		end
--		if not words:find "^[%w%-+*/&$%%!?~_\"';:.,()%[%] ]+$" then
--			error("2: " .. i)
--		end
		if words:find "^%a%l+$" then
			t[words] = true
		end
	end

	local tt = {}
	for word in pairs(t) do
		tt[#tt + 1] = word
	end
	table.sort(tt)

	local f = io.open("words.txt", "wb")
	for _, word in ipairs(tt) do
		f:write(word, "\n")
	end
	f:close()

	print "done!"
end

local function calcWords()
	local words = {}
	for word in io.lines "words.txt" do
		if word:find "^%a%l+$" then
			words[word:lower()] = true
		end
	end

	local files = {
		"tes3cn_Morrowind.ext.txt",
		"tes3cn_Tribunal.ext.txt",
		"tes3cn_Bloodmoon.ext.txt",
	}
	local t = {}
	for _, file in ipairs(files) do
		for line in io.lines(file) do
			line = line:gsub("\r+$", "")
			if not line:find "^> " then
				for word in line:gmatch "%a%l+" do
					word = word:lower()
					if not words[word] then
						t[word] = (t[word] or 0) + 1
					end
				end
			end
		end
	end

	local tt = {}
	for word in pairs(t) do
		tt[#tt + 1] = word
	end
	table.sort(tt, function(a, b)
		if t[a] ~= t[b] then
			return t[a] > t[b]
		end
		return a < b
	end)

	local f = io.open("words1.txt", "wb")
	for _, word in ipairs(tt) do
		f:write(word, "\t", t[word], "\n")
	end
	f:close()

	print "done!"
end

-- extWords()
calcWords()
