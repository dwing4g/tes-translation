-- luajit terms_ext.lua terms.json terms.csv
-- "term": "'ata",
-- "translation": "阿塔",
-- "note": "夏暮岛命名习惯，ata后接母亲名，表某某的孩子。",

local f = io.open(arg[1], "rb")
local s = f:read "*a"
f:close()
if s:find "<[qrn]>" or s:find("|", 1, true) then
	error "ERROR: found mark"
end
s = s:gsub('\xef\xbb\xbf', '')
	 :gsub('\\"', '<q>')
	 :gsub('\\r', '') -- '<r>'
	 :gsub('\\n', '|') -- '<n>'

f = io.open(arg[2], "wb")
for term, trans, note in s:gmatch '"term"[:%s]+"(.-)"[,%s]+"translation"[:%s]+"(.-)"[,%s]+"note"[:%s]+"(.-)"' do
	if	term:find ','  or trans:find ','  or note:find ',' or
		term:find '^<q>' or trans:find '^<q>' or note:find '^<q>' then
		f:write('"', term:gsub('"', '""'), '","', trans:gsub('"', '""'), '","', note:gsub('"', '""'), '"\n')
	else
		f:write(term, ',', trans, ',', note, '\n')
	end
end
f:close()
print "DONE!"
