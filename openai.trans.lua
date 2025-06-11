-- luajit openai.lua openai.trans.lua 输入.txt 输出.txt
-- luajit openai.lua openai.trans.lua TamrielRebuilt\TR_Mainland.cel TamrielRebuilt\TR_Mainland.c.cel
url = 'http://127.0.0.1:8080/v1/chat/completions'
openai_api_key = nil
model = nil
temperature = 0.01 -- for thinking
top_k = 20
top_p = 0.95
min_p = 0
repeat_last_n = 64 -- for thinking
repeat_penalty = 1.1 -- for thinking
max_tokens = -1
seed = 0
debug = nil
jsonHighSize = 8 * 1024 -- for 4k context + thinking
jsonLowSize = jsonHighSize * 0.75
lineLimitSize = jsonHighSize * 0.1 -- for batch mode

local filetypes = {
	{ "ACTI%.FNAM%.txt$"  , "地点和可交互物品名" },
	{ "ALCH%.FNAM%.txt$"  , "药水名" },
	{ "APPA%.FNAM%.txt$"  , "炼金器材名" },
	{ "ARMO%.FNAM%.txt$"  , "护甲名" },
	{ "BOOK%.FNAM%.txt$"  , "书信笔记标题" },
	{ "CLAS%.DESC%.txt$"  , "职业描述" },
	{ "CLAS%.FNAM%.txt$"  , "职业名" },
	{ "CLOT%.FNAM%.txt$"  , "服饰名" },
	{ "CONT%.FNAM%.txt$"  , "容器名" },
	{ "CREA%.FNAM%.txt$"  , "战斗单位名" },
	{ "DOOR%.FNAM%.txt$"  , "传送门名" },
	{ "FACT%.FNAM%.txt$"  , "家族名" },
	{ "FACT%.RNAM%.txt$"  , "家族成员名" },
	{ "INGR%.FNAM%.txt$"  , "炼金材料名" },
	{ "LIGH%.FNAM%.txt$"  , "灯源名" },
	{ "LOCK%.FNAM%.txt$"  , "开锁器名" },
	{ "MISC%.FNAM%.txt$"  , "杂项物品名" },
	{ "NPC_%.FNAM%.txt$"  , "NPC人名" },
	{ "PROB%.FNAM%.txt$"  , "侦测器名" },
	{ "RACE%.DESC%.txt$"  , "种族描述" },
	{ "RACE%.FNAM%.txt$"  , "种族名" },
	{ "REGN%.FNAM%.txt$"  , "区域名" },
	{ "REPA%.FNAM%.txt$"  , "修理锤名" },
	{ "SCPT%.SCTX%.txt$"  , "提示信息或对话" },
	{ "SPEL%.FNAM%.txt$"  , "法术名" },
	{ "WEAP%.FNAM%.txt$"  , "武器名" },
	{ "%.cel$"            , "地名" },
	{ "BOOK[/\\].*%.txt$" , "书信笔记内容" },
	{ "INFO[/\\].*%.txt$" , "对话和描述信息" },
}
local info
for _, filetype in ipairs(filetypes) do
	if arg[2]:find(filetype[1]) then
		info = filetype[2]
		break
	end
end
if not info then
	error("ERROR: unknown file type: " .. arg[2])
end
prompt = ([[
你是精通英文到简体中文翻译的好助手，下面将要翻译我每次提供的英文原文。我每次还会先提示一些专有名词的参考翻译。
原文出自一款西方奇幻风格角色扮演游戏中的**%s**，相邻原文可能上下文相关，以帮助理解每句话的含义。
你会理解原文每个词的含义，译文要遵循原文的风格和语气，调整用词、语序和标点以符合通顺自然的中文习惯，还要保证专有名词和术语的一致性。
如果遇到部分原文用<>括起来，则对此部分原样复制。每行译文要跟每行原文保持一一对应，行数一致，不能错位。在完整译文的前后用```括起来。
]]):format(info)

local tree = {}
local i = 0
for line in io.lines 'terms.csv' do
	i = i + 1
	line = local_utf8(line)
	local term, tran = line:match '^"(.+)","(.+)","'
	if not term then
		term, tran = line:match '^(.+),(.+),'
		if not term then
			error('ERROR: invalid line in terms.csv at line ' .. i)
		end
	end
	local node = tree
	for word in term:gsub("[^%w%%%-_']+", " "):lower():gmatch "[%w%%%-_']+" do
		local n = node[word]
		if not n then
			n = {}
			node[word] = n
		end
		node = n
	end
	if node == tree then
		error('ERROR: empty term at line ' .. i)
	end
	if node[1] then -- and node[2] ~= tran
		error('ERROR: duplicated terms: "' .. node[1] .. '" and "' .. term .. '"')
	end
	node[1] = term
	node[2] = tran
end

local lineCount, empties
filter_line_in = function(line, i)
	return line
end
filter_lines_in = function(lines, i)
	empties = {}
	local i = 0
	lineCount = 0
	for line in lines:gmatch '(.-)\n' do
		i = i + 1
		if line:find '^%s*$' then
			empties[i] = true
		else
			lineCount = lineCount + 1
		end
	end
	local words = {}
	for word in lines:gsub("[^%w%%%-_']+", " "):lower():gmatch "[%w%%%-_']+" do
		words[#words + 1] = word
	end
	local pres, set = {}, {}
	for i = 1, #words do
		local node, best = tree, nil
		for j = i, #words do
			node = node[words[j]]
			if not node then
				if best then
					local term = best[1]
					if not set[term] then
						set[term] = true
						if #pres == 0 then
							pres[1] = '专有名词的参考翻译:\n'
						end
						pres[#pres + 1] = term
						pres[#pres + 1] = '=>'
						pres[#pres + 1] = best[2]
						pres[#pres + 1] = '\n'
					end
				end
				break
			end
			if node[1] then
				best = node
			end
		end
	end
	local pre = table.concat(pres)
	io.write(utf8_local(pre))
	return pre .. '英文原文:\n' .. lines:gsub('%s*\n', '\n')
end
filter_line_out = function(res, i)
	local trans = {}
	local all, tran = res:gsub('^<think>.-</think>', ''):gsub('\r', ''):match '(```.-\n(.-)```)'
	local tran, n = tran:gsub('%s*\n', '\n')
	if n ~= lineCount then
		local msg = 'WARN: {{{ mismatched line count: ' .. n .. ' != ' .. lineCount .. '\n'
		io.write(msg)
		trans[1] = msg
	end
	i = 0
	for line in tran:gmatch '(.-)\n' do
		i = i + 1
		while empties[i] do
			i = i + 1
			trans[#trans + 1] = '\n'
		end
		trans[#trans + 1] = line
		trans[#trans + 1] = '\n'
	end
	while empties[i + 1] do
		i = i + 1
		trans[#trans + 1] = '\n'
	end
	if n ~= lineCount then
		trans[#trans + 1] = 'WARN: }}} mismatched line count: ' .. n .. ' != ' .. lineCount .. '\n'
	end
	lineCount = 0
	return all, table.concat(trans)
end
