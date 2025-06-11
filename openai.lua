-- luajit openai.lua "input"
-- luajit openai.lua [settings.lua] input.txt output.txt
-- llama-server -m Qwen3-8B-Q4_K_M.gguf -c 4096 -n 4096 -ngl 100 --keep -1 --port 8080
-- curl -X POST -H "Content-Type: application/json" -T openai_upload.json -v "http://127.0.0.1:8080/v1/chat/completions"
--              -H "Authorization: Bearer $OPENAI_API_KEY"
--[[
{"model":"gpt-4o","stream":false,"cache_prompt":true,"temperature":0.1,"top_k":20,"top_p":0.95,"min_p":0,"max_tokens":1024,"messages":
[{"role":"system",   "content":"You are a helpful assistant./no_think"}
,{"role":"user",     "content":"你好"}
,{"role":"assistant","content":"你好！很高兴见到你。你可以问我任何问题，我会尽力帮助你。"}
,{"role":"user",     "content":"再见"}
]}
{"choices":[{"index":0,"finish_reason":"stop","message":{"role":"assistant","content":"再见！希望我们将来还有机会交流。祝你有一个美好的一天！"}}],
"usage":{"prompt_tokens":47,"completion_tokens":16,"total_tokens":63},
"timings":{"prompt_n":1,"prompt_ms":229.333,"prompt_per_token_ms":229.333,"prompt_per_second":4.36047145417363,"predicted_n":16,"predicted_ms":503.99,"predicted_per_token_ms":31.499375,"predicted_per_second":31.7466616401119},
"id":"chatcmpl-ipbhDUI79TqWNDlCp1NZkag8sfKuLEgt","object":"chat.completion","created":1740976033,"model":"gpt-3.5-turbo","system_fingerprint":"b4793-70680c48"}
--]]
------------------------------------------------------------------------------
local G = _G
G.url = 'http://127.0.0.1:8080/v1/chat/completions' -- default: 'http://127.0.0.1:8080/v1/chat/completions'
G.openai_api_key = nil -- default: nil
G.model = nil          -- default: nil
G.temperature = 0.6    -- default: 0.6,  disabled: 1
G.top_k = 20           -- default: 20,   disabled: 0
G.top_p = 0.95         -- default: 0.95, disabled: 1
G.min_p = 0            -- default: 0,    disabled: 0
G.repeat_last_n = 64   -- default: 64,   disabled: 0
G.repeat_penalty = 1   -- default: 1,    disabled: 0
G.max_tokens = -1      -- default: -1,   disabled: -1
G.seed = nil           -- default: nil
G.prompt = 'You are a helpful assistant.' -- default: 'You are a helpful assistant.'
G.debug = nil          -- default: nil
G.jsonFileName = 'openai.tmp.json'
G.jsonHighSize = 16 * 1024 -- for 4k context
G.jsonLowSize = G.jsonHighSize * 0.75
G.lineLimitSize = G.jsonHighSize * 0.2
G.filter_line_in = function(line, i)
	return line
end
G.filter_lines_in = function(lines, i)
	return lines
end
G.filter_line_out = function(res, i)
	res = res:gsub('^<think>.-</think>', ''):gsub('^<think>', ''):gsub('\r+', ''):gsub('^\n+', ''):gsub('\n+$', '')
	return res, '[' .. i .. ']' .. (res:find '\n' and '\n' or '') .. res .. '\n'
end
------------------------------------------------------------------------------
local ffi = require 'ffi'
ffi.cdef[[
int __stdcall MultiByteToWideChar(int cp, int flag, const char* src, int srclen, char* wdst, int wdstlen);
int __stdcall WideCharToMultiByte(int cp, int flag, const char* src, int srclen, char* dst, int dstlen, const char* defchar, int* used);
]]
local function mb2wc(src, cp)
	local srclen = #src
	local dst = ffi.typeof 'char[?]'(srclen * 2)
	return ffi.string(dst, ffi.C.MultiByteToWideChar(cp or 65001, 0, src, srclen, dst, srclen) * 2)
end
local function wc2mb(src, cp)
	local srclen = #src / 2
	local dstlen = srclen * 3
	local dst = ffi.typeof 'char[?]'(dstlen)
	return ffi.string(dst, ffi.C.WideCharToMultiByte(cp or 65001, 0, src, srclen, dst, dstlen, nil, nil))
end
local function utf8_local(s)
	return wc2mb(mb2wc(s), 1)
end
local function local_utf8(s)
	return wc2mb(mb2wc(s, 1))
end
G.utf8_local = utf8_local
G.local_utf8 = local_utf8
------------------------------------------------------------------------------
local function escapeCmd(cmd)
	return cmd:gsub('(\\+)"', function(s) return s .. s .. '"' end):gsub('(\\+)$', function(s) return s .. s end):gsub('"', '\\"')
end

local function genCmdHeader()
	return 'curl "' .. G.url .. '" -X POST -H "Content-Type: application/json"' .. (G.openai_api_key and (' -H "Authorization: Bearer ' .. G.openai_api_key .. '"') or '')
end

local function escapeJsonWithQuot(str)
	return string.format('%q', str or ''):gsub('\\\n', '\\n')
end

local tonumber = tonumber
local table = table
local concat = table.concat
local function genJsonHeader(noSpace)
	return concat{
		G.model and ('{"model":' .. escapeJsonWithQuot(G.model) .. ',') or '{',
		'"stream":false,"cache_prompt":true',
		G.temperature and (',"temperature":' .. tonumber(G.temperature)) or '',
		G.top_k and (',"top_k":' .. tonumber(G.top_k)) or '',
		G.top_p and (',"top_p":' .. tonumber(G.top_p)) or '',
		G.min_p and (',"min_p":' .. tonumber(G.min_p)) or '',
		G.repeat_last_n and (',"repeat_last_n":' .. tonumber(G.repeat_last_n)) or '',
		G.repeat_penalty and (',"repeat_penalty":' .. tonumber(G.repeat_penalty)) or '',
		G.max_tokens and (',"max_tokens":' .. tonumber(G.max_tokens)) or '',
		G.seed and (',"seed":' .. tonumber(G.seed)) or '',
		noSpace and ',"messages":[{"role":"system","content":' or ',"messages":\n[{"role":"system",   "content":',
		escapeJsonWithQuot(G.prompt), noSpace and '}' or '}\n',
	}
end

local io = io
local open = io.open
local write = io.write
local function callAiCmd(cmd)
	if G.debug then
		write('cmd: ', utf8_local(cmd), '\n')
	else
		cmd = cmd .. ' 2>nul'
	end
	local f = io.popen(utf8_local(cmd), 'rb')
	local rawRes = f:read '*a'
	f:close()
--	local tokens = rawRes:find '"total_tokens"%s*:%s*(%d+)'
--	write('tokens = ', tokens, '\n')
	local _, q = rawRes:find '"content"%s*:%s*"'
	if not q then
		return nil, cmd, rawRes
	end
	if G.debug then
		write('rawRes: ', utf8_local(rawRes), '\n')
	end
	local p = q
	local res = rawRes
	while q and q < #res do
		local b = res:byte(q + 1)
		if b == 0x22 then -- '"'
			res = res:sub(p + 1, q)
			break
		end
		q = q + (b == 0x5c and 2 or 1) -- '\'
	end
	return (res:gsub('\\(.)', function(c)
			if c == 'b' then return '\b'
		elseif c == 'f' then return '\f'
		elseif c == 'n' then return '\n'
		elseif c == 'r' then return '\r'
		elseif c == 't' then return '\t'
		-- elseif c == 'u' then TODO
		else return c
		end
	end)), cmd, rawRes
end

G.callAiFile = function(jsonFileName)
	return callAiCmd(genCmdHeader() .. ' -T "' .. jsonFileName .. '"')
end

G.callAiStr = function(str)
	local json = genJsonHeader(true) .. ',{"role":"user","content":' .. escapeJsonWithQuot(str) .. '}]}'
	return callAiCmd(genCmdHeader() .. ' -d "' .. escapeCmd(json) .. '"')
end
------------------------------------------------------------------------------
local error = error
local tostring = tostring
local inputFileName, outputFileName
local args = {...}
if #args == 3 then
	dofile(args[1])
	inputFileName, outputFileName = args[2], args[3]
elseif #args == 2 then
	inputFileName, outputFileName = args[1], args[2]
else
	if #args == 1 then
		local line = args[1]
		write('> ', line, '\n')
		local lastRes, cmd, rawRes = G.callAiStr(local_utf8(line))
		if lastRes then
			write('= ', utf8_local(lastRes), '\n')
		else
			error('ERROR: callAiStr failed:\ncmd: ' .. utf8_local(tostring(cmd)) .. '\nres: ' .. utf8_local(tostring(rawRes)))
		end
	else
		write 'INFO: usage: luajit openai.lua [settings.lua] input.txt output.txt\n'
	end
	return
end

local jsons = { [0] = genJsonHeader() }
local jsonSize = #jsons[0]
local jsonFileNameLocal = utf8_local(G.jsonFileName)
local remove = table.remove
local function saveJsons()
	if jsonSize > G.jsonHighSize then
		local n, oldSize = 0, jsonSize
		while jsons[2] and jsonSize > G.jsonLowSize do
			jsonSize = jsonSize - #remove(jsons, 1) - #remove(jsons, 1)
			n = n + 1
		end
		write('INFO: remove ', n, ' pairs, size = ', oldSize, ' => ', jsonSize, '\n')
	end
	local fjson = open(jsonFileNameLocal, 'wb')
	if not fjson then
		error('ERROR: can not create: ' .. jsonFileNameLocal)
	end
	for i = 0, #jsons do
		fjson:write(jsons[i])
	end
	fjson:write ']}\n'
	fjson:close()
end

local fout = open(outputFileName, 'wb')
if not fout then
	error('ERROR: can not create: ' .. outputFileName)
end
local lastRes, cmd, rawRes
local i, n, lines = 0, 0, {}
local function callAi()
	local arg = concat(lines)
	arg = G.filter_lines_in(arg)
	if arg then
		if lastRes then
			jsons[#jsons + 1] = ',{"role":"assistant","content":' .. escapeJsonWithQuot(lastRes) .. '}\n'
			jsonSize = jsonSize + #jsons[#jsons]
		end
			jsons[#jsons + 1] = ',{"role":"user",     "content":' .. escapeJsonWithQuot(arg) .. '}\n'
			jsonSize = jsonSize + #jsons[#jsons]
		saveJsons()
		lastRes, cmd, rawRes = G.callAiFile(G.jsonFileName)
		if not lastRes then
			error('ERROR: callAiFile(' .. jsonFileNameLocal .. ') failed:\ncmd: ' .. utf8_local(tostring(cmd)) .. '\nrawRes: ' .. utf8_local(tostring(rawRes)))
		end
		write('[', i, ']', (lastRes:find '\n' and '\n' or ''), utf8_local(lastRes:gsub('^<think>%s*</think>\n*', '')), '\n')
		lastRes, arg = G.filter_line_out(lastRes, i)
		fout:write(arg)
		fout:flush()
	end
end
for line in io.lines(inputFileName) do
	line = G.filter_line_in(line, i + 1)
	if line then
		n = n + #line
		if n > G.lineLimitSize and lines[1] then
			callAi()
			n = #line
			lines = {}
		end
		lines[#lines + 1] = line
		lines[#lines + 1] = '\n'
		i = i + 1
		write('<', i , '>', utf8_local(line), '\n')
	else
		i = i + 1
	end
end
if lines[1] then
	callAi()
end
fout:close()
if lastRes then
	jsons[#jsons + 1] = ',{"role":"assistant","content":' .. escapeJsonWithQuot(lastRes) .. '}\n'
	saveJsons()
end
write 'DONE!\n'
