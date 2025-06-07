-- md ext2
-- md ext2\BOOK
-- md ext2\INFO
-- luajit tes3ext2.lua _.ext.txt ext2

-- 考虑当做专有名词的有: *.FNAM; *.RNAM; 关键词(DIAL.NAME); 地名(CELL.NAME)
-- 参考专有名词再翻译的: RACE.DESC; CLAS.DESC; SCPT.SCTX; INFO.NAME/BNAM; BOOK.TEXT
local tags = {
	["ACTI.FNAM"] = true, -- 以下默认单个文件,文件名是前4字母的类名,其中每行一条(排序,不重复),扩展名:.txt,翻译后扩展名:.c.txt
	["ALCH.FNAM"] = true,
	["APPA.FNAM"] = true,
	["ARMO.FNAM"] = true,
	["BOOK.FNAM"] = true,
	["BOOK.TEXT"] = "BOOK", -- 子目录:BOOK,每条一个文件,文件名是BOOK的key(BOOK.NAME),扩展名:.txt,翻译后扩展名:.c.txt
	["BSGN.FNAM"] = true,
	["BSGN.DESC"] = true,
--	["CELL.NAME"] = true,
	["CLAS.FNAM"] = true, -- 仅TD有
	["CLAS.DESC"] = true, -- 仅TD有
	["CLOT.FNAM"] = true,
	["CONT.FNAM"] = true,
	["CREA.FNAM"] = true,
--	["DIAL.NAME"] = true,
	["DOOR.FNAM"] = true,
--	["ENCH.????"] = true,
	["FACT.FNAM"] = true,
	["FACT.RNAM"] = true,
	["GMST.STRV"] = true, -- 只有一部分会用于专有名词
	["INFO.NAME"] = "INFO", -- 子目录:INFO,文件名是关键词原文(DIAL.NAME),其中每行一条,扩展名:.k|e.txt,翻译后扩展名:.c.txt
	["INFO.BNAM"] = "INFO", -- 同上
	["INGR.FNAM"] = true,
	["LIGH.FNAM"] = true,
	["LOCK.FNAM"] = true,
	["MGEF.DESC"] = true,
	["MISC.FNAM"] = true,
	["NPC_.FNAM"] = true,
	["PROB.FNAM"] = true,
	["RACE.FNAM"] = true, -- 仅TD有
	["RACE.DESC"] = true, -- 仅TD有
	["REGN.FNAM"] = true,
	["REPA.FNAM"] = true,
	["SCPT.SCTX"] = true,
	["SKIL.DESC"] = true,
	["SPEL.FNAM"] = true,
	["WEAP.FNAM"] = true,
}
local newLineMark = "<n/>" -- 主要出现在INFO里的txt中

local function readStrExt(line, isFirst)
	if isFirst then
		if line:sub(1, 3) ~= '"""' then
			return line
		end
		line = line:sub(4, -1)
	end
	local p = line:reverse():find '"""'
	if p then
		return line:sub(1, -p - 3)
	end
	return line, true
end

io.write("loading '" .. arg[1] .. "' ... ")
local all = {}
local i, s = 0, 0
local tag, k, v1, v2
for line in io.lines(arg[1]) do
	i = i + 1
	if line ~= "" or s == 2 or s == 4 then
		if s == 0 then
			tag, k = line:match "^>%s+(.-)%s+(.+)$"
			if not tag then
				error("ERROR: require key line at line " .. i)
			end
			if not tags[tag] then
				error("ERROR: unknown key tag at line " .. i)
			end
			s = 1
		else
			if line:find "^> " and s ~= 2 and s ~= 4 then
				error("ERROR: invalid key line at line " .. i)
			end
			if s <= 2 then
				local t, r = readStrExt(line, s == 1)
				if tags[tag] ~= "BOOK" then
					if t:find(newLineMark, 1, true) then
						error("ERROR: found newLineMark at line " .. i)
					end
					v1 = v1 and (v1 .. newLineMark .. t) or t
				else
					v1 = v1 and (v1 .. "\n" .. t) or t
				end
				s = r and 2 or 3
			else
				local t, r = readStrExt(line, s == 3)
				v2 = v2 and (v2 .. "\n" .. t) or t
				if r then
					s = 4
				else
					local tag1 = tags[tag] == true and tag or tags[tag]
					all[tag1] = all[tag1] or {}
					if all[tag1][k] then
						error("ERROR: duplicated key '", k, "' for tag '", tag, "'")
					end
					if tag1 ~= "INFO" then
						all[tag1][k] = { k, v1, v2 }
					else
						local kw, kx = k:match(tag == "INFO.NAME" and "^(.+) (%d+)$" or "^(.+) (%d+ %w+)$")
						if not kw then
							error("ERROR: invalid key: '" .. k .. "'")
						end
						t = all[tag1][kw]
						if not t then
							t = {}
							all[tag1][kw] = t
						end
						t[#t + 1] = kx
						t[#t + 1] = v1
					end
					s, tag, k, v1, v2 = 0, nil, nil, nil, nil
				end
			end
		end
	end
end
print "OK!"

local fn = arg[2] .. "/terms.csv"
io.write("creating '", fn, "' ... ")
local ft = io.open(fn, "wb")
if not ft then
	error "ERROR: can not create"
end
for tag, st in pairs(all) do
	if tags[tag] == true then
		local isTerm = tag:find "%.[FR]NAM$"
		fn = arg[2] .. "/" .. tag .. ".txt"
		io.write("creating '", fn, "' ... ")
		local f = io.open(fn, "wb")
		if not f then
			error "ERROR: can not create"
		end
		local set = {}
		local es = {}
		for _, a in pairs(st) do
			local e = a[2]
			if not set[e] and e:find "%a" then
				set[e] = true
				es[#es + 1] = a
			end
		end
		table.sort(es, isTerm
			and function(a1, a2) return a1[2] < a2[2] end
			or  function(a1, a2) return a1[1] < a2[1] end)
		for _, a in ipairs(es) do
			local term = a[2]
			if isTerm then
				local trans = a[3]
				local note = tag -- .. " " .. a[1]
				if	term:find ','  or trans:find ','  or note:find ',' or
					term:find '^"' or trans:find '^"' then
					ft:write('"', term:gsub('"', '""'), '","', trans:gsub('"', '""'), '","', note:gsub('"', '""'), '"\n')
				else
					ft:write(term, ',', trans, ',', note, '\n')
				end
			end
			f:write(term, "\n")
		end
		f:close()
		print "OK!"
	elseif tag == "INFO" then
		for key, kes in pairs(st) do
			fn = arg[2] .. "/INFO/" .. key:gsub(":", "：")
			io.write("creating '", fn, ".k|e.txt' ... ")
			local fk = io.open(fn .. ".k.txt", "wb")
			local fe = io.open(fn .. ".e.txt", "wb")
			if not fk or not fe then
				error "ERROR: can not create"
			end
			for i = 1, #kes, 2 do
				fk:write(kes[i], "\n")
				fe:write(kes[i + 1], "\n")
			end
			fk:close()
			fe:close()
			print "OK!"
		end
	elseif tag == "BOOK" then
		for k, a in pairs(st) do
			fn = arg[2] .. "/BOOK/" .. k:gsub(":", "：") .. ".txt"
			io.write("creating '", fn, "' ... ")
			local f = io.open(fn, "wb")
			if not f then
				error "ERROR: can not create"
			end
			f:write(a[2])
			f:close()
			print "OK!"
		end
	end
end
ft:close()

print "DONE!"
