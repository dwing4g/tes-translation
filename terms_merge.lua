-- luajit terms_merge.lua terms.csv terms1.csv terms2.csv terms3.csv ... [-] ... termsN.csv
-- "term","trans1[xx]|trans2[yy]|...","note1[xx]|note2[yy]|..."
-- terms={ key:term(lower) value:{term=term, trans={tran1=xx,tran2=yy,...}, notes={note1=xx,note2=yy,...}} }

-- luajit terms_merge.lua terms.csv ~$cel_split.csv ~$ext2m\terms_split.csv ~$ext2t\terms_split.csv ~$ext2b\terms_split.csv - ~$terms.csv

local terms = {}
local function addTerms(term, tran, note, ifAbsent)
	term = term:gsub("^%s+", ""):gsub("%s+$", ""):gsub('""','"')
	tran = tran:gsub("^%s+", ""):gsub("%s+$", ""):gsub('""','"')
	note = note:gsub("^%s+", ""):gsub("%s+$", ""):gsub('""','"')
	local termLower = term:lower()
	local t = terms[termLower]
	if not t then
		t = { term = term, trans={}, notes={} }
		terms[termLower] = t
	elseif ifAbsent then
		return
	end
	if #term:gsub("%l", "") > #t.term:gsub("%l", "") then
		t.term = term
	end
	t.trans[tran] = (t.trans[tran] or 0) + 1
	if note ~= "" then
		t.notes[note] = (t.notes[note] or 0) + 1
	end
end

local f = io.open(arg[1], "wb")
if not f then error("ERROR: can not create: " .. arg[1]) end
local ifAbsent = false
for i = 2, #arg do
	if arg[i] == "-" then
		ifAbsent = true
	else
		local lineId = 0
		for line in io.lines(arg[i]) do
			lineId = lineId + 1
			local term, tran, note = line:match '^"(..-)","(..-)","(.*)"$'
			if term then
				term = term:gsub('""', '"')
				tran = tran:gsub('""', '"')
				note = note:gsub('""', '"')
			else
				term, tran, note = line:match '^([^,]+),([^,]+),([^,]*)$'
				if not term then
					error("ERROR: unknown line(" .. arg[i] .. ":" .. lineId .. "): " .. line)
				end
			end
			addTerms(term, tran, note, ifAbsent)
		end
	end
end

local function combine(t, alwaysNum)
	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end
	table.sort(keys, function(k1, k2)
		local c = t[k1] - t[k2]
		if c > 0 then return true  end
		if c < 0 then return false end
		c = #k1 - #k2
		if c < 0 then return true  end
		if c > 0 then return false end
		return k1 < k2
	end)
	local s = {}
	for i, k in ipairs(keys) do
		if i > 1 then
			s[#s + 1] = "|"
		end
		s[#s + 1] = k
		if t[k] > 1 and (alwaysNum or #keys > 1) then
			s[#s + 1] = "["
			s[#s + 1] = t[k]
			s[#s + 1] = "]"
		end
	end
	return table.concat(s)
end

local function writeCsvStr(s1, s2, s3)
	if	s1:find ','  or s2:find ','  or s3:find ',' or
		s1:find '^"' or s2:find '^"' or s3:find '^"' then
		f:write('"', s1:gsub('"', '""'), '","', s2:gsub('"', '""'), '","', s3:gsub('"', '""'), '"\n')
	else
		f:write(s1, ',', s2, ',', s3, '\n')
	end
end

local termsKeys = {}
for k in pairs(terms) do
	termsKeys[#termsKeys + 1] = k
end
table.sort(termsKeys)
for _, k in ipairs(termsKeys) do
	local t = terms[k]
	writeCsvStr(t.term, combine(t.trans), combine(t.notes))
end
f:close()
print "DONE!"
