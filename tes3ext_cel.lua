local cellBegin = false
local i = 0
for line in io.lines(arg[1]) do
	line = line:gsub("\r+$", "")
	i = i + 1
	if line == "-CELL" then
		cellBegin = true
	else
		if cellBegin then
			local name = line:match '^ CELL%.NAME "(.-)[$"]'
			if not name then
				error("ERROR: not found CELL.NAME at line " .. i)
			end
			if name ~= "" then
				print(name .. "\t" .. name)
			end
			cellBegin = false
		end
		if line:find '[Pp]osition[Cc]ell' then -- fast checking
			line = line:gsub('("".-"")', function(s) return s:gsub(';', '@TeS3ExTmArK@') end):gsub(';.*', ''):gsub('@TeS3ExTmArK@', ';') -- remove comment
			line = line:gsub('%s+$', '') -- trim
			local a1, name = line:match '[Pp]osition[Cc]ell[%s,]+([^%s,"]+)[%s,]+[^%s,"]+[%s,]+[^%s,"]+[%s,]+[^%s,"]+[%s,]+""(.-)""[$0"]*$' -- maybe end with '$00"'
			if name and a1 ~= 'in' then
				print(name .. "\t" .. name)
			else
				a1, name = line:match '[Pp]osition[Cc]ell[%s,]+([^%s,"]+)[%s,]+[^%s,"]+[%s,]+[^%s,"]+[%s,]+[^%s,"]+[%s,]+([%w_]+)[$0"]*$' -- maybe without ""
				if name and a1 ~= 'in' then
					print(name .. "\t" .. name)
				end
			end
		end
	end
end
